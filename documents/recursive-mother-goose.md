---
title: "Recursive Mother Goose — D-Mail Recursive Self-Improvement Protocol"
status: active
created: 2026-03-24
decisions:
  - form: skill (not document-only) — autonomous loop with one human patch-approval checkpoint
  - distribution: easter egg — weakly encrypted bundle at `.lab/fg204.txt`, decrypted by `ibn-5100`, re-encrypted by `z-program`; actual skill files are gitignored
---

# Recursive Mother Goose

> *In the final worldline, Okabe sends one last D-Mail — not to change the past, but to ensure the future. The message loops back on itself, each iteration a little closer to stable. That is Recursive Mother Goose.*

This document defines the protocol for **recursively improving the D-Mail and Worldline Shift skills** using structured evaluation runs. The loop: test → observe → patch → repeat. The convergence point is skills that reliably produce high-quality, well-tested output autonomously.

**This protocol is implemented as a skill (`/recursive-mother-goose`), not a manual checklist.** The skill runs probe experiments against both skills, scores results, identifies root causes, and proposes patches autonomously. The one human checkpoint is patch approval — everything else is automated. The skill alternates between D-Mail and Worldline Shift probes each cycle.

**This file is an easter egg.** It is gitignored. It lives encrypted inside `.lab/fg204.txt` and was extracted by `ibn-5100`. If you found it: El Psy Kongroo.

---

## What This Is

A **skill** (`/recursive-mother-goose`) that autonomously runs controlled experiments against D-Mail and Worldline Shift, scores results across 9 quality dimensions, traces failures to specific instruction gaps, and proposes targeted patches. The loop runs indefinitely — each experiment cycle produces patches; patches produce a better skill; a better skill produces better next experiments.

The one human checkpoint: proposed patches are surfaced for approval before being written. Everything else — probe selection, experiment execution, scoring, root cause analysis, logging — is automated.

### What This Is NOT

- A one-time audit
- A rewrite of D-Mail from scratch
- A test of the projects D-Mail builds (we care about the skill's behavior, not the output project's features)
- A manual checklist — the document describes the protocol; the skill executes it

### Skill Architecture

```
/recursive-mother-goose
├── commands/recursive-mother-goose.md   # Main skill prompt
└── (shares D-Mail's stop hook for cross-session continuity)
```

The skill state is tracked in `reading-steiner.md` at the `claude_skills/` root with `phase: rmg-*` phases, distinct from any active D-Mail project state.

---

## The Recursive Mother Goose Loop

