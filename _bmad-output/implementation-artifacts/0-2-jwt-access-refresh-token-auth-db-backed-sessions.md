# Story 0.2: JWT Access + Refresh Token Auth with DB-Backed Sessions

**Status:** backlog  
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
