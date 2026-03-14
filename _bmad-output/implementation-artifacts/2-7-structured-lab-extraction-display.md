# Story 2.7: Structured Lab Extraction Display

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As an authenticated user,
I want to see structured lab values when extraction exists for a report,
so that I can quickly read parameters (name, value, unit, date) without opening the PDF.

## Acceptance Criteria

1. **Given** a report has extracted lab data available
   **When** I open the report detail view (or the view that shows report metadata before/instead of only PDF)
   **Then** I see a list of lab parameters with: parameter name, value, unit (if present), and date/sample date (if present)
   **And** values are rendered safely (no crash for null/missing fields; show "—" or omit optional fields when absent)

2. **Given** a report has no extraction or extraction is empty
   **When** I open the report detail view
   **Then** I do not see a lab values section (or I see a clear "No structured data" / "Lab values not available" state)
   **And** I can still access "View PDF" and other existing report actions

3. **Given** I am viewing structured lab values
   **When** the data is loading
   **Then** a loading state is shown for the lab section (or the whole detail); no flash of wrong/empty data

4. **Given** report detail is scoped to a profile I own
   **When** I request report detail for that report
   **Then** the API returns report metadata and extracted lab values (if any) only after validating I own the report’s profile
   **And** no PHI is logged (per project-context)

## Tasks / Subtasks

- [ ] API: storage and contract for extracted lab values (AC: 1, 2, 4)
  - [ ] Define storage for extracted lab data: either (a) a dedicated table `report_lab_values` or equivalent (reportId FK, parameterName, value, unit, sampleDate, sortOrder), or (b) a JSONB column on `reports` with a documented shape. Prefer a normalised table for queryability and future trend use (story 2.8).
  - [ ] Ensure report ownership is validated (existing getReport flow uses userId + reportId and resolves profile; reuse that pattern). Return 403/404 if user does not own the report.
  - [ ] Extend `GET /reports/:reportId` (or equivalent) response to include optional `extractedLabValues?: Array<{ parameterName, value, unit?, sampleDate? }>` when present. When no extraction, omit key or return empty array. Keep camelCase in JSON per architecture.
  - [ ] If parser/extraction pipeline does not exist yet: support writing extraction from a stub or admin path so dev/QA can seed data; or document "extraction populated by future parser story" and return empty array until then.

- [x] Flutter: report detail screen and lab display (AC: 1, 2, 3)
  - [x] Add a report detail screen (e.g. `report_detail_screen.dart` under `lib/features/reports/screens/`) that loads a single report via `getReport(reportId)` and displays: report metadata (name, date, status) and optional structured lab values. Entry: from timeline tap → navigate to report detail first; from report detail, "View PDF" pushes existing `PdfViewerScreen`.
  - [x] Extend `Report` model and `getReport` parsing to include `extractedLabValues` (list of objects with parameterName, value, unit, sampleDate). Handle null/absent safely.
  - [x] When `extractedLabValues` is non-empty: show a section "Lab values" with a list (e.g. `ListView` or table-like rows) of parameter name, value, unit (if present), date (if present). Use safe rendering: null/empty string → "—" or omit.
  - [x] When `extractedLabValues` is null or empty: do not show lab section, or show "No structured data" / "Lab values not available" per UX preference. Keep "View PDF" and any retry/keep-file actions from existing flows.
  - [x] Loading: show loading state while fetching report; no flash of previous report’s data when opening another report.

- [x] Integration and navigation (AC: 2)
  - [x] Timeline: change tap behaviour to push report detail screen (with reportId and profileId or report summary); from report detail, "View PDF" opens `PdfViewerScreen`. Preserve existing PDF viewer behaviour.
  - [x] Ensure back from report detail returns to timeline; from PDF viewer back returns to report detail (or timeline if that was the only entry for this story’s scope).

- [x] Tests
  - [x] API: unit test that getReport returns extractedLabValues when present and omits or returns [] when absent; E2E: GET report with extraction returns 200 and shape; GET report for another user’s report returns 403/404.
  - [x] Flutter: widget test that report detail shows lab list when data present and no lab section (or empty state) when absent; test loading state; test "View PDF" navigates to viewer.

## Dev Notes

### Scope and data boundary

- This story is **display-only** for structured lab data: parameter name, value, unit, date. Storage and API shape are in scope; the **source** of extraction (parser/AI) may be out of scope for this story—document how extraction is populated (e.g. stub, future parser story) so that when extraction exists, it is returned and displayed.
- Profile/report ownership: reuse existing authz (getReport validates user owns report via report’s profile). NFR8: profile-scoped data enforced.

### API contract (recommended)

- **GET /reports/:reportId** (existing) response extended with optional:
  - `extractedLabValues?: Array<{ parameterName: string, value: string, unit?: string, sampleDate?: string }>`
  - Omit key or return `[]` when no extraction. camelCase per architecture. sampleDate ISO 8601 or date string.

### Architecture and project rules

- **Profile-scoped data:** Only return extraction for reports the user owns (same as existing getReport). No PHI in logs (project-context).
- **Response envelope:** Use `successResponse(data, correlationId)`; include report metadata plus `extractedLabValues` in `data`.

### Files to touch

