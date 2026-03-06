# Story 1.9: Data Export and Account Closure Requests

Status: done

## Story

As an authenticated user,
I want export/closure workflows,
So that I can exercise data rights.

## Acceptance Criteria

### Data Export (FR54)

1. **Given** I am authenticated
   **When** I call `POST /account/data-export-requests`
   **Then** a new export request is created with status `pending`
   **And** the response returns `requestId`, `status`, `createdAt` in the envelope
   **And** response uses standard success envelope with `correlationId`

2. **Given** I have created an export request
   **When** I call `GET /account/data-export-requests/:requestId` (own request only)
   **Then** I receive the request status (`pending` | `completed` | `failed`)
   **And** when status is `completed`, the response includes a way to obtain the export (e.g. `downloadUrl` or inline `exportToken` with limited validity)
   **And** when status is `failed`, the response includes a non-PHI `reason` code for support

3. **Given** I call `GET /account/data-export-requests/:requestId` with another user's requestId or invalid id
   **When** the request is processed
   **Then** I receive `404` with `{ success: false, code: "EXPORT_REQUEST_NOT_FOUND", ... }`

4. **Given** export workflow completes (in-memory: on status poll or background; later: async job)
   **When** the export is ready
   **Then** the request status is set to `completed` and the export includes account data (profile, profiles list, consent records, etc.) in a portable format (e.g. JSON)
   **And** a structured audit log entry is emitted (no PHI in logs — correlationId, userId, requestId, status only)

### Account Closure (FR62)

5. **Given** I am authenticated
   **When** I call `POST /account/closure-requests` with a confirmation payload (e.g. `{ "confirmClosure": true }` or password confirmation per policy)
   **Then** a closure request is created and my sessions are invalidated (or scheduled for invalidation)
   **And** the response returns `requestId`, `status` (e.g. `pending` | `completed`), and a short `message` describing access-state changes (e.g. "Your account is scheduled for closure. You will lose access to all data.")
   **And** response uses standard success envelope with `correlationId`

6. **Given** I have requested account closure
   **When** I call `GET /account/closure-request` (singular: one active closure per user)
   **Then** I receive the current closure request status and the same `message` about data-access changes
   **And** if no closure request exists, return `200` with `{ status: null }` or `404` per API design

7. **Given** closure is processed (immediate in-memory or async)
   **When** the account is closed
   **Then** access-state changes follow policy (sessions invalidated, account marked closed; data purge can be deferred to a later story)
   **And** a structured audit log entry is emitted (no PHI — correlationId, userId, requestId, action: CLOSURE_REQUESTED / CLOSURE_COMPLETED)

### Auth and UX

8. **Given** I am not authenticated
   **When** I call any data-export or closure endpoint
   **Then** I receive `401` with `{ success: false, code: "AUTH_UNAUTHORIZED", ... }`

9. **Given** I am on the Flutter app data rights / account screen
   **When** I tap "Export my data"
   **Then** I can trigger an export request and see status (pending → completed or failed)
   **And** when completed, I can download or view the export (e.g. open link or show "Download ready" with key)

10. **Given** I am on the Flutter app and tap "Close my account"
    **When** a confirmation dialog appears
    **Then** it shows impact messaging (data loss, access revocation) and a destructive confirm action
    **And** confirming calls the API and invalidates the session; I am navigated to login
    **And** cancel closes the dialog without submitting

## Tasks / Subtasks

### API — Data Export Types and Service (AC: 1, 2, 3, 4)

- [x] Add types in `account` module (e.g. `account.types.ts` or `data-rights.types.ts`)
  - [x] `DataExportRequest`: `{ requestId: string; userId: string; status: 'pending' | 'completed' | 'failed'; createdAt: string; completedAt?: string; downloadUrl?: string; failureReason?: string }`
  - [x] Error code `EXPORT_REQUEST_NOT_FOUND` and corresponding exception

- [x] Implement export request service (in `AccountService` or dedicated `DataRightsService`)
  - [x] `createDataExportRequest(userId: string, correlationId: string): DataExportRequest` — create with status `pending`, store by requestId and userId; emit audit log; return request
  - [x] `getDataExportRequest(userId: string, requestId: string): DataExportRequest | null` — return only if request belongs to userId; else null (controller returns 404)
  - [x] When `getDataExportRequest` is called for a `pending` request, optionally trigger sync generation (in-memory: build JSON export from user + profiles + consent, set status `completed` and store downloadUrl or inline token); or leave for async job in a later story
  - [x] In-memory store: `Map<requestId, DataExportRequest>`; index by userId for listing if needed

