# Story 3.5: Recipient Access via Valid Link (No Account)

Status: review

## Story

As a recipient,
I want no-login access to valid links,
so that shared context is easy to consume.

## Acceptance Criteria

1. **Given** a valid, active, non-expired share token in the URL, **When** recipient opens `/share/:token`, **Then** a page loads showing profile name and a list of parsed reports (no login required).
2. **Given** a token that does not exist in the DB, **When** recipient opens `/share/:token`, **Then** a 404 "Link not found" page is shown.
3. **Given** a token for a link that has been revoked (`isActive=false`) or is past its `expiresAt`, **When** recipient opens `/share/:token`, **Then** a 410 "Link expired or revoked" page is shown.
4. **Given** a valid link, **When** the public API endpoint `GET /v1/sharing/public/:token` is called, **Then** it returns `profileName`, `scope`, and an array of reports with `id`, `originalFileName`, `status`, `summary`, `createdAt` — no authentication header required.
5. **Given** a valid link, **When** the API responds, **Then** only reports with status `parsed` are included (non-PHI-safe statuses excluded from recipient view).
6. **Given** the share page, **When** rendered by a search crawler, **Then** the page carries `<meta name="robots" content="noindex, nofollow">` — share routes are non-indexable by design.

## Tasks / Subtasks

