# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

This is a **Claude Code skills/plugins repository** — a collection of custom slash commands, agents, and hooks that extend Claude Code's capabilities. The flagship skill is **D-Mail**, an autonomous project builder that runs indefinitely from a single prompt.

## Repository Structure

```
claude_skills/
├── documents/                        # Design specs and feature docs
│   └── autonomous-builder-skill.md   # Full design spec for D-Mail
└── plugins/
    └── dmail/
        ├── README.md                 # User-facing guide
        ├── commands/
        │   ├── dmail.md    # Main skill (phase logic, 461 lines)
        │   └── cancel-steiner.md     # Halt command
        ├── agents/
        │   ├── okabe.md              # Spec writer + expansion ideator (Mad Scientist)
        │   ├── daru.md               # Coder (Super Hacker)
        │   ├── kurisu.md             # Architecture proposer (dual-worldline)
        │   ├── moeka.md              # Codebase explorer (reads before building)
        │   └── future-okabe.md       # Parallel code reviewers (3 dimensions)
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
| 1 | Divergence Analysis | Okabe agent writes full feature spec |
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

## Modifying Skills

Skills are markdown files with structured prompt content. When editing:
- `commands/*.md` — The slash command prompt. Changes affect what Claude does when the skill is invoked.
- `agents/*.md` — Sub-agent instructions. Spawned via `Agent` tool with these as the prompt.
- `hooks/stop-hook.sh` — Bash script. Must remain POSIX-compatible; parses `reading-steiner.md` with `grep`/`sed`.
- `hooks/hooks.json` — Declares which hooks fire on which events.

## Thematic Naming (Steins;Gate)

All naming is thematic — it's cosmetic, not functional:
- "D-Mail" = the `/dmail` prompt that kicks off worldline divergence
- "Reading Steiner" = `reading-steiner.md` persistence (memory across context resets)
- "Worldlines" = build iterations
- "Divergence Meter" = test coverage %
- "SERN interference" = bugs/blockers
- "Time Leap" = git rollback
- "El Psy Kongroo" = completion signal
