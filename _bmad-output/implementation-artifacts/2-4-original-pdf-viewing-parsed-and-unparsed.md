# Story 2.4: Original PDF Viewing (Parsed and Unparsed)

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As an authenticated user,
I want original file access always,
so that source documents remain available regardless of parse status.

## Acceptance Criteria

1. **Given** I am authenticated and own a report (any status: `parsed`, `unparsed`, `failed_terminal`, etc.)
   **When** I request the original file via `GET /reports/:id/file`
   **Then** the API returns the stored file bytes with `Content-Type` from the report (e.g. `application/pdf`) and `Content-Disposition: inline; filename="<originalFileName>"`
   **And** if the report does not exist or belongs to another user, I receive `404` with `{ success: false, code: "REPORT_NOT_FOUND", ... }`
   **And** the response body is the raw file (binary), not a JSON envelope

2. **Given** I am not authenticated (missing or invalid `Authorization` header)
   **When** I call `GET /reports/:id/file`
   **Then** I receive `401` with `{ success: false, code: "AUTH_UNAUTHORIZED", ... }`

3. **Given** I am on the Flutter app and viewing a report (from upload result or future timeline/detail)
   **When** I tap **View PDF** (or equivalent)
   **Then** the app fetches the file using the authenticated `GET /reports/:id/file` and displays the PDF in-app (e.g. PDF viewer) or opens it via platform handler
   **And** this works for both parsed and unparsed reports

4. **Given** the report’s file has been removed from storage (e.g. orphaned key)
   **When** I call `GET /reports/:id/file`
   **Then** the API returns `404` or `503` with a stable code (e.g. `REPORT_FILE_UNAVAILABLE`) so the client can show a clear message

## Tasks / Subtasks

- [x] Backend: GET /reports/:id/file (AC: 1, 2, 4)
  - [x] In `reports.service.ts` — add `getReportFile(userId: string, reportId: string): Promise<{ buffer: Buffer; contentType: string; originalFileName: string }>`:
    - Load report by id and userId; throw `ReportNotFoundException` if not found
    - Call `fileStorage.get(entity.originalFileStorageKey)`; on storage failure (e.g. key not found), throw a dedicated exception (e.g. `ReportFileUnavailableException`) or map to 503/404 with code `REPORT_FILE_UNAVAILABLE`
    - Return buffer + contentType + originalFileName (from entity)
  - [x] In `reports.controller.ts` — add `@Get(':id/file')` guarded by AuthGuard:
    - Use Nest `StreamableFile` (from `@nestjs/common`) with the buffer, or `@Res()` and `res.send(buffer)` with headers; set `Content-Type`, `Content-Disposition: inline; filename="..."` (escape filename for RFC 5987 if needed)
    - Do not wrap body in success envelope; response is raw binary
  - [x] Add `REPORT_FILE_UNAVAILABLE` (or equivalent) in `reports.types.ts` if used for 503/404

- [x] Flutter: repository and PDF viewing (AC: 3)
  - [x] In `reports_repository.dart` — add `Future<List<int>> getReportFile(String reportId)` (or equivalent that returns bytes)
  - [x] In `api_reports_repository.dart` — implement: `GET v1/reports/:id/file` with auth header; return response body bytes (real API only; no in-memory impl)
  - [x] Add an in-app PDF viewer: use a package such as `pdfx` or `syncfusion_flutter_pdfviewer` to display bytes, or write to temp file and use `open_file` / `url_launcher` for platform default. Prefer in-app viewer for consistent UX; document choice in Dev Notes
  - [x] Add **View PDF** action where report is shown (e.g. upload result screen when status is success or unparsed; later timeline in 2.6). Navigate to a PDF viewer screen or bottom sheet that loads and shows the file
  - [x] Widget keys: `Key('view-pdf-button')`, `Key('pdf-viewer-screen')` (or equivalent) for tests

- [x] Error handling (AC: 4)
  - [x] Backend: handle storage get failure (missing key / B2 error) and return 404 or 503 with `REPORT_FILE_UNAVAILABLE`
  - [x] Flutter: on 404/503 for file, show message e.g. "This report’s file is no longer available."

- [x] Tests
  - [x] `reports.service.spec.ts` — getReportFile: returns buffer + metadata for owner; throws ReportNotFoundException for non-owner/missing; throws or returns error for storage failure
  - [x] `reports.controller.spec.ts` — GET :id/file: returns stream/binary with correct headers for owner; 401 when unauthenticated; 404 when report not found
  - [x] E2E: GET /reports/:id/file with valid token + owned report → 200, body is PDF bytes, Content-Type application/pdf; non-existent → 404; no token → 401
  - [x] Flutter: widget test that "View PDF" triggers repository getReportFile and navigates to viewer (or opens file)

## Dev Notes

### Critical Architecture Notes

- **No JSON envelope for file:** `GET /reports/:id/file` returns raw binary. Do not use `successResponse()` for this route; use `StreamableFile` or raw `res.send(buffer)` with appropriate headers.
- **Ownership:** Reuse same ownership check as `getReport(userId, reportId)` — report must belong to userId. No public or share-link access in this story (share flow is Epic 3).
- **Storage:** `fileStorage.get(key)` already exists (Story 2.3). Use it; on failure (e.g. key not found), map to 404/503 and stable code so client can show "file unavailable".
- **Filename:** Use `report.originalFileName` for Content-Disposition. Sanitise or escape for RFC 5987 if needed (e.g. quotes in filename).

### API Contract

- `GET /reports/:id/file` — 200 OK, body = raw file bytes; headers: `Content-Type: <report.contentType>`, `Content-Disposition: inline; filename="<originalFileName>"`. 404 REPORT_NOT_FOUND if report missing/not owned; 404 or 503 REPORT_FILE_UNAVAILABLE if storage get fails; 401 if unauthenticated.

