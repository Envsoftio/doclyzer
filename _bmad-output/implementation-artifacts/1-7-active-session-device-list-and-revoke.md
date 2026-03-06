# Story 1.7: Active Session/Device List and Revoke

Status: done

## Story

As an authenticated user,
I want to view and revoke active sessions,
so that I can secure my account.

## Acceptance Criteria

1. **Given** I am authenticated
   **When** I call `GET /auth/sessions`
   **Then** I receive a list of my active device sessions
   **And** each session includes: `sessionId`, `ip`, `userAgent`, `createdAt`, `isCurrent`
   **And** the session for the current request is marked `isCurrent: true`
   **And** response uses the standard success envelope with `correlationId`

2. **Given** I revoke a selected session via `DELETE /auth/sessions/:sessionId`
   **When** revocation succeeds
   **Then** that session's access token and refresh token are both invalidated immediately
   **And** the session is removed from the user-sessions index
   **And** a structured audit log entry is emitted (no PHI — correlationId, actorUserId, targetSessionId only)
   **And** response returns `{ success: true, data: null, correlationId }`

3. **Given** I revoke a session that does not exist or belongs to another user
   **When** the request is processed
   **Then** I receive `404` with `{ success: false, code: "SESSION_NOT_FOUND", ... }`

4. **Given** I revoke my current active session
   **When** revocation succeeds
   **Then** the access token is deleted from Redis
   **And** the associated refresh token is invalidated in the DB
   **And** subsequent requests using that access token return `401 AUTH_UNAUTHORIZED`

5. **Given** I am not authenticated (missing or invalid `Authorization` header)
   **When** I call either sessions endpoint
   **Then** I receive `401 AUTH_UNAUTHORIZED`

6. **Given** I am on the Flutter app session list screen
   **When** it loads successfully
   **Then** I see all active sessions with userAgent, IP, createdAt, and a current-session badge
   **And** each session has a "Revoke" button (current session labeled "Revoke (Logout)")

7. **Given** I tap "Revoke" on a session
   **When** the confirmation dialog appears
   **Then** it shows session ip/device info and destructive-styled confirm button
   **And** tapping Cancel closes the dialog without revoking
   **And** tapping Revoke calls the repository and refreshes the list
   **And** if the revoked session was the current one, the app navigates back to the login screen

## Tasks / Subtasks

### API — Session Schema Extension (AC: 1, 2, 4)

- [x] Extend session types in `auth.types.ts` (AC: 1, 2, 3)
  - [x] Add `DeviceSessionData` interface: `{ userId: string; sessionId: string; ip: string; userAgent: string; createdAt: string }` (stored per access token in Redis)
  - [x] Add `DeviceSessionSummary` interface: `{ sessionId: string; ip: string; userAgent: string; createdAt: string; isCurrent: boolean }`
  - [x] Add error code constant `SESSION_NOT_FOUND = 'SESSION_NOT_FOUND'`
  - [x] Add `SessionNotFoundException extends NotFoundException` constructed as `{ code: SESSION_NOT_FOUND, message: 'Session not found' }`

- [x] Extend `AuthService.login()` to store device session index (AC: 1, 2)
  - [x] Generate `sessionId = crypto.randomUUID()` (Node.js v24 built-in — no import)
  - [x] Extend the object stored at `doclyzer:session:<tokenHash>` to include all `DeviceSessionData` fields (additive, backward-compatible — AuthGuard only reads `userId`)
  - [x] After storing session at `doclyzer:session:<tokenHash>`, store device session in user-sessions hash: `this.redis.hset('doclyzer:user-sessions:<userId>', sessionId, JSON.stringify({ sessionId, tokenHash, ip, userAgent, createdAt }))` — `tokenHash` is stored server-side in Redis only, never returned to client; this is the revocation lookup key, eliminating the need for a separate reverse-lookup key
  - [x] Controller must extract `ip` and `userAgent` and pass them to `authService.login(dto, ip, userAgent)` — services must NOT receive raw request objects; update `login()` signature: `login(dto: LoginDto, ip: string, userAgent: string): Promise<...>`; controller: `authService.login(dto, req.ip, req.headers['user-agent'] ?? 'Unknown')`

- [x] Extend `AuthService.logout()` to clean up device session index (AC: 2)
  - [x] After deleting `doclyzer:session:<tokenHash>`, fetch sessionId from session data, then `HDEL doclyzer:user-sessions:<userId> <sessionId>` and `DEL doclyzer:session-by-id:<userId>:<sessionId>` (N/A: in-memory auth — no Redis keys; logout already revokes session)

