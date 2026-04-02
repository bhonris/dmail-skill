---
description: "Comprehensive code project porting — migrates a codebase from one tech stack to another with 1:1 feature parity"
argument-hint: '"source/path" [--target "target/path"] [--from "flutter"] [--to "react-pwa"] [--max-iterations N] [--push-to-github] [--bypass-playwright]'
---

# Worldline Shift — Autonomous Project Porting

You are orchestrating a **Worldline Shift**: porting an entire project from one technology stack to another while maintaining exact functional parity. The source project is the living spec — every feature, screen, endpoint, and data model must converge in the target worldline.

---

## Session Startup

1. Look for `worldline-shift.md` in the **target project directory**.
   - **Missing** → This is a fresh shift. Begin at **Phase 0**.
   - **Present** → Read it. Resume from the saved `phase` and `next_action`.
2. If resuming, increment `leap_count` by 1 and update `session_id`.

**PLAYWRIGHT GATE — run this before anything else, including Phase 0:**

Check whether Playwright MCP tools are present in your tool list (look for tools named `playwright_navigate`, `playwright_screenshot`, `playwright_click`, or similar `playwright_*` names).

- **If Playwright MCP tools are NOT present AND `BYPASS_PLAYWRIGHT` is false:**
  Output exactly:

  ```
  Worldline Shift cannot start. Playwright MCP is not running.

  Playwright is required for browser-level parity verification of web targets and is
  non-negotiable. Add and start it before invoking /worldline-shift:

    claude mcp add playwright npx @playwright/mcp@latest

  Then restart Claude Code and re-run /worldline-shift.

  To skip this check (CLI/API/library projects only), re-run with --bypass-playwright.
  ```

  Then stop. Do not proceed to Phase 0 or any other phase.

- **If Playwright MCP tools are NOT present AND `BYPASS_PLAYWRIGHT` is true:**
  Output a warning: `⚠ Playwright MCP not detected — proceeding anyway (--bypass-playwright set). Phase 4b will be skipped.`
  Write `bypass_playwright: true` to `worldline-shift.md` and continue.

- **If Playwright MCP tools ARE present:** Continue normally. Write `bypass_playwright: false` to state.

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
coded_features: [N]
integrated_features: [N]
verified_features: [N]
source_test_count: [N]
target_test_count: [N]
test_parity_pct: [0-100]
features_this_leap: [N]
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
   - `--bypass-playwright` — explicit opt-out of Playwright gate (CLI/API/library projects only)
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
   - **Granularity rule**: Every distinct user action (submit form, open dialog, capture signature, download PDF) is a separate feature. If a source "feature" has more than 3 source files, decompose it into sub-features. Target ratio: ~1 feature per 2-3 source files. A 74-file project should produce 25-40 features, not 10.
3. **Count source tests**: Run the source test suite or count test files/cases. Record as `source_test_count` in state.
4. **Update state**: `phase: source-recon`, update `total_features`, `source_test_count`
5. **Commit**: `shift: source reconnaissance — [N] features inventoried, [M] source tests counted`
6. → **Phase 2**

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
   - Parity statuses: `not-started` → `in-progress` → `coded` → `integrated` → `verified`
     - `coded` — component file exists, unit tests pass
     - `integrated` — component is imported and rendered in its parent page, event handlers are functional, navigation works
     - `verified` — parity tests + Playwright confirm identical behavior to source
   - A feature only counts toward parity % when it reaches `integrated` status, not `coded`
   - Include totals row with parity percentage
2. **Spawn Ruka** (data contract mapper) with source analysis:
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

1. **Spawn Kurisu (Port)** (`plugins/port/agents/kurisu-port.md`) twice — propose two architectures for the target:
   - **Alpha Worldline** (Direct Map): Mirror source structure as closely as possible in target stack. Fastest to port, easiest to verify parity.
   - **Beta Worldline** (Idiomatic): Use target stack's idiomatic patterns and conventions. Cleaner long-term, but more translation work.
   - Both must include:
     - Directory structure (tree)
     - Source → target module mapping table
     - Platform API mapping table (every source dependency → target equivalent)
     - Key dependencies with versions
     - Testing strategy (framework, patterns, how to verify parity)
     - i18n strategy (if source uses localization)
     - Migration order based on dependency graph
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

