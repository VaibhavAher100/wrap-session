You are resuming a Claude Code session for this Obsidian vault. Execute all steps below in order — no confirmation needed.

---

## Step 0 — Validate state.md

Use the Bash tool:
```bash
head -1 state.md 2>/dev/null && wc -c < state.md 2>/dev/null
```

- If file is missing or empty: output `> [!warning] state.md is missing or empty. Session state is unavailable. Proceed with caution — open items and in-progress work cannot be loaded.` then continue with Steps 2-4 as best you can.
- If first line is not `---`: output `> [!warning] state.md appears malformed (does not start with YAML frontmatter). The file may have been written incorrectly. Content below may be unreliable.` then continue.
- If valid: proceed silently.

---

## Step 1 — Read current state

Read `state.md` in full.

---

## Step 2 — Find and read latest session log

Use the Bash tool to find the most recent session file:
```bash
ls sessions/*.md 2>/dev/null | sort | tail -1
```

Read that file in full.

---

## Step 3 — Output structured briefing

Check the `confidence` field from the session frontmatter first:
- If `confidence: low` — prepend a warning block before the briefing (see format below)
- If `confidence` is absent — note `(pre-schema, confidence unknown)`
- If `confidence: medium` — note it inline, no separate warning needed

Output the briefing in this exact format:

```
## Session Resumed

**Last session:** <session-id> (<session-date>)
**Summary:** <summary from frontmatter>
**Confidence:** <value> <— if low, see warning above>

### What was in progress
<In Progress section from state.md — or "Nothing" if empty>

### Open items
<Open Items section from state.md, preserving [carried N] tags>

### Vault health
<one-line status from Vault Health in state.md>

### Active decisions (last 3)
<Last 3 entries from decisions.md — title + Chose line only>
```

**Low confidence warning format (prepend before briefing):**
```
> [!warning] Low-confidence session log
> The previous session (`<session-id>`) was logged with **low confidence** — compaction occurred and early context was lost. Key actions or decisions may be missing from the log. Do not rely on the session log as a complete record. Cross-check with `state.md` and `decisions.md` before resuming work.
```

Do not summarize or paraphrase the open items — copy them exactly so no task is silently dropped.

---

## Step 4 — Check for CLAUDE.md breadcrumb

Read `CLAUDE.md` and find the sentinel block:
```
<!-- wrap:begin -->
<!-- wrap: ... -->
<!-- wrap:end -->
```

Extract the session ID from inside the block. Compare it to the session ID from `state.md`.

- If they match: note `(breadcrumb consistent)`
- If breadcrumb is older than `state.md`: output `> **Note:** CLAUDE.md breadcrumb points to <breadcrumb-id> but state.md reflects <state-id>. They are out of sync — run /wrap to update the breadcrumb.`
- If no sentinel block found: output `> **Note:** No wrap breadcrumb found in CLAUDE.md. Run /wrap at end of session to establish it.`
