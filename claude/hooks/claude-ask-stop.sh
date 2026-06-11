#!/usr/bin/env bash
# Stop hook — tear down the per-turn AskUserQuestion poller spawned by
# claude-ask-start.sh. The turn is over, so any pending-question watch is moot.
# Paired with claude-ask-start.sh and claude-ask-poll.sh.
set -euo pipefail

input=$(cat)
session_id=$(printf '%s' "$input" | jq -r '.session_id // empty')
[ -z "$session_id" ] && exit 0

pidfile="${TMPDIR:-/tmp}/claude-ask/$session_id.pid"
[ ! -f "$pidfile" ] && exit 0

pid=$(cat "$pidfile" 2>/dev/null || echo "")
[ -n "$pid" ] && kill "$pid" 2>/dev/null || true
rm -f "$pidfile"

exit 0
