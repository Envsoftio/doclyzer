# Code Review: Epic 2 Stories 2.1–2.4 (All)

**Stories reviewed:** 2-1–upload-report–2-4–original-pdf-viewing  
**Review date:** 2026-03-13  
**Review type:** Adversarial — validate ACs, task completion, and code quality across all four stories.

---

## Git vs Story Discrepancies

| Story | Files in story File List | Files in git | Discrepancy |
|-------|--------------------------|--------------|-------------|
| 2.1 | Only story file + sprint-status.yaml — **no app code** | report.entity, reports module, migrations, storage, mobile | **CRITICAL** — Story claims done but File List is empty; all tasks unchecked |
| 2.2 | "To be filled by dev agent" — empty | Same reports module as 2.1 | **CRITICAL** — Story claims done but no File List; all tasks unchecked |
| 2.3 | 17 files — comprehensive | Matches | None |
| 2.4 | 14 files — comprehensive | Matches | None |

**Files changed in git but not in any story File List:**
- `.github/workflows/ci.yml`
- `apps/api/src/database/data-source.ts`
- `apps/api/src/database/migrations/index.ts`
- `apps/mobile/lib/features/auth/*` (home_screen, login_screen, api_auth_repository)
- `apps/mobile/lib/main.dart`
- `apps/mobile/pubspec.lock`, `pubspec.yaml`
- `apps/mobile/test/mocks.dart`, `widget_test.dart`
- `apps/api/src/modules/account/account.service.spec.ts`
- `apps/api/src/modules/profiles/profiles.module.ts`, `profiles.service.ts`
- `apps/api/test/app.e2e-spec.ts` (shared)

---

## Findings Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 4 |
| HIGH     | 4 |
| MEDIUM   | 5 |
| LOW      | 3 |

---

## CRITICAL ISSUES

### 1. Story 2.1: Status "done" but File List is empty; all tasks unchecked

**Location:** `_bmad-output/implementation-artifacts/2-1-upload-report-to-active-profile.md`

**Issue:** Story claims Status: done but:
- Every task is `- [ ]` (unchecked)
- File List contains only: story file + sprint-status.yaml — **no app code**
- Senior Developer Review says "Story not implemented" — outdated

**Evidence:** Implementation exists in git (report.entity, reports module, migrations, storage, mobile upload flow). The story was never updated after implementation.

**Required:** Update story File List with all app files; check off completed tasks; update Senior Developer Review.

---

### 2. Story 2.2: Status "done" but File List empty; all tasks unchecked

**Location:** `_bmad-output/implementation-artifacts/2-2-parsing-status-lifecycle-visibility.md`

**Issue:** File List: "To be filled by dev agent" — empty. All tasks unchecked. Story claims done.

**Evidence:** GET /reports/:id, parse stub, status enum, Flutter status display all implemented. Story never updated.

**Required:** Update story File List; check off completed tasks; add Dev Agent Record.

---

### 3. E2E: Retry/keep-file 401 tests are broken — nested `it()` never runs

**Location:** `apps/api/test/app.e2e-spec.ts` lines 789–828

**Issue:** The first `it('POST /reports/:id/retry without token → 401 ...')` wraps multiple nested `it()` calls. The outer `it` callback never actually runs the inner tests — they are never executed. Same for keep-file 401, retry 404, retry 400.

```javascript
it('POST /reports/:id/retry without token → 401 AUTH_UNAUTHORIZED', async () => {
  it('POST /reports/:id/retry without token → 401 ...', async () => { ... });  // WRONG
  it('POST /reports/:id/keep-file without token → 401 ...', async () => { ... });
  it('POST /reports/:id/retry for non-existent report → 404 ...', async () => { ... });
  it('POST /reports/:id/retry for already parsed report → 400 ...', async () => { ... });
});
```

**Required:** Flatten — each `it()` must be a top-level (or sibling) test. Remove the outer wrapper.

---

### 4. Controller: Hardcoded error code instead of constant

**Location:** `apps/api/src/modules/reports/reports.controller.ts` line 67

**Issue:** `code: 'REPORT_FILE_REQUIRED'` is hardcoded. Project context: "Error codes are screaming snake case constants — never inline string codes; define constants in the module's types file."

**Required:** Import `REPORT_FILE_REQUIRED` from `reports.types` and use it.

---

## HIGH ISSUES

### 5. Flutter: Retry failure shows no error to user

