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
type_check_cmd: [null or detected command]
build_cmd: [null or detected command]
parity_test_cmd: [null or derived run command]
has_localization: [true|false]
localization_file_pattern: [null or detected glob/path]
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
5. **Detect stack-specific commands** — probe the source and target stacks to populate the four new state fields. These are referenced throughout later phases; never hardcode commands.

   **`type_check_cmd`** — the static analysis command for the target stack:
   | Target stack indicator | Command |
   |------------------------|---------|
   | `tsconfig.json` present | `tsc --noEmit` |
   | `pubspec.yaml` (Dart/Flutter) | `dart analyze` |
   | `go.mod` (Go) | `go vet ./...` |
   | `Cargo.toml` (Rust) | `cargo check` |
   | `mypy.ini` / `.mypy.ini` / `[tool.mypy]` in `pyproject.toml` | `mypy .` |
   | `pyrightconfig.json` | `pyright` |
   | `build.gradle` / `gradlew` (Kotlin/Android) | `./gradlew compileKotlin --no-daemon` |
   | `pom.xml` (Java/Maven) | `./mvnw compile -q` |
   | None of the above | `null` (gate is skipped) |

   **`build_cmd`** — the production build command for the target stack:
   | Target stack indicator | Command |
   |------------------------|---------|
   | `vite.config.*` or `package.json` with `"build"` script | `pnpm build` (or `npm run build` / `yarn build` based on lock file) |
   | `pubspec.yaml` (Flutter web target) | `flutter build web` |
   | `go.mod` | `go build ./...` |
   | `Cargo.toml` | `cargo build` |
   | `build.gradle` | `./gradlew assembleRelease --no-daemon` |
   | `pom.xml` | `./mvnw package -q -DskipTests` |
   | Python (library/CLI) | `python -m build` if `pyproject.toml` has `[build-system]`, else `null` |
   | None of the above | `null` (gate is skipped) |

   **`parity_test_cmd`** — command to run ONLY files matching `*.parity.test.*`:
   | Test runner (inferred from `test_cmd`) | Parity filter command |
   |----------------------------------------|----------------------|
   | jest | `{test_cmd} --testPathPattern=\\.parity\\.test\\.` |
   | vitest | `{test_cmd} --reporter=verbose parity.test` |
   | pytest | `pytest -k parity` |
   | go test | `go test -run Parity ./...` |
   | flutter test | `flutter test --name parity` |
   | gradle test | `./gradlew test --tests "*ParityTest" --no-daemon` |
   | None matched | Same as `test_cmd` with `null` filter note |

   **`has_localization` + `localization_file_pattern`** — scan the SOURCE project root for localization artifacts:
   - `*.arb` files anywhere → `has_localization: true`, pattern `**/*.arb`
   - `res/values*/strings.xml` → `has_localization: true`, pattern `**/strings.xml`
   - `*.lproj/Localizable.strings` → `has_localization: true`, pattern `**/*.strings`
   - `*.po` or `*.pot` files → `has_localization: true`, pattern `**/*.po`
   - A directory named `locales/`, `i18n/`, or `translations/` containing `*.json` files → `has_localization: true`, pattern `locales/**/*.json` (or equivalent)
   - None found → `has_localization: false`, `localization_file_pattern: null`

   Record all four fields in `worldline-shift.md` before touching the target directory.

6. **Create target directory**, `git init`, create initial files:
   - `worldline-shift.md` (state file, including all detected commands)
   - `documents/` directory
   - `SHIFT_LOG.md` (migration log — one entry per leap)
   - `PARITY_REPORT.md` (running parity status)
7. **Initial commit**: `shift: init — worldline shift from [source_stack] to [target_stack]`
8. → **Phase 1**

---

## Phase 1 — Source Reconnaissance

**Goal**: Exhaustive analysis of the source project. The source is the spec.

1. **Spawn Moeka** (codebase explorer) pointed at `source_path`:
   - Every file, directory, module, package
   - All dependencies and their purposes
   - Test structure and existing test patterns
   - Configuration files and environment variables
   - Build system and scripts
