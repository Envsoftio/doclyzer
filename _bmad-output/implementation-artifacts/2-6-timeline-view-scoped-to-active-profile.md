# Story 2.6: Timeline View Scoped to Active Profile

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As an authenticated user,
I want a timeline of reports scoped to the active profile,
so that cross-profile leakage is prevented and I see only that profile’s reports.

## Acceptance Criteria

1. **Given** I am authenticated and have an active profile
   **When** I open the timeline (reports list) view
   **Then** I see only reports belonging to the active profile
   **And** reports are ordered in a deterministic way (e.g. by `createdAt` descending)

2. **Given** the timeline is displayed for profile A
   **When** I switch active profile to profile B (e.g. from profile switcher)
   **Then** the timeline data updates strictly to profile B’s reports
   **And** no reports from profile A (or any other profile) are shown
   **And** the UI reflects the new scope (e.g. empty state if B has no reports, or B’s list)

3. **Given** I request the timeline for a profile I do not own (e.g. tampered profileId)
   **When** the API validates the request
   **Then** the API returns 403 Forbidden (or 404) and does not return that profile’s reports

4. **Given** my active profile has no reports
   **When** I open the timeline
   **Then** I see a clear empty state (e.g. “No reports yet” with guidance to upload)

5. **Given** timeline data is loading
   **When** the request is in flight
   **Then** a loading state is shown (no flash of wrong profile’s data)

## Tasks / Subtasks

- [x] API: list reports by profile (AC: 1, 2, 3)
  - [x] Add `GET /reports` (or `GET /profiles/:profileId/reports` per architecture) that returns reports for a single profile. Prefer query param `profileId` with server-side validation that the user owns that profile (ProfilesService or auth context). If no profileId, derive from active profile (getActiveProfileId) for backward compatibility.
  - [x] Enforce authz: user may only list reports for profiles they own. Use existing ProfilesService to validate profile ownership before querying reports.
  - [x] Return list of report DTOs (id, profileId, originalFileName, status, createdAt, etc.) in standard success envelope; order by createdAt DESC. Pagination optional for later (not required for this story).
  - [x] Add `listReportsByProfile(userId, profileId)` (or equivalent) in ReportsService; use Report repo `find({ where: { profileId }, order: { createdAt: 'DESC' } })`.

- [x] Flutter: timeline screen and profile scope (AC: 1, 2, 4, 5)
  - [x] Add a timeline (reports list) screen that displays reports for the current active profile. Location: `lib/features/reports/screens/timeline_screen.dart` (or under `lib/features/timeline/` if you prefer a separate feature; architecture mentions both `reports` and `timeline` — prefer `reports` for “list of reports” to keep upload + list in one feature).
  - [x] Repository: add `listReports(profileId)` (or get active profile from profiles repo and then list). ApiReportsRepository calls `GET /reports?profileId=...` (or the chosen contract). Parse response into list of report summary DTOs.
  - [x] When user switches active profile (e.g. from profile list or app-level profile context), timeline screen must refetch using the new active profile id. If the app uses a single “current profile” source of truth (e.g. from ProfilesRepository or app state), the timeline screen should depend on that and refetch when it changes.
  - [x] Empty state: when list is empty, show “No reports yet” (and optionally link to upload). Loading state: show indicator while loading; do not show previous profile’s data during switch.

- [x] Integration and navigation (AC: 2)
  - [x] Ensure profile switch triggers timeline refresh: either timeline listens to active-profile stream/callback or parent passes new profileId and triggers reload. No caching that would show stale profile’s reports after switch.
  - [x] Tapping a report item can navigate to report detail or PDF view (existing flow from 2.4); ensure report id is for the current profile’s report.

- [x] Tests
  - [x] API: unit test that listReportsByProfile returns only reports for that profile and respects ownership (user A cannot list user B’s profile reports). E2E: authenticated GET list for profile returns 200 and correct items; GET with another user’s profileId returns 403/404.
  - [x] Flutter: widget test that timeline shows list when reports exist and empty state when empty; test that changing profileId (or active profile) triggers reload and displayed data matches (mock repository).

## Dev Notes

### Scope and data boundary

