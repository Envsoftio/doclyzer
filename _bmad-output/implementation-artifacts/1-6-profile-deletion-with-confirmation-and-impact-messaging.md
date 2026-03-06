# Story 1.6: Profile Deletion with Confirmation and Impact Messaging

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As an account holder,
I want guarded profile deletion,
so that I avoid accidental data-context loss.

## Acceptance Criteria

1. **Given** I am authenticated and have one or more profiles
   **When** I call `DELETE /profiles/:id` for a profile I own
   **Then** that profile is removed from my account
   **And** the response returns the updated profile list (same shape as `GET /profiles`) with that profile removed
   **And** if the deleted profile was active, another profile is set active (or none if it was the last)
   **And** the response uses the standard success envelope with `correlationId`

2. **Given** I attempt to delete a profile that does not exist or belongs to another user
   **When** the request is processed
   **Then** I receive `404` with `{ success: false, code: "PROFILE_NOT_FOUND", ... }`

3. **Given** I am not authenticated (missing or invalid `Authorization` header)
   **When** I call `DELETE /profiles/:id`
   **Then** I receive `401` with `{ success: false, code: "AUTH_UNAUTHORIZED", ... }`

4. **Given** I am on the Flutter app on the profile list screen
   **When** I tap a delete control on a profile (e.g. delete icon or "Delete" action)
   **Then** a confirmation dialog is shown with:
   **And** title and short copy explaining the action (e.g. "Delete profile?")
   **And** impact messaging (e.g. "This profile will be removed. Any data linked to it will be affected." — report count can be 0 for this story)
   **And** primary destructive action (e.g. "Delete") and secondary "Cancel"
   **And** destructive action uses semantic danger styling per UX (e.g. error/destructive color)

5. **Given** I confirm deletion in the dialog
   **When** the delete request succeeds
   **Then** the profile is removed from the list and I remain on the profile list (or navigate back appropriately)
   **And** if the deleted profile was active, the UI reflects the new active profile

6. **Given** I cancel the confirmation dialog
   **When** I dismiss it
   **Then** no deletion occurs and I remain on the profile list

## Tasks / Subtasks

- [x] Add delete to ProfilesService and API (AC: 1, 2, 3)
  - [x] Reuse `PROFILE_NOT_FOUND` from `profiles.types.ts` (already defined in 1.5) — no change needed to types
  - [x] In `profiles.service.ts` — add `deleteProfile(userId: string, profileId: string): ProfileWithActive[]`; remove profile from in-memory store; if deleted profile was active, set `activeProfileId` to another profile in the list or clear; return `getProfiles(userId)` after delete
  - [x] In `profiles.controller.ts` — add `@Delete(':id')` route (AuthGuard already at class level); extract userId from `req.user`, call `profilesService.deleteProfile(userId, params.id)`, return `successResponse(data, getCorrelationId(req))` with updated list; HTTP 200
  - [x] Unauthenticated or not-found behavior: same as 1.5 (401 via AuthGuard, 404 via ProfileNotFoundException)

- [x] Unit test ProfilesService.deleteProfile (AC: 1, 2)
  - [x] In `profiles.service.spec.ts` — delete removes profile and returns updated list; delete of active profile switches active to another; delete of last profile returns empty list and clears active; delete of non-existent or wrong user throws `ProfileNotFoundException`

- [x] Unit test ProfilesController delete (AC: 1, 3)
  - [x] In `profiles.controller.spec.ts` — DELETE delegates to service and returns success envelope with list; exceptions propagate

- [x] E2E tests for DELETE /profiles/:id (AC: 1, 2, 3)
  - [x] In `apps/api/test/app.e2e-spec.ts` — extend Profiles describe or add: DELETE with valid token and owned profile → 200, list no longer contains that profile; DELETE with valid token for non-existent id → 404 PROFILE_NOT_FOUND; DELETE without token → 401 AUTH_UNAUTHORIZED; if deleted was active, next GET /profiles shows new active or empty

- [x] Flutter: repository and UI (AC: 4, 5, 6)
  - [x] In `profiles_repository.dart` — add `Future<void> deleteProfile(String id);` to abstract and implement in `in_memory_profiles_repository.dart` (remove from list; clear or reassign `_activeProfileId` if deleted was active)
  - [x] In `profile_list_screen.dart` — add delete control per profile (e.g. IconButton with Icons.delete); on tap show confirmation dialog (AlertDialog) with title, impact message, Delete (destructive) and Cancel; on confirm call `profilesRepository.deleteProfile(profile.id)`, then `_loadProfiles()`, stay on list
  - [x] Widget keys for tests: delete button `Key('profile-delete-${profile.id}')`; dialog confirm `Key('profile-delete-confirm')`, cancel `Key('profile-delete-cancel')`
  - [x] Use Material 3 destructive styling for the confirm button (e.g. `ButtonStyle(foregroundColor: Theme.of(context).colorScheme.error)`)
  - [x] No stacking modals per UX; single confirmation dialog

