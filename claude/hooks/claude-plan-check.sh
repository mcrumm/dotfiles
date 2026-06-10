#!/usr/bin/env bash
# PostToolUse hook — validate project-plan frontmatter the moment Claude
# saves it. Reads the hook payload as JSON on stdin (fields: tool_name,
# tool_input.file_path, ...), path-filters to plan files (PROJECT.md or
# .project/plans/*.md), and runs `lab project check` on the edited file.
#
# Exit 2 feeds the validator's one-line reasons back to Claude as tool
# feedback, so the schema error is fixed in the same turn it was made —
# this is the in-session half of the plan-checker loop (the pre-commit
# hook and CI catch what this can't see, e.g. Bash-tool edits).
#
# Fail-open by design: no jq, no lab, or a non-plan file must never
# block an edit. Schema reference: homelab/homelab → docs/projects.md.
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -n "$file" ] || exit 0
[ -f "$file" ] || exit 0

case "$file" in
  */.project/plans/*.md | */PROJECT.md | PROJECT.md) ;;
  *) exit 0 ;;
esac

LAB=$(command -v lab || true)
[ -n "$LAB" ] || LAB=/usr/local/bin/lab
[ -x "$LAB" ] || exit 0

out=$("$LAB" project check "$file" 2>&1)
status=$?
# A lab predating the verb must not block edits — fail open until
# `lab update` delivers a binary that knows `project check`.
if printf '%s' "$out" | grep -q 'unknown command "project"'; then
  exit 0
fi
if [ "$status" -ne 0 ]; then
  printf '%s\n' "$out" >&2
  exit 2
fi
exit 0
