# Code Review: Story 0-2 — JWT Access + Refresh Token Auth with DB-Backed Sessions

**Story file:** `0-2-jwt-access-refresh-token-auth-db-backed-sessions.md`  
**Story key:** `0-2-jwt-access-refresh-token-auth-db-backed-sessions`  
**Review date:** 2026-03-07

---

## Git vs Story Discrepancies

- **Files in git diff not in story File List:** `auth.controller.ts` is modified (rate-limit and response flow) but not listed in Dev Agent Record → File List. (Incomplete documentation.)
- **Untracked:** `apps/api/src/modules/auth/strategies/` (new dir) — story correctly lists `jwt.strategy.ts` as NEW.
- **Other modified files** (e.g. account, mobile, migrations) are outside this story’s scope; not counted as discrepancies for 0-2.

**Git vs Story discrepancy count:** 1 (auth.controller.ts omitted from File List).

---

## Findings Summary

| Severity | Count |
|----------|--------|
| HIGH     | 1     |
| MEDIUM   | 3     |
| LOW      | 3     |

---

## HIGH ISSUES

### 1. Session expiry not enforced at query level (AC violation)

**AC / Technical notes:** “expiresAt on SessionEntity enforced at query level (not just application level).”

**Current code:** In `auth.service.ts` `refresh()`, the code does:

- `findOne({ where: { refreshTokenHash: hash } })`
- Then checks `session.expiresAt <= new Date()` in application code.

So expired sessions can still be loaded from the DB; expiry is only enforced in app logic. The spec explicitly requires query-level enforcement.

**Required change:** In `refresh()`, use TypeORM’s `MoreThan(new Date())` (or equivalent) on `expiresAt` in the `where` clause so expired sessions are never returned by the query.

**File:** `apps/api/src/modules/auth/auth.service.ts` (refresh flow).

---

## MEDIUM ISSUES

### 2. Rate limiting missing on POST /auth/refresh

**Technical notes:** “Rate limiting on `/auth/login` and `/auth/refresh` stays in-memory for now.”

**Current code:** `auth.controller.ts` calls `enforceRateLimit` for `register`, `login`, and `forgot-password`, but **not** for `refresh`. So `/auth/refresh` is not rate-limited.

**Risk:** Refresh tokens can be replayed or brute-forced without rate limiting.

**Required change:** Call `enforceRateLimit` for the refresh route (e.g. same pattern as login: by IP and/or by a stable identifier), then invoke `authService.refresh(...)`.

**File:** `apps/api/src/modules/auth/auth.controller.ts`.

### 3. `expiresIn` hardcoded instead of from config

**Current code:** `auth.service.ts` returns `expiresIn: 900` in both `login()` and `refresh()`.

**Issue:** `JWT_ACCESS_TTL_SECONDS` is already used in `JwtModule.registerAsync` for signing. If the config value is changed (e.g. to 600), the API would still tell clients `900`, causing config drift and wrong client-side expiry behaviour.

**Required change:** Inject `ConfigService` (or a dedicated config factory) into `AuthService` and set `expiresIn` from `JWT_ACCESS_TTL_SECONDS` (with same default, e.g. 900) when building login/refresh responses.

**File:** `apps/api/src/modules/auth/auth.service.ts`.

### 4. Story File List omits modified file

**Current state:** Git shows `apps/api/src/modules/auth/auth.controller.ts` as modified, but the story’s Dev Agent Record → File List does not include it.

**Required change:** Add `apps/api/src/modules/auth/auth.controller.ts` to the story File List with a short note (e.g. “rate-limit and response wiring for login/refresh/logout/sessions”).

---

## LOW ISSUES

### 5. `req.user` shape vs AC wording

**AC:** “req.user is populated with `{ userId, sessionId }`.”

**Current code:** Guard sets `req.user = { id: payload.sub }` and `req.currentSessionId = payload.sessionId`. So the “userId” is exposed as `id`, and `sessionId` is a sibling property on the request, not inside `req.user`.

**Assessment:** Intentional for backward compatibility with existing `req.user.id` usage. No code change required; consider adding a one-line comment in the guard or in the story that `id` is the userId and `currentSessionId` is the sessionId.

### 6. Refresh token length differs from technical note

**Technical note:** “Refresh token: `crypto.randomBytes(32).toString('hex)`.”

**Current code:** `randomBytes(48).toString('hex)` in `createSession()`.

**Assessment:** 48 bytes gives more entropy; deviation is security-positive. Optional: update the story technical note to “32 or more bytes” or “48 bytes” so the doc matches the code.

### 7. Error code not in types file

**Project context:** “Error codes are screaming snake case constants … define constants in the module’s types file.”

**Current code:** `'INVALID_REFRESH_TOKEN'` is inlined in `auth.service.ts` in two places.

**Required change:** Add `INVALID_REFRESH_TOKEN = 'INVALID_REFRESH_TOKEN'` (or equivalent) in `auth.types.ts` and use that constant in the service.

**Files:** `apps/api/src/modules/auth/auth.types.ts`, `apps/api/src/modules/auth/auth.service.ts`.

---

## What was validated (no issues)

- Login returns `{ accessToken, refreshToken, expiresIn: 900 }` and creates a session with SHA-256(refreshToken), ipAddress, userAgent, expiresAt (30d). **OK.**
- Refresh rotates session (delete old, create new), returns same response shape, and uses `INVALID_REFRESH_TOKEN` for invalid/expired token. **OK** (aside from query-level expiry and rate limit).
- Logout deletes current SessionEntity by token-derived sessionId/userId. **OK.**
- AuthGuard is stateless (JwtService.verify only, no DB). **OK.**
- POST /auth/refresh is public (no AuthGuard). **OK.**
- Sessions list and revoke (GET/DELETE) behave as specified. **OK.**
- Registration uses bcrypt (cost 12) and returns requiresVerification. **OK.**
- JWT payload uses `sub` and `sessionId`. **OK.**

---

**Next step:** Choose how to handle these issues (fix automatically, add action items to the story, or deep-dive specific items).
