# Story 1.8: Communication Preferences Management

Status: done

## Story

As an authenticated user,
I want communication preference controls,
So that I receive relevant notices.

## Acceptance Criteria

1. **Given** I am authenticated
   **When** I call `GET /account/communication-preferences`
   **Then** I receive my current preferences
   **And** each preference includes: `category`, `enabled`, `mandatory` (where `mandatory: true` means the category cannot be disabled by the user)
   **And** response uses the standard success envelope with `correlationId`

2. **Given** I am authenticated
   **When** I call `PATCH /account/communication-preferences` with a valid body (e.g. `{ "productEmails": false }`)
   **Then** only non-mandatory categories are updated
   **And** mandatory categories are ignored if sent (remain `enabled: true`)
   **And** response returns the full updated preferences object in the envelope

3. **Given** I update preferences via the API
   **When** changes are saved
   **Then** future notification delivery (Epic 6) will respect these settings
   **And** mandatory notices (security, compliance) remain enforced by policy and cannot be turned off

4. **Given** I am not authenticated (missing or invalid `Authorization` header)
   **When** I call either communication-preferences endpoint
   **Then** I receive `401` with `{ success: false, code: "AUTH_UNAUTHORIZED", ... }`

5. **Given** I am on the Flutter app communication preferences screen (from account/settings)
   **When** the screen loads
   **Then** I see each preference category with a toggle (Switch or equivalent)
   **And** mandatory categories show a non-interactive or disabled toggle with an explanatory label (e.g. "Required for your account")

6. **Given** I change a non-mandatory preference and tap Save
   **When** the save succeeds
   **Then** the UI reflects the new state and shows success feedback
   **And** on next load, the saved preference is displayed

7. **Given** the API returns an error when saving preferences
   **When** the Flutter app handles the response
   **Then** an inline error message is shown (no SnackBar per project convention)
   **And** the form state is not lost

## Tasks / Subtasks

### API — Types and DTOs (AC: 1, 2, 3)

- [x] Add communication preference types in `account.types.ts` or new `account/communication-preferences.types.ts` (AC: 1, 2)
  - [x] `CommunicationPreferenceItem`: `{ category: string; enabled: boolean; mandatory: boolean }`
  - [x] `CommunicationPreferences`: `{ preferences: CommunicationPreferenceItem[] }` or keyed object
  - [x] Categories: `security` (mandatory), `compliance` (mandatory), `product` (optional). Constants for category keys.

- [x] Add DTO in `account.dto.ts` or new file (AC: 2)
  - [x] `UpdateCommunicationPreferencesDto`: optional booleans per non-mandatory category only (e.g. `productEmails?: boolean`); validate with `@IsOptional()` and `@IsBoolean()` where applicable

### API — Service and Persistence (AC: 1, 2, 3)

- [x] Extend `AccountService` or add dedicated service for preferences (AC: 1, 2, 3)
  - [x] `getCommunicationPreferences(userId: string): CommunicationPreferences` — return current state; default for new users: security=true (mandatory), compliance=true (mandatory), product=true (optional)
  - [x] `updateCommunicationPreferences(userId: string, dto: UpdateCommunicationPreferencesDto): CommunicationPreferences` — apply only non-mandatory fields; mandatory categories always remain true; return full updated preferences
  - [x] In-memory store: `Map<userId, Partial<...>>` or extend existing user in-memory representation; no DB until persistence story

### API — Controller (AC: 1, 2, 4)

- [x] Add endpoints in `account.controller.ts` (AC: 1, 2, 4)
  - [x] `GET /account/communication-preferences` — `@UseGuards(AuthGuard)`, delegate to service, return `successResponse(data, getCorrelationId(req))`
  - [x] `PATCH /account/communication-preferences` — `@UseGuards(AuthGuard)`, body `UpdateCommunicationPreferencesDto`, delegate to service, return full preferences in envelope

### API — Tests (AC: 1, 2, 4)

- [x] Unit tests for preferences service (AC: 1, 2)
  - [x] `getCommunicationPreferences`: returns defaults for user with no stored prefs; returns stored prefs when present
  - [x] `updateCommunicationPreferences`: updates only product (or other optional) category; leaves mandatory categories true even if client sends false

- [x] Unit tests for controller (AC: 1, 2, 4)
  - [x] GET and PATCH delegate to service and wrap in envelope; unauthenticated not tested here (e2e)

