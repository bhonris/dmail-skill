# D-Mail — Autonomous Project Builder Skill Plan

## What We're Building

A Claude Code skill (`/dmail`) that takes a single natural-language prompt and autonomously builds a complete project — ideating, planning, coding, testing, reviewing, and iterating — for hours without any human intervention.

**Elevator pitch:** You send one D-Mail. You walk away. The lab members work through the night. You return to a project that has reached Steins;Gate.

---

## Steins;Gate Concept Mapping

The skill is themed entirely around Steins;Gate. Every concept maps to one from the series:

| Steins;Gate | D-Mail skill |
|---|---|
| **D-Mail** — message sent to the past to alter the timeline | The `/dmail` prompt — the message that kicks off worldline divergence |
| **Reading Steiner** — Okabe's memory retention across worldline shifts | `reading-steiner.md` persistence across context resets |
| **Worldlines** — branching timelines | Build iterations / alternative implementation approaches |
| **Divergence Meter** — measures deviation from baseline | Test coverage % + passing test count |
| **Lab Members** — Okabe's team | Sub-agents (each named after a character) |
| **El Psy Kongroo** — "it is decided" | Completion promise token: `EL_PSY_KONGROO` |
| **SERN** — the antagonist causing suffering | Bugs, failing tests, blockers |
| **Time Leap** — jumping back to a previous moment | Rolling back to a prior git checkpoint |
| **Attractor Field** — inevitable convergence regardless of worldline | The acceptance criteria; the final working state |
| **Alpha / Beta Worldlines** — the two main branching timelines | The two competing architecture proposals in Phase 2 |
| **Future Gadget Lab** — the workshop | The project directory |
| **Reaching Steins;Gate** — the one true worldline | Phase 6: Done — all acceptance criteria met |
| **Hououin Kyouma** — Okabe's mad scientist alter ego | The skill's persona / narration voice |

---

## Scope

### In scope
- Single-command invocation from a bare prompt
- Autonomous spec & architecture generation
- TDD-driven implementation loop
- Self-directed code review and refinement
- State persistence across context-window resets
- Configurable completion criteria and iteration caps
- Git commits at each stable checkpoint
- Automated E2E verification of web UIs via Playwright MCP (Divergence Meter)
- Three living documents updated throughout every iteration