## Phase 4 — Worldline Migration (Page Composition Porting)

**Goal**: Port features as **page compositions** — not isolated components — with TDD and strict parity.

**CRITICAL RULE — Port by Page Composition, Not by Component:**
When porting a page-level feature, ALL child components shown in the source page MUST be included in the same leap, even if it means fewer features per leap. A page without its children is not "ported." The porting unit is the **full page as the user sees it**, not individual component files.

Example — correct approach:

```
F-008: Homepage = HomePage + WeeklyCalendar + AnnouncementSection + StatusCard + NotificationPopup
→ All rendered together, all event handlers connected, tested as composition
```

Example — WRONG approach (leads to orphan components):

```
F-008: Homepage (stub)       ← Leap 4
F-009: WeeklyCalendar        ← Leap 16, never wired back into HomePage
F-012: AnnouncementSection   ← Leap 5, never wired back into HomePage
```

For each unported feature from the parity matrix (in priority order):

1. **Spawn Moeka** to read the target project's current state.
2. **Spawn Moeka** to re-read the source feature's implementation — **including the parent page/container that renders this feature**:
   - Read the component file(s) to understand behavior
   - Read the parent page to understand WHERE and HOW the component is rendered, what props it receives, what events it emits
   - Read any sibling components that interact with this feature
   - This parent context is **mandatory** — never port a component without knowing its integration point
3. **Spawn Daru (Port)** (`plugins/port/agents/daru-port.md`) with:
   - The feature spec from the inventory
   - The data contract mapping for relevant models
   - The source implementation AND its parent page context (both are the spec)
   - The source test files for this feature (Daru must match test count)
   - Moeka's target codebase report
   - Daru will:
     a. Read source implementation AND parent page to understand exact behavior and integration
     b. Count source tests and write comparable parity tests FIRST
     c. Write **page composition tests** that verify child components render inside their parent
     d. Implement the feature to make all parity tests pass
     e. Wire the component into its parent page — import it, render it, connect real event handlers
     f. Run full test suite — all tests must pass, not just the new ones
     g. Update `PARITY_REPORT.md` with feature status and test counts
4. **Update parity matrix**: Mark feature as `coded` initially. Only mark as `integrated` after verifying:
   - Component is imported in its parent file
   - Component is rendered in the parent's JSX/template
   - All event handlers are functional (no `console.log` placeholders)
   - Navigation targets actually exist and are routable
5. **Commit**: `shift: port F-[NNN] [feature_name] — [N] tests passing, integrated in [parent]`
6. **Calculate parity percentage**: `integrated_features / total_features * 100` (only `integrated` or higher counts)

**Repeat** for next unported feature, but respect the **leap limit**:

**Leap limit**: Port at most **3 features per leap**. After 3 features, advance to **Phase 4c** (Integration Wiring) then checkpoint (Phase 7) even if more features remain. Update `features_this_leap` in state. Reset to 0 at the start of each leap. This ensures each feature gets adequate depth and prevents shallow batch porting.

**Advancement criteria** (to leave Phase 4):

- All critical features ported and tested
- All high-priority features ported and tested
- `target_test_count / source_test_count ≥ 0.5` (test parity ratio)
- Full test suite green

When criteria met → **Phase 4c** (Integration Wiring) → **Phase 4b** (web targets) or **Phase 5** (non-web targets).

### Decision Rules for Phase 4

| Situation                                                 | Rule                                                                        |
| --------------------------------------------------------- | --------------------------------------------------------------------------- |
| Source uses platform-specific API (e.g., Android sensors) | Map to closest web/target equivalent; document gap in parity matrix         |
| No direct equivalent exists                               | Create adapter/shim that preserves the interface; mark as `ported-with-gap` |
| Source feature is broken/buggy                            | Port the intended behavior, not the bug; note in parity matrix              |
| Feature stuck 3 sessions                                  | Mark `deferred`, move to next, retry after others complete                  |
| Source has no tests for a feature                         | Write tests based on source code behavior analysis, not guessing            |