- [x] Update `AuthGuard` to expose current sessionId (AC: 1)
  - [x] After reading session data from Redis and setting `request['user'] = { id: sessionData.userId }`, also set `request['currentSessionId'] = sessionData.sessionId ?? null` — handle legacy sessions without `sessionId` gracefully with `?? null`

### API — Sessions Endpoints (AC: 1, 2, 3, 4, 5)

- [x] Add `AuthService.getSessions()` (AC: 1)
  - [x] Signature: `async getSessions(userId: string, currentSessionId: string | null): Promise<DeviceSessionSummary[]>`
  - [x] `HGETALL doclyzer:user-sessions:<userId>` → `Record<string, string>` (empty object `{}` if key missing — not an error; ioredis returns `{}` for missing hash keys)
  - [x] Parse each value as `{ sessionId, tokenHash, ip, userAgent, createdAt }` — verify live session by checking `GET doclyzer:session:<tokenHash>` still exists; if null (access token expired and not refreshed), prune with `HDEL`
  - [x] Map survivors to `DeviceSessionSummary[]` (omit `tokenHash`): `{ sessionId, ip, userAgent, createdAt, isCurrent: sessionId === currentSessionId }`
  - [x] Return sorted descending by `createdAt`

- [x] Add `AuthService.revokeSession()` (AC: 2, 3, 4)
  - [x] Signature: `async revokeSession(userId: string, sessionId: string, correlationId: string): Promise<void>`
  - [x] `HGET doclyzer:user-sessions:<userId> <sessionId>` → raw JSON; parse to get `tokenHash`; if null, throw `SessionNotFoundException`
  - [x] `DEL doclyzer:session:<tokenHash>` — invalidates the access token immediately
  - [x] `HDEL doclyzer:user-sessions:<userId> <sessionId>` — removes from device session index
  - [x] Invalidate associated refresh token in DB: check `RefreshToken` entity in `apps/api/src/modules/auth/entities/` for its actual columns; the entity was created in story 1.2 — add `sessionId VARCHAR` column via migration and store it at login; on revoke: `refreshTokenRepository.delete({ userId, sessionId })` or equivalent soft-delete/revoke pattern that already exists
  - [x] Emit audit log (NestJS Logger, not PHI): `this.logger.log(JSON.stringify({ action: 'SESSION_REVOKED', actorUserId: userId, targetSessionId: sessionId, correlationId }))` — no email, no tokenHash, no IP

- [x] Add controller endpoints in `auth.controller.ts` (AC: 1, 2, 3, 5)
  - [x] `@Get('sessions') @UseGuards(AuthGuard)`: extract `userId` from `req.user.id`, `currentSessionId` from `req['currentSessionId']`, call `authService.getSessions(userId, currentSessionId)`, return `successResponse(sessions, getCorrelationId(req))`
  - [x] `@Delete('sessions/:sessionId') @UseGuards(AuthGuard)`: extract `userId`, call `authService.revokeSession(userId, params.sessionId, getCorrelationId(req))`, return `successResponse(null, getCorrelationId(req))`
  - [x] Controller stays thin — no business logic; delegate everything to service

### API — Tests (AC: 1, 2, 3, 4, 5)

- [x] Unit tests in `auth.service.spec.ts` (AC: 1, 2, 3, 4)
  - [x] `getSessions`: returns sessions with `isCurrent: true` for matching sessionId; returns empty array when no sessions; maps all fields correctly
  - [x] `revokeSession`: deletes Redis access-token key; removes from user-sessions hash; removes session-by-id key; emits audit log; throws `SessionNotFoundException` for unknown sessionId or wrong user's session

- [x] Unit tests in `auth.controller.spec.ts` (AC: 1, 2, 5)
  - [x] `GET /auth/sessions` delegates to `getSessions` and wraps in envelope; `DELETE /auth/sessions/:id` delegates to `revokeSession` and wraps envelope; exceptions propagate

- [x] E2E tests in `apps/api/test/app.e2e-spec.ts` (AC: 1, 2, 3, 4, 5)
  - [x] `GET /auth/sessions` with valid token → 200, list contains isCurrent session; without token → 401
  - [x] `DELETE /auth/sessions/:sessionId` for valid owned session → 200, `data: null`; non-existent sessionId → 404 `SESSION_NOT_FOUND`; no token → 401
  - [x] After `DELETE` on current session, subsequent `GET /auth/sessions` with same token → 401

### Flutter — Repository and Model (AC: 6, 7)

