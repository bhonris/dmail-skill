---
name: echelon
description: "SERN's all-seeing surveillance — enumerate every page and interactive element, test each one, produce a structured evidence-backed report with deterministic pass/fail"
argument-hint: '[url-or-path] [--pages-only] [--report-only]'
---

# Echelon — SERN Surveillance Protocol

You are running **Echelon**: SERN's all-seeing surveillance sweep of a web application. Every page, every interactive element, every console error — all intercepted, catalogued, and reported. Nothing is out of scope. Nothing is silently dropped. You cannot self-certify a pass.

---

## Playwright Gate

First, check whether Playwright MCP tools are present in your tool list (look for tools named `playwright_navigate`, `playwright_screenshot`, `playwright_click`, `playwright_snapshot`, or similar `playwright_*` names).

If Playwright MCP tools are NOT present:
```
Echelon cannot start. Playwright MCP is not running.

Required: claude mcp add playwright npx @playwright/mcp@latest

Restart Claude Code and re-run /echelon.
```
Stop. Do not proceed.

---

## Input

Parse arguments:
- **First argument**: A URL (e.g. `http://localhost:5173`) or a project directory path. If a path, start the dev server from it before testing.
- **`--pages-only`**: Test page loads only. Skip per-element interaction testing.
- **`--report-only`**: Skip testing. Read existing `echelon/manifest.json` and `echelon/results.json` and regenerate `echelon/ECHELON_REPORT.md` only.

If no argument is given, look for a running dev server at common ports (`5173`, `3000`, `4173`, `8080`) or detect a startable project in the current directory (`package.json` with `dev`/`start`/`preview` script).

If no URL can be determined, ask the user before proceeding.

---

## Output Structure

All output goes to `echelon/` in the project root (or current directory if no project):

```
echelon/
├── manifest.json        ← enumerated routes + elements. COMMITTED before testing begins.
├── results.json         ← per-element results with quoted evidence
├── screenshots/
│   ├── page-<id>.png    ← one screenshot per page visit (mandatory)
│   └── fail-<id>.png    ← extra screenshot on failure
└── ECHELON_REPORT.md    ← human-readable summary with health score
```

---

## Phase 1 — Discovery (Enumerate Everything Before Testing Anything)

**Goal**: Build a complete manifest of all pages and interactive elements. The manifest is committed to git before any testing begins. After that commit, nothing may be removed from it.

### Step 1: Start the app

If argument was a path (not a URL):
- Read `package.json` to find the dev server command (prefer `dev`, then `start`, then `preview`)
- Start the dev server
- Wait for it to respond (ping the URL until it returns 200 or times out after 30s)
- Record the base URL

### Step 2: Crawl for routes

From the root URL:
1. Navigate to `/`
2. Take an accessibility snapshot
3. Extract all internal links from the snapshot
4. Follow each link, record the route
5. Look for route definitions in source code (`src/router`, `src/routes`, `App.tsx`, `routes/`, `pages/`) — these reveal routes that are not reachable by clicking (deep links, authenticated routes)
6. For dynamic routes (e.g. `/user/:id`), record ONE representative instance using a real ID found in the app or a test value
7. Deduplicate. Record every unique path.

### Step 3: For each route, enumerate interactive elements

Navigate to the route. Take an accessibility snapshot. Extract:
- **Buttons** — every role=button, `<button>`, icon button (include invisible/small ones)
- **Links** — every internal `<a href>` and nav link (skip `mailto:`, `tel:`, and external URLs — mark them `external`)
- **Tabs** — every role=tab within a tablist
- **Form inputs** — every `<input>`, `<select>`, `<textarea>`, `<checkbox>`, `<radio>`
- **Modal/dialog triggers** — buttons whose accessible name suggests they open overlays (e.g. "Open", "Add", "Edit", "Delete", "Confirm", "×")
- **Accordions** — expandable/collapsible sections

For each element, record its **accessible name** (the text the screen reader would announce) — this is your stable identifier.

### Step 4: Write and commit `echelon/manifest.json`

```json
{
  "generated_at": "<ISO timestamp>",
  "base_url": "http://localhost:5173",
  "total_pages": 0,
  "total_elements": 0,
  "pages": [
    {
      "id": "page-home",
      "route": "/",
      "title": "Page title from <title> or <h1>",
      "requires_auth": false,
      "elements": [
        {
          "id": "elem-home-001",
          "type": "button | link | tab | input | modal-trigger | accordion | external",
          "accessible_name": "Submit form",
          "description": "Submits the contact form"
        }
      ]
    }
  ]
}
```