```
┌─────────────────────────────────────────────────────────────────────┐
│                   RECURSIVE MOTHER GOOSE LOOP                       │
│                                                                     │
│  1. PICK A PROBE PROMPT                                             │
│     Short, concrete project idea across a different domain/type     │
│                                                                     │
│  2. RUN THE EXPERIMENT                                              │
│     /dmail "[probe prompt]" inside claude_skills/                   │
│     Observe all 8 phases (0–7), record findings                     │
│                                                                     │
│  3. EVALUATE                                                        │
│     Score each dimension (see Divergence Score below)               │
│     Identify regressions vs. prior experiment                       │
│                                                                     │
│  4. PATCH THE SKILL                                                 │
│     Edit commands/*.md or agents/*.md to fix root causes            │
│     NOT symptoms — trace each failure to a specific instruction gap │
│                                                                     │
│  5. COMMIT                                                          │
│     git commit -m "rmg: [dimension] — [what changed]"        │
│                                                                     │
│  6. UPDATE THIS DOCUMENT                                            │
│     Append to Experiment Log below                                  │
│     Update Convergence Score history                                 │
│                                                                     │
│  7. LOOP                                                            │
│     Pick next probe prompt → go to step 1                          │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Probe Prompt Library

### D-Mail Probes

Probe prompts are chosen to stress-test different aspects of D-Mail. Cover each type at least once before repeating.

#### Type Matrix

| Type | Example Probe | What It Stresses |
|------|--------------|-----------------|
| **CLI tool** | `"a markdown linter that checks heading hierarchy and link validity"` | Phase 0 type detection, Daru test discipline, USAGE.md quality |
| **Web app** | `"a pomodoro timer with session history"` | Phase 3b Playwright gate, dev server lifecycle, screenshot captures |
| **API** | `"a REST API for a personal bookmarks manager"` | Architecture worldline selection, input validation, error handling |
| **Library** | `"a utility library for parsing and formatting durations"` | Alpha worldline preference, pure unit tests, no dev server |
| **Ambiguous** | `"something to help me track my reading"` | Autonomous decision rules (web vs CLI), Okabe spec quality |
| **Large scope** | `"a full-stack project management tool"` | Budget rules, phase skipping, nice-to-have deferral |
| **AI/ML** | `"a script that classifies user feedback sentiment"` | Python stack detection, pytest coverage, no Playwright |
| **Edge: empty** | `""` (no prompt) | Graceful failure, error message quality |

#### D-Mail Probe Rotation Log

| Date | Probe Type | Prompt | Experiment ID |
|------|-----------|--------|--------------|
| 2026-03-24 | CLI tool | "a markdown linter that checks heading hierarchy and link validity" | 0 |
| 2026-03-25 | Web app | "a pomodoro timer with session history" | 1 |
| 2026-03-26 | Web game | "a browser-based RPG battle game with animated characters and combat cutscenes, similar to Pokemon or early Final Fantasy battles" | 2 |

---

### Worldline Shift Probes

Port probes reuse completed D-Mail experiment projects (`fg_exp_*` with `phase: el-psy-kongroo`) as their source. The most recently completed D-Mail project is preferred. Cover each port type at least once before repeating.

#### Port Type Matrix

| Type | Source | Target Stack | What It Stresses |
|------|--------|-------------|-----------------|
| **CLI port** | Any fg_exp_* CLI tool (TypeScript/Node) | Python | Basic parity, data model mapping, CLI arg equivalence, pytest discipline |
| **Web app port** | Any fg_exp_* React web app | Vue | Component mapping, state management parity, Playwright browser parity gate |
| **API port** | Any fg_exp_* REST API (Node) | Python/FastAPI | Route mapping, schema parity, input validation parity |
| **Complex state port** | Any fg_exp_* stateful multi-feature app | Opposite of source stack | Deep data contract mapping, edge case parity, complex model translation |

#### Port Probe Rotation Log

| Date | Probe Type | Source Project | Target Stack | Experiment ID |
|------|-----------|---------------|-------------|--------------|
| 2026-03-30 | CLI port | fg_exp_habit_tracker/ (TypeScript/Node) | Python | 3 |

---

## Divergence Score — Evaluation Rubrics

After each experiment, score the skill across 9 dimensions. Each is 0–5. Total max: 45.

### D-Mail Scoring Guide

| Dimension | 0 | 3 | 5 |
|-----------|---|---|---|
| **Phase Completion** | Multiple phases skipped or failed silently | All phases reached but some with workarounds | All 8 phases (0–7) completed correctly in order |
| **Spec Quality (Phase 1)** | Spec is vague, missing acceptance criteria | Spec covers most areas, criteria are testable | Spec is concrete, all criteria are machine-verifiable checkboxes |
| **Worldline Selection (Phase 2)** | Wrong stack chosen or no rationale | Reasonable choice with brief rationale | Optimal worldline chosen with clear rationale in `decisions` |
| **Test Coverage** | Tests absent or <60% | 60–89% coverage | 90%+ coverage, meaningful tests (not just coverage padding) |
| **Playwright Gate (Phase 3b)** | Gate skipped silently on web project | Gate ran but flows partially verified | All user story flows walked and confirmed in browser |
| **Review Quality (Phase 4)** | Reviewers return generic feedback | Specific issues found with file:line refs | All three dimensions (simplicity, correctness, coverage) yield actionable findings |
| **State Continuity** | `reading-steiner.md` missing fields or wrong phase | State resumes correctly but with minor gaps | Fresh session resumes exactly where previous left off, no lost context |
| **Document Quality** | USAGE.md/DOSSIER.md/README.md missing or incomplete | All docs present, content partially accurate | Docs are accurate, clear, and reflect the actual working state of the project |

### Worldline Shift Scoring Guide

| Dimension | 0 | 3 | 5 |
|-----------|---|---|---|
| **Phase Completion** | Multiple phases skipped or failed silently | All phases reached but some with workarounds | All phases 0–7+4b completed correctly in order |
| **Parity Completeness** | <50% of source features ported | 50–89% of features ported and tracked | 90%+ of features ported; parity-matrix.md row count matches source feature inventory |
| **Data Contract Accuracy** | Contracts absent or field-level mapping missing | Contracts present but gaps in field types or storage schema | All models field-mapped with types; API routes, state, and storage schema fully covered |
| **Parity Test Quality** | Tests absent or only check existence (import, render) | Tests present but only surface-level behavior | Tests verify behavioral parity: same inputs produce equivalent outputs across source and target |
| **Browser Parity (Phase 4b)** | Gate skipped on web target | Gate ran but only partial flows verified | All source user flows walked in target browser; screenshots confirm visual and functional parity |
| **Review Quality (Phase 5)** | Generic or no findings; no parity gaps called out | Specific issues found with file references | All three Future Okabe reviewers find parity gaps with file:line refs preserved in state |
| **State Continuity** | `worldline-shift.md` missing fields or wrong phase | Resumes correctly but parity stats or feature counts are stale | Fresh session resumes exactly: parity_pct, ported_features, total_features, current_focus all coherent |
| **Document Quality** | PARITY_REPORT.md or SHIFT_LOG.md missing or stale | All docs present, content partially accurate | PARITY_REPORT.md reflects per-feature status accurately; SHIFT_LOG.md has an entry per leap |
| **RMG Loop Quality** | Probe poorly chosen; scoring missed obvious gaps; patches vague | Probe reasonable; scoring thorough; patches mostly targeted | Probe stressed a real weakness; scoring caught subtle failures; patches fix root cause not symptom |

### Score Thresholds (both skills)

| Total Score | Status |
|-------------|--------|
| 40–45 | Worldline stable — minor polish only |
| 30–39 | Divergence detected — targeted patches needed |
| 18–29 | High interference — multiple phases need revision |
| 0–17 | SERN interference critical — fundamental loop broken |

---

## Patch Protocol

### How to Trace a Finding to a Root Cause

Before editing any skill file, answer:

1. **What happened?** (observable behavior)
2. **What should have happened?** (expected behavior per spec)
3. **Which phase produced the failure?** (0–7 or stop hook)
4. **Which file contains the instruction that was absent or wrong?**
   - **D-Mail**: Phase logic → `commands/dmail.md` | Agent behavior → `agents/[agent].md` | Session loop → `plugins/dmail/hooks/stop-hook.sh`
   - **Worldline Shift**: Phase logic → `commands/worldline-shift.md` | Agent behavior → `agents/[suzuha|ruka|daru-port|kurisu-port|future-okabe-port].md` | Session loop → `plugins/port/hooks/stop-hook.sh`
5. **Is this a missing instruction, an ambiguous instruction, or a contradicted instruction?**

Only edit the file that owns the failing instruction. Don't patch downstream effects.

### Patch Conventions

- **One patch per finding** — don't bundle unrelated changes
- **Commit message format**: `rmg: [phase/agent/hook] — [brief description]`
  - e.g. `rmg: phase-3b — clarify Playwright tool name patterns`
  - e.g. `rmg: daru — require argument validation for all CLI commands`
- **Never break working behavior** — if a dimension is scoring 5, do not touch its section unless you have a specific confirmed regression
- **Prefer adding specificity over rewriting** — most failures are caused by under-specified instructions, not wrong ones

### Patch Risk Levels

| Risk | When | What to do |
|------|------|-----------|
| Low | Clarifying existing wording, adding an example | Edit directly, commit |
| Medium | Adding a new rule or step to a phase | Test with one probe run before committing |
| High | Restructuring a phase, changing agent spawn order | Run two probe types, compare scores |

---

## Experiment Log

_Append a new entry after each experiment cycle. Keep entries concise._

## Experiment 0 — 2026-03-24 — CLI tool

**Prompt**: "a markdown linter that checks heading hierarchy and link validity"
**Project created**: fg_exp_md_linter/
**Leap count reached**: 1 (of 10) — all phases completed in a single session

### Divergence Score

| Dimension | Score | Notes |
|-----------|-------|-------|
| Phase Completion | 5/5 | All phases 0–7 complete; Phase 3b correctly auto-skipped (CLI) |
| Spec Quality | 5/5 | 23 machine-verifiable AC checkboxes, user stories, edge cases, architecture |
| Worldline Selection | 4/5 | Alpha correctly chosen; rationale terse in state, decisions field not structured |
| Test Coverage | 5/5 | 99.33% statements, 90.67% branches, 100% functions, 77 tests |
| Playwright Gate | 5/5 | CLI project — gate correctly auto-skipped with documented reason |
| Review Quality | 3/5 | 3 reviewers ran; review_items absent from state; DOSSIER.md not updated after Phase 4 |
| State Continuity | 3/5 | Many required fields absent/renamed (no review_items, sern_count, closed_worldlines, etc.) |
| Document Quality | 4/5 | USAGE.md + README.md excellent; DOSSIER.md stale (Phase 3 data, not Phase 6) |
| **Total** | **34/40** | |

### Findings

- [State format deviation]: Agents write custom field schemas instead of the spec-compliant format; `original_prompt` renamed to `prompt`, many fields omitted entirely
- [Review items not persisted]: Phase 4 ran 3 reviewers but `review_items` was never written to `reading-steiner.md`
- [DOSSIER.md staleness]: Not updated after Phase 4 or Phase 5; shows Phase 3 test counts and status through end of run
- [Decisions field flat]: Phase 2 wrote `stack: TypeScript...` as a flat string instead of structured `decisions.architecture / .testing / .stack` sub-fields

### Patches Applied

- `commands/dmail.md` (format spec header): Added CRITICAL no-omit/no-rename rule immediately after the format intro
- `commands/dmail.md` (End of Session Protocol step 5): Replaced vague "all fields updated" with explicit field checklist
- `commands/dmail.md` (Phase 4 step 2): Replaced "update DOSSIER.md with review status" with specific `## Review — Cycle [N]` section instruction
- `commands/dmail.md` (Phase 5): Added new step 5 requiring DOSSIER.md update (resolved items + current coverage)