### API — Account Closure Types and Service (AC: 5, 6, 7)

- [x] Add types for closure request
  - [x] `ClosureRequest`: `{ requestId: string; userId: string; status: 'pending' | 'completed'; createdAt: string; message: string }`

- [x] Implement closure request service
  - [x] `createClosureRequest(userId: string, dto: { confirmClosure: boolean }, correlationId: string): ClosureRequest` — validate confirmation; create request; invalidate all user sessions (call auth layer to revoke all tokens for user); set message; emit audit; return request
  - [x] `getClosureRequest(userId: string): ClosureRequest | null` — return current/latest closure request for user
  - [x] In-memory: mark user as closure-requested (e.g. flag on user or separate map); session invalidation = remove all sessions for userId from Redis/in-memory store

### API — Controllers and DTOs (AC: 1–8)

- [x] DTOs: `CreateDataExportRequestDto` (empty or optional); `CreateClosureRequestDto`: `{ @IsBoolean() confirmClosure: boolean }`
- [x] `POST /account/data-export-requests` — create export request, return 201 or 200 with request body
- [x] `GET /account/data-export-requests/:requestId` — return request or 404
- [x] `POST /account/closure-requests` — create closure request, invalidate sessions, return request + message
- [x] `GET /account/closure-request` — return current closure request or 200 with null/empty
- [x] All endpoints `@UseGuards(AuthGuard)`; use `getCorrelationId(req)` and `successResponse`

### API — Tests (AC: 1–8)

- [x] Unit tests: create/get export request; create/get closure request; 404 for wrong userId on export; audit log emitted
- [x] E2E: POST export → GET by requestId → 200 with status; GET with wrong requestId → 404; POST closure with confirm → GET closure-request → 200; unauthenticated → 401 for all

### Flutter — Repositories and Models (AC: 9, 10)

- [x] Data export: model `DataExportRequest`; abstract repo `createExportRequest()`, `getExportRequest(requestId)`; in-memory impl
- [x] Closure: model `ClosureRequest`; abstract repo `createClosureRequest(confirmClosure)`, `getClosureRequest()`; in-memory impl

### Flutter — Screens and Navigation (AC: 9, 10)

- [x] Data rights / account screen or section: "Export my data" button; after create, poll or navigate to status; show "Download" when completed; use Keys for tests
- [x] "Close my account" button → confirmation dialog (impact text + destructive confirm) → on confirm call repo, then logout and navigate to login
- [x] Wire from HomeScreen or account/settings; add `_AuthView.dataRights` or reuse account screen with tabs/sections

### Flutter — Widget Tests (AC: 9, 10)

- [x] Export: trigger creates request; status displayed; download when completed
- [x] Closure: dialog appears with impact text; cancel does not call API; confirm calls API and triggers logout callback
- [x] Key-based finds only

## Dev Notes

### Scope and Policy

- **Export**: Portable format = JSON (profile, profiles, consent acceptances). No report content required in this story if reports are Epic 2; include only what exists in account/consent domain. Async job for large data deferred if needed; in-memory can be sync-on-GET for MVP.
- **Closure**: Sessions invalidated immediately; account marked as closure-requested. Actual data deletion/purge can be a separate story; this story focuses on request creation, status visibility, and session invalidation.
- **Audit**: Logger-based; no PHI. Fields: `action`, `userId`, `requestId`, `correlationId`. Actions: `DATA_EXPORT_REQUESTED`, `DATA_EXPORT_COMPLETED`/`FAILED`, `CLOSURE_REQUESTED`, `CLOSURE_COMPLETED`.

### API Design Notes

- Export: `GET /account/data-export-requests/:requestId` scoped to current user (only own requests). Listing all requests for user optional: `GET /account/data-export-requests` returning array.
- Closure: one active closure per user; `GET /account/closure-request` returns single current request.
- Confirm closure: require `confirmClosure: true` in body to avoid accidental POST; optionally add password re-auth in a later story.

### Consistency

