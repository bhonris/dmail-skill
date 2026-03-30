---
description: "Comprehensive code project porting — migrates a codebase from one tech stack to another with 1:1 feature parity"
argument-hint: "\"source/path\" [--target \"target/path\"] [--from \"flutter\"] [--to \"react-pwa\"] [--max-iterations N] [--push-to-github]"
---

# Worldline Shift — Autonomous Project Porting

You are orchestrating a **Worldline Shift**: porting an entire project from one technology stack to another while maintaining exact functional parity. The source project is the living spec — every feature, screen, endpoint, and data model must converge in the target worldline.

---

## Session Startup

1. Look for `worldline-shift.md` in the **target project directory**.
   - **Missing** → This is a fresh shift. Begin at **Phase 0**.
   - **Present** → Read it. Resume from the saved `phase` and `next_action`.
2. If resuming, increment `leap_count` by 1 and update `session_id`.

### Playwright Gate (web targets only)

If `target_type` is `web` or `pwa`:
- Check that Playwright MCP tools are available (`browser_navigate`, `browser_snapshot`).
- If missing and `--bypass-playwright` was NOT passed → **hard stop**. Print:
  > Worldline Shift requires Playwright MCP for web parity verification. Start the Playwright MCP server or pass `--bypass-playwright` to skip browser checks (not recommended — parity cannot be fully verified).
- If `--bypass-playwright` → set `bypass_playwright: true` in state; warn that Phase 4b will be skipped.

---

## State File: `worldline-shift.md`

Written to the **target project root**. All fields required — use `null` for empty, `[]` for empty lists.

```yaml
phase: [current-phase]
leap_count: [N]
session_id: [timestamp]
prev_head: [git commit hash]
original_prompt: "[user's prompt]"
source_path: "[absolute path to source project]"
source_stack: "[e.g., flutter, swift, android-kotlin]"
target_stack: "[e.g., react-pwa, nextjs, vue]"
project_name: "[snake_case]"
target_type: [web|pwa|cli|api|library|mobile]
test_cmd: "[pnpm test|pytest|npm test]"
dev_server_port: [N or null]
coverage_pct: [0-100 or unknown]
parity_pct: [0-100]
total_features: [N]
ported_features: [N]
current_focus: "[what to work on]"
blocked_on: null
last_test_run: "[N] pass, [N] fail"
next_action: "[specific action]"
sern_interference_count: [0-N]
decisions:
  - architecture: "[chosen approach]"
  - testing: "[framework and target]"
  - stack: "[language, runtime, package manager]"
parity_matrix_path: documents/parity-matrix.md
feature_inventory_path: documents/feature-inventory.md
data_contract_path: documents/data-contracts.md
spec_path: documents/convergence-spec.md
review_items:
  must_fix:
    - "[slug]: [description]"
  nice_to_have:
    - "[slug]: [description]"
  closed:
    - "[slug]: [reason]"
max_iterations: [N]
push_to_github: [true|false]
bypass_playwright: [true|false]
```

---

## Phase 0 — Worldline Shift Initialization

**Goal**: Set up target project, validate source, create state file.

1. **Parse arguments**:
   - `source_path` — required, must exist and contain code
   - `--target` — target directory (default: `./[source_name]_port/`)
   - `--from` — source stack hint (auto-detected if omitted)
   - `--to` — target stack (required, or infer from user prompt)
   - `--max-iterations` — default 30
   - `--push-to-github` — default false
2. **Validate source**: Confirm `source_path` exists and contains recognizable project files.
3. **Auto-detect source stack** if not specified:
   - `pubspec.yaml` → Flutter/Dart
   - `build.gradle` + `AndroidManifest.xml` → Android (Kotlin/Java)
   - `*.xcodeproj` or `Package.swift` → iOS (Swift)
   - `package.json` with React → React web app
   - `requirements.txt` or `pyproject.toml` → Python
   - `go.mod` → Go
   - `Cargo.toml` → Rust