### Out of scope
- Multi-human-in-the-loop workflows (that's `/feature-dev`)
- Deployment / infra provisioning
- External API integration requiring secrets not already in the environment
- Visual / UI design decisions (can scaffold, not polish)

---

## Why Existing Plugins Don't Cover This

| Plugin | Gap |
|---|---|
| `ralph-loop` | Loops well but has no structured phases, no sub-agents, no state evolution — just raw repetition |
| `feature-dev` | Excellent structure but **requires human sign-off at 4 checkpoints** — not autonomous |

`/dmail` is `ralph-loop`'s persistence mechanism fused with `feature-dev`'s phase intelligence, with all human checkpoints replaced by autonomous decision rules.

---

## Core Architecture

### The Two-Layer Loop

```
Outer loop (ralph-loop stop-hook style) — runs until budget exhausted
│  Stop hook reads reading-steiner.md on every session end
│  Injects updated state as the next session's context
│  Halts only when leap_count >= max_iterations (EL_PSY_KONGROO)
│
│  Phase sequence (repeating):
│  Divergence Analysis → Worldline Selection → Time Leap Development
│  → [Divergence Meter Reading] → Future Okabe's Review
│  → Worldline Convergence → Worldline Checkpoint → Worldline Expansion
│  → back to Worldline Selection (new features) → ...
│
└── Inner loop (Claude's own reasoning within one session)
       TDD: write test → implement → run → fix → repeat
       Exits when feature is committed OR sern_interference_count exceeds threshold
```

### reading-steiner.md — the Heart of the System

Every iteration Claude reads and writes a single **`reading-steiner.md`** file at the project root. This survives context compression and session resets — it *is* the Reading Steiner ability.

```markdown
## reading-steiner.md (example mid-run)

phase: time-leap-development
leap_count: 7              ← total leaps across ALL expansion cycles
expansion_cycle: 1         ← which improvement cycle we're on (starts at 1)
original_prompt: "Build a CLI budgeting tool in TypeScript"
spec_path: documents/steiner-spec.md
decisions:
  - architecture: "single-file CLI with commander.js, SQLite via better-sqlite3"
  - testing: "vitest, 90% coverage target"
  - stack: "TypeScript, Node 20, pnpm"
project_type: cli
test_cmd: "pnpm test"
coverage_pct: 74
dev_server_port: null
divergence_readings: []
current_focus: "Implement `transactions add` command"
blocked_on: null
last_test_run: "18 pass, 6 fail — failing: transaction validation edge cases"
closed_worldlines: [divergence-analysis, worldline-selection]
next_action: "Fix failing validation tests, then implement `transactions list`"
sern_interference_count: 0  ← resets each expansion cycle
max_iterations: 40
completion_promise: "EL_PSY_KONGROO"  ← only fires on budget exhaustion or nothing left to build
```

Claude updates this file before ending each session. The stop hook reads it to decide whether to continue or halt.

---

## Git Commit Strategy

Commits serve two purposes: **checkpointing** (work is never lost across context resets) and **progress signaling** (the stop hook reads git log to verify real forward motion, not just spinning).

### When to commit

| Trigger | Commit message |
|---|---|
| Phase 0 complete | `steiner: init — [project name]` |
| Spec written | `steiner: divergence-analysis` |
| Architecture chosen + scaffold | `steiner: worldline-[alpha\|beta]-selected` |
| Feature's tests go green | `steiner: feat([name]) — divergence meter N%` |
| Before risky refactor | `steiner: time-leap — save before risky refactor` |
| After refactor | `steiner: refactor([scope])` |
| E2E smoke passes | `steiner: divergence-meter-stable` |
| Review findings logged | `steiner: christina-review — N issues found` |
| Each must-fix issue resolved | `steiner: fix([issue slug])` |
| All acceptance criteria met | `steiner: el-psy-kongroo` |

### Commit = proof of work

The stop hook checks `git log --oneline -1` before deciding whether to continue. If the HEAD commit is the same as the previous iteration's HEAD, `sern_interference_count` is incremented. **No commit = SERN interference detected.** This prevents the loop from spinning in place — it will eventually trip the stuck threshold and either skip the blocker or halt cleanly.

### Commit granularity rules

- **One logical change per commit** — don't batch multiple features
- **Tests must pass before committing** a feature (or mark it `time-leap:` if mid-flight)
- **State file, living documents, and code change committed together** — always in sync
- **Never force-push or amend** — the full history is the audit trail

---

## Testing Strategy — The Divergence Meter

D-Mail uses a two-tier verification model. The Divergence Meter must read stable before advancing to Future Okabe's Review.

| Tier | Tooling | When | What it proves |
|---|---|---|---|
| Unit / integration tests | vitest (TS), pytest (Python), jest (JS) | After every feature in Phase 3 | Logic correctness — SERN interference eliminated |
| E2E / visual — Divergence Meter Reading | Playwright MCP | Phase 3b, after all features green | The worldline is stable; the app runs |

### Auto-detection rules

- `package.json` with React/Vite/Next.js → `project_type: web`, enable Playwright (Phase 3b)
- `package.json` without UI framework → unit tests only, no Phase 3b
- `pyproject.toml` → pytest; if FastAPI/Flask detected → `project_type: web`, enable Phase 3b
- CLI projects → unit tests only

### Coverage target

Divergence meter must read **90%+** before advancing from Phase 3 to Phase 4. If below threshold, Phase 3 continues.

---

## MCP Server Strategy — Lab Equipment

D-Mail leverages MCP servers as lab equipment. Most are auto-detected from the project's dependencies.

### Standard lab equipment (auto-use if configured)

| Tool | When | Why |
|---|---|---|
| **Playwright MCP** | Phase 3b, Phase 6 | Divergence Meter — E2E worldline stability verification |
| **Context7** | Phases 3–5, any library call | Fetches live docs — prevents SERN from corrupting the timeline with hallucinated or outdated APIs; single biggest quality win |

### Optional lab upgrades (flag-gated)

| Tool | Trigger | Use |
|---|---|---|
| **GitHub MCP** | `--push-to-github` flag | Phase 6: publish the completed worldline — create repo, push, tag release |
| **PostgreSQL / Supabase / Turso MCP** | Detected in deps + MCP configured | Phase 3: verify schema and run queries against real DB instead of mocks — eliminate SERN from data layer |

### Detection rules (run during Phase 2)

- Any deps in `package.json` / `pyproject.toml` → activate Context7 when writing code against those libs
- React/Vite/Next.js → `project_type: web`, enable Divergence Meter phase
- `pg`, `@supabase/supabase-js`, `@libsql/client` → note in state that DB MCP would improve verification

**Not used by D-Mail:** Slack, Vercel, AWS, Sentry, Docker — post-convergence ops, outside lab scope.

---

## Three Living Documents

D-Mail maintains three markdown files in the **project root** that are kept current throughout every iteration. At any point mid-build, these give a complete picture without needing to read the code.

### `STEINER_LOG.md` — The Divergence Log

Updated after **every commit**. One entry per leap, written as part of the same commit.

```markdown
## Leap 7 — steiner: feat(transactions-add) — divergence meter 74%
*Worldline: 2026-03-22T14:23:00Z*

**Changed**: Implemented `transactions add` command with validation
**SERN interference**: Input parsing edge case on empty description — resolved
**Divergence meter**: 74% (18/24 tests passing)
**Next target**: `transactions list` command
```

### `DOSSIER.md` — The Future Gadget Dossier

Created in Phase 1. Updated at **every phase transition** and whenever a major feature completes.

```markdown
# [Project Name] — Future Gadget Dossier

## What this is
[One paragraph from spec]

## Current status
Phase: Time Leap Development (Leap 7/40)
Divergence meter: 74%

## Lab decisions
- Stack: TypeScript, Node 20, pnpm, vitest
- Architecture: single-file CLI, commander.js, SQLite

## Completed features
- [x] transactions add
- [ ] transactions list
- [ ] monthly report

## Lab Members engaged
Okabe (spec), Daru (implementation), Kurisu × 2 (beta worldline selected), Moeka (exploration)
```

### `USAGE.md` — The Lab Member Operating Manual

Created as a stub in Phase 2. Updated **whenever a feature's tests go green** in Phase 3 — describes only what's actually working. By Phase 6 it's already complete; Done just does a final polish pass.

```markdown
# How to use [Project Name]

## Installation
pnpm install

## Commands

### transactions add
`app transactions add --amount 25.00 --desc "Coffee"`

### transactions list
[written when this feature completes]
```

### Update schedule

| Document | Created | Updated |
|---|---|---|
| `STEINER_LOG.md` | Phase 0 (empty stub) | After every commit in Phase 3+ |
| `DOSSIER.md` | Phase 1 after spec | Each phase transition + major feature completion |
| `USAGE.md` | Phase 2 stub | When each feature goes green in Phase 3 |

All three are **committed alongside the code changes they describe** — never out of sync.

---

## Phases

### Phase 0 — Future Gadget Lab Initialization
*Runs once on first invocation*

1. Parse arguments: `$PROMPT [--max-iterations N] [--stack hint] [--output-dir path] [--push-to-github]`
2. Create project directory, `git init`
3. Initialize `reading-steiner.md` with `phase: divergence-analysis`
4. Create empty stubs: `STEINER_LOG.md`, `DOSSIER.md` (placeholder), `USAGE.md` (placeholder)
5. Commit: `steiner: init — [project name]`

---

### Phase 1 — Divergence Analysis
*Autonomous — no human needed*

**Goal**: Turn the raw prompt into a concrete spec doc at `documents/steiner-spec.md`

**Lab member**: Spawn **Okabe** (Mad Scientist) — writes the spec following CLAUDE.md's feature doc template (user stories, acceptance criteria, edge cases, etc.)

**Actions**:
- Claude reviews Okabe's output and fills obvious gaps by reasoning from the prompt
- Update `DOSSIER.md` with project overview and current status
- Commit: `steiner: divergence-analysis`
- Advance state → `worldline-selection`

**Autonomous decision rule for ambiguity**: If the prompt is ambiguous on a dimension that affects architecture (e.g., web app vs CLI?), pick the simpler/faster option and note the assumption in the spec's Open Questions.

---

### Phase 2 — Worldline Selection
*Autonomous*

**Goal**: Select the architecture and scaffold the project

**Lab members**: Spawn **Kurisu × 2** in parallel — one proposes the Alpha Worldline (minimal, smallest surface area), one proposes the Beta Worldline (clean architecture, maintainability)

**Actions**:
- Claude evaluates both worldlines and selects the one that better fits the spec's constraints
- Write architecture decision to `reading-steiner.md` under `decisions`
- Detect `project_type` from intended stack — write to state
- Scaffold directory structure, config files, `package.json` / `pyproject.toml`, etc.
- Create `USAGE.md` stub with installation section and placeholder commands
- Update `DOSSIER.md` with selected worldline and stack decisions
- Commit: `steiner: worldline-[alpha|beta]-selected`
- Advance state → `time-leap-development`

**Autonomous decision rule**: Default to CLAUDE.md stack preferences (React+TypeScript+Vite for web, Node.js/TypeScript for backend, Python for AI/ML). Only deviate if the prompt explicitly requires otherwise.

---

### Phase 3 — Time Leap Development
*The core loop — runs for many iterations*

**Goal**: Build all features to green tests with 90%+ divergence meter

**Lab members**: Spawn **Moeka** (Explorer) once per major feature to understand what already exists, then spawn **Daru** (Super Hacker) to implement it with TDD

**Structure** (one session = one feature or one bug-fix cycle):
```
1. Read reading-steiner.md → pick current_focus
2. Spawn Moeka to explore existing code relevant to the feature
3. Use Context7 to fetch live docs for any libraries being used
4. Write failing tests for the feature
5. Implement until tests pass
6. Update USAGE.md with the working feature's usage instructions
7. Run full test suite, update coverage_pct in state
8. Update STEINER_LOG.md with leap entry
9. Update DOSSIER.md feature checklist
10. If 90%+ coverage and all features done → advance to Phase 3b (web) or Phase 4
11. If stuck (same failure 3×) → SERN interference detected, increment sern_interference_count
12. Commit: "steiner: feat([name]) — divergence meter N%"
```

**SERN interference handling**: If `sern_interference_count >= 3` on the same problem, Claude documents the blocker in `reading-steiner.md`, marks the feature as "deferred — SERN interference", and moves to the next one. After all other features are complete, retries deferred items.

---

### Phase 3b — Divergence Meter Reading
*Web projects only (`project_type: web`)*

**Goal**: Confirm the worldline is stable — the app runs and core flows work

**Actions**:
1. Start dev server (`pnpm dev` / `npm run dev`) in background
2. Use **Playwright MCP** to:
   - Navigate to `localhost:[dev_server_port]`
   - Take a screenshot — visual proof the worldline is stable
   - Walk the primary happy-path user flows from the spec's user stories
   - Assert key elements are present / interactions work
3. Failures → write to `divergence_readings` in reading-steiner.md, loop back to Phase 3
4. Pass → update STEINER_LOG.md, commit `steiner: divergence-meter-stable`, advance to Phase 4
5. Kill dev server

**SERN rule**: If E2E fails 3× on the same assertion, log it as a `must-fix` for Future Okabe's Review and advance anyway — don't let SERN hold the lab hostage.

---

### Phase 4 — Future Okabe's Review
*Autonomous code review*

**Goal**: Catch bugs, quality issues, and convention violations before declaring the worldline stable

**Lab members**: Spawn **Future Okabe × 3** in parallel, each reviewing a different dimension:
1. Simplicity / DRY / elegance
2. Bugs / functional correctness / security
3. Test coverage gaps / missing edge cases

**Actions**:
- Consolidate findings into a prioritized list in `reading-steiner.md`
- Classify each: `must-fix` (SERN-level threat) vs `nice-to-have`
- Update DOSSIER.md with review status
- Commit: `steiner: christina-review — N issues found`
- Advance state → `worldline-convergence`

**Autonomous decision rule**: Fix all `must-fix` items. Skip `nice-to-have` items if `leap_count >= (max_iterations * 0.8)` — near the temporal budget, prioritize reaching Steins;Gate over polish.

---

### Phase 5 — Worldline Convergence
*Refinement — iterates back through Phase 3 logic if needed*

**Goal**: Eliminate all must-fix issues and confirm acceptance criteria are met

**Actions**:
- Work through `must-fix` issues one by one
- Re-run tests after each fix, update STEINER_LOG.md, commit `steiner: fix([slug])`
- Once all `must-fix` resolved, check if acceptance criteria are met:
  - Yes → advance to Phase 6 (Worldline Checkpoint)
  - No → advance back to `time-leap-development` with remaining criteria as `current_focus`

---

### Phase 6 — Worldline Checkpoint
*Stabilise and document the current worldline, then loop back*

The lab does not stop when acceptance criteria are met — it checkpoints and expands. The only exit is the iteration budget.

1. Run full test suite — capture final coverage report
2. Run **Playwright MCP** against the **production build** (`pnpm build && pnpm preview`) — confirm stability under production conditions, not just dev. Capture a screenshot
3. Polish `USAGE.md` — completeness pass for all features built this cycle
4. Update `DOSSIER.md` — mark `expansion_cycle` complete, log what was achieved
5. Write / update `README.md` linking to USAGE.md and DOSSIER.md
6. Update `documents/steiner-spec.md` Open Questions with assumptions made
7. STEINER_LOG.md checkpoint entry: "Worldline N stabilised — [summary of what was built]"
8. Commit: `steiner: worldline-[N]-stable`
9. If `--push-to-github`: use GitHub MCP to push and tag this expansion
10. Increment `expansion_cycle` in state, advance → `worldline-expansion`

---

### Phase 7 — Worldline Expansion
*Ideate the next improvement cycle — the loop never ends, only the budget does*

**Goal**: Decide what to build next by reasoning over the existing project

**Lab member**: Spawn **Okabe** again — but this time with read access to the full project (codebase, DOSSIER.md, STEINER_LOG.md, USAGE.md, original prompt). Okabe's job is to answer: *"What would meaningfully improve this project?"*

Okabe considers:
- Features implied by the original prompt but not yet built
- Improvements surfaced as `nice-to-have` in Future Okabe's Review (not fixed yet)
- Natural extensions of what's already there (e.g., built `add` and `list` → now suggest `export`, `search`, `categories`)
- Quality improvements: performance, error handling, DX, accessibility
- Test coverage gaps that were deferred

**Actions**:
1. Spawn Okabe to read the project and generate a ranked list of improvements with rationale
2. Claude selects the top 2–4 that offer the best value relative to implementation cost
3. Append selected improvements to `documents/steiner-spec.md` as a new "Expansion N" section with acceptance criteria
4. Update `reading-steiner.md`: clear `closed_worldlines`, reset `current_focus` to first new feature
5. Update DOSSIER.md with the expansion plan
6. Commit: `steiner: expansion-[N]-planned — [brief summary]`
7. Advance state → `worldline-selection`

The loop re-enters Phase 2 (Worldline Selection) — Kurisu proposes alpha/beta approaches for the new features, and the cycle begins again. **The loop runs until `leap_count >= max_iterations`, at which point the stop hook fires `EL_PSY_KONGROO` and halts.**

**Edge case**: If Okabe genuinely cannot identify any meaningful improvements (project is truly complete for its scope), Claude outputs `EL_PSY_KONGROO` voluntarily and the stop hook halts.

---

## Implementation Plan

### File Structure (as a plugin)

```
claude-skills/
└── plugins/
    └── dmail/
        ├── README.md
        ├── commands/
        │   ├── dmail.md            ← main skill entry point
        │   └── cancel-dmail.md     ← interrupt and clean up
        ├── agents/
        │   ├── okabe.md            ← spec writer + expansion ideator (Mad Scientist)
        │   ├── daru.md             ← coder (Super Hacker)
        │   ├── kurisu.md           ← architect (alpha/beta worldline proposals)
        │   ├── moeka.md            ← codebase explorer
        │   └── future-okabe.md     ← code reviewer
        ├── hooks/
        │   ├── hooks.json          ← registers the stop hook
        │   └── stop-hook.sh        ← reads reading-steiner.md, decides continue/halt
        └── scripts/
            ├── init-steiner.sh     ← Phase 0 setup
            └── check-completion.sh ← parses state for EL_PSY_KONGROO signal

Project root (generated):
├── reading-steiner.md    ← the Reading Steiner state
├── STEINER_LOG.md      ← the Divergence Log
├── DOSSIER.md          ← the Future Gadget Dossier
├── USAGE.md            ← the Lab Member Operating Manual
└── README.md           ← written in Phase 6
```

### `hooks/stop-hook.sh` (loop controller)

```bash
#!/usr/bin/env bash
# Reads reading-steiner.md. If done or budget exhausted → allow stop.
# Otherwise → inject updated state as continuation prompt and block stop.

STATE="reading-steiner.md"
if [ ! -f "$STATE" ]; then exit 0; fi  # not a dmail session

PHASE=$(grep '^phase:' "$STATE" | awk '{print $2}')
LEAP=$(grep '^leap_count:' "$STATE" | awk '{print $2}')
MAX=$(grep '^max_iterations:' "$STATE" | awk '{print $2}')
CYCLE=$(grep '^expansion_cycle:' "$STATE" | awk '{print $2}')
PREV_HEAD=$(grep '^prev_head:' "$STATE" | awk '{print $2}')
CURR_HEAD=$(git rev-parse HEAD 2>/dev/null)

# Claude sets phase to el-psy-kongroo only when truly nothing left to build
if [ "$PHASE" = "el-psy-kongroo" ]; then
  echo "El Psy Kongroo. The lab has declared the worldline complete."
  exit 0
fi
if [ "$LEAP" -ge "$MAX" ]; then
  echo "El Psy Kongroo. The lab has exhausted its temporal budget after $LEAP leaps across $CYCLE expansion cycles. The worldline has been preserved in git."
  exit 0
fi

# Detect no progress (same commit as last iteration)
if [ "$CURR_HEAD" = "$PREV_HEAD" ]; then
  echo "WARNING: SERN interference — no new commit detected this leap."
fi

# Inject continuation prompt
cat "$STATE"
echo ""
echo "Continue the D-Mail loop from the current state above. Advance to the next action. El Psy Kongroo."
exit 1  # blocks Claude from stopping
```

---

## Key Design Decisions

### Why `reading-steiner.md` instead of task files?
Task files exist only within a session. `reading-steiner.md` is a tracked git file — it survives context resets, partial failures, and even manual edits if the user wants to redirect the build mid-way. This *is* the Reading Steiner ability.

### Why not just use `ralph-loop` directly?
Ralph loops on a fixed prompt. D-Mail's prompt *evolves* — each iteration the stop hook injects the updated state, so Claude always has fresh context about what's done and what's next. Ralph is stateless; D-Mail is stateful.

### Why TDD?
Tests are machine-verifiable. They replace the human review loop. Claude can run `pnpm test` and get objective signal without a person looking at the output. Tests are the Divergence Meter.

### Why Context7?
Claude's training data has a knowledge cutoff. Library APIs change. Without live docs, Claude hallucinates outdated method signatures, causing tests to fail in loops that waste the temporal budget. Context7 prevents SERN from corrupting the timeline.

### Autonomous decision rules vs. asking the user
Every place `feature-dev` asks the user a question, `/dmail` has a rule:
- **Stack**: Use CLAUDE.md preferences, or infer from prompt
- **Ambiguous requirements**: Pick the simpler interpretation, note assumption in spec
- **Architectural choice** (alpha vs beta worldline): Pick the one that better fits the spec
- **Stuck (SERN interference)**: Skip, document, return later
- **Near temporal budget**: Deprioritize polish, focus on reaching Steins;Gate

---

## Cost & Safety Controls

| Control | Mechanism |
|---|---|
| Iteration cap | `--max-iterations` flag (default: 30) |
| SERN interference detection | `sern_interference_count` in state, auto-skip at 3 |
| No-progress detection | Stop hook compares HEAD to `prev_head` in state — no new commit = interference warning + counter increment |
| Budget exhaustion | Stop hook halts cleanly, worldline preserved in git |
| User escape | `/cancel-dmail` writes `phase: cancelled` to state, hook exits 0 |

---

## Open Questions

1. **Session injection mechanism**: The stop hook can `echo` the continuation prompt, but does Claude Code's stop hook feed that output back as the next user message? Verify the exact hook output contract against ralph-loop's implementation.

2. **Sub-agent context**: When spawning Okabe/Daru/Kurisu/Moeka/Future Okabe via the `Agent` tool, do they have access to project files in the cwd? Likely yes — verify.

3. **Test runner detection**: Auto-detect (`package.json` → `pnpm test`, `pyproject.toml` → `pytest`) or require `--test-cmd` flag? Recommendation: auto-detect with fallback to flag.

4. **Plugin vs. global skill**: Prototype as a local skill file in `~/.claude/commands/dmail.md` before packaging as a full plugin.

5. **Playwright E2E spec file**: Should assertions be written as a committed `e2e/smoke.spec.ts` file, or run ad-hoc via Playwright MCP? Recommendation: committed file — so the worldline's proof of stability is preserved in git for future leaps.

6. **Cost visibility**: Should D-Mail log cumulative token usage to `reading-steiner.md`? Would require Claude to self-report, which is imprecise — consider omitting.

---

## Todo List

- [ ] Prototype `reading-steiner.md` schema and validate it survives a simulated context reset
- [ ] Write `commands/dmail.md` — Phase 0 + phase dispatch logic
- [ ] Write `hooks/stop-hook.sh` — state-aware loop controller
- [ ] Write `scripts/init-steiner.sh` — project dir setup, git init, state + living doc stubs
- [ ] Write agent prompts: `daru.md`, `kurisu.md`, `moeka.md`, `future-okabe.md`
- [ ] Test end-to-end with a simple prompt ("build a CLI todo app in TypeScript")
- [ ] Tune autonomous decision rules based on test run results
- [ ] Write `cancel-dmail.md` escape command
- [ ] Write `README.md` for the plugin
- [ ] Package as installable plugin (manifest, etc.)

---

## Migration & Rollback

- D-Mail only touches the project directory it creates (or the cwd it's pointed at)
- All changes committed to git at each phase — rollback is `git reset`
- `reading-steiner.md` can be manually edited to restart from any phase
- `/cancel-dmail` cleanly halts the loop without destructive side effects

---

## Phased Rollout

**V1 (prototype)** — Local `~/.claude/commands/dmail.md` skill only, no stop hook, manual re-invocation to iterate. Proves the phase logic and state file approach.

**V2 (autonomous)** — Add stop hook for true hands-off looping. Add sub-agents. Test overnight run.

**V3 (plugin)** — Package as a proper plugin with manifest, README, marketplace listing.
