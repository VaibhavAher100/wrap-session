# wrap-session

Every time you type `/clear` in Claude Code, Claude forgets everything about your session. This skill adds a `/wrap` command that makes Claude save its memory first - so your next session can start exactly where you left off.

---

## Install

Run this from inside your project folder:

```bash
curl -sS https://raw.githubusercontent.com/VaibhavAher100/wrap-session/main/install.sh | sh
```

That's it. The script creates all the files and folders automatically.

---

## How to use it

**At the end of every session**, before you type `/clear`:

```
/wrap
```

Claude writes the session log and says:

```
Session logged as `YYYY-MM-DD-001`. Safe to /clear.
```

Now `/clear` safely.

**At the start of your next session**, tell Claude:

```
Read logs/_state.md and the latest file in logs/sessions/ to get context.
```

Claude picks up right where you left off.

---

## What it saves

Every `/wrap` creates or updates three files:

| File | What it stores |
|------|---------------|
| `logs/sessions/YYYY-MM-DD-001.md` | Everything that happened this session |
| `logs/_state.md` | Current state of your project (overwritten fresh each session) |
| `logs/_decisions.md` | Important decisions, kept forever |

> **Heads up:** Session logs contain details of your Claude session. The installer adds `logs/` to your `.gitignore` automatically, but double-check before pushing to a public repo.

---

## What your project looks like after setup

```
your-project/
├── .claude/
│   └── commands/
│       └── wrap.md       ← the /wrap command
└── logs/
    ├── _state.md         ← current project state
    ├── _decisions.md     ← decision history
    └── sessions/         ← one file per session
```

---

## Manual install (no curl)

If you prefer not to pipe curl into sh:

1. Download [`wrap.md`](./wrap.md) and put it at `.claude/commands/wrap.md`
2. Create `logs/sessions/`, `logs/_state.md`, and `logs/_decisions.md` (templates below)
3. Add `logs/` to your `.gitignore`

**`logs/_state.md`:**
```markdown
---
updated: YYYY-MM-DD
---

# Project State

> Living document - Claude overwrites this each session. Last session: none

## Health

## In Progress

## Open Items

## User Working Preferences
```

**`logs/_decisions.md`:**
```markdown
# Decision Log

Append-only. Never delete entries.

---
```

---

## Troubleshooting

| Problem | What to do |
|---------|-----------|
| `/wrap` not found | The file must be at `.claude/commands/wrap.md` - the folder name must be `commands` |
| Claude asks what to do | Open `.claude/commands/wrap.md` and check the three path comments at the top match your folder structure |
| Session log is incomplete | Run `/wrap` again before clearing - once you clear, context is gone |
| Wrong session number | Rename the file manually - format is `YYYY-MM-DD-NNN.md` |

---

## Requirements

- [Claude Code](https://claude.ai/code) installed
- Any project folder (code, notes, research - anything works)

---

## License

MIT