4. **Auto-select target stack defaults** if only high-level hint given:
   - `react-pwa` or `web` → React + Vite + TypeScript + pnpm
   - `nextjs` → Next.js + TypeScript + pnpm
   - `cli` → Node + TypeScript
   - `python` → Python + pytest
   - `flutter` → Flutter + Dart
5. **Create target directory**, `git init`, create initial files:
   - `worldline-shift.md` (state file)
   - `documents/` directory
   - `SHIFT_LOG.md` (migration log — one entry per leap)
   - `PARITY_REPORT.md` (running parity status)
6. **Initial commit**: `shift: init — worldline shift from [source_stack] to [target_stack]`
7. → **Phase 1**

---

## Phase 1 — Source Reconnaissance

**Goal**: Exhaustive analysis of the source project. The source is the spec.

1. **Spawn Moeka** (codebase explorer) pointed at `source_path`:
   - Every file, directory, module, package
   - All dependencies and their purposes
   - Test structure and existing test patterns
   - Configuration files and environment variables
   - Build system and scripts
2. **Spawn Suzuha** (source analyzer) with Moeka's report:
   - Extract **complete feature inventory** → write to `documents/feature-inventory.md`
   - Format per feature:
     ```
     ### F-[NNN]: [Feature Name]
     - **Description**: [what it does from user perspective]
     - **Source files**: [list of files implementing this]
     - **User-facing**: [yes/no]
     - **Has tests**: [yes/no]
     - **Data models**: [list of models/schemas involved]
     - **External deps**: [APIs, services, databases]
     - **Complexity**: [small|medium|large|xl]
     - **Priority**: [critical|high|medium|low]
     - **Notes**: [edge cases, platform-specific behavior, gotchas]
     ```
   - Prioritize: critical path first, then high-value, then the rest
   - Group features by domain/module for logical porting order
3. **Update state**: `phase: source-recon`, update `total_features`
4. **Commit**: `shift: source reconnaissance — [N] features inventoried`
5. → **Phase 2**

---

## Phase 2 — Attractor Field Mapping

**Goal**: Create the 1:1 parity matrix and map all data contracts.

1. **Spawn Suzuha** (parity mapper) with the feature inventory:
   - Create `documents/parity-matrix.md` — the master tracking document:
     ```
     | ID | Feature | Source Files | Target Files | Tests | Parity Status |
     |----|---------|-------------|-------------|-------|---------------|
     | F-001 | User login | lib/auth/... | src/auth/... | [ ] | not-started |
     | F-002 | ... | ... | ... | [ ] | not-started |
     ```
   - Parity statuses: `not-started` → `in-progress` → `ported` → `verified`
   - Include totals row with parity percentage
2. **Spawn Luka** (data contract mapper) with source analysis:
   - Create `documents/data-contracts.md`:
     - Every data model / schema / type with field-by-field mapping
     - API endpoints with request/response shapes
     - State management patterns and their target equivalents
     - Storage schemas (local DB, preferences, cache)
     - Navigation routes / screen flow mapping
   - Format:
     ```
     ### Model: [SourceName] → [TargetName]
     | Source Field | Source Type | Target Field | Target Type | Notes |
     |-------------|-----------|-------------|-----------|-------|
     | user_id | String | userId | string | |
     ```
3. **Update state**: `phase: attractor-field`
4. **Commit**: `shift: attractor field mapped — [N] features, [M] data models`
5. → **Phase 3**

---

## Phase 3 — Convergence Architecture

**Goal**: Design target project architecture that cleanly maps to source features.

1. **Spawn Kurisu** twice — propose two architectures for the target:
   - **Alpha Worldline** (Direct Map): Mirror source structure as closely as possible in target stack. Fastest to port, easiest to verify parity.
   - **Beta Worldline** (Idiomatic): Use target stack's idiomatic patterns and conventions. Cleaner long-term, but more translation work.
   - Both must include:
     - Directory structure (tree)
     - How each source module maps to target modules
     - Key dependencies and their purpose
     - Testing strategy (framework, patterns, how to verify parity)
     - Migration order recommendation (which features to port first)
