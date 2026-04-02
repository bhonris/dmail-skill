# Worldline Shift — Post-Mortem & Improvement Plan

## Context

This document summarizes findings from the first real-world execution of the Worldline Shift skill, porting a Flutter HR application (74 source files, 246 tests) to a React + TypeScript PWA. The shift completed in 19 leaps with 66/66 features "ported" and 336 tests passing (137% test parity), yet **the resulting app had significant functional gaps** when actually run.

---

## Issues Found

### CRITICAL — Features non-functional

| # | Issue | Root Cause |
|---|-------|-----------|
| 1 | **Auto-login not working** | LoginPage pre-fills saved credentials but never attempts automatic login. Flutter shows a spinner screen during auto-login; React skips this entirely. |
| 2 | **Form History tab is a placeholder** | `FormHistory` component was created and tested in isolation, but `FormPage.tsx` never imports or renders it. Tab shows static "no history" text. |
| 3 | **FormPage card clicks don't navigate** | `handleCardClick` in FormPage is `console.log("Navigate to:", type)` — never replaced with actual navigation to CheckInLateRequest, LeaveRequestForm, or AnnouncementListScreen. |
| 4 | **OT Today tab is empty** | `OtRequestForm` component exists and is tested, but `OvertimePage.tsx` renders only a text placeholder "ไม่มีการขอล่วงเวลา" instead of the form. |
| 5 | **Salary Slip table layout completely wrong** | Flutter uses a specific two-column landscape table (Earnings \| Deductions side by side). React renders a different layout that doesn't match the source design at all. |

### HIGH — Important features missing

| # | Issue | Root Cause |
|---|-------|-----------|
| 6 | **Notification bell non-functional** | Homepage 🔔 button has no `onClick` handler. `NotificationPopup` component exists but is never opened. |
| 7 | **WeeklyCalendar not used in Homepage** | `WeeklyCalendar` component was built and tested in Leap 16, but `HomePage.tsx` (built in Leap 4) still uses `<input type="date">`. |
| 8 | **AnnouncementSection not rendered in Homepage** | `AnnouncementSection` component was built in Leap 5, but `HomePage.tsx` never imports it. |
| 9 | **OT Signature flow disconnected** | `SignaturePad` and `SignatureSection` exist as standalone components but are not wired into the OT request/confirm workflow. |
| 10 | **Profile page missing multiple sections** | `LateInfoCard`, `WorkInfoCard`, `SettingsDialog` — all three components were created and tested individually but never imported into `ProfilePage.tsx`. Profile shows minimal inline info instead. |
| 11 | **No deep linking to tabs** | No routes for `/app/home`, `/app/forms`, etc. `MainLayout` has no `initialIndex` support. Notification-to-tab navigation cannot work. |
| 12 | **Salary Slip missing landscape mode + PDF button** | Flutter locks to landscape orientation and has a PDF download button in the AppBar. React has neither. |

### MEDIUM — Functional but incomplete

| # | Issue | Root Cause |
|---|-------|-----------|
| 13 | **Pull-to-refresh missing on Homepage** | Flutter uses `RefreshIndicator`; React has no refresh mechanism. |
| 14 | **Funeral/cremation request handling missing** | `FormPage`'s `CheckinCard` in Flutter fetches pending cremation requests. React version doesn't. |
| 15 | **WebSocket not initialized on login** | `NotificationWebSocket` service exists but is never `connect()`ed when user logs in. |

---

## Root Cause Analysis

All 15 issues share **three fundamental failure patterns** in the skill's approach:

### Pattern 1: "Component Island" Problem

The skill ports features as isolated components (3 per leap), each with its own tests, committed separately. But it **never goes back to wire child components into parent pages**.

**Example timeline:**
```
Leap 4:  HomePage.tsx created (basic structure, no children)
Leap 5:  AnnouncementSection.tsx created (isolated, tested alone)
Leap 12: LateInfoCard.tsx created (isolated, tested alone)
Leap 16: WeeklyCalendar.tsx created (isolated, tested alone)
         ↑ None of these were ever imported back into HomePage.tsx
```

