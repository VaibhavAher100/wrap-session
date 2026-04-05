---
name: wrap-session
description: Use when a Claude Code session is ending and the user wants to preserve context before /clear, or wants to add session logging to a new project.
---

# wrap-session

Prevents session history loss when users type `/clear`. Sets up a project-local `/wrap` slash command, or executes the wrap directly if the project already has the logging structure.

## When to Use

- User says "wrap up", "log this session", "save before clear", or types `/wrap`
- User wants to set up session logging in a new project
- Project has a `_state.md` / `sessions/` structure but no `/wrap` command yet

## What /wrap Does

1. **Determine session ID** - scan `sessions/` for today's files, increment to next `YYYY-MM-DD-NNN`
2. **Write session log** - create `sessions/YYYY-MM-DD-NNN.md` from the template
3. **Overwrite living state doc** - update `_state.md` with current project health, open items, preferences
4. **Append to decision log** - only if new cross-session structural decisions were made this session
5. **Report** - output `Session logged as \`<id>\`. Safe to /clear.`

## Three-Document System

| File | Purpose | Update pattern |
|------|---------|----------------|
| `_state.md` | Current project health, open items, user preferences | **Overwritten** each session |
| `_decisions.md` | Locked-in cross-session decisions | **Append-only** - never delete |
| `sessions/YYYY-MM-DD-NNN.md` | Full session detail | Created once, immutable after |

## Setting Up in a New Project

### Step 1 - Create the logging structure

```
<logs-dir>/
  _state.md          # Living doc - overwritten each session
  _decisions.md      # Append-only decision log
  sessions/
    (empty - Claude fills this)
```

Seed `_state.md` with current project state. Seed `_decisions.md` with the header only.

### Step 2 - Create the /wrap command

```bash
mkdir -p .claude/commands
```

Copy `wrap.md` from this skill into `.claude/commands/wrap.md`.

**Adapt the three path comments at the top of the copied file:**
```
<!-- SESSIONS_DIR: logs/sessions          -->
<!-- STATE_DOC:    logs/_state.md         -->
<!-- DECISIONS_LOG: logs/_decisions.md    -->
```

All other instructions in `wrap.md` are path-agnostic.

### Step 3 - Invoke

```
/wrap
```
or
```
/project:wrap
```

## Session Log Frontmatter

```yaml
---
session_date: YYYY-MM-DD
session_id: YYYY-MM-DD-NNN
summary: one-line description
status: complete
tags: [session]
files_changed: 0
open_items: 0
---
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| `/wrap` not found | File must be at `.claude/commands/wrap.md`, not `.claude/wrap.md` |
| Session ID collision | Always scan existing files before picking ID - never hardcode |
| `_state.md` not updated | Step 3 must **overwrite**, not append |
| Decision log bloated | Only append when a genuine cross-session structural decision was made |
| Wrap run after `/clear` | Too late - context is gone. Always `/wrap` before `/clear` |
| Wrong paths in wrap.md | Adapt the three path comments at the top of wrap.md to match your project |
