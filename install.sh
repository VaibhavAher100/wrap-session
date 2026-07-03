#!/bin/sh
# wrap-session installer
# Run from inside your project folder:
#   curl -fsSL https://raw.githubusercontent.com/VaibhavAher100/wrap-session/main/install.sh | sh
#
# Options (set as env vars before piping):
#   WRAP_LOG_DIR=logs   - where to store session logs (default: logs)
#   WRAP_NO_HOOKS=1     - skip settings.json hook registration

set -e

REPO="https://raw.githubusercontent.com/VaibhavAher100/wrap-session/main"
TODAY=$(date +%Y-%m-%d)
LOG_DIR="${WRAP_LOG_DIR:-logs}"

echo "Installing wrap-session..."
echo "  Log directory: $LOG_DIR"

# Check curl
if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required. Install curl and retry."
  exit 1
fi

# Create folders
mkdir -p .claude/commands
mkdir -p .claude/scripts
mkdir -p "$LOG_DIR/sessions"

# Download commands (-f: fail on 404, no silent swallow)
for cmd in wrap unwrap wrap-list wrap-find wrap-repair; do
  tmpfile=$(mktemp)
  if ! curl -fsSL "$REPO/commands/${cmd}.md" -o "$tmpfile"; then
    echo "Error: failed to download commands/${cmd}.md (check network or repo path)"
    rm -f "$tmpfile"
    exit 1
  fi
  sed "s|logs/|${LOG_DIR}/|g" "$tmpfile" > ".claude/commands/${cmd}.md"
  rm -f "$tmpfile"
  echo "  + .claude/commands/${cmd}.md"
done

# Download hook scripts (same logs/ -> LOG_DIR substitution as the commands)
for script in context-thresholds context-monitor context-prompt-check change-ledger statusline; do
  tmpfile=$(mktemp)
  if ! curl -fsSL "$REPO/scripts/${script}.sh" -o "$tmpfile"; then
    echo "Error: failed to download scripts/${script}.sh"
    rm -f "$tmpfile"
    exit 1
  fi
  sed "s|logs/|${LOG_DIR}/|g" "$tmpfile" > ".claude/scripts/${script}.sh"
  rm -f "$tmpfile"
  chmod +x ".claude/scripts/${script}.sh"
  echo "  + .claude/scripts/${script}.sh"
done

# Register hooks in .claude/settings.json
if [ -z "$WRAP_NO_HOOKS" ]; then
  SETTINGS=".claude/settings.json"
  HOOK_PROMPT='bash ".claude/scripts/context-prompt-check.sh"'
  HOOK_MONITOR='bash ".claude/scripts/context-monitor.sh" 2>/dev/null || true'
  HOOK_LEDGER='bash ".claude/scripts/change-ledger.sh" 2>/dev/null || true'
  STATUSLINE_CMD='bash ".claude/scripts/statusline.sh"'

  if [ ! -f "$SETTINGS" ]; then
    cat > "$SETTINGS" << SETTINGS_EOF
{
  "statusLine": { "type": "command", "command": "$STATUSLINE_CMD" },
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [{ "type": "command", "command": "$HOOK_PROMPT", "timeout": 5 }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": ".*",
        "hooks": [{ "type": "command", "command": "$HOOK_MONITOR", "timeout": 5 }]
      },
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [{ "type": "command", "command": "$HOOK_LEDGER", "timeout": 5 }]
      }
    ]
  }
}
SETTINGS_EOF
    echo "  + .claude/settings.json (created with hooks)"
  elif command -v python3 >/dev/null 2>&1; then
    python3 << PYEOF
import json

path = "$SETTINGS"
with open(path) as f:
    s = json.load(f)

s.setdefault("hooks", {})

ups = s["hooks"].setdefault("UserPromptSubmit", [])
prompt_cmd = '$HOOK_PROMPT'
already = any(
    h.get("command") == prompt_cmd
    for entry in ups
    for h in entry.get("hooks", [])
)
if not already:
    ups.append({"hooks": [{"type": "command", "command": prompt_cmd, "timeout": 5}]})

ptu = s["hooks"].setdefault("PostToolUse", [])
monitor_cmd = '$HOOK_MONITOR'
already = any(
    h.get("command") == monitor_cmd
    for entry in ptu
    for h in entry.get("hooks", [])
)
if not already:
    ptu.append({"matcher": ".*", "hooks": [{"type": "command", "command": monitor_cmd, "timeout": 5}]})

ledger_cmd = '$HOOK_LEDGER'
already = any(
    h.get("command") == ledger_cmd
    for entry in ptu
    for h in entry.get("hooks", [])
)
if not already:
    ptu.append({"matcher": "Write|Edit|MultiEdit", "hooks": [{"type": "command", "command": ledger_cmd, "timeout": 5}]})

# Register the bundled statusline ONLY if none is configured - never clobber the user's own.
# (The context hooks need SOME statusline writing the ctx_pct state file; if the user keeps
# theirs, they must port the state-file block from scripts/statusline.sh into it.)
if "statusLine" not in s:
    s["statusLine"] = {"type": "command", "command": '$STATUSLINE_CMD'}
else:
    print("  ! existing statusLine kept - port the state-file block from scripts/statusline.sh")

with open(path, "w") as f:
    json.dump(s, f, indent=2)
print("  + .claude/settings.json (hooks merged into existing)")
PYEOF
  else
    echo "  ! settings.json exists but Python not available for merge."
    echo "    Add hooks manually — see README for the JSON snippet."
  fi
fi

# Seed logs/state.md
if [ ! -f "$LOG_DIR/state.md" ]; then
cat > "$LOG_DIR/state.md" << STATE_EOF
---
updated: $TODAY
---

# Project State

> [!info] Living document - Claude overwrites this each session. Last session: none

## In Progress

## Open Items

## Health

## User Working Preferences
STATE_EOF
  echo "  + $LOG_DIR/state.md"
fi

# Seed logs/decisions.md
if [ ! -f "$LOG_DIR/decisions.md" ]; then
cat > "$LOG_DIR/decisions.md" << DECISIONS_EOF
# Decision Log

Append-only. Claude adds entries at session end when a structural decision is made.

---
DECISIONS_EOF
  echo "  + $LOG_DIR/decisions.md"
fi

# Add logs/ to .gitignore
if [ -f .gitignore ]; then
  grep -qF "$LOG_DIR/" .gitignore || echo "$LOG_DIR/" >> .gitignore
else
  echo "$LOG_DIR/" > .gitignore
fi
echo "  + $LOG_DIR/ added to .gitignore"

echo ""
echo "wrap-session installed."
echo ""
echo "Commands:"
echo "  /wrap        - close session (before /clear)"
echo "  /unwrap      - resume last session"
echo "  /wrap-list   - all sessions as a table"
echo "  /wrap-find   - search sessions by keyword"
echo "  /wrap-repair - fix CLAUDE.md breadcrumb"
echo ""
echo "Run /wrap at the end of your next session."
