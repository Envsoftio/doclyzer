# Story 1.4: Policy Acceptance with Version Tracking

Status: done

## Story

As an authenticated user,
I want to view and accept the current Terms of Service and Privacy Policy (with version tracking),
So that my compliance state is explicit, auditable, and I am only reprompted when policy versions actually change.

## Acceptance Criteria

1. **Given** I am authenticated and have not accepted the current policy versions
   **When** I call `GET /consent/status`
   **Then** I receive both policies in the response with `accepted: false`
   **And** `hasPending: true` in the response
   **And** the response uses the standard success envelope with a correlationId

2. **Given** I submit valid `policyTypes` to `POST /consent/accept`
   **When** my acceptance is recorded
   **Then** each accepted policy stores `userId`, `policyType`, `version`, and `acceptedAt`
   **And** a subsequent `GET /consent/status` returns `accepted: true` for those policies
   **And** `hasPending: false` when all current policies are accepted

3. **Given** I have accepted the current policy versions
   **When** a new policy version is deployed (version string changes)
   **Then** `GET /consent/status` returns `accepted: false` for the updated policy
   **And** `hasPending: true` again

4. **Given** I am not authenticated (missing or invalid `Authorization` header)
   **When** I call any `/consent/*` endpoint
   **Then** I receive `401` with `{ success: false, code: "AUTH_UNAUTHORIZED", ... }`

5. **Given** I am on the Flutter app and have pending policies after login
   **When** the app routes post-login
   **Then** I am shown the `PolicyAcceptanceScreen` before the home screen
   **And** after accepting all pending policies, I am routed to the home screen

6. **Given** I have already accepted all current policies
   **When** the app routes post-login
   **Then** I am taken directly to the home screen without the policy acceptance step

## Tasks / Subtasks

- [x] Create `ConsentModule` API (AC: 1, 2, 3, 4)
  - [x] Create `apps/api/src/modules/consent/consent.types.ts` — `PolicyType`, `PolicyDefinition`, `PolicyAcceptanceRecord`, `PolicyStatusItem`, `ConsentStatus` interfaces
  - [x] Create `apps/api/src/modules/consent/consent.dto.ts` — `AcceptPoliciesDto` with `@IsArray() @ArrayNotEmpty() @IsString({ each: true }) @IsIn(['terms', 'privacy'], { each: true }) policyTypes: string[]`
  - [x] Create `apps/api/src/modules/consent/consent.service.ts` — in-memory `Map<string, PolicyAcceptanceRecord>` keyed by `${userId}:${policyType}`; exposes `getStatus(userId)` and `acceptPolicies(userId, policyTypes)`; static `CURRENT_POLICIES` constant defines `terms@1.0.0` and `privacy@1.0.0`
  - [x] Create `apps/api/src/modules/consent/consent.controller.ts` — `@Controller('consent') @UseGuards(AuthGuard)`; `GET /consent/status` and `POST /consent/accept` (HTTP 200); casts `req.user as AuthUser`
  - [x] Create `apps/api/src/modules/consent/consent.module.ts` — imports `AuthModule`; provides `ConsentService`; registers `ConsentController`; no exports needed
  - [x] Register `ConsentModule` in `AppModule.imports[]`

- [x] Unit test `ConsentService` (AC: 1, 2, 3)
  - [x] Create `apps/api/src/modules/consent/consent.service.spec.ts`
  - [x] `getStatus` for new user → all policies `accepted: false`, `hasPending: true`
  - [x] `acceptPolicies(['terms', 'privacy'])` → subsequent `getStatus` returns `hasPending: false`
  - [x] `acceptPolicies(['terms'])` only → `privacy` still pending
  - [x] Acceptance record stores correct `userId`, `policyType`, `version`, `acceptedAt`
  - [x] Version mismatch: user accepted `1.0.0`, current bumped to `1.1.0` → `accepted: false` returned

- [x] Unit test `ConsentController` (AC: 1, 2, 4)
  - [x] Create `apps/api/src/modules/consent/consent.controller.spec.ts`
  - [x] `getStatus` delegates to `ConsentService.getStatus(userId)` and wraps in success envelope
  - [x] `accept` delegates to `ConsentService.acceptPolicies(userId, dto.policyTypes)`
  - [x] Exceptions from service propagate correctly

