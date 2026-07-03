#!/usr/bin/env bash
# statusline.sh - minimal Claude Code statusline that ALSO writes the context state file
# consumed by context-prompt-check.sh (40% ask) and context-monitor.sh (70% emergency).
# Without this state file those hooks silently no-op.
#
# Already have your own statusline? Keep it - just port the "state file" block below into it.
# Registered by install.sh only if settings.json has no statusLine yet (never clobbers yours).

input=$(cat)

if ! command -v jq &>/dev/null; then
  printf 'statusline: jq not found'
  exit 0
fi

model=$(printf '%s' "$input" | jq -r '.model.display_name // empty')
pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')

# State file: {"ctx_pct": N, "ts": unix-seconds} - project-local + /tmp fallback
if [ -n "$pct" ]; then
  state_dir="${CLAUDE_PROJECT_DIR:-/tmp}/.claude/hooks/state"
  mkdir -p "$state_dir" 2>/dev/null
  printf '{"ctx_pct": %s, "ts": %s}\n' "$pct" "$(date +%s)" > "$state_dir/context-pressure.json" 2>/dev/null
  printf '{"ctx_pct": %s, "ts": %s}\n' "$pct" "$(date +%s)" > "/tmp/claude-context-monitor.json" 2>/dev/null
fi

out="$model"
if [ -n "$pct" ]; then
  ipct=$(printf '%.0f' "$pct")
  filled=$(( ipct / 10 )); empty=$(( 10 - filled ))
  bar=""
  [ "$filled" -gt 0 ] && printf -v f "%${filled}s" && bar="${f// /▓}"
  [ "$empty"  -gt 0 ] && printf -v e "%${empty}s" && bar="${bar}${e// /░}"
  out="${out:+$out }${bar} ${ipct}%"
fi
printf '%s' "$out"