### Flutter

- **PDF viewer choice:** In-app: e.g. `pdfx` (from bytes) or save to temp file and open with `open_file`. Alternative: get a short-lived signed URL from backend and open in WebView/browser (not in scope for this story; stream-from-API is simpler and keeps auth on one place).
- **Where to show "View PDF":** Upload result screen (2.1/2.2/2.3) when report is present (parsed or unparsed). Timeline report cards (Story 2.6) will add the same action later; this story can add the action on the upload result screen and a reusable viewer route/screen.

### Project Structure (additions only)

- Extend `reports.service.ts`, `reports.controller.ts`, `reports.types.ts`.
- New exception optional: `ReportFileUnavailableException` (or use existing and map in controller).
- Flutter: extend `reports_repository.dart`, `api_reports_repository.dart`; add PDF viewer screen or bottom sheet; add "View PDF" on upload result (and optionally a minimal report detail placeholder).

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.4]
- [Source: _bmad-output/planning-artifacts/prd.md#FR15]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Unparsed – view PDF; Report detail (full summary, PDF view)]
- [Source: _bmad-output/implementation-artifacts/2-1-upload-report-to-active-profile.md]
- [Source: _bmad-output/implementation-artifacts/2-2-parsing-status-lifecycle-visibility.md]
- [Source: _bmad-output/implementation-artifacts/2-3-parse-failure-recovery-retry-keep-file-anyway.md]

## Technical Requirements

- `GET /reports/:id/file` protected by `@UseGuards(AuthGuard)`.
- Response is binary; do not log file contents; correlation ID can be set on response headers if desired (e.g. X-Correlation-Id).
- No PHI in logs; log only report id and outcome (success / not found / file unavailable).

## Architecture Compliance

- ADR: Strict ownership — only report owner can access file. No share-link access in this story.
- Use existing `ReportNotFoundException` for 404 when report missing or not owned.
- Optional: dedicated exception for storage failure (e.g. `ReportFileUnavailableException`) for 503/404 with code `REPORT_FILE_UNAVAILABLE`.

## Library / Framework Requirements

- Backend: NestJS, TypeScript. Use `StreamableFile` from `@nestjs/common` or Express `res.send(buffer)` with headers.
- Flutter: Add PDF viewer dependency (e.g. `pdfx` or `syncfusion_flutter_pdfviewer`); Material 3.

## Testing Requirements

- **Service:** getReportFile returns buffer + metadata for owner; throws for non-owner; throws or maps storage failure to REPORT_FILE_UNAVAILABLE.
- **Controller:** GET :id/file returns binary + Content-Type + Content-Disposition; 401/404/503 as specified.
- **E2E:** Valid token + owned report → 200, body is PDF, correct Content-Type; non-existent report → 404; no token → 401.
- **Flutter:** View PDF triggers getReportFile and shows viewer or opens file; widget keys for test.

## Previous Story Intelligence (2.1–2.3)

- **Report entity:** id, userId, profileId, originalFileName, contentType, sizeBytes, originalFileStorageKey, status. Storage has `get(key): Promise<Buffer>`.
- **GET /reports/:id** returns report metadata (JSON). No file endpoint yet.
- **Flutter:** upload_report_screen shows success or unparsed with "Keep file anyway"; no PDF view yet. Reports repository has upload, getReport, retryParse, keepFile.
- **Storage:** B2 and in-memory stub implement `get(key)`.

## Testing Notes (no in-memory)

- **Flutter:** Use real API (`ApiReportsRepository`). Widget tests use `MockReportsRepository` (mocktail) to stub `getReportFile`; no in-memory impl.

## Project Context Reference

- [Source: _bmad-output/project-context.md] — AuthGuard, response envelope (not used for binary response), error codes, PHI-safe logging.

## Story Completion Status

- Story implemented. Real API only; no in-memory impl. InMemoryReportsRepository removed.

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent.)

### Debug Log References

(To be filled by dev agent.)

### Completion Notes List

- API: Added `GET /reports/:id/file`; `getReportFile` in service; `ReportFileUnavailableException`; `StreamableFile` for binary response.
- Flutter: `ApiClient.getBytes()`; `getReportFile` in repository; `PdfViewerScreen` with pdfx; View PDF on success and parse-failure; removed InMemoryReportsRepository.
- Tests: Service, controller, E2E (real API), Flutter widget (MockReportsRepository).

### File List

- apps/api/src/modules/reports/reports.types.ts
- apps/api/src/modules/reports/exceptions/report-file-unavailable.exception.ts
- apps/api/src/modules/reports/reports.service.ts
- apps/api/src/modules/reports/reports.controller.ts
- apps/api/src/modules/reports/reports.service.spec.ts
- apps/api/src/modules/reports/reports.controller.spec.ts
- apps/api/test/app.e2e-spec.ts
- apps/mobile/lib/core/api_client.dart
- apps/mobile/lib/features/reports/reports_repository.dart
- apps/mobile/lib/features/reports/api_reports_repository.dart
- apps/mobile/lib/features/reports/screens/upload_report_screen.dart
- apps/mobile/lib/features/reports/screens/pdf_viewer_screen.dart
- apps/mobile/pubspec.yaml
- apps/mobile/test/upload_report_test.dart

## Change Log

| Date       | Author | Change |
|------------|--------|--------|
| 2026-03-13 | AI     | Story file created from epics.md and sprint-status (next story 2-4). |
| 2026-03-13 | AI     | Story implemented. Real API only; no in-memory; InMemoryReportsRepository removed. |
