You are closing a Claude Code session. Execute all steps below in order.

> **Note:** This skill tracks only the current model's context window. Context percentage is read from the Claude Code API via the statusline state file — model-aware, accurate for any context window size. The 5-hour and 7-day usage limits are separate — do not conflate them with session context.
>
> When invoked manually by the user (`/wrap`): execute all steps immediately, no confirmation needed.
> When invoked automatically by the context monitor hook at 40%: the hook will have already asked the user whether they want to wrap. By the time this skill runs, the user has already said yes — proceed directly.

---

## Step 0 — Pre-flight safety check

Use the Bash tool (bash, not PowerShell — these are bash-specific commands):
```bash
git -C . status --short 2>/dev/null | grep "^.D\|^ D" | wc -l
```

If the count is 20 or more uncommitted deletions, stop and output:
> **Warning:** Detected N uncommitted file deletions. Wrapping now may lose context on files that were deleted this session. Type `confirm wrap` to proceed anyway, or commit/stash first.

Wait for user response before continuing. If count is under 20, proceed immediately.

---

## Step 1 — Determine session ID

Use the Bash tool:
```bash
ls logs/sessions/$(date +%Y-%m-%d)-*.md 2>/dev/null | sort | tail -1
```

- If output is empty: new ID is `<today's date>-001`
- If output is e.g. `...2026-05-21-003.md`: new ID is `2026-05-21-004`
- Do not count manually — use the shell output as the source of truth

---

## Step 2 — Write the session log

**Self-assess confidence using this rubric:**
- `confidence: high` — full session visible, no compaction events fired, all tool calls in context, clean completion with no unexplained gaps
- `confidence: medium` — at least one of: some compaction occurred, session ran >2 hours, >50 tool calls, some tool outputs were truncated; key decisions are present but some actions may be missing
- `confidence: low` — heavy compaction (early messages gone), unresolved blockers exist that you cannot explain, or more than ~30 minutes of work is unaccounted for in your context

**Generate tags (2-5 tags) from the controlled vocabulary below. Always include `claude/session`.**

Allowed tags: `claude/session`, `career`, `embedded`, `vault-cleanup`, `debugging`, `wrap-skill`, `german`, `university`, `github`, `skills`, `wiki`, `research`, `job-application`, `context`, `session-mgmt`, `cv`, `cover-letter`, `stm32`, `freertos`, `hooks`

After selecting tags, verify each against the allowed list above. Remove any tag not present in the list. Never invent new tags — if nothing fits, use only `claude/session`.

Create `logs/sessions/<session-id>.md` using this exact structure:

```
---
schema_version: 2
session_date: <YYYY-MM-DD>
session_id: <session-id>
summary: <one-line description of what was done this session>
confidence: <high|medium|low>
status: complete
tags:
  - claude/session
  - <topic-tag-1>
files_changed: <count of files actually modified>
open_items: <count of open items listed below>
---

## Request

<What the user asked for at the start of this session>

## Context at Start

<What logs/state.md said. What was in progress or open at session start.>

## Actions

| File | Action | Change |
|------|--------|--------|
<one row per file touched — Read / Edit / Create / Delete and a brief description of the change>

## Reasoning & Decisions

<Why actions were taken. Note any new decisions made. Reference logs/decisions.md if a new entry was added.>

## User Feedback

<Any corrections, rejections, or pivots the user made mid-session — with context. Leave blank if none.>

## Open Items

<Bulleted task list of unfinished or follow-up items. Tag each item as [new], [resolved], or [carried N].
Match items by intent, not exact wording — if an item is the same task with slightly different phrasing, treat it as the same item and preserve its [carried N] count. Only reset to [new] if it is genuinely a different task.>
```

