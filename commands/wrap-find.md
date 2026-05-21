Search session logs for a keyword or phrase. The search term is everything after `/wrap-find` in the user's message.

Execute immediately, no confirmation needed.

---

## Step 1 — Run the search

Use the Bash tool:
```bash
grep -ril "<SEARCH_TERM>" sessions/ 2>/dev/null | sort
```

Replace `<SEARCH_TERM>` with the user's argument.

## Step 2 — For each matching file

Read only the frontmatter of each matching file to get `session_id`, `session_date`, and `summary`.

Then run a second grep to extract the matching lines with context:
```bash
grep -in "<SEARCH_TERM>" <FILE> 2>/dev/null
```

## Step 3 — Output results

For each matching session, output:

```
### <session-id> (<session-date>)
<summary>

Matches:
- Line N: <matching line>
- Line N: <matching line>
```

Separate each session result with a horizontal rule.

If no matches found, output: `No sessions found matching "<SEARCH_TERM>".`

After all results, print: `Found in N of M sessions.`

## Notes
- Search is case-insensitive
- Searches full file content — frontmatter, actions table, reasoning, open items
- For tag search, user can pass e.g. `career` or `embedded` to match topic tags
