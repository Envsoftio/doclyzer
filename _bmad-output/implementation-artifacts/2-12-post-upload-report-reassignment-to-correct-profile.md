# Story 2.12: Post-Upload Report Reassignment to Correct Profile

Status: done

## Story

As an authenticated user,
I want to reassign a mistakenly scoped report to a different profile,
so that profile organization remains accurate.

## Acceptance Criteria

1. **Given** a report exists under the current profile and the user has other profiles,
   **When** the user selects "Reassign to profile" and picks a different profile,
   **Then** the report's profileId is updated, derived views (lab values, processing history) follow automatically (they are linked by reportId, not profileId), and the report disappears from the source profile's timeline.

2. **Given** the user attempts to reassign a report to the same profile it currently belongs to,
   **Then** a `BadRequestException` is returned (`REPORT_ALREADY_IN_PROFILE`) — no-op reassignment is not allowed.

3. **Given** the user does not own the target profile,
   **Then** the API returns 404 (profile not found via `profilesService.getProfile`).

4. **Given** the reportId does not exist or belongs to a different user,
   **Then** the API returns 404 (`ReportNotFoundException`).

5. **Given** the reassignment is confirmed,
   **When** the API succeeds,
   **Then** the Flutter screen navigates back (report is no longer in the source profile's timeline — calling `widget.onBack()`).

6. **Given** the user has only one profile (no other profiles to reassign to),
   **Then** the "Reassign" button is either hidden or disabled on the detail screen.

## Tasks / Subtasks

- [x] **Backend: Add `reassignReport` to ReportsService** (AC: 1, 2, 3, 4)
  - [x] Add method `async reassignReport(userId, reportId, targetProfileId): Promise<ReportDto>`
  - [x] UUID-validate both `reportId` and `targetProfileId`; throw `ReportNotFoundException` / `BadRequestException` for invalid UUIDs
  - [x] Find report where `{ id: reportId, userId }` — throw `ReportNotFoundException` if not found
  - [x] Validate user owns `targetProfileId` via `profilesService.getProfile(userId, targetProfileId)`
  - [x] Reject same-profile reassignment: throw `BadRequestException({ code: 'REPORT_ALREADY_IN_PROFILE', message: 'Report is already in the specified profile.' })`
  - [x] Update `entity.profileId = targetProfileId`; save with `reportRepo.save(entity)`
  - [x] Return `toDto(entity)` (no need to update storage key — it embeds old profileId but that is fine, access still works)
  - [x] Do NOT record a processing attempt for reassignment (attempts track parsing only)

- [x] **Backend: Add controller endpoint** (AC: 1–4)
  - [x] Add `@Post(':id/reassign')` endpoint in `ReportsController`
  - [x] Import and use `@Body()` decorator for `{ targetProfileId: string }`
  - [x] Validate `targetProfileId` is present in body; throw `BadRequestException` with meaningful message if missing
  - [x] Place the route **before** `@Get(':id')` and `@Post(':id/retry')` to avoid NestJS route shadowing (all `POST :id/…` routes are distinct, this is precautionary; critical ordering for `GET :id/…` already established)
  - [x] Return `successResponse(data, getCorrelationId(req))`

- [x] **Flutter: Extend `ReportsRepository` interface** (AC: 1)
  - [x] Add method `Future<Report> reassignReport(String reportId, String targetProfileId);` to `reports_repository.dart`

- [x] **Flutter: Implement in `ApiReportsRepository`** (AC: 1)
  - [x] Call `_client.post('v1/reports/$reportId/reassign', body: {'targetProfileId': targetProfileId})`
  - [x] Parse the returned `data` map into a `Report` object (same pattern as `retryParse`)

- [x] **Flutter: Pass `profilesRepository` through the widget tree** (AC: 1, 6)
  - [x] Add required `ProfilesRepository profilesRepository` param to `TimelineScreen` constructor
  - [x] Update `TimelineScreen._openReport` to pass `profilesRepository` to `ReportDetailScreen`
  - [x] Add required `ProfilesRepository profilesRepository` param to `ReportDetailScreen` constructor
  - [x] Update `main.dart`: pass `profilesRepository: _profilesRepository` to `TimelineScreen`

- [x] **Flutter: Add reassignment UX to `ReportDetailScreen`** (AC: 1, 5, 6)
  - [x] On `initState`, also load profiles via `widget.profilesRepository.getProfiles()`; store as `List<Profile> _profiles` in state
  - [x] Derive `_otherProfiles` = profiles where `id != widget.profileId`
  - [x] Show `OutlinedButton` "Reassign to profile" (key: `'report-detail-reassign'`) only when `_otherProfiles.isNotEmpty`
  - [x] On tap: show `showDialog` with a list of `_otherProfiles` to pick from (keys: `'reassign-profile-{profile.id}'`)
  - [x] On profile selected: call `_onReassign(targetProfileId)` — sets loading state, calls `widget.reportsRepository.reassignReport(reportId, targetProfileId)`, then calls `widget.onBack()` on success
  - [x] On error during reassign: show error message in the dialog or as `_errorMessage` in the detail screen

## Dev Notes

### Storage Key Immutability
The `originalFileStorageKey` is stored in DB as `reports/${userId}/${profileId}/${reportId}.pdf` with the **original** profileId baked in. Do NOT attempt to move the file in B2 storage or update this field. The key is opaque — the file remains accessible at the original path regardless of which profile it's now assigned to.

### Lab Values and Processing Attempts Follow Automatically
`ReportLabValueEntity` and `ReportProcessingAttemptEntity` are both FK-linked by `reportId` (not `profileId`). Updating `report.profileId` is the only change needed — derived data moves transparently.

### Content Hash Duplicate Detection — Not a Concern Here
The duplicate check in `uploadReport` is keyed on `{ profileId, contentHash }`. Reassignment intentionally moves a report to another profile — it is a user-confirmed action. Do NOT add a duplicate-hash check to `reassignReport`.

### NestJS Controller Route Ordering
The existing controller has a critical comment: specific routes (`GET lab-trends`, `GET :id/attempts`, `GET :id/file`) MUST be declared before the generic `GET :id`. The new `POST :id/reassign` is a POST and does not conflict with existing GETs, but for consistency, declare it alongside other `POST :id/…` actions (`retry`, `keep-file`).

### Body Parsing in NestJS Controller
`@Body()` is already imported from `@nestjs/common` across other controllers in the project. Import it in the reports controller. The request body should be typed inline or via a simple DTO.

### ApiClient Already Supports POST with Body
`_client.post(path, body: {...})` is fully supported in `ApiClient.post` — the `body` parameter is optional. Use this directly in `ApiReportsRepository.reassignReport`.

### ReportDetailScreen — Loading Profiles
Load profiles in `initState` alongside the report. Store `_profiles` in state. If profile load fails, silently omit the reassign button (fail-open: don't break the screen if profiles can't be fetched). If profiles list has only the current profile, hide the reassign button.

### ReportDetailScreen — Call Sites
`ReportDetailScreen` is instantiated in two places:
1. `timeline_screen.dart:75` — `_openReport()` method. Add `profilesRepository: widget.profilesRepository` here.
2. `test/report_detail_test.dart` — tests already mock `ReportsRepository`. Tests are **not** in scope per project convention.

### Widget Keys (kebab-case as per project convention)
- Reassign button: `Key('report-detail-reassign')`
- Dialog profile items: `Key('reassign-profile-${profile.id}')`

### Project Structure
- Backend files to modify:
  - `apps/api/src/modules/reports/reports.service.ts` — add `reassignReport` method
  - `apps/api/src/modules/reports/reports.controller.ts` — add `@Post(':id/reassign')` endpoint, import `@Body()`
- Flutter files to modify:
  - `apps/mobile/lib/features/reports/reports_repository.dart` — add `reassignReport` method to abstract class
  - `apps/mobile/lib/features/reports/api_reports_repository.dart` — implement `reassignReport`
  - `apps/mobile/lib/features/reports/screens/timeline_screen.dart` — add `profilesRepository` param, pass to `ReportDetailScreen`
  - `apps/mobile/lib/features/reports/screens/report_detail_screen.dart` — add `profilesRepository` param, load profiles, show reassign button and dialog
  - `apps/mobile/lib/main.dart` — pass `profilesRepository: _profilesRepository` to `TimelineScreen`

### References
- Existing ownership check pattern: [reports.service.ts](apps/api/src/modules/reports/reports.service.ts) — `reportRepo.findOne({ where: { id: reportId, userId } })`
- Profile ownership validation: `profilesService.getProfile(userId, profileId)` — already used in `listReportsByProfile` and `getLabTrends`
- `successResponse + getCorrelationId` pattern: [reports.controller.ts](apps/api/src/modules/reports/reports.controller.ts)
- `toDto` helper: [reports.service.ts](apps/api/src/modules/reports/reports.service.ts) — use as-is after reassignment
- Flutter post-with-body: [api_client.dart](apps/mobile/lib/core/api_client.dart#L85) — `post(path, body: {...})`
- ProfilesRepository interface: [profiles_repository.dart](apps/mobile/lib/features/profiles/profiles_repository.dart) — `getProfiles()` returns `List<Profile>`
- `_profilesRepository` in main.dart: [main.dart](apps/mobile/lib/main.dart#L90) — already initialized as `ApiProfilesRepository(_apiClient!)`
- Previous story (2.11) pattern for new controller route: [2-11-processing-attempt-history-per-report.md](apps/../_bmad-output/implementation-artifacts/2-11-processing-attempt-history-per-report.md) — route ordering guidance

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- Added `reassignReport` method to `ReportsService` with UUID validation, ownership checks via `profilesService.getProfile`, same-profile guard (`REPORT_ALREADY_IN_PROFILE`), and DB update. No processing attempt recorded (parsing-only).
- Added `@Post(':id/reassign')` endpoint to `ReportsController` with `@Body()` import, body validation, placed before `@Post(':id/retry')` for consistency with route ordering guidance.
- Extended `ReportsRepository` abstract class with `reassignReport(reportId, targetProfileId)` method.
- Implemented `reassignReport` in `ApiReportsRepository` using `_client.post` with body, same parse pattern as `retryParse`.
- Added `ProfilesRepository profilesRepository` param to both `TimelineScreen` and `ReportDetailScreen`; updated `_openReport` to pass it through; updated `main.dart` to supply it.
- `ReportDetailScreen` loads profiles in `initState` (fail-open on error). Shows "Reassign to profile" `OutlinedButton` only when other profiles exist. Dialog lists other profiles with keyed `SimpleDialogOption`s. On selection, calls `reassignReport` and navigates back via `widget.onBack()` on success; surfaces error as `_errorMessage` on failure.
- Storage key immutability respected — original B2 key not modified.
- Code-review remediation: moved `POST :id/reassign` before `GET :id` to align controller ordering guidance.
- Code-review remediation: refreshed timeline after returning from report detail so reassigned reports disappear immediately from the source profile list.
- Code-review remediation: added visible reassignment error rendering on `ReportDetailScreen` for non-unparsed reports.
- Note: existing in-progress files from Story 2.11 remain in the git working tree and are not part of Story 2.12 scope.

## Change Log

- 2026-03-20: Applied code-review fixes (route order alignment, timeline refresh after reassignment navigation, reassignment error visibility), and updated story status to `done`.

### Senior Developer Review (AI)

- Outcome: **Changes Requested** issues were fixed automatically.
- Verified AC status after fixes:
  - AC1 implemented end-to-end (backend reassignment + source timeline refresh after returning from detail).
  - AC2–AC6 remain implemented.
- Git/story transparency note recorded for pre-existing cross-story working tree changes.

### File List

- apps/api/src/modules/reports/reports.service.ts
- apps/api/src/modules/reports/reports.controller.ts
- apps/mobile/lib/features/reports/reports_repository.dart
- apps/mobile/lib/features/reports/api_reports_repository.dart
- apps/mobile/lib/features/reports/screens/timeline_screen.dart
- apps/mobile/lib/features/reports/screens/report_detail_screen.dart
- apps/mobile/lib/main.dart