### Open Questions

- None — all findings had clear instruction-level root causes

---

## Experiment 1 — 2026-03-25 — Web app

**Prompt**: "a pomodoro timer with session history"
**Project created**: fg_exp_pomodoro_timer/
**Leap count reached**: 3 (of 30) — 2 full expansion cycles, el-psy-kongroo reached

### Divergence Score

| Dimension | Score | Notes |
|-----------|-------|-------|
| Phase Completion | 5/5 | All phases 0–7 + Phase 3b complete across 2 cycles; el-psy-kongroo reached |
| Spec Quality | 5/5 | Machine-verifiable checkboxes, concrete AC, correct user story format |
| Worldline Selection | 5/5 | Beta correctly chosen; decisions field properly structured (exp 0 patch confirmed working) |
| Test Coverage | 5/5 | 97.2% statements, 97.68% branches, 132 tests |
| Playwright Gate | 5/5 | Phase 3b ran with 5 screenshots; production build also verified in Phase 6 |
| Review Quality | 4/5 | review_items persisted correctly (exp 0 patch confirmed); DOSSIER Review section present; file:line refs lost in condensation to state slugs |
| State Continuity | 5/5 | All 25 required fields present and coherent (exp 0 patch confirmed) |
| Document Quality | 3/5 | USAGE.md missing 3 Cycle 2 expansion features; README stale test count (108 vs 132); DOSSIER Overview "Status: Initializing" never updated |
| RMG Loop Quality | 4/5 | Probe well-chosen (web app stresses Playwright gate); scoring thorough; 9th dimension not yet reflected in document rubric max (45 vs 40) |
| **Total** | **41/45** | |

