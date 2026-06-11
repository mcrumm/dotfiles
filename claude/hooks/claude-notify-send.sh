#!/usr/bin/env bash
# Detached delayed sender for claude-notify.sh. Waits a grace period and POSTs to
# ntfy ONLY if the session stayed quiet — i.e. you didn't resolve the prompt
# (approve / deny / respond) in time. If the transcript changed during the wait,
# you handled it, so we stay silent. Spawned via nohup so it outlives the hook's
# timeout; self-terminating, no pidfile. Paired with claude-notify.sh.
#
# Baseline mtime is captured HERE (a beat after the hook fired), so the
# triggering tool_use line has already flushed to the transcript — any change
# during the wait is *your* response, not the event that triggered us.
#
# NOTE: no `set -e` — a notification path must never fail the turn.
set -uo pipefail

delay=${1:-120}
transcript=${2:-}
title=${3:-Claude}
tags=${4:-bell}
prio=${5:-default}
body=${6:-}

NTFY_URL=${CLAUDE_NTFY_URL:-http://ntfy.lan/claude-code}
PROBE_LOG=${CLAUDE_NTFY_PROBE_LOG:-}
probe() { [ -n "$PROBE_LOG" ] && printf '%s %s\n' "$(date '+%H:%M:%S')" "$1" >> "$PROBE_LOG"; return 0; }

baseline=""
[ -n "$transcript" ] && [ -f "$transcript" ] && baseline=$(stat -f %m "$transcript" 2>/dev/null || echo "")

sleep "$delay"

# Transcript advanced during the wait → you responded → stay silent.
if [ -n "$baseline" ] && [ -f "$transcript" ]; then
  now_m=$(stat -f %m "$transcript" 2>/dev/null || echo "")
  if [ -n "$now_m" ] && [ "$now_m" != "$baseline" ]; then
    probe "drop   resolved within ${delay}s title=\"$title\""
    exit 0
  fi
fi

probe "send   after ${delay}s title=\"$title\" body=\"$body\""
curl -fsS -m 5 \
  -H "Title: ${title}" \
  -H "Tags: ${tags}" \
  -H "Priority: ${prio}" \
  -d "$body" \
  "$NTFY_URL" >/dev/null 2>&1 || probe "curl   FAILED title=\"$title\""

exit 0