**Why the skill doesn't catch this:** Phase 4 moves forward feature-by-feature. There is no step that revisits already-committed parent pages to integrate newly created children. The parity matrix marks each feature as "ported" when its component + tests exist, not when it's actually used.

### Pattern 2: "Test Parity ≠ Functional Parity"

The skill measures success by test count ratio (`target_test_count / source_test_count`). At 137%, it appeared to exceed source coverage. But every test renders its component in **isolation**:

```tsx
// Test for AnnouncementSection — PASSES ✓
render(<AnnouncementSection />)
expect(screen.getByTestId('announcement-section')).toBeInTheDocument()

// But HomePage never renders AnnouncementSection — NO TEST CATCHES THIS
render(<HomePage />)
// No assertion that AnnouncementSection exists inside HomePage
```

**Why the skill doesn't catch this:** The parity test strategy tests each component independently. There are zero integration tests that verify parent-child composition. A component can pass all its tests while being completely orphaned from the app.

### Pattern 3: "Scaffold Then Abandon"

Pages created early as placeholders/stubs are never back-filled when their child components become available:

```
Phase 3:  FormPage.tsx created as placeholder with basic tabs
Leap 6:   CheckinCard added, but handleCardClick = console.log
Leap 10:  CheckInLateRequest created as standalone page
Leap 11:  LeaveRequestForm created as standalone page
          ↑ FormPage.tsx never updated to navigate to these pages
```

**Why the skill doesn't catch this:** The stub scan (`grep TODO/FIXME`) only catches explicit markers. A `console.log("Navigate to:", type)` is not a TODO — it's a silent placeholder that passes all tests.

---

## Improvement Recommendations

### 1. Add "Integration Wiring" Phase (Phase 4c)

Insert after every 3 leaps of feature porting:

```
Phase 4c — Integration Wiring

For EVERY component ported in the last 3 leaps:
1. Read the source to find which parent page/container renders this component
2. In the target, verify the component is:
   a. Imported in the parent file
   b. Rendered in the parent's JSX
   c. Connected with real event handlers (not console.log)
   d. Navigation targets actually exist and are routable
3. If any of (a-d) fail → fix immediately before proceeding

This phase is BLOCKING — cannot advance to next leap until all wiring is verified.
```

### 2. Change Porting Unit from "Component" to "Page Composition"

Current approach ports individual components as separate features:
```
F-008: Homepage (stub)
F-009: EmployeeCard (isolated)
F-010: WeeklyCalendar (isolated)
F-012: AnnouncementSection (isolated)
F-013: StatusCard (isolated)
```

Better approach: **port entire page compositions as a single unit**:
```
F-008: Homepage = HomePage + WeeklyCalendar + AnnouncementSection + StatusCard + NotificationPopup
→ All rendered together, all event handlers connected, tested as composition
```

**Implementation rule:** When porting a page-level feature, ALL child components shown in the source page MUST be included in the same leap, even if it means fewer features per leap. A page without its children is not "ported."

### 3. Require Page Composition Tests (not just unit tests)

For every page-level component, require an integration test that verifies ALL children render:

```tsx
// REQUIRED test for every page component
describe('HomePage — Page Composition', () => {
  it('renders WeeklyCalendar', () => {
    render(<HomePage />);
    expect(screen.getByTestId('weekly-calendar')).toBeInTheDocument();
  });
  
  it('renders AnnouncementSection', () => {
    render(<HomePage />);
    expect(screen.getByTestId('announcement-section')).toBeInTheDocument();
  });
  
  it('notification bell opens NotificationPopup on click', async () => {
    render(<HomePage />);
    await user.click(screen.getByTestId('notification-bell'));
    expect(screen.getByTestId('notification-popup')).toBeInTheDocument();
  });
  
  it('all navigation handlers are functional (no console.log placeholders)', () => {
    // Verify no console.log in onClick handlers
  });
});
```

