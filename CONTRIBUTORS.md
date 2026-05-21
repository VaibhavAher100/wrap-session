# Contributors

## Vaibhav Aher ([@VaibhavAher100](https://github.com/VaibhavAher100))

Creator. Built wrap-session out of personal need while managing an Obsidian knowledge vault, job applications, and embedded systems projects across long Claude Code sessions. Designed the three-document architecture and all five commands.

## Claude (Anthropic)

Co-developer. Contributed the session hardening architecture across the v2 upgrade:

- Atomic write pattern for `state.md` (tmp file -> YAML verify -> atomic rename)
- CLAUDE.md sentinel pair (`<!-- wrap:begin -->` / `<!-- wrap:end -->`) replacing loose line matching
- Copy-then-verify-then-truncate for decisions archive
- Model-aware context monitoring (API `used_percentage` replacing file-size estimation)
- Shared `context-thresholds.sh` config file
- `[carried N]` open item staleness tracking with intent-based matching
- Confidence rubric (high/medium/low) and controlled tag vocabulary
- `sessions/_index.jsonl` for fast `/wrap-list` at scale
- `/unwrap` state.md validator (Step 0)
- `/wrap-repair` command
- Full v2 session log schema (`schema_version`, topic tags, confidence field)

Built iteratively across a single session, reviewed by Claude Opus 4.7 at two checkpoints.
