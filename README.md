# D-Mail Skill Repository

> *El Psy Kongroo.*

Two autonomous Claude Code skills: **D-Mail** (project builder) and **Worldline Shift** (project porter). Send a single prompt. Walk away. The lab members work through the night.

---

## D-Mail

Autonomous project builder for Claude Code. Takes a single natural-language prompt and builds a complete project from scratch, iterating indefinitely until the budget is exhausted.

### What it does

`/dmail` takes a single natural-language prompt and autonomously:

1. **Divergence Analysis** — Faris researches existing solutions; Okabe writes a full feature spec
2. **Worldline Selection** — Kurisu proposes two architectures; best one wins
3. **Time Leap Development** — TDD loop: write tests, implement, fix, repeat
4. **Divergence Meter Reading** — Playwright MCP verifies the running UI (web projects)
5. **Christina's Analysis** — Future Okabe reviews for bugs, quality, and coverage gaps
6. **Worldline Convergence** — All must-fix issues resolved
7. **Worldline Checkpoint** — Docs polished, git tagged, optionally pushed to GitHub
8. **Worldline Expansion** — Okabe ideates what to build next, loop restarts

**The loop never ends voluntarily.** It runs until the iteration budget is exhausted (`leap_count >= max_iterations`). Each completed cycle improves the project further.

### Usage

```bash
/dmail "Build a CLI budgeting tool in TypeScript"
/dmail "Build a React todo app with local storage" --max-iterations 50
/dmail "Build a Python web scraper for Hacker News" --push-to-github
```

To cancel a running loop:
```bash
/cancel-dmail
```

### Options

| Flag | Default | Description |
|---|---|---|
| `--max-iterations N` | 30 | Budget cap — loop halts at this many leaps |
| `--stack hint` | auto | Technology preference (e.g. "Python", "React") |
| `--push-to-github` | false | Auto-publish each completed worldline via GitHub MCP |

### Output files (in project root)

| File | Purpose |
|---|---|
| `reading-steiner.md` | Loop state — the Reading Steiner memory |
| `STEINER_LOG.md` | Per-commit changelog with divergence meter readings |
| `DOSSIER.md` | Project summary updated at every phase |
| `USAGE.md` | Usage instructions updated as features go green |
| `README.md` | Written at first checkpoint |
| `documents/steiner-spec.md` | Living spec, expanded each cycle |

### Steins;Gate concept mapping

| Series | Skill |
|---|---|
| D-Mail | The `/dmail` prompt — the message that triggers worldline divergence |
| Reading Steiner | `reading-steiner.md` persistence across context resets |
| Worldlines | Build iterations and architecture approaches |
| Divergence Meter | Test coverage % |
| Lab Members | Sub-agents (Daru, Kurisu, Moeka, Future Okabe) |
| SERN | Bugs, failing tests, blockers |
| El Psy Kongroo | Budget exhausted — loop halts |
| Cheshire Break | Faris NyanNyan's market research phase (existing solutions, gaps) |

### Lab Members (sub-agents)

| Agent | Role |
|---|---|
| **Faris NyanNyan** | Market researcher — scans existing solutions and differentiation gaps before spec (Phase 1) |
| **Okabe** | Spec writer (Phase 1) and expansion ideator (Phase 7) |
| **Daru** | Super Hacker — implements features with TDD (Phase 3) |
| **Kurisu × 2** | Parallel architecture proposals — Alpha and Beta worldlines |
| **Moeka** | Silent codebase explorer before each feature |
| **Future Okabe × 3** | Parallel code review — simplicity, correctness, coverage |
| **Mayuri** | User reviewer — final check before worldline is declared stable (Phase 6) |

### MCP servers used

| Server | When | Why |
|---|---|---|
| **Playwright** | Phase 3b, Phase 6 | E2E verification of running web UI |
| **Context7** | Phases 3–5 | Live library docs — prevents SERN (hallucinated APIs) |
| **GitHub MCP** | Phase 6 (optional) | Auto-publish completed worldlines |

---

## Worldline Shift (Port)

Autonomous project porter for Claude Code. Takes a source project in one tech stack and migrates it to a target stack with 1:1 functional parity. The source project IS the spec — no guessing, no feature invention.

### What it does

`/worldline-shift` takes a source project path and a target stack and autonomously:

1. **Initialization** — Setup target directory, validate source, detect stacks
2. **Source Reconnaissance** — Moeka + Suzuha exhaustively catalog every feature, route, model, and behavior
3. **Attractor Field Mapping** — Suzuha creates the parity matrix; Ruka maps all data models and API contracts field-by-field
4. **Convergence Architecture** — Kurisu proposes Alpha (direct map) + Beta (idiomatic) target architectures
5. **Worldline Migration** — Page-composition TDD porting: Moeka reads source → Daru ports with parity tests
6. **Integration Wiring** — Every 3 leaps: verify all components are wired into parents, scan for orphans and placeholders
7. **Cross-Worldline Verification** — Per-page, per-button Playwright verification for web targets
8. **Divergence Audit** — Future Okabe ×3 reviews with parity, orphan detection, and placeholder scan focus
9. **Convergence Fix** — All must-fix review items resolved
10. **Parity Verification** — Suzuha verifies every ported feature matches source behavior
11. **Shift Checkpoint** — Final scan; if features remain → back to Phase 4; else complete

**Parity percentage** (`integrated_features / total_features`) is tracked continuously. Only features wired into their parent pages count as integrated.

### Usage

```bash
/worldline-shift --source ./my-react-app --target-stack "Vue + Vite"
/worldline-shift --source /path/to/project --target-stack "Python Flask" --max-iterations 40
/worldline-shift --source ./cli-tool --target-stack "Go" --push-to-github
```

