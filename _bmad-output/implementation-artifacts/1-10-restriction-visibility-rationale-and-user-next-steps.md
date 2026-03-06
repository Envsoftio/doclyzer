# Story 1.10: Restriction Visibility, Rationale, and User Next Steps

Status: done

## Story

As an authenticated user,
I want restriction clarity,
So that blocked actions are understandable and recoverable.

## Acceptance Criteria

1. **Given** I am authenticated and my account is not restricted
   **When** I call `GET /account/restriction-status`
   **Then** I receive `{ isRestricted: false }` (or equivalent) in the envelope
   **And** response uses the standard success envelope with `correlationId`

2. **Given** I am authenticated and my account has a protective restriction applied (e.g. by superadmin in Epic 5)
   **When** I call `GET /account/restriction-status`
   **Then** I receive `isRestricted: true` and at least: `rationale` (string), `nextSteps` (string), and optionally `restrictedActions` (array of action codes or labels describing what is limited)
   **And** the response uses the standard success envelope with `correlationId`

3. **Given** I am not authenticated
   **When** I call `GET /account/restriction-status`
   **Then** I receive `401` with `{ success: false, code: "AUTH_UNAUTHORIZED", ... }`

4. **Given** I am on the Flutter app and my account is restricted
   **When** I access any affected surface (e.g. home, account, or a screen where actions may be limited)
   **Then** I see restriction status: a visible banner, block, or dedicated area showing that my account is restricted
   **And** I see the rationale and next steps text so that blocked actions are understandable and I know how to recover (e.g. contact support, wait for review)

5. **Given** I am on the Flutter app and my account is not restricted
   **When** I access the same surfaces
   **Then** no restriction banner or block is shown

6. **Given** restriction data is available from the API (e.g. returned with profile or from a dedicated restriction-status call)
   **When** the Flutter app loads or navigates to an affected screen
   **Then** it fetches or uses cached restriction status and displays it when `isRestricted` is true
   **And** rationale and next steps are readable and accessible (e.g. screen reader friendly per NFR17/NFR18)

## Tasks / Subtasks

### API — Types and Service (AC: 1, 2)

- [x] Add restriction types (e.g. in `account.types.ts` or `restriction.types.ts`)
  - [x] `RestrictionStatus`: `{ isRestricted: boolean; rationale?: string; nextSteps?: string; restrictedActions?: string[] }`
  - [x] When restricted, all of `rationale` and `nextSteps` must be present; `restrictedActions` optional

- [x] Implement restriction status read (in `AccountService` or dedicated service)
  - [x] `getRestrictionStatus(userId: string): RestrictionStatus` — look up user in restriction store; if not restricted return `{ isRestricted: false }`; if restricted return `{ isRestricted: true, rationale, nextSteps, restrictedActions? }`
  - [x] In-memory store: e.g. `Map<userId, { rationale: string; nextSteps: string; restrictedActions?: string[] }>`. Empty map = no users restricted. Superadmin (Epic 5) will write to this store; this story only reads. For MVP, store can be empty so all users get `isRestricted: false`.

### API — Controller (AC: 1, 2, 3)

- [x] Add `GET /account/restriction-status` in `account.controller.ts`
  - [x] `@UseGuards(AuthGuard)`; extract `userId` from `req.user`; call service `getRestrictionStatus(userId)`; return `successResponse(data, getCorrelationId(req))`

### API — Tests (AC: 1, 2, 3)

- [x] Unit tests: `getRestrictionStatus` returns `isRestricted: false` when user not in store; returns full payload when user is restricted
- [x] E2E: `GET /account/restriction-status` with valid token → 200 and body with `isRestricted`; without token → 401

### Flutter — Repository and Model (AC: 4, 5, 6)

- [x] Add restriction model: `RestrictionStatus` with `isRestricted`, `rationale?`, `nextSteps?`, `restrictedActions?`
- [x] Extend account or auth repository to fetch restriction status, or add `RestrictionRepository`: `Future<RestrictionStatus> getStatus()`. In-memory impl: return `RestrictionStatus(isRestricted: false)` by default; test impl can override to simulate restricted state.

### Flutter — UI and Surfaces (AC: 4, 5, 6)

- [x] Fetch restriction status when app loads (e.g. after login or with profile) or when entering affected screens; cache in app state if needed
- [x] When `isRestricted: true`, show a persistent banner or block on home/account (and other affected surfaces) with: restriction message, rationale, next steps. Use semantic labels and readable contrast (accessibility)
- [x] When `isRestricted: false`, do not show the restriction UI
- [x] Widget keys for restriction banner and text (e.g. `Key('restriction-banner')`, `Key('restriction-rationale')`, `Key('restriction-next-steps')`) for tests

### Flutter — Widget Tests (AC: 4, 5, 6)

- [x] When repository returns restricted status, banner (or equivalent) is visible and shows rationale and next steps
- [x] When repository returns non-restricted status, banner is not shown
- [x] Use Key-based finds only

## Dev Notes

### Scope: Read-Only User Visibility