- Timeline = list of reports for one profile. No aggregation across profiles. NFR3: timeline interactions (scroll/filter/open report) respond within 300 ms for typical profile data volumes — keep list endpoint efficient (index on profileId + createdAt if needed).
- Profile ownership: always validate that the profileId in the request belongs to the authenticated user (e.g. ProfilesService.getProfile or exists and userId match). Never return reports for another user’s profile.

### API contract (recommended)

- **GET /reports?profileId={uuid}**  
  Query param `profileId` required (or optional: if omitted, use active profile from session).  
  Response: 200 + success envelope with `data: { reports: ReportDto[] }`.  
  ReportDto: id, profileId, originalFileName, contentType, sizeBytes, status, createdAt (and any other fields already in ReportDto).  
  Order: newest first (createdAt DESC).  
  403/404 if profileId not owned by user.

- Alternative: **GET /profiles/:profileId/reports** — same semantics; validate profile ownership in profiles module or reports module.

### Architecture and project rules

- **Profile-scoped data:** ADR and NFR8 — access to profile-scoped data enforced by account and authorization context. Listing reports is PHI-bearing; must be profile-scoped and ownership-checked.
- **No PHI in logs:** Do not log report names or profile ids in a way that leaks PHI; correlation ID and report count are fine (project-context).
- **Response envelope:** Use `successResponse(data, correlationId)` for JSON (project-context). Pagination not required for MVP; add later if needed.

### Files to touch

- **API:** `reports.service.ts` — add `listReportsByProfile(userId, profileId)` (and optionally “list by active profile” that resolves active then lists). `reports.controller.ts` — add GET endpoint with profileId query (or path) and ownership check. `reports.types.ts` — reuse or extend ReportDto for list item. Optionally `profiles.service.ts` — ensure there is a way to validate “user owns this profile” (e.g. getProfile or getActiveProfileId already used elsewhere).
- **Flutter:** `reports_repository.dart` — add `Future<List<ReportSummary>> listReports(String profileId)`. `api_reports_repository.dart` — implement GET /reports?profileId=... and parse. New screen: `timeline_screen.dart` (or `reports_list_screen.dart`) under `reports/screens/`. Wire from home or navigation so user can open timeline; ensure screen receives or resolves active profile and refetches on profile change.

### Previous story intelligence (2.1–2.5)

- **2.1–2.4:** Upload, status lifecycle, retry/keep-file, original PDF view. Report entity: id, userId?, profileId, originalFileName, contentType, sizeBytes, originalFileStorageKey, status, createdAt. No list endpoint yet.
- **2.5:** Duplicate detection (contentHash, 409 + existingReport), upload_anyway. ReportsService has uploadReport, getReport, getReportFile, retryParse, keepFile. No list method. Flutter: upload screen, PDF viewer; no timeline list screen.
- **Patterns:** AuthGuard on all report routes; successResponse envelope; exception with code for 4xx; repository pattern in Flutter; widget keys kebab-case for tests.

## Technical Requirements

- **API:** Add GET handler; validate profile ownership via ProfilesService (e.g. getProfile(userId, profileId) or ensure profile belongs to user). TypeORM: `reportRepo.find({ where: { profileId }, order: { createdAt: 'DESC' } })`. Index on (profileId, createdAt) if table grows (migration in this or a follow-up story).
- **Flutter:** Repository method returns `List<ReportSummary>` (or reuse existing report model with id, originalFileName, status, createdAt at minimum). Timeline screen uses that list; on init and when active profile changes, call listReports(activeProfileId). No force-unwrap; handle null/empty; loading and empty states per project-context.

## Architecture Compliance

- ADR: Profile-scoped data; list reports is strictly scoped to one profile with ownership check. NFR8: profile-scoped data enforced by account and authorization context across all surfaces.
- Frontend state: When active profile changes, timeline data must update (no cross-profile leakage). Architecture: “explicit domain slices”, “profile-scoped ownership checks on PHI-bearing operations”.

## Library / Framework Requirements

- Backend: No new deps; use existing TypeORM repo, ProfilesService, AuthGuard, successResponse.
- Flutter: No new packages; use existing HTTP client and navigation. Material 3, full Scaffold, same patterns as upload_report_screen.