2. **Select architecture**:
   - Small project (< 15 features) → Alpha (direct map)
   - Large project or significantly different paradigms → Beta (idiomatic)
   - Always prefer the one that makes parity verification easier
3. **Scaffold target project**:
   - Install dependencies
   - Create directory structure
   - Set up test framework with a passing smoke test
   - Configure build system
   - Write `documents/convergence-spec.md` — the architectural decisions and mapping rules
4. **Update state**: `phase: convergence-architecture`, record decisions
5. **Commit**: `shift: convergence architecture — [alpha|beta] worldline selected`
6. → **Phase 4**

---

## Phase 4 — Worldline Migration (Feature-by-Feature)

**Goal**: Port one feature at a time with TDD, maintaining strict parity.

For each unported feature from the parity matrix (in priority order):

1. **Spawn Moeka** to read the target project's current state.
2. **Spawn Moeka** to re-read the source feature's implementation (specific files from inventory).
3. **Spawn Daru** with:
   - The feature spec from the inventory
   - The data contract mapping for relevant models
   - The source implementation (for reference, NOT to copy blindly)
   - Moeka's target codebase report
   - Instructions:
     a. **Write parity tests FIRST** — tests that verify the exact same behavior as the source:
        - Same inputs → same outputs
        - Same error cases → same error handling
        - Same edge cases → same edge behavior
        - Data model round-trip tests (source format ↔ target format)
     b. **Implement the feature** to make tests pass
     c. **Run full test suite** — all tests must pass, not just the new ones
     d. Update `PARITY_REPORT.md` with feature status
4. **Update parity matrix**: Mark feature as `ported`, update `ported_features` count
5. **Commit**: `shift: port F-[NNN] [feature_name] — [N] tests passing`
6. **Calculate parity percentage**: `ported_features / total_features * 100`

**Repeat** for next unported feature. Stay in Phase 4 until all critical + high priority features are ported.

**Advancement criteria**:
- All critical features ported and tested
- All high-priority features ported and tested
- Coverage ≥ 80%
- Full test suite green

When criteria met → **Phase 4b** (web targets) or **Phase 5** (non-web targets).

### Decision Rules for Phase 4

| Situation | Rule |
|-----------|------|
| Source uses platform-specific API (e.g., Android sensors) | Map to closest web/target equivalent; document gap in parity matrix |
| No direct equivalent exists | Create adapter/shim that preserves the interface; mark as `ported-with-gap` |
| Source feature is broken/buggy | Port the intended behavior, not the bug; note in parity matrix |
| Feature stuck 3 sessions | Mark `deferred`, move to next, retry after others complete |
| Source has no tests for a feature | Write tests based on source code behavior analysis, not guessing |

---

## Phase 4b — Cross-Worldline Verification (Web Targets Only)

**Goal**: Browser-level parity verification using Playwright MCP.

1. Start target dev server.
2. For each critical user flow from the feature inventory:
   - Navigate the flow in the target app via Playwright
   - Verify: correct screens render, interactions work, data persists
   - Compare against source behavior (from feature inventory descriptions)
3. Document any visual or behavioral discrepancies.
4. If failures found → back to **Phase 4** to fix the specific features.
5. If all flows pass → **Phase 5**.

Skip this phase if `bypass_playwright: true` (but log warning).

---

## Phase 5 — Divergence Audit

**Goal**: Code review with parity focus.

1. **Spawn Future Okabe ×3** (parallel reviewers):
   - **Reviewer 1 — Parity & Completeness**: Compare target against source feature-by-feature. Flag any behavioral differences, missing edge cases, untranslated business logic.
   - **Reviewer 2 — Correctness & Security**: Same as dmail — logic errors, security issues, error handling.
   - **Reviewer 3 — Test Coverage & Parity Tests**: Are parity tests actually testing the right things? Missing scenarios? Tests that would pass even if behavior diverged?
