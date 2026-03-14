# Story 2.5: Duplicate Report Detection and User Choice

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As an authenticated user,
I want duplicate detection with explicit choice,
so that accidental duplicates are reduced.

## Acceptance Criteria

1. **Given** I upload a file whose content matches an existing report in the same profile (same content hash)
   **When** the API detects the duplicate before creating a new report
   **Then** the API returns a deterministic response indicating a potential duplicate (e.g. HTTP 409 or 200 with a duplicate flag) including at least: existing report id, existing report metadata (e.g. originalFileName, createdAt) so the client can show "This looks like a duplicate of [report X]. Keep existing or upload anyway?"
   **And** no second report is created until the user explicitly chooses to upload anyway

2. **Given** a potential duplicate was detected and the client shows the choice
   **When** I choose **Keep existing**
   **Then** no new report is created; the client navigates or returns to the existing report (e.g. show existing report id / detail) and the outcome is consistent (no orphan uploads)

3. **Given** a potential duplicate was detected and the client shows the choice
   **When** I choose **Upload anyway**
   **Then** the API creates the new report as normal (same as current upload flow) and the choice is auditable (e.g. stored or logged without PHI: duplicate resolution = upload_anyway, existingReportId, timestamp)

4. **Given** I upload a file that does not match any existing report in the profile (by content hash)
   **When** upload completes
   **Then** behavior is unchanged from current flow: new report is created and 201 returned with report payload

5. **Given** duplicate detection runs
   **When** comparison is performed
   **Then** it is scoped to the same profile (same profileId); reports in other profiles do not trigger duplicate

## Tasks / Subtasks

- [x] Backend: content hash and duplicate check (AC: 1, 4, 5)
  - [x] Add `contentHash` (e.g. SHA-256 hex string) to Report entity; add migration (nullable initially for existing rows; backfill optional or leave null for old reports).
  - [x] In `reports.service.ts` before creating a new report: compute hash of file buffer (e.g. `crypto.createHash('sha256').update(buffer).digest('hex')`); query for existing report with same `profileId` and `contentHash`; if found, do not upload to storage or insert new row; return a structured duplicate response (see API contract below).
  - [x] When no duplicate: set `contentHash` on new entity and save as today. When duplicate and user later chooses "upload anyway", create report with same hash (allowed; duplicate check only blocks first creation until user confirms).
  - [x] Add error/response code e.g. `REPORT_DUPLICATE_DETECTED` in `reports.types.ts` and a DTO/shape for duplicate payload (existingReportId, existingFileName, existingCreatedAt, etc.).

- [x] Backend: upload-anyway path and audit (AC: 2, 3)
  - [x] Extend upload API to accept an optional parameter indicating "upload anyway" (e.g. query `?duplicateAction=upload_anyway` or body field when multipart). When present and request would have been a duplicate, skip duplicate response and proceed with normal upload; store the new report with same contentHash.
  - [x] Audit: when user uploads anyway, log or persist a minimal audit event (e.g. duplicateResolution: 'upload_anyway', existingReportId, newReportId, timestamp); no PHI in logs (project-context). If no audit table exists yet, logging with correlation ID and report ids is acceptable.

- [x] API contract
  - [x] `POST /reports` (no duplicate): 201, body = current success envelope with report (id, profileId, fileName, contentType, sizeBytes, status, etc.).
  - [x] `POST /reports` (duplicate detected, no override): 409 with body e.g. `{ success: false, code: 'REPORT_DUPLICATE_DETECTED', existingReport: { id, originalFileName, createdAt }, message: '...' }` (or 200 with duplicate flag per product preference; keep consistent).
  - [x] `POST /reports?duplicateAction=upload_anyway` (or equivalent): same as current upload; 201 with new report.

- [x] Flutter: duplicate UX (AC: 1, 2, 3)
  - [x] When upload returns duplicate response (409 or duplicate flag): show dialog/sheet "This report looks like a duplicate of [name/date]. [Keep existing] [Upload anyway]". Wire "Keep existing" to navigate to existing report (e.g. by existingReportId) or call existing getReport and show success state for that report; do not create a second report.
  - [x] Wire "Upload anyway" to retry upload with `duplicateAction=upload_anyway` (or equivalent), then show normal success for the new report.
  - [x] Widget keys for duplicate dialog: e.g. `Key('duplicate-dialog')`, `Key('duplicate-keep-existing')`, `Key('duplicate-upload-anyway')` for tests.