- [x] Task 1: Add public API endpoint to SharingService (AC: #4, #5)
  - [x] Add `PublicShareDto` and `PublicReportDto` interfaces to `sharing.service.ts`
  - [x] Add `getPublicShareData(token: string)` method to `SharingService` — looks up link by token (not by userId), calls `isLinkValid()`, loads profile via `profilesService.getProfile(link.userId, link.profileId)`, queries reports for profileId with status `parsed`, returns dto
  - [x] Add `SHARE_LINK_EXPIRED_OR_REVOKED` error code to `sharing.types.ts`
  - [x] Inject `ReportEntity` repository into `SharingService` (add to `TypeOrmModule.forFeature` in `sharing.module.ts`)

- [x] Task 2: Create public controller with no auth guard (AC: #2, #3, #4)
  - [x] Create `apps/api/src/modules/sharing/public-sharing.controller.ts` with `@Controller('sharing/public')` — **NO** `@UseGuards(AuthGuard)` — separate from `SharingController`
  - [x] Implement `@Get(':token')` handler: calls `sharingService.getPublicShareData(token)`, wraps in `successResponse()`
  - [x] Return 404 via `ShareLinkNotFoundException` when token not found; return 410 via new `ShareLinkExpiredException` when link is invalid
  - [x] Register `PublicSharingController` in `SharingModule`

- [x] Task 3: Create `ShareLinkExpiredException` (AC: #3)
  - [x] Create `apps/api/src/modules/sharing/exceptions/share-link-expired.exception.ts` — extends `HttpException` with status 410 and code `SHARE_LINK_EXPIRED_OR_REVOKED`

- [x] Task 4: Scaffold Nuxt web app (AC: #1, #6)
  - [x] Bootstrap `apps/web` with `npx nuxi@latest init web` (Nuxt 3)
  - [x] Create `apps/web/nuxt.config.ts` with: `runtimeConfig.public.apiBaseUrl` pointing to `NUXT_PUBLIC_API_BASE_URL` env var (default `http://localhost:3000/v1`)
  - [x] Add `.env.example` in `apps/web` with `NUXT_PUBLIC_API_BASE_URL=http://localhost:3000/v1`

- [x] Task 5: Create share page `pages/share/[token].vue` (AC: #1, #2, #3, #6)
  - [x] Fetch from `GET /v1/sharing/public/:token` in `onMounted` or `useAsyncData`
  - [x] States: loading spinner → success (profile name + report list) | 404 (link not found) | 410 (link expired/revoked) | generic error
  - [x] Add `<meta name="robots" content="noindex, nofollow">` via `useHead()` in the page component
  - [x] Display: profile name as heading, list of reports showing `originalFileName` + `createdAt` date + `summary` (if present, show truncated)

## Dev Notes

### Critical: No Auth on Public Endpoint

`SharingController` has `@UseGuards(AuthGuard)` at **class level**. The public endpoint MUST be a **separate controller** (`PublicSharingController`) with no guard — do NOT add `@Get(':token')` to `SharingController` and attempt to skip the guard. Mixing public/private on the same controller is error-prone.

```typescript
// apps/api/src/modules/sharing/public-sharing.controller.ts
@Controller('sharing/public')   // No UseGuards at all
export class PublicSharingController { ... }
```

### Token Lookup Pattern

Existing service methods look up links by `{ id, userId }` (ownership check). For the public endpoint, look up by token alone:

```typescript
const link = await this.shareLinkRepo.findOne({ where: { token } });
if (!link) throw new ShareLinkNotFoundException();
if (!this.isLinkValid(link)) throw new ShareLinkExpiredException();
```

`isLinkValid()` already handles both `isActive=false` and `expiresAt <= now`.

### Profile Data Access Pattern

`ProfilesService.getProfile(userId, profileId)` requires both args and throws `ProfileNotFoundException` if not owned. For the public endpoint, use the **link's own `userId`** as the owner arg — the link was created by the profile owner, so their userId is correct:

```typescript
const profile = await this.profilesService.getProfile(link.userId, link.profileId);
```

This avoids needing to bypass the ownership check.

### Report Filtering

Only return reports with `status = 'parsed'` in the public view. Reports with `uploading`, `queued`, `parsing`, `unparsed`, `content_not_recognized`, `failed_*` statuses are internal states not meaningful to a recipient. The `summary` field will be `null` for many; display it only when non-null.

```typescript
const reports = await this.reportRepo.find({
  where: { profileId: link.profileId, status: 'parsed' },
  order: { createdAt: 'DESC' },
  select: ['id', 'originalFileName', 'status', 'summary', 'createdAt'],
});
```

### 410 vs 404 Error Code

- Token not found in DB → `ShareLinkNotFoundException` (404, `SHARE_LINK_NOT_FOUND`) — same exception used in 3.2
- Token found but invalid (revoked/expired) → new `ShareLinkExpiredException` (410 Gone, `SHARE_LINK_EXPIRED_OR_REVOKED`)

```typescript
// share-link-expired.exception.ts
import { HttpException, HttpStatus } from '@nestjs/common';
export class ShareLinkExpiredException extends HttpException {
  constructor() {
    super({ code: 'SHARE_LINK_EXPIRED_OR_REVOKED', message: 'This share link has expired or been revoked' }, HttpStatus.GONE);
  }
}
```

### SharingModule Changes

Add `ReportEntity` to `TypeOrmModule.forFeature` and register `PublicSharingController`:

```typescript
@Module({
  imports: [
    TypeOrmModule.forFeature([ShareLinkEntity, UserSharePolicyEntity, ReportEntity]),
    AuthModule,
    ProfilesModule,
  ],
  controllers: [SharingController, PublicSharingController],
  providers: [SharingService],
})
```

Import path for ReportEntity: `../../database/entities/report.entity`.

### PublicShareDto Shape

```typescript
export interface PublicReportDto {
  id: string;
  originalFileName: string;
  status: string;
  summary: string | null;
  createdAt: string; // ISO string
}

export interface PublicShareDto {
  profileName: string;
  scope: string;
  reports: PublicReportDto[];
}
```

### NestJS API Route Precedence

Global prefix is `v1/` (set in `main.ts`). Final route: `GET /v1/sharing/public/:token`. Verify no collision with authenticated routes — `SharingController` path is `sharing`, `PublicSharingController` is `sharing/public`. No conflict.

### PHI Safety

- Do NOT log token values in any log statement
- Do NOT include `userId` or `profileId` from the link in the API response (not needed by recipient)
- `originalFileName` is user-uploaded but not inherently PHI — safe to expose
- `summary` is AI-generated health summary — include it (that's the point of sharing), but do not include raw `parsedTranscript`

### Nuxt App

Architecture specifies: `apps/web` bootstrapped with `npx nuxi@latest init`. Key config:
- Route: `pages/share/[token].vue` → path `/share/:token` (Nuxt file-based routing)
- `SHARE_BASE_URL` in the NestJS service already points to `http://localhost:3001` (the Nuxt port) — do not change this
- For API calls from Nuxt, use `$fetch` with the `apiBaseUrl` from `runtimeConfig.public`
- Nuxt 3 uses Composition API + `<script setup lang="ts">`

Minimal `nuxt.config.ts`:
```typescript
export default defineNuxtConfig({
  runtimeConfig: {
    public: {
      apiBaseUrl: process.env.NUXT_PUBLIC_API_BASE_URL ?? 'http://localhost:3000/v1',
    },
  },
})
```

Minimal share page pattern:
```vue
<script setup lang="ts">
const { token } = useRoute().params
const config = useRuntimeConfig()
useHead({ meta: [{ name: 'robots', content: 'noindex, nofollow' }] })
// fetch from config.public.apiBaseUrl + '/sharing/public/' + token
</script>
```

### Project Structure Notes

- New files follow existing patterns exactly: kebab-case filenames, same import style as `sharing.service.ts`
- The `apps/web` directory does not exist yet — this is the first web-surface story; scaffold it as part of this story
- `apps/api/src/modules/sharing/exceptions/` directory exists (from story 3.2 — `share-link-not-found.exception.ts`)
- Do not modify `apps/mobile` — this story is API + web only

### References

- `SharingService.isLinkValid()` comment: "Returns true when link can be used by a recipient. Called by story 3.5 public endpoint." [Source: apps/api/src/modules/sharing/sharing.service.ts#L53]
- `SharingController` class-level `@UseGuards(AuthGuard)` [Source: apps/api/src/modules/sharing/sharing.controller.ts#L14]
- `ReportEntity.status` type and `summary` field [Source: apps/api/src/database/entities/report.entity.ts]
- Architecture: share page route `apps/web/pages/share/[token].vue`, non-indexable [Source: _bmad-output/planning-artifacts/architecture.md]
- Architecture: share-access guard middleware `apps/web/server/middleware/share-access-guard.ts` (defer full guard to 3.6)
- `SHARE_BASE_URL` default `http://localhost:3001` in SharingService [Source: apps/api/src/modules/sharing/sharing.service.ts#L37]
- Nuxt init command: `npx nuxi@latest init web` [Source: _bmad-output/planning-artifacts/architecture.md]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- Task 1: Added `PublicReportDto` and `PublicShareDto` interfaces to `sharing.service.ts`. Added `getPublicShareData(token)` method that looks up by token, validates via `isLinkValid()`, fetches profile using link's own userId, and returns only `parsed` reports. Injected `ReportEntity` repository. Added `SHARE_LINK_EXPIRED_OR_REVOKED` constant to `sharing.types.ts`.
- Task 2: Created `public-sharing.controller.ts` with `@Controller('sharing/public')` — no auth guard. `GET :token` handler calls service and wraps in `successResponse()`. 404 from `ShareLinkNotFoundException`, 410 from `ShareLinkExpiredException`. Registered in `SharingModule` alongside `SharingController`.
- Task 3: Created `share-link-expired.exception.ts` extending `HttpException` with HTTP 410 (GONE) and code `SHARE_LINK_EXPIRED_OR_REVOKED`.
- Task 4: Scaffolded `apps/web` using `npx nuxi@latest init web --template minimal`. Updated `nuxt.config.ts` with `runtimeConfig.public.apiBaseUrl`. Created `.env.example`. Note: nuxi init produced Nuxt 4 (`^4.4.2`) with `app/` srcDir convention; pages live at `app/pages/`.
- Task 5: Created `app/pages/share/[token].vue` with `$fetch` in `onMounted`, loading/404/410/error/success states, `useHead` robots noindex meta, and report list showing `originalFileName`, date, and truncated `summary`. Updated `app/app.vue` to use `<NuxtPage />` for file-based routing.

### File List

- apps/api/src/modules/sharing/sharing.types.ts (modified)
- apps/api/src/modules/sharing/sharing.service.ts (modified)
- apps/api/src/modules/sharing/sharing.module.ts (modified)
- apps/api/src/modules/sharing/public-sharing.controller.ts (new)
- apps/api/src/modules/sharing/exceptions/share-link-expired.exception.ts (new)
- apps/web/nuxt.config.ts (modified — scaffolded + runtimeConfig added)
- apps/web/.env.example (new)
- apps/web/app/app.vue (modified — NuxtPage for routing)
- apps/web/app/pages/share/[token].vue (new)
- apps/web/package.json (new — nuxi scaffold)
- apps/web/tsconfig.json (new — nuxi scaffold)
- apps/web/public/robots.txt (new — nuxi scaffold)
- apps/web/public/favicon.ico (new — nuxi scaffold)
- apps/web/.gitignore (new — nuxi scaffold)
- apps/web/README.md (new — nuxi scaffold)

### Change Log

- 2026-03-22: Implemented story 3.5 — public share page + API endpoint. Added `PublicSharingController` (no auth), `ShareLinkExpiredException` (410), `getPublicShareData` service method. Scaffolded `apps/web` Nuxt 4 app with share page at `/share/:token`.
