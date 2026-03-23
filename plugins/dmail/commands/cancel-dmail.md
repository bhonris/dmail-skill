---
description: "Cancel an active D-Mail loop"
argument-hint: ""
---

# Cancel D-Mail

Halt the active D-Mail loop in the current directory.

1. Check if `reading-steiner.md` exists in the current directory
   - If not: "No active D-Mail session found in this directory."
   - If yes: continue

2. Read the current state (phase, leap_count, expansion_cycle)

3. Write a final STEINER_LOG.md entry:
   ```
   ## Leap [N] — CANCELLED — [timestamp]
   **Phase**: [current phase]
   **Reason**: User invoked /cancel-dmail
   **Divergence meter**: [coverage_pct]%
   **Worldline preserved in git at**: [git rev-parse HEAD]
   ```

4. Update `reading-steiner.md`: set `phase: cancelled`, `mayuri_rework_count: 0`

5. Commit: `git add -A && git commit -m "steiner: cancelled at leap [N], cycle [expansion_cycle]"`

6. Print summary:
   ```
   D-Mail loop cancelled.
   - Leaps completed: [leap_count]
   - Expansion cycles: [expansion_cycle]
   - Last phase: [phase]
   - Divergence meter: [coverage_pct]%
   - Worldline preserved in git — resume anytime by editing reading-steiner.md and running /dmail again
   ```

The stop hook will see `phase: cancelled` and allow the session to exit cleanly.