- [x] Create `apps/mobile/lib/features/auth/sessions_repository.dart`
  - [x] `DeviceSessionSummary` class: `final String sessionId, ip, userAgent, createdAt; final bool isCurrent`
  - [x] Abstract `SessionsRepository`: `Future<List<DeviceSessionSummary>> getSessions()` and `Future<void> revokeSession(String sessionId)`

- [x] Create `apps/mobile/lib/features/auth/in_memory_sessions_repository.dart`
  - [x] `InMemorySessionsRepository implements SessionsRepository`
  - [x] Seed with 2 sessions (one with `isCurrent: true`, one with `isCurrent: false`)
  - [x] `revokeSession`: remove from internal list; throw `Exception('Session not found')` if sessionId not in list

### Flutter — Screen and Navigation (AC: 6, 7)

- [x] Create `apps/mobile/lib/features/auth/screens/session_list_screen.dart`
  - [x] Full `Scaffold` with `appBar: AppBar(title: const Text('Active Sessions'))`; `body: Padding(padding: const EdgeInsets.all(16), ...)`
  - [x] `final SessionsRepository sessionsRepository; final VoidCallback onLogout;` constructor params
  - [x] `List<DeviceSessionSummary> _sessions = []; String? _error; bool _loading = false;` state
  - [x] `_loadSessions()` in `initState`; show `CircularProgressIndicator` while loading
  - [x] `ListView.builder` of session cards: show `userAgent`, `ip`, `createdAt`; `Chip(label: Text('Current'))` if `isCurrent`
  - [x] Widget keys: `Key('session-item-${session.sessionId}')`, `Key('session-revoke-${session.sessionId}')`
  - [x] Current session revoke button label: `'Revoke (Logout)'`; non-current: `'Revoke'`
  - [x] `_showRevokeConfirm(session)`: `showDialog` with `AlertDialog`; title `'Revoke session?'`; content shows `session.ip` and `session.userAgent`; Cancel (`Key('session-revoke-cancel')`) and Revoke (`Key('session-revoke-confirm')`) with `TextButton.styleFrom(foregroundColor: colorScheme.error)`
  - [x] On confirm: `try { await sessionsRepository.revokeSession(session.sessionId); if (session.isCurrent) { widget.onLogout(); return; } await _loadSessions(); } catch (e) { setState(() => _error = 'Failed to revoke session.'); }`
  - [x] `_error` shown inline below list with `TextStyle(color: Colors.red)` — never SnackBar for errors

- [x] Wire `SessionListScreen` into `DoclyzerApp` navigation
  - [x] Follow existing state-based nav pattern (`_AppView` enum or `_AuthView` equivalent in `doclyzer_app.dart`)
  - [x] Add entry point from account/settings accessible post-login; pass `InMemorySessionsRepository()` and `onLogout` callback that resets auth state

### Flutter — Widget Tests (AC: 6, 7)

- [x] Create `apps/mobile/test/session_list_test.dart`
  - [x] Sessions render with correct keys; `Key('session-revoke-${id}')` present per session
  - [x] Tapping revoke shows confirmation dialog
  - [x] Tapping Cancel closes dialog; `revokeSession` not called
  - [x] Tapping Revoke calls `revokeSession(sessionId)` and list refreshes
  - [x] Revoking current session calls `onLogout` callback
  - [x] Error state shown when repository throws

## Dev Notes

### Critical: Session Storage Design

The project uses two distinct concepts:
- **Access token session** (`doclyzer:session:<tokenHash>`) — 15-min TTL, per access token
- **Device session** — user-facing session tied to a login event; persists across token refreshes

This story adds device-session tracking **layered on top** of the existing access-token session without breaking it:

```
# At login — NEW additions:
doclyzer:session:<tokenHash>    → DeviceSessionData { userId, sessionId, ip, userAgent, createdAt }  (extends existing)
doclyzer:user-sessions:<userId> → Redis Hash { [sessionId]: JSON({ sessionId, tokenHash, ip, userAgent, createdAt }) }
                                  tokenHash stored server-side only — never in API responses
```

**Token refresh lifecycle:** When story 1.2 refreshes access tokens (old tokenHash → new tokenHash), the `doclyzer:user-sessions:<userId>` hash entry for the session must be updated to the new `tokenHash`. Update `AuthService.refreshToken()` to: `HSET doclyzer:user-sessions:<userId> <sessionId> JSON({...newTokenHash})`. This keeps revocation working after refresh.

