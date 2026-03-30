phase: rmg-patch-review
session_id: 2026-03-30T00:00:00Z
prev_head: ddcb400eb1991461bfc904188392e64a973801b6
experiment_id: 3
max_iterations: 10
skill_target: worldline-shift
probe_type: CLI port
probe_prompt: "port fg_exp_habit_tracker from TypeScript/Node to Python"
probe_project: fg_exp_port_habit_tracker_python
port_source_project: fg_exp_habit_tracker
current_score: 37/45
evaluation_step: null
findings_pending: 0
patches_proposed:
  - id: "review-quality-1"
    dimension: "Review Quality"
    risk: "medium"
    file: "plugins/port/commands/worldline-shift.md"
    description: "Phase 5 step 2 — require findings written to state with file:line refs; forbid empty review_items when reviewers return output"
    old_text: "2. **Consolidate findings** into `review_items` (must-fix / nice-to-have).\n3. **Commit**: `shift: divergence audit — [N] must-fix, [M] nice-to-have`"
    new_text: |
      2. **Write findings to `worldline-shift.md`** — update `review_items` in state:
         - `must_fix`: parity gaps, behavioral divergences, missing sub-features, TODO stubs, logic errors, security issues, test parity failures. Each slug **must include a file reference**: `slug (file.py:line-range)`. If a reviewer found nothing, write `[reviewer-N-clean]: no issues found` — never leave a section as a bare empty list when reviewers have run.
         - `nice_to_have`: style, minor improvements, test refactors that don't affect parity
         - Write the state update **before** the commit — the commit must capture the findings.
      3. **Commit**: `shift: divergence audit — [N] must-fix, [M] nice-to-have`
  - id: "state-continuity-1"
    dimension: "State Continuity"
    risk: "low"
    file: "plugins/port/commands/worldline-shift.md"
    description: "Phase 1 step 3 — require running the test suite to count source tests; allow file counting only as explicit fallback with logged method"
    old_text: "3. **Count source tests**: Run the source test suite or count test files/cases. Record as `source_test_count` in state."
    new_text: |
      3. **Measure source test count**:
         - **Preferred**: Run the source test suite (e.g. `pnpm test`, `pytest`, `npm test`) and read the reported test count from output. This is the ground truth.
         - **Fallback (if suite fails to run)**: Count test cases by grepping for test function declarations (`it(`, `test(`, `def test_`). Document the method used: `source_test_count: [N] (via grep — suite failed to run)`.
         - Record as `source_test_count` in state. Do not estimate — an inaccurate count makes `test_parity_pct` unreliable.
patches_approved: []
next_action: "present patches to user for approval"
