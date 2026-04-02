# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

This is a **Claude Code skills/plugins repository** — a collection of custom slash commands, agents, and hooks that extend Claude Code's capabilities. The flagship skill is **D-Mail**, an autonomous project builder that runs indefinitely from a single prompt. The second skill is **Port** (Worldline Shift), an autonomous project porting tool that migrates codebases across tech stacks with 1:1 feature parity.

## Repository Structure

```
claude_skills/
├── documents/                        # Design specs and feature docs
│   └── autonomous-builder-skill.md   # Full design spec for D-Mail
└── plugins/
    ├── dmail/
    │   ├── README.md                 # User-facing guide
    │   ├── commands/
    │   │   ├── dmail.md              # Main skill (phase logic)
    │   │   └── cancel-dmail.md       # Halt command
    │   ├── agents/
    │   │   ├── faris.md              # Market researcher (Cheshire Break — runs before Okabe)
    │   │   ├── okabe.md              # Spec writer + expansion ideator (Mad Scientist)
    │   │   ├── daru.md               # Coder (Super Hacker)
    │   │   ├── kurisu.md             # Architecture proposer (dual-worldline)
    │   │   ├── moeka.md              # Codebase explorer (reads before building)
    │   │   ├── mayuri.md             # User reviewer (final usability check)
    │   │   └── future-okabe.md       # Parallel code reviewers (3 dimensions)
    │   └── hooks/
    │       ├── hooks.json            # Hook registration manifest
    │       └── stop-hook.sh          # Session-to-session loop controller
    └── port/
        ├── commands/
        │   ├── worldline-shift.md    # Main skill (porting phase logic)
        │   └── cancel-worldline-shift.md  # Halt command
        ├── agents/
        │   ├── suzuha.md             # Source analyzer + parity mapper + verifier
        │   ├── ruka.md               # Data model & API contract mapper
        │   ├── daru-port.md          # Parity-driven coder (port-specific)
        │   ├── kurisu-port.md        # Mapping-focused architect (port-specific)
        │   └── future-okabe-port.md  # Parity-focused reviewer (port-specific)
        └── hooks/
            ├── hooks.json            # Hook registration manifest
            └── stop-hook.sh          # Session-to-session loop controller
```

## D-Mail: How It Works

### The Core Loop

D-Mail operates as a **two-layer autonomous loop**:

1. **Inner loop** (within a session): TDD-driven — write failing tests → implement → run suite → fix → repeat
2. **Outer loop** (across sessions): The `stop-hook.sh` runs when Claude tries to exit. It reads `reading-steiner.md` in the target project directory and injects it back as context, blocking exit and continuing the loop

### The Seven Phases

Every built project follows this sequence:

| Phase | Name | Purpose |
|-------|------|---------|
| 0 | Initialization | Setup state file, git repo, install deps |
| 1 | Divergence Analysis | Faris researches existing solutions; Okabe writes full feature spec |
| 2 | Worldline Selection | Kurisu agent proposes Alpha (minimal) + Beta (clean) architectures |
| 3 | Time Leap Development | TDD implementation loop |
| 3b | Divergence Meter Reading | Playwright E2E verification (web projects only, non-negotiable) |
| 4 | Christina's Analysis | 3× Future Okabe agents review in parallel |
| 5 | Worldline Convergence | Fix all review findings |
| 6 | Worldline Checkpoint | Git commit + docs update |
| 7 | Worldline Expansion | Okabe ideates next features → back to Phase 2 |

The loop continues until `leap_count >= max_iterations` (default 30) or Claude outputs `<promise>EL_PSY_KONGROO</promise>`.

### State Persistence: `reading-steiner.md`

The key to cross-session continuity. Written at the end of each session to the **target project directory** (not this repo). Contains current phase, leap count, architecture decisions, test coverage, and what to build next. The stop hook reads this file to resume work.

### Sub-Agents