**Location:** `apps/mobile/lib/features/reports/screens/upload_report_screen.dart` — `_onRetry()` catch block

**Issue:** When `retryParse()` throws (network error, 500, etc.), the catch block does:
```dart
} catch (_) {
  if (mounted) setState(() => _state = _UploadState.success);
}
```
The UI stays on parse-failure (because `_isParseFailure()` is true) but the user gets no feedback that retry failed. They might think nothing happened.

**AC 3:** "Retry calls POST /reports/:id/retry and shows progress until response" — on failure, user should see an error.

**Required:** Set `_errorMessage` and show it in parse-failure UI, or add a retry-specific error state.

---

### 6. ApiClient.getBytes: Error envelope shape mismatch

**Location:** `apps/mobile/lib/core/api_client.dart` — `getBytes()` lines 72–80

**Issue:** On error, it parses `body['error']` for `code` and `message`. The API returns `{ success: false, error: { code, message } }` — correct. But `_handleResponse` uses `body['error']` — the API exception filter returns `error` in the envelope. So this should work. Let me double-check...

Actually the API response from ApiExceptionFilter is `{ success: false, error: { code, message }, correlationId }`. So `body['error']` is correct. But wait — the error might be nested differently. Let me check the filter again...

From api-exception.filter: `error: { code, message }`. So `body.error` is correct. The getBytes uses `body['error']` — same. So this might be OK. I'll downgrade to LOW or remove — the ApiClient uses `error` key. Actually the standard envelope in project-context says `{ success: false, code: "...", message: "..." }` — let me check. The filter returns `error: { code, message }`. So `body.error.code` and `body.error.message` are correct. I'll remove this as a finding.

Actually looking again: the Flutter uses `body['error']` — in Dart that's `body['error']`. The API returns `{ "success": false, "error": { "code": "...", "message": "..." } }`. So `body['error']` gives the error object. Good. I'll leave this out.

---

### 7. Content-Disposition: filename not RFC 5987 encoded for special chars

**Location:** `apps/api/src/modules/reports/reports.controller.ts` — `getReportFile` lines 91–95

**Issue:** `originalFileName.replace(/[^\w.-]/g, '_')` strips special chars but doesn't handle filename* for RFC 5987. Story 2.4 says "Sanitise or escape for RFC 5987 if needed (e.g. quotes in filename)."

**Risk:** Filenames with non-ASCII or quotes could break or be unsafe. Current sanitization is minimal.

**Required:** Either document that sanitization is sufficient for MVP, or add proper RFC 5987 encoding for filename* parameter when needed.

---

### 8. Report entity: missing `failed_transient` in retryParse path

**Location:** `apps/api/src/modules/reports/reports.service.ts` — `runParseStub`

**Issue:** Story 2.2 says status enum includes `failed_transient`. The stub only returns `parsed` or `unparsed`. No `failed_transient` or `failed_terminal` from the stub. For retry-on-failure, we set `unparsed`. AC 5 says "status remains or is set to unparsed or failed_terminal" — so `unparsed` is acceptable. OK.

---

## MEDIUM ISSUES

### 9. Story 2.1: POST response uses `reportId` but entity uses `id`

**Location:** API returns `reportId` in upload response; entity has `id`. The service returns `reportId`, which matches. Good.

---

### 10. Upload flow: "Uploading…" shown too briefly

**Location:** `apps/mobile/lib/features/reports/screens/upload_report_screen.dart` — `_pickAndUpload`

**Issue:** `setState(() => _state = _UploadState.uploading)` then immediately `setState(() => _state = _UploadState.reading)` before the `await`:
```dart
setState(() {
  _state = _UploadState.uploading;
  _errorMessage = null;
});
try {
  setState(() => _state = _UploadState.reading);  // Immediately overwrites!
  final report = await widget.reportsRepository.uploadReport(path);
```

So "Uploading…" is never shown — we jump straight to "Reading report…". AC 4: "Uploading… during network transfer and Reading report… once the server acknowledges upload."

**Required:** Only set `_UploadState.reading` after the upload completes (or when the server starts processing). For sync upload+parse, the server doesn't distinguish — so we could show "Uploading…" until the request completes, then "Reading report…" briefly. Or show "Uploading…" for the whole request, then "Reading report…" only if we had async. Simpler: show "Uploading…" until the request completes. If upload and parse are one request, we can't distinguish. So we show "Uploading…" during the request and "Reading report…" only when we have a response. Actually the flow is: set uploading, then set reading, then await. So we show reading for the whole request. The upload happens inside uploadReport. So we never show "Uploading…" — we show "Reading report…" for the whole thing. That's a MEDIUM UX issue — user doesn't see "Uploading…" at all.

