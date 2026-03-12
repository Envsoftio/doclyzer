# Story 1.3: Account Profile Management (View/Update Basic Info)

Status: done

## Story

As an authenticated user,
I want to view and update my account's basic information,
So that my account details remain accurate.

## Acceptance Criteria

1. **Given** I am authenticated
   **When** I request my account profile
   **Then** I receive current account info (email, displayName, createdAt)
   **And** the response uses the standard success envelope with a correlationId

2. **Given** I submit valid editable fields (e.g. `displayName`)
   **When** I save changes via `PATCH /account/profile`
   **Then** updates persist and are reflected in a subsequent `GET /account/profile`

3. **Given** I submit a restricted field (e.g. `email`, `id`, `createdAt`)
   **When** I attempt to update it via `PATCH /account/profile`
   **Then** the restricted field is silently stripped by `ValidationPipe` whitelist
   **And** only the permitted fields are updated

4. **Given** I am not authenticated (missing or invalid `Authorization` header)
   **When** I call any `/account/*` endpoint
   **Then** I receive `401` with `{ success: false, code: "AUTH_UNAUTHORIZED", ... }`

## Tasks / Subtasks

- [x] Create `AuthGuard` (prerequisite for all future protected routes) (AC: 4)
  - [x] Create `apps/api/src/common/guards/auth.guard.ts` implementing `CanActivate`
  - [x] Extract `Authorization: Bearer <token>` from request headers; throw `UnauthorizedException({ code: 'AUTH_UNAUTHORIZED' })` for missing/invalid tokens
  - [x] Call `authService.validateAccessToken(token)` and attach resolved user to `request.user`
  - [x] Add `validateAccessToken(token: string): AuthUser` to `AuthService`; throw `AUTH_UNAUTHORIZED` for unknown, revoked, or expired access tokens
  - [x] Export `AuthService` from `AuthModule` (already done — verify only)
  - [x] Unit test: valid token resolves user, missing token throws 401, revoked token throws 401, expired token throws 401

- [x] Add `displayName` field to `AuthUser` and in-memory store (AC: 1, 2)
  - [x] Add `displayName: string | null` to `AuthUser` interface in `auth.types.ts`
  - [x] Set `displayName: null` on all existing `AuthUser` creation sites in `AuthService.register()`

- [x] Implement account module API (AC: 1, 2, 3, 4)
  - [x] Create `apps/api/src/modules/account/account.module.ts`
  - [x] Create `apps/api/src/modules/account/account.service.ts` — injects `AuthService`; exposes `getProfile(userId)` and `updateProfile(userId, dto)`
  - [x] Create `apps/api/src/modules/account/account.controller.ts` — decorated with `@UseGuards(AuthGuard)`; `GET /account/profile` and `PATCH /account/profile`
  - [x] Create `apps/api/src/modules/account/account.dto.ts` — `UpdateAccountProfileDto` with only `@IsOptional() @IsString() @MaxLength(100) displayName`; whitelist strips everything else
  - [x] Create `apps/api/src/modules/account/account.types.ts` — `AccountProfile` interface (`id`, `email`, `displayName`, `createdAt`)
  - [x] `AccountModule` imports `AuthModule`; registers `AccountService`; does NOT re-export `AuthModule`
  - [x] Register `AccountModule` in `AppModule.imports[]`

- [x] Add e2e tests in `apps/api/test/app.e2e-spec.ts` (AC: 1, 2, 3, 4)
  - [x] Setup: register + login to obtain access token before account tests
  - [x] `GET /account/profile` with valid token → 200, correct shape
  - [x] `PATCH /account/profile` updates `displayName` → persists on subsequent GET
  - [x] `PATCH /account/profile` with `email` in body → email unchanged on GET
  - [x] `GET /account/profile` without token → 401 `AUTH_UNAUTHORIZED`
  - [x] `PATCH /account/profile` without token → 401 `AUTH_UNAUTHORIZED`

- [x] Implement Flutter account feature (AC: 1, 2)
  - [x] Create `apps/mobile/lib/features/account/account_repository.dart` — abstract class with `getProfile()` and `updateProfile({String? displayName})`
  - [x] Create `apps/mobile/lib/features/account/in_memory_account_repository.dart` — in-memory implementation; `getLastDisplayNameForTest()` utility for widget tests
  - [x] Create `apps/mobile/lib/features/account/screens/account_profile_screen.dart` — `StatefulWidget`; displays email (read-only), editable `displayName` field, Save button; uses `_error` pattern for validation feedback
  - [x] Add navigation to `AccountProfileScreen` from the logged-in state in `DoclyzerApp` (e.g. a Settings or Account button on the home/placeholder screen)
  - [x] Dispose `TextEditingController` in `dispose()`

