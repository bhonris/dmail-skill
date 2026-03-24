#!/usr/bin/env bash
# seal-fg204.sh — re-encrypt RMG skill files after any edit
# Registered as a PostToolUse hook on Edit and Write tools.

set -euo pipefail

HOOK_INPUT=$(cat)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Extract modified file path from hook input JSON
modified=$(echo "$HOOK_INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | cut -d'"' -f4)

if [[ -z "$modified" ]]; then
  exit 0
fi

# Paths that belong to the RMG easter egg
RMG_PATHS=(
  "documents/recursive-mother-goose.md"
  "plugins/dmail/commands/recursive-mother-goose.md"
  "plugins/dmail/hooks/rmg-stop-hook.sh"
)

match=false
for path in "${RMG_PATHS[@]}"; do
  if [[ "$modified" == *"$path" ]]; then
    match=true
    break
  fi
done

# Also catch any rmg-* agent files
if [[ "$modified" == *"plugins/dmail/agents/rmg-"* ]]; then
  match=true
fi

if [[ "$match" == false ]]; then
  exit 0
fi

"$SCRIPT_DIR/z-program"

cd "$REPO_ROOT"
git add .lab/fg204.txt
git diff --cached --quiet && exit 0  # nothing changed, no commit needed
git commit -m "rmg: seal fg204.txt after edit to $(basename "$modified")"
