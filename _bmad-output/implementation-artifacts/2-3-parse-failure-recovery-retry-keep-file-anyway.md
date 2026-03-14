# Story 2.3: Parse Failure Recovery (Retry + Keep File Anyway)

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As an authenticated user,
I want retry and keep-file options when parsing fails,
so that failed parsing does not block usage and I can recover or accept the file as-is.

## Acceptance Criteria

1. **Given** a report has status `unparsed` or `failed_terminal` (parser could not read the format)
   **When** I call `POST /reports/:id/retry` for a report I own
   **Then** the API re-fetches the file from storage and re-runs the parser
   **And** returns the updated report with `status` (`parsed` or `unparsed`/`failed_terminal`) in the standard success envelope
   **And** if the report does not exist or belongs to another user, I receive `404` with `{ success: false, code: "REPORT_NOT_FOUND", ... }`
   **And** if the report status is `parsed`, the API returns `400` with a stable code (e.g. `REPORT_ALREADY_PARSED`) — nothing to retry

2. **Given** a report has status `unparsed`, `failed_transient`, or `failed_terminal`
   **When** I call `POST /reports/:id/keep-file` for a report I own
   **Then** the API sets the report status to `unparsed` (user accepts file-only)
   **And** returns the updated report in the standard success envelope
   **And** the operation is idempotent when status is already `unparsed`
   **And** if the report does not exist or belongs to another user, I receive `404` with `REPORT_NOT_FOUND`
   **And** if the report status is `parsed`, the API returns `400` with a stable code (e.g. `REPORT_ALREADY_PARSED`) — nothing to keep

3. **Given** I am on the Flutter app and a report has status `unparsed` or `failed_terminal`
   **When** I view the upload result or report detail
   **Then** the UI shows **We couldn't read this format. Your file is saved.**
   **And** displays two actions: **Retry** and **Keep file anyway**
   **And** **Retry** calls `POST /reports/:id/retry` and shows progress ("Reading report…") until response
   **And** **Keep file anyway** calls `POST /reports/:id/keep-file` (or is a no-op if already `unparsed`) and navigates to timeline / report card showing "Unparsed – View PDF"

4. **Given** I am not authenticated (missing or invalid `Authorization` header)
   **When** I call `POST /reports/:id/retry` or `POST /reports/:id/keep-file`
   **Then** I receive `401` with `{ success: false, code: "AUTH_UNAUTHORIZED", ... }`

5. **Given** the parser is unavailable or times out during retry
   **When** `POST /reports/:id/retry` runs
   **Then** the report status remains or is set to `unparsed` or `failed_terminal`
   **And** the file stays in storage (no deletion)
   **And** the API returns the report with terminal status; user can retry again or choose Keep file anyway

## Tasks / Subtasks

- [x] Add retry and keep-file API endpoints (AC: 1, 2, 4, 5)
  - [x] In `reports.types.ts` — add `REPORT_ALREADY_PARSED` error code
  - [x] In `reports.service.ts` — add `retryParse(userId: string, reportId: string): Promise<ReportDto>`:
    - Load report; verify ownership; throw `ReportNotFoundException` if not found
    - If status is `parsed`, throw `BadRequestException` with `REPORT_ALREADY_PARSED`
    - Fetch file from storage via `fileStorage.get()` or equivalent (stream/buffer)
    - Invoke parse (stub or Docling); update status to `parsed` or `unparsed`/`failed_terminal`
    - On parse failure: set `unparsed` or `failed_terminal`; keep file; return report
  - [x] In `reports.service.ts` — add `keepFile(userId: string, reportId: string): Promise<ReportDto>`:
    - Load report; verify ownership; throw if not found
    - If status is `parsed`, throw `BadRequestException` with `REPORT_ALREADY_PARSED`
    - Set status to `unparsed`; save; return report (idempotent if already `unparsed`)
  - [x] In `reports.controller.ts` — add `@Post(':id/retry')` and `@Post(':id/keep-file')` protected by AuthGuard; delegate to service; return `successResponse(report, getCorrelationId(req))`

- [x] Ensure file storage supports read (AC: 1, 5)
  - [x] In `file-storage.interface.ts` — add `get(storageKey: string): Promise<Buffer>` to interface
  - [x] Implement in `B2FileStorageService` and `InMemoryFileStorageService`; used by retry to re-parse

