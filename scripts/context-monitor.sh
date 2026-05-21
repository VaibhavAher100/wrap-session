#!/usr/bin/env bash
# context-monitor.sh — PostToolUse hook (emergency backup only)
# Primary context monitoring is done by context-prompt-check.sh (UserPromptSubmit).
# This fires during autonomous runs where the user isn't sending messages.
# Threshold is 70% (not 40%) — only for emergencies when UserPromptSubmit can't fire.
#
# Uses the state file written by statusline.sh for accurate % (no file-size guessing).
# Falls back to JSONL file-size estimation if state file is stale or missing.
#
# Hook type: PostToolUse (matcher: ".*")
# Timeout: 5s

# Load shared thresholds — keeps WARN_PCT and EMERGENCY_PCT in one place
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/context-thresholds.sh" ]; then
  source "$SCRIPT_DIR/context-thresholds.sh"
fi
EMERGENCY_PCT="${CONTEXT_EMERGENCY_PCT:-70}"
STATE_FILE="/tmp/claude-context-monitor.json"

# Try project-local state file first
PROJECT_STATE="${CLAUDE_PROJECT_DIR:+${CLAUDE_PROJECT_DIR}/.claude/hooks/state/context-pressure.json}"
if [ -n "$PROJECT_STATE" ] && [ -f "$PROJECT_STATE" ]; then
  STATE_FILE="$PROJECT_STATE"
fi

CTX_INT=0

if [ -f "$STATE_FILE" ]; then
  # Check if state file is fresh (written within last 120 seconds)
  INPUT=$(cat)
  NOW=$(date +%s)
  TS=$(python3 -c "
import json
try:
    d = json.load(open('$STATE_FILE'))
    print(d.get('ts', 0))
except Exception:
    print(0)
" 2>/dev/null || echo 0)
  AGE=$(( NOW - TS ))

  if [ "$AGE" -lt 120 ]; then
    CTX_PCT=$(python3 -c "
import json
try:
    d = json.load(open('$STATE_FILE'))
    print(d.get('ctx_pct', 0))
except Exception:
    print(0)
" 2>/dev/null || echo 0)
    CTX_INT=$(printf '%.0f' "${CTX_PCT:-0}" 2>/dev/null || echo 0)
  fi
else
  INPUT=$(cat)
fi

# No fallback to file-size estimation — that approach is model-specific and inaccurate.
# If state file is missing or stale, skip the check. Statusline writes the state file
# continuously so a stale state means the statusline isn't running, not that context is full.

if [ "$CTX_INT" -ge "$EMERGENCY_PCT" ]; then
  echo "{\"hookSpecificOutput\": {\"hookEventName\": \"PostToolUse\", \"additionalContext\": \"EMERGENCY: Context window at ${CTX_INT}%. Stop all current work immediately. Tell the user the context is critically full and run /wrap now before continuing.\"}}"
fi

exit 0
