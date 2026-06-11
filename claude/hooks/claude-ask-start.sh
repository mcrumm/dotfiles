#!/usr/bin/env bash
# UserPromptSubmit hook — (re)start the per-turn poller that watches the session
# transcript for an AskUserQuestion left unanswered too long and pings ntfy.
# Runs synchronously (NOT async) but does almost nothing: it spawns a detached
# watcher and exits immediately, so the watcher outlives this hook. Paired with
# claude-ask-poll.sh (the watcher) and claude-ask-stop.sh (Stop hook teardown).
set -euo pipefail

THRESHOLD_SECS=${CLAUDE_NTFY_ASK_THRESHOLD_SECS:-120}
# 0 (or non-positive) disables the unanswered-question notification entirely.
[ "$THRESHOLD_SECS" -le 0 ] 2>/dev/null && exit 0

input=$(cat)
session_id=$(printf '%s' "$input" | jq -r '.session_id // empty')
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
[ -z "$session_id" ] && exit 0
[ -z "$transcript" ] && exit 0

state_dir="${TMPDIR:-/tmp}/claude-ask"
mkdir -p "$state_dir"

# Bounded cleanup of pidfiles left by sessions that never sent Stop.
find "$state_dir" -type f -mtime +1 -delete 2>/dev/null || true

pidfile="$state_dir/$session_id.pid"

# Tear down a poller lingering from a previous turn (Stop should have, but be
# defensive — a stale one would double-notify).
if [ -f "$pidfile" ]; then
  oldpid=$(cat "$pidfile" 2>/dev/null || echo "")
  [ -n "$oldpid" ] && kill "$oldpid" 2>/dev/null || true
  rm -f "$pidfile"
fi

# Detach the watcher: nohup + full fd redirection so the harness doesn't wait on
# our stdout pipe, and the process survives this hook returning.
watcher="$(dirname "$0")/claude-ask-poll.sh"
nohup "$watcher" "$transcript" "$cwd" "$THRESHOLD_SECS" "$pidfile" >/dev/null 2>&1 &
echo $! > "$pidfile"
disown 2>/dev/null || true

exit 0