- [x] E2E tests in `app.e2e-spec.ts` (AC: 1, 2, 4)
  - [x] `GET /account/communication-preferences` with valid token → 200, body has preferences array/object with mandatory flags
  - [x] `PATCH /account/communication-preferences` with `{ productEmails: false }` → 200, response includes updated prefs
  - [x] Either endpoint without token → 401 `AUTH_UNAUTHORIZED`

### Flutter — Repository and Model (AC: 5, 6, 7)

- [x] Create `apps/mobile/lib/features/account/communication_preferences_repository.dart` (or under account)
  - [x] Model: `CommunicationPreferenceItem` (category, enabled, mandatory); `CommunicationPreferences` (list or map)
  - [x] Abstract `CommunicationPreferencesRepository`: `Future<CommunicationPreferences> getPreferences()`, `Future<CommunicationPreferences> updatePreferences(Map<String, bool> updates)`

- [x] Create in-memory implementation for tests and dev
  - [x] Default: security=true (mandatory), compliance=true (mandatory), product=true (optional)
  - [x] `updatePreferences`: only apply non-mandatory keys; return updated state

### Flutter — Screen and Navigation (AC: 5, 6, 7)

- [x] Create `apps/mobile/lib/features/account/screens/communication_preferences_screen.dart`
  - [x] Load preferences in `initState`; show loading indicator while fetching
  - [x] List of rows: category label + Switch (or disabled Switch + "Required" for mandatory)
  - [x] Local state for dirty optional toggles; "Save" button to call `updatePreferences` with changes
  - [x] On save success: refresh from repo and show success (e.g. brief text or state update); on error: set `_error` and display inline with `TextStyle(color: Colors.red)`
  - [x] Widget keys: e.g. `Key('pref-security')`, `Key('pref-compliance')`, `Key('pref-product')`, `Key('pref-save')`, `Key('communication-preferences-error')`

- [x] Wire screen into app: add `_AuthView.communicationPreferences`; entry from HomeScreen or account profile area (e.g. "Communication preferences" link/button)

### Flutter — Widget Tests (AC: 5, 6, 7)

- [x] Create `apps/mobile/test/communication_preferences_test.dart`
  - [x] Screen renders categories; mandatory ones have disabled toggle or visible "Required" label
  - [x] Toggling optional category and Save calls repository `updatePreferences` with correct payload
  - [x] Error from repository shows inline error widget
  - [x] Use `Key`-based finds per project convention

## Dev Notes

### Category and Mandatory Policy

- **Security**: login alerts, password reset, suspicious activity — mandatory (policy); user cannot disable.
- **Compliance**: policy updates, legal notices — mandatory (policy); user cannot disable.
- **Product**: optional; user can opt out of product/news/feature notifications.

API must reject or ignore attempts to set mandatory categories to `false`. Flutter UI must not allow toggling mandatory categories off.

### API Placement

Preferences live under `account` module (user-scoped account settings). No new module required unless product prefers a dedicated `preferences` module; current spec uses `GET/PATCH /account/communication-preferences`.

### Consistency with Existing Patterns

- Reuse `AuthGuard`, `getCorrelationId`, `successResponse` from existing account and auth modules.
- Error envelope: same shape as other account endpoints (`success: false`, `code`, `message`, `correlationId`).
- Flutter: repository abstraction + in-memory impl; state `_loading`, `_error`; inline error text; Keys for test targets (no `find.text` for assertions).

### Future Persistence

