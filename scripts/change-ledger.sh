#!/usr/bin/env bash
# change-ledger.sh - PostToolUse(Write|Edit|MultiEdit) hook.
# Records WHAT file changed and WHEN, with zero LLM tokens (pure shell).
# /wrap consumes + clears this ledger: the model summarizes each change while the
# content is still in context, so no future session re-reads a file just to remember it.
#
# Hook type: PostToolUse (matcher: "Write|Edit|MultiEdit")
# Timeout: 5s

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || ROOT=$(pwd)
LEDGER="$ROOT/logs/change-ledger.md"

input=$(cat)
path=$(printf '%s' "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//')
sid=$(printf '%s'  "$input" | grep -o '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//')
[ -z "$path" ] && exit 0

# normalize backslashes so excludes match on win32 absolute paths.
# JSON encodes a single win32 backslash as "\\" (two chars), so collapse those
# first, then any lone backslash, then squeeze the resulting double slashes.
np=$(printf '%s' "$path" | sed 's#\\\\#/#g; s#\\#/#g; s#//*#/#g')
case "$np" in
  *"/.claude/"*|*"/.git/"*|*"node_modules"*|*"/logs/"*|*".tmp") exit 0;;
esac

# store the path relative to the repo root when possible
rel=${np#"${ROOT//\\//}/"}
[ -f "$LEDGER" ] || printf '# Change Ledger (auto, zero-token). Consumed + cleared by /wrap.\n\n' > "$LEDGER"
printf '%s | %s | %s\n' "$(date +%F)" "${sid:0:8}" "$rel" >> "$LEDGER"
exit 0