- [x] Flutter widget tests (AC: 4, 5, 6)
  - [x] In `profile_list_test.dart` (or new tests) — delete control present; tapping delete shows dialog with expected title/copy; tapping Cancel closes dialog and does not call delete; tapping Delete calls `deleteProfile(id)` and refreshes list (mock repository)

## Dev Notes

### Critical Architecture Notes

- **ProfilesService remains in-memory** — same `Map<string, Profile[]>` and `Map<string, string>` activeProfileId as Story 1.5. `deleteProfile` is synchronous: remove from array, update or clear `activeProfileId`, return `getProfiles(userId)`.
- **Authorization** — same as 1.5: resolve profile by `userId` first; if `profileId` not in that user's list, throw `ProfileNotFoundException` (404, no existence leak).
- **Response shape** — `DELETE /profiles/:id` returns the same envelope as `GET /profiles`: `{ success: true, data: ProfileWithActive[], correlationId }` so the client can refresh in one round-trip.
- **Active profile after delete** — if deleted profile was active and other profiles exist, set `activeProfileId` to the first remaining profile (e.g. `userProfiles[0].id` after removal). If deleted was the last profile, clear `activeProfileId` for that user.
- **No new exception type** — reuse `ProfileNotFoundException` for non-existent or unauthorized profile id.
- **PII** — do not log profile name or id in success path; log only `correlationId`.

### API Contract

- `DELETE /profiles/:id` — 200 OK, body: same as `GET /profiles` (full updated list). 404 if profile not found or not owned. 401 if unauthenticated.

### Flutter

- **Dialog** — Use `showDialog` with `AlertDialog` (or `AlertDialog.adaptive`). Title: e.g. "Delete profile?" Body: impact message. Actions: `TextButton` Cancel, destructive-styled `FilledButton` or `TextButton` "Delete". On Delete: `Navigator.of(context).pop(true)`, then call repository and refresh.
- **Repository** — `deleteProfile(String id)` returns `Future<void>`. In-memory impl: remove from `_profiles`, if `_activeProfileId == id` set to `_profiles.isNotEmpty ? _profiles.first.id : null` (or clear).
- **Profile list** — Delete control per row (e.g. `IconButton(icon: Icon(Icons.delete), onPressed: () => _showDeleteConfirm(profile))`). Key for tests: e.g. `Key('profile-delete-${profile.id}')`.

### Project Structure (additions only)