- [x] Tests
  - [x] Service: upload when same profile + same content hash returns duplicate info and does not save new report; upload when hash different or different profile creates report; upload with duplicateAction and same hash creates second report.
  - [x] Controller: 409 (or chosen contract) when duplicate; 201 with duplicateAction; 201 when no duplicate. Auth and validation unchanged.
  - [x] E2E: upload same file twice (same profile) → second request gets duplicate response; with duplicateAction → 201 and second report exists.
  - [x] Flutter: widget test that duplicate response shows dialog and "Upload anyway" triggers second request with override and shows success.

## Dev Notes

### Duplicate detection scope

- Scope: same `profileId`. Hash is per-file content (SHA-256 of buffer). Two reports in same profile with same hash → duplicate. Different profiles → not duplicate.
- Existing reports with null `contentHash` (e.g. from before this story): treat as no match (only new uploads get hash; optional backfill not required for MVP).

### API contract (summary)

- **POST /reports** (multipart file):
  - No duplicate: **201** + `successResponse({ reportId, profileId, fileName, contentType, sizeBytes, status })`.
  - Duplicate: **409** + `{ success: false, code: 'REPORT_DUPLICATE_DETECTED', existingReport: { id, originalFileName, createdAt }, message: '...' }`.
  - **POST /reports?duplicateAction=upload_anyway** (same file): always create; **201** + same success payload.
- Use standard error envelope (ApiExceptionFilter) for 409; include `existingReport` in response body for client to show "duplicate of X" and to navigate.

### Architecture and project rules

- **Idempotency:** Upload remains non-idempotent by design (each upload is a new report unless duplicate). Duplicate resolution is explicit user choice.
- **No PHI in logs:** Log only report ids, correlation id, and duplicate resolution action; no file names or hashes in plaintext if considered sensitive (hash is technical identifier).
- **Ownership:** Duplicate check uses same profile as upload (active profile); no cross-user or cross-profile match.

### Files to touch

- **API:** `report.entity.ts` (contentHash column), new migration; `reports.service.ts` (hash, duplicate check, upload-anyway); `reports.controller.ts` (query/body for duplicateAction); `reports.types.ts` (REPORT_DUPLICATE_DETECTED, duplicate response type); exception optional (e.g. `ReportDuplicateDetectedException` for 409).
- **Flutter:** `api_reports_repository.dart` (upload with optional duplicateAction; parse 409 and existingReport); `upload_report_screen.dart` (duplicate state, dialog, Keep existing / Upload anyway); possibly `reports_repository.dart` interface (e.g. uploadReport(path, { forceUploadAnyway: bool })).

### Previous story intelligence (2.1–2.4)

- Report entity: id, userId, profileId, originalFileName, contentType, sizeBytes, originalFileStorageKey, status. No contentHash yet.
- Upload flow: `ReportsService.uploadReport(userId, file)` → validate, generate reportId, storageKey, upload to B2, runParseStub, save entity, return DTO. Add hash computation and duplicate lookup before `fileStorage.upload`.
- Flutter: `reportsRepository.uploadReport(path)` returns `UploadedReport`; success/error state on upload screen; View PDF and retry/keep-file from 2.3/2.4. Add branch for duplicate response and dialog.
- Error handling: Use existing Nest exception pattern (e.g. ConflictException or custom exception with code REPORT_DUPLICATE_DETECTED) and standard envelope.

## Technical Requirements

- Hash algorithm: SHA-256 of raw file buffer; store hex string in `contentHash` (varchar, length 64).
- Migration: add column `content_hash` (nullable); no backfill required for existing rows.
- Controller: read `duplicateAction` from query or body (multipart form field); pass to service so service can skip duplicate check when user confirms upload anyway.

## Architecture Compliance

- ADR: Profile-scoped data; duplicate check respects profile boundary.
- Idempotency: Upload is not idempotent; duplicate handling is explicit user choice (keep existing vs upload anyway).
- Audit: Minimal audit trail for "upload anyway" (report ids + resolution + timestamp; no PHI in logs).

## Library / Framework Requirements

- Backend: Node `crypto` for SHA-256 (no new deps). NestJS, TypeORM as today.
- Flutter: No new packages required; use existing HTTP and navigation.

## Testing Requirements

