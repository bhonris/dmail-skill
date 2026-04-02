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
blocked_on=$(grep '^blocked_on:' "$STATE_FILE" | head -1 | sed 's/^blocked_on: *//' | tr -d '[:space:]')

# ── Read last SHIFT_LOG entry ──
LAST_LOG_ENTRY=""
if [ -f "SHIFT_LOG.md" ]; then
  LAST_LOG_ENTRY=$(awk '/^## Leap /{found=1; entry=""} found{entry=entry"\n"$0} END{print entry}' SHIFT_LOG.md 2>/dev/null | tail -40)
fi

# ── Read must_fix items from state ──
MUST_FIX_ITEMS=""
MUST_FIX_ITEMS=$(awk '/^  must_fix:/{found=1; next} found && /^    - /{print} found && /^  [a-z]/{exit}' "$STATE_FILE" 2>/dev/null)

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
SERN_RECOVERY=""
if [ -n "$prev_head" ] && [ "$prev_head" = "$CURRENT_HEAD" ]; then
  new_sern=$((sern_count + 1))
  SERN_WARNING=" | SERN interference #${new_sern} — no git progress detected"

  if [ "$new_sern" -ge 2 ]; then
    SERN_RECOVERY="

## SERN INTERFERENCE RECOVERY REQUIRED (${new_sern} consecutive sessions with no git progress)

The last ${new_sern} sessions made no commits. The worldline is stuck. You MUST take one of these recovery actions — do NOT repeat the same approach that failed:

1. **If blocked on a test failure**: Read the exact error message carefully. If the same assertion has failed twice, the implementation strategy is wrong — change the approach entirely, do not retry the same fix.
2. **If blocked on a type error or build error**: Use Context7 to look up the exact API. Do not guess at method signatures or type shapes.
3. **If the feature is architecturally stuck**: Mark it \`deferred\` in the parity matrix with a specific documented reason (not just \"stuck\"), update worldline-shift.md with \`blocked_on: [specific reason]\`, commit the deferred status (this counts as progress), and move to the next unblocked feature.
4. **Specific blocker from last session**: \`blocked_on: ${blocked_on}\` — address this exact issue first.

After taking recovery action: if a new commit is made, reset \`sern_interference_count\` to 0 in worldline-shift.md. If still stuck, increment it."
  fi
fi

# ── Build continuation ──
NEXT_LEAP=$((leap_count + 1))
MSG="Worldline Shift — Leap ${NEXT_LEAP} / ${max_iterations} | Parity: ${ported}/${total} (${parity_pct}%) | Phase: ${phase}${SERN_WARNING}"

STATE_CONTENT=$(cat "$STATE_FILE")

# ── Build context sections conditionally ──
LOG_SECTION=""
if [ -n "$LAST_LOG_ENTRY" ]; then
  LOG_SECTION="

## Last Session Log Entry
\`\`\`
${LAST_LOG_ENTRY}
\`\`\`"
fi

MUSTFIX_SECTION=""
if [ -n "$MUST_FIX_ITEMS" ]; then
  MUSTFIX_SECTION="

## Outstanding must_fix Items (NOT yet closed)
${MUST_FIX_ITEMS}"
fi

PROMPT="You are resuming a Worldline Shift (project porting) session.

## Full State
\`\`\`yaml
${STATE_CONTENT}
\`\`\`
${LOG_SECTION}${MUSTFIX_SECTION}${SERN_RECOVERY}

Continue from the current phase and next_action. Follow the worldline-shift skill instructions exactly. Increment leap_count to ${NEXT_LEAP}.

Do NOT repeat work completed last session. The last session log entry above shows what was done — start from where it left off."

# ── Block exit and continue ──
# Escape for JSON
REASON=$(echo "$PROMPT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))" 2>/dev/null || echo "$PROMPT" | sed 's/\\/\\\\/g;s/"/\\"/g;s/\t/\\t/g' | tr '\n' ' ')
SYS_MSG=$(echo "$MSG" | sed 's/"/\\"/g')

echo "{\"decision\": \"block\", \"reason\": ${REASON}, \"systemMessage\": \"${SYS_MSG}\"}"
exit 0
