# Story 0.5: Backblaze B2 Object Storage for Reports, Profile Pictures, and File Uploads

**Status:** done  
**Epic:** 0 — Backend Foundation — Real Persistence, JWT Auth & API Wiring  
**Depends on:** Story 0.1, 0.2, 0.3 (DB and auth in place; 0.4 optional for E2E)

## Story

As a developer,
I want all user-uploaded files (report PDFs, profile/account avatars, and other assets) stored in Backblaze B2 via an S3-compatible API,
So that storage is durable, scalable, and not tied to local disk, and access is controlled via signed URLs or application-served streams.

## Acceptance Criteria

1. **Given** the API is configured with valid B2 credentials (key ID, application key, bucket name, endpoint)  
   **When** a user uploads a report PDF or profile avatar  
   **Then** the file is uploaded to the configured B2 bucket with a deterministic key structure (e.g. `reports/{userId}/{profileId}/{reportId}.pdf`, `avatars/{userId}.{ext}`)  
   **And** the database record stores the B2 key (or URL path) for later retrieval  
   **And** no file is stored on local disk in production (local disk allowed only for dev/test when B2 is disabled or mocked).

2. **Given** a client requests to read an uploaded file (e.g. view PDF, avatar image)  
   **When** the user is authorized to access that resource  
   **Then** the API serves the file via a short-lived signed URL from B2 or streams it through the API  
   **And** bucket and keys are not publicly listable or directly accessible without authorization.

3. **Given** a user deletes a report or account closure removes data  
   **When** the delete is committed  
   **Then** the corresponding object(s) in B2 are deleted (or scheduled for deletion) so that storage is not left with orphans.

4. **Given** B2 is unavailable or misconfigured  
   **When** an upload is attempted  
   **Then** the API returns a clear error and does not leave the DB in an inconsistent state (no report/avatar record without a stored file).

## Tasks / Subtasks

- [x] **Task 1: Introduce file-storage abstraction and B2 client** (AC: 1, 4)
  - [x] 1.1 Add `@aws-sdk/client-s3` (or equivalent S3-compatible client) and config validation for B2 env vars
  - [x] 1.2 Create `FileStorageService` (or `ObjectStorageService`) interface + B2 implementation in `apps/api/src/common/storage/` (or `apps/api/src/modules/shared/storage/`)
  - [x] 1.3 Register config: `B2_KEY_ID`, `B2_APPLICATION_KEY`, `B2_BUCKET_NAME`, `B2_ENDPOINT` (e.g. `https://s3.us-west-002.backblazeb2.com`), optional `B2_DISABLED` for local dev
  - [x] 1.4 Implement: `upload(key, streamOrBuffer, contentType?)`, `delete(key)`, `getSignedUrl(key, expiresInSeconds)` (and/or `getReadStream(key)` for streaming)
  - [x] 1.5 Key naming: `reports/{userId}/{profileId}/{reportId}.pdf`, `avatars/{userId}.{ext}`; document in code and project-context

- [x] **Task 2: Wire avatar upload to B2** (AC: 1, 2, 4)
  - [x] 2.1 Replace multer `diskStorage` in `AccountController` with memory storage (multer.memoryStorage()) so file is in buffer
  - [x] 2.2 After multer, call `FileStorageService.upload('avatars/' + userId + ext, file.buffer, file.mimetype)`; store returned key (or stable path) in DB
  - [x] 2.3 User/Profile entity: store `avatarStorageKey` or `avatarUrl` (path/key) instead of local path; ensure existing migration or new migration for new column if needed
  - [x] 2.4 Avatar read: endpoint returns signed URL from B2 or streams; remove reliance on static `/uploads/avatars/` serving

- [x] **Task 3: Report upload flow (placeholder for Epic 2)** (AC: 1, 2, 3)
  - [x] 3.1 If report upload exists in this codebase: same pattern — upload to B2 key `reports/{userId}/{profileId}/{reportId}.pdf`, save key in report record
  - [x] 3.2 If report upload is not yet implemented: ensure `FileStorageService` is used from report module when implemented; document key layout in project-context