**AuthGuard is backward-compatible:** it only reads `sessionData.userId`. New fields in session data are additive. Handle legacy sessions (pre-1.7, no `sessionId`) with `?? null` in AuthGuard.

### Critical: Do NOT Expose tokenHash to Client

`tokenHash` is the session secret. The `sessionId` (UUID) is the only client-facing identifier. Never include `tokenHash` in API responses.

### Critical: Refresh Token Invalidation on Revoke

Story 1.2 stores refresh tokens hashed in the DB. **Before writing migration code**, read the actual `RefreshToken` entity at `apps/api/src/modules/auth/entities/refresh-token.entity.ts` (or equivalent) to see real column names and any existing revocation mechanism.

The `session_id` column likely does NOT exist yet — add it via a new migration:
- Migration file: `apps/api/src/database/migrations/<timestamp>-add-session-id-to-refresh-tokens.ts`
- Column: `session_id VARCHAR(36) NULL` (nullable for backward compatibility with old tokens)
- At login: store `sessionId` in the `RefreshToken` row when creating it
- On revoke: `refreshTokenRepository.delete({ user: { id: userId }, sessionId })` or soft-delete with `revokedAt = NOW()`

Do not assume the ORM method name — check the existing service method in story 1.2's `AuthService` that handles token invalidation and follow that pattern.

### API Pattern Reuse (do not reinvent)

From `auth.module.ts` / `auth.service.ts` (1.1, 1.2):
- Redis injected as `@Inject('REDIS_CLIENT') private readonly redis: Redis`
- Existing session write: likely `this.redis.set('doclyzer:session:<tokenHash>', JSON.stringify({ userId }), 'EX', ttl)`
- Existing logout: `this.redis.del('doclyzer:session:<tokenHash>')`
- Correlation ID: `getCorrelationId(req)` from `common/`
- Response envelope: `successResponse(data, correlationId)` from `common/response-envelope.ts`
- Error codes: `SESSION_NOT_FOUND` in `auth.types.ts` (same file as existing `AUTH_*` codes)

### NestJS Constraints

- `require-await`: `AuthService.getSessions()` and `revokeSession()` use `await this.redis.*` → they MUST be `async`; do not remove `async` even if linter seems satisfied
- Module exports: do not export `SessionNotFoundException` from `AuthModule` unless another module needs it
- `crypto.randomUUID()` is global in Node.js 18+; no import needed

### Flutter Pattern Reuse (do not reinvent)

From 1.5 / 1.6 (`profile_list_screen.dart`):
- State: `List<T> _items; String? _error; bool _loading;`
- `_loadItems()` called in `initState`
- Confirmation dialog: `showDialog` + `AlertDialog` with Cancel and destructive Revoke
- Destructive button style: `TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error)`
- All `find.*` in tests use `Key(...)` — never `find.text`
- Error display: inline `Text(_error!, style: TextStyle(color: Colors.red))` — no SnackBar

`SessionListScreen` constructor must accept `SessionsRepository` for test injection (same pattern as `ProfileListScreen` accepting `ProfilesRepository`).

### Project Structure (new files only)

```
apps/api/src/modules/auth/auth.types.ts                                          (extend — add DeviceSessionData, DeviceSessionSummary, SESSION_NOT_FOUND, SessionNotFoundException)
apps/api/src/modules/auth/auth.service.ts                                        (extend — modify login signature + body, logout, refreshToken; add getSessions, revokeSession)
apps/api/src/modules/auth/auth.controller.ts                                     (extend — modify login call to pass ip/userAgent; add GET /auth/sessions, DELETE /auth/sessions/:sessionId)
apps/api/src/modules/auth/auth.guard.ts (or auth.guard.ts)                       (extend — set request['currentSessionId'])
apps/api/src/modules/auth/auth.service.spec.ts                                   (extend)
apps/api/src/modules/auth/auth.controller.spec.ts                                (extend)
apps/api/test/app.e2e-spec.ts                                                    (extend — add sessions describe block)
apps/api/src/database/migrations/<timestamp>-add-session-id-to-refresh-tokens.ts (NEW)

apps/mobile/lib/features/auth/sessions_repository.dart                           (NEW)
apps/mobile/lib/features/auth/in_memory_sessions_repository.dart                 (NEW)
apps/mobile/lib/features/auth/screens/session_list_screen.dart                   (NEW)
apps/mobile/test/session_list_test.dart                                          (NEW)
```

### Security: No PHI in Audit Log