1b. **Run Project Cartography** — before spawning Suzuha, execute these shell commands against `source_path` to produce a verified file map. Adapt patterns to the detected source stack:

   ```bash
   # Full file listing (adapt root dir to source stack: lib/ for Flutter, src/ for TS, app/src/ for Android)
   find lib -type f -name "*.dart" | sort                                    # Flutter/Dart
   find src -type f \( -name "*.ts" -o -name "*.tsx" \) | sort              # React/TS
   find app/src -type f -name "*.kt" | sort                                  # Android/Kotlin

   # Routes / navigation
   grep -rn "routes\|GoRoute\|pushNamed\|Navigator\|\.go(" lib/ --include="*.dart" | head -80
   grep -rn "Route\|useNavigate\|<Link\|createRouter\|router" src/ --include="*.tsx" | head -80

   # Models / schemas (data layer — exclude test files)
   grep -rn "^class \|^abstract class \|^enum \|^typedef " lib/ --include="*.dart" | grep -v "_test\|test/" | sort
   grep -rn "^interface \|^type \|^enum \|^class " src/ --include="*.ts" | grep -v "\.test\.\|\.spec\." | sort

   # API calls / service layer
   grep -rn "http\.\|dio\.\|fetch(\|ApiClient\|Repository\|\.get(\|\.post(" lib/ --include="*.dart" | head -60
   grep -rn "fetch(\|axios\.\|useQuery\|useMutation\|api\." src/ --include="*.ts" --include="*.tsx" | head -60

   # Tests
   find . -type f \( -name "*.test.*" -o -name "*_test.*" -o -name "*.spec.*" \) | sort
   ```

   Write the output to `documents/source-map.md` with sections: **File Count by Directory**, **Routes Found**, **Model/Class Names Found**, **API Call Sites Found**, **Test Files Found**. This document is the ground truth — Suzuha must account for every file in it.

2. **Spawn Suzuha** (source analyzer) with Moeka's report AND `documents/source-map.md`:
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
   - **File reconciliation**: At the end of the inventory, Suzuha must append a `## File Reconciliation` table mapping every file from `source-map.md` to the feature(s) it belongs to (or marking it as a shared utility with no dedicated feature). Any unaccounted file is a gap — add a feature or explicitly exclude it.
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
   - **Ruka must run the Self-Validation Protocol** from her spec before reporting completion. The data contracts document is not finished until the `## Coverage Report` section is appended and shows no missing models.
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

For each unported feature, select the next using this dependency-aware protocol:

1. **Consult the dependency graph** in `documents/parity-matrix.md` (Feature Dependencies section).
2. **Hard dependencies must be ported first**: Never select a feature whose hard dependencies are not yet at `integrated` status. If the highest-priority unported feature has an unmet hard dependency, port the dependency first regardless of its own priority ranking.
3. **Among eligible features** (all hard dependencies met): select by priority (critical → high → medium → low).
4. **Document the selection**: When spawning Daru, include in the handoff which features this feature hard-depends on and confirm they are already `integrated`.

Then:

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

3. **Static Analysis Gate** (run if `type_check_cmd` is not `null`):
   - Run `type_check_cmd` from state against the target project.
   - Any errors → **MUST-FIX** immediately. Do not advance until the command exits clean.
   - If `type_check_cmd` is `null` (stack has no applicable static analyzer), skip and note in SHIFT_LOG.
   - This catches type mismatches, missing fields, and broken imports that tests may not exercise.

4. **Build Gate** (run if `build_cmd` is not `null`):
   - Run `build_cmd` from state against the target project.
   - Any build errors or warnings on ported files → **MUST-FIX** before advancing.
   - If `build_cmd` is `null`, skip and note in SHIFT_LOG.
   - Running the build every 3 leaps catches broken exports and missing assets far earlier than Phase 7.

5. **Route Coverage Diff** (run if `target_type` is `web | pwa | mobile`):
   - Open `documents/source-map.md` and extract the complete route list from the **Routes Found** section.
   - Run the equivalent route-extraction grep on the TARGET project (use the same patterns that were used for the source in Phase 1's Project Cartography, adapted to the target stack's routing idioms).
   - Diff the two lists:
     - Any source route not present in the target → **MUST-FIX**, add to must-fix list with the missing route
     - Any target route with no source equivalent → note as **new/untracked route** in SHIFT_LOG (not a must-fix, but flag it)
   - Skip if `target_type` is `cli | api | library`.

6. **Orphan Component Quick Scan:**
   - Adapt file extensions to the target stack (`.tsx`/`.jsx` for React, `.vue` for Vue, `.svelte` for Svelte, `.dart` for Flutter, `.kt` for Android, etc.). Exclude test files.
   - For every component file in the target source tree:
     - Check if any other non-test file imports it
     - If not imported anywhere → **MUST-FIX** — wire it into the correct parent or remove it
     - Exception: root app entry point, page-level components imported by router config

7. **Update parity matrix:**
   - Features that pass all wiring checks (steps 1–6) → status `integrated`
   - Features that fail any check → status remains `coded`, add to must-fix list

