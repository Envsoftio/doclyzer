# Code Review: Reports Upload & Storage (Report entity, B2, upload flow)

**Scope:** Report entity, migrations, reports module (controller/service), B2/in-memory storage, mobile upload screen & API repository.  
**Review type:** Adversarial — bugs, consistency, security, edge cases.

---

## Findings Summary

| Severity | Count |
|----------|--------|
| HIGH     | 2     |
| MEDIUM   | 3     |
| LOW      | 3     |

---

## HIGH ISSUES

### 1. Storage–DB ordering: orphaned file on save failure

**Location:** `apps/api/src/modules/reports/reports.service.ts` — `uploadReport()`

**Current flow:** `fileStorage.upload(storageKey, buffer)` → then `reportRepo.save(entity)`. If the second step fails (DB timeout, constraint, connection drop), the file is already in B2 and the client gets a 500. The object remains in B2 with no DB row (orphan), and storage cost/leak grows over time.

**Required change (pick one):**

- **Option A (recommended):** Save first with status `queued` (or `uploading`), then upload. On upload failure, update status to `failed_transient` or delete the row. Optionally add a periodic job to delete rows stuck in `uploading` and their B2 objects.
- **Option B:** Keep current order but on `reportRepo.save()` failure catch, call `fileStorage.delete(storageKey)` in a best-effort cleanup, then rethrow. Document that delete failure is only logged (avoid masking the original error).

---

### 2. Invalid UUID in `getReport` can yield 500 instead of 404

**Location:** `apps/api/src/modules/reports/reports.service.ts` — `getReport(userId, reportId)`

**Current code:** `reportRepo.findOne({ where: { id: reportId, userId } })` with no validation of `reportId`. If the client sends a non-UUID (e.g. `"abc"`, `"../../../etc/passwd"`, or a long string), PostgreSQL’s `uuid` type can throw on the query, resulting in an unhandled exception and 500.

**Required change:** Validate `reportId` before querying. Use `isUUID(reportId)` (e.g. from `class-validator`, already used in `ProfilesService`) and throw `ReportNotFoundException` when invalid, so the API consistently returns 404 for “report not found” (including bad id format).

**File:** `apps/api/src/modules/reports/reports.service.ts`

---

## MEDIUM ISSUES

### 3. No rate limiting on POST /reports

**Location:** `apps/api/src/modules/reports/reports.controller.ts`

**Current state:** Upload endpoint has no rate limit. A single client can flood the server with uploads, exhausting storage, DB, or bandwidth.

**Required change:** Apply the same pattern used on auth routes (e.g. `enforceRateLimit` by IP or user id) to `uploadReport`, so POST `/v1/reports` is rate-limited.

---

### 4. `InMemoryFileStorageService.getSignedUrl` ignores second parameter

**Location:** `apps/api/src/common/storage/in-memory-file-storage.service.ts`

**Current code:** `getSignedUrl(key: string): Promise<string>` — second parameter `expiresInSeconds` from `FileStorageService` is not declared, so it’s ignored.

**Impact:** In-memory storage is mainly for tests/dev; behavior is “no expiry” for the data URL. Interface contract is not fully implemented; callers that pass `expiresInSeconds` get no effect.

**Required change:** Add the optional parameter to the method signature and either document that in-memory impl ignores it or simulate expiry (e.g. store a timestamp and return empty after expiry). Prefer at least matching the interface for consistency.

---

### 5. Redundant double save in `uploadReport`

**Location:** `apps/api/src/modules/reports/reports.service.ts` — `uploadReport()`

**Current code:** Create entity with `status: 'queued'`, `save(entity)`, then `entity.status = 'parsed'`, `save(entity)` again (sync parse stub).

**Required change:** For the current MVP stub, a single save is enough: create with `status: 'parsed'` and save once. If you plan to add async parsing soon, keep two saves but consider a single update (e.g. `reportRepo.update(reportId, { status: 'parsed' })`) instead of loading and saving the full entity again.

---

## LOW ISSUES

### 6. Empty or whitespace `originalFileName` stored as-is

**Location:** `apps/api/src/modules/reports/reports.service.ts` — `originalFileName: file.originalname ?? 'report.pdf'`

**Current behavior:** If the client sends `originalname: ""`, the value `""` is stored. DB allows it (varchar NOT NULL). No injection risk from the column, but empty names are poor UX and can complicate listing/display.

**Required change:** Normalize: if `file.originalname` is missing or only whitespace, use `'report.pdf'` (or trim and default to `'report.pdf'` when empty).

---

### 7. Controller does not guard against missing file when multer allows request through

**Location:** `apps/api/src/modules/reports/reports.controller.ts` — `uploadReport()`

**Current code:** `fileFilter` rejects when `!file`. If the client uses a different field name (e.g. `document` instead of `file`), multer may not set `req.file`, and the handler runs with `file` undefined. The code then passes `buffer: file?.buffer ?? Buffer.alloc(0)` and the service throws “File is empty”. So no storage or DB write occurs. Defensive check is in the service; controller could still validate `req.file` and return 400 with a clear message (e.g. “Missing file field”) before calling the service, to align with “fail fast” and clearer API contract.

---

### 8. B2 `delete` throws on failure

**Location:** `apps/api/src/common/storage/b2-file-storage.service.ts` — `delete()`

**Current code:** On S3 delete failure, the service throws `FileStorageException`. If you later add “delete uploaded file on DB save failure” (see HIGH #1), a failed delete would throw and might obscure the original save failure. Acceptable as-is; if you add cleanup, consider logging delete failures and rethrowing the original error so the root cause (DB failure) is not hidden.

---

## Positive Notes

- **Auth:** Reports controller is behind `AuthGuard`; upload and get are both protected.
- **Validation:** Service validates active profile, buffer presence, size, and content type before storage; no upload on invalid input.
- **Tests:** Service tests cover no-active-profile, empty file, oversized file, wrong content type, and storage failure; controller tests verify delegation and envelope. E2E uses `/v1/reports` with auth.
- **Entity/migration:** Report entity and migration align (PK, FKs, indexes, CASCADE). `uuid_generate_v4` is registered in pg-mem for tests.
- **Mobile:** Upload screen uses `ReportsRepository` and shows clear states; API repository maps response to `UploadedReport` and uses `uploadFile` with field name `'file'` matching the API.

---

## Checklist (quick fixes)

- [ ] HIGH: Add storage–DB consistency (save-first or delete-on-save-failure) in `reports.service.ts`.
- [ ] HIGH: Validate `reportId` with `isUUID` in `getReport` and throw `ReportNotFoundException` when invalid.
- [ ] MEDIUM: Rate limit POST `/v1/reports` (e.g. same pattern as auth).
- [ ] MEDIUM: Align `InMemoryFileStorageService.getSignedUrl` with interface (param + doc or no-op expiry).
- [ ] MEDIUM: Single save with `status: 'parsed'` or single update for stub in `uploadReport`.
- [ ] LOW: Normalize empty/whitespace `originalFileName` to `'report.pdf'`.
- [ ] LOW: Optional: controller 400 when `req.file` is missing.