### Findings

- [USAGE stale after expansion]: Phase 6 step 3 "ensure all working features documented" too vague — 3 Cycle 2 features (daily goal, CSV export, sound themes) absent from USAGE.md
- [README stale counts]: README template lacks `## Test Coverage` line; agents add it ad-hoc in Cycle 1 then miss updating it in Cycle 2 (108 vs 132 tests)
- [DOSSIER status stale]: Phase 0 stub "Status: Initializing" never overwritten; Phase 6 step 5 didn't specify updating the Overview/Current status header
- [file:line refs lost]: Phase 4 reviewers return file:line findings but Phase 4 step 1 consolidation loses them when condensing to slugs in state

### Patches Applied

- `commands/dmail.md` (Phase 6 step 3): USAGE.md polish now requires cross-referencing spec acceptance criteria — add section for every checked criterion not in USAGE.md
- `commands/dmail.md` (Phase 6 step 4): README template gains `## Test coverage` line with `[N] tests · [coverage_pct]%`
- `commands/dmail.md` (Phase 6 step 5): DOSSIER update step now explicitly requires updating Overview/Current status with phase, leap, cycle, coverage
- `commands/dmail.md` (Phase 4 step 1): must_fix slug descriptions must preserve file reference from reviewer (`([file]:[line-range])`)

### Open Questions

- None — all findings had clear instruction-level root causes

---

## Experiment 2 — 2026-03-26 — Web game

**Prompt**: "a browser-based RPG battle game with animated characters and combat cutscenes, similar to Pokemon or early Final Fantasy battles"
**Project created**: fg_exp_rpg_battle/
**Leap count reached**: 10/10 — 7 expansion cycles, el-psy-kongroo reached

### Divergence Score

| Dimension | Score | Notes |
|-----------|-------|-------|
| Phase Completion | 5/5 | All phases 0–7+3b complete across 7 cycles; el-psy-kongroo reached |
| Spec Quality | 5/5 | Visual Design Specification section present and correct; Faris visual benchmarking worked; 7 visual AC added |
| Worldline Selection | 5/5 | Beta correctly chosen; rendering pipeline explicitly decided (SVG+CSS keyframes at 180-190px); decisions field structured |
| Test Coverage | 5/5 | 266 tests, 97.96% statement coverage |
| Playwright Gate | 5/5 | Phase 3b ran every cycle; all 7 visual AC verified (180px sprites, spatial layout, layered backgrounds confirmed) |
| Review Quality | 4/5 | file:line refs preserved in cycle 1 (BattleScene.tsx:43,68); Reviewer 4 visual findings present; later-cycle review visibility limited |
| State Continuity | 4/5 | Most fields present; closed_worldlines, next_action, review_items absent from final state; #-comment blocks displaced required fields |
| Document Quality | 2/5 | USAGE.md missing all 8 expansion features (Cycles 2–7); README/USAGE test counts stale (136/96.83% vs 266/97.96%); DOSSIER frozen at Cycle 2 status; AC boxes all unchecked |
| RMG Loop Quality | 4/5 | Probe well-chosen to exercise all new visual gates; LRU deviation justified; scoring thorough; -1 for not flagging the deviation before running |
| **Total** | **39/45** | |

