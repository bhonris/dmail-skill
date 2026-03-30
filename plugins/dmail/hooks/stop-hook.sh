#!/bin/bash

# D-Mail Stop Hook
# Intercepts session exit to keep the autonomous build loop running.
# Modelled after ralph-loop's stop hook contract.

set -euo pipefail

# Read hook input from stdin (contains session_id, transcript_path)
HOOK_INPUT=$(cat)

STATE_FILE="reading-steiner.md"

# Not a D-Mail session — allow exit
if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# Parse state fields
PHASE=$(grep '^phase:' "$STATE_FILE" | sed 's/phase: *//' | tr -d '[:space:]' || echo "")
LEAP=$(grep '^leap_count:' "$STATE_FILE" | sed 's/leap_count: *//' | tr -d '[:space:]' || echo "0")
MAX=$(grep '^max_iterations:' "$STATE_FILE" | sed 's/max_iterations: *//' | tr -d '[:space:]' || echo "30")
CYCLE=$(grep '^expansion_cycle:' "$STATE_FILE" | sed 's/expansion_cycle: *//' | tr -d '[:space:]' || echo "1")
STATE_SESSION=$(grep '^session_id:' "$STATE_FILE" | sed 's/session_id: *//' | tr -d '[:space:]' || echo "")

# Session isolation — only the session that started the loop can continue it
HOOK_SESSION=$(echo "$HOOK_INPUT" | jq -r '.session_id // ""' 2>/dev/null || echo "")
if [[ -n "$STATE_SESSION" ]] && [[ "$STATE_SESSION" != "$HOOK_SESSION" ]]; then
  exit 0
fi

# Cancelled by user — allow exit
if [[ "$PHASE" = "cancelled" ]]; then
  exit 0
fi

# Phase explicitly marked done by Claude — allow exit
if [[ "$PHASE" = "el-psy-kongroo" ]]; then
  echo "✅ El Psy Kongroo. The lab has declared the worldline complete after $LEAP leaps."
  exit 0
fi

# Validate numeric fields
if [[ ! "$LEAP" =~ ^[0-9]+$ ]]; then
  echo "⚠️  D-Mail: leap_count is not a valid number ('$LEAP'). Stopping." >&2
  exit 0
fi
if [[ ! "$MAX" =~ ^[0-9]+$ ]]; then
  echo "⚠️  D-Mail: max_iterations is not a valid number ('$MAX'). Stopping." >&2
  exit 0
fi

# Budget exhausted — allow exit
if [[ $MAX -gt 0 ]] && [[ $LEAP -ge $MAX ]]; then
  echo "⏱️  El Psy Kongroo. The lab has exhausted its temporal budget after $LEAP leaps across $CYCLE expansion cycles. The worldline has been preserved in git."
  exit 0
fi

# Note: EL_PSY_KONGROO completion is signalled by Claude writing phase: el-psy-kongroo
# to reading-steiner.md — already handled above. No transcript parsing needed.

# Check for no-progress (same git HEAD as recorded in state)
PREV_HEAD=$(grep '^prev_head:' "$STATE_FILE" | sed 's/prev_head: *//' | tr -d '[:space:]' || echo "")
CURR_HEAD=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
SERN_COUNT=$(grep '^sern_interference_count:' "$STATE_FILE" | sed 's/sern_interference_count: *//' | tr -d '[:space:]' || echo "0")
SERN_NO_PROGRESS_STREAK=$(grep '^sern_no_progress_streak:' "$STATE_FILE" | sed 's/sern_no_progress_streak: *//' | tr -d '[:space:]' || echo "0")
CURRENT_FOCUS=$(grep '^current_focus:' "$STATE_FILE" | sed 's/current_focus: *//' | sed 's/^"//' | sed 's/"$//' || echo "unknown")
NEXT_ACTION=$(grep '^next_action:' "$STATE_FILE" | sed 's/next_action: *//' | sed 's/^"//' | sed 's/"$//' || echo "unknown")
BLOCKED_ON=$(grep '^blocked_on:' "$STATE_FILE" | sed 's/blocked_on: *//' | tr -d '[:space:]' || echo "null")
MUST_FIX_COUNT=$(awk '/^  must_fix:/{f=1} f && /^    - /{c++} /^  nice_to_have:/{f=0} END{print c+0}' "$STATE_FILE" 2>/dev/null || echo "0")

NO_PROGRESS=false
if [[ -n "$PREV_HEAD" ]] && [[ "$PREV_HEAD" != "unknown" ]] && [[ "$CURR_HEAD" = "$PREV_HEAD" ]]; then
  NO_PROGRESS=true
fi

# Not done — continue the loop
NEXT_LEAP=$((LEAP + 1))

if [[ "$NO_PROGRESS" = true ]] && [[ "$SERN_NO_PROGRESS_STREAK" =~ ^[0-9]+$ ]] && [[ $SERN_NO_PROGRESS_STREAK -ge 2 ]]; then
  # Time-leap directive — agent is stuck, escalate
  SYSTEM_MSG="⚠️  D-Mail — SERN x${SERN_NO_PROGRESS_STREAK} | Leap $NEXT_LEAP / $MAX | Phase: $PHASE | TIME-LEAP REQUIRED"
  CONTINUATION_PROMPT="=== D-MAIL SERN INTERFERENCE — TIME-LEAP REQUIRED ===
${SERN_NO_PROGRESS_STREAK} consecutive leaps with no git commit detected.

TIME-LEAP PROTOCOL:
1. Run: git log --oneline -5
2. Identify the last commit with a \"steiner:\" prefix
3. Re-read reading-steiner.md to understand what was supposed to happen last leap
4. Try a meaningfully different approach to make progress on: ${CURRENT_FOCUS}
5. If the same blocker persists after trying: mark it as deferred in must_fix, advance to next feature or phase
6. You MUST make at least one git commit this leap, even if only a state update

Phase: ${PHASE} | Blocked on: ${BLOCKED_ON}
Read reading-steiner.md for full state. Reset sern_no_progress_streak to 0 after your first commit."

else
  # Normal focused continuation brief
  if [[ "$NO_PROGRESS" = true ]]; then
    WARN_LINE="⚠️  No commit last leap — sern_no_progress_streak is ${SERN_NO_PROGRESS_STREAK}. Increment it in state."
  else
    WARN_LINE=""
  fi
  SYSTEM_MSG="🔄 D-Mail — Leap $NEXT_LEAP / $MAX | Cycle $CYCLE | Phase: $PHASE"

  CONTINUATION_PROMPT="=== D-MAIL CONTINUATION BRIEF — Leap ${NEXT_LEAP} / ${MAX} ===
Phase:          ${PHASE}
Focus:          ${CURRENT_FOCUS}
Next action:    ${NEXT_ACTION}
Blocked on:     ${BLOCKED_ON}
Must-fix open:  ${MUST_FIX_COUNT} items
SERN count:     ${SERN_COUNT}
${WARN_LINE}

Read reading-steiner.md for full state. Resume from the top of the current phase.
Do not re-run completed steps. Commit before this session ends.
Update: prev_head (git rev-parse HEAD), leap_count (+1), sern_no_progress_streak (reset to 0 if committed, +1 if not)."
fi

# Output JSON to block exit and feed the continuation prompt back
jq -n \
  --arg prompt "$CONTINUATION_PROMPT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'

exit 0
