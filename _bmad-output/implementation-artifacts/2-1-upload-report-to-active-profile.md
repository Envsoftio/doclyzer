# Story 2.1: Upload Report to Active Profile

**Status:** ready-for-dev  
**Epic:** 2 — Report Ingestion, Processing Recovery & Timeline Insights  
**Depends on:** Story 1.5 (active profile context), Story 0.5 (object storage via Backblaze B2)  

## Story

As an authenticated user,  
I want to upload a supported report to my active profile,  
so that it enters my health record and processing can begin.

## Acceptance Criteria

1. **Given** I am authenticated and have an active profile selected  
   **When** I upload a valid PDF report file  
   **Then** the API stores the file in object storage using a deterministic key structure (e.g. `reports/{userId}/{profileId}/{reportId}.pdf`)  
   **And** creates a `Report` record linked to my active profile  
   **And** sets the report lifecycle state to an initial processing state (e.g. `processing` / `queued`)  
   **And** returns a response containing at least `reportId`, `profileId`, `fileName`, `contentType`, `sizeBytes`, and `status` in the standard success envelope.

2. **Given** I attempt to upload a file that is missing, empty, too large, or not a supported type  
   **When** the API validates the request  
   **Then** it returns a standardized error envelope with a stable error code  
   **And** does not create any `Report` DB record  
   **And** does not store the file in object storage.

3. **Given** object storage is unavailable or misconfigured  
   **When** I attempt to upload a report  
   **Then** the API returns a clear error (stable code)  
   **And** does not create a `Report` DB record (no “report without a file” state).

4. **Given** the mobile app initiates an upload  
   **When** the upload is in progress and then completes  
   **Then** the UI shows **Uploading…** during network transfer and **Reading report…** once the server acknowledges upload and begins processing  
   **And** the user is navigated to a result state that clearly shows the report is added to the active profile (timeline rendering is handled in Story 2.6).

## Tasks / Subtasks

- [ ] **Task 1: Add report persistence model** (AC: 1–3)
  - [ ] 1.1 Create `Report` entity under `apps/api/src/database/entities/report.entity.ts` (TypeORM Data Mapper pattern) with:
    - `id` (uuid), `userId`, `profileId`
    - original file metadata (`originalFileName`, `contentType`, `sizeBytes`)
    - storage reference (`originalFileStorageKey`)
    - `status` enum (initial values only for now; full lifecycle in Story 2.2)
    - timestamps
  - [ ] 1.2 Add migration to create the reports table (and indices for `userId`, `profileId`, and `createdAt`).

- [ ] **Task 2: Implement API upload endpoint** (AC: 1–3)
  - [ ] 2.1 Create `ReportsModule` under `apps/api/src/modules/reports/` with `reports.controller.ts`, `reports.service.ts`, `reports.types.ts` (error codes, status enum), and DTOs as needed.
  - [ ] 2.2 Add `POST /reports` (or `POST /reports/upload`) protected by `@UseGuards(AuthGuard)`; accept multipart upload with a single `file` field.
  - [ ] 2.3 Validate:
    - user has an active profile (source-of-truth is the server; do not trust client-provided profileId unless explicitly required)
    - file is provided, non-empty, and `contentType` is `application/pdf` (and/or allowlist per UX/PRD if expanded later)
    - enforce an explicit max upload size (choose a default and document it; align later with product limits/entitlements).
  - [ ] 2.4 Implement safe “storage-first then DB” ordering:
    - generate `reportId` (uuid) without saving
    - compute `storageKey = reports/{userId}/{activeProfileId}/{reportId}.pdf`
    - upload file to object storage via the shared storage abstraction (Story 0.5)
    - only after successful upload: insert `Report` row with `status = queued|processing`
  - [ ] 2.5 Return success via `successResponse(data, correlationId)` and ensure errors use typed `HttpException` subclasses with `{ code, message }`.

- [ ] **Task 3: Implement mobile upload flow (Flutter)** (AC: 4)
  - [ ] 3.1 Create `features/reports/`:
    - `reports_repository.dart` (abstract)
    - `api_reports_repository.dart` (multipart upload via `ApiClient`)
    - screens: `upload_report_screen.dart` + a minimal “upload result” state.
  - [ ] 3.2 Add an “Upload report” entry point from the authenticated home experience:
    - visible active profile indicator (“Uploading to: <Profile>”)
    - progress states: **Uploading…** → **Reading report…** (post-upload processing kickoff)
  - [ ] 3.3 Ensure the upload flow is profile-safe:
    - if multiple profiles exist, allow user to confirm the active profile before upload (do not add cross-profile selection creep unless required by UX; keep it simple and explicit).