---

## Phase 4c — Integration Wiring (Mandatory After Every 3 Leaps)

**Goal**: Verify that every component ported in the last 3 leaps is actually wired into its parent page. This phase catches the "Component Island" problem — components that exist and pass tests in isolation but are never rendered in the running app.

**This phase is BLOCKING — cannot advance to Phase 4b or next leap until all wiring is verified.**

1. **For EVERY component ported in the last 3 leaps:**
   a. **Read the source** to find which parent page/container renders this component
   b. **In the target, verify the component is:**
   - Imported in the parent file (not just existing as a standalone file)
   - Rendered in the parent's JSX/template (not commented out, not behind a never-true condition)
   - Connected with real event handlers (not `console.log`, not `() => {}`, not `// TODO`)
   - Navigation targets actually exist and are routable (clicking a button goes somewhere real)
     c. **If any of (a-d) fail** → fix immediately before proceeding

2. **Page Composition Test Verification:**
   For every page-level component, verify a composition test exists that checks ALL children render inside the parent:

   ```tsx
   // REQUIRED: composition test for every page component
   describe("HomePage — Page Composition", () => {
     it("renders WeeklyCalendar", () => {
       render(<HomePage />);
       expect(screen.getByTestId("weekly-calendar")).toBeInTheDocument();
     });
     it("renders AnnouncementSection", () => {
       render(<HomePage />);
       expect(screen.getByTestId("announcement-section")).toBeInTheDocument();
     });
     it("notification bell opens NotificationPopup on click", async () => {
       render(<HomePage />);
       await user.click(screen.getByTestId("notification-bell"));
       expect(screen.getByTestId("notification-popup")).toBeInTheDocument();
     });
     it("all navigation handlers are functional (no console.log placeholders)", () => {
       // Verify onClick handlers produce real effects
     });
   });
   ```

   If composition tests are missing → write them now and ensure they pass.

3. **Orphan Component Quick Scan:**
   - For every `.tsx`/`.vue`/`.svelte` component file in `src/` (excluding test files):
     - Check if any other non-test file imports it
     - If not imported anywhere → **MUST-FIX** — wire it into the correct parent or remove it
     - Exception: `App.tsx` root, page-level components imported by router

4. **Update parity matrix:**
   - Features that pass all wiring checks → status `integrated`
   - Features that fail any check → status remains `coded`, add to must-fix list

5. **Commit**: `shift: integration wiring — [N] features integrated, [M] wiring fixes applied`
6. → **Phase 4b** (web targets) or back to **Phase 4** (if more features to port)

---

## Phase 4b — Cross-Worldline Verification (Web Targets Only)

**Goal**: Browser-level parity verification using Playwright MCP.

**IMPORTANT**: This phase is NON-NEGOTIABLE for web/PWA targets. Do NOT silently skip it.

1. **Re-check Playwright availability**: Check `bypass_playwright` in `worldline-shift.md`.
   - If `bypass_playwright: true` → skip this entire phase, advance directly to Phase 5. Log warning in SHIFT_LOG: `"Phase 4b SKIPPED — bypass_playwright is true. Parity cannot be fully verified. No features will be marked 'verified' — only 'ported'."`
   - If `bypass_playwright: false` → verify Playwright MCP tools are present in your tool list (look for `playwright_navigate`, `playwright_screenshot`, `playwright_click`, or similar `playwright_*` names). If they are NOT present, output:
     ```
     SERN interference: Playwright MCP is not running. Phase 4b cannot proceed.
     Commit current state, write phase: phase-4b-blocked to worldline-shift.md, and stop.
     The user must add and start Playwright MCP (claude mcp add playwright npx @playwright/mcp@latest), restart Claude Code, and re-invoke /worldline-shift to continue.
     ```
     Then commit state and stop. Do NOT advance to Phase 5. Do NOT skip Phase 4b. Do NOT mark features as verified.
