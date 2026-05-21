# wrap-session

Session memory for Claude Code. Save where you were. Resume where you left off.

Not a chat log. A structured three-document memory layer that lives in your project folder: a living state file, an immutable session log, and an append-only decision record. Every Claude Code session can read it and pick up exactly where the last one ended.

---

## Getting Started

Never used wrap-session? Start here:

1. **[One-line install](#install)** - Run a single curl command. Done in 10 seconds.
2. **[AI-assisted install](AI_INSTALL.md)** - Paste a prompt into Claude Code, Cursor, Copilot, or any AI with terminal access.
3. **[Manual install](MANUAL.md)** - Step-by-step without scripts. Full control.

If you hit a wall: open an [issue](https://github.com/VaibhavAher100/wrap-session/issues).

---

## The problem

Claude Code has no memory between sessions. Type `/clear` or close the tab, and everything is gone - what you were building, what decisions were made, what is still open. You come back the next day and spend 10-15 minutes re-explaining context. Over weeks, this compounds.

The native workarounds (`CLAUDE.md`, auto-memory, `/compact`, `--continue`) are either manual, lossy, or too coarse. If you use Claude Code for serious multi-session work - development, research, knowledge management, job hunting - you hit this wall fast.

---

## How it works

Before closing a session:

```
/wrap
```

Claude saves its memory and confirms:

```
Session logged as `2026-05-21-003`. Safe to /clear.
```

Next session:

```
/unwrap
```

Claude reads the memory files and outputs a structured briefing: what was in progress, all open items with staleness tags, last 3 decisions, project health. Then `Resume from the briefing above` and you are back.

---

## The five commands

| Command | When | What it does |
|---------|------|-------------|
| `/wrap` | Before `/clear` | Write session log, update state, capture decisions |
| `/unwrap` | Session start | Read memory, output structured briefing |
| `/wrap-list` | Anytime | See all sessions as a searchable table |
| `/wrap-find <term>` | Anytime | Search full text across all session history |
| `/wrap-repair` | Maintenance | Fix CLAUDE.md breadcrumb if it drifts out of sync |

---

## The three-document architecture

Three files. Each does one job.

**`logs/sessions/YYYY-MM-DD-NNN.md`** - Immutable session log. Created once, never modified. Contains what was asked, a file-by-file action table, reasoning, open items with `[carried N]` staleness tracking, confidence rating, and topic tags.

**`logs/state.md`** - Living current state. Overwritten every session. What `/unwrap` reads first. Contains in-progress work, all open items, project health, user preferences.

**`logs/decisions.md`** - Append-only decision record. Only written when a structural decision is made. Never overwritten. Answers "why did we do it this way?" months later. Auto-archives at 30 entries.

---

## Install

### One-line

Run from inside your project folder:

```bash
curl -sS https://raw.githubusercontent.com/VaibhavAher100/wrap-session/main/install.sh | sh
```

Creates `.claude/commands/`, `.claude/scripts/`, `logs/`, and merges hooks into `.claude/settings.json` without touching existing config.

Options:

```bash
# Custom log directory
WRAP_LOG_DIR=.memory curl -sS https://raw.githubusercontent.com/VaibhavAher100/wrap-session/main/install.sh | sh

# Skip hook registration
WRAP_NO_HOOKS=1 curl -sS https://raw.githubusercontent.com/VaibhavAher100/wrap-session/main/install.sh | sh
```

### AI-assisted

Paste into Claude Code:

```
Install wrap-session from https://github.com/VaibhavAher100/wrap-session
Run: curl -sS https://raw.githubusercontent.com/VaibhavAher100/wrap-session/main/install.sh | sh
Verify .claude/commands/wrap.md, .claude/scripts/context-monitor.sh, and logs/state.md all exist.
```

See [AI_INSTALL.md](AI_INSTALL.md) for prompts covering Claude Code, Cursor, Copilot, ChatGPT, and Gemini.

### Manual

[MANUAL.md](MANUAL.md) - step-by-step without scripts.

---

## Safety features

- **Atomic writes** - `state.md` writes to `.tmp` first, verifies YAML frontmatter, then renames. Crash mid-write does not corrupt live state.
- **Sentinel breadcrumb** - CLAUDE.md uses `<!-- wrap:begin -->` and `<!-- wrap:end -->`. Only the block between them is touched.
- **Deletion check** - `/wrap` warns if it detects 20+ uncommitted deletions. Requires explicit confirmation.
- **Decisions archive** - copy then verify then truncate. Archive confirmed non-empty before active file is trimmed.
- **Deterministic session ID** - generated from shell, not LLM counting.
- **Controlled tag vocabulary** - 18 allowed tags enforced at wrap time.

---

## Confidence levels

- **`high`** - Full session visible, no compaction, all actions in context
- **`medium`** - Some compaction; key decisions present, some detail may be missing
- **`low`** - Heavy compaction; `/unwrap` shows a warning callout

---

## What is intentionally NOT included

- **Auto-wrap on `/clear`** - You decide when to wrap. Manual trigger keeps memory intentional, not noisy.
- **Vector search** - `/wrap-find` is grep-based. Fast, deterministic, zero dependencies.
- **Cloud sync** - Everything stays local in `logs/`.

---

## Context monitoring hooks

Two hooks registered automatically:

- **`context-prompt-check.sh`** (UserPromptSubmit) - at 40% context, asks whether to wrap, finish then wrap, or continue
- **`context-monitor.sh`** (PostToolUse) - at 70%, hard stop

Both read `used_percentage` from the Claude Code API. Model-aware - correct for any context window size. To change thresholds, edit `.claude/scripts/context-thresholds.sh`.

---

## For Obsidian users

wrap-session was built inside an Obsidian vault managed via Claude Code:

- Open items in `state.md` support wikilinks: `[[folder/file|Display Text]]`
- Session frontmatter tags are compatible with Obsidian
- `/wrap-find` searches across session memory and vault notes from the vault root

---

## FAQ

**Does this work with any project, not just Obsidian?**
Yes. `logs/` is a generic directory. Works in any Claude Code project.

**Will it overwrite my existing `.claude/settings.json`?**
No. The installer merges hooks using Python. Falls back to printing the JSON snippet if Python is unavailable.

**What if `/wrap` crashes mid-write?**
The write goes to `state.md.tmp` first. If verification fails, the tmp is preserved and `state.md` is untouched.

**Can I change the `logs/` directory?**
Yes. Set `WRAP_LOG_DIR=your-path` before running the installer.

**The confidence field shows `-` in `/wrap-list`. Why?**
That session predates the confidence field. The log is still valid.

---

## Repository structure

```
wrap-session/
├── commands/
│   ├── wrap.md
│   ├── unwrap.md
│   ├── wrap-list.md
│   ├── wrap-find.md
│   └── wrap-repair.md
├── scripts/
│   ├── context-thresholds.sh   - edit thresholds here
│   ├── context-monitor.sh      - PostToolUse hook (70%)
│   └── context-prompt-check.sh - UserPromptSubmit hook (40%)
├── install.sh
├── MANUAL.md
├── AI_INSTALL.md
├── SKILL.md
└── README.md
```

---

## License

MIT.

---

## Contributors

**Vaibhav Aher** ([@VaibhavAher100](https://github.com/VaibhavAher100)) - creator, three-document architecture, all five commands

**Claude** (Anthropic) - v2 hardening: atomic writes, sentinel breadcrumb, context monitoring, staleness tracking, confidence schema. Full breakdown in [CONTRIBUTORS.md](CONTRIBUTORS.md).