ID convention:
- Pages: `page-<slug>` where slug = route path with `/` replaced by `-` (root = `page-root`)
- Elements: `elem-<page-slug>-<NNN>` (3-digit zero-padded sequence per page)

**Commit**: `echelon: manifest — <total_pages> pages, <total_elements> elements`

After this commit, the manifest is the ground truth. Testing must produce a result for every element ID in it.

---

## Phase 2 — Test Execution

**The invariant**: `results.json` must contain an entry for every element ID in `manifest.json` before the report can be generated. Missing entries = incomplete sweep.

For each page in `manifest.json`, in order:

### Step 1: Navigate and capture baseline

1. Navigate to the page's `route`
2. Take a screenshot → save as `echelon/screenshots/<page-id>.png`
   - **This file must exist**. No screenshot = the page was not properly visited and must be retested.
3. Take an accessibility snapshot → save it in memory as `baseline_snapshot`
4. Record the page load result:
   - Pass: page loaded, no error overlay, title matches expected
   - Fail: 404, blank page, JS crash error overlay, or blank `<body>`
   - Record any console errors captured during load

### Step 2: Test each element

For each element in `page.elements`:

#### Locating the element

Search `baseline_snapshot` for the element's `accessible_name`. You must find a line in the snapshot that contains this name.

- **If found**: quote the exact line(s) from the snapshot as `snapshot_evidence`
- **If NOT found**: result is `fail`, `snapshot_evidence` = `"Element not found in accessibility snapshot"`. Do not attempt to interact with it.

#### Interacting with the element (only if found)

Take the snapshot **before** interaction and record it as `snapshot_before`. Then:

| Element type | Action | Pass condition |
|---|---|---|
| `button` | Click it | Snapshot changes OR URL changes OR network request fires |
| `link` (internal) | Click it | URL changes to the link's target. No 404. |
| `tab` | Click it | Snapshot changes (different tab panel becomes visible) |
| `input` | Type a test value (`"Test input 123"`) | Snapshot reflects the typed value |
| `select` | Select the second option | Snapshot reflects the selection |
| `checkbox` | Click to toggle | Snapshot shows changed checked state |
| `modal-trigger` | Click it | A dialog/modal/overlay appears in snapshot |
| `accordion` | Click to expand | Snapshot shows additional content |
| `external` | Do NOT click | Record as `skip` with reason `"external link"` |

After interaction, take a new snapshot as `snapshot_after`. Record the **actual diff** between before and after — what changed.

**Dead element rule**: If you clicked a `button` or `link` and:
- The URL did not change, AND
- The snapshot before and after are identical, AND
- No loading state appeared

→ result is `fail`, `actual_behavior` = `"No DOM change, no navigation, no loading state after click. Likely dead handler."`

#### Recording the result

```json
{
  "id": "elem-home-001",
  "page_id": "page-home",
  "result": "pass | fail | skip | flaky",
  "snapshot_evidence": "<quoted line(s) from accessibility snapshot showing the element>",
  "actual_behavior": "<what actually happened — URL change, snapshot diff summary, or 'no change'>",
  "expected_behavior": "<what should happen based on element type and accessible name>",
  "console_errors": [],
  "screenshot_after": null
}
```

Rules:
- `snapshot_evidence` **must** be a literal quote from the Playwright snapshot. Paraphrase is not allowed.
- For failures, also save `echelon/screenshots/fail-<elem-id>.png` and set `screenshot_after` to that path.
- `flaky` = passed on retry after one failure. Note retry count.
- `skip` = disabled element, external link, or requires auth (clearly document reason).

**Console error rule**: Any `console.error` or unhandled JS exception captured during a page's test session is recorded in the element results where it occurred (or in the page's `page_load` result if it occurred during navigation). These are findings and must appear in the report. They are never silently dropped.

### Step 3: After each page, write progress to `results.json`

Don't batch all pages — write results incrementally. If the sweep is interrupted, it can resume from the last completed page.

---

## Completion Gate

After all pages are done:

1. Count: `tested_count` = number of entries in `results.json`
2. Count: `manifest_count` = `manifest.total_elements`
3. If `tested_count < manifest_count`:
   - List the missing element IDs (in `manifest.json` but not in `results.json`)
   - **Continue testing** those elements before generating the report. Do not skip this.
4. Only when `tested_count == manifest_count`: proceed to Phase 3.

---

## Phase 3 — Report

Generate `echelon/ECHELON_REPORT.md`:

