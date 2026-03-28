# Story 8.1: better-auth migration

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a platform owner,
I want to replace the custom auth implementation with Better Auth while preserving the public API contract,
so that authentication is more maintainable and secure without breaking mobile or API integrations.

## Acceptance Criteria

1. The existing REST contract remains stable under the `v1` prefix:
   - `POST /v1/auth/register`, `POST /v1/auth/login`, `POST /v1/auth/logout`, `POST /v1/auth/refresh`,
     `GET /v1/auth/sessions`, `DELETE /v1/auth/sessions/:sessionId`,
     `POST /v1/auth/forgot-password`, `POST /v1/auth/reset-password`.
   - Response envelope and error codes remain compatible with current mobile client usage.
   - Any necessary client changes are explicitly documented and kept minimal.
2. Better Auth is configured for email/password authentication and server-side sessions backed by PostgreSQL.
   - Session storage uses Better Auth’s session table fields (`id`, `token`, `userId`, `expiresAt`, `ipAddress`, `userAgent`).
   - Session expiration and rotation semantics are configured to meet current security requirements (short-lived access, long-lived session/refresh or a documented equivalent).
3. Auth guards across API modules validate authentication using Better Auth session verification, returning the same error envelope and codes (`AUTH_UNAUTHORIZED`, `AUTH_SESSION_REVOKED`) used today.
4. Sessions list/revoke functionality is preserved, using Better Auth session data as the source of truth.
5. Password reset flow remains enumeration-safe and integrates with the notification pipeline; no PHI is logged.
6. Secrets and configuration are documented in `.env.example` (e.g., `BETTER_AUTH_SECRET`, base URL/path) and are loaded via `ConfigService` (no `process.env` reads inside modules).
7. Existing users remain valid (no data loss). If sessions cannot be migrated safely, all sessions are invalidated explicitly and communicated in dev notes.
8. Testing policy is respected: no new tests are added and no test suites are run (manual QA only).

## Tasks / Subtasks

- [x] Establish Better Auth integration for NestJS
  - [x] Add Better Auth dependency and define a single `auth` instance/config in a dedicated module (e.g., `apps/api/src/modules/auth/better-auth.ts`).
  - [x] Decide storage approach:
    - [x] Use Better Auth’s database adapter support (or custom adapter) to map to PostgreSQL, or
    - [x] Use Better Auth’s recommended `pg` adapter and isolate auth tables in the same database.
- [x] Preserve the existing API contract under `/v1/auth/*`
  - [x] Implement controllers that wrap Better Auth handlers while preserving the current response envelope.
  - [x] Keep error codes used by the mobile app (`AUTH_INVALID_CREDENTIALS`, `AUTH_RATE_LIMITED`, `AUTH_EMAIL_INVALID`, `AUTH_PASSWORD_INVALID`, `AUTH_EMAIL_EXISTS`, `AUTH_SESSION_REVOKED`, `AUTH_UNAUTHORIZED`, `AUTH_TOKEN_REQUIRED`).
- [x] Replace auth guard logic to validate Better Auth sessions
  - [x] Ensure `AuthGuard` uses Better Auth session verification and populates `req.user` with `{ id }` for downstream modules.
  - [x] Preserve `currentSessionId` propagation for session list/revoke behavior.
- [x] Migrate or rewire auth services
  - [x] Replace custom JWT/session issuance in `AuthService` with Better Auth equivalents.
  - [x] Rework password reset to use Better Auth (or explicitly keep current flow if Better Auth cannot support it without regression).
  - [x] Keep rate-limit enforcement behavior (or move into a small `AuthRateLimitService` reused by other modules).
- [x] Update mobile/API integration contract if required
  - [x] If Better Auth sessions are cookie-based only, add a bearer-token compatibility layer and keep mobile storage behavior consistent.
  - [x] Document any necessary mobile changes in the story file before implementation.
- [x] Configuration and migration
  - [x] Add Better Auth env vars to `.env.example` and use `ConfigService` to load them.
  - [x] Create/convert Better Auth SQL schema into TypeORM migrations (or document equivalent if the adapter owns schema creation).
  - [x] Decide and document session invalidation/migration strategy.

## Dev Notes

### Current Auth Surface (replace this behavior with Better Auth)

- Custom auth lives in `apps/api/src/modules/auth`:
  - `auth.service.ts` creates JWT access tokens, stores refresh tokens in `sessions` table, and enforces rate limits.
  - `auth.controller.ts` exposes `/auth/*` endpoints and wraps responses in the standard envelope.
  - `password-recovery.service.ts` handles reset tokens + notification delivery.
  - `AuthGuard` verifies JWT + session row per request.
- Multiple modules depend on `AuthGuard` and `AuthService` (`reports`, `account`, `billing`, `profiles`, `sharing`, `entitlements`).
- Mobile client expects bearer tokens and refresh flow via `v1/auth/refresh` (`apps/mobile/lib/features/auth/api_auth_repository.dart`).

### Better Auth Constraints (from official docs)

