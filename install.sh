#!/bin/sh
# wrap-session installer
# Run this from inside your project folder.

set -e

TODAY=$(date +%Y-%m-%d)

echo "Setting up wrap-session..."

# Create folders
mkdir -p .claude/commands
mkdir -p logs/sessions

# Download wrap.md
curl -sS https://raw.githubusercontent.com/VaibhavAher100/wrap-session/main/wrap.md \
  -o .claude/commands/wrap.md

# Create _state.md if it doesn't exist
if [ ! -f logs/_state.md ]; then
cat > logs/_state.md << EOF
---
updated: $TODAY
---

# Project State

> Living document - Claude overwrites this each session. Last session: none

## Health

## In Progress

## Open Items

## User Working Preferences
EOF
fi

# Create _decisions.md if it doesn't exist
if [ ! -f logs/_decisions.md ]; then
cat > logs/_decisions.md << EOF
# Decision Log

Append-only. Never delete entries.

---
EOF
fi

# Add logs/ to .gitignore if not already there
if [ -f .gitignore ]; then
  grep -qx "logs/" .gitignore || echo "logs/" >> .gitignore
else
  echo "logs/" > .gitignore
fi

echo ""
echo "Done. wrap-session is ready."
echo ""
echo "At the end of any Claude session, type:"
echo "  /wrap"
echo ""
echo "Then /clear safely."