When moving off in-memory: add `user_communication_preferences` table or columns on `users` (e.g. `communication_preferences JSONB`). Migration and schema design out of scope for this story; service interface should allow swapping store without changing controller or Flutter.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.8]
- [Source: _bmad-output/planning-artifacts/epics.md#FR60]
- [Source: _bmad-output/planning-artifacts/architecture.md#API & Communication Patterns]
- [Source: _bmad-output/implementation-artifacts/1-3-account-profile-management-view-update-basic-info.md (account module, repository pattern)]
- [Source: _bmad-output/implementation-artifacts/1-7-active-session-device-list-and-revoke.md#Flutter Pattern Reuse]

## Validation (Post-Creation)

- **Sections**: Story, Acceptance Criteria, Tasks/Subtasks, Dev Notes, References, Dev Agent Record — present.
- **AC → Tasks**: AC1 (GET prefs) → Types, Service get, Controller GET, E2E. AC2 (PATCH) → DTO, Service update, Controller PATCH, E2E. AC3 (future delivery) → Dev note + service contract. AC4 (401) → Controller + E2E. AC5–7 (Flutter) → Repository, Screen, Widget tests.
- **Epic/FR**: Aligns with Epic 1 Story 1.8 and FR60 (account communication preferences for security and compliance).
- **Patterns**: Account module extension, AuthGuard, success envelope, correlationId; Flutter Keys, inline error, repository abstraction.

## Dev Agent Record

### Agent Model Used

claude-4.6-sonnet-medium-thinking (2026-03-06)

### Debug Log References

- Fixed pre-existing e2e rate-limit exhaustion: added `x-forwarded-for` headers with unique IPs to all `beforeAll` login calls in `app.e2e-spec.ts` (Account Profile, Consent, Profiles, Communication Preferences describe blocks). The shared IP rate limit (maxCount=10) was being exhausted by the `enforces rate limiting` top-level test, causing all subsequent describe-block `beforeAll` logins to 429.

### Completion Notes List

- Extended `account.types.ts` with `CommunicationPreferenceItem`, `CommunicationPreferences`, `COMM_PREF_CATEGORY` constants, and `MANDATORY_CATEGORIES` set.
- Added `UpdateCommunicationPreferencesDto` to `account.dto.ts` with `@IsOptional() @IsBoolean() productEmails?: boolean`.
- Extended `AccountService` with `getCommunicationPreferences` and `updateCommunicationPreferences` methods backed by an in-memory `Map<userId, {productEmails}>` store.
- Added `GET /account/communication-preferences` and `PATCH /account/communication-preferences` endpoints to `AccountController`, both guarded by `AuthGuard`.
- Added unit tests for service (4 cases) and controller (2 cases) covering defaults, updates, and mandatory category enforcement.
- Added 5 e2e tests in `app.e2e-spec.ts`: GET returns all 3 categories with mandatory flags, PATCH updates product, persistence across GET, and 401 for both endpoints without token.
- Created Flutter `communication_preferences_repository.dart` (abstract + models + constants) and `in_memory_communication_preferences_repository.dart`.
- Created `CommunicationPreferencesScreen` with loading state, Switch per category (mandatory = `onChanged: null`), local pending changes, Save button, inline error display.
- Wired into `DoclyzerApp`: added `communicationPreferences` to `_AuthView` enum, injected repository, added case to switch expression; added "Communication Preferences" button to `HomeScreen`.
- 6 Flutter widget tests covering render, mandatory labels, disabled switches, toggle+save payload, and error display.
- All tests: 98 API unit + 53 e2e + 48 Flutter = 199 passing, 0 failing.

### Senior Developer Review (AI)

**Date:** 2026-03-06  
**Reviewer:** Vishnu (AI code review)  
**Outcome:** Done — 2 medium and 4 low issues found and fixed.

**Fixes applied:**
- [M1] Added `sprint-status.yaml` to File List (was changed but undocumented).
- [M2] Flutter test used `find.text()` instead of `find.byKey()` — added `Key('pref-{category}-mandatory-hint')` to mandatory hint `Text` widgets; test updated to `find.byKey`.
- [L3] AC6 was missing explicit success feedback — added `_successMessage` state + `Key('communication-preferences-success')` inline text shown after successful save; new widget test added.
- [L4] Save button was always enabled — now `onPressed: _pendingChanges.isEmpty ? null : _save`.
- [L5] Controller unit tests for comm prefs endpoints lacked `correlationId` assertion — added.
- [L6] Mandatory hint used `Colors.grey` (hardcoded) — changed to `Theme.of(context).colorScheme.onSurfaceVariant`.

**Change Log entry:** Review complete. 6 issues fixed. Tests: 18 API unit, 7 Flutter widget (was 6). All passing.

### File List

- `apps/api/src/modules/account/account.types.ts` (modified)
- `apps/api/src/modules/account/account.dto.ts` (modified)
- `apps/api/src/modules/account/account.service.ts` (modified)
- `apps/api/src/modules/account/account.controller.ts` (modified)
- `apps/api/src/modules/account/account.service.spec.ts` (modified)
- `apps/api/src/modules/account/account.controller.spec.ts` (modified)
- `apps/api/test/app.e2e-spec.ts` (modified)
- `apps/mobile/lib/features/account/communication_preferences_repository.dart` (new)
- `apps/mobile/lib/features/account/in_memory_communication_preferences_repository.dart` (new)
- `apps/mobile/lib/features/account/screens/communication_preferences_screen.dart` (new)
- `apps/mobile/lib/main.dart` (modified)
- `apps/mobile/lib/features/auth/screens/home_screen.dart` (modified)
- `apps/mobile/test/communication_preferences_test.dart` (new)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (modified)