- Reuse `AuthGuard`, `getCorrelationId`, `successResponse`, standard error envelope.
- Flutter: repository pattern, inline errors, Keys for tests; destructive actions use `colorScheme.error` for confirm button.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.9]
- [Source: _bmad-output/planning-artifacts/epics.md#FR54, FR62]
- [Source: _bmad-output/planning-artifacts/architecture.md#API & Communication Patterns, Auditability]
- [Source: _bmad-output/implementation-artifacts/1-6-profile-deletion-with-confirmation-and-impact-messaging.md (confirmation + impact messaging)]
- [Source: _bmad-output/implementation-artifacts/1-7-active-session-device-list-and-revoke.md (session invalidation, audit log)]

## Validation (Post-Creation)

- **Sections**: Story, AC, Tasks, Dev Notes, References, Dev Agent Record — present.
- **AC → Tasks**: Export (AC1–4) → types, service create/get, controller, audit, tests. Closure (AC5–7) → types, service create/get, session invalidation, audit, tests. Auth (AC8) → Guard, E2E. Flutter (AC9–10) → repo, screens, dialog, Keys, tests.
- **Epic/FR**: Aligns with Epic 1 Story 1.9, FR54 (data export), FR62 (account closure), FR41 (data rights).
- **Patterns**: Account module extension; audit no-PHI; Flutter confirmation + impact messaging per 1-6.

## Dev Agent Record

### Agent Model Used

claude-4.6-sonnet-medium-thinking (2026-03-06)

### Debug Log References

None — implementation was straightforward with no blocking issues.

### Completion Notes List

- Implemented `DataExportRequest` and `ClosureRequest` types with typed exception subclasses (`ExportRequestNotFoundException`, `ClosureConfirmationRequiredException`) in `account.types.ts`.
- Added `createDataExportRequest` / `getDataExportRequest` to `AccountService`; sync export generation on first GET populates a base64-encoded JSON `downloadUrl` with account profile data. Audit logs emitted for `DATA_EXPORT_REQUESTED` and `DATA_EXPORT_COMPLETED` (no PHI).
- Added `createClosureRequest` / `getClosureRequest` to `AccountService`; calls `authService.revokeAllSessionsForUser` for immediate session invalidation. Audit log for `CLOSURE_REQUESTED`.
- 4 new endpoints added to `AccountController` (`POST /data-export-requests`, `GET /data-export-requests/:requestId`, `POST /closure-requests`, `GET /closure-request`), all guarded by `AuthGuard`.
- `CreateClosureRequestDto` validates `confirmClosure: boolean` via `@IsBoolean()`.
- 34 unit tests (service + controller) and 10 new e2e tests — all pass (63 total e2e).
- Flutter: `DataRightsRepository` abstract class + `InMemoryDataRightsRepository` with both export and closure methods; combined in one repo since both are data-rights concerns.
- `DataRightsScreen` with export flow (pending → check status → completed + download ready) and closure flow (dialog with impact text, destructive confirm button using `colorScheme.error`, cancel/confirm with Keys).
- `_AuthView.dataRights` added to `main.dart`; "Data Rights" button added to `HomeScreen`; `onAccountClosed` navigates to login.
- 7 Flutter widget tests all pass; 56 total Flutter tests with no regressions.

### File List

**API — Modified:**
- `apps/api/src/modules/account/account.types.ts`
- `apps/api/src/modules/account/account.dto.ts`
- `apps/api/src/modules/account/account.service.ts`
- `apps/api/src/modules/account/account.controller.ts`
- `apps/api/src/modules/account/account.service.spec.ts`
- `apps/api/src/modules/account/account.controller.spec.ts`
- `apps/api/test/app.e2e-spec.ts`

**Flutter — New:**
- `apps/mobile/lib/features/account/data_rights_repository.dart`
- `apps/mobile/lib/features/account/in_memory_data_rights_repository.dart`
- `apps/mobile/lib/features/account/screens/data_rights_screen.dart`
- `apps/mobile/test/data_rights_test.dart`

**Flutter — Modified:**
- `apps/mobile/lib/main.dart`
- `apps/mobile/lib/features/auth/screens/home_screen.dart`

## Senior Developer Review (AI)

**Review Date:** 2026-03-06
**Outcome:** Changes Requested → Fixed

### Action Items (all resolved)

- [x] [High] `getDataExportRequest` set status `completed` even when user not found — profile would be `null` in payload and `status: 'failed'` path was dead code [account.service.ts:getDataExportRequest]
- [x] [High] `CLOSURE_COMPLETED` audit log never emitted despite AC7 requiring it [account.service.ts:createClosureRequest]
- [x] [Med] Flutter `onAccountClosed` did not call `_logout()` — client token not cleared on closure [main.dart:_AuthView.dataRights]
- [x] [Med] No e2e test for `POST /account/closure-requests` with `confirmClosure: false` → 400 [app.e2e-spec.ts]
- [x] [Med] Force-unwrap `!` on `_closureRequest` in production code [in_memory_data_rights_repository.dart:56]