- [x] Flutter widget tests (AC: 1, 2, 4)
  - [x] Screen renders email (read-only) and existing `displayName` from injected repository
  - [x] Save button calls `updateProfile` with new `displayName`
  - [x] Empty `displayName` save is allowed (field is optional)

## Dev Notes

- **`AuthGuard` is the primary deliverable of this story** — it is a prerequisite for every subsequent story with a protected endpoint. Implement it first; all other modules will import and reuse it.
- `AuthGuard` must live in `src/common/guards/`, not inside the `auth` module — it is cross-cutting infrastructure.
- `AccountModule` accesses the user store exclusively via `AuthService` (imported from `AuthModule`) — it does NOT define its own user map or duplicate auth state.
- Email is implicitly read-only in this story: `ValidationPipe` whitelist mode strips it from `PATCH` payload. Do not add email-change logic — that requires a separate email-verification flow (out of scope).
- `displayName` is the only mutable field in this story scope. Do not add phone, avatar, or other fields — those are not in FR4 and would expand scope.
- The `request.user` pattern established by `AuthGuard` (attaching `AuthUser` to the Express `Request`) is the canonical way all future controllers access the authenticated user. Use `@Req() req: Request & { user: AuthUser }` or a custom `@CurrentUser()` decorator.
- Response envelope: `GET /account/profile` returns `{ success: true, data: AccountProfile, correlationId }`. Use the same `successResponse()` helper from prior stories (verify it exists in `src/common/response-envelope.ts`; if not, create it in this story).

### Project Structure Notes

```
apps/api/src/
  common/
    guards/
      auth.guard.ts          ← NEW
  modules/
    auth/
      auth.types.ts          ← MODIFIED (add displayName to AuthUser)
      auth.service.ts        ← MODIFIED (add validateAccessToken, set displayName on register)
    account/                 ← NEW MODULE
      account.module.ts
      account.service.ts
      account.controller.ts
      account.dto.ts
      account.types.ts

apps/mobile/lib/features/
  account/                   ← NEW DOMAIN SLICE
    account_repository.dart
    in_memory_account_repository.dart
    screens/
      account_profile_screen.dart
```

### Architecture Module Naming Note