- [x] **Task 4: Delete and lifecycle** (AC: 3)
  - [x] 4.1 On avatar update/remove: delete old B2 object by key when overwriting or clearing avatar
  - [x] 4.2 On report delete (or account closure): delete corresponding B2 object(s); hook into existing account/report services

- [x] **Task 5: Error handling and configuration** (AC: 4)
  - [x] 5.1 If B2 credentials missing or `B2_DISABLED=true`: use in-memory or local-disk stub in dev so tests and local run still work; log warning
  - [x] 5.2 On B2 upload/delete failure: throw descriptive exception (e.g. `FileStorageException`), do not create/update DB record for the file so state stays consistent
  - [x] 5.3 Add `.env.example` entries for all B2_* vars

- [x] **Task 6: Tests** (AC: 1–4)
  - [x] 6.1 Unit tests: `FileStorageService` with mocked S3 client (or in-memory stub)
  - [x] 6.2 Integration/E2E: optional test against real B2 bucket in CI if credentials provided; otherwise test with stub that asserts key layout and delete calls

## Dev Notes

- **Current state:** `AccountController` uses `diskStorage` to write avatars under `uploads/avatars/` and stores path in user/profile; replace with B2 key storage and signed URL or stream for reads.
- **PRD:** Object Storage (Backblaze B2) section in `_bmad-output/planning-artifacts/prd.md` — private buckets, key structure, env-based config, no credentials in code.
- **Architecture:** Follow existing NestJS module pattern; config via `ConfigService`; no `process.env` in application code except data-source. Use standard response envelope and error codes for storage failures.

### Project Structure Notes

- New module or shared folder: `apps/api/src/common/storage/` (or under a dedicated `storage` module). Suggested files:
  - `file-storage.interface.ts` — interface (upload, delete, getSignedUrl / getStream)
  - `b2-file-storage.service.ts` — B2 implementation using S3 client
  - `file-storage.module.ts` — register provider (B2 or stub by env)
- Account module: inject `FileStorageService`, use in avatar upload/update/delete and in any endpoint that serves avatar URL.
- Key naming must be consistent so account closure / data export can list and delete by prefix if needed.

### References

- [Source: _bmad-output/planning-artifacts/prd.md — Object Storage (Backblaze B2)]
- [Source: _bmad-output/planning-artifacts/epics.md — Story 0.5]
- Backblaze B2 S3-compatible API: https://www.backblaze.com/b2/docs/s3_compatible_api.html
- AWS SDK v3 S3 client works with B2 endpoint: use `endpoint` and path-style or virtual-hosted style as per B2 docs.

## Developer Context (Implementation Guardrails)

### Technical requirements

- Use `@aws-sdk/client-s3` with custom `endpoint` and `forcePathStyle` (or per B2 docs). Credentials: `accessKeyId` = B2 key ID, `secretAccessKey` = B2 application key.
- All config from `ConfigService`; validate presence of B2_* in production; allow stub when `B2_DISABLED=true` or vars missing for local dev.
- Do not log or expose B2 keys; do not put keys in error messages.

### Architecture compliance

- Domain separation: file storage is a shared capability; no PHI in object keys beyond userId/profileId/reportId (IDs only).
- Standard API error envelope and correlation ID on storage failures.
- Follow existing NestJS patterns: injectable service, module export only what’s needed.

### Library / framework

- `@aws-sdk/client-s3`: `PutObjectCommand`, `DeleteObjectCommand`, `GetObjectCommand`; for signed URL use `@aws-sdk/s3-request-presigner` or equivalent.
- Multer: switch to `memoryStorage()` for avatar so buffer can be sent to B2; keep file size and type validation.

### File structure

- `apps/api/src/common/storage/` (or `modules/shared/storage/`): interface, B2 service, module.
- `apps/api/src/modules/account/account.controller.ts`: replace diskStorage with memoryStorage + `FileStorageService.upload`.
- `apps/api/src/modules/account/account.service.ts`: persist and return storage key; on delete/overwrite call `FileStorageService.delete`.
- User or Profile entity: column for avatar storage key (e.g. `avatarStorageKey`); migration if adding new column.

### Testing