Each agent has a specific role and is spawned at defined phases:
- **Faris NyanNyan** → Phase 1 (market research via Cheshire Break — existing solutions, target audience, differentiation gaps; runs before Okabe to inform the spec)
- **Okabe** → Phase 1 (spec) and Phase 7 (expansion ideation)
- **Daru** → Phase 3 (TDD implementation of each feature)
- **Kurisu** → Phase 2 (two competing architecture proposals)
- **Moeka** → Before each feature (reads existing codebase to prevent duplication)
- **Future Okabe** → Phase 4 (3 parallel reviewers: simplicity, bugs/security, test coverage)
- **Mayuri** → Phase 6 (user-perspective final review; if she finds a genuine usability gap, loops back to Phase 3)

### Stop Hook Behavior

`stop-hook.sh` checks (in order):
1. Is `reading-steiner.md` present? (If not, allow exit — not a D-Mail session)
2. Is phase `el-psy-kongroo`, `cancelled`, or budget exhausted? → Allow exit
3. Is transcript contains `<promise>EL_PSY_KONGROO</promise>`? → Allow exit
4. Same git HEAD as before (no progress)? → Increment SERN interference counter, warn
5. Otherwise → Return `{"decision": "block"}` with state injected as continuation prompt

### Autonomous Decision Rules

| Situation | Rule |
|-----------|------|
| Stack ambiguity | React+Vite+pnpm for web; Node+TS for backend; Python for AI/ML |
| Web vs CLI ambiguity | Default to CLI (faster to test) |
| Alpha vs Beta worldline | Simple project → Alpha; multi-concern → Beta |
| Feature stuck 3 sessions | Mark deferred, move to next, retry later |
| Budget at 80%+ | Prioritize checkpoint over polish |
| Playwright MCP missing | Verify MCP running; do NOT skip Phase 3b |

### MCP Dependencies (for target projects)

- **Playwright MCP**: Required for Phase 3b E2E testing of web projects
- **Context7 MCP**: Live library docs to prevent hallucinated API usage
- **GitHub MCP**: Optional, used with `--push-to-github` flag

## Port (Worldline Shift): How It Works

### The Core Concept

Port takes a **source project** in one tech stack and autonomously migrates it to a **target project** in another stack, maintaining 1:1 functional parity. The source project IS the spec — no guessing, no feature invention.

### The Porting Phases

| Phase | Name | Purpose |
|-------|------|---------|
| 0 | Initialization | Setup target dir, validate source, detect stacks |
| 1 | Source Reconnaissance | Moeka + Suzuha exhaustively analyze source, extract feature inventory |
| 2 | Attractor Field Mapping | Suzuha creates parity matrix; Ruka maps all data models & API contracts |
| 3 | Convergence Architecture | Kurisu proposes Alpha (direct map) + Beta (idiomatic) target architectures |
| 4 | Worldline Migration | Page-composition TDD porting: Moeka reads source+parent → Daru ports with parity+composition tests |
| 4c | Integration Wiring | Verify all components wired into parents, orphan scan, composition test check (every 3 leaps) |
| 4b | Cross-Worldline Verification | Per-page, per-button Playwright browser verification for web targets |
| 5 | Divergence Audit | Future Okabe ×3 review with parity, orphan detection, and placeholder scan focus |
| 6 | Convergence Fix | Fix all must-fix review items |
| 6b | Parity Verification | Suzuha verifies every "ported" feature matches source (integration + behavior) |
| 7 | Shift Checkpoint | Final verification + orphan/placeholder scans; if features remain → Phase 4; else complete |

### Key Differences from D-Mail

- **Source = Spec**: No spec-writing phase — the source project defines all requirements
- **Parity Matrix**: Master tracking document mapping every source feature to its target equivalent
- **Data Contract Mapping**: Field-by-field mapping of all models, APIs, state, storage, routes
- **Parity Tests**: Tests written to verify the target behaves identically to the source
- **Parity Percentage**: Tracks `integrated_features / total_features` — only features wired into their parent pages count
- **Page Composition Porting**: Features are ported as full page compositions (parent + all children), not isolated components
- **Integration Wiring (Phase 4c)**: Mandatory check every 3 leaps that catches orphan components, placeholder handlers, and missing composition tests
- **Status Lifecycle**: `not-started → in-progress → coded → integrated → verified` — "coded" means component exists; "integrated" means it's actually wired into the app

