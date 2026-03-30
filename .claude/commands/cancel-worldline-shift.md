---
description: "Cancel an active Worldline Shift (port) loop"
argument-hint: ""
---

# Cancel Worldline Shift

1. Check for `worldline-shift.md` in the current directory.
   - If missing → print "No active Worldline Shift found in this directory." and stop.
2. Read current state: `phase`, `leap_count`, `parity_pct`, `ported_features`, `total_features`.
3. Write final `SHIFT_LOG.md` entry:
   ```
   ## Leap [leap_count] — CANCELLED
   - **Phase at cancellation**: [phase]
   - **Parity at cancellation**: [ported_features]/[total_features] ([parity_pct]%)
   - **Reason**: User cancelled
   ```
4. Update `worldline-shift.md`: set `phase: cancelled`.
5. Commit: `shift: cancelled at leap [N] — [parity_pct]% parity achieved`
6. Print summary:
   ```
   Worldline Shift cancelled.
   Parity achieved: [ported_features]/[total_features] ([parity_pct]%)
   All progress preserved in git. Resume by running /worldline-shift again from this directory.
   ```
