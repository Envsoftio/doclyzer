# Code Review: Story 2.3 — Parse Failure Recovery (Retry + Keep File Anyway)

**Story file:** `2-3-parse-failure-recovery-retry-keep-file-anyway.md`  
**Story key:** 2-3-parse-failure-recovery-retry-keep-file-anyway  
**Review date:** 2026-03-13  
**Review type:** Adversarial — validate ACs, task completion, and code quality.

---

## Git vs Story File List

- **Story File List:** 17 files (storage, config, reports module, Flutter reports feature, e2e).
- **Git status:** Story-related files match (reports.config.ts, reports module, storage changes, Flutter reports, upload_report_test.dart). No discrepancy — File List is accurate for 2.3 scope.

---

## Findings Summary

| Severity | Count |
|----------|--------|
| HIGH     | 0 (1 fixed during review) |
| MEDIUM   | 2     |
| LOW      | 1     |

---

## HIGH ISSUES

### 1. [FIXED] Flutter: Retry success leaves UI stuck on "Reading report…"

**Location:** `apps/mobile/lib/features/reports/screens/upload_report_screen.dart` — `_onRetry()`

**Issue:** After a successful `retryParse()` the code updated `_result` in `setState` but never set `_state = _UploadState.success`. The UI stayed in `_UploadState.reading`, so the user saw "Reading report…" indefinitely instead of success or parse-failure.

**Fix applied:** In the success branch of `_onRetry()`, added `_state = _UploadState.success` inside the same `setState` so the UI re-renders correctly (success or parse-failure based on new `_result.status`).

---

## MEDIUM ISSUES

### 2. Controller spec does not verify 404/400 propagation for retry and keep-file

**Location:** `apps/api/src/modules/reports/reports.controller.spec.ts`

**Story task:** "POST :id/retry and POST :id/keep-file delegate; 401 when unauthenticated; 404 when not found; 400 when already parsed"

**Current state:** Only happy-path tests — "delegates to service and returns success envelope". No tests that mock `ReportNotFoundException` (404) or `BadRequestException` with `REPORT_ALREADY_PARSED` (400) and assert the controller propagates them.

**Required change:** Add tests that mock `reportsService.retryParse` / `keepFile` to throw `ReportNotFoundException` and assert 404 response; mock to throw `BadRequestException` with code `REPORT_ALREADY_PARSED` and assert 400 response.

---

### 3. Flutter widget test does not assert Retry triggers repository

**Location:** `apps/mobile/test/upload_report_test.dart`

**Story task:** "Retry triggers repository call; Keep file triggers repository + onComplete"

**Current state:** Test only taps "Keep file anyway" and asserts `onCompleteCalled`. It does not tap "Retry" or verify `reportsRepo.retryParse` was called.

**Required change:** Add a test (or extend the existing one) that taps `parse-failure-retry`, then assert `reportsRepo.retryParse` was called with the correct report id (e.g. using `verify(() => reportsRepo.retryParse(any())).called(1)` or equivalent).

---

## LOW ISSUES

### 4. Force-unwrap in production Flutter code

**Location:** `apps/mobile/lib/features/reports/screens/upload_report_screen.dart`

**Project context:** "No force-unwrap `!` in production code — always handle null explicitly."

**Current state:** `_result!` is used in `_isParseFailure()`, `_onRetry()`, `_onKeepFile()`, and `_buildSuccess()`. In these paths `_result` is only null when we haven’t reached that state (e.g. parse-failure UI is only shown when `_result != null`), but the linter/style rule asks to avoid `!`.

**Suggestion:** Use early returns or local variables, e.g. `final r = _result; if (r == null) return;` then use `r` instead of `_result!`, to satisfy the project rule without changing behavior.

---

---

## Acceptance Criteria Verification

| AC | Status | Evidence |
|----|--------|----------|
| 1. POST /reports/:id/retry re-fetches, re-parses, returns report; 404 not found/not owned; 400 when parsed | IMPLEMENTED | reports.service.ts retryParse: getReport ownership, throwIfAlreadyParsed, fileStorage.get(), runParseStub(buffer, true), save; controller POST ':id/retry' |
| 2. POST /reports/:id/keep-file sets unparsed, idempotent, 404/400 | IMPLEMENTED | keepFile(): throwIfAlreadyParsed, entity.status = 'unparsed', save |
| 3. Flutter parse-failure UI + Retry + Keep file anyway | IMPLEMENTED | upload_report_screen: _buildParseFailure(), retryParse/keepFile in repo, keys present; bug (stuck on reading) fixed |
| 4. 401 when unauthenticated | IMPLEMENTED | Controller @UseGuards(AuthGuard) at class level |
| 5. Parser unavailable: status terminal, file kept, no delete | IMPLEMENTED | retryParse does not delete file; runParseStub returns unparsed on stub failure |

---

## Outcome

**Changes requested.** One HIGH issue was fixed during review (Flutter retry state). Two MEDIUM issues remain: controller spec 404/400 tests and Flutter test for Retry triggering repository. Two LOW items: reduce `!` usage in Flutter (optional), no change on keep-file await.

**Recommendation:** Address MEDIUM items (controller tests and Retry widget test), then mark story done or in-progress per your workflow.

**Update (2026-03-13):** All MEDIUM and LOW items fixed automatically: controller spec now has 404/400 propagation tests for retry and keep-file; widget test "Tapping Retry calls retryParse on repository" added; Flutter force-unwrap removed (local `r` after null check). Story status → done.
