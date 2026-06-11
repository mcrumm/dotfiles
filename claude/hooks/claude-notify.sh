#!/usr/bin/env bash
# Notification hook — relay Claude Code Notification events to ntfy so the
# "Claude is blocked on you" signals reach your phone. Reads the hook payload as
# JSON on stdin (fields: notification_type, message, cwd, transcript_path, ...).
# Shares CLAUDE_NTFY_URL with claude-ask-poll.sh so both pingers hit one topic.
#
# Forwards only the notification_types in CLAUDE_NTFY_NOTIFY_TYPES (a space-
# delimited allowlist). Two delivery modes:
#   - idle_prompt        → sent immediately (Claude Code already debounced it 60s)
#   - permission_prompt  → DEBOUNCED: a detached sender (claude-notify-send.sh)
#     elicitation_dialog   waits CLAUDE_NTFY_DELAY_SECS and only pings if you
#                          haven't resolved the prompt by then. A quick approve
#                          stays silent; only genuinely-missed prompts ping you.
#
# Set CLAUDE_NTFY_PROBE_LOG=/path to append a breadcrumb per event.
#
# NOTE: no `set -e` — a notification path must never fail the turn.
set -uo pipefail

ALLOW=${CLAUDE_NTFY_NOTIFY_TYPES:-"permission_prompt idle_prompt elicitation_dialog"}
DELAY=${CLAUDE_NTFY_DELAY_SECS:-120}
NTFY_URL=${CLAUDE_NTFY_URL:-http://ntfy.lan/claude-code}
PROBE_LOG=${CLAUDE_NTFY_PROBE_LOG:-}
probe() { [ -n "$PROBE_LOG" ] && printf '%s %s\n' "$(date '+%H:%M:%S')" "$1" >> "$PROBE_LOG"; return 0; }

input=$(cat)
ntype=$(printf '%s'      "$input" | jq -r '.notification_type // "unknown"' 2>/dev/null)
msg=$(printf '%s'        "$input" | jq -r '.message // ""'                   2>/dev/null)
cwd=$(printf '%s'        "$input" | jq -r '.cwd // ""'                       2>/dev/null)
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // ""'          2>/dev/null)

# Forward only allowlisted types; everything else is a quiet no-op.
case " $ALLOW " in
  *" $ntype "*) : ;;
  *) probe "skip   type=$ntype"; exit 0 ;;
esac

short_cwd=${cwd/#$HOME/\~}

# title / tags / priority / per-type debounce delay (0 = send now)
delay=0
case "$ntype" in
  idle_prompt)        title="Claude is waiting on you"; tags="hourglass_flowing_sand"; prio="default"; delay=0      ;;
  permission_prompt)  title="Claude needs permission";  tags="lock";                   prio="high";    delay=$DELAY ;;
  elicitation_dialog) title="Claude needs input (MCP)"; tags="speech_balloon";         prio="default"; delay=$DELAY ;;
  *)                  title="Claude notification";      tags="bell";                   prio="default"; delay=0      ;;
esac

body="${msg:-$ntype}"
[ -n "$short_cwd" ] && body="${body} · ${short_cwd}"

if [ "$delay" -gt 0 ] 2>/dev/null; then
  # Debounced: hand off to a detached sender that pings only if still unresolved.
  probe "queue  type=$ntype delay=${delay}s body=\"$body\""
  sender="$(dirname "$0")/claude-notify-send.sh"
  nohup "$sender" "$delay" "$transcript" "$title" "$tags" "$prio" "$body" >/dev/null 2>&1 &
  disown 2>/dev/null || true
  exit 0
fi

# Immediate (idle_prompt): Claude already waited 60s, so ping now.
probe "send   type=$ntype prio=$prio body=\"$body\""
curl -fsS -m 5 \
  -H "Title: ${title}" \
  -H "Tags: ${tags}" \
  -H "Priority: ${prio}" \
  -d "$body" \
  "$NTFY_URL" >/dev/null 2>&1 || probe "curl   FAILED type=$ntype"

exit 0
