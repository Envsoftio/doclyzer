# Story 1.5: Multi-Profile Create/Edit/Switch

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As an account holder,
I want to create, edit, and switch between patient profiles,
so that I can manage health records for myself and family members safely.

## Acceptance Criteria

1. **Given** I am authenticated
   **When** I call `POST /profiles` with a valid `name`
   **Then** a new profile is created scoped to my account
   **And** the response includes the profile's `id`, `name`, `createdAt`, and `isActive`
   **And** the first profile I create is automatically set as active (`isActive: true`)
   **And** the response uses the standard success envelope with a `correlationId`

2. **Given** I have one or more profiles
   **When** I call `GET /profiles`
   **Then** I receive a list of my profiles, each with `isActive` correctly reflecting the active state
   **And** exactly one profile is `isActive: true` (after the first profile has been created)

3. **Given** I have an existing profile
   **When** I call `PATCH /profiles/:id` with updated fields
   **Then** the mutable fields (`name`, `dateOfBirth`, `relation`) are updated
   **And** a subsequent `GET /profiles` reflects the changes

4. **Given** I have two or more profiles and one is active
   **When** I call `POST /profiles/:id/activate` for a different profile
   **Then** that profile becomes active (`isActive: true`)
   **And** the previously active profile becomes `isActive: false`
   **And** the response returns the full updated profile list

5. **Given** I attempt to access, update, or activate a profile that does not exist or belongs to another user
   **When** the request is processed
   **Then** I receive `404` with `{ success: false, code: "PROFILE_NOT_FOUND", ... }`

6. **Given** I am not authenticated (missing or invalid `Authorization` header)
   **When** I call any `/profiles/*` endpoint
   **Then** I receive `401` with `{ success: false, code: "AUTH_UNAUTHORIZED", ... }`

7. **Given** I am on the Flutter app
   **When** I navigate to the profile list screen
   **Then** I see all my profiles with a visible "active" indicator on the current profile
   **And** I can create a new profile via a form (name required, dateOfBirth and relation optional)
   **And** I can edit an existing profile via the same form
   **And** tapping "Set Active" on a non-active profile switches the active context

8. **Given** I am on the free tier and already have 1 profile
   **When** I attempt to create another profile (API `POST /profiles` or Flutter create flow)
   **Then** creation is blocked: API returns `403` with `{ success: false, code: "PROFILE_LIMIT_EXCEEDED", message: "Free plan allows 1 profile. Upgrade to add more." }`
   **And** Flutter shows upgrade CTA instead of "Add Profile" when at limit, or shows the error message on create attempt

## Tasks / Subtasks

- [x] Create `EntitlementsService` stub (AC: 8)
  - [x] Create `apps/api/src/modules/entitlements/entitlements.service.ts` — `getMaxProfiles(userId: string): number`; stub returns `1` for all users (free tier) until Epic 4 wires real plan data
  - [x] Create `apps/api/src/modules/entitlements/entitlements.module.ts` — provides `EntitlementsService`; register in `AppModule`

- [x] Create `ProfilesModule` API (AC: 1, 2, 3, 4, 5, 6, 8)
  - [x] Create `apps/api/src/modules/profiles/profiles.types.ts` — `Profile`, `ProfileWithActive` interfaces; `PROFILE_NOT_FOUND`, `PROFILE_LIMIT_EXCEEDED` error code constants
  - [x] Create `apps/api/src/modules/profiles/profiles.dto.ts` — `CreateProfileDto` and `UpdateProfileDto` with proper class-validator decorators
  - [x] Create `apps/api/src/modules/profiles/exceptions/profile-limit-exceeded.exception.ts` — `ProfileLimitExceededException extends ForbiddenException`
  - [x] Create `apps/api/src/modules/profiles/profiles.service.ts` — two in-memory Map stores; first profile auto-activates; limit check via EntitlementsService
  - [x] Create `apps/api/src/modules/profiles/profiles.controller.ts` — `@Controller('profiles') @UseGuards(AuthGuard)`; all 4 endpoints
  - [x] Create `apps/api/src/modules/profiles/profiles.module.ts` — imports AuthModule, EntitlementsModule; provides ProfilesService and AuthGuard
  - [x] Register `ProfilesModule` in `AppModule.imports[]`