- Unit: mock S3 client; assert correct key format and that upload/delete are called with expected args.
- E2E: either stub storage (no real B2) or optional CI job with test bucket; ensure no DB record is created when upload fails.

## Previous Story Intelligence (Story 0.4)

- E2E uses real Postgres and `clearDatabase`; any new tables (e.g. file metadata) should be truncated in E2E cleanup.
- Config and env are validated via `ConfigService`; follow same pattern for B2 env vars.
- No PHI in logs; do not log file contents or object keys that could contain PII beyond IDs.

## Project Context Reference

- **project-context.md:** Config via `ConfigService` only; no `process.env` in modules; exception subclasses with `code`; standard response envelope; AuthGuard on protected routes.
- **Entity convention:** shared entities in `src/database/entities/`; ensure User/Profile (or Account) has avatar key field and migration.

## Dev Agent Record

### Agent Model Used

Composer (Cursor)

### Completion Notes List

- Added `@aws-sdk/client-s3` and `@aws-sdk/s3-request-presigner`; storage config via `registerAs('storage', ...)`.
- Created `FileStorageService` interface, `B2FileStorageService`, `InMemoryFileStorageService` (stub when B2_DISABLED or vars missing).
- StorageModule provides FILE_STORAGE token; AccountModule imports StorageModule.
- Replaced multer diskStorage with memoryStorage; avatar upload → FileStorageService.upload → store key in user.avatarUrl.
- getProfile resolves avatar key to signed URL (5 min TTL); B2 returns presigned URL, stub returns data URL.
- Avatar overwrite/clear: delete old key before save; account closure deletes avatar and clears user.avatarUrl.
- Removed static asset serving for /uploads from main.ts.
- Documented key layout in project-context.md. Unit tests for InMemoryFileStorageService and AccountService/Controller with mocked storage.
- Code review fixes: B2 error logging, production warning when B2 disabled, E2E avatar tests, createClosureRequest avatar-deletion unit test.

### File List

- apps/api/package.json — added @aws-sdk/client-s3, @aws-sdk/s3-request-presigner
- apps/api/src/config/storage.config.ts
- apps/api/src/database/entities/user.entity.ts — avatarUrl column
- apps/api/src/database/migrations/1730813100000-AddAvatarUrl.ts
- apps/api/src/common/storage/file-storage.interface.ts
- apps/api/src/common/storage/file-storage.types.ts
- apps/api/src/common/storage/in-memory-file-storage.service.ts
- apps/api/src/common/storage/in-memory-file-storage.service.spec.ts
- apps/api/src/common/storage/b2-file-storage.service.ts
- apps/api/src/common/storage/b2-file-storage.service.spec.ts
- apps/api/src/common/storage/storage.module.ts
- apps/api/src/app.module.ts — load storageConfig
- apps/api/src/main.ts — removed uploads dir and static assets
- apps/api/src/modules/account/account.module.ts — import StorageModule
- apps/api/src/modules/account/account.controller.ts — memoryStorage, FileStorageService.upload
- apps/api/src/modules/account/account.service.ts — getProfile signed URL, updateAvatar/updateProfile delete old key, closure deletes avatar
- apps/api/src/modules/account/account.service.spec.ts — fileStorage mock
- apps/api/src/modules/account/account.controller.spec.ts — fileStorage mock
- .env.example — B2_* vars
- _bmad-output/project-context.md — object storage key layout
- apps/api/test/app.e2e-spec.ts — avatar upload, getProfile avatarUrl, clear avatar, closure with avatar E2E tests

## Change Log

- 2026-03-13: Implemented Story 0.5 — B2 storage abstraction, avatar upload/read/clear, account closure avatar deletion. Status → review.
- 2026-03-13: Code review fixes — B2 error logging, production warning, E2E avatar tests, createClosureRequest unit test, File List updated. Status → done.

## Senior Developer Review (AI)

- 2026-03-13: Adversarial code review completed. Fixed 2 HIGH + 4 MEDIUM issues: File List completed (migration, entity, b2 spec), E2E avatar flow tests added, createClosureRequest avatar-deletion unit test, B2 error logging, production warning when B2 disabled. Approved.
