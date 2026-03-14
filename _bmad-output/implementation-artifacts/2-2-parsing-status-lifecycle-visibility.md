# Story 2.2: Parsing Status Lifecycle Visibility

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As an authenticated user,
I want clear processing states for my uploaded reports,
so that I understand progress and outcomes consistently across the app and API.

## Acceptance Criteria

1. **Given** the API and Flutter app use a shared report status enum
   **When** a report transitions through its lifecycle
   **Then** the same canonical values are used in API responses, DB, and Flutter
   **And** no surface introduces aliases or divergent status names

2. **Given** I have uploaded a report (Story 2.1)
   **When** I call `GET /reports/:id` for a report I own
   **Then** the response includes `status` with one of the canonical values
   **And** the response uses the standard success envelope with `correlationId`
   **And** if the report does not exist or belongs to another user, I receive `404` with `{ success: false, code: "REPORT_NOT_FOUND", ... }`

3. **Given** I am on the Flutter app viewing a report (upload result or later)
   **When** the report status is `queued`, `parsing`, or `uploading`
   **Then** the UI shows **Reading report…** (or equivalent in-progress copy)
   **And** when status is `parsed`, the UI shows the report as ready (summary/chart hint per later stories)
   **And** when status is `unparsed` or `failed_terminal`, the UI shows **We couldn't read this format** with recovery options (Retry/Keep file anyway — full UX in Story 2.3)

4. **Given** parsing is implemented as sync (upload + parse in one request) for MVP
   **When** the upload completes and parse runs
   **Then** the `POST /reports` response includes the final `status` (`parsed` or `unparsed`) when parse finishes within the request
   **And** if parse is deferred (async), the response returns `status: queued` or `parsing` and the client can poll `GET /reports/:id` until terminal state

5. **Given** I am not authenticated (missing or invalid `Authorization` header)
   **When** I call `GET /reports/:id`
   **Then** I receive `401` with `{ success: false, code: "AUTH_UNAUTHORIZED", ... }`

## Tasks / Subtasks

- [x] Define canonical report status enum (AC: 1)
  - [x] In `reports.types.ts` — define `ReportStatus` enum/union: `uploading` | `queued` | `parsing` | `parsed` | `unparsed` | `failed_transient` | `failed_terminal`
  - [x] Update `Report` entity to use this enum (migration if 2.1 used different values)
  - [x] Document in project-context or architecture: shared lifecycle enum; no surface-specific aliases

- [x] Add GET /reports/:id endpoint (AC: 2, 5)
  - [x] In `reports.controller.ts` — add `@Get(':id')` protected by AuthGuard
  - [x] In `reports.service.ts` — add `getReport(userId: string, reportId: string): Report`; throw `ReportNotFoundException` if not found or not owned
  - [x] Add `REPORT_NOT_FOUND` to `reports.types.ts`
  - [x] Return `successResponse(report, getCorrelationId(req))` with report including `status`

- [x] Implement parse orchestration (sync MVP) (AC: 4)
  - [x] In `reports.service.ts` — after storage upload and DB insert, invoke parse (stub or Docling integration)
  - [x] If sync: run parse in request; update Report `status` to `parsed` or `unparsed` before returning
  - [x] If parse fails (timeout, error): set `status = unparsed` or `failed_terminal`; keep file; return in response
  - [x] Parse stub for MVP: immediately set `parsed` or `unparsed` based on config/flag if real parser not wired

- [x] Flutter: status display mapping (AC: 3)
  - [x] In `lib/features/reports/` — add shared `ReportStatus` enum matching API (or generated from contract)
  - [x] Map status to display: `queued`/`parsing`/`uploading` → "Reading report…"; `parsed` → ready; `unparsed`/`failed_terminal` → "We couldn't read this format" + recovery UI (minimal for this story; full in 2.3)
  - [x] Upload result screen: show status from `POST` response or poll `GET /reports/:id` if async
  - [x] Widget keys for tests: `Key('report-status-${status}')`, `Key('report-reading')`, `Key('report-unparsed')`

- [x] Unit and E2E tests (AC: 2, 4, 5)
  - [x] `reports.service.spec.ts` — getReport returns report for owner; throws for non-owner/non-existent
  - [x] `reports.controller.spec.ts` — GET :id delegates to service; 401 when unauthenticated; 404 when not found
  - [x] E2E: GET /reports/:id with valid token + owned report → 200 with status; GET with non-existent → 404 REPORT_NOT_FOUND; GET without token → 401

- [x] Flutter widget tests (AC: 3)
  - [x] Upload result / report card: displays "Reading report…" when status in-progress; displays "We couldn't read this format" when unparsed; uses keys for testability

## Dev Notes

### Critical Architecture Notes