- [x] Create domain exception (AC: 5)
  - [x] Create `apps/api/src/modules/profiles/exceptions/profile-not-found.exception.ts` — `ProfileNotFoundException extends NotFoundException`

- [x] Unit test `ProfilesService` (AC: 1, 2, 3, 4, 5)
  - [x] Create `apps/api/src/modules/profiles/profiles.service.spec.ts`
  - [x] `getProfiles` for new user → empty array
  - [x] `createProfile` → returns profile with generated `id`, `createdAt`, and `isActive: true` (first profile auto-activates)
  - [x] `createProfile` second profile → `isActive: false`; first profile still active
  - [x] `createProfile` when free tier and already at 1 profile → throws `ProfileLimitExceededException`
  - [x] `activateProfile` → target becomes active, previous loses active
  - [x] `updateProfile` updates `name`, `dateOfBirth`, `relation`; reflects in `getProfiles`
  - [x] `updateProfile` with non-existent/unauthorized profile id → throws `ProfileNotFoundException`
  - [x] `activateProfile` with non-existent/unauthorized profile id → throws `ProfileNotFoundException`

- [x] Unit test `ProfilesController` (AC: 1, 2, 3, 4, 6)
  - [x] Create `apps/api/src/modules/profiles/profiles.controller.spec.ts`
  - [x] `getProfiles` delegates to `ProfilesService.getProfiles(userId)` and wraps in success envelope
  - [x] `createProfile` delegates to service and returns 201 with profile
  - [x] `updateProfile` delegates to service
  - [x] `activateProfile` delegates to service and returns full profile list
  - [x] Exceptions from service propagate correctly

- [x] Add e2e tests in `apps/api/test/app.e2e-spec.ts` (AC: 1, 2, 3, 4, 5, 6)
  - [x] Setup: register `profiles@example.com` + login once per `describe` block
  - [x] `GET /profiles` without token → 401 `AUTH_UNAUTHORIZED`
  - [x] `GET /profiles` with valid token → 200, empty profiles array
  - [x] `POST /profiles` with `{ name: 'Vishnu' }` → 201, `isActive: true`
  - [x] `GET /profiles` after first create → 200, one profile `isActive: true`
  - [x] `POST /profiles` with `{ name: 'Amma', relation: 'parent' }` → 201, `isActive: false`
  - [x] `POST /profiles/:id/activate` on second profile → 200, second is active, first is not
  - [x] `PATCH /profiles/:id` with `{ name: 'Amma Edited' }` → 200, name updated
  - [x] `GET /profiles` after update → updated name reflected
  - [x] `PATCH /profiles/nonexistent-id` → 404 `PROFILE_NOT_FOUND`
  - [x] `POST /profiles/:id/activate` with non-existent id → 404 `PROFILE_NOT_FOUND`
  - [x] `POST /profiles` when free tier and already 1 profile → 403 `PROFILE_LIMIT_EXCEEDED`

- [x] Implement Flutter profiles feature (AC: 7, 8)
  - [x] Create `apps/mobile/lib/features/profiles/profiles_repository.dart` — abstract class + Profile model; includes `getMaxProfiles()` returning `int?`
  - [x] Create `apps/mobile/lib/features/profiles/in_memory_profiles_repository.dart` — unlimited by default (`maxProfiles = null`); optional limit param; throws `ProfileLimitExceededException` when at limit
  - [x] Create `apps/mobile/lib/features/profiles/screens/profile_list_screen.dart` — loads profiles, Active chip / Set Active button, Add Profile button, edit icons
  - [x] Create `apps/mobile/lib/features/profiles/screens/create_edit_profile_screen.dart` — create and edit modes; catches `ProfileLimitExceededException` for upgrade message
  - [x] Update `apps/mobile/lib/main.dart` — added `profileList`, `createProfile`, `editProfile` to `_AuthView` enum; `ProfilesRepository?` constructor param; wired all profile screens; fixed pre-existing `onGoToLogin` bug (was navigating to `forgotPassword` instead of `login`)

