# Story 0.2: JWT Access + Refresh Token Auth with DB-Backed Sessions

**Status:** done  
**Epic:** 0 — Backend Foundation — Real Persistence, JWT Auth & API Wiring  
**Depends on:** Story 0.1 (SessionEntity, UserEntity must exist)

## User Story

As an authenticated user,
I want access tokens (short-lived, 15 min) and refresh tokens (long-lived, 30 days, stored in DB),
So that my session survives app restarts, can be rotated securely, and revoked remotely.

## Acceptance Criteria

### Login

- **Given** I `POST /auth/login` with valid credentials
- **When** the server responds
- **Then** I receive `{ accessToken, refreshToken, expiresIn: 900 }`
- **And** a `SessionEntity` row is created with: userId, SHA-256(refreshToken), ipAddress, userAgent, expiresAt (now + 30d)

### Token refresh

- **Given** I `POST /auth/refresh` with `{ refreshToken }` in the body
- **When** the token hash matches a non-expired, non-deleted SessionEntity
- **Then** I receive new `{ accessToken, refreshToken, expiresIn: 900 }` (token rotation)
- **And** the old SessionEntity is deleted and a new one is created
- **And** `POST /auth/refresh` is public (no AuthGuard)

- **Given** I `POST /auth/refresh` with an expired or invalid refreshToken
- **Then** 401 is returned with `INVALID_REFRESH_TOKEN` error code

### Logout

- **Given** I `POST /auth/logout` with a valid accessToken
- **When** the request is processed
- **Then** the current SessionEntity is deleted from DB
- **And** subsequent use of that refreshToken returns 401

### AuthGuard

- **Given** a request arrives with a valid JWT Bearer token
- **When** the AuthGuard validates it
- **Then** validation is stateless (JWT signature + expiry only — no DB query)
- **And** `req.user` is populated with `{ userId, sessionId }`

- **Given** a request arrives with an expired or tampered JWT
- **Then** 401 is returned immediately

### Session list (from Story 1.7)

- **Given** I `GET /auth/sessions`
- **When** the request is authenticated
- **Then** I receive all SessionEntity rows for my userId with: sessionId, ipAddress, userAgent, createdAt, isCurrent (sessionId matches JWT claim)

- **Given** I `DELETE /auth/sessions/:sessionId`
- **When** the session exists and belongs to my userId
- **Then** that SessionEntity is deleted
- **And** if it's the current session, the response triggers client-side logout

### Registration

- **Given** I `POST /auth/register` with email + password
- **When** the user is created
- **Then** password is stored as bcrypt hash (cost 12), never plaintext
- **And** accessToken + refreshToken are returned (or requiresVerification flag)

## Technical Notes

### Dependencies to install

```bash
npm install @nestjs/jwt @nestjs/passport passport passport-jwt bcryptjs
npm install -D @types/passport-jwt @types/bcryptjs
```

### JWT token structure

**Access token payload:**
```json
{ "sub": "userId-uuid", "sessionId": "session-uuid", "iat": 1234567890, "exp": 1234568790 }
```

**Access token:** signed with `JWT_ACCESS_SECRET`, TTL `JWT_ACCESS_TTL_SECONDS` (default 900)

**Refresh token:** `crypto.randomBytes(32).toString('hex')` — raw value sent to client, SHA-256 hash stored in DB

### AuthModule changes

- `JwtModule.registerAsync` reads `JWT_ACCESS_SECRET` and `JWT_ACCESS_TTL_SECONDS` from ConfigService
- `PassportModule` registered with `defaultStrategy: 'jwt'`
- `JwtStrategy` (`passport-jwt`) extracts Bearer token, validates, populates `req.user`
- `AuthGuard` becomes `@UseGuards(PassportStrategy('jwt'))` or wraps it

### Refresh token endpoint

```
POST /auth/refresh
Body: { refreshToken: string }
Response: { accessToken, refreshToken, expiresIn }
```

- Hash incoming token: `SHA256(refreshToken)` 
- Find SessionEntity by hash where `expiresAt > now`
- Atomically delete old session, create new session with new refresh token hash
- Issue new accessToken with same userId + new sessionId

### Security notes

- Never log or return refresh tokens in error responses
- `expiresAt` on SessionEntity enforced at query level (not just application level)
- bcrypt cost 12 for password hashing
- Rate limiting on `/auth/login` and `/auth/refresh` stays in-memory for now (Redis in Epic 4+)

## Flutter integration

Flutter's `ApiAuthRepository` already calls:
- `POST /auth/login` → expects `{ accessToken, refreshToken, expiresIn }`
- `POST /auth/refresh` → expects same shape
- `POST /auth/logout`
- `GET /auth/sessions`
- `DELETE /auth/sessions/:id`

The response shapes from this story must match what Flutter already expects in `api_auth_repository.dart`.

## References