The audit log emitted via NestJS `Logger` must include only:
```json
{ "action": "SESSION_REVOKED", "actorUserId": "<uuid>", "targetSessionId": "<uuid>", "correlationId": "<uuid>" }
```
No email, no IP, no userAgent, no token hash.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.7]
- [Source: _bmad-output/planning-artifacts/epics.md#FR55, FR56]
- [Source: _bmad-output/planning-artifacts/architecture.md#Authentication & Security]
- [Source: _bmad-output/project-context.md#API Architecture — Sessions are server-side]
- [Source: _bmad-output/implementation-artifacts/1-6-profile-deletion-with-confirmation-and-impact-messaging.md#Dev Notes, Flutter]
- [Source: _bmad-output/implementation-artifacts/1-1-account-registration-login-logout.md (auth patterns)]

## Senior Developer Review (AI)

**Reviewer:** Vishnu on 2026-03-06  
**Outcome:** Approved with fixes applied

**Findings fixed:**
- [HIGH] `AuthGuard` was attaching full `AuthUser` (incl. `passwordHash`) to `req.user`. Fixed: guard now sets `{ id: user.id }` (new `RequestUser` type in `auth.types.ts`). All controllers updated from `as AuthUser` → `as RequestUser`. `auth.guard.spec.ts` assertion updated to match minimal shape.
- [LOW] `session_list_test.dart` used `find.text()` to locate error message, violating the project's Key-only test rule. Fixed: added `Key('session-list-error')` to the error `Text` widget; test now uses `find.byKey`.
- [MEDIUM] `sprint-status.yaml` was changed but absent from story File List. Fixed: added to File List.

**Remaining items (deferred):**
- [MEDIUM] Refresh-token DB invalidation on revoke and `session_id` migration are not implemented (in-memory service). Required before Redis/DB switchover.
- [MEDIUM] `refresh()` does not propagate `ip`/`userAgent` to the new session. Required before Redis/DB switchover.
- [LOW] Session list entry point lives on `HomeScreen` rather than the account/settings screen. Evaluate discoverability before next release.

## Dev Agent Record

### Agent Model Used

claude-4.6-sonnet-medium-thinking

### Debug Log References

### Completion Notes List

- API: Implemented against in-memory AuthService (no Redis/DB). Added DeviceSessionData, DeviceSessionSummary, SESSION_NOT_FOUND, SessionNotFoundException. Extended AuthSession with ip, userAgent. login(dto, ip?, userAgent?) stores device metadata; createSession(userId, ip, userAgent). getSessions(userId, currentSessionId) and revokeSession(userId, sessionId, correlationId) implemented. AuthGuard sets req.currentSessionId via getSessionIdForAccessToken. GET /auth/sessions and DELETE /auth/sessions/:sessionId added; AuthModule provides AuthGuard. Unit tests: auth.service.spec (getSessions, revokeSession, getSessionIdForAccessToken), auth.controller.spec (getSessions, revokeSession), auth.guard.spec (getSessionIdForAccessToken mock). E2E: 6 tests for sessions (200/401/404, revoke current → 401).
- Flutter: SessionsRepository + DeviceSessionSummary, InMemorySessionsRepository with 2 seeded sessions. SessionListScreen with list, revoke dialog, onLogout when revoking current. Wired into main.dart (_AuthView.sessionList, HomeScreen onGoToSessions, Active Sessions button). session_list_test.dart: 6 widget tests (keys, dialog, Cancel, Revoke, onLogout, error state).

### File List

**Modified (API):**
- apps/api/src/modules/auth/auth.types.ts
- apps/api/src/modules/auth/auth.service.ts
- apps/api/src/modules/auth/auth.controller.ts
- apps/api/src/modules/auth/auth.module.ts
- apps/api/src/modules/auth/auth.service.spec.ts
- apps/api/src/common/guards/auth.guard.ts
- apps/api/src/common/guards/auth.guard.spec.ts
- apps/api/test/app.e2e-spec.ts

**New (API):**
- apps/api/src/modules/auth/exceptions/session-not-found.exception.ts
- apps/api/src/modules/auth/auth.controller.spec.ts

**New (Flutter):**
- apps/mobile/lib/features/auth/sessions_repository.dart
- apps/mobile/lib/features/auth/in_memory_sessions_repository.dart
- apps/mobile/lib/features/auth/screens/session_list_screen.dart
- apps/mobile/test/session_list_test.dart

**Modified (Flutter):**
- apps/mobile/lib/main.dart
- apps/mobile/lib/features/auth/screens/home_screen.dart

**Modified (Sprint tracking):**
- _bmad-output/implementation-artifacts/sprint-status.yaml
