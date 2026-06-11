# set xhigh effort for Opus 4.7
# export CLAUDE_CODE_EFFORT_LEVEL=xhigh

# Per-machine `host` label for Claude Code's OpenTelemetry metrics, derived from
# the machine (never hardcoded) so each workstation self-identifies on the
# `claude` Grafana dashboard. Lowercased to match host naming (computer, …).
export OTEL_RESOURCE_ATTRIBUTES="host=${(L)$(scutil --get LocalHostName 2>/dev/null || hostname -s)}"