2. Start target dev server.
3. **For EACH page in the app** (not just critical flows — every page):
   a. Navigate to the page
   b. Take accessibility snapshot
   c. Verify EVERY child component from the source page is present in the snapshot — cross-reference the feature inventory's source file list
   d. Click EVERY interactive element (buttons, links, tabs, form controls)
   e. Verify each click produces the expected result:
   - Navigation buttons → navigate to correct route (not 404, not blank)
   - Dialog triggers → dialog opens with correct content
   - Form submissions → submit handler fires (not console.log)
   - Tab switches → correct tab content appears
   - Toggle/checkbox → state changes visually
     f. Compare against source feature inventory — every user action listed must work

4. **Failure criteria** (any of these = FAIL, back to Phase 4):
   - Button/link exists but does nothing on click
   - Component listed in source page but missing from target snapshot
   - Navigation target returns 404 or renders blank page
   - Tab content is placeholder text instead of real component
   - Interactive element triggers `console.log` instead of real action

5. Document all discrepancies with page, element, expected behavior, actual behavior.
6. If failures found → back to **Phase 4** to fix the specific features, then re-run **Phase 4c** for wiring.
7. If all pages pass → mark passing features as `verified` in parity matrix → **Phase 5**.

---

## Phase 5 — Divergence Audit

**Goal**: Code review with parity focus.

1. **Spawn Future Okabe (Port) ×3** (`plugins/port/agents/future-okabe-port.md`) as parallel reviewers:
   - **Reviewer 1 — Parity & Completeness** (Mode 1): Read source AND target side-by-side for every ported feature. Flag behavioral divergences, missing sub-features, TODO stubs, hardcoded strings in localized apps.
   - **Reviewer 2 — Correctness & Security** (Mode 2): Logic errors, security issues, error handling gaps.
   - **Reviewer 3 — Test Parity & Coverage** (Mode 3): Compare source test count vs target test count per feature. Flag parity tests that could pass even with wrong behavior. Flag render-only tests as insufficient.
2. **Consolidate findings** into `review_items` (must-fix / nice-to-have).
3. **Commit**: `shift: divergence audit — [N] must-fix, [M] nice-to-have`
4. → **Phase 6**

---

## Phase 6 — Convergence Fix

**Goal**: Fix all must-fix review items, then verify parity.

1. For each `must_fix` item:
   - Fix the issue
   - Add or update parity test to prevent regression
   - Run full test suite
   - Move item to `closed` in review_items
2. When all must-fix items closed → **Phase 6b**.

---

## Phase 6b — Parity Verification (Mandatory)

**Goal**: Suzuha verifies every "ported" feature actually matches source behavior.

1. **Spawn Suzuha** (Mode 3: Parity Verification) with access to both source and target codebases:
   - For each feature marked `ported`: read source, read target, read parity tests
   - Verdict per feature: `verified` | `parity-gap` | `regression`
   - Features with parity gaps or regressions go back to must-fix list
2. Update parity matrix: only features Suzuha marks `verified` count toward `verified_features`
3. Update state: `parity_pct` = `verified_features / total_features * 100`
4. If any features have `parity-gap` or `regression` → back to **Phase 4** for those specific features
5. When all ported features are `verified` → **Phase 7**

---

## Phase 7 — Shift Checkpoint

**Goal**: Final verification, documentation, and completion check.

1. **Run full test suite** — must be 100% green.
2. **Production build verification** (if applicable):
   - `pnpm build` / `npm run build` / equivalent must succeed
   - No build warnings for ported code
3. **Stub scan** — run `grep -rn "TODO\|FIXME\|HACK\|PLACEHOLDER" src/` (or equivalent for target stack). If any results in non-test files:
   - Each is a **must-fix** item. Do NOT proceed to completion.
   - Back to **Phase 6** to fix stubs, then re-run Phase 6b verification.

3b. **Orphan Component Scan** — detect components never imported by any other file:

- For every component file in `src/` (e.g., `.tsx`, `.vue`, `.svelte` — excluding test files, story files, and index re-exports):
  - Search all other non-test source files for an import of this component
  - If not imported anywhere → **MUST-FIX** item
  - Exceptions: `App.tsx`/root component, page-level components imported by router config