- [x] Flutter widget tests (AC: 7)
  - [x] Create `apps/mobile/test/profile_list_test.dart` — 7 tests covering list render, active chip, Set Active, Add Profile, edit callback, back button
  - [x] Create `apps/mobile/test/create_edit_profile_test.dart` — 8 tests covering create mode (empty error, valid submit, optional fields, back) and edit mode (pre-fill, update submit)

## Dev Notes

### Critical Architecture Notes

- **`ProfilesService` stores are fully in-memory** — `Map<string, Profile[]>` (keyed by `userId`) for profiles, `Map<string, string>` (keyed by `userId`) for `activeProfileId`. TypeORM/PostgreSQL persistence is deferred; see "In-Memory Store" note below.
- **`ProfilesModule` pattern mirrors `ConsentModule` and `AccountModule`** — imports `AuthModule`, provides `ProfilesService` + `AuthGuard`, registers `ProfilesController`. Copy this exact structure; do NOT deviate.
- **All `ProfilesService` methods are synchronous** — no DB/Redis/I/O; the `require-await` ESLint rule is enforced. Methods return `ProfileWithActive` or `ProfileWithActive[]` directly, NOT `Promise<T>`. Making them `async` will fail lint.
- **Authorization is per-operation** — `updateProfile` and `activateProfile` look up the profile by `userId` first; if the `profileId` is not found in that user's list, throw `ProfileNotFoundException` — this also covers cross-user unauthorized access without leaking existence.
- **Profile IDs use `crypto.randomUUID()`** — already available in Node 24 without imports; no uuid package needed.
- **`POST /profiles` returns HTTP 201** — use `@HttpCode(HttpStatus.CREATED)`.
- **`POST /profiles/:id/activate` returns the full updated profile list** (same shape as `GET /profiles`) — not just the activated profile; this lets the Flutter app refresh in one call.
- **Profile names and `dateOfBirth` are PII** — never log them; log only `correlationId`.
- **Domain exception file location:** `apps/api/src/modules/profiles/exceptions/profile-not-found.exception.ts` — follow the same pattern implied by `ConsentModule` / `AccountModule` for exception placement.

### In-Memory Store Design

```typescript
// profiles.service.ts

// Store 1: profiles per user
// Map key: userId
// Map value: array of Profile (without isActive — isActive is derived)
private readonly profiles = new Map<string, Profile[]>();

// Store 2: active profile per user
// Map key: userId
// Map value: profileId of the active profile (undefined = none yet)
private readonly activeProfileId = new Map<string, string>();
```

When computing `ProfileWithActive[]` for a response, join the two stores:
```typescript
const active = this.activeProfileId.get(userId);
return (this.profiles.get(userId) ?? []).map(p => ({
  ...p,
  isActive: p.id === active,
}));
```

### API Response Shape

```json
// GET /profiles → 200
{
  "success": true,
  "data": [
    { "id": "uuid", "name": "Vishnu", "relation": "self", "dateOfBirth": null, "createdAt": "2026-03-06T...", "isActive": true },
    { "id": "uuid2", "name": "Amma", "relation": "parent", "dateOfBirth": "1960-05-15", "createdAt": "2026-03-06T...", "isActive": false }
  ],
  "correlationId": "uuid"
}

// POST /profiles body
{ "name": "Amma", "dateOfBirth": "1960-05-15", "relation": "parent" }
// → 201 with created profile shape (single ProfileWithActive)

// PATCH /profiles/:id body
{ "name": "Amma Edited" }
// → 200 with updated profile shape (single ProfileWithActive)

// POST /profiles/:id/activate → 200
// → same shape as GET /profiles (full list, updated isActive flags)
```

### DTO Validation Notes

`UpdateProfileDto.name` — optional, BUT if provided must not be empty: use `@IsOptional()` combined with `@IsNotEmpty()`. This prevents `{ "name": "" }` from clearing a profile name. The `ValidationPipe` whitelist strips any fields not decorated.

