#!/usr/bin/env bash
# UserPromptSubmit hook — record the start epoch + prompt snippet so the
# companion Stop hook can compute elapsed time and ping ntfy if the turn
# ran long. Paired with claude-turn-stop.sh.
set -euo pipefail

input=$(cat)
session_id=$(printf '%s' "$input" | jq -r '.session_id // empty')
[ -z "$session_id" ] && exit 0

state_dir="${TMPDIR:-/tmp}/claude-turn"
mkdir -p "$state_dir"

# Drop any state files older than 24h — abandoned sessions, missed Stop
# events. Bounded cleanup, never fails the hook.
find "$state_dir" -type f -mtime +1 -delete 2>/dev/null || true

prompt=$(printf '%s' "$input" | jq -r '.prompt // empty')
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
first_line=$(printf '%s' "$prompt" | head -n1 | cut -c1-160)

jq -n \
  --arg start "$(date +%s)" \
  --arg prompt "$first_line" \
  --arg cwd "$cwd" \
  '{start: $start, prompt: $prompt, cwd: $cwd}' \
  > "$state_dir/$session_id.json"

exit 0
