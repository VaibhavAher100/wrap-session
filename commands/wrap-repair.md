Repair the CLAUDE.md breadcrumb sentinel to match the current `logs/state.md`. Execute immediately, no confirmation needed.

Use this when `/unwrap` reports that the breadcrumb is out of sync with `logs/state.md`.

---

## Step 1 — Read current state

Use the Bash tool to extract the session backlink from `logs/state.md`:
```bash
grep -o "sessions/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-[0-9]\{3\}" logs/state.md | head -1
```

Also read the `summary:` field from the session file that matches that ID:
```bash
grep "^summary:" logs/sessions/<session-id>.md 2>/dev/null | head -1 | sed 's/^summary: //'
```

---

## Step 2 — Rewrite breadcrumb sentinel

Find the sentinel block in `CLAUDE.md`:
```
<!-- wrap:begin -->
...
<!-- wrap:end -->
```

**Before writing:** strip any `-->`, `<`, or `>` characters from the session summary. This prevents HTML comment breakout if the summary contains those characters.

Replace the entire block with the correct content from logs/state.md:
```
<!-- wrap:begin -->
<!-- wrap: <session-id> — <sanitized-summary> | state: logs/state.md -->
<!-- wrap:end -->
```

If no sentinel block found: append the full block to the end of `CLAUDE.md`.

Never modify any content outside the sentinel pair.

---

## Step 3 — Confirm

Output: `Breadcrumb repaired: now points to \`<session-id>\`.`