- **Canonical enum:** PRD and architecture require `uploading`, `queued`, `parsing`, `parsed`, `unparsed`, `failed_transient`, `failed_terminal`. Use snake_case in API/DB; Flutter can use same or Dart enum. No aliases.
- **Sync vs async:** Product brief allows sync for V1 (upload + parse in one request). If parse >10–15s, consider async + polling. This story supports both: sync = final status in POST response; async = POST returns queued/parsing, client polls GET.
- **Parse stub:** If Docling/parser not integrated, use a stub that sets `parsed` or `unparsed` (e.g. config flag or round-robin) so lifecycle is testable.
- **Retry/Keep file:** Story 2.3 implements full Retry and Keep file anyway UX. This story only ensures status is visible; minimal recovery copy is acceptable.

### API Contract

- `GET /reports/:id` — 200 OK, body: `{ success: true, data: Report, correlationId }`. Report includes `id`, `profileId`, `status`, `originalFileName`, `contentType`, `sizeBytes`, `createdAt`. 404 REPORT_NOT_FOUND if not found or not owned. 401 if unauthenticated.
- `POST /reports` (from 2.1) — response `status` must be one of canonical values; if sync parse, may return `parsed` or `unparsed` directly.

### Flutter

- **Status enum:** Mirror API values exactly. Consider shared package or generated types if cross-platform contract grows.
- **Display mapping:** In-progress (`uploading`, `queued`, `parsing`) → "Reading report…". Terminal success → `parsed`. Terminal failure → `unparsed` or `failed_terminal` → "We couldn't read this format" (Retry/Keep file UI in 2.3).

### Project Structure (additions only)

- Extend `reports.service.ts`, `reports.controller.ts`, `reports.types.ts` from Story 2.1.
- Flutter: extend `reports_repository.dart` with `getReport(id)` if polling; extend upload result screen with status display.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.2]
- [Source: _bmad-output/planning-artifacts/prd.md#FR12, Async-first backend contract]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX2, Shared lifecycle enums]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Upload flow, Parse failure]
- [Source: _bmad-output/implementation-artifacts/2-1-upload-report-to-active-profile.md]

## Technical Requirements

- `GET /reports/:id` protected by `@UseGuards(AuthGuard)`.
- Report status enum exported from `reports.types.ts` and used in entity, DTOs, and Flutter.
- No PHI in logs; correlation ID in responses.

## Architecture Compliance

- ADR-CX2: State Transparency Contract — deterministic states across API and Flutter.
- Shared lifecycle enum; no surface-specific aliases.
- `ReportNotFoundException` for 404 with `REPORT_NOT_FOUND` code.

## Library / Framework Requirements

- Backend: NestJS, TypeScript (no new deps).
- Flutter: Material 3; reuse existing patterns.

## Testing Requirements

- **Service:** getReport returns for owner; throws for non-owner/non-existent.
- **Controller:** GET delegates; 401/404 propagate.
- **E2E:** GET with token + valid id → 200; GET non-existent → 404; GET no token → 401.
- **Flutter:** Status display maps correctly; widget keys for tests.

## Previous Story Intelligence (2.1)

- **Report entity** has `status` with initial values `queued`|`processing`. Story 2.2 expands to full enum and may require migration if 2.1 used different values.
- **POST /reports** returns `reportId`, `profileId`, `fileName`, `contentType`, `sizeBytes`, `status`. Story 2.2 ensures `status` is canonical and may include parse result when sync.
- **Flutter** has `reports_repository.dart`, `api_reports_repository.dart`, `upload_report_screen.dart`. Add `getReport(id)` to repository if async polling; extend upload result to show status from response.
- **Storage-first:** Upload to B2, then DB. Parse runs after both; if parse fails, file remains, status = unparsed.

## Project Context Reference

- [Source: _bmad-output/project-context.md] — AuthGuard, response envelope, error codes, PHI-safe logging, require-await.

## Story Completion Status

- Story context file generated with implementation guardrails and testing standards.
- Ready for `dev-story` execution after Story 2.1.

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent.)

### Debug Log References

(To be filled by dev agent.)

### Completion Notes List

- Story 2.2 extends 2.1: Report entity uses full status enum (report.entity.ts); GET /reports/:id in controller/service; parse stub in uploadReport (reports.config for stub flags); Flutter upload result shows status (success vs parse-failure). E2E covers GET :id 200/404/401.

### File List

- apps/api/src/database/entities/report.entity.ts
- apps/api/src/config/reports.config.ts
- apps/api/src/modules/reports/reports.controller.ts
- apps/api/src/modules/reports/reports.service.ts
- apps/api/src/modules/reports/reports.types.ts
- apps/api/src/modules/reports/reports.service.spec.ts
- apps/api/src/modules/reports/reports.controller.spec.ts
- apps/api/test/app.e2e-spec.ts
- apps/mobile/lib/features/reports/reports_repository.dart
- apps/mobile/lib/features/reports/api_reports_repository.dart
- apps/mobile/lib/features/reports/screens/upload_report_screen.dart
- apps/mobile/test/upload_report_test.dart
- _bmad-output/implementation-artifacts/2-2-parsing-status-lifecycle-visibility.md
