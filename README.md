# D-Mail

> *El Psy Kongroo.*

Autonomous project builder for Claude Code. Send one D-Mail. Walk away. The lab members work through the night. You return to a project that has reached Steins;Gate.

## What it does

`/dmail` takes a single natural-language prompt and autonomously:

1. **Divergence Analysis** — Okabe writes a full feature spec
2. **Worldline Selection** — Kurisu proposes two architectures; best one wins
3. **Time Leap Development** — TDD loop: write tests, implement, fix, repeat
4. **Divergence Meter Reading** — Playwright MCP verifies the running UI (web projects)
5. **Christina's Analysis** — Future Okabe reviews for bugs, quality, and coverage gaps
6. **Worldline Convergence** — All must-fix issues resolved
7. **Worldline Checkpoint** — Docs polished, git tagged, optionally pushed to GitHub
8. **Worldline Expansion** — Okabe ideates what to build next, loop restarts

**The loop never ends voluntarily.** It runs until the iteration budget is exhausted (`leap_count >= max_iterations`). Each completed cycle improves the project further.

## Usage

```bash
/dmail "Build a CLI budgeting tool in TypeScript"
/dmail "Build a React todo app with local storage" --max-iterations 50
/dmail "Build a Python web scraper for Hacker News" --push-to-github
```

To cancel a running loop:
```bash
/cancel-dmail
```

## Options

| Flag | Default | Description |
|---|---|---|
| `--max-iterations N` | 30 | Budget cap — loop halts at this many leaps |
| `--stack hint` | auto | Technology preference (e.g. "Python", "React") |
| `--push-to-github` | false | Auto-publish each completed worldline via GitHub MCP |

## Output files (in project root)

| File | Purpose |
|---|---|
| `reading-steiner.md` | Loop state — the Reading Steiner memory |
| `STEINER_LOG.md` | Per-commit changelog with divergence meter readings |
| `DOSSIER.md` | Project summary updated at every phase |
| `USAGE.md` | Usage instructions updated as features go green |
| `README.md` | Written at first checkpoint |
| `documents/steiner-spec.md` | Living spec, expanded each cycle |

## Steins;Gate concept mapping

| Series | Skill |
|---|---|
| D-Mail | The `/dmail` prompt — the message that triggers worldline divergence |
| Reading Steiner | `reading-steiner.md` persistence across context resets |
| Worldlines | Build iterations and architecture approaches |
| Divergence Meter | Test coverage % |
| Lab Members | Sub-agents (Daru, Kurisu, Moeka, Future Okabe) |
| SERN | Bugs, failing tests, blockers |
| El Psy Kongroo | Budget exhausted — loop halts |

## Lab Members (sub-agents)

| Agent | Role |
|---|---|
| **Okabe** | Spec writer (Phase 1) and expansion ideator (Phase 7) |
| **Daru** | Super Hacker — implements features with TDD (Phase 3) |
| **Kurisu × 2** | Parallel architecture proposals — Alpha and Beta worldlines |
| **Moeka** | Silent codebase explorer before each feature |
| **Future Okabe × 3** | Parallel code review — simplicity, correctness, coverage |
| **Mayuri** | User reviewer — final check before worldline is declared stable (Phase 6) |

## MCP servers used

| Server | When | Why |
|---|---|---|
| **Playwright** | Phase 3b, Phase 6 | E2E verification of running web UI |
| **Context7** | Phases 3–5 | Live library docs — prevents SERN (hallucinated APIs) |
| **GitHub MCP** | Phase 6 (optional) | Auto-publish completed worldlines |

## Windows compatibility

The stop hook requires Git Bash. Ensure `settings.json` uses `bash` (not the full `bash.exe` path) as the command prefix.

## Manual resume

If a session crashes mid-loop, resume by running `/dmail` again in the project directory. It will read `reading-steiner.md` and continue from the last saved state.

To restart from a specific phase, edit `reading-steiner.md` and change the `phase` field.

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
