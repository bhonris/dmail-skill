phase: rmg-probe-selection
session_id: 2026-03-26T00:00:00Z
prev_head: 30f8d4adbcfea466948d5e3d9e4e9defaa9d0e15
experiment_id: 3
max_iterations: 10
probe_type: web-game
probe_prompt: "a browser-based RPG battle game with animated characters and combat cutscenes, similar to Pokemon or early Final Fantasy battles"
probe_project: fg_exp_rpg_battle
current_score: 39/45
evaluation_step: complete
findings_pending: 0
patches_proposed:
  - id: "doc-quality-1"
    dimension: "Document Quality"
    risk: "medium"
    file: "plugins/dmail/commands/dmail.md"
    description: "Phase 6 step 3 must explicitly scan all ## Expansion [N] sections in the spec, not just the initial ## Acceptance Criteria section"
    old_text: "Polish `USAGE.md` — do a complete pass: open `documents/steiner-spec.md` and compare each **checked** acceptance criterion against the sections in `USAGE.md`. Add a section for every feature that is checked in the spec but not documented in USAGE.md. Expansion cycle features are especially likely to be missing."
    new_text: "Polish `USAGE.md` — do a complete pass: open `documents/steiner-spec.md` and scan EVERY section — both the initial `## Acceptance Criteria` section AND every `## Expansion [N]` section. For each checked criterion anywhere in the spec, confirm it has a corresponding section in `USAGE.md`. Add a section for every checked criterion that is not yet documented. Do not stop after the initial acceptance criteria — scroll to the end of the spec file and check all expansion sections. This is critical: expansion features from Cycles 2+ are almost always missing from USAGE.md."
  - id: "doc-quality-2"
    dimension: "Document Quality"
    risk: "low"
    file: "plugins/dmail/commands/dmail.md"
    description: "Phase 6 must update test count and coverage in both README.md and USAGE.md (not just README) to current values"
    old_text: "Write/update `README.md`:\n   ```markdown\n   # [project_name]\n   [one-line description]\n   ## Quick start\n   [installation + first command]\n   ## Test coverage\n   [N] tests · [coverage_pct]% statement coverage\n   ## Documentation\n   See [USAGE.md](USAGE.md) for full usage and [DOSSIER.md](DOSSIER.md) for project decisions.\n   ```"
    new_text: "Write/update `README.md`:\n   ```markdown\n   # [project_name]\n   [one-line description]\n   ## Quick start\n   [installation + first command]\n   ## Test coverage\n   [N] tests · [coverage_pct]% statement coverage\n   ## Documentation\n   See [USAGE.md](USAGE.md) for full usage and [DOSSIER.md](DOSSIER.md) for project decisions.\n   ```\n   **Also update `USAGE.md`**: find the test count / coverage line in USAGE.md (usually in a 'Running Tests' or 'Development' section) and update it to the current values (`[N] tests`, `[coverage_pct]%`). This number drifts stale across expansion cycles if not explicitly refreshed here."
  - id: "doc-quality-3"
    dimension: "Document Quality"
    risk: "low"
    file: "plugins/dmail/commands/dmail.md"
    description: "Phase 6 step 5 must also check acceptance criteria boxes in DOSSIER.md as features are confirmed met"
    old_text: "Update `DOSSIER.md` — mark expansion cycle N complete, record what was achieved. Specifically: update the `## Current status` or `## Overview` section (whichever exists) to set Phase to `[phase]`, Leap to `[leap_count]/[max_iterations]`, Cycle to `[expansion_cycle]`, and Divergence meter to `[coverage_pct]%`. If neither section exists, add `## Current status` at the top of the file."
    new_text: "Update `DOSSIER.md` — mark expansion cycle N complete, record what was achieved. Specifically:\n   a. Update the `## Current status` or `## Overview` section (whichever exists) to set Phase to `[phase]`, Leap to `[leap_count]/[max_iterations]`, Cycle to `[expansion_cycle]`, and Divergence meter to `[coverage_pct]%`. If neither section exists, add `## Current status` at the top of the file.\n   b. In the `## Acceptance Criteria` section of DOSSIER.md, check the box (`- [x]`) for every criterion that has been met this cycle. A criterion is met if: it was implemented by Daru AND verified by tests AND (for visual criteria) confirmed by Phase 3b. Do not leave all boxes unchecked through the entire run — checked boxes are how Mayuri and future sessions know what is complete."
  - id: "state-continuity-1"
    dimension: "State Continuity"
    risk: "low"
    file: "plugins/dmail/commands/dmail.md"
    description: "State file format spec must forbid inline comments displacing required fields"
    old_text: "**CRITICAL: Never omit fields. Never rename fields. If a field doesn't apply, write `null`. If no items in a list, write `[]`. Do NOT invent your own field names as substitutes for the ones above — a fresh session will fail to resume correctly if fields are missing or renamed.**"
    new_text: "**CRITICAL: Never omit fields. Never rename fields. If a field doesn't apply, write `null`. If no items in a list, write `[]`. Do NOT invent your own field names as substitutes for the ones above — a fresh session will fail to resume correctly if fields are missing or renamed.**\n\n**CRITICAL: Do NOT use `#` comments or free-form text sections inside `reading-steiner.md` as a substitute for required fields. Comments (e.g. `# ── Expansion Cycle 5 ──`) may be appended AFTER all required fields are written, but the required fields must all appear first in the correct format. A field buried after a comment block will be skipped by the stop hook parser. Write all 25 required fields first, then any supplemental notes after.**"
patches_approved: []
probe_selection_note: "Deviated from LRU order (API/Library) to target new visual quality gates added this session: Faris visual benchmarking, Okabe visual design spec, Kurisu rendering pipeline decision, Phase 3b visual quality check, Reviewer 4. Reference titles in prompt intentionally trigger all new code paths."
next_action: "select next probe — API or Library (neither has been run; web-game was run as exp 2)"