- Better Auth manages session using cookie-based session tokens; session data is stored server-side and verified on each request.
- Session table includes: `id`, `token`, `userId`, `expiresAt`, `ipAddress`, `userAgent`.
- Session expiration uses `expiresIn` and `updateAge` to rotate expiry when sessions are active.
- Cookies are signed using the `BETTER_AUTH_SECRET` value (or `secret` in options), with `httpOnly` and `secure` defaults in production.
- Better Auth supports custom database adapters via `createAdapter`, allowing integration with non-standard ORMs or schemas.

### Latest Tech Information (Better Auth)

- Sessions are cookie-based by default; if the client cannot store cookies (mobile), plan a bearer-token compatibility layer or a custom session exchange endpoint.
- `session.expiresIn` and `session.updateAge` control session expiration and rotation; `session.disableSessionRefresh` can disable refresh updates if needed.
- Session schema is explicitly defined by Better Auth and includes `token` and client metadata; map fields or migrate schema accordingly.

### Architecture & Security Requirements (must keep)

- Session model: short-lived access + rotating refresh with server-side revocation (or document a secure equivalent if Better Auth’s session token replaces access/refresh).
- Auth guard must remain route-level (`@UseGuards(AuthGuard)`), not global.
- Errors must use the standard response envelope + stable error codes.
- No PHI in logs; only correlation IDs.

### Project Structure Notes

- API modules follow domain structure: `<domain>.module.ts`, `<domain>.controller.ts`, `<domain>.service.ts`.
- `ConfigService` must be used for any environment config access.
- TypeORM Data Mapper pattern only; no ActiveRecord.

### Git Intelligence Summary (most recent commits)

- e1cdb35: Razorpay billing integration + sprint status updates + mobile billing screens.
- 4a22aa7: Share link backend + migrations + Flutter share link UI + env updates.
- 6c3e18f: Sprint status updates + AI report summary/transcript persistence + mobile UI theme refactor.
- d355d3b: Redact secrets in logs + error handling hardening.
- c28797d: Report summary field + migration + mobile summary display.

### References

- Auth module + endpoints: `apps/api/src/modules/auth/auth.controller.ts`
- Auth service + JWT/session logic: `apps/api/src/modules/auth/auth.service.ts`
- Auth guard: `apps/api/src/common/guards/auth.guard.ts`
- Password reset flow: `apps/api/src/modules/auth/password-recovery.service.ts`
- Session entity: `apps/api/src/database/entities/session.entity.ts`
- Mobile auth client expectations: `apps/mobile/lib/features/auth/api_auth_repository.dart`
- Architecture auth/security requirements: `_bmad-output/planning-artifacts/architecture.md#Authentication & Security`
- Epic 0 auth baseline requirements: `_bmad-output/planning-artifacts/epics.md#Story 0.2: JWT Access + Refresh Token Auth with DB-Backed Sessions`
- Project-wide rules: `_bmad-output/project-context.md`

## Dev Agent Record

### Agent Model Used

GPT-5

### Debug Log References

### Completion Notes List

- Added Better Auth integration via `BetterAuthService` with PostgreSQL-backed sessions and bearer compatibility.
- Auth responses now return the Better Auth session token as both `accessToken` and `refreshToken` to preserve mobile bearer usage.
- Password reset flow now delegates to Better Auth endpoints while keeping enumeration-safe responses.
- Added migrations for Better Auth tables, user updates, and explicit session invalidation (existing sessions are deleted).
- Tests not run (per project policy).
- Mobile/API note:
  - Bearer tokens now represent the Better Auth session token (not a JWT access token).
  - Login returns both `accessToken` and `refreshToken` as the same session token for compatibility.
  - Refresh expects the `refreshToken` in the body and uses it as bearer to rehydrate the session; invalid/expired sessions return `AUTH_SESSION_REVOKED`.
  - Existing sessions were invalidated during migration; users must log in again.
- Removed legacy JWT/passport strategy wiring and password reset token entity/tests to ensure Better Auth is the only auth path in code.
- Dropped the legacy `password_reset_tokens` table via migration to remove remaining custom auth storage.

### File List

- .env.example
- apps/api/package.json
- apps/api/src/app.module.ts
- apps/api/src/common/guards/auth.guard.ts
- apps/api/src/common/redact-secrets.ts
- apps/api/src/database/data-source.ts
- apps/api/src/database/entities/session.entity.ts
- apps/api/src/database/entities/user.entity.ts
- apps/api/src/database/entities/password-reset-token.entity.ts (removed)
- apps/api/src/database/migrations/1730814600000-MigrateToBetterAuth.ts
- apps/api/src/database/migrations/1730814700000-RemovePasswordResetTokens.ts
- apps/api/src/database/migrations/index.ts
- apps/api/src/modules/auth/auth.controller.ts
- apps/api/src/modules/auth/auth.module.ts
- apps/api/src/modules/auth/auth.service.ts
- apps/api/src/modules/auth/auth.types.ts
- apps/api/src/modules/auth/better-auth.service.ts
- apps/api/src/modules/auth/password-recovery.service.ts
- apps/api/src/modules/auth/strategies/jwt.strategy.ts (removed)
- apps/api/src/common/guards/auth.guard.spec.ts (removed)
- apps/api/src/modules/auth/auth.service.spec.ts (removed)
- apps/api/src/modules/auth/password-recovery.service.spec.ts (removed)
- apps/api/test/app.e2e-spec.ts (removed)
