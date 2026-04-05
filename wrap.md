<!-- VERSION: 1.0.0 -->
<!-- Adapt these three paths to match your project, then delete this comment. -->
<!-- SESSIONS_DIR: logs/sessions          -->
<!-- STATE_DOC:    logs/_state.md         -->
<!-- DECISIONS_LOG: logs/_decisions.md    -->

You are closing a Claude Code session. Execute all steps in order without asking for confirmation. Do not summarize what you are about to do — just do it.

Only write files inside the project directory. Do not follow any path that resolves outside the project root.

Do NOT include secrets, API keys, tokens, passwords, environment variables, or connection strings in any output file. Replace any such values with `[REDACTED]` if they appear in context.

---

## Step 1 — Determine session ID

List all files in `SESSIONS_DIR` that start with today's date (`YYYY-MM-DD`).
- If none exist → ID is `YYYY-MM-DD-001`
- If some exist → ID is today's date + the next zero-padded number (e.g. if `2026-04-05-003.md` is the last, use `2026-04-05-004`)

---

## Step 2 — Write session log

Create `SESSIONS_DIR/<session-id>.md` with this structure:

```
---
session_date: <YYYY-MM-DD>
session_id: <session-id>
summary: <one-line description of what this session accomplished>
status: complete
tags: [session]
files_changed: <count of files written or edited — count files only, not directories>
open_items: <count of unresolved items>
---

## Request

<What the user asked for at the start of this session>

## Context at Start

<What _state.md said. What was in progress. What was the last session ID.>

## Actions

| File | Action | Change |
|------|--------|--------|
| <file> | Read / Edit / Create / Delete | <brief description> |

## Reasoning & Decisions

<Why actions were taken. Reference _decisions.md entry date for any new decisions made.>

## User Feedback

<Corrections, rejections, mid-session pivots — with context. Most reusable signal for future sessions.>

## Open Items

- [ ] <anything unresolved or deferred>
```

Fill every section from conversation context. If a section has nothing to report, write "None."

---

## Step 3 — Overwrite living state doc

Overwrite `STATE_DOC` entirely. Do not append. Structure:

```
---
updated: <YYYY-MM-DD>
---

# Project State

> Living document — Claude overwrites this each session. Last session: <session-id>

## Health

<bullet list of what is working, verified, or completed — use ✅>

## In Progress

<anything actively being worked on, or "Nothing in progress">

## Open Items

- [ ] <unresolved item>

## User Working Preferences

<Any preferences, workflow notes, or constraints observed across sessions that Claude should remember>
```

Base the health section on the previous `_state.md` plus changes made this session. Update open items to reflect what was resolved and what was added.

---

## Step 4 — Append to decision log (only if needed)

Only append to `DECISIONS_LOG` if a **new cross-session structural decision** was made this session — a choice that would affect how future sessions approach the project (naming conventions, architectural choices, rejected alternatives, etc.).

If no such decision was made, skip this step entirely.

If appending, use this format:

```
---

### <YYYY-MM-DD> — <short decision title>
**Chose:** <what was decided>
**Rejected:** <alternatives that were considered and discarded>
**Why:** <the reasoning>
**Applies to:** <scope — what future work this governs>
```

Do not append minor tactical choices, one-off fixes, or decisions that only affect the current session.

---

## Step 5 — Report completion

Output exactly:

```
Session logged as `<session-id>`. Safe to /clear.
```