- [x] Add e2e tests in `apps/api/test/app.e2e-spec.ts` (AC: 1, 2, 4)
  - [x] Setup: register `consent-policy@example.com` + login once per describe block
  - [x] `GET /consent/status` without token → 401 `AUTH_UNAUTHORIZED`
  - [x] `GET /consent/status` with valid token → 200, both policies `accepted: false`, `hasPending: true`
  - [x] `POST /consent/accept` with `policyTypes: ['terms', 'privacy']` → 200
  - [x] `GET /consent/status` after acceptance → both `accepted: true`, `hasPending: false`
  - [x] `POST /consent/accept` without token → 401 `AUTH_UNAUTHORIZED`

- [x] Implement Flutter consent feature (AC: 5, 6)
  - [x] Create `apps/mobile/lib/features/consent/consent_repository.dart` — abstract class with `Future<ConsentStatus> getStatus()` and `Future<void> acceptPolicies(List<String> policyTypes)`; `ConsentStatus` model with `List<PolicyStatusItem> policies` and `bool hasPending`; `PolicyStatusItem` model with `type`, `version`, `title`, `accepted`, `acceptedAt`
  - [x] Create `apps/mobile/lib/features/consent/in_memory_consent_repository.dart` — `hasPending` starts `true`; `getStatus()` returns two policies with `accepted` state; `acceptPolicies()` marks specified types as accepted, recomputes `hasPending`
  - [x] Create `apps/mobile/lib/features/consent/screens/policy_acceptance_screen.dart` — `StatefulWidget`; loads `getStatus()` from repository; shows each pending policy as a row (title + `Checkbox`); "Accept & Continue" `FilledButton` enabled only when all checkboxes are checked; on submit calls `acceptPolicies`, then invokes `onComplete` callback
  - [x] Update `apps/mobile/lib/main.dart` — add `_AppView.policyAcceptance` to view enum; accept `ConsentRepository?` in `DoclyzerApp` constructor; after login success, call `_consentRepository.getStatus()` and route to `_AppView.policyAcceptance` if `hasPending`, else route to `_AppView.home`; on policy acceptance complete, route to `_AppView.home`

- [x] Flutter widget tests (AC: 5, 6)
  - [x] Create `apps/mobile/test/policy_acceptance_test.dart`
  - [x] Screen renders all pending policy titles
  - [x] "Accept & Continue" button is disabled until all checkboxes are checked
  - [x] Checking all checkboxes enables the button
  - [x] Tapping "Accept & Continue" calls `acceptPolicies` and invokes `onComplete`
  - [x] Widget keys: `Key('policy-acceptance-item-terms')`, `Key('policy-acceptance-item-privacy')`, `Key('policy-acceptance-submit')`
  - [x] Navigation: `DoclyzerApp` routes to `PolicyAcceptanceScreen` post-login when policies are pending

## Dev Notes

### Critical Architecture Notes

- **`AuthGuard` already exists** at `src/common/guards/auth.guard.ts` (created in Story 1.3). Do NOT recreate or move it. Import it via `AuthModule` exports chain: `ConsentModule` imports `AuthModule` which exports `AuthService`; `AuthGuard` is provided in `ConsentModule.providers[]` directly (same pattern as `AccountModule`).
- **`ConsentService` does NOT inject `AuthService`**. The authenticated user's `userId` comes via `req.user.id` (set by `AuthGuard`). No user lookup is needed inside `ConsentService`. Avoiding this dependency keeps the module self-contained and prevents circular imports.
- **Module is named `consent`** (not `consent_policy` as the architecture directory suggests). The `consent_policy` folder in the architecture tree is the broader domain; for this story the bounded context is just `consent`.
- **In-memory store is intentional for this sprint.** Compliance/audit durability (FR48, NFR23) requires PostgreSQL persistence in production. TypeORM setup is deferred until the database infrastructure story. When TypeORM is introduced, `ConsentService` methods map directly to repository calls — design the interface accordingly.
- **Policy versions are static constants in `ConsentService`.** When a policy version changes, update `CURRENT_POLICIES` constant. The version mismatch logic (`acceptedVersion !== currentVersion`) handles reprompting automatically with no additional code changes.
- **Map key format**: `${userId}:${policyType}` — one record per user per policy type (latest acceptance replaces old; we only need to know if *current* version is accepted).
- **`policyAccepted: true` at registration (Story 1.1) stays unchanged.** It is a gate to prevent unapproved registrations. Story 1.4 adds *versioned* tracking on top of that gate. Existing users (registered before 1.4) will see `hasPending: true` on first login — this is expected and correct.

### API Response Shape