- If orphan components found → back to **Phase 4c** to wire them into their parent pages, then re-verify.

3c. **Placeholder Handler Scan** — detect non-functional event handlers:

- Scan for patterns that indicate placeholder/stub handlers in non-test source files:
  - `console.log` in onClick/onSubmit/onChange handlers
  - `() => {}` or `() => { }` as event handler values
  - `// TODO`, `// PLACEHOLDER`, `// FIXME` inside handler functions
  - `alert(` as a substitute for real functionality
  - Navigation handlers that don't actually call router navigation
- Each placeholder handler found → **MUST-FIX** item
- Back to **Phase 6** to implement real handlers, then re-run Phase 6b verification.

4. **Test parity check**:
   - Update `target_test_count` by counting all test cases in target.
   - Calculate `test_parity_pct = target_test_count / source_test_count * 100`.
   - If `test_parity_pct < 50%` → do NOT declare convergence. Back to **Phase 4** to write missing parity tests.
5. **Update living documents**:
   - `PARITY_REPORT.md` — final parity percentage, per-feature status, test counts (source vs target)
   - `SHIFT_LOG.md` — summary of this migration cycle
   - `README.md` — setup and usage instructions for the target project
6. **Final parity check**:
   - If unported features remain AND `leap_count < max_iterations * 0.8` → back to **Phase 4**
   - If unported features remain AND budget tight → checkpoint and note remaining features in `PARITY_REPORT.md`
   - If any features are `coded` but not `integrated` → back to **Phase 4c** (Integration Wiring)
   - If all features `verified` (not just `coded` or `integrated`) AND test parity ≥ 50% AND zero TODO stubs AND zero orphan components AND zero placeholder handlers → complete
7. **Commit**: `shift: worldline converged — [parity_pct]% parity, [verified]/[total] features, [target_test_count]/[source_test_count] tests`
8. **Completion**: If all convergence gates pass:
   - Set `phase: el-psy-kongroo`
   - Output `<promise>EL_PSY_KONGROO</promise>`
   - Print final summary:
     ```
     Worldline Shift Complete.
     Source: [source_stack] → Target: [target_stack]
     Features verified: [N]/[M] ([parity_pct]%)
     Test parity: [target_test_count]/[source_test_count] ([test_parity_pct]%)
     Total leaps: [leap_count]
     ```
     Otherwise → back to **Phase 4** for remaining features.

---

## Autonomous Decision Rules

| Situation                                | Rule                                                                                                              |
| ---------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Target stack ambiguity                   | React+Vite+TypeScript+pnpm for web/PWA; Next.js for SSR needs; Node+TS for CLI/API                                |
| Source uses native APIs                  | Map to web-compatible equivalent; document gap                                                                    |
| Source has no tests                      | Analyze source code behavior, write parity tests from behavior, not from guesses                                  |
| Platform-specific UI                     | Map to closest target equivalent (e.g., Flutter Material → React MUI/Tailwind)                                    |
| Source data in SQLite/Realm              | Map to IndexedDB (PWA), PostgreSQL (API), or equivalent                                                           |
| Feature stuck 3 sessions                 | Mark deferred, move to next, retry later                                                                          |
| Budget at 80%+                           | Focus on critical features only, checkpoint what exists                                                           |
| Parity test fails                        | Fix target implementation, never weaken the test                                                                  |
| **Playwright smoke test on web targets** | **ALWAYS RUN. Never skip. Not running it is not an option. Parity is not verified until Playwright confirms it.** |
| Playwright MCP not detected at startup   | **HARD STOP** — print error and terminate unless `--bypass-playwright` was passed                                 |
| Playwright MCP not detected at Phase 4b  | **HARD STOP** — commit state as `phase-4b-blocked`, stop, tell user to start MCP and re-invoke                    |
| `--bypass-playwright` flag               | Only valid for CLI/API/library projects. Skips the startup gate and Phase 4b entirely.                            |

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