`dateOfBirth` — accept as a free-form string (ISO 8601 date format preferred but not validated strictly in this story; do not use `@IsISO8601()` unless the existing date validation approach in the project is confirmed — keep it `@IsString()`).

### Flutter Navigation Pattern

State-based navigation (no `Navigator.push`). Extend `_AppView` enum:

```dart
enum _AppView {
  login, register, forgotPassword,
  home,
  accountProfile,     // Story 1.3
  policyAcceptance,   // Story 1.4
  profileList,        // Story 1.5 NEW
  createProfile,      // Story 1.5 NEW
  editProfile,        // Story 1.5 NEW
}
```

After logging in and passing consent check (from Story 1.4), the flow continues to `_AppView.home` as before. The `HomeScreen` gains a "Profiles" button alongside the existing "Account" button. Profile navigation is initiated from `_AppView.home` → `_AppView.profileList`.

`CreateEditProfileScreen` receives an `onComplete` callback → routes back to `_AppView.profileList`. For edit mode, it also receives the `existingProfile`.

**Existing widget tests (1.1–1.4) that bootstrap `DoclyzerApp`** inject `InMemoryConsentRepository(hasPending: false)` to bypass the consent screen. This story introduces `ProfilesRepository` as an additional injectable. Update the constructor injection to also accept a `ProfilesRepository?`. Existing tests that don't care about profiles pass `null` (or default `InMemoryProfilesRepository()`).

### Profile Model (Dart)

```dart
class Profile {
  final String id;
  final String name;
  final String? dateOfBirth;
  final String? relation;
  final DateTime createdAt;
  final bool isActive;

  const Profile({
    required this.id,
    required this.name,
    this.dateOfBirth,
    this.relation,
    required this.createdAt,
    required this.isActive,
  });

  Profile copyWith({bool? isActive, String? name, String? dateOfBirth, String? relation}) => ...;
}
```

### Project Structure Notes

```
NEW files:
  apps/api/src/modules/profiles/profiles.module.ts
  apps/api/src/modules/profiles/profiles.service.ts
  apps/api/src/modules/profiles/profiles.controller.ts
  apps/api/src/modules/profiles/profiles.dto.ts
  apps/api/src/modules/profiles/profiles.types.ts
  apps/api/src/modules/profiles/profiles.service.spec.ts
  apps/api/src/modules/profiles/profiles.controller.spec.ts
  apps/api/src/modules/profiles/exceptions/profile-not-found.exception.ts
  apps/mobile/lib/features/profiles/profiles_repository.dart
  apps/mobile/lib/features/profiles/in_memory_profiles_repository.dart
  apps/mobile/lib/features/profiles/screens/profile_list_screen.dart
  apps/mobile/lib/features/profiles/screens/create_edit_profile_screen.dart
  apps/mobile/test/profile_list_test.dart
  apps/mobile/test/create_edit_profile_test.dart

MODIFIED files:
  apps/api/src/app.module.ts           (add ProfilesModule to imports[])
  apps/api/test/app.e2e-spec.ts        (add Profiles describe block)
  apps/mobile/lib/main.dart            (add profileList/createProfile/editProfile views, ProfilesRepository injection)
  apps/mobile/lib/features/auth/screens/home_screen.dart  (add Profiles button)
  apps/mobile/test/widget_test.dart    (inject InMemoryProfilesRepository alongside existing InMemoryConsentRepository)
```