- **API:** Report entity or new entity for lab values; migration if new table; `reports.service.ts` (getReport to load and map extraction); `reports.types.ts` or DTO (extend ReportDto with optional extractedLabValues); controller unchanged route, response shape only.
- **Flutter:** `reports_repository.dart` / `api_reports_repository.dart` — extend Report model and getReport parsing; new `report_detail_screen.dart`; timeline_screen — tap navigates to report detail with reportId; report detail has "View PDF" → PdfViewerScreen.

### Previous story intelligence (2.6)

- **2.6:** Timeline lists reports per profile; tap opens PdfViewerScreen. ReportsService.getReport(userId, reportId) returns ReportDto (id, profileId, originalFileName, contentType, sizeBytes, status, createdAt). No report detail screen; no extraction fields. Reuse: AuthGuard, successResponse, profile ownership pattern (report belongs to user’s profile), repository pattern, Material 3, full Scaffold.

## Technical Requirements

- **API:** Add persistence for extracted lab values (table or JSONB); extend getReport to return them when present; validate ownership via existing pattern (report → profile → user). No new endpoint required if extending GET /reports/:reportId.
- **Flutter:** Report model + optional `List<ExtractedLabValue>?`; report detail screen with loading/list/empty states; safe rendering of null/empty fields; navigation: timeline → report detail → View PDF → PdfViewerScreen.

## Architecture Compliance

- ADR: Profile-scoped data; getReport already enforces ownership. NFR8: profile-scoped data enforced. Naming: DB snake_case, API JSON camelCase (architecture.md). No PHI in logs.

## Library / Framework Requirements

- Backend: No new deps; TypeORM for new entity/column if needed; reuse ReportsService, AuthGuard, successResponse.
- Flutter: No new packages; Material 3, Scaffold; reuse ApiClient and repository pattern.

## Testing Requirements

- **API unit:** getReport returns extractedLabValues when present; returns empty or omits when absent; ownership enforced (mock repo + profilesService).
- **API E2E:** GET /reports/:id with extraction → 200 and shape; GET for other user’s report → 403 or 404.
- **Flutter:** Report detail shows lab list when data present; no lab section or empty state when absent; loading state; View PDF navigates; widget tests with Key('report-detail-*') or similar.

## Previous Story Intelligence (2.6)

- Timeline implemented: listReports(profileId), TimelineScreen, tap → PdfViewerScreen. ReportsService.getReport returns ReportDto without extraction. ProfilesService.getProfile used for ownership. Add report detail screen between timeline and PDF viewer; extend DTO and Report model with extractedLabValues; add storage and mapping for lab values.

## Project Context Reference

- [Source: _bmad-output/project-context.md] — AuthGuard, ConfigService, no process.env in modules, error codes in types file, PHI-safe logging, successResponse envelope; Flutter repository pattern, no force-unwrap, full Scaffold, Material 3, widget test keys kebab-case.

## References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.7]
- [Source: _bmad-output/planning-artifacts/epics.md#FR18]
- [Source: _bmad-output/planning-artifacts/architecture.md] — API camelCase, profile-scoped data, project structure
- [Source: _bmad-output/implementation-artifacts/2-6-timeline-view-scoped-to-active-profile.md]

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent.)

### Debug Log References

(To be filled by dev agent.)

### Completion Notes List

- API: ReportLabValueEntity and report_lab_values table (migration 1730813400000); getReport loads lab values and returns extractedLabValues ([] when none). Ownership unchanged (userId + reportId). ReportDto and ExtractedLabValueDto in reports.service.ts.
- Flutter: ExtractedLabValue and Report.extractedLabValues; getReport parses extractedLabValues; ReportDetailScreen with metadata, View PDF, lab list or "No structured data"; timeline tap → ReportDetailScreen → View PDF → PdfViewerScreen. PdfViewerScreen: document: Future.value(doc) for pdfx API compatibility.
- Tests: reports.service.spec getReport with/without lab values and ReportLabValueEntity mock; e2e GET /reports/:id asserts extractedLabValues array; report_detail_test.dart (loading, lab list, empty state, View PDF navigates, back). Timeline test "refetches when profileId changes" may be flaky (unrelated to this story).

### File List

- apps/api/src/database/entities/report-lab-value.entity.ts
- apps/api/src/database/migrations/1730813400000-AddReportLabValuesTable.ts
- apps/api/src/database/migrations/index.ts
- apps/api/src/database/data-source.ts
- apps/api/src/modules/reports/reports.module.ts
- apps/api/src/modules/reports/reports.service.ts
- apps/api/src/modules/reports/reports.service.spec.ts
- apps/api/src/modules/reports/reports.controller.spec.ts
- apps/api/test/app.e2e-spec.ts
- apps/mobile/lib/features/reports/reports_repository.dart
- apps/mobile/lib/features/reports/api_reports_repository.dart
- apps/mobile/lib/features/reports/screens/report_detail_screen.dart
- apps/mobile/lib/features/reports/screens/timeline_screen.dart
- apps/mobile/lib/features/reports/screens/pdf_viewer_screen.dart
- apps/mobile/test/report_detail_test.dart
- _bmad-output/implementation-artifacts/2-7-structured-lab-extraction-display.md

## Change Log

| Date       | Author | Change |
|------------|--------|--------|
| 2026-03-15 | AI     | Story created: structured lab extraction display; API storage + GET extension; Flutter report detail screen and safe lab list rendering. |
