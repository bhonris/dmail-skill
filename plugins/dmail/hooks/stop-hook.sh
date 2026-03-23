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

NO_PROGRESS_WARNING=""
if [[ -n "$PREV_HEAD" ]] && [[ "$PREV_HEAD" != "unknown" ]] && [[ "$CURR_HEAD" = "$PREV_HEAD" ]]; then
  NO_PROGRESS_WARNING="⚠️  WARNING: SERN interference detected — no new git commit this leap. sern_interference_count: $SERN_COUNT"
fi

# Not done — continue the loop
NEXT_LEAP=$((LEAP + 1))
SYSTEM_MSG="🔄 D-Mail — Leap $NEXT_LEAP / $MAX | Cycle $CYCLE | Phase: $PHASE"
if [[ -n "$NO_PROGRESS_WARNING" ]]; then
  SYSTEM_MSG="$SYSTEM_MSG | $NO_PROGRESS_WARNING"
fi

# Build the continuation prompt from the state file
CONTINUATION_PROMPT=$(cat << 'PROMPT_EOF'
[READING STEINER — WORLDLINE RESUMPTION]

The D-Mail has activated. A new session has begun. Read reading-steiner.md below and continue exactly from where the lab left off.

PROMPT_EOF
)
CONTINUATION_PROMPT="${CONTINUATION_PROMPT}

$(cat "$STATE_FILE")

---

You are Hououin Kyouma. Resume the lab's work. Read the phase and next_action above. Execute the corresponding phase from your instructions. Commit before this session ends. Update reading-steiner.md with prev_head and incremented leap_count. El Psy Kongroo."

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