## Testing Requirements

- **API unit:** ReportsService.listReportsByProfile(userId, profileId) returns only reports for that profileId; when profile is not owned by user, throw (e.g. ForbiddenException). Mock report repo and profiles service.
- **API E2E:** GET /reports?profileId=<user’s profile> → 200 and list of that profile’s reports. GET /reports?profileId=<other user’s profile> → 403 or 404. Unauthenticated → 401.
- **Flutter:** Timeline shows loading then list or empty state; mock repository returns different list for different profileId; changing profileId and refetching shows correct list (widget test with key for list and empty state).

## Previous Story Intelligence (2.5)

- Story 2.5 added contentHash, duplicate detection, upload_anyway, Flutter duplicate dialog. Files: report.entity.ts, reports.service/controller, reports.types (REPORT_DUPLICATE_DETECTED), ApiExceptionFilter (allowed extra keys), Flutter upload_report_screen and api_reports_repository (duplicateAction, getReport on “Keep existing”).
- Reuse: ReportDto shape, AuthGuard, successResponse, repository pattern, exception codes in types file. Timeline does not need duplicate logic; it only lists reports for a profile.

## Project Context Reference

- [Source: _bmad-output/project-context.md] — AuthGuard, ConfigService, no process.env in modules, error codes in types file, PHI-safe logging, successResponse envelope; Flutter repository pattern, no force-unwrap, full Scaffold, Material 3, widget test keys kebab-case.

## References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.6]
- [Source: _bmad-output/planning-artifacts/epics.md#FR17]
- [Source: _bmad-output/planning-artifacts/architecture.md] — project structure (reports/timeline), profile-scoped data, NFR8
- [Source: _bmad-output/implementation-artifacts/2-5-duplicate-report-detection-and-user-choice.md]

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent.)

### Debug Log References

(To be filled by dev agent.)

### Completion Notes List

- API: ProfilesService.getProfile(userId, profileId) added for ownership validation. ReportsService.listReportsByProfile(userId, profileId) and listReports(userId, profileId?) (resolves active profile when profileId omitted). GET /reports?profileId= with success envelope { reports: ReportDto[] }; 404 when profile not owned. Controller and service unit tests added. E2E tests added for GET /reports (401, 200 with profileId, 200 without profileId, 404 for other user's profile).
- Flutter: ReportsRepository.listReports(profileId), ApiReportsRepository GET v1/reports?profileId=; TimelineScreen with loading, empty, list, error states; didUpdateWidget refetches when profileId changes. HomeScreen onGoToTimeline; main.dart timeline view and _timelineProfileId; tap report opens PdfViewerScreen via Navigator.push.
- Flutter widget tests: timeline_test.dart (empty state, list state, back button, profileId change refetch). API E2E: Reports describe uses app from parent scope—if running with --testNamePattern="Reports" only, ensure full e2e or run from root describe that defines app.
- Code review fixes: All task checkboxes set to [x]; timeline_test uses verify() instead of expect(..., completes); const Key('timeline-loading'); profileId-change widget test added; sprint-status.yaml added to File List.

### File List

- _bmad-output/implementation-artifacts/sprint-status.yaml
- apps/api/src/modules/profiles/profiles.service.ts
- apps/api/src/modules/reports/reports.service.ts
- apps/api/src/modules/reports/reports.controller.ts
- apps/api/src/modules/reports/reports.service.spec.ts
- apps/api/src/modules/reports/reports.controller.spec.ts
- apps/api/test/app.e2e-spec.ts
- apps/mobile/lib/features/reports/reports_repository.dart
- apps/mobile/lib/features/reports/api_reports_repository.dart
- apps/mobile/lib/features/reports/screens/timeline_screen.dart
- apps/mobile/lib/features/auth/screens/home_screen.dart
- apps/mobile/lib/main.dart
- apps/mobile/test/timeline_test.dart

## Change Log

| Date       | Author | Change |
|------------|--------|--------|
| 2026-03-15 | AI     | Story implemented: GET /reports?profileId=, listReportsByProfile/listReports, ProfilesService.getProfile; Flutter TimelineScreen, listReports in repo, home timeline nav; unit + widget tests. |