After creating the session file, append one line to `logs/sessions/_index.jsonl` (create the file if it doesn't exist):
```
{"session_id": "<session-id>", "date": "<YYYY-MM-DD>", "summary": "<summary>", "confidence": "<high|medium|low>", "tags": [<tag-list-as-json-array>], "files_changed": <N>, "open_items": <N>}
```

Escape any `"` or `\` characters inside the summary when writing this line — it must remain valid JSON.

---

## Step 3 — Update `logs/state.md` (atomic write)

First, read the existing `logs/state.md`. For each open item, track whether it was resolved or carried — use this for Open Items tagging in Step 2. Match by intent, not exact text.

Write the updated content to `logs/state.md.tmp` first. Then use the Bash tool to verify and atomically rename:
```bash
head -1 logs/state.md.tmp && \
  wc -c < logs/state.md.tmp
```

- If output shows `---` on the first line and size > 0: run `mv logs/state.md.tmp logs/state.md`
- If first line is not `---` or file is empty: do NOT rename — report "logs/state.md write failed: malformed output in tmp file. logs/state.md.tmp preserved for inspection." and stop Step 3.

The written content must include:
- `updated:` set to today's date
- Session backlink in the info callout pointing to the new session ID
- `## In Progress` — clear if nothing is ongoing; otherwise list what is
- `## Open Items` — carry forward uncompleted items (preserve `[carried N]` count, increment N), add new ones tagged `[new]`, remove resolved ones
- `## Health` — update if anything changed
- `## User Working Preferences` — keep as-is unless a new preference emerged this session

---

## Step 3b — Consume the change-ledger (if present)

`logs/change-ledger.md` is a zero-token capture of what changed this session, written by the
optional `change-ledger.sh` PostToolUse hook. If it exists:
```bash
cat logs/change-ledger.md 2>/dev/null
```
Cross-check it against the Actions table in the session log — any listed file you have not
already summarized still has its content in context, so summarize it now instead of letting a
future session re-read the file. Then clear the ledger back to its header:
```bash
printf '# Change Ledger (auto, zero-token). Consumed + cleared by /wrap.\n\n' > logs/change-ledger.md
```
Skip this step silently if the file does not exist.

---

## Step 4 — Append to `logs/decisions.md` (only if needed)

First, count existing entries:
```bash
grep -c "^### " logs/decisions.md 2>/dev/null || echo 0
```

**If count exceeds 30 — archive using copy-then-truncate (never destructive move):**

1. Read the full content of `logs/decisions.md`
2. Append the full content to `logs/decisions-archive.md` (append, never overwrite)
3. Verify `logs/decisions-archive.md` was written and is non-empty before touching `logs/decisions.md`
4. Only after verification: rewrite `logs/decisions.md` with only the 20 most recent `### ` entries, prepended with: `<!-- Entries before <oldest-kept-date> archived to logs/decisions-archive.md -->`
5. If verification fails (archive write error), abort the archive step and log a warning in the session file — do not truncate `logs/decisions.md`

**If a new cross-session decision was made this session**, append to `logs/decisions.md`:

```
### <YYYY-MM-DD> — <short title>
**Chose:** <what was chosen>
**Rejected:** <what was not chosen>
**Why:** <reason>
**Applies to:** <scope>
```

Skip entirely if no new decisions were made and count is under 30.

---

## Step 5 — Write CLAUDE.md breadcrumb

Find the sentinel block in `CLAUDE.md`:
```
<!-- wrap:begin -->
...any existing content...
<!-- wrap:end -->
```

**Before writing:** strip any `-->`, `<`, or `>` characters from the session summary. This prevents HTML comment breakout if the summary contains those characters.

Replace the entire block (including sentinel lines) with:
```
<!-- wrap:begin -->
<!-- wrap: <session-id> — <sanitized-summary> | state: logs/state.md -->
<!-- wrap:end -->
```

If no sentinel block exists, **append** the full block to the end of `CLAUDE.md`. Never modify any content outside the sentinel pair. Never replace the sentinel by matching a single loose line — only match the full `<!-- wrap:begin -->` ... `<!-- wrap:end -->` block.

---

## Step 6 — Report completion

Output exactly: `Session logged as \`<session-id>\`. Safe to /clear.`