- No new API files beyond extending existing `profiles.service.ts`, `profiles.controller.ts`, `profiles.service.spec.ts`, `profiles.controller.spec.ts`.
- Flutter: only extend `profiles_repository.dart`, `in_memory_profiles_repository.dart`, `profile_list_screen.dart`; add/extend tests in `profile_list_test.dart`.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.6]
- [Source: _bmad-output/planning-artifacts/prd.md#FR10]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Destructive, Dialogs]
- [Source: _bmad-output/implementation-artifacts/1-5-multi-profile-create-edit-switch.md#Dev Notes, API Response Shape, Architecture Compliance]

## Technical Requirements

- `DELETE /profiles/:id` protected by `@UseGuards(AuthGuard)` at controller level (same as existing routes).
- `ProfilesService.deleteProfile` is synchronous (no I/O); do not make it `async` (require-await).
- Response: `successResponse(updatedList, getCorrelationId(req))`; `updatedList` is `ProfileWithActive[]`.
- Flutter: confirmation before delete; impact message in dialog; destructive styling for confirm button.

## Architecture Compliance

- Same module pattern as 1.5: ProfilesModule, thin controller, service owns logic, `ProfileNotFoundException` for 404.
- Correlation ID and response envelope per project standards.

## Library / Framework Requirements

- Backend: NestJS, TypeScript (no new deps).
- Flutter: Material 3; use existing `FilledButton`/`TextButton` and theme for destructive action (e.g. `ButtonStyle(foregroundColor: Theme.of(context).colorScheme.error)` or equivalent).

## Testing Requirements

- **Service:** delete removes profile; delete active switches active; delete last returns empty list; delete non-existent throws.
- **Controller:** DELETE delegates to service and wraps in envelope; exceptions propagate.
- **E2E:** DELETE with token + valid id → 200 and list updated; DELETE non-existent → 404; DELETE no token → 401.
- **Flutter:** Dialog shown on delete tap; Cancel does not delete; Confirm calls repository and refreshes; delete control has test key.

## Previous Story Intelligence (1.5)

- **ProfilesService** uses two in-memory Maps; all methods synchronous. Add `deleteProfile(userId, profileId)` that: finds index, throws `ProfileNotFoundException` if -1; removes from array; if `activeProfileId.get(userId) === profileId`, set active to `userProfiles[0]?.id` or delete key; return `getProfiles(userId)`.
- **Controller** pattern: `@Delete(':id')`, get userId from `(req.user as AuthUser).id`, get id from `@Param('id')`, call service, return `successResponse(data, getCorrelationId(req))`.
- **Flutter** `ProfilesRepository` and `InMemoryProfilesRepository`: add `deleteProfile(String id)`. `ProfileListScreen` already has list and callbacks; add delete icon/button and confirmation dialog.
- **Widget keys** — kebab-case, e.g. `Key('profile-delete-${profile.id}')`, `Key('profile-delete-dialog')`, `Key('profile-delete-confirm')`, `Key('profile-delete-cancel')` for testability.
- **No new screens** — only extend profile list screen with delete and dialog.

## Project Context Reference

- [Source: _bmad-output/project-context.md] — require-await, AuthGuard, response envelope, no PHI in logs, repository pattern (Flutter), FilledButton/TextButton, error display pattern.

## Story Completion Status

- Story context file generated with implementation guardrails and testing standards.
- Validated against create-story checklist: PROFILE_NOT_FOUND reuse clarified; `@Delete(':id')` and HTTP 200 called out; Flutter dialog widget keys added to tasks.
- Ready for `dev-story` execution.

## Dev Agent Record

### Agent Model Used

claude-4.6-sonnet-medium-thinking

### Debug Log References

No blocking issues encountered. All tasks completed in single pass.

### Completion Notes List

- `ProfilesService.deleteProfile` — synchronous (no await), splices profile from array, uses `activeProfileId.delete()` to clear key when last profile is removed, falls back to `userProfiles[0].id` when remaining profiles exist. Returns full updated list via `getProfiles(userId)`.
- `ProfilesController.deleteProfile` — `@Delete(':id')`, HTTP 200 (default), delegates to service, wraps in `successResponse`. `Delete` decorator imported alongside existing NestJS imports.
- E2E suite extended within existing `Profiles` describe block; 5 new tests covering 401/404/200/state-after-delete flows. All 42 E2E tests pass.
- Flutter: `deleteProfile(String id)` added to abstract class and `InMemoryProfilesRepository`. `_showDeleteConfirm` method on `_ProfileListScreenState` uses `showDialog` + `AlertDialog`; Delete button styled with `TextButton.styleFrom(foregroundColor: colorScheme.error)`.
- Widget keys match spec: `Key('profile-delete-${profile.id}')`, `Key('profile-delete-confirm')`, `Key('profile-delete-cancel')`.
- All tests: API unit 80/80, E2E 42/42, Flutter widget 12/12. Zero regressions.

### File List

**Modified (API):**
- `apps/api/src/modules/profiles/profiles.service.ts`
- `apps/api/src/modules/profiles/profiles.controller.ts`
- `apps/api/src/modules/profiles/profiles.service.spec.ts`
- `apps/api/src/modules/profiles/profiles.controller.spec.ts`
- `apps/api/test/app.e2e-spec.ts`

**Modified (Flutter):**
- `apps/mobile/lib/features/profiles/profiles_repository.dart`
- `apps/mobile/lib/features/profiles/in_memory_profiles_repository.dart`
- `apps/mobile/lib/features/profiles/screens/profile_list_screen.dart`
- `apps/mobile/test/profile_list_test.dart`

### Senior Developer Review (AI)

**Date:** 2026-03-06  
**Outcome:** Changes Requested → Resolved

**Action Items:**
- [x] [Med] No try/catch around `deleteProfile` in Flutter `_showDeleteConfirm` — added error handling with `_error` state
- [x] [Low] Widget tests using `find.text` instead of keys — replaced all instances with key-based finders; added `Key('profile-active-chip-${id}')` and `Key('profile-delete-dialog')` to screen
- [x] [Low] E2E test name misleading: "DELETE active profile → remaining profile becomes active" → renamed to "DELETE last profile → empty list returned"
- [x] [Low] `Theme.of(context)` used inside dialog builder — corrected to `Theme.of(ctx)`

### Change Log

- 2026-03-06: Implemented story 1.6 — `DELETE /profiles/:id` endpoint with 401/404/200 flows; Flutter delete button with confirmation dialog and destructive styling; full unit, E2E, and widget test coverage.
- 2026-03-06: Code review fixes — Flutter delete error handling; all `find.text` replaced with key finders; new widget keys (`profile-active-chip`, `profile-delete-dialog`); E2E test name corrected; `Theme.of(ctx)` fix.