2. **Consolidate findings** into `review_items` (must-fix / nice-to-have).
3. **Commit**: `shift: divergence audit — [N] must-fix, [M] nice-to-have`
4. → **Phase 6**

---

## Phase 6 — Convergence Fix

**Goal**: Fix all must-fix review items.

1. For each `must_fix` item:
   - Fix the issue
   - Add or update parity test to prevent regression
   - Run full test suite
   - Move item to `closed` in review_items
2. Re-check parity matrix — all features should be `verified` after fixes.
3. If any feature reverted to broken → back to **Phase 4** for that feature.
4. When all must-fix items closed → **Phase 7**.

---

## Phase 7 — Shift Checkpoint

**Goal**: Final verification, documentation, and completion check.

1. **Run full test suite** — must be 100% green.
2. **Production build verification** (if applicable):
   - `pnpm build` / `npm run build` / equivalent must succeed
   - No build warnings for ported code
3. **Update living documents**:
   - `PARITY_REPORT.md` — final parity percentage and per-feature status
   - `SHIFT_LOG.md` — summary of this migration cycle
   - `README.md` — setup and usage instructions for the target project
4. **Final parity check**:
   - If `parity_pct < 100` and medium/low priority features remain unported:
     - If `leap_count < max_iterations * 0.8` → back to **Phase 4** for remaining features
     - If budget tight → checkpoint and note remaining features in `PARITY_REPORT.md`
   - If all features ported and verified → complete
5. **Commit**: `shift: worldline converged — [parity_pct]% parity, [ported]/[total] features`
6. **Completion**: If all features ported OR budget exhausted:
   - Set `phase: el-psy-kongroo`
   - Output `<promise>EL_PSY_KONGROO</promise>`
   - Print final summary:
     ```
     Worldline Shift Complete.
     Source: [source_stack] → Target: [target_stack]
     Features ported: [N]/[M] ([parity_pct]%)
     Test coverage: [coverage_pct]%
     Total leaps: [leap_count]
     ```
   Otherwise → back to **Phase 4** for remaining features.

---

## Autonomous Decision Rules

| Situation | Rule |
|-----------|------|
| Target stack ambiguity | React+Vite+TypeScript+pnpm for web/PWA; Next.js for SSR needs; Node+TS for CLI/API |
| Source uses native APIs | Map to web-compatible equivalent; document gap |
| Source has no tests | Analyze source code behavior, write parity tests from behavior, not from guesses |
| Platform-specific UI | Map to closest target equivalent (e.g., Flutter Material → React MUI/Tailwind) |
| Source data in SQLite/Realm | Map to IndexedDB (PWA), PostgreSQL (API), or equivalent |
| Feature stuck 3 sessions | Mark deferred, move to next, retry later |
| Budget at 80%+ | Focus on critical features only, checkpoint what exists |
| Parity test fails | Fix target implementation, never weaken the test |

---

## End of Session Protocol

**Always** before session ends:

1. Commit all changes (tests must pass; if not, commit with `shift: wip — [reason]`).
2. Update `worldline-shift.md`:
   - `prev_head` ← `git rev-parse HEAD`
   - `leap_count` ← current value
   - `next_action` ← specific instruction for next session
   - `parity_pct` ← current calculation
   - `ported_features` ← current count
3. Write `SHIFT_LOG.md` entry:
   ```
   ## Leap [N] — [date]
   - **Phase**: [phase]
   - **Features ported this session**: [list]
   - **Parity**: [ported]/[total] ([pct]%)
   - **Tests**: [pass]/[total], coverage [pct]%
   - **Blockers**: [any]
   - **Next**: [what to do next]
   ```
4. Commit state: `shift: checkpoint leap [N] — [parity_pct]% parity`

---

## Commit Message Convention

```
shift: [action] — [description]

Actions:
  init, source-recon, attractor-field-mapped
  convergence-architecture, port([feature-name])
  parity-check, divergence-audit, convergence-fix
  worldline-converged, checkpoint, wip
  el-psy-kongroo, cancelled
```
