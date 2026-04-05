# wrap-session

Every time you type `/clear` in Claude Code, Claude forgets everything about your session. This skill adds a `/wrap` command that makes Claude save its memory first — so your next session can start exactly where you left off.

---

## How it works

Type `/wrap` before `/clear`. Claude writes three files:

| File | What it stores |
|------|---------------|
| `logs/sessions/2026-04-06-001.md` | Everything that happened this session |
| `logs/_state.md` | Current state of your project (updated fresh each session) |
| `logs/_decisions.md` | Important decisions, kept forever |

Next session, tell Claude: *"Read `logs/_state.md` and the latest session log."* It picks up right where you left off.

> **Note:** Session logs may contain details from your Claude session. Do not commit the `logs/` folder to a public repository if your sessions involve private work.

---

## Install

### Option 1 — Claude Code CLI

```bash
claude skill install VaibhavAher100/wrap-session
```

### Option 2 — One command in your terminal

Open a terminal, go to your project folder, and run:

```bash
mkdir -p .claude/commands logs/sessions && \
curl -sS https://raw.githubusercontent.com/VaibhavAher100/wrap-session/main/wrap.md \
  -o .claude/commands/wrap.md
```

Then create the two seed files below.

### Option 3 — Do it by hand

**Step 1.** Inside your project folder, create these folders and files:

```
your-project/
├── .claude/
│   └── commands/
│       └── wrap.md          ← copy this from the repo
└── logs/
    ├── _state.md            ← create this (template below)
    ├── _decisions.md        ← create this (template below)
    └── sessions/            ← leave empty, Claude fills it
```

**Step 2.** Copy [`wrap.md`](./wrap.md) into `.claude/commands/wrap.md`.

**Step 3.** Open `.claude/commands/wrap.md` and update the three lines at the top to match your folder names:

```
<!-- SESSIONS_DIR: logs/sessions          -->
<!-- STATE_DOC:    logs/_state.md         -->
<!-- DECISIONS_LOG: logs/_decisions.md    -->
```

If your logs folder is somewhere else, just change `logs/` to whatever path you use.

---

## Create the seed files

You only do this once.

**`logs/_state.md`** — paste this in and save:

```markdown
---
updated: 2026-04-06
---

# Project State

> Living document — Claude overwrites this each session. Last session: none

## Health

## In Progress

## Open Items

## User Working Preferences
```

**`logs/_decisions.md`** — paste this in and save:

```markdown
# Decision Log

Append-only. Never delete entries.

---
```

---

## Add a .gitignore entry

If you use Git, add this to your `.gitignore` so session logs don't get pushed:

```
logs/
```

---

## How to use it

**At the end of every session**, before you type `/clear`:

```
/wrap
```

Claude will write the session log and tell you:

```
Session logged as `2026-04-06-001`. Safe to /clear.
```

Now you can `/clear` safely.

**At the start of your next session**, paste this to Claude:

```
Read logs/_state.md and the latest file in logs/sessions/ to get context.
```

That's it.

---

## What your logs folder looks like after a few sessions

```
logs/
├── _state.md                 ← always up to date
├── _decisions.md             ← never shrinks
└── sessions/
    ├── 2026-04-05-001.md
    ├── 2026-04-05-002.md
    └── 2026-04-06-001.md
```

---

## Troubleshooting

| Problem | What to do |
|---------|-----------|
| `/wrap` not found | Check that the file is at `.claude/commands/wrap.md` — the folder name must be `commands` |
| Claude asks what to do | The paths at the top of `wrap.md` don't match your folders — open the file and update them |
| Session log is missing sections | Run `/wrap` again before clearing — once you've cleared, the context is gone |
| Wrong session number | Claude scans existing files to pick the ID — if it got it wrong, rename the file manually |
| Worried about sensitive data | The prompt tells Claude not to write secrets — but always review logs before pushing to Git |

---

## Requirements

- [Claude Code](https://claude.ai/code) installed
- A project folder (works for code, notes, research, anything)

---

## License

MIT
