#!/usr/bin/env bash
# context-prompt-check.sh — UserPromptSubmit hook
# Reads exact context % from the state file written by statusline.sh.
# At 40%: asks the user whether to wrap now, finish then wrap, or continue.
# Tracks the last-prompted % to avoid repeating the same alert every message.
#
# Only monitors the model's context window. The 5-hour and 7-day rate limits
# are separate concerns and are NOT tracked here.
#
# Hook type: UserPromptSubmit (matcher: "")
# Timeout: 5s

# Load shared thresholds — keeps WARN_PCT and EMERGENCY_PCT in one place
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/context-thresholds.sh" ]; then
  source "$SCRIPT_DIR/context-thresholds.sh"
fi
WARN_PCT="${CONTEXT_WARN_PCT:-40}"
STATE_FILE="/tmp/claude-context-monitor.json"
LAST_WARN_FILE="/tmp/claude-context-last-warn.txt"

# Try project-local state file first (more accurate when CLAUDE_PROJECT_DIR is set)
PROJECT_STATE="${CLAUDE_PROJECT_DIR:+${CLAUDE_PROJECT_DIR}/.claude/hooks/state/context-pressure.json}"
if [ -n "$PROJECT_STATE" ] && [ -f "$PROJECT_STATE" ]; then
  STATE_FILE="$PROJECT_STATE"
fi

if [ ! -f "$STATE_FILE" ]; then
  exit 0
fi

# Read context % — file contains {"ctx_pct": 23, "ts": 1234567890}
CTX_PCT=$(python3 -c "
import json, sys
try:
    d = json.load(open('$STATE_FILE'))
    print(d.get('ctx_pct', 0))
except Exception:
    print(0)
" 2>/dev/null || echo 0)

CTX_INT=$(printf '%.0f' "${CTX_PCT:-0}" 2>/dev/null || echo 0)

if [ "$CTX_INT" -lt "$WARN_PCT" ]; then
  # Below threshold — clear last-warn so we re-alert if it goes up again
  echo 0 > "$LAST_WARN_FILE" 2>/dev/null
  exit 0
fi

# Avoid repeating the same alert within 5% increments
LAST_WARN=$(cat "$LAST_WARN_FILE" 2>/dev/null || echo 0)
BUCKET=$(( CTX_INT / 5 ))
LAST_BUCKET=$(( LAST_WARN / 5 ))

if [ "$BUCKET" -le "$LAST_BUCKET" ]; then
  exit 0
fi

echo "$CTX_INT" > "$LAST_WARN_FILE" 2>/dev/null

echo "{\"hookSpecificOutput\": {\"hookEventName\": \"UserPromptSubmit\", \"additionalContext\": \"CONTEXT WINDOW AT ${CTX_INT}%: Before responding, tell the user: 'Context is at ${CTX_INT}%. Do you want to (1) wrap up this session now with /wrap, (2) finish what you are working on and then wrap, or (3) continue as normal?' Wait for their answer before doing anything else. Do NOT invoke /wrap automatically.\"}}"
