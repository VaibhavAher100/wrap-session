# Manual Install

If you prefer not to run the install script, follow these steps.

## Step 1 — Download command files

```bash
mkdir -p .claude/commands
for cmd in wrap unwrap wrap-list wrap-find wrap-repair; do
  curl -sS "https://raw.githubusercontent.com/VaibhavAher100/wrap-session/main/commands/${cmd}.md" \
    -o ".claude/commands/${cmd}.md"
done
```

## Step 2 — Download hook scripts

```bash
mkdir -p .claude/scripts
for s in context-thresholds context-monitor context-prompt-check change-ledger; do
  curl -sS "https://raw.githubusercontent.com/VaibhavAher100/wrap-session/main/scripts/${s}.sh" \
    -o ".claude/scripts/${s}.sh"
  chmod +x ".claude/scripts/${s}.sh"
done
```

## Step 3 — Create log directory

```bash
mkdir -p logs/sessions
```

## Step 4 — Seed state and decisions files

`logs/state.md`:
```markdown
---
updated: YYYY-MM-DD
---

# Project State

> [!info] Living document - Claude overwrites this each session. Last session: none

## In Progress

## Open Items

## Health

## User Working Preferences
```

`logs/decisions.md`:
```markdown
# Decision Log

Append-only. Claude adds entries at session end when a structural decision is made.

---
```

## Step 5 — Register hooks in `.claude/settings.json`

If the file doesn't exist, create it. If it does, merge these hooks in without removing existing entries.

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \".claude/scripts/context-prompt-check.sh\"",
            "timeout": 5
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "bash \".claude/scripts/context-monitor.sh\" 2>/dev/null || true",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

## Step 6 — Gitignore

```bash
echo "logs/" >> .gitignore
```

## Step 7 — Verify

Type `/wrap` in a Claude Code session. You should see:
```
Session logged as `YYYY-MM-DD-001`. Safe to /clear.
```

## Custom log directory

Replace all instances of `logs/` in the command files with your preferred path. The hook scripts don't reference the log path.

## Uninstall

```bash
rm -f .claude/commands/wrap*.md .claude/commands/unwrap.md
rm -f .claude/scripts/context-*.sh
rm -rf logs/
```

Remove the hook entries from `.claude/settings.json` manually.