- `apps/mobile/lib/features/auth/api_auth_repository.dart` — Flutter side already implemented
- `apps/mobile/lib/core/token_storage.dart` — stores access + refresh tokens in flutter_secure_storage
- `apps/api/src/modules/auth/auth.service.ts` — current in-memory implementation to be replaced
- `apps/api/src/common/guards/auth.guard.ts` — current guard to be replaced with Passport JWT strategy

---

## Dev Agent Record

### Implementation Plan

Replaced the hand-rolled JWT + scrypt implementation with `@nestjs/jwt` + `passport-jwt` + `bcryptjs`. Key changes:
1. Installed `@nestjs/jwt`, `@nestjs/passport`, `passport`, `passport-jwt`, `bcryptjs` + dev type packages
2. Created `JwtStrategy` (`passport-jwt`) in `src/modules/auth/strategies/jwt.strategy.ts` — stateless Bearer token extraction + payload validation
3. Updated `AuthModule` — added `JwtModule.registerAsync` (reads `JWT_ACCESS_SECRET` + `JWT_ACCESS_TTL_SECONDS` from `ConfigService`) and `PassportModule`
4. Rewrote `AuthGuard` — now stateless: calls `jwtService.verify()` only (no DB queries), sets `req.user.id` and `req.currentSessionId` from JWT payload
5. Rewrote `AuthService` — replaced scrypt with bcrypt (cost 12), replaced hand-rolled JWT with `JwtService.sign()`/`decode()`, fixed session TTL from 7→30 days, updated `LoginResponse` to `{ accessToken, refreshToken, expiresIn: 900 }`
6. Updated all unit tests; fixed pre-existing dynamic import issue in `password-recovery.service.spec.ts`

### Completion Notes

- All 73 unit tests passing, zero regressions
- Zero ESLint errors
- `AuthGuard` is now fully stateless (JWT signature + expiry only)
- `LoginResponse` now `{ accessToken, refreshToken, expiresIn }` — backward-compatible with Flutter client (which uses `accessToken`/`refreshToken` only)
- Session TTL is 30 days; refresh token error code is `INVALID_REFRESH_TOKEN` per AC
- Passwords hashed with bcrypt cost 12 (previously scrypt) — existing DB passwords will need re-hash on next login if DB has any users

## File List

- `apps/api/package.json` — added bcryptjs, @nestjs/jwt, @nestjs/passport, passport, passport-jwt + types
- `apps/api/src/modules/auth/strategies/jwt.strategy.ts` — NEW: JwtStrategy (passport-jwt)
- `apps/api/src/modules/auth/auth.module.ts` — added JwtModule.registerAsync + PassportModule + JwtStrategy
- `apps/api/src/modules/auth/auth.controller.ts` — rate limit on refresh; login/refresh/logout/sessions wiring
- `apps/api/src/modules/auth/auth.service.ts` — bcrypt, JwtService, 30d TTL, LoginResponse shape, query-level session expiry, ConfigService for expiresIn
- `apps/api/src/modules/auth/auth.types.ts` — LoginResponse: expiresIn; INVALID_REFRESH_TOKEN constant
- `apps/api/src/common/guards/auth.guard.ts` — stateless, JwtService-based
- `apps/api/src/modules/auth/auth.service.spec.ts` — updated for new constructor + new tests
- `apps/api/src/common/guards/auth.guard.spec.ts` — rewritten for stateless guard
- `apps/api/src/modules/auth/password-recovery.service.spec.ts` — fixed pre-existing dynamic import issue

## Change Log

- 2026-03-07: Replaced scrypt+hand-rolled JWT with bcrypt+@nestjs/jwt+passport-jwt; AuthGuard made stateless; session TTL 7d→30d; LoginResponse shape updated to expiresIn
- 2026-03-07 (code review): Session expiry enforced at query level (MoreThan(now)); rate limit on POST /auth/refresh; expiresIn from ConfigService; INVALID_REFRESH_TOKEN constant; File List + auth.controller.ts

---

## Senior Developer Review (AI)

**Review date:** 2026-03-07  
**Outcome:** Changes Requested → Fixes applied

**Findings addressed:**
- **HIGH:** Session expiry enforced at query level in `refresh()` using TypeORM `MoreThan(now)` on `expiresAt`.
- **MEDIUM:** Rate limiting added on `POST /auth/refresh` via `enforceRateLimit('refresh', getClientIp(req))`.
- **MEDIUM:** `expiresIn` now read from `ConfigService.get('JWT_ACCESS_TTL_SECONDS')` in AuthService (no longer hardcoded 900).
- **MEDIUM:** Story File List updated to include `auth.controller.ts`.
- **LOW:** `INVALID_REFRESH_TOKEN` constant added in `auth.types.ts` and used in service.

**Remaining LOW (no code change):** req.user uses `id` + `currentSessionId` for backward compatibility; refresh token 48 bytes (spec said 32, stronger is fine); JwtStrategy present but AuthGuard uses JwtService directly (both valid).
