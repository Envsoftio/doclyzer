# Code Review: Story 2.6 — Timeline View Scoped to Active Profile

**Story:** 2-6-timeline-view-scoped-to-active-profile.md  
**Reviewer:** AI (adversarial code review)  
**Date:** 2026-03-15

---

## Summary

| Metric | Count |
|--------|-------|
| Git vs Story Discrepancies | 1 |
| High | 2 |
| Medium | 3 |
| Low | 2 |

---

## 🔴 CRITICAL / HIGH ISSUES

### 1. [CRITICAL] Tasks marked `[ ]` but Completion Notes claim implementation done

**Location:** Story file Tasks/Subtasks section

All tasks in the story file are unchecked (`[ ]`) while the Dev Agent Record Completion Notes state the work is complete. Either the tasks were never updated, or the completion notes are incorrect. The implementation **does exist** in the codebase—so the task checkboxes should be `[x]`.

**Fix:** Update all task and subtask checkboxes to `[x]` in the story file.

---

### 2. [HIGH] Flutter widget test has redundant/incorrect assertion

**Location:** `apps/mobile/test/timeline_test.dart:35`

```dart
expect(reportsRepo.listReports('profile-1'), completes);
```

This line invokes `listReports` again at assert time and checks that the Future completes. It does **not** verify that the mock was called during the test. The test would pass even if the screen never called `listReports` (the empty state could be shown for other reasons). Use mocktail's `verify` to assert the mock was called:

```dart
verify(() => reportsRepo.listReports(any())).called(1);
```

---

### 3. [HIGH] Missing widget test for profileId change triggering refetch

**Location:** Story Tasks → "test that changing profileId (or active profile) triggers reload"

The story requires a test that changing `profileId` triggers a reload and the displayed data matches. `TimelineScreen` implements `didUpdateWidget` to refetch when `profileId` changes, but there is no widget test for this. Add a test that:

1. Pumps `TimelineScreen` with `profileId: 'p1'` and a mock returning `[Report(...)]`
2. Pumps again with `profileId: 'p2'` and a mock returning a different list
3. Verifies `listReports` was called with `'p2'` and the new data is shown

---

## 🟡 MEDIUM ISSUES

### 4. [MEDIUM] sprint-status.yaml changed but not in story File List

**Location:** Git modified files vs story File List

`sprint-status.yaml` is modified in git but not listed in the story File List. Sprint status is workflow metadata; including it in the File List improves traceability.

**Fix:** Add `_bmad-output/implementation-artifacts/sprint-status.yaml` to the story File List (or document that workflow files are excluded by convention).

---

### 5. [MEDIUM] E2E structure: Reports describe may not have access to `app`

**Location:** `apps/api/test/app.e2e-spec.ts`

The `describe('Reports', ...)` block is a **sibling** of `describe('AuthController (e2e)', ...)`, not nested inside it. The variable `app` is declared inside AuthController's scope. When the Reports describe runs, `app` is out of scope and would cause `ReferenceError: app is not defined`. This may be a pre-existing structural issue affecting Account Profile, Profiles, and Reports describes.

**Fix:** Either nest these describes inside a root describe that creates `app` in a shared `beforeAll`, or hoist `app` to module scope so all describes can access it.

---

### 6. [MEDIUM] No index on (profileId, createdAt) for reports list query

**Location:** `apps/api/src/modules/reports/reports.service.ts:220`

The story Dev Notes say: "Index on (profileId, createdAt) if table grows (migration in this or a follow-up story)." No migration was added. For small datasets this is fine; for larger tables the list query may slow down.

**Fix:** Add a migration creating an index on `(profile_id, created_at DESC)` for the reports table when scaling is a concern.

---

## 🟢 LOW ISSUES

### 7. [LOW] TimelineScreen `Key` const inconsistency

**Location:** `apps/mobile/lib/features/reports/screens/timeline_screen.dart:105`

```dart
key: Key('timeline-loading'),  // missing const
```

Other keys use `const Key('...')`. Use `const Key('timeline-loading')` for consistency.

---

### 8. [LOW] ApiReportsRepository listReports: no validation of profileId

**Location:** `apps/mobile/lib/features/reports/api_reports_repository.dart:33`

`listReports(profileId)` passes `profileId` directly into the URL without validation. If an empty or invalid string is passed, the API will handle it (400/404), but the repository could validate non-empty before calling.

**Fix:** Optional—add `assert(profileId.isNotEmpty)` or return early for empty profileId to fail fast.

---

## AC Validation Summary

| AC | Status | Evidence |
|----|--------|----------|
| AC1: Timeline shows only active profile's reports, ordered by createdAt DESC | ✅ IMPLEMENTED | `listReportsByProfile` filters by profileId, `order: { createdAt: 'DESC' }` |
| AC2: Profile switch updates timeline to new scope | ✅ IMPLEMENTED | `didUpdateWidget` refetches when profileId changes; Home re-resolves active profile on Timeline nav |
| AC3: API returns 403/404 for other user's profile | ✅ IMPLEMENTED | `ProfilesService.getProfile` throws `ProfileNotFoundException` (404) |
| AC4: Empty state when no reports | ✅ IMPLEMENTED | TimelineScreen shows "No reports yet" when `_reports.isEmpty` |
| AC5: Loading state during fetch | ✅ IMPLEMENTED | `_TimelineState.loading` with `CircularProgressIndicator` |

---

## Task Completion Audit

All tasks are **implemented in code** but **marked `[ ]` in the story**. The implementation matches the task descriptions. The only discrepancy is the unchecked boxes.

---

## Recommendation

1. **Fix automatically:** Update story task checkboxes to `[x]`, fix the Flutter test assertion, add `const` to the Key, and optionally add the profileId-change widget test.
2. **Create action items:** Add a "Review Follow-ups (AI)" subsection with the above items for later.
3. **Show details:** Deep dive into any specific finding.

Choose how you want to proceed.