**Add to skill:** Every page-level component must have a "composition test" file that tests parent-child integration. Test parity should count composition tests separately.

### 4. Add "Orphan Component" Detection to Phase 7

Add an automated scan that finds components never imported by any other file:

```
Phase 7 — Shift Checkpoint (addition)

Step 3b: Orphan Component Scan
- For every .tsx component file in src/ (excluding test files):
  - Check if any other non-test .tsx file imports it
  - If not imported anywhere → MUST-FIX item
  - Exception: App.tsx root, page-level components imported by router

If orphan components found → back to Phase 4c to wire them in.
```

### 5. Add "Placeholder Handler" Scan to Phase 7

Scan for non-functional event handlers:

```
Phase 7 — Shift Checkpoint (addition)

Step 3c: Placeholder Handler Scan
- grep -rn "console.log" src/ (excluding test files)
- grep -rn "// TODO\|// PLACEHOLDER\|() => {}" src/
- Any onClick/onSubmit/onChange handler that does nothing meaningful

If placeholder handlers found → MUST-FIX item.
```

### 6. Playwright Verification Per-Page (not per-project)

Current Phase 4b does a single pass verifying "pages render." This should be expanded:

```
Phase 4b — Cross-Worldline Verification (improved)

For EACH page in the app:
1. Navigate to the page
2. Take accessibility snapshot
3. Verify EVERY child component from source is present in snapshot
4. Click EVERY interactive element (buttons, links, tabs)
5. Verify each click produces the expected result (navigation, dialog, state change)
6. Compare against source feature inventory — every user action listed must work

Failure criteria:
- Button exists but does nothing → FAIL
- Component listed in source but missing from snapshot → FAIL  
- Navigation target returns 404 or blank page → FAIL
```

### 7. Redefine "Ported" vs "Integrated" vs "Verified"

Current parity matrix has: `not-started → in-progress → ported → verified`

Add an intermediate status:

```
not-started → in-progress → coded → integrated → verified

coded:      Component file exists, unit tests pass
integrated: Component is imported and rendered in its parent page,
            event handlers are functional, navigation works
verified:   Playwright confirms the feature works end-to-end in browser
```

A feature should only count toward parity % when it reaches "integrated" status, not "coded."

### 8. Source Reading Must Include Parent Context

When reading source for a feature, the skill should also read the **parent page that renders it** to understand integration requirements:

```
Current (insufficient):
  "Read announcement_section.dart" → port AnnouncementSection.tsx ✓

Should be:
  "Read announcement_section.dart" → understand the component
  "Read homepage.dart" → understand WHERE and HOW it's rendered
  → port AnnouncementSection.tsx AND update HomePage.tsx to render it
```

---

## Summary Table

| Problem | Current Skill Behavior | Proposed Fix |
|---------|----------------------|-------------|
| Components created but never wired | Port features in isolation, move forward | Add Phase 4c: Integration Wiring |
| Test parity masks real gaps | Unit tests per component | Require page composition tests |
| Pages port without children | Components are separate features | Port by page composition, not component |
| Placeholders never replaced | `console.log` passes all checks | Add placeholder handler scan |
| Orphan components undetected | No import-chain verification | Add orphan component scan |
| Playwright too shallow | "Does page render?" check only | Per-page, per-button verification |
| "Ported" counted too early | Component exists = ported | Add "integrated" status gate |
| Source read too narrow | Read only the component file | Read component + its parent page |

---

## Estimated Impact

If these improvements were applied to the Flutter → React PWA shift:

- **Issues #1-4 (Critical):** Would be caught by Phase 4c Integration Wiring
- **Issues #5-10 (High):** Would be caught by Orphan Component Scan + Page Composition Tests
- **Issues #11-12 (High):** Would be caught by improved Playwright per-page verification
- **Issues #13-15 (Medium):** Would be caught by Integration Wiring + parent context reading

All 15 issues were **preventable** with the proposed improvements. The fundamental insight is: **porting code is not the same as integrating code**, and the skill must verify integration, not just existence.
