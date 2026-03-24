phase: rmg-patch-review
session_id: 2026-03-24T00:00:00Z
prev_head: 4d5e10b13fd21e92c563906b929d4d9b51584ecb
experiment_id: 1
max_iterations: 30
probe_type: Web app
probe_prompt: "a pomodoro timer with session history"
probe_project: fg_exp_pomodoro_timer
current_score: 41/45
evaluation_step: patch-proposal
findings_pending: 4
patches_proposed:
  - id: "doc-quality-1"
    dimension: "Document Quality"
    risk: "low"
    file: "plugins/dmail/commands/dmail.md"
    description: "Phase 6 step 3 — cross-reference USAGE.md against spec acceptance criteria to catch missing expansion features"
    old_text: "3. Polish `USAGE.md` — complete pass, ensure all working features are documented"
    new_text: "3. Polish `USAGE.md` — do a complete pass: open `documents/steiner-spec.md` and compare each **checked** acceptance criterion against the sections in `USAGE.md`. Add a section for every feature that is checked in the spec but not documented in USAGE.md. Expansion cycle features are especially likely to be missing."
  - id: "doc-quality-2"
    dimension: "Document Quality"
    risk: "low"
    file: "plugins/dmail/commands/dmail.md"
    description: "Phase 6 step 4 README template — add Test Coverage line so it is explicitly updated each cycle"
    old_text: "4. Write/update `README.md`:\n   ```markdown\n   # [project_name]\n   [one-line description]\n   ## Quick start\n   [installation + first command]\n   ## Documentation\n   See [USAGE.md](USAGE.md) for full usage and [DOSSIER.md](DOSSIER.md) for project decisions.\n   ```"
    new_text: "4. Write/update `README.md`:\n   ```markdown\n   # [project_name]\n   [one-line description]\n   ## Quick start\n   [installation + first command]\n   ## Test coverage\n   [N] tests · [coverage_pct]% statement coverage\n   ## Documentation\n   See [USAGE.md](USAGE.md) for full usage and [DOSSIER.md](DOSSIER.md) for project decisions.\n   ```"
  - id: "doc-quality-3"
    dimension: "Document Quality"
    risk: "low"
    file: "plugins/dmail/commands/dmail.md"
    description: "Phase 6 step 5 — explicitly require updating DOSSIER Current Status with phase, leap count, and coverage"
    old_text: "5. Update `DOSSIER.md` — mark expansion cycle N complete, record what was achieved"
    new_text: "5. Update `DOSSIER.md` — mark expansion cycle N complete, record what was achieved. Specifically: update the `## Current status` or `## Overview` section (whichever exists) to set Phase to `[phase]`, Leap to `[leap_count]/[max_iterations]`, Cycle to `[expansion_cycle]`, and Divergence meter to `[coverage_pct]%`. If neither section exists, add `## Current status` at the top of the file."
  - id: "review-quality-1"
    dimension: "Review Quality"
    risk: "low"
    file: "plugins/dmail/commands/dmail.md"
    description: "Phase 4 step 1 — require file:line refs to be preserved in must_fix state entries"
    old_text: "1. Consolidate into `review_items` in state:\n   - `must_fix`: bugs, security issues, broken tests, missing critical coverage\n   - `nice_to_have`: style, minor refactors, non-critical improvements"
    new_text: "1. Consolidate into `review_items` in state:\n   - `must_fix`: bugs, security issues, broken tests, missing critical coverage. For each item, the slug description must include the file reference from the reviewer (e.g. `[slug]: [description] ([file]:[line-range])`). Preserve the reviewer's specific location — do not summarize to a slug alone.\n   - `nice_to_have`: style, minor refactors, non-critical improvements"
patches_approved: []
next_action: "present patches to user for approval"