Note: Architecture tree shows `apps/api/src/modules/profiles/` at the top level — use this exact path. Do NOT create a `profiles/` folder under `account/` or anywhere else.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.5]
- [Source: _bmad-output/planning-artifacts/prd.md#FR6, FR7, FR8]
- [Source: _bmad-output/planning-artifacts/architecture.md#Project Structure]
- [Source: _bmad-output/planning-artifacts/architecture.md#Authentication & Security]
- [Source: _bmad-output/planning-artifacts/architecture.md#API & Communication Patterns]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Profile switch, Multi-profile mental model]
- [Source: _bmad-output/implementation-artifacts/1-4-policy-acceptance-with-version-tracking.md#Architecture Compliance, Flutter Navigation Pattern]
- [Source: _bmad-output/implementation-artifacts/1-3-account-profile-management-view-update-basic-info.md#Architecture Compliance, Module pattern]
- [Source: _bmad-output/project-context.md]

## Technical Requirements

- All `/profiles/*` endpoints require `@UseGuards(AuthGuard)` at `ProfilesController` class level — unauthenticated requests return `401 AUTH_UNAUTHORIZED`
- `ProfilesService` methods are synchronous (no I/O) — do NOT mark them `async`; `require-await` ESLint is enforced; they return typed values directly
- `POST /profiles` returns HTTP 201 — use `@HttpCode(HttpStatus.CREATED)`; all other endpoints return 200
- `CreateProfileDto.name` — `@IsString() @IsNotEmpty() @MaxLength(100)`; `dateOfBirth` and `relation` are `@IsOptional() @IsString() @MaxLength(50)` each
- `UpdateProfileDto` — all fields optional; `name`, if provided, must also satisfy `@IsNotEmpty()` to prevent clearing the name
- All responses use `successResponse(data, correlationId)` — never `res.json()` directly
- Profile authorization: ownership enforced at service level — a `userId` + `profileId` pair that doesn't match throws `ProfileNotFoundException` (not `403`, to avoid existence enumeration)
- Profile names and `dateOfBirth` are PII — never log them; log only `correlationId`
- `POST /profiles/:id/activate` response data is the full profile list (same as `GET /profiles`) — the Flutter app uses this to refresh in one round-trip

## Architecture Compliance

- `ProfilesModule` imports `AuthModule` (exports `AuthService`); `AuthGuard` in `ProfilesModule.providers[]` — same pattern as `ConsentModule` and `AccountModule`
- `ProfilesModule` registered in `AppModule.imports[]` — NestJS has no auto-discovery
- Controller is thin: extract `(req.user as AuthUser).id`, extract `req.params.id` if needed, call one service method, wrap in `successResponse()`
- Correlation IDs via `getCorrelationId(req)` on all success responses
- `ProfileNotFoundException` extends `NotFoundException` with `{ code: 'PROFILE_NOT_FOUND', message: 'Profile not found' }` — this shape is extracted by `ApiExceptionFilter` into the standard error envelope

## Library / Framework Requirements

- **Backend:** NestJS `^11.0.1`, TypeScript `^5.7.3` (strict), `class-validator ^0.15.1` (already installed), `class-transformer ^0.5.1`
- **Mobile:** Flutter stable 3.41.x, Dart SDK `^3.11.0`
- **No new npm or pub packages needed for this story** — `crypto.randomUUID()` is available natively in Node 24; no uuid package required

## Testing Requirements

### API Unit Tests (ProfilesService)

- `getProfiles` for new user → returns empty array
- `createProfile` → returns profile with uuid `id`, ISO `createdAt`, `isActive: true` (first profile auto-activates)
- `createProfile` second profile → `isActive: false`; first profile remains active
- `activateProfile` on second profile → second is `isActive: true`, first is `isActive: false`
- `updateProfile` updates `name` (and optional fields); updated values reflected in subsequent `getProfiles`
- `updateProfile` with non-existent profile id → throws `ProfileNotFoundException`
- `activateProfile` with non-existent profile id → throws `ProfileNotFoundException`
- Profile from user A cannot be updated/activated by user B (simulate by calling with different `userId`)

### API Unit Tests (ProfilesController)

- `getProfiles` delegates to `ProfilesService.getProfiles(userId)` and wraps result in success envelope
- `createProfile` delegates to `ProfilesService.createProfile(userId, dto)` and returns 201
- `updateProfile` delegates to service with correct `userId` and `profileId`
- `activateProfile` delegates to service and returns full profile list
- Exceptions from service propagate (not caught by controller)

### API e2e Tests (add to `apps/api/test/app.e2e-spec.ts`)

- Dedicated email `profiles@example.com` to avoid rate limit collisions with other test suites
- `beforeAll`: register + login; store `accessToken`
- `GET /profiles` without token → 401 `AUTH_UNAUTHORIZED`
- `GET /profiles` with valid token → 200, empty array
- `POST /profiles` (name: "Vishnu") → 201, `isActive: true`
- `GET /profiles` → one profile, `isActive: true`
- `POST /profiles` (name: "Amma", relation: "parent") → 201, `isActive: false`
- `POST /profiles/:ammaId/activate` → 200, Amma is active, Vishnu is not
- `PATCH /profiles/:ammaId` (name: "Amma Edited") → 200, name updated
- `GET /profiles` → name update reflected, active state preserved
- `PATCH /profiles/nonexistent-id` → 404 `PROFILE_NOT_FOUND`
- `POST /profiles/nonexistent-id/activate` → 404 `PROFILE_NOT_FOUND`

### Flutter Widget Tests

`profile_list_test.dart`:
- `ProfileListScreen` renders one profile name with active indicator widget
- With two profiles, only non-active profile shows enabled "Set Active" button
- Tapping "Set Active" calls `activateProfile(id)` on the repository
- "Add Profile" button (or FAB) is present and tappable
- Widget keys used in tests: `Key('profile-list-item-<id>')`, `Key('profile-activate-<id>')`, `Key('profile-edit-<id>')`, `Key('profile-create-new')`

`create_edit_profile_test.dart`:
- Create mode: form fields are empty; submitting with empty name shows inline error (no `SnackBar`)
- Create mode: submitting with valid name calls `createProfile` and triggers `onComplete` callback
- Edit mode (`existingProfile` provided): `name` field pre-filled with `existingProfile.name`
- Edit mode: submitting calls `updateProfile` with the `existingProfile.id` and new values
- Widget keys: `Key('profile-name-field')`, `Key('profile-dob-field')`, `Key('profile-relation-field')`, `Key('profile-submit')`

## Previous Story Intelligence

- **`ConsentModule` (Story 1.4) is the closest reference pattern** for `ProfilesModule`: imports `AuthModule`, provides `AuthGuard` in providers, synchronous service methods, thin controller. Copy that structure.
- **`req.user as AuthUser` cast** — confirmed pattern from Story 1.3 code review; required for TypeScript/ESLint `no-unsafe-*` compliance. Always cast to `AuthUser` before accessing `id`.
- **`express.d.ts` ambient augmentation** — already fixed in Story 1.3 with inline `import()` type. Do NOT touch `express.d.ts`.
- **e2e test email uniqueness** — `profiles@example.com` is reserved for this story. Do NOT reuse `consent-policy@example.com`, `account-profile@example.com`, or any auth test emails.
- **`ProfilesService` synchronous methods** — same reasoning as `ConsentService` and `validateAccessToken`: no I/O → must not be `async`; will trigger `require-await` ESLint error.
- **Flutter `_AppView` enum** is in `apps/mobile/lib/main.dart`; it currently has: `login`, `register`, `forgotPassword`, `home`, `accountProfile`, `policyAcceptance`. Add `profileList`, `createProfile`, `editProfile`.
- **Story 1.4 flutter change**: `InMemoryConsentRepository(hasPending: false)` is injected in existing `widget_test.dart` to bypass consent screen in auth flow tests. This story adds a second injectable repository; update the `DoclyzerApp` constructor signature but do NOT break existing tests — the consent injection must remain in place.
- **`HomeScreen`** (from Story 1.3) has an "Account" button. Add a "Profiles" button alongside it in the same style.
- **In-memory stores intentional** — all stories in this sprint use in-memory stores; TypeORM/PostgreSQL setup is deferred. The `Map` structure for `profiles` and `activeProfileId` maps directly to future TypeORM entity repository calls when persistence is added.
- **Story 1.6 handles profile deletion** — do NOT implement any delete endpoint or delete button in this story even if it seems obvious. Keep the scope clean.
- **Active profile ID is consumed by Epic 2 stories** (report upload, timeline) — the `ProfilesRepository.activeProfileId` getter established here is the canonical pattern those stories will use. Name it correctly from the start.

## Project Context Reference

- [Source: _bmad-output/project-context.md] — read this file before starting implementation
- Key rules that apply directly:
  - `require-await` enforced — all `ProfilesService` methods are synchronous (no DB/Redis I/O), must NOT be `async`
  - `@UseGuards(AuthGuard)` at controller class level — covers all routes
  - Module exports are minimal — `ProfilesModule` exports nothing
  - New modules must be manually added to `AppModule.imports[]`
  - Widget test keys use kebab-case strings
  - Repository pattern for all data access (Flutter) — abstract class + InMemory implementation
  - No business logic in widgets — screens call injected `ProfilesRepository` methods only
  - All Flutter screens are full `Scaffold` widgets with `appBar` and `body` padding
  - Navigation is state-based — no `Navigator.push`; use `_AppView` enum in `DoclyzerApp`
  - `FilledButton` for primary CTAs (Material 3) — not `ElevatedButton`
  - Error display: `String? _error` state variable, shown inline with red text — never `SnackBar` for validation errors
  - `TextEditingController` must be disposed in `dispose()`

## Story Completion Status

- Story context file generated with implementation guardrails, architecture constraints, and testing standards.
- Ready for `dev-story` execution.
- Completion note: Ultimate context engine analysis completed — comprehensive developer guide created.

## Dev Agent Record

### Agent Model Used

claude-4.6-sonnet-medium-thinking

### Debug Log References

None.

### Completion Notes List

- Implemented full `ProfilesModule` (NestJS) with `ProfilesService` (in-memory Map stores), `ProfilesController` (4 endpoints), DTOs, `ProfileNotFoundException`, `ProfileLimitExceededException`, and `EntitlementsService` stub (returns 1 max profile, free tier).
- All service methods are synchronous (no async/await) per `require-await` ESLint rule.
- `POST /profiles/:id/activate` returns the full updated profile list (not just the activated profile), matching the story spec.
- `ProfileNotFoundException` is thrown for non-existent profileIds regardless of which user queries — prevents existence enumeration.
- Flutter: Added `ProfileListScreen`, `CreateEditProfileScreen`, `InMemoryProfilesRepository` (unlimited by default), and abstract `ProfilesRepository` with `Profile` model + `ProfileLimitExceededException` class.
- Flutter: `DoclyzerApp` constructor updated with optional `ProfilesRepository?` (backward-compatible — all existing tests unaffected).
- Flutter: `HomeScreen` updated with required `onGoToProfiles` callback and "Profiles" `FilledButton`.
- Fixed pre-existing bug in `main.dart`: `_AuthView.forgotPassword` case's `onGoToLogin` was navigating back to `forgotPassword` instead of `login`, causing the pre-existing `widget_test.dart` test `'forgot password screen navigates from login and back'` to fail.
- All test counts: 72 API unit tests, 37 API e2e tests, 32 Flutter widget tests — all passing.

### File List

**New files:**
- `apps/api/src/modules/entitlements/entitlements.service.ts`
- `apps/api/src/modules/entitlements/entitlements.module.ts`
- `apps/api/src/modules/profiles/profiles.types.ts`
- `apps/api/src/modules/profiles/profiles.dto.ts`
- `apps/api/src/modules/profiles/profiles.service.ts`
- `apps/api/src/modules/profiles/profiles.service.spec.ts`
- `apps/api/src/modules/profiles/profiles.controller.ts`
- `apps/api/src/modules/profiles/profiles.controller.spec.ts`
- `apps/api/src/modules/profiles/profiles.module.ts`
- `apps/api/src/modules/profiles/exceptions/profile-not-found.exception.ts`
- `apps/api/src/modules/profiles/exceptions/profile-limit-exceeded.exception.ts`
- `apps/mobile/lib/features/profiles/profiles_repository.dart`
- `apps/mobile/lib/features/profiles/in_memory_profiles_repository.dart`
- `apps/mobile/lib/features/profiles/screens/profile_list_screen.dart`
- `apps/mobile/lib/features/profiles/screens/create_edit_profile_screen.dart`
- `apps/mobile/test/profile_list_test.dart`
- `apps/mobile/test/create_edit_profile_test.dart`

**Modified files:**
- `apps/api/src/app.module.ts` (added ProfilesModule, EntitlementsModule, ConfigModule to imports)
- `apps/api/test/app.e2e-spec.ts` (added Profiles describe block with 11 tests)
- `apps/mobile/lib/main.dart` (added profileList/createProfile/editProfile views; ProfilesRepository injection; fixed forgotPassword onGoToLogin bug)
- `apps/mobile/lib/features/auth/screens/home_screen.dart` (added onGoToProfiles callback and Profiles button)
- `apps/mobile/lib/features/profiles/profiles_repository.dart` (added ProfileNotFoundException)
- `apps/api/src/modules/account/account.controller.spec.ts` (Prettier reformatting)
- `apps/api/src/modules/account/account.service.spec.ts` (Prettier reformatting)
- `apps/api/src/modules/consent/consent.service.spec.ts` (Prettier reformatting)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (updated to in-progress → review)

### Senior Developer Review (AI)

**Reviewer:** Vishnu — 2026-03-06  
**Outcome:** Changes Requested → Fixed automatically during review

**Issues found and fixed:**

1. **[HIGH → FIXED]** `EntitlementsService` read `process.env.E2E_MAX_PROFILES` directly — violation of `no process.env inside modules` rule (project-context). Fixed: installed `@nestjs/config`, added `ConfigModule.forRoot({ isGlobal: true })` to `AppModule`, injected `ConfigService` into `EntitlementsService`.

2. **[MEDIUM → FIXED]** `CreateProfileDto` and `UpdateProfileDto` both missing `@MaxLength(50)` on `dateOfBirth` field — stated in story Technical Requirements. Fixed in `profiles.dto.ts`.

3. **[LOW → FIXED]** `InMemoryProfilesRepository.updateProfile` and `activateProfile` threw generic `Exception('Profile not found')` instead of typed `ProfileNotFoundException`. Fixed: added `ProfileNotFoundException` to `profiles_repository.dart`; updated both `InMemoryProfilesRepository` methods to throw it.

4. **[MEDIUM → DOCUMENTED]** `account.controller.spec.ts`, `account.service.spec.ts`, `consent.service.spec.ts` were Prettier-reformatted as a side effect of the dev agent run — added to story File List.

**All ACs verified as implemented (1–8). No false [x] tasks found.**

### Change Log

- Added `ProfilesModule` (NestJS) with full CRUD and switch — `GET /v1/profiles`, `POST /v1/profiles`, `PATCH /v1/profiles/:id`, `POST /v1/profiles/:id/activate` (Date: 2026-03-06)
- Added `EntitlementsService` stub: free tier capped at 1 profile; `POST /v1/profiles` returns 403 `PROFILE_LIMIT_EXCEEDED` when at limit (Date: 2026-03-06)
- Added Flutter profiles feature: `ProfileListScreen`, `CreateEditProfileScreen`, `InMemoryProfilesRepository`, `Profile` model (Date: 2026-03-06)
- Updated `DoclyzerApp` with `profilesRepository` injection + `HomeScreen` Profiles button (Date: 2026-03-06)
- Fixed pre-existing `forgotPassword → login` navigation bug in `main.dart` (Date: 2026-03-06)
- [Code Review] Added `ConfigModule.forRoot({ isGlobal: true })` to `AppModule`; injected `ConfigService` into `EntitlementsService` replacing direct `process.env` read (Date: 2026-03-06)
- [Code Review] Added `@MaxLength(50)` to `dateOfBirth` in `CreateProfileDto` and `UpdateProfileDto` (Date: 2026-03-06)
- [Code Review] Added `ProfileNotFoundException` to `profiles_repository.dart`; updated `InMemoryProfilesRepository` to throw typed exception (Date: 2026-03-06)
