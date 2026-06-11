#!/usr/bin/env bash
# Stop hook — read the start timestamp written by claude-turn-start.sh,
# compute elapsed; if >= threshold, POST a notification to ntfy.
set -euo pipefail

THRESHOLD_SECS=${CLAUDE_NTFY_THRESHOLD_SECS:-300}
NTFY_URL=${CLAUDE_NTFY_URL:-http://ntfy.lan/claude-code}

input=$(cat)
session_id=$(printf '%s' "$input" | jq -r '.session_id // empty')
[ -z "$session_id" ] && exit 0

state_file="${TMPDIR:-/tmp}/claude-turn/$session_id.json"
[ ! -f "$state_file" ] && exit 0

start=$(jq -r '.start // "0"' "$state_file")
prompt=$(jq -r '.prompt // ""' "$state_file")
cwd=$(jq -r '.cwd // ""' "$state_file")
rm -f "$state_file"

[ "$start" = "0" ] && exit 0

now=$(date +%s)
elapsed=$(( now - start ))
[ "$elapsed" -lt "$THRESHOLD_SECS" ] && exit 0

if [ "$elapsed" -ge 3600 ]; then
  duration=$(printf '%dh%dm' $((elapsed/3600)) $(((elapsed%3600)/60)))
else
  duration=$(printf '%dm%ds' $((elapsed/60)) $((elapsed%60)))
fi

short_cwd=${cwd/#$HOME/\~}
body="Done in ${duration} · ${short_cwd}"
[ -n "$prompt" ] && body="${body} · \"${prompt}\""

curl -fsS -m 5 \
  -H "Title: Claude turn complete" \
  -H "Tags: white_check_mark" \
  -H "Priority: default" \
  -d "$body" \
  "$NTFY_URL" >/dev/null 2>&1 || true

exit 0
