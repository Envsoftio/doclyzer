# Story 3.8: Enforce Profile Isolation in Shared Output

Status: done

## Story

As an account holder,
I want strict scope isolation enforced on share links,
So that no data from non-shared profiles can ever leak to recipients.

## Acceptance Criteria

1. **Given** a valid share link scoped to Profile A, **When** a recipient calls `GET /v1/sharing/public/:token`, **Then** reports returned belong exclusively to Profile A (verified by both `profileId` AND `userId` in the DB query — double isolation).
2. **Given** a share link with `scope='all'`, **When** data is fetched, **Then** all parsed reports for the scoped profile are returned (existing behavior preserved, now explicit in code).
3. **Given** a share link with any unrecognized `scope` value, **When** data is fetched, **Then** the system falls back to returning all parsed reports for the scoped profile (safe permissive fallback; scope validation is a future story).
4. **Given** reports are returned from `getPublicShareData()`, **When** any returned report's `profileId` does not match `link.profileId`, **Then** a runtime error is thrown before the response is sent (defense-in-depth assertion).

## Tasks / Subtasks

- [x] Task 1: Add `userId` isolation to reports query in `getPublicShareData()` (AC: #1)
  - [x] In `SharingService.getPublicShareData()`, change the `reportRepo.find()` `where` clause from `{ profileId: link.profileId, status: 'parsed' }` to `{ profileId: link.profileId, userId: link.userId, status: 'parsed' }` — double isolation
  - [x] Add inline comment: `// Double isolation: profileId scopes to the shared profile; userId prevents cross-user data access if profileId were ever reused or guessed`

- [x] Task 2: Make scope enforcement explicit (AC: #2, #3)
  - [x] Extract a private helper `buildScopedReportWhere(link: ShareLinkEntity)` that returns the TypeORM `FindOptionsWhere<ReportEntity>` — currently returns `{ profileId: link.profileId, userId: link.userId, status: 'parsed' }` for `scope='all'` (and any unrecognized scope as safe fallback)
  - [x] Call this helper from `getPublicShareData()` instead of inlining the where clause
  - [x] Add comment on helper: `// scope='all' is the only defined value today; extend this switch for future scope types (e.g. date-range, specific-reports)`

- [x] Task 3: Add defense-in-depth assertion post-fetch (AC: #4)
  - [x] After `const reports = await this.reportRepo.find(...)`, add assertion: if any `report.profileId !== link.profileId`, throw an `InternalServerErrorException` with a safe non-PHI message (`'Isolation violation: unexpected report in shared output'`)
  - [x] This assertion should never trigger in normal operation — it is a canary for data access bugs

## Dev Notes

### Existing Code to Modify

**File:** `apps/api/src/modules/sharing/sharing.service.ts`

**Current `getPublicShareData()` (lines 97–146):**
```typescript
// Current — scopes only by profileId
const reports = await this.reportRepo.find({
  where: { profileId: link.profileId, status: 'parsed' },
  order: { createdAt: 'DESC' },
  select: ['id', 'originalFileName', 'status', 'summary', 'createdAt'],
});
```

**Target changes — add private helper + update call site:**
```typescript
private buildScopedReportWhere(link: ShareLinkEntity): FindOptionsWhere<ReportEntity> {
  // Double isolation: profileId (profile boundary) + userId (owner boundary)
  // scope='all' is the only defined value today; extend for future scope types
  const base = { profileId: link.profileId, userId: link.userId, status: 'parsed' as const };
  switch (link.scope) {
    case 'all':
    default:
      return base;
  }
}

async getPublicShareData(token: string): Promise<PublicShareDto> {
  const link = await this.shareLinkRepo.findOne({ where: { token } });
  if (!link) throw new ShareLinkNotFoundException();

  const outcome = this.isLinkValid(link) ? 'accessed' : 'expired_or_revoked';
  await this.accessEventRepo.save(
    this.accessEventRepo.create({ shareLinkId: link.id, outcome }),
  );

  if (!this.isLinkValid(link)) throw new ShareLinkExpiredException();

  const profile = await this.profilesService.getProfile(link.userId, link.profileId);
  const reports = await this.reportRepo.find({
    where: this.buildScopedReportWhere(link),  // <-- use helper
    order: { createdAt: 'DESC' },
    select: ['id', 'originalFileName', 'status', 'summary', 'createdAt', 'profileId'],  // add profileId for assertion
  });

  // Defense-in-depth: assert isolation holds (should never trigger in normal operation)
  for (const r of reports) {
    if (r.profileId !== link.profileId) {
      throw new InternalServerErrorException('Isolation violation: unexpected report in shared output');
    }
  }

  // ... rest of method unchanged (lab values fetch, response mapping)
}
```

**Important:** The `select` array must add `'profileId'` to support the isolation assertion. Without it, `r.profileId` would be `undefined` and the check would always fail.

**Imports to add:**
```typescript
import { InternalServerErrorException } from '@nestjs/common';
import type { FindOptionsWhere } from 'typeorm';
```

### ReportEntity confirms `userId` + `profileId` fields both exist

From `apps/api/src/database/entities/report.entity.ts`:
- `userId` — `@Column({ type: 'uuid', name: 'user_id' })`
- `profileId` — `@Column({ type: 'uuid', name: 'profile_id' })`

Both are available for the double-isolation WHERE clause.

### No Changes to Nuxt Web App

The Nuxt share page (`apps/web/app/pages/share/[token].vue`) renders exactly what the API returns. Since isolation is fully enforced server-side, no Nuxt changes are required for this story. Route-level robots exclusion is deferred to Story 3.10.

### No Database Migrations Needed

This story involves only application-layer changes (service logic). No new entities, columns, or migrations.

### PHI / Security Rules (from architecture)

- **Do NOT log** `link.profileId`, `link.userId`, or report content in error messages — the isolation violation error message must be safe: `'Isolation violation: unexpected report in shared output'`
- **No PHI in logs** — if adding any debug logging, never include profileId, userId, or report content values
- The `buildScopedReportWhere` helper must never be `public` — it's an internal isolation mechanism

### Project Structure Notes

- Only `apps/api/src/modules/sharing/sharing.service.ts` changes
- No new files, modules, or routes
- `FindOptionsWhere` import comes from `typeorm` (already in use in the file via `In`, `IsNull`, `MoreThan`, `Or`)

### Previous Story Intelligence (from 3-7)

- The `accessEventRepo.save()` error is **intentionally not caught** — errors surface as 500 (visible fail, not silent skip). Same pattern applies here.
- The `revokeShareLink()` ownership pattern (`where: { id: linkId, userId }`) is the model for how double-isolation WHERE clauses look — same pattern applied to `reportRepo`.
- The `SharingModule` forFeature already includes `ReportEntity` and `ReportLabValueEntity`.

### References

- `SharingService.getPublicShareData()` [Source: apps/api/src/modules/sharing/sharing.service.ts#L97]
- `ReportEntity` (userId + profileId fields) [Source: apps/api/src/database/entities/report.entity.ts]
- `ShareLinkEntity` (scope, userId, profileId fields) [Source: apps/api/src/database/entities/share-link.entity.ts]
- Architecture: "Authorization model: RBAC + profile-scoped ownership checks on PHI-bearing operations" [Source: _bmad-output/planning-artifacts/architecture.md — Authentication & Security section]
- Architecture: FR46 — "System can enforce profile isolation across all user-facing views and share outputs" [Source: _bmad-output/planning-artifacts/epics.md#FR46]
- TypeORM `FindOptionsWhere` import pattern (already used in service via `In`, `Or`, etc.) [Source: apps/api/src/modules/sharing/sharing.service.ts#L4]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- Implemented double isolation (profileId + userId) in `getPublicShareData()` via `buildScopedReportWhere()` private helper
- Added `FindOptionsWhere` import from typeorm and `InternalServerErrorException` from @nestjs/common
- `buildScopedReportWhere()` uses switch on `link.scope` with `'all'` and `default` both returning the double-isolated base where clause (safe permissive fallback for unrecognized scopes per AC#3)
- Added `'profileId'` to the `select` array so the post-fetch assertion has the value to check
- Defense-in-depth assertion throws `InternalServerErrorException` with PHI-safe message if any returned report's profileId doesn't match the link's profileId
- Pre-existing TypeScript errors in test files are unrelated to this story; no errors in sharing module

### File List

- apps/api/src/modules/sharing/sharing.service.ts

### Change Log

- 2026-03-23: Implemented profile isolation enforcement — double WHERE isolation (profileId + userId), `buildScopedReportWhere()` helper with scope switch, defense-in-depth post-fetch assertion