```markdown
# Echelon Surveillance Report

**Date**: <timestamp>
**App**: <base_url>
**Health Score**: <pass_count / (total_elements - skip_count) * 100>%

## Summary

| Metric | Count |
|--------|-------|
| Pages tested | N |
| Elements in manifest | M |
| Passed | X |
| Failed | Y |
| Skipped (external/disabled/auth) | Z |
| Flaky (passed on retry) | W |
| Console errors / JS exceptions | E |

## Failed Elements

<!-- One section per failure -->
### <elem-id> — <page title> › <accessible name>

- **Type**: button / link / tab / etc.
- **Route**: /path/to/page
- **Expected**: <expected_behavior>
- **Actual**: <actual_behavior>
- **Evidence**: `<snapshot_evidence>`
- **Screenshot**: echelon/screenshots/fail-<elem-id>.png

## Console Errors

<!-- All console.error and unhandled exceptions, grouped by page -->
### <page-id> — <route>
- `<error message>` (during: page load / elem-<id> interaction)

## Page-by-Page Results

| Page | Route | Screenshot | Elements | Pass | Fail | Skip |
|------|-------|-----------|----------|------|------|------|
| Home | / | echelon/screenshots/page-root.png | 12 | 10 | 1 | 1 |
| ...  | ...  | ...  | ...  | ...  | ...  | ...  |

## Manifest Coverage

Elements tested: <tested_count> / <manifest_count> (<pct>%)

<!-- If < 100%, list untested IDs here -->
```

---

## Deterministic Feedback Rules

These rules exist to prevent Echelon from self-certifying without ground truth. They are not guidelines — violations mean the surveillance report is invalid.

### Rule 1 — No evidence, no pass

If `snapshot_evidence` does not contain a literal quote from the Playwright accessibility snapshot, the result is `fail`. Paraphrase, interpretation, or "I could see the button" are not evidence.

### Rule 2 — No screenshot, no page visit

If `echelon/screenshots/<page-id>.png` does not exist after the run, that page was not properly visited. Re-navigate and re-test.

### Rule 3 — Manifest is immutable after commit

After Phase 1's git commit, no elements may be removed from `manifest.json`. If new elements are discovered during testing, add them and test them. The total count may only go up, never down.

### Rule 4 — Count must match before reporting

`results.json` entry count must equal `manifest.total_elements` before the report is generated. If not, continue testing. Do not generate a partial report and call it complete.

### Rule 5 — Console errors are mandatory findings

Every `console.error` and unhandled exception must appear in the report. None may be omitted because they seem "unrelated" or "minor."

### Rule 6 — Dead buttons are failures

A button or link that produces no DOM change, no URL change, and no visible loading state after clicking is `fail`. No exceptions. "It might be intentional" is not a pass.

### Rule 7 — Placeholder handlers are failures

Any click handler that clearly resolves to `console.log(...)`, `() => {}`, `alert(...)`, or `// TODO` is `fail`. These are unimplemented features, not passes.

### Rule 8 — Snapshot diff must be stated

For any `pass` result on an interactive element, `actual_behavior` must describe what changed in the snapshot or URL. "Button clicked successfully" is not a valid `actual_behavior`. Write what changed: "URL changed from `/` to `/dashboard`" or "Modal with title 'Confirm Delete' appeared in snapshot."

---

## Autonomous Decision Rules

| Situation | Rule |
|-----------|------|
| Page requires authentication | Record as `requires_auth: true`, test only what's visible unauthenticated, note auth-gated pages in report |
| Route has dynamic params | Use one real ID from the app's data, or a known test ID. If none available, use a sentinel (`test-id-001`) and note it |
| Element is `disabled` | Record `skip`, reason `"disabled at time of test"`. Include snapshot evidence of disabled state. |
| Two elements have same accessible name | Disambiguate by index (`elem-page-001`, `elem-page-002`). Test both. |
| Infinite scroll / virtualized list | Test the first visible batch. Note pagination/virtualization in report. |
| Element triggers a file download | Click it. If a download is initiated (Playwright detects it), record `pass`. |
| Form submit with required fields | Fill all required fields with test data first, then submit. |
| Modal opens another modal | Test each modal independently. Close after each test. |
| Flaky element (fails once, passes on retry) | Retry once. If it passes, mark `flaky`. If it fails twice, mark `fail`. |
| Dev server port conflicts | Try ports 5173, 3000, 4173, 8080 in order. |
| Navigation leads to external domain | Mark `skip`, reason `"external"`. Do NOT follow. |

---

## Commit Convention

```
echelon: manifest — <N> pages, <M> elements
echelon: results — <pass>/<total> passing, <fail> failures
echelon: report — <health_score>% health, <fail> failures
```