To cancel a running loop:
```bash
/cancel-worldline-shift
```

### Options

| Flag | Default | Description |
|---|---|---|
| `--source PATH` | required | Path to the source project to port |
| `--target-stack STACK` | required | Target technology (e.g. "Vue + Vite", "Go", "Python Flask") |
| `--max-iterations N` | 30 | Budget cap — loop halts at this many leaps |
| `--push-to-github` | false | Auto-publish each checkpoint via GitHub MCP |
| `--bypass-playwright` | false | Skip browser verification (non-web targets) |

### Output files (in target project root)

| File | Purpose |
|---|---|
| `worldline-shift.md` | Loop state — the Worldline Shift memory |
| `SHIFT_LOG.md` | Per-leap log with parity stats |
| `PARITY_REPORT.md` | Running feature-by-feature parity status |
| `documents/feature-inventory.md` | Complete source feature catalog |
| `documents/parity-matrix.md` | Master 1:1 feature tracking (source → target) |
| `documents/data-contracts.md` | Field-level data model and API mapping |
| `documents/convergence-spec.md` | Architectural decisions for the port |

### Steins;Gate concept mapping

| Series | Skill |
|---|---|
| Worldline Shift | The `/worldline-shift` prompt — migrating from one worldline (stack) to another |
| Attractor Field | The set of features that must remain constant across worldlines (parity matrix) |
| Convergence | Making the target match the source's full functionality |
| Suzuha | Time traveler who has seen both worldlines — source analyzer and parity verifier |
| Ruka | The one who exists in both worldlines — data model and API contract mapper |
| Parity Matrix | Master tracking of every source feature and its target equivalent |
| Status Lifecycle | `not-started → in-progress → coded → integrated → verified` |
| El Psy Kongroo | 100% parity reached or budget exhausted — shift complete |

### Lab Members (sub-agents)

| Agent | Role |
|---|---|
| **Suzuha** | Source analyzer (Phase 1), parity matrix creator (Phase 2), parity verifier (Phase 6b) |
| **Ruka** | Data model and API contract mapper — field-level source→target mapping (Phase 2) |
| **Daru (Port)** | Parity-driven coder — ports features with behavioral test parity (Phase 4) |
| **Kurisu (Port)** | Mapping-focused architect — source→target module and platform API mapping (Phase 3) |
| **Future Okabe (Port) × 3** | Parity-focused reviewers — side-by-side comparison, stub detection, orphan scan (Phase 5) |
| **Moeka** | Codebase explorer — reads both source and target before each porting step (Phases 1, 4) |

### MCP servers used

| Server | When | Why |
|---|---|---|
| **Playwright** | Phase 4b, Phase 6b | Per-page browser verification against source behavior |
| **Context7** | Phases 4–6 | Live library docs for the target stack |
| **GitHub MCP** | Phase 7 (optional) | Auto-publish completed shift checkpoints |

### Key differences from D-Mail

| D-Mail | Worldline Shift |
|---|---|
| Spec written by Okabe from scratch | Source project IS the spec — no invention |
| Tests verify new functionality | Parity tests verify behavior matches source |
| Iterates to add features | Iterates to achieve 100% parity |
| Output: complete new project | Output: functionally equivalent project in new stack |
| Loop ends when budget runs out | Loop ends when all features are verified or budget runs out |

---

## Windows compatibility

The stop hooks require Git Bash. Ensure `settings.json` uses `bash` (not the full `bash.exe` path) as the command prefix.

## Manual resume

If a session crashes mid-loop, resume by running the skill again in the project directory. It will read the state file and continue from the last saved phase.

- **D-Mail**: Run `/dmail` in the target project directory. Reads `reading-steiner.md`.
- **Worldline Shift**: Run `/worldline-shift` in the target project directory. Reads `worldline-shift.md`.

To restart from a specific phase, edit the state file and change the `phase` field.

## Installation

### 1. Register slash commands (global)

Copy all skill commands to `~/.claude/commands/`:

```bash
# D-Mail
cp plugins/dmail/commands/dmail.md ~/.claude/commands/
cp plugins/dmail/commands/cancel-dmail.md ~/.claude/commands/
cp plugins/dmail/commands/recursive-mother-goose.md ~/.claude/commands/

# Worldline Shift (Port)
cp plugins/port/commands/worldline-shift.md ~/.claude/commands/
cp plugins/port/commands/cancel-worldline-shift.md ~/.claude/commands/
```

### 2. Install stop hooks

Copy the stop hooks to `~/.claude/`:

```bash
mkdir -p ~/.claude/dmail/hooks ~/.claude/port/hooks
cp plugins/dmail/hooks/stop-hook.sh ~/.claude/dmail/hooks/
cp plugins/port/hooks/stop-hook.sh ~/.claude/port/hooks/
```

### 3. Register hooks in `~/.claude/settings.json`

Add both hooks under the `Stop` event:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"~/.claude/dmail/hooks/stop-hook.sh\""
          },
          {
            "type": "command",
            "command": "bash \"~/.claude/port/hooks/stop-hook.sh\""
          }
        ]
      }
    ]
  }
}
```

> **Windows**: Use full paths (e.g. `C:/Users/<you>/.claude/...`) instead of `~` in `settings.json`. The stop hooks require Git Bash — ensure `bash` is on your PATH.

### Keeping skills up to date

The files in `~/.claude/commands/` and `~/.claude/*/hooks/` are plain copies — they won't auto-update when this repo changes. Re-run the copy commands above after pulling updates.