### Sub-Agents

Shared with D-Mail:
- **Moeka** → Phases 1, 4 (codebase explorer — reads both source and target)

Port-specific agents:
- **Daru (Port)** → Phase 4 (parity-driven TDD — translates source features with behavioral test parity)
- **Kurisu (Port)** → Phase 3 (mapping-focused architecture — source→target module mapping, platform API mapping)
- **Future Okabe (Port)** → Phase 5 (parity-focused review — source/target side-by-side comparison, test count verification, stub detection)
- **Suzuha** → Phases 1, 2, 5 (source analyzer, parity matrix creator, parity verifier — "time traveler who bridges both worldlines")
- **Ruka** → Phase 2 (data model & API contract mapper — "exists in both worldlines")

### State Persistence: `worldline-shift.md`

Same pattern as D-Mail's `reading-steiner.md` but with porting-specific fields: `source_path`, `source_stack`, `target_stack`, `parity_pct`, `total_features`, `ported_features`, and paths to the parity matrix and data contracts.

### Living Documents (in target project)

- `SHIFT_LOG.md` — one entry per leap with parity stats
- `PARITY_REPORT.md` — running feature-by-feature parity status
- `documents/feature-inventory.md` — complete source feature catalog
- `documents/parity-matrix.md` — master 1:1 feature tracking
- `documents/data-contracts.md` — field-level data model mapping
- `documents/convergence-spec.md` — architectural decisions

## Modifying Skills

Skills are markdown files with structured prompt content. When editing:
- `commands/*.md` — The slash command prompt. Changes affect what Claude does when the skill is invoked.
- `agents/*.md` — Sub-agent instructions. Spawned via `Agent` tool with these as the prompt.
- `hooks/stop-hook.sh` — Bash script. Must remain POSIX-compatible; parses `reading-steiner.md` with `grep`/`sed`.
- `hooks/hooks.json` — Declares which hooks fire on which events.

### Committing skill changes

Editing files under `.lab/` triggers the `seal-fg204.sh` PostToolUse hook, which auto-commits `.lab/fg204.txt` as part of the change.

## Experiments

Skill test runs are kept out of git using the `fg_exp_` prefix convention:

- D-Mail test projects are placed directly inside `claude_skills/` and named `fg_exp_<project_name>/` (e.g., `fg_exp_habit_tracker/`)
- The root `.gitignore` excludes all `fg_exp_*/` directories
- This keeps the skills repo clean while allowing throwaway experiment projects to live alongside it

When running `/dmail` for skill testing, `cd` into `claude_skills/` first so the experiment directory is created here and automatically ignored.

## Thematic Naming (Steins;Gate)

All naming is thematic — it's cosmetic, not functional:
- "D-Mail" = the `/dmail` prompt that kicks off worldline divergence
- "Reading Steiner" = `reading-steiner.md` persistence (memory across context resets)
- "Worldlines" = build iterations
- "Divergence Meter" = test coverage %
- "SERN interference" = bugs/blockers
- "Time Leap" = git rollback
- "El Psy Kongroo" = completion signal
- "Worldline Shift" = `/worldline-shift` — migrating from one worldline (stack) to another
- "Attractor Field" = the set of features that must remain constant across worldlines (parity matrix)
- "Convergence" = making the target match the source's functionality
- "Cheshire Break" = Faris NyanNyan's market research phase (existing solutions, differentiation gaps)
- "Mayuri" = user-perspective final reviewer before a worldline is declared stable
- "Suzuha" = the time traveler who has seen both worldlines (source analyzer + parity verifier)
- "Ruka" = the one who exists in both worldlines (data contract mapper)