This story is the **user-facing read path** for restriction state. Who sets the restriction (superadmin) and how (Epic 5) is out of scope. This story only: (1) exposes an API that returns the current user’s restriction status, and (2) shows that status in the Flutter app. The in-memory “restriction store” can be a simple Map; Epic 5 (or a later story) will populate it. For MVP, the map can be empty so the endpoint always returns `isRestricted: false` until superadmin restriction flows exist.

### Affected Surfaces

“Affected surfaces” = screens where the user might try actions that are limited when restricted (e.g. home, account/settings). Minimum: show the restriction banner on home and account so the user always sees status, rationale, and next steps when restricted. Additional screens can be added later.

### Consistency

- Reuse `AuthGuard`, `getCorrelationId`, `successResponse`.
- Flutter: repository abstraction, Keys for tests, inline or banner error/status patterns consistent with 1-6/1-7.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.10]
- [Source: _bmad-output/planning-artifacts/epics.md#FR70, FR71]
- [Source: _bmad-output/planning-artifacts/architecture.md#Restriction controls, Auditability]
- [Source: _bmad-output/implementation-artifacts/1-3-account-profile-management-view-update-basic-info.md (account module)]
- [Source: _bmad-output/implementation-artifacts/1-7-active-session-device-list-and-revoke.md#Flutter Pattern Reuse]

## Validation (Post-Creation)

- **Sections**: Story, AC, Tasks, Dev Notes, References, Dev Agent Record — present.
- **AC → Tasks**: AC1–2 (API read) → types, service getRestrictionStatus, controller GET, tests. AC3 (401) → Guard, E2E. AC4–6 (Flutter) → repo, fetch, banner/block UI, Keys, widget tests.
- **Epic/FR**: Aligns with Epic 1 Story 1.10, FR70 (restriction visibility), FR71 (rationale and next steps).
- **Patterns**: Account module; read-only restriction status; Flutter banner + Keys.

## Dev Agent Record

### Agent Model Used

claude-4.6-sonnet-medium-thinking — 2026-03-06

### Debug Log References

No blockers encountered. Implemented cleanly on first pass.

### Completion Notes List

- Added `RestrictionStatus` interface to `account.types.ts`
- Added `restrictionStore` (private Map) and `getRestrictionStatus()` to `AccountService`; store is empty by default so all users get `isRestricted: false` until Epic 5 superadmin flows populate it
- Added `GET /account/restriction-status` controller endpoint guarded by `AuthGuard`; returns standard success envelope with correlationId
- All 120 API unit tests pass (40 account-specific tests including 5 new ones for restriction)
- All 2 e2e restriction tests pass; full e2e suite clean
- Created `restriction_repository.dart` (abstract class + `RestrictionStatus` model) and `in_memory_restriction_repository.dart` (defaults to not-restricted; `setStatusForTest` utility for tests)
- Converted `HomeScreen` from `StatelessWidget` to `StatefulWidget`; fetches restriction status in `initState`; shows accessible banner with `Key('restriction-banner')`, `Key('restriction-rationale')`, `Key('restriction-next-steps')` when restricted; hidden when not restricted
- Wired `RestrictionRepository` into `DoclyzerApp` constructor and `_DoclyzerAppState.initState` following existing injectable repository pattern
- All 59 Flutter tests pass (3 new restriction tests)

### File List

- `apps/api/src/modules/account/account.types.ts` — added `RestrictionStatus` interface
- `apps/api/src/modules/account/account.service.ts` — added `restrictionStore`, `getRestrictionStatus()` with validation guard
- `apps/api/src/modules/account/account.controller.ts` — added `GET /account/restriction-status`
- `apps/api/src/modules/account/account.service.spec.ts` — added 5 unit tests for `getRestrictionStatus` (including invalid-entry guard)
- `apps/api/src/modules/account/account.controller.spec.ts` — added 2 unit tests for `getRestrictionStatus`
- `apps/api/test/app.e2e-spec.ts` — added `Restriction Status` describe block with 3 e2e tests (unrestricted, 401, restricted)
- `apps/mobile/lib/features/account/restriction_repository.dart` — new file: `RestrictionStatus` model + abstract `RestrictionRepository`
- `apps/mobile/lib/features/account/in_memory_restriction_repository.dart` — new file: in-memory implementation
- `apps/mobile/lib/features/auth/screens/home_screen.dart` — converted to StatefulWidget; added restriction banner
- `apps/mobile/lib/features/account/screens/account_profile_screen.dart` — added `RestrictionRepository` param and restriction banner
- `apps/mobile/lib/main.dart` — wired up `RestrictionRepository` injection for HomeScreen and AccountProfileScreen
- `apps/mobile/test/restriction_test.dart` — new file: 3 widget tests for HomeScreen restriction banner
- `apps/mobile/test/account_profile_test.dart` — updated to pass restriction repository; added 2 banner tests

### Change Log

- 2026-03-06: Implemented Story 1.10 — restriction visibility, rationale, and user next steps
- 2026-03-06: Code review fixes — banner added to AccountProfileScreen, service validation guard for empty rationale/nextSteps, e2e test for restricted user