FR4 ("account profile management") is categorically distinct from FR6/7/8/10 (patient multi-profile management, covered in stories 1.5–1.6). This story creates an `account` module (for the registered user's own record), NOT a `profiles` module. The `profiles` module is reserved for the multi-patient-profile domain in stories 1.5+. The architecture's `profiles/` folder reference in the directory tree most likely encompasses both, but the bounded context separation is cleaner with `account/` for FR4.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.3]
- [Source: _bmad-output/planning-artifacts/prd.md#FR4]
- [Source: _bmad-output/planning-artifacts/architecture.md#Authentication & Security]
- [Source: _bmad-output/planning-artifacts/architecture.md#Project Structure]
- [Source: _bmad-output/planning-artifacts/architecture.md#Code naming conventions]
- [Source: _bmad-output/implementation-artifacts/1-2-password-recovery-and-secure-session-rotation.md]
- [Source: _bmad-output/project-context.md#AI Agent Guidance Notes]

## Technical Requirements

- `AuthGuard` calls `authService.validateAccessToken(token)`: throws `UnauthorizedException({ code: 'AUTH_UNAUTHORIZED', message: 'Authentication required' })` for missing token, invalid token, revoked session, or expired access token; never throws a different error shape
- `GET /account/profile` requires `Authorization: Bearer <token>` header — no query-param token support
- `PATCH /account/profile` body is a class with `ValidationPipe` whitelist active globally — only `displayName` is decorated, everything else is stripped silently
- `displayName` constraints: optional, string, max 100 chars — validate with `@IsOptional() @IsString() @MaxLength(100)`
- All responses use `{ success: true, data, correlationId }` / `{ success: false, code, message, correlationId }` envelopes
- No PHI in logs — `displayName` is PII and must never appear in log statements; log only `userId` and correlation IDs

## Architecture Compliance

- `@UseGuards(AuthGuard)` on `AccountController` class level (covers all routes in the controller)
- `AccountModule` imports `AuthModule` (which exports `AuthService`); does NOT redeclare `AuthService` as a provider
- Register `AccountModule` in `AppModule.imports[]` — NestJS has no auto-discovery
- Follow the established error envelope: `UnauthorizedException({ code: 'AUTH_UNAUTHORIZED', message: '...' })` — `ApiExceptionFilter` extracts the `code` field
- Correlation IDs flow through via `getCorrelationId(req)` from `correlationIdMiddleware` — include in all success responses

## Library / Framework Requirements

- **Backend:** NestJS `^11.0.1`, TypeScript `^5.7.3` (strict), `class-validator ^0.15.1`, `class-transformer ^0.5.1`
- **Mobile:** Flutter stable 3.41.x, Dart SDK `^3.11.0`
- No new npm or pub packages needed for this story

## File Structure Requirements

```
NEW files:
  apps/api/src/common/guards/auth.guard.ts
  apps/api/src/modules/account/account.module.ts
  apps/api/src/modules/account/account.service.ts
  apps/api/src/modules/account/account.controller.ts
  apps/api/src/modules/account/account.dto.ts
  apps/api/src/modules/account/account.types.ts
  apps/mobile/lib/features/account/account_repository.dart
  apps/mobile/lib/features/account/in_memory_account_repository.dart
  apps/mobile/lib/features/account/screens/account_profile_screen.dart

MODIFIED files:
  apps/api/src/modules/auth/auth.types.ts      (add displayName to AuthUser)
  apps/api/src/modules/auth/auth.service.ts    (add validateAccessToken; set displayName: null on register)
  apps/api/src/app.module.ts                   (add AccountModule to imports[])
  apps/api/test/app.e2e-spec.ts                (add account profile e2e tests)
  apps/mobile/lib/main.dart                    (add AccountProfileScreen navigation from logged-in state)
```

## Testing Requirements

### API unit tests

- `AuthGuard`: test with mocked `AuthService.validateAccessToken`; cover valid token, missing header, revoked session, expired token
- `AccountService`: test `getProfile` returns correct `AccountProfile` shape; `updateProfile` updates only `displayName`; unknown userId throws `NotFoundException`

### API e2e tests (add to `apps/api/test/app.e2e-spec.ts`)

- Full flow: register → login → GET profile → PATCH displayName → GET profile confirms update
- PATCH with restricted field (`email`) → email unchanged
- GET profile with no/invalid token → 401 `AUTH_UNAUTHORIZED`
- Use a unique account (unique email) for these tests to avoid rate limit collisions with existing test accounts

### Flutter widget tests

- `AccountProfileScreen` renders injected profile data
- Save triggers `updateProfile` callback with new `displayName`
- Widget keys: `Key('account-profile-email')`, `Key('account-profile-display-name')`, `Key('account-profile-save')`

## Previous Story Intelligence

- Stories 1.1 and 1.2 established: auth module with `AuthUser`, `AuthSession`, in-memory stores, `ValidationPipe` global, correlation IDs, standard error envelope, `NotificationService` abstraction, `InMemoryNotificationService`
- `AuthService.findUserByEmail` already exists — add `validateAccessToken(token)` alongside it; do NOT duplicate or replace session-lookup logic
- The e2e test suite shares a single app instance — add account tests in a dedicated `describe('Account Profile')` block using a unique test email to avoid rate limit exhaustion
- Flutter: `DoclyzerApp` currently shows auth screens; the logged-in state shows a placeholder — this story adds the first post-login navigation target

## Project Context Reference

- [Source: _bmad-output/project-context.md] — read this file before starting implementation
- Key rules from project-context.md that apply directly:
  - `@UseGuards(AuthGuard)` on protected controllers — this story creates the `AuthGuard` itself
  - Module exports are minimal — `AccountModule` does not export anything
  - New modules must be manually added to `AppModule.imports[]`
  - No `process.env` reads inside modules — use `ConfigService` (N/A for this story, no new env vars)
  - `require-await` enforced — `validateAccessToken` is synchronous (no I/O), must NOT be `async`
  - Widget test keys use kebab-case strings

## Story Completion Status

- Story context file generated with implementation guardrails, architecture constraints, and testing standards.
- Ready for `dev-story` execution.
- Completion note: Ultimate context engine analysis completed — comprehensive developer guide created.

## Dev Agent Record

### Agent Model Used

claude-4.6-sonnet-medium-thinking

### Debug Log References

- `npm test -- --runInBand` (apps/api): 29/29 unit tests passed
- `npm run test:e2e -- --runInBand` (apps/api): 21/21 e2e tests passed
- `npm run lint` (apps/api): clean (0 errors)
- `flutter test` (apps/mobile): 10/10 tests passed

### Completion Notes List

- Created `AuthGuard` in `src/common/guards/auth.guard.ts` — validates `Authorization: Bearer <token>`, attaches `req.user` for downstream controllers; reusable by all future modules
- Added `validateAccessToken(token)`, `findUserById(userId)`, `updateUser(userId, patch)` to `AuthService`; `validateAccessToken` is synchronous (no I/O) per `require-await` lint rule
- Added `displayName: string | null` to `AuthUser` interface; set to `null` on registration
- Created `AccountModule` with `AccountService`, `AccountController`, `account.dto.ts`, `account.types.ts`; `PATCH /account/profile` whitelist strips all fields except `displayName`
- Fixed `express.d.ts` to use inline `import()` type (not `import` statement) to preserve ambient global augmentation — adding an `import` statement breaks the `correlationId` declaration
- Created Flutter `AccountRepository` abstract + `InMemoryAccountRepository`; `AccountProfileScreen` with read-only email, editable displayName, Save button; `TextEditingController` disposed in `dispose()`
- Added `AccountProfileScreen` to `DoclyzerApp` navigation via `_AuthView.accountProfile`; `HomeScreen` gains `onGoToAccount` callback and Account button
- All 6 account e2e tests use unique email `account-profile@example.com` to avoid rate limit collisions with other test suites

### File List

- _bmad-output/implementation-artifacts/1-3-account-profile-management-view-update-basic-info.md
- apps/api/src/types/express.d.ts
- apps/api/src/modules/auth/auth.types.ts
- apps/api/src/modules/auth/auth.service.ts
- apps/api/src/common/guards/auth.guard.ts
- apps/api/src/common/guards/auth.guard.spec.ts
- apps/api/src/modules/account/account.module.ts
- apps/api/src/modules/account/account.service.ts
- apps/api/src/modules/account/account.service.spec.ts
- apps/api/src/modules/account/account.controller.ts
- apps/api/src/modules/account/account.dto.ts
- apps/api/src/modules/account/account.types.ts
- apps/api/src/app.module.ts
- apps/api/test/app.e2e-spec.ts
- apps/mobile/lib/features/account/account_repository.dart
- apps/mobile/lib/features/account/in_memory_account_repository.dart
- apps/mobile/lib/features/account/screens/account_profile_screen.dart
- apps/mobile/lib/features/auth/screens/home_screen.dart
- apps/mobile/lib/main.dart
- apps/mobile/test/account_profile_test.dart

## Change Log (review)

- 2026-03-13: Senior Developer Review (AI) — MEDIUM: userId in logs; fixed by removing userId from DATA_EXPORT_REQUESTED and CLOSURE_COMPLETED log payloads.

## Senior Developer Review (AI)

**Review date:** 2026-03-13

### Git vs Story
- No uncommitted changes at review time. File List matches implementation.

### Findings

| Severity | Finding | Location |
|----------|---------|----------|
| **MEDIUM** | `AccountService.createDataExportRequest` and `createClosureRequest` log `userId` in JSON payload (action, userId, requestId, correlationId). Project-context: "No PHI in logs — never log email addresses, passwords, tokens, user IDs". userId is an identifier that can be linked to PII; should not be logged. | `apps/api/src/modules/account/account.service.ts` ~174–180, ~254–260 |
| **LOW** | Story 1.3 scope was "displayName" only; `UpdateAccountProfileDto` and `updateProfile` also allow `avatarUrl`. Acceptable if added in a later story, but File List / completion notes don't document that 1.3 delivered avatar support. | account.dto.ts, account.service.ts |
| **LOW** | `AuthGuard` uses `JwtService` + `SessionEntity` directly; story text mentioned `AuthService.validateAccessToken`. Implementation is DB-backed (0.2/0.3); no bug, just evolution. | auth.guard.ts |

### AC / Task verification
- AC1 (GET profile, envelope, correlationId): **Met** — controller uses `successResponse`, service returns AccountProfile.
- AC2 (PATCH profile, persist displayName): **Met** — updateProfile updates displayName (and avatarUrl).
- AC3 (restricted fields stripped): **Met** — DTO whitelist only displayName, avatarUrl.
- AC4 (401 when unauthenticated): **Met** — `@UseGuards(AuthGuard)` on controller.
- Tasks [x]: AuthGuard, displayName, account module, e2e, Flutter — all evidenced in code.

### Outcome
**Done.** MEDIUM fix applied: `userId` removed from `DATA_EXPORT_REQUESTED` and `CLOSURE_COMPLETED` log payloads in `account.service.ts` (project-context: no user IDs in logs).
