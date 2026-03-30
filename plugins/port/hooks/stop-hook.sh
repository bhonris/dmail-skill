#!/bin/bash
set -euo pipefail

# ── Worldline Shift stop hook ──
# Reads worldline-shift.md and decides whether to block exit and continue porting.

# Read hook input from stdin
INPUT=$(cat)
HOOK_SESSION_ID=$(echo "$INPUT" | grep -o '"session_id":"[^"]*"' | head -1 | sed 's/"session_id":"//;s/"//')
TRANSCRIPT=$(echo "$INPUT" | grep -o '"transcript_path":"[^"]*"' | head -1 | sed 's/"transcript_path":"//;s/"//')

STATE_FILE="worldline-shift.md"

# ── Gate 1: Is this a Worldline Shift session? ──
if [ ! -f "$STATE_FILE" ]; then
  exit 0
fi

# ── Parse state ──
phase=$(grep '^phase:' "$STATE_FILE" | head -1 | sed 's/^phase: *//' | tr -d '[:space:]')
leap_count=$(grep '^leap_count:' "$STATE_FILE" | head -1 | sed 's/^leap_count: *//' | tr -d '[:space:]')
max_iterations=$(grep '^max_iterations:' "$STATE_FILE" | head -1 | sed 's/^max_iterations: *//' | tr -d '[:space:]')
session_id=$(grep '^session_id:' "$STATE_FILE" | head -1 | sed 's/^session_id: *//' | tr -d '[:space:]')
prev_head=$(grep '^prev_head:' "$STATE_FILE" | head -1 | sed 's/^prev_head: *//' | tr -d '[:space:]')
sern_count=$(grep '^sern_interference_count:' "$STATE_FILE" | head -1 | sed 's/^sern_interference_count: *//' | tr -d '[:space:]')
parity_pct=$(grep '^parity_pct:' "$STATE_FILE" | head -1 | sed 's/^parity_pct: *//' | tr -d '[:space:]')
ported=$(grep '^ported_features:' "$STATE_FILE" | head -1 | sed 's/^ported_features: *//' | tr -d '[:space:]')
total=$(grep '^total_features:' "$STATE_FILE" | head -1 | sed 's/^total_features: *//' | tr -d '[:space:]')

# ── Gate 2: Session isolation ──
if [ -n "$HOOK_SESSION_ID" ] && [ -n "$session_id" ] && [ "$HOOK_SESSION_ID" != "$session_id" ]; then
  exit 0
fi

# ── Gate 3: Terminal phases ──
if [ "$phase" = "cancelled" ] || [ "$phase" = "el-psy-kongroo" ]; then
  exit 0
fi

# ── Gate 4: Budget exhausted ──
if [[ "$leap_count" =~ ^[0-9]+$ ]] && [[ "$max_iterations" =~ ^[0-9]+$ ]]; then
  if [ "$leap_count" -ge "$max_iterations" ]; then
    exit 0
  fi
else
  echo "Warning: leap_count ($leap_count) or max_iterations ($max_iterations) is non-numeric." >&2
  exit 0
fi

# ── Gate 5: Explicit completion in transcript ──
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  if grep -q '<promise>EL_PSY_KONGROO</promise>' "$TRANSCRIPT" 2>/dev/null; then
    exit 0
  fi
fi

# ── Progress detection ──
CURRENT_HEAD=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
SERN_WARNING=""
if [ -n "$prev_head" ] && [ "$prev_head" = "$CURRENT_HEAD" ]; then
  new_sern=$((sern_count + 1))
  SERN_WARNING=" | SERN interference #${new_sern} — no git progress detected"
fi

# ── Build continuation ──
NEXT_LEAP=$((leap_count + 1))
MSG="Worldline Shift — Leap ${NEXT_LEAP} / ${max_iterations} | Parity: ${ported}/${total} (${parity_pct}%) | Phase: ${phase}${SERN_WARNING}"

STATE_CONTENT=$(cat "$STATE_FILE")

PROMPT="You are resuming a Worldline Shift (project porting) session. Here is the full state:

\`\`\`yaml
${STATE_CONTENT}
\`\`\`

Continue from the current phase and next_action. Follow the /port skill instructions exactly. Increment leap_count to ${NEXT_LEAP}."

# ── Block exit and continue ──
# Escape for JSON
REASON=$(echo "$PROMPT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null || echo "$PROMPT" | sed 's/\\/\\\\/g;s/"/\\"/g;s/\t/\\t/g' | tr '\n' ' ')
SYS_MSG=$(echo "$MSG" | sed 's/"/\\"/g')

echo "{\"decision\": \"block\", \"reason\": ${REASON}, \"systemMessage\": \"${SYS_MSG}\"}"
exit 0