- [x] Flutter: retry and keep-file actions (AC: 3)
  - [x] In `reports_repository.dart` — add `Future<Report> retryParse(String reportId)` and `Future<Report> keepFile(String reportId)`
  - [x] In `api_reports_repository.dart` — implement via `POST v1/reports/:id/retry` and `POST v1/reports/:id/keep-file`
  - [x] In `upload_report_screen.dart` — when `_result?.status` is `unparsed` or `failed_terminal`, show parse-failure UI: "We couldn't read this format. Your file is saved." + Retry + Keep file anyway
  - [x] Retry: call `retryParse(reportId)`; show "Reading report…"; on success, update `_result` and show success; on failure, keep parse-failure UI
  - [x] Keep file anyway: call `keepFile(reportId)` (or skip if already `unparsed`); call `onComplete()` to return to timeline
  - [x] Widget keys: `Key('parse-failure-retry')`, `Key('parse-failure-keep-file')`, `Key('parse-failure-message')`

- [x] Report detail / card parse-failure UI (AC: 3)
  - [x] For this story, focus on upload result screen; timeline report cards (Story 2.6) will reuse the same pattern

- [x] Unit and E2E tests (AC: 1, 2, 4, 5)
  - [x] `reports.service.spec.ts` — retryParse: returns updated report for owner; throws for non-owner; throws REPORT_ALREADY_PARSED when parsed; keeps file on parse failure
  - [x] `reports.service.spec.ts` — keepFile: sets unparsed for owner; idempotent when already unparsed; throws for parsed report
  - [x] `reports.controller.spec.ts` — POST :id/retry and POST :id/keep-file delegate; 401 when unauthenticated; 404 when not found; 400 when already parsed
  - [x] E2E: POST /reports/:id/retry and POST /reports/:id/keep-file with valid token + owned report → 200; non-existent → 404; no token → 401; parsed report → 400

- [x] Flutter widget tests (AC: 3)
  - [x] Upload result with status `unparsed`: displays "We couldn't read this format" + Retry + Keep file anyway; Keep file triggers repository + onComplete

## Dev Notes

### Critical Architecture Notes

- **Retry = re-parse from storage:** Do not re-upload the file. Fetch from B2 using `originalFileStorageKey`, run parser again. Avoids duplicate uploads and keeps storage as source of truth.
- **Keep file anyway = explicit user acceptance:** Sets status to `unparsed` so UI can hide retry prompts and show "Unparsed – View PDF" (Story 2.4 adds PDF viewing).
- **Parser stub:** If Docling not wired, extend the stub to support configurable failure (e.g. env flag or round-robin) so retry/keep flows are testable. Story 2.2 may have already done this.
- **Storage read:** Story 0.5 added upload/delete; ensure `get` or equivalent exists for retry. If not, add to the storage interface and both implementations.

### API Contract

- `POST /reports/:id/retry` — 200 OK, body: `{ success: true, data: Report, correlationId }`. 404 REPORT_NOT_FOUND if not found or not owned. 400 REPORT_ALREADY_PARSED if status is `parsed`. 401 if unauthenticated.
- `POST /reports/:id/keep-file` — 200 OK, body: `{ success: true, data: Report, correlationId }`. Same error semantics. Idempotent when status already `unparsed`.

### Flutter

- **Parse-failure state:** Distinct from generic upload error. Upload error = network/4xx, no report created. Parse failure = report exists, status `unparsed` or `failed_terminal`.
- **Keep file anyway:** Can be no-op (just navigate) if status is already `unparsed` and we don't need to persist "user confirmed". For consistency and audit, calling the API is preferred so backend records the transition.

### Project Structure (additions only)