---

### 11. E2E: Reports config uses process.env — may not load in tests

**Location:** `apps/api/src/config/reports.config.ts` — uses `process.env.PARSE_STUB_FAIL`

**Issue:** ConfigModule loads this. In e2e, `process.env.PARSE_STUB_FAIL = 'true'` is set before creating the app. The config is loaded at module init, so it should work. The retry e2e tests use a separate app with PARSE_STUB_FAIL. Good.

---

### 12. No E2E for GET /reports/:id/file with REPORT_FILE_UNAVAILABLE

**Location:** `apps/api/test/app.e2e-spec.ts`

**Issue:** Story 2.4 AC 4: "When file has been removed from storage, API returns 404 or 503 with REPORT_FILE_UNAVAILABLE." No e2e test for this — would require stubbing storage to fail.

**Required:** Add e2e with mocked storage that throws on get, or document as out-of-scope for e2e.

---

### 13. PdfViewerScreen: no Key on loading/error states

**Location:** `apps/mobile/lib/features/reports/screens/pdf_viewer_screen.dart`

**Issue:** Story 2.4: "Widget keys: Key('view-pdf-button'), Key('pdf-viewer-screen')". The PdfViewPinch has `Key('pdf-viewer-screen')`. Loading and error states have no keys — harder to test.

**Required:** Add keys for loading and error states if widget tests need them.

---

## LOW ISSUES

### 14. reports.types: ReportStatus re-exported from entity

**Location:** `apps/api/src/modules/reports/reports.types.ts` — `import type { ReportStatus } from '../../database/entities/report.entity'`

**Issue:** Story 2.2 says "Report status enum exported from reports.types.ts". Currently it's re-exported from entity. Fine for consistency.

---

### 15. Flutter: UploadedReport uses reportId, Report uses id

**Location:** `reports_repository.dart` — UploadedReport.reportId vs Report.id

**Issue:** Minor inconsistency — API returns reportId in upload, id in GET. Both refer to the same report. Acceptable.

---

### 16. PHI-safe logging: report id in getReportFile warning

**Location:** `apps/api/src/modules/reports/reports.service.ts` line 166

**Issue:** `this.logger.warn(\`Report ${reportId}: file unavailable...\`)` — report ID is logged. Project context: "never log user IDs". Report ID is a UUID, not necessarily PHI, but could be considered. Conservative: use correlation ID only.

---

## Acceptance Criteria Verification (Summary)

| Story | AC | Status |
|-------|-----|--------|
| 2.1 | 1–4 | IMPLEMENTED |
| 2.2 | 1–5 | IMPLEMENTED |
| 2.3 | 1–5 | IMPLEMENTED (see code-review-2-3) |
| 2.4 | 1–4 | IMPLEMENTED |

---

## Recommended Actions (all addressed)

1. ~~**Fix E2E test structure** (CRITICAL)~~ — Done: flattened nested `it()` in Reports describe.
2. ~~**Fix controller**~~ — Done: use REPORT_FILE_REQUIRED constant.
3. ~~**Update stories 2.1 and 2.2**~~ — Done: File List, task checkboxes, Dev Agent Record / Completion Notes.
4. ~~**Flutter retry failure**~~ — Done: show _errorMessage in parse-failure UI when retry fails.
5. ~~**Upload flow UX**~~ — Done: show "Uploading…" for the whole request (removed premature switch to reading).
6. ~~**E2E REPORT_FILE_UNAVAILABLE**~~ — Done: added test that deletes file from storage then GET file → 503.
7. ~~**Content-Disposition RFC 5987**~~ — Done: added filename*=UTF-8'' for non-ASCII filenames.
8. ~~**PdfViewerScreen keys**~~ — Done: Key('pdf-viewer-loading'), Key('pdf-viewer-error').
9. ~~**PHI logging**~~ — Done: removed reportId from getReportFile warning log.

---

## Outcome

**Fixes applied.** Story docs (2.1, 2.2), E2E structure, controller constant, Flutter retry error display, upload progress, REPORT_FILE_UNAVAILABLE e2e, Content-Disposition, PdfViewerScreen keys, and PHI-safe logging have been addressed.
