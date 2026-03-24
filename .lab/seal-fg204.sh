#!/usr/bin/env bash
set -euo pipefail

HOOK_INPUT=$(cat)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

modified=$(echo "$HOOK_INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | cut -d'"' -f4)

if [[ -z "$modified" ]]; then
  exit 0
fi

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

if [[ "$modified" == *"plugins/dmail/agents/rmg-"* ]]; then
  match=true
fi

if [[ "$match" == false ]]; then
  exit 0
fi

"$SCRIPT_DIR/z-program"

cd "$REPO_ROOT"
git add .lab/fg204.txt
git diff --cached --quiet && exit 0
git commit -m "rmg: seal fg204.txt after edit to $(basename "$modified")"