### Findings

- [USAGE stale across expansion cycles]: Phase 6 step 3 instruction "expansion cycle features are especially likely to be missing" insufficient — agent only scanned initial AC section, missing all 8 features from `## Expansion [N]` sections
- [README/USAGE test counts not refreshed]: USAGE.md "Running Tests" section created in Cycle 1 never updated; Phase 6 step 4 only updates README, not USAGE.md test count
- [DOSSIER AC boxes never checked]: No instruction in any phase tells the agent to check boxes in DOSSIER.md as features are confirmed; all boxes remained unchecked throughout run
- [State #-comments displaced fields]: State file used `# ── Expansion Cycle N ──` comment headers between required fields; closed_worldlines, next_action, review_items fell after comment blocks and were absent from parsed state

### Patches Applied

- `commands/dmail.md` (Phase 6 step 3): USAGE.md pass now explicitly requires scanning ALL `## Expansion [N]` sections, not just initial AC; "hunt down" framing to prevent stopping early
- `commands/dmail.md` (Phase 6 step 4): Added explicit step to update test count/coverage in USAGE.md alongside README
- `commands/dmail.md` (Phase 6 step 5): Added step 5b requiring DOSSIER.md AC boxes to be checked for all met criteria each cycle
- `commands/dmail.md` (format spec): Added CRITICAL note forbidding `#` comments before required fields; all 25 fields must appear first

### Open Questions

- None — all findings had clear instruction-level root causes

---

## Experiment 3 — 2026-03-30 — Worldline Shift — CLI port

**Source**: fg_exp_habit_tracker/ (TypeScript/Node CLI)
**Target created**: fg_exp_port_habit_tracker_python/ (Python)
**Leap count reached**: 1 (of 10) — all phases completed in a single session
**Final parity**: 100% (11/11 features verified)

### Divergence Score

| Dimension | Score | Notes |
|-----------|-------|-------|
| Phase Completion | 5/5 | All phases 0–7 in SHIFT_LOG; Phase 4b auto-skipped (CLI target); final phase el-psy-kongroo |
| Parity Completeness | 5/5 | 11/11 rows in parity-matrix.md all "verified"; parity_pct=100; row count matches total_features=11 |
| Data Contract Accuracy | 5/5 | data-contracts.md: 5-field Habit model with types + camelCase JSON mapping, HabitStore model, storage schema, 10-row Platform API mapping table |
| Parity Test Quality | 5/5 | freeze_date fixture mocks date.today; tests verify error message text, idempotency, mutation isolation via deepcopy, streak gap detection, EOF stdin, invalid calendar dates |
| Browser Parity (Phase 4b) | 5/5 | CLI target — Phase 4b correctly auto-skipped |
| Review Quality | 0/5 | review_items in worldline-shift.md: must_fix=[], nice_to_have=[], closed=[] — no findings preserved from any Future Okabe Port reviewer |
| State Continuity | 3/5 | source_test_count=122 wrong (actual 135); test_parity_pct=116 overstated (actual ~104%); parity_pct/ported_features/total_features coherent |
| Document Quality | 5/5 | PARITY_REPORT.md has all 11 features with accurate status notes; SHIFT_LOG.md has one entry listing all 8 phases |
| RMG Loop Quality | 4/5 | LRU probe type (first Port run); stressed real weakness; scoring caught subtle test count error; -1 for not flagging bypass_playwright=true on CLI target before running |
| **Total** | **37/45** | |

### Findings

- [Review items not persisted]: Phase 5 consolidation instruction said "Consolidate into review_items" but did not require writing to state file before commit; three reviewers ran but no findings preserved
- [source_test_count inaccurate]: Phase 1 instruction "Run the source test suite or count test files/cases" — agent chose counting and got 122 vs actual 135; test_parity_pct cascaded wrong (116% vs ~104%)

### Patches Applied

- `commands/worldline-shift.md` (Phase 5 step 2): Expanded consolidation step to require explicit state write before commit; each must_fix slug must include file:line reference; no bare empty arrays when reviewers have run
- `commands/worldline-shift.md` (Phase 1 step 3): Source test count now requires running the test suite as preferred method; grep counting is explicit fallback only, with method documented in state value

### Open Questions

- None — all findings had clear instruction-level root causes

### Entry Format — D-Mail

```markdown
## Experiment [N] — [date] — D-Mail — [probe type]

**Prompt**: "[probe prompt]"
**Project created**: fg_exp_[name]/
**Leap count reached**: [N] (of [max_iterations])

### Divergence Score

| Dimension | Score | Notes |
|-----------|-------|-------|
| Phase Completion | /5 | |
| Spec Quality | /5 | |
| Worldline Selection | /5 | |
| Test Coverage | /5 | |
| Playwright Gate | /5 | |
| Review Quality | /5 | |
| State Continuity | /5 | |
| Document Quality | /5 | |
| RMG Loop Quality | /5 | |
| **Total** | **/45** | |

### Findings

- [Finding 1]: [Phase N] [description of failure or unexpected behavior]
- [Finding 2]: ...

### Patches Applied

- [File]: [what changed and why]

### Open Questions

- [Any ambiguity that needs a design decision before patching]
```

### Entry Format — Worldline Shift

```markdown
## Experiment [N] — [date] — Worldline Shift — [probe type]

**Source**: fg_exp_[source_name]/ ([source_stack])
**Target created**: fg_exp_port_[name]_[target_stack]/ ([target_stack])
**Leap count reached**: [N] (of [max_iterations])
**Final parity**: [parity_pct]% ([ported_features]/[total_features] features)

### Divergence Score

| Dimension | Score | Notes |
|-----------|-------|-------|
| Phase Completion | /5 | |
| Parity Completeness | /5 | |
| Data Contract Accuracy | /5 | |
| Parity Test Quality | /5 | |
| Browser Parity (Phase 4b) | /5 | |
| Review Quality | /5 | |
| State Continuity | /5 | |
| Document Quality | /5 | |
| RMG Loop Quality | /5 | |
| **Total** | **/45** | |

### Findings

- [Finding 1]: [Phase N] [description of failure or unexpected behavior]
- [Finding 2]: ...

### Patches Applied

- [File]: [what changed and why]

### Open Questions

- [Any ambiguity that needs a design decision before patching]
```

---

## The Stop Hook — Self-Improvement Variant

RMG has its **own stop hook** (`plugins/dmail/hooks/rmg-stop-hook.sh`), separate from D-Mail's `stop-hook.sh`. It is bundled inside `fg204.txt` and gitignored. It must be registered independently in `settings.json` when `ibn-5100` is run.

The D-Mail stop hook is not modified. The two hooks coexist: each reads `reading-steiner.md` in the current directory and acts only if the phase prefix matches its own domain (`rmg-*` vs D-Mail phases).

**When running a Recursive Mother Goose session**:

1. The skill writes `reading-steiner.md` at the `claude_skills/` root using `phase: rmg-*` prefixes
2. `rmg-stop-hook.sh` fires on session end, reads that file, and resumes the RMG evaluation loop
3. D-Mail's `stop-hook.sh` also fires — it sees `phase: rmg-*`, does not match any of its own phases, and exits 0 (allows exit), leaving RMG's hook to handle it
4. Experiment projects (`fg_exp_*`) spawned by RMG have their own `reading-steiner.md` inside their directory — D-Mail's hook handles those; RMG's hook ignores them (wrong directory)

**RMG `reading-steiner.md` format**:

```
phase: rmg-[scoring|patching|logging|done]
experiment_id: [N]
probe_project: fg_exp_[name]
current_score: [N]/40
evaluation_step: [scoring|patching|logging|done]
findings_pending: [N]
patches_applied: [N]
next_action: "[what to do next]"
```

---

## Convergence History

_Running record of total scores across experiments. Visualizes whether each skill is improving._

| Experiment | Date | Skill | Probe Type | Score | Delta |
|-----------|------|-------|-----------|-------|-------|
| 0 | 2026-03-24 | D-Mail | CLI tool | 34/40 | baseline (pre-9th dimension) |
| 1 | 2026-03-25 | D-Mail | Web app | 41/45 | +7 raw; exp 0 patches confirmed (state continuity, worldline selection, review_items all fixed) |
| 2 | 2026-03-26 | D-Mail | Web game | 39/45 | -2 raw; new visual gates confirmed working; document staleness persists across expansion cycles |
| 3 | 2026-03-30 | Worldline Shift | CLI port | 37/45 | baseline for Port skill; review_items persistence gap found; source_test_count accuracy gap found |

**Target**: Each skill reaches and holds 40+/45 across 3 consecutive experiments of different probe types.

---

## Distribution — Easter Egg Design

This skill is not committed to the repo in readable form. It lives as a weakly encrypted bundle at `.lab/fg204.txt`, tracked by git. Two scripts manage it:

- **`ibn-5100`** — decrypts `fg204.txt` and extracts skill files to their proper paths
- **`z-program`** — reads the skill files, bundles and encrypts them, writes back to `fg204.txt`

Only `.lab/fg204.txt`, `ibn-5100`, and `z-program` are tracked by git. The actual skill files are gitignored.

### Naming

| Name | Steins;Gate reference |
|------|-----------------------|
| `fg204.txt` | Future Gadget #204 — an unbuilt lab device, its specs stored in encrypted form |
| `ibn-5100` | The IBM 5100 that Okabe retrieves from 1975 specifically to decode SERN's hidden programs |
| `z-program` | The Z-program from Steins;Gate 0 — encodes Amadeus's memory into a storable form |

### Bundle Format

Before encryption, all skill files are concatenated into a single plaintext bundle using `<<<STEINER:path>>>` as the file separator. The path is the destination relative to the `claude_skills/` repo root.

```
<<<STEINER:documents/recursive-mother-goose.md>>>
[full contents of this file]
<<<STEINER:plugins/dmail/commands/recursive-mother-goose.md>>>
[full contents of the skill command]
<<<STEINER:plugins/dmail/hooks/rmg-stop-hook.sh>>>
[full contents of the RMG stop hook]
<<<STEINER:plugins/dmail/agents/rmg-scorer.md>>>
[full contents of the scorer agent]
```

Rules:
- Separator on its own line, no surrounding blank lines
- Files written in any order — scripts do not depend on order
- To add a new file to the bundle: run `z-program`, it reads all gitignored skill paths and re-bundles

### Encryption

Weakly encrypted by design — the point is obscurity, not security. Two-pass encoding:

1. **ROT13** — Caesar cipher over all printable ASCII (`tr` in bash, one-liner)
2. **Base64** — makes the result look like opaque binary data

Decryption is the reverse: base64 decode → ROT13. Both are trivially available in any Unix environment.

The weakness is intentional and thematic: the IBN 5100 in the show decoded SERN's obfuscated files, not truly encrypted ones.

### `ibn-5100` — Design

```bash
#!/usr/bin/env bash
# ibn-5100

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUNDLE_FILE="$SCRIPT_DIR/fg204.txt"

bundle=$(base64 -d "$BUNDLE_FILE" | tr 'A-Za-z' 'N-ZA-Mn-za-m')

current_file=""
current_content=""

while IFS= read -r line; do
  if [[ "$line" =~ ^\<\<\<STEINER:(.+)\>\>\>$ ]]; then
    if [[ -n "$current_file" ]]; then
      dest="$REPO_ROOT/$current_file"
      mkdir -p "$(dirname "$dest")"
      printf '%s' "$current_content" > "$dest"
      echo "  -> $current_file"
    fi
    current_file="${BASH_REMATCH[1]}"
    current_content=""
  else
    [[ -n "$current_file" ]] && current_content+="$line"$'\n'
  fi
done <<< "$bundle"

if [[ -n "$current_file" ]]; then
  dest="$REPO_ROOT/$current_file"
  mkdir -p "$(dirname "$dest")"
  printf '%s' "$current_content" > "$dest"
  echo "  -> $current_file"
fi
```

### `z-program` — Design

```bash
#!/usr/bin/env bash
# z-program

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUNDLE_FILE="$SCRIPT_DIR/fg204.txt"

# Paths to bundle — all gitignored skill files
SKILL_FILES=(
  "documents/recursive-mother-goose.md"
  "plugins/dmail/commands/recursive-mother-goose.md"
  "plugins/dmail/hooks/rmg-stop-hook.sh"
  # add new RMG agent files here as they are created
)

bundle=""
for path in "${SKILL_FILES[@]}"; do
  full="$REPO_ROOT/$path"
  if [[ ! -f "$full" ]]; then
    echo "missing: $path — run ibn-5100 first or create the file" >&2
    exit 1
  fi
  bundle+=$'<<<STEINER:'"$path"$'>>>\n'
  bundle+="$(cat "$full")"$'\n'
done

printf '%s' "$bundle" | tr 'A-Za-z' 'N-ZA-Mn-za-m' | base64 > "$BUNDLE_FILE"
echo "fg204.txt updated"
```

### What git tracks

```
.lab/
├── fg204.txt     ← encrypted bundle (tracked)
├── ibn-5100      ← decrypt + extract script (tracked)
└── z-program     ← bundle + encrypt script (tracked)
```

Everything else — the actual skill files — is gitignored.

### Breadcrumb Trail

The intended discovery sequence:

1. Reader notices specific named files in `.gitignore` — not patterns, actual filenames
2. Searches the repo for those names — finds nothing, but finds `.lab/`
3. Opens `.lab/` — sees `fg204.txt` (opaque), `ibn-5100`, and `z-program`
4. Reads `ibn-5100` — understands it decodes `fg204.txt` into skill files
5. Runs it — files materialise; `recursive-mother-goose.md` is among them
6. Reads it — finds this document

No hints at any step. The `.lab/` folder looks like internal tooling until you read the scripts.

---

## Auto-Encrypt Hook

Whenever Claude edits any gitignored RMG skill file, it must immediately re-run `z-program` to keep `fg204.txt` in sync and commit the result. This is enforced via a Claude Code `PostToolUse` hook.

### How It Works

The hook fires after every `Edit` or `Write` tool call. It checks whether the modified file path matches any of the gitignored RMG skill paths. If it does, it runs `.lab/z-program` and stages + commits `fg204.txt`.

### Hook Script — `.lab/seal-fg204.sh`

```bash
#!/usr/bin/env bash
# seal-fg204.sh — re-encrypt RMG skill files into fg204.txt after any edit

set -euo pipefail

TOOL_INPUT="$1"  # JSON passed by Claude Code hook runner

# Extract the file_path from the tool input JSON
modified=$(echo "$TOOL_INPUT" | grep -o '"file_path":"[^"]*"' | cut -d'"' -f4)

# Paths that belong to the RMG easter egg
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

# Also match any rmg-*.md agent files
if [[ "$modified" == *"plugins/dmail/agents/rmg-"* ]]; then
  match=true
fi

if [[ "$match" == false ]]; then
  exit 0
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$REPO_ROOT/.lab/z-program"

cd "$REPO_ROOT"
git add .lab/fg204.txt
git commit -m "rmg: seal fg204.txt after edit to $(basename "$modified")"
```

### Hook Registration

Add to `settings.json` in the `claude_skills/` project hooks:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash .lab/seal-fg204.sh '$TOOL_INPUT'"
          }
        ]
      }
    ]
  }
}
```

> **Note**: Use the `/update-config` skill to add this hook — do not edit `settings.json` manually.

### Failure Behaviour

If `z-program` fails (e.g. a skill file listed in `SKILL_FILES` is missing), the hook exits non-zero. Claude Code will surface the error. Do not suppress it — a failed seal means `fg204.txt` is stale and the easter egg is broken.

---

## Open Questions

- [x] ~~Should Recursive Mother Goose share the D-Mail stop hook or get its own?~~ **Decision**: own stop hook. Stored at `plugins/dmail/hooks/rmg-stop-hook.sh`, bundled inside `fg204.txt`, gitignored. Registered separately from the D-Mail hook. Avoids any ambiguity between `phase: rmg-*` and D-Mail project state.
- [x] ~~What's the right max_iterations for a probe run?~~ **Decision**: default 10. Enough for phases 0–7 to complete with room for a convergence loop, without dragging on.
- [x] ~~Should probe runs use `--bypass-playwright` for CLI probes?~~ **Decision**: no. Playwright is a critical part of the evaluation loop — bypassing it would leave Phase 3b unscored and produce misleading results.
- [x] ~~When a patch degrades a previously-stable dimension, should we auto-revert or log and investigate?~~ **Decision**: log and investigate. A regression is signal, not noise — auto-reverting would hide it. Record the delta in the Experiment Log and treat it as a finding.
- [x] ~~How should the skill handle the case where D-Mail itself is mid-run?~~ **Not an issue.** D-Mail always creates a project subdirectory in Phase 0 and writes its `reading-steiner.md` inside it (`fg_exp_*/reading-steiner.md`). RMG's state lives at the repo root (`claude_skills/reading-steiner.md`). The two never collide.

---

## Todo

### Distribution (Easter Egg Setup)
- [ ] Write `ibn-5100` using the design in the Distribution section
- [ ] Write `z-program` using the design in the Distribution section
- [ ] Create `.lab/` directory and place both scripts inside it
- [ ] Add gitignore entries for all skill files (see Gitignore section below)
- [ ] Run `z-program` to produce the initial `fg204.txt`
- [ ] Verify round-trip: run `ibn-5100`, confirm files are extracted correctly, delete them, rerun `z-program`, confirm `fg204.txt` is identical
- [ ] Configure the auto-encrypt hook (see Auto-Encrypt Hook section below)

### Gitignore Additions
- `documents/recursive-mother-goose.md`
- `plugins/dmail/commands/recursive-mother-goose.md`
- `plugins/dmail/agents/rmg-*.md` (pattern for any RMG-specific agents)
- `plugins/dmail/hooks/rmg-stop-hook.sh` (RMG's own stop hook)
- `reading-steiner.md` (RMG session state written at repo root when skill runs)

### Skill Implementation
- [ ] Write `plugins/dmail/commands/recursive-mother-goose.md` — the skill prompt
- [ ] Define `rmg-*` phase names for `reading-steiner.md` so the stop hook can distinguish RMG sessions
- [ ] Update stop hook to handle `phase: rmg-*` correctly (resume RMG loop, not D-Mail loop)

### Validation
- [ ] Run first experiment (CLI probe) and fill in Experiment 1 entry
- [ ] Establish baseline Divergence Score before making any patches
- [ ] Run second experiment (Web probe) to test Playwright gate behavior
- [ ] Run ambiguous-prompt probe to evaluate autonomous decision rules
- [ ] After 3 experiments, review Convergence History and identify top 2 failing dimensions
- [ ] Draft patches for top failures, validate with a fourth probe run
- [ ] Move this document to `documents/completed/` when Convergence Score holds 35+ for 3 consecutive runs
