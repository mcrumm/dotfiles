#!/usr/bin/env bash
# Detached per-turn poller, spawned by claude-ask-start.sh. Watches the session
# transcript; when the most recent AskUserQuestion has no answer yet and has
# been pending >= threshold, POSTs one "waiting on you" notification to ntfy
# (at most once per question). Killed by claude-ask-stop.sh at end of turn;
# also self-terminates after a safety cap. Paired with claude-ask-start.sh.
#
# Why poll the transcript instead of hooking the tool: a PreToolUse hook on
# AskUserQuestion corrupts the answers the tool returns
# (github.com/anthropics/claude-code/issues/12031), so we never hook it. The
# transcript records the tool_use at ask-time and the tool_result at
# answer-time, so an unanswered question shows up as an ask line with no
# matching result line — which is exactly what we look for here.
#
# NOTE: intentionally no `set -e` — a long-lived loop must survive a transient
# jq/stat/curl hiccup rather than die on it.
set -uo pipefail

transcript=${1:-}
cwd=${2:-}
threshold=${3:-120}
pidfile=${4:-}
[ -z "$transcript" ] && exit 0

NTFY_URL=${CLAUDE_NTFY_URL:-http://ntfy.lan/claude-code}
POLL_SECS=${CLAUDE_NTFY_ASK_POLL_SECS:-15}
MAX_SECS=${CLAUDE_NTFY_ASK_MAX_SECS:-14400}   # 4h cap; backstop against zombies

# Clean shutdown: kill the in-flight sleep and drop our pidfile. The sleep runs
# in the background and we wait on it (below) so this trap interrupts it
# immediately — a foreground `sleep` would block the kill for up to POLL_SECS.
sleep_pid=""
cleanup() {
  [ -n "$sleep_pid" ] && kill "$sleep_pid" 2>/dev/null
  [ -n "$pidfile" ] && rm -f "$pidfile" 2>/dev/null
  return 0
}
trap 'cleanup; exit 0' TERM INT
trap cleanup EXIT

# Print a compact JSON object {id,ts,q,n} for the latest *unanswered*
# AskUserQuestion, or nothing if none is pending. ts is epoch seconds.
scan() {
  jq -s -c '
    def epoch: sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601;
    def content: (.message.content // []) | if type == "array" then . else [] end;
    ([ .[] | . as $l | ($l | content)[]
        | select(.type == "tool_use" and .name == "AskUserQuestion")
        | { id,
            ts: ($l.timestamp | epoch),
            q:  (.input.questions[0].question // .input.questions[0].header // ""),
            n:  (.input.questions | length) } ]) as $asks
    | ([ .[] | (. | content)[] | select(.type == "tool_result") | .tool_use_id ]) as $res
    | ($asks | last) as $q
    | if ($q != null) and (($res | index($q.id)) | not) then $q else empty end
  ' "$transcript" 2>/dev/null
}

started=$(date +%s)
notified=" "        # space-delimited set of tool_use ids we've already pinged
last_mtime=""       # only re-scan when the transcript actually changes
pending=0
p_id=""; p_ts=0; p_q=""; p_n=1

while :; do
  now=$(date +%s)
  [ $(( now - started )) -ge "$MAX_SECS" ] && exit 0

  if [ -f "$transcript" ]; then
    # While a question is pending the file is quiet, so this collapses to a
    # cheap stat + arithmetic; we only pay for jq when the transcript grows.
    m=$(stat -f %m "$transcript" 2>/dev/null || echo "")
    if [ "$m" != "$last_mtime" ]; then
      last_mtime="$m"
      obj=$(scan)
      if [ -n "$obj" ]; then
        pending=1
        p_id=$(printf '%s' "$obj" | jq -r '.id // ""')
        p_ts=$(printf '%s' "$obj" | jq -r '.ts // 0')
        p_q=$(printf '%s'  "$obj" | jq -r '.q // ""')
        p_n=$(printf '%s'  "$obj" | jq -r '.n // 1')
      else
        pending=0
      fi
    fi

    if [ "$pending" -eq 1 ] 2>/dev/null; then
      case "$notified" in
        *" $p_id "*) : ;;   # already pinged for this question
        *)
          elapsed=$(( now - p_ts ))
          if [ "$elapsed" -ge "$threshold" ] 2>/dev/null; then
            notified="${notified}${p_id} "
            mins=$(( elapsed / 60 )); secs=$(( elapsed % 60 ))
            if [ "$mins" -gt 0 ]; then waited="${mins}m${secs}s"; else waited="${secs}s"; fi
            short_cwd=${cwd/#$HOME/\~}
            body="Unanswered for ${waited} · ${short_cwd}"
            [ "$p_n" -gt 1 ] 2>/dev/null && body="${body} · ${p_n} questions"
            [ -n "$p_q" ] && body="${body} · \"${p_q}\""
            curl -fsS -m 5 \
              -H "Title: Claude is waiting on you" \
              -H "Tags: speech_balloon" \
              -H "Priority: high" \
              -d "$body" \
              "$NTFY_URL" >/dev/null 2>&1 || true
          fi
          ;;
      esac
    fi
  fi

  # Interruptible sleep: background it and wait, so TERM/INT (from the Stop
  # hook) ends the poller right away instead of after the full interval.
  sleep "$POLL_SECS" & sleep_pid=$!
  wait "$sleep_pid" 2>/dev/null || true
  sleep_pid=""
done
