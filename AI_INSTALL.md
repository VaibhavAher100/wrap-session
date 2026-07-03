# AI-Assisted Install

Copy and paste the relevant prompt into your AI to install wrap-session automatically.

---

## Claude Code

Paste into Claude Code:

```
Install wrap-session from https://github.com/VaibhavAher100/wrap-session

Run: curl -sS https://raw.githubusercontent.com/VaibhavAher100/wrap-session/main/install.sh | sh

Then verify:
- .claude/commands/wrap.md exists
- .claude/commands/unwrap.md exists
- .claude/scripts/context-monitor.sh exists
- logs/state.md exists and starts with ---
- logs/decisions.md exists
```

Claude Code will run the installer via the Bash tool, check output, and confirm.

---

## Cursor / Copilot / Windsurf (or any AI with terminal access)

```
I want to install wrap-session, a session memory system for Claude Code.
Run from my project root:

  curl -sS https://raw.githubusercontent.com/VaibhavAher100/wrap-session/main/install.sh | sh

After running, verify:
- .claude/commands/ contains wrap.md, unwrap.md, wrap-list.md, wrap-find.md, wrap-repair.md
- .claude/scripts/ contains context-thresholds.sh, context-monitor.sh, context-prompt-check.sh, change-ledger.sh, statusline.sh
- logs/state.md exists
- If .claude/settings.json already existed, confirm the context hooks were merged in
  without removing any pre-existing entries.
```

---

## ChatGPT / Gemini / Claude.ai (no terminal access)

Paste this to get exact manual commands for your setup:

```
I want to manually install wrap-session, a Claude Code skill.
GitHub: https://github.com/VaibhavAher100/wrap-session

My setup:
- OS: [your OS]
- Shell: [bash/zsh/powershell]
- Project root: [path]
- .claude/settings.json already exists: [yes/no]

Give me exact shell commands to:
1. Download 5 command files into .claude/commands/
2. Download 3 hook scripts into .claude/scripts/ with execute permissions
3. Create logs/state.md with YAML frontmatter seed content
4. Create logs/decisions.md with header seed content
5. Merge the UserPromptSubmit and PostToolUse hooks into settings.json
   without touching any existing keys
6. Add logs/ to .gitignore
```

---

## Update existing install

To update command and script files while keeping your session history and state:

```
Update my wrap-session install.
Run: curl -sS https://raw.githubusercontent.com/VaibhavAher100/wrap-session/main/install.sh | sh

This will overwrite .claude/commands/wrap*.md, .claude/commands/unwrap.md,
and .claude/scripts/context-*.sh with the latest versions.

It will NOT touch:
- logs/state.md
- logs/decisions.md
- logs/sessions/
- Any pre-existing .claude/settings.json entries
```

---

## Verify install

After installation, paste into any AI with file access:

```
Verify wrap-session is correctly installed:
1. .claude/commands/ has: wrap.md, unwrap.md, wrap-list.md, wrap-find.md, wrap-repair.md
2. .claude/scripts/ has: context-thresholds.sh, context-monitor.sh, context-prompt-check.sh, change-ledger.sh, statusline.sh
3. logs/state.md exists and first line is ---
4. logs/decisions.md exists
5. .claude/settings.json has UserPromptSubmit hook pointing to context-prompt-check.sh
   and PostToolUse hook pointing to context-monitor.sh
Report anything missing or misconfigured.
```