```json
// GET /consent/status → 200
{
  "success": true,
  "data": {
    "policies": [
      {
        "type": "terms",
        "version": "1.0.0",
        "title": "Terms of Service",
        "url": "/legal/terms",
        "accepted": false,
        "acceptedAt": null
      },
      {
        "type": "privacy",
        "version": "1.0.0",
        "title": "Privacy Policy",
        "url": "/legal/privacy",
        "accepted": true,
        "acceptedAt": "2026-03-05T12:00:00.000Z"
      }
    ],
    "hasPending": true
  },
  "correlationId": "uuid"
}

// POST /consent/accept body
{ "policyTypes": ["terms", "privacy"] }
// → 200 with same ConsentStatus shape (reflects updated acceptance state)
```

### DTO Validation Notes

`@IsIn(['terms', 'privacy'], { each: true })` requires `class-validator ^0.15.1` (already installed). The `@ArrayNotEmpty()` decorator prevents accepting an empty `policyTypes` array.

### Flutter Navigation Pattern

The post-login consent check follows the same **state-based navigation** pattern established in Story 1.1:

```
_AuthView enum:
  login → register → forgotPassword → home → accountProfile (Story 1.3) → policyAcceptance (NEW)
```

After `_handleLoginSuccess()`:
1. Call `await _consentRepository.getStatus()`
2. If `status.hasPending` → `setState(() => _view = _AppView.policyAcceptance)`
3. If not pending → `setState(() => _view = _AppView.home)`

`PolicyAcceptanceScreen` receives `onComplete` callback → routes to `_AppView.home`.

### Project Structure Notes