8. **Commit**: `shift: integration wiring — [N] features integrated, [M] wiring fixes applied`
9. **Route**:
   - `target_type` is `web | pwa` → **always go to Phase 4b** (browser verification of currently integrated features). After Phase 4b completes, return to Phase 4 if unported features remain, else Phase 5.
   - `target_type` is `cli | api | library | mobile` → back to **Phase 4** if unported features remain, else **Phase 5**.

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
6. If failures found → back to **Phase 4** to fix the specific features, then re-run **Phase 4c** → **Phase 4b** again.
7. If all integrated pages pass → mark passing features as `verified` in parity matrix.
8. **Route**: if unported features remain in the parity matrix → back to **Phase 4**. If all features are `verified` → **Phase 5**.

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
2. **Localization Key Coverage** (run only if `has_localization: true`):
   - List all localization files in the source using `localization_file_pattern`.
   - Extract every string key from those source files (format is stack-dependent: keys in ARB files, `<string name="...">` in Android XML, keys in `.po` msgid fields, keys in JSON translation objects, etc.).
   - Run the equivalent extraction on the TARGET project's localization files.
   - Diff the two key sets:
     - Keys present in source but missing from target → **MUST-FIX** (parity gap — missing strings will crash or show raw key names)
     - Keys in target but absent from source → note as new/added strings in SHIFT_LOG (acceptable)
   - A single missing key is a parity gap. If the diff is clean, note "Localization: all [N] keys present" in SHIFT_LOG.
   - If `has_localization: false`, skip this step entirely.
3. Update parity matrix: only features Suzuha marks `verified` count toward `verified_features`
4. Update state: `parity_pct` = `verified_features / total_features * 100`
5. If any features have `parity-gap` or `regression`, OR if localization key diff has must-fix items → back to **Phase 4** / **Phase 6** respectively
6. When all ported features are `verified` AND localization keys are complete (or `has_localization: false`) → **Phase 7**

---

## Phase 7 — Shift Checkpoint

**Goal**: Final verification, documentation, and completion check.

1. **Run full test suite** — must be 100% green.
2. **Production build verification** (if `build_cmd` is not `null`):
   - Run `build_cmd` from state — must exit clean with no errors
   - No build warnings on ported code
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
   - If `test_parity_pct < 90%` → do NOT declare convergence. Back to **Phase 4** to write missing parity tests.
5. **Update living documents**:
   - `PARITY_REPORT.md` — final parity percentage, per-feature status, test counts (source vs target)
   - `SHIFT_LOG.md` — summary of this migration cycle
   - `README.md` — setup and usage instructions for the target project
6. **Final parity check**:
   - If unported features remain AND `leap_count < max_iterations * 0.8` → back to **Phase 4**
   - If unported features remain AND budget tight → checkpoint and note remaining features in `PARITY_REPORT.md`
   - If any features are `coded` but not `integrated` → back to **Phase 4c** (Integration Wiring)
   - If all features `verified` (not just `coded` or `integrated`) AND test parity ≥ 90% AND zero TODO stubs AND zero orphan components AND zero placeholder handlers → proceed to step 7 (Final Playwright Run)
7. **Final Playwright Run** (web/PWA targets only — MANDATORY before completion):
   - This is the last gate before the shift is declared complete. It cannot be skipped.
   - If `bypass_playwright: true` → skip this step, note in PARITY_REPORT: `"Final Playwright run SKIPPED — bypass_playwright is true. Manual verification required."`
   - If `bypass_playwright: false`:
     - Verify Playwright MCP tools are present. If not → HARD STOP: commit state as `phase: final-playwright-blocked`, tell user to start Playwright MCP and re-invoke.
     - Start the target dev server.
     - Run a **complete end-to-end sweep** of the entire app — every page, every interactive element, every navigation path:
       - Navigate to every route in `documents/source-map.md`
       - Click every button, link, tab, and form control
       - Verify every action produces the correct result (no console.log handlers, no 404s, no blank pages, no placeholder text)
       - Take a screenshot of each page and record it in SHIFT_LOG
     - Any failure → **MUST-FIX**: back to **Phase 4** to fix, then re-run Phase 4c → Phase 4b → return here
     - All pages pass → proceed to step 8
   - Non-web targets (`cli | api | library | mobile`) → skip this step, proceed directly to step 8.
8. **Commit**: `shift: worldline converged — [parity_pct]% parity, [verified]/[total] features, [target_test_count]/[source_test_count] tests`
9. **Completion**: If all convergence gates pass:
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
   - `integrated_features` ← current count (features fully wired into their parent)
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