- [ ] **Task 4: Tests** (AC: 1–4)
  - [ ] 4.1 API unit tests for `ReportsService`:
    - rejects missing/invalid files with stable error codes
    - does not insert DB rows on storage upload failure
    - inserts DB row only after successful upload
  - [ ] 4.2 API e2e test for `POST /reports` using a stubbed storage provider (no real B2 required).
  - [ ] 4.3 Flutter widget test for the upload screen: validates button enabled/disabled states and renders progress + error states using an in-memory reports repository.

## Dev Notes

- **Cross-story context:** This story is only responsible for “upload + start lifecycle”. Deterministic multi-surface lifecycle visibility is Story 2.2; retry/keep-file recovery is Story 2.3; original PDF viewing is Story 2.4; timeline rendering is Story 2.6.
- **Storage requirement:** PRD mandates Backblaze B2 (S3-compatible) with private buckets and application-generated signed URLs/streams for reads. Upload must be storage-first to avoid “DB row without file” drift.
- **PHI safety:** Do not log file contents, filenames, or user identifiers in request logs; rely on correlation IDs for debugging.

### Project Structure Notes

- API:
  - `apps/api/src/modules/reports/` — new module (controller/service/types/dto)
  - `apps/api/src/database/entities/report.entity.ts` + migration under `apps/api/src/database/migrations/`
  - shared storage abstraction from Story 0.5 (expected location: `apps/api/src/common/storage/`)
- Mobile:
  - `apps/mobile/lib/features/reports/` — repository + upload UI
  - add only the minimum navigation wiring needed (do not build timeline here).

### References

- [Source: _bmad-output/planning-artifacts/epics.md — Epic 2 / Story 2.1]
- [Source: _bmad-output/planning-artifacts/prd.md — Object Storage (Backblaze B2); failure modes/mitigations]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md — Upload flow + backend parse/status expectations]
- [Source: _bmad-output/project-context.md — API envelopes, error codes, TypeORM + ConfigService rules, PHI-safe logging]

## Developer Context (Implementation Guardrails)

### Technical requirements

- Follow existing NestJS conventions:
  - `ConfigService` only (no `process.env` inside modules)
  - TypeORM Data Mapper: repositories via `@InjectRepository(Report)`
  - Standard success envelope via `successResponse()`
  - Standard error envelope via `ApiExceptionFilter` (exceptions must include `{ code, message }`)
- Enforce strict validation and stable error codes in `reports.types.ts` (screaming snake case).
- File upload handling:
  - prefer memory-backed upload (buffer/stream) so object storage receives the file directly
  - ensure max upload size is enforced at the Nest interceptor/multer layer (and documented).

### Architecture compliance

- No cross-module repository injection: `ReportsModule` owns `Report` persistence.
- Storage-first ordering is mandatory (PRD resilience requirement).
- IDs in storage keys only; do not embed PHI/PII in object keys.

### Library / framework requirements

- Reuse the shared object-storage provider introduced in Story 0.5 (Backblaze B2 via S3-compatible API). If Story 0.5 is not yet implemented, implement a minimal interface + local stub first and keep B2 specifics behind that interface.
- For Flutter upload: use a file picker that supports PDFs; keep dependencies minimal and documented.

### File structure requirements

- `apps/api/src/modules/reports/`
  - `reports.controller.ts`
  - `reports.service.ts`
  - `reports.dto.ts` (if needed)
  - `reports.types.ts` (error codes + status enum)
- `apps/api/src/database/entities/report.entity.ts`
- `apps/mobile/lib/features/reports/`
  - `reports_repository.dart`
  - `api_reports_repository.dart`
  - `screens/upload_report_screen.dart`

### Testing requirements

- Unit tests: mock repositories via `getRepositoryToken(Report)`; mock storage via a stub service; no SQLite/in-memory DB.
- E2E: use supertest against real NestJS app; stub storage provider so tests do not require B2 credentials.

## Project Context Reference

- See `_bmad-output/project-context.md` for non-obvious API patterns (error envelopes, correlation ID handling, TypeORM/migrations rules, PHI-safe logging).

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent.)

### Debug Log References

(To be filled by dev agent.)

### Completion Notes List

- Story selected from sprint status first backlog item: `2-1-upload-report-to-active-profile`
- No previous story exists in Epic 2; previous-story intelligence section intentionally omitted
- Git intelligence section omitted because no previous-story implementation artifacts exist
- Latest-tech section intentionally omitted; Story 0.5 already captures B2/S3 SDK implementation guidance
- Validation task file `_bmad/core/tasks/validate-workflow.xml` not present; manual checklist-aligned validation should be applied before dev-story if desired

### File List

- _bmad-output/implementation-artifacts/2-1-upload-report-to-active-profile.md
- _bmad-output/implementation-artifacts/sprint-status.yaml

## Senior Developer Review (AI)

**Review date:** 2026-03-13  
**Outcome:** Story not implemented (Status: ready-for-dev; all tasks unchecked; File List has no app code). No code to review. Review again after implementation.