- Extend `reports.service.ts`, `reports.controller.ts`, `reports.types.ts` from Story 2.1/2.2.
- Extend `file-storage.interface.ts` and implementations if `get` is missing.
- Flutter: extend `reports_repository.dart`, `api_reports_repository.dart`, `upload_report_screen.dart`.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.3]
- [Source: _bmad-output/planning-artifacts/prd.md#FR13, FR14; Parse reliability; Keep file anyway]
- [Source: _bmad-output/planning-artifacts/product-brief-doclyzer-2026-03-01.md#Fail recovery, Retry, Keep file anyway]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Parse failure, Upload flow]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX3, Dependency Degradation]
- [Source: _bmad-output/implementation-artifacts/2-1-upload-report-to-active-profile.md]
- [Source: _bmad-output/implementation-artifacts/2-2-parsing-status-lifecycle-visibility.md]

## Technical Requirements

- `POST /reports/:id/retry` and `POST /reports/:id/keep-file` protected by `@UseGuards(AuthGuard)`.
- Storage interface must support reading file by key for retry flow.
- No PHI in logs; correlation ID in responses.

## Architecture Compliance

- ADR-CX2: State Transparency — deterministic status transitions.
- ADR-CX3: Dependency Degradation — parser failure does not block file access; Keep file anyway preserves baseline.
- `ReportNotFoundException` for 404; `BadRequestException` with `REPORT_ALREADY_PARSED` for invalid retry/keep.

## Library / Framework Requirements

- Backend: NestJS, TypeScript (no new deps).
- Flutter: Material 3; reuse existing patterns.

## Testing Requirements

- **Service:** retryParse and keepFile return for owner; throw for non-owner; throw REPORT_ALREADY_PARSED when parsed; retry keeps file on parse failure.
- **Controller:** POST delegates; 401/404/400 propagate.
- **E2E:** Valid token + owned report → 200; non-existent → 404; no token → 401; parsed report → 400.
- **Flutter:** Parse-failure UI with Retry and Keep file anyway; widget keys for tests.

## Previous Story Intelligence (2.1, 2.2)

- **Report entity** has `status`, `originalFileStorageKey`. Full enum: `uploading` | `queued` | `parsing` | `parsed` | `unparsed` | `failed_transient` | `failed_terminal`.
- **POST /reports** returns report with status; sync stub currently sets `parsed`. For 2.3, parser must be able to produce `unparsed` or `failed_terminal` (configurable stub or real parser).
- **GET /reports/:id** returns report; used for polling in async flow.
- **Flutter** has `upload_report_screen.dart`, `reports_repository.dart`, `api_reports_repository.dart`. Upload result shows success or generic error; 2.2 added status display. 2.3 adds parse-failure branch with Retry + Keep file anyway.
- **Storage:** B2 and in-memory implementations; ensure `get` exists for retry.

## Project Context Reference

- [Source: _bmad-output/project-context.md] — AuthGuard, response envelope, error codes, PHI-safe logging, require-await.

## Story Completion Status

- Story context file generated with implementation guardrails and testing standards.
- Ready for `dev-story` execution after Story 2.2.

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent.)

### Debug Log References

(To be filled by dev agent.)

### Completion Notes List

- Storage: Added `get(key)` to FileStorageService interface; implemented in B2 and InMemory.
- API: Added `POST /reports/:id/retry` and `POST /reports/:id/keep-file`; `REPORT_ALREADY_PARSED` error code
- Config: Added `reports.config.ts` with `parseStubFail` and `parseStubRetrySucceeds` for testing
- Flutter: Parse-failure UI on upload result; Retry and Keep file anyway; `initialReport` for widget tests
- E2E: Added "Reports retry and keep-file" describe with PARSE_STUB_FAIL; main e2e may need DB migrations for reports table

### File List

- apps/api/src/common/storage/file-storage.interface.ts
- apps/api/src/common/storage/file-storage.types.ts
- apps/api/src/common/storage/b2-file-storage.service.ts
- apps/api/src/common/storage/in-memory-file-storage.service.ts
- apps/api/src/config/reports.config.ts
- apps/api/src/app.module.ts
- apps/api/src/modules/reports/reports.types.ts
- apps/api/src/modules/reports/reports.service.ts
- apps/api/src/modules/reports/reports.controller.ts
- apps/api/src/modules/reports/reports.service.spec.ts
- apps/api/src/modules/reports/reports.controller.spec.ts
- apps/api/test/app.e2e-spec.ts
- apps/mobile/lib/features/reports/reports_repository.dart
- apps/mobile/lib/features/reports/api_reports_repository.dart
- apps/mobile/lib/features/reports/in_memory_reports_repository.dart
- apps/mobile/lib/features/reports/screens/upload_report_screen.dart
- apps/mobile/test/upload_report_test.dart

## Senior Developer Review (AI)

**Reviewer:** Vishnu (AI)  
**Date:** 2026-03-13  
**Report:** [_bmad-output/implementation-artifacts/code-review-2-3-parse-failure-recovery.md](code-review-2-3-parse-failure-recovery.md)

**Summary:** Adversarial review of Story 2.3. One HIGH bug fixed during review: Flutter `_onRetry()` did not set `_state = _UploadState.success` after successful retry, leaving the UI stuck on "Reading report…". Fix applied in `upload_report_screen.dart`.

**Remaining:** 2 MEDIUM (controller spec 404/400 tests; widget test for Retry calling repository), 1 LOW (reduce `!` in Flutter per project context). ACs verified implemented.

**Outcome:** Changes requested. Status set to in-progress until MEDIUM items are addressed.

**Follow-up (auto-fix):** Controller spec 404/400 tests added for retry and keep-file; widget test added for Retry calling `retryParse`; Flutter `_result!` replaced with local null checks. Status → done.

## Change Log

| Date       | Author | Change |
|------------|--------|--------|
| 2026-03-13 | AI     | Code review: HIGH fix (retry state); MEDIUM/LOW findings documented; status → in-progress |
| 2026-03-13 | AI     | Auto-fix: controller 404/400 tests; Retry widget test; remove force-unwrap; status → done |