- **Service:** Same-profile same-hash → duplicate response, no new row; different hash or different profile → new report; upload_anyway + same hash → new report created; hash set on new entities.
- **Controller:** 409 + existingReport for duplicate; 201 for normal and for upload_anyway; 401/400 as today.
- **E2E:** Two identical uploads (same user, same profile) → first 201, second 409; second with duplicateAction=upload_anyway → 201 and two reports for profile.
- **Flutter:** Duplicate response shows dialog; Keep existing and Upload anyway both behave as specified; widget keys for testability.

## Previous Story Intelligence (2.1–2.4)

- **2.1–2.3:** Upload, status lifecycle, retry/keep-file; Report entity and storage key pattern; B2 and in-memory storage interface.
- **2.4:** GET /reports/:id/file for PDF viewing; StreamableFile; no envelope for binary; ReportFileUnavailableException; Flutter PdfViewerScreen, getReportFile, View PDF on upload result.
- **Patterns:** Exception with `code` in response; successResponse envelope for JSON; repository uploadReport(path) returning UploadedReport; upload screen handles success/error and retry/keep-file.

## Project Context Reference

- [Source: _bmad-output/project-context.md] — AuthGuard, ConfigService, no process.env in modules, error codes in types file, PHI-safe logging, response envelope for JSON (not for file stream).

## References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.5]
- [Source: _bmad-output/planning-artifacts/epics.md#FR16]
- [Source: _bmad-output/implementation-artifacts/2-1-upload-report-to-active-profile.md]
- [Source: _bmad-output/implementation-artifacts/2-4-original-pdf-viewing-parsed-and-unparsed.md]

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent.)

### Debug Log References

(To be filled by dev agent.)

### Completion Notes List

- API: Report entity + contentHash (nullable); migration AddContentHashToReports; ReportsService.uploadReport computes SHA-256, finds duplicate by profileId+contentHash, throws ReportDuplicateDetectedException(409) with existingReport; optional options.duplicateAction=upload_anyway skips duplicate response and creates report; audit log on upload_anyway includes existingReportId and newReportId. Controller reads @Query('duplicateAction'). ApiExceptionFilter whitelists extra keys (existingReport) onto 409 response.
- Flutter: ApiClient.uploadFile(queryParams), ApiException.data; getBytes now passes body to ApiException. ReportsRepository.uploadReport(path, {forceUploadAnyway}); ApiReportsRepository passes duplicateAction query; UploadReportScreen duplicate state, dialog (Keep existing / Upload anyway), getReport on Keep existing, uploadReport(forceUploadAnyway: true) on Upload anyway; initialDuplicateExistingReport/initialDuplicatePendingPath for tests.
- Tests: Service 3 new tests (duplicate returns exception, upload_anyway creates report); controller 3 (duplicateAction param, 409); E2E 2 (same file 409, duplicateAction 201); Flutter widget test for duplicate dialog and Upload anyway. E2E global-setup runs migrations; if "relation reports does not exist" appears, check DATABASE_URL and data-source migration list.
- Code review fixes: Audit log now logs existingReportId + newReportId when upload_anyway; duplicate lookup always run (used for both throw and audit); ApiExceptionFilter whitelists allowed extra keys; getBytes passes body to ApiException; race condition documented as best-effort in comment.

### File List

- apps/api/src/common/api-exception.filter.ts
- apps/api/src/database/entities/report.entity.ts
- apps/api/src/database/migrations/1730813300000-AddContentHashToReports.ts
- apps/api/src/database/migrations/index.ts
- apps/api/src/modules/reports/reports.types.ts
- apps/api/src/modules/reports/exceptions/report-duplicate-detected.exception.ts
- apps/api/src/modules/reports/reports.service.ts
- apps/api/src/modules/reports/reports.controller.ts
- apps/api/src/modules/reports/reports.service.spec.ts
- apps/api/src/modules/reports/reports.controller.spec.ts
- apps/api/test/app.e2e-spec.ts
- apps/mobile/lib/core/api_client.dart
- apps/mobile/lib/features/reports/reports_repository.dart
- apps/mobile/lib/features/reports/api_reports_repository.dart
- apps/mobile/lib/features/reports/screens/upload_report_screen.dart
- apps/mobile/test/upload_report_test.dart

## Change Log

| Date       | Author | Change |
|------------|--------|--------|
| 2026-03-14 | AI     | Story implemented: duplicate detection (contentHash, 409 + existingReport), upload_anyway path, Flutter dialog and Keep existing / Upload anyway; tests added (service, controller, E2E, Flutter widget). |