```
apps/api/src/
  modules/
    consent/                     ← NEW MODULE
      consent.module.ts
      consent.service.ts
      consent.controller.ts
      consent.dto.ts
      consent.types.ts
      consent.service.spec.ts    ← NEW
      consent.controller.spec.ts ← NEW
  app.module.ts                  ← MODIFIED (add ConsentModule)
  test/
    app.e2e-spec.ts              ← MODIFIED (add consent e2e tests)

apps/mobile/lib/
  features/
    consent/                     ← NEW DOMAIN SLICE
      consent_repository.dart
      in_memory_consent_repository.dart
      screens/
        policy_acceptance_screen.dart
  main.dart                      ← MODIFIED (add consent routing + ConsentRepository)
mobile/test/
  policy_acceptance_test.dart    ← NEW
```

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.4]
- [Source: _bmad-output/planning-artifacts/prd.md#FR5, FR48, NFR23, NFR24]
- [Source: _bmad-output/planning-artifacts/architecture.md#Authentication & Security]
- [Source: _bmad-output/planning-artifacts/architecture.md#consent_policy module]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX4 Auditability Baseline]
- [Source: _bmad-output/implementation-artifacts/1-3-account-profile-management-view-update-basic-info.md]
- [Source: _bmad-output/project-context.md]

## Technical Requirements

- `GET /consent/status` and `POST /consent/accept` are both protected by `@UseGuards(AuthGuard)` — unauthenticated requests return `401 AUTH_UNAUTHORIZED`
- `ConsentService` methods are synchronous (no I/O) — do NOT mark them `async`; `require-await` ESLint rule is enforced
- `AcceptPoliciesDto.policyTypes` validation: `@IsArray()`, `@ArrayNotEmpty()`, `@IsString({ each: true })`, `@IsIn(['terms', 'privacy'], { each: true })`; rejects empty arrays and unrecognized policy type strings
- `POST /consent/accept` returns HTTP 200 (not 201) — use `@HttpCode(HttpStatus.OK)`
- All responses use `successResponse(data, correlationId)` — never `res.json()` directly
- No PHI in logs — never log `userId`, `email`, or policy content in any log statement; log only `correlationId`
- Map key for in-memory acceptance store: `${userId}:${policyType}` — single record per user per policy type; re-accepting replaces the record (stores latest `acceptedAt`)

## Architecture Compliance

- `ConsentModule` imports `AuthModule` (exports `AuthService`); `AuthGuard` is in `ConsentModule.providers[]` (same pattern as `AccountModule`)
- `ConsentModule` registered in `AppModule.imports[]` — NestJS has no auto-discovery
- Controllers are thin: extract `(req.user as AuthUser).id`, call one service method, wrap in `successResponse()`
- Correlation IDs via `getCorrelationId(req)` on all success responses
- Error envelope via `ApiExceptionFilter` — only throw NestJS `HttpException` subclasses with `{ code, message }` shape
- `ConsentService` has zero cross-module dependencies (no `AuthService` injection) — fully self-contained except for the `AuthUser` type import

## Library / Framework Requirements

- **Backend:** NestJS `^11.0.1`, TypeScript `^5.7.3` (strict), `class-validator ^0.15.1` (already installed — `@IsIn` is available), `class-transformer ^0.5.1`
- **Mobile:** Flutter stable 3.41.x, Dart SDK `^3.11.0`
- **No new npm or pub packages needed for this story**

## File Structure Requirements

```
NEW files:
  apps/api/src/modules/consent/consent.module.ts
  apps/api/src/modules/consent/consent.service.ts
  apps/api/src/modules/consent/consent.controller.ts
  apps/api/src/modules/consent/consent.dto.ts
  apps/api/src/modules/consent/consent.types.ts
  apps/api/src/modules/consent/consent.service.spec.ts
  apps/api/src/modules/consent/consent.controller.spec.ts
  apps/mobile/lib/features/consent/consent_repository.dart
  apps/mobile/lib/features/consent/in_memory_consent_repository.dart
  apps/mobile/lib/features/consent/screens/policy_acceptance_screen.dart
  apps/mobile/test/policy_acceptance_test.dart

MODIFIED files:
  apps/api/src/app.module.ts                  (add ConsentModule to imports[])
  apps/api/test/app.e2e-spec.ts               (add consent e2e tests)
  apps/mobile/lib/main.dart                   (add _AppView.policyAcceptance, ConsentRepository, post-login routing)
```

## Testing Requirements

### API Unit Tests

- `ConsentService`: `getStatus` for new user → `hasPending: true`; `acceptPolicies(['terms'])` → only terms accepted; `acceptPolicies(['terms', 'privacy'])` → `hasPending: false`; acceptance record has correct fields; re-acceptance updates `acceptedAt`; version mismatch (simulated by temporary mutation of `CURRENT_POLICIES`) → `accepted: false`
- `ConsentController`: `getStatus` wraps service result in success envelope; `accept` delegates to service and returns updated status; propagates exceptions from service

### API e2e Tests

- Dedicated email `consent-policy@example.com` to avoid rate limit collisions
- `beforeAll`: register + login; store `accessToken`
- Full happy path: GET status (pending) → POST accept all → GET status (all accepted)
- Unauthenticated access → 401

### Flutter Widget Tests

- `PolicyAcceptanceScreen` renders policy names loaded from `InMemoryConsentRepository`
- "Accept & Continue" is disabled until all policy checkboxes are checked
- Checking all boxes and tapping submit calls `acceptPolicies` and triggers `onComplete`
- Widget keys must match exactly: `Key('policy-acceptance-item-terms')`, `Key('policy-acceptance-item-privacy')`, `Key('policy-acceptance-submit')`
- `DoclyzerApp` integration: post-login, when `InMemoryConsentRepository` has `hasPending: true`, `PolicyAcceptanceScreen` is shown (not `HomeScreen`)

## Previous Story Intelligence

- **Story 1.3 established `AuthGuard`** — already lives at `src/common/guards/auth.guard.ts`; provided inside feature modules via `providers: [AuthGuard]` (not globally); `ConsentModule` must follow the same pattern
- **`AccountModule` pattern** is the reference implementation for this module: imports `AuthModule`, provides its service + `AuthGuard`, registers controller — copy that structure exactly
- **`req.user as AuthUser` cast** is required to satisfy TypeScript/ESLint `no-unsafe-*` rules — confirmed pattern from Story 1.3 code review
- **`express.d.ts` ambient module augmentation** is already fixed (inline `import()` type, not top-level `import`); do NOT touch `express.d.ts` in this story
- **`@Transform` pattern** for DTO coercion (Story 1.3 code review fix) — `AcceptPoliciesDto` doesn't need Transform since the array values are validated directly
- **e2e test email uniqueness** — each feature area uses a unique email; `consent-policy@example.com` is reserved for this story; do not reuse `account-profile@example.com`
- **`ConsentService` synchronous methods** — same reasoning as `AuthService.validateAccessToken`: no I/O → must not be `async`; will trigger `require-await` ESLint error if made async
- **Flutter `_AuthView` enum** is in `apps/mobile/lib/main.dart`; it currently has `login`, `register`, `forgotPassword`, `home`, `accountProfile`; add `policyAcceptance` to this enum

## Project Context Reference

- [Source: _bmad-output/project-context.md] — read this file before starting implementation
- Key rules that apply directly:
  - `require-await` enforced — all `ConsentService` methods are synchronous (no DB/Redis I/O), must NOT be `async`
  - `@UseGuards(AuthGuard)` at controller class level — covers all routes
  - Module exports are minimal — `ConsentModule` exports nothing
  - New modules must be manually added to `AppModule.imports[]`
  - Widget test keys use kebab-case strings
  - Repository pattern for all data access (Flutter) — abstract class + InMemory implementation
  - No business logic in widgets — `PolicyAcceptanceScreen` calls injected `ConsentRepository` methods only
  - All Flutter screens are full `Scaffold` widgets with `appBar` and `body` padding
  - Navigation is state-based — no `Navigator.push`; use `_AppView` enum in `DoclyzerApp`

## Story Completion Status

- Story context file generated with implementation guardrails, architecture constraints, and testing standards.
- Ready for `dev-story` execution.
- Completion note: Ultimate context engine analysis completed — comprehensive developer guide created.

## Dev Agent Record

### Agent Model Used

claude-4.6-sonnet-medium-thinking

### Debug Log References

### Completion Notes List

- Implemented full `ConsentModule` following `AccountModule` pattern exactly: `AuthModule` import, `AuthGuard` in providers, thin controller, synchronous service methods (no `async` — `require-await` compliant).
- `ConsentService.CURRENT_POLICIES` is a static readonly array; version mismatch check compares stored record version against current constant — no extra code needed when version bumps.
- `POST /consent/accept` returns HTTP 200 with updated `ConsentStatus` shape (same as GET), not 201.
- Flutter `InMemoryConsentRepository` defaults `hasPending: true`; existing `widget_test.dart` tests that test the auth flow injected `InMemoryConsentRepository(hasPending: false)` to bypass the consent screen without breaking coverage.
- All 48 API unit tests, 25 e2e tests, and 15 Flutter widget tests pass after lint fix.

### File List

- apps/api/src/modules/consent/consent.types.ts (NEW)
- apps/api/src/modules/consent/consent.dto.ts (NEW)
- apps/api/src/modules/consent/consent.service.ts (NEW)
- apps/api/src/modules/consent/consent.controller.ts (NEW)
- apps/api/src/modules/consent/consent.module.ts (NEW)
- apps/api/src/modules/consent/consent.service.spec.ts (NEW)
- apps/api/src/modules/consent/consent.controller.spec.ts (NEW)
- apps/api/src/app.module.ts (MODIFIED — added ConsentModule to imports)
- apps/api/test/app.e2e-spec.ts (MODIFIED — added Consent describe block with 4 e2e tests)
- apps/mobile/lib/features/consent/consent_repository.dart (NEW)
- apps/mobile/lib/features/consent/in_memory_consent_repository.dart (NEW)
- apps/mobile/lib/features/consent/screens/policy_acceptance_screen.dart (NEW)
- apps/mobile/lib/main.dart (MODIFIED — policyAcceptance view, ConsentRepository injection, post-login routing)
- apps/mobile/test/policy_acceptance_test.dart (NEW)
- apps/mobile/test/widget_test.dart (MODIFIED — inject InMemoryConsentRepository(hasPending: false) in login flow tests)

### Change Log

- 2026-03-06: Story 1.4 implemented — ConsentModule (NestJS) + consent feature (Flutter) with versioned policy tracking, GET/POST endpoints, full test coverage (48 unit + 25 e2e + 15 Flutter widget tests passing)
- 2026-03-06: Code review fixes applied — 6 issues resolved (3 Medium, 3 Low); 48 unit + 26 e2e + 15 Flutter tests passing

## Senior Developer Review (AI)

**Date:** 2026-03-06
**Outcome:** Approve (after fixes)

### Action Items

- [x] [Med] Controller spec test described "NotFoundException" but `ConsentService` never throws it — renamed to "Exceptions from service propagate correctly" [`consent.controller.spec.ts`]
- [x] [Med] `PolicyAcceptanceScreen` error `Text` lacked a `Key` — added `Key('policy-acceptance-error')` [`policy_acceptance_screen.dart`]
- [x] [Med] Flutter `PolicyStatusItem` missing `url` field, mismatching API response shape — added `url` to model and `InMemoryConsentRepository` [`consent_repository.dart`, `in_memory_consent_repository.dart`]
- [x] [Low] Version mismatch test mutated shared static object in place — refactored to replace array element and restore original reference atomically [`consent.service.spec.ts`]
- [x] [Low] E2E missing invalid-token test for consent endpoints — added `GET /consent/status with invalid token → 401` [`app.e2e-spec.ts`]
- [x] [Low] `POST /consent/accept` e2e test missing `correlationId` assertion (AC1 requires success envelope with correlationId) — added assertion [`app.e2e-spec.ts`]
