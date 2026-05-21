List all recorded sessions as a summary table. Execute immediately, no confirmation needed.

---

## Step 1 — Check for index file

Use the Bash tool:
```bash
wc -l sessions/_index.jsonl 2>/dev/null || echo "no-index"
```

---

## Step 2 — Build the table

**If `_index.jsonl` exists (fast path):**

Read `sessions/_index.jsonl`. Each line is a JSON object with fields: `session_id`, `date`, `summary`, `confidence`, `tags`, `files_changed`, `open_items`. Build the table directly from these fields — no file scanning needed.

**If `_index.jsonl` is missing (fallback — scan frontmatter):**

Use the Bash tool:
```bash
ls sessions/*.md 2>/dev/null | grep -v "_index" | sort
```

For each file, read only the frontmatter (lines between the `---` delimiters). Extract: `session_id`, `session_date`, `summary`, `confidence`, `files_changed`, `open_items`.

---

## Step 3 — Output

Output a markdown table:

| Session | Date | Summary | Confidence | Files | Open |
|---------|------|---------|------------|-------|------|
| `<id>` | YYYY-MM-DD | <summary> | high/med/low/— | N | N |

Rules:
- Truncate summary to 80 chars if longer
- If `confidence` field is absent (pre-schema sessions), show `—`
- Sort rows by session ID ascending (oldest first)
- After the table, print one line: `Total: N sessions across D distinct dates`
- If index was used: append `(source: _index.jsonl)` — if frontmatter scan was used: append `(source: frontmatter scan — run /wrap to build index)`
