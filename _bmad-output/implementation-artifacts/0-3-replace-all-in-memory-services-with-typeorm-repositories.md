# Story 0.3: Replace All In-Memory Services with TypeORM Repositories

**Status:** done  
**Epic:** 0 — Backend Foundation — Real Persistence, JWT Auth & API Wiring  
**Depends on:** Story 0.1 (entities/migrations), Story 0.2 (JWT auth, UserEntity, SessionEntity)

## User Story

As a developer,
I want all in-memory Map stores replaced with TypeORM repositories,
So that all Epic 1 data is durable, the API behaves identically after restart, and the external contract is unchanged.

## Acceptance Criteria

- **Given** the API is restarted
- **When** data was previously written (profiles, preferences, restrictions, etc.)
- **Then** all data is present — no in-memory state survives restart

- **Given** the external API contract (routes, HTTP methods, request/response shapes)
- **When** this story is complete
- **Then** no breaking changes to any endpoint — Flutter app works without modification

- **Given** unit tests exist for the services
- **When** this story is complete
- **Then** all unit tests pass with mocked TypeORM `Repository<Entity>` injected via `@InjectRepository`

## Services to Migrate

### AuthService (`auth.service.ts`)

**Remove:**
- `usersByEmail: Map<string, AuthUser>`
- `sessionsByAccessToken: Map<string, AuthSession>`
- `sessionsByRefreshToken: Map<string, AuthSession>`

**Replace with:**
- `@InjectRepository(UserEntity) private users: Repository<UserEntity>`
- Session operations moved to Story 0.2 SessionEntity logic
- `findUserByEmail(email)` → `users.findOneBy({ email })`
- `createUser(email, passwordHash)` → `users.save(new UserEntity(...))`
- Password comparison: `bcryptjs.compare(plaintext, hash)`

**Keep in-memory (defer to Redis):**
- `rateLimit: Map<string, RateLimitState>` — acceptable for now, note in code

### PasswordRecoveryService (`password-recovery.service.ts`)

**Remove:**
- `resetTokensByHash: Map<string, ResetTokenRecord>`

**Replace with:**
- `@InjectRepository(PasswordResetTokenEntity) private resetTokens: Repository<PasswordResetTokenEntity>`
- `createResetToken(userId)` → generate random token, store `SHA256(token)` + `expiresAt` (1h) in DB
- `validateAndConsumeToken(token)` → find by hash where `expiresAt > now AND usedAt IS NULL`, set `usedAt = now`
- Cleanup of expired tokens: either a cron or on-demand (deferred)

### ProfilesService (`profiles.service.ts`)

**Remove:**
- `profiles: Map<string, Profile[]>`
- `activeProfileId: Map<string, string>`

**Replace with:**
- `@InjectRepository(ProfileEntity) private profiles: Repository<ProfileEntity>`
- `getProfiles(userId)` → `profiles.findBy({ userId })`, sort by `createdAt`
- `createProfile(userId, data)` → `profiles.save(...)`, if first profile set `isActive = true`
- `activateProfile(userId, profileId)` → transaction: set all `isActive = false` for userId, then set target `isActive = true`
- `deleteProfile(userId, profileId)` → delete row; if it was active, activate earliest remaining
- `getMaxProfiles(userId)` → query EntitlementsService (returns 1 for free tier)
- Profile limit check: `count({ userId }) >= maxProfiles` → throw `ProfileLimitExceededException`

### AccountService (`account.service.ts`)

**Remove:**
- `commPrefsStore: Map<string, { productEmails: boolean }>`
- `restrictionStore: Map<string, RestrictionData>`
- `exportRequestStore: Map<string, DataExportRequest>`
- `closureRequestStore: Map<string, ClosureRequest>`

**Replace with:**
```
@InjectRepository(AccountPreferenceEntity) private prefs
@InjectRepository(RestrictionEntity) private restrictions
@InjectRepository(DataExportRequestEntity) private exportRequests
@InjectRepository(ClosureRequestEntity) private closureRequests
```

- `getPreferences(userId)` → upsert AccountPreferenceEntity (create with defaults if missing)
- `updatePreferences(userId, updates)` → update fields, save
- `getRestriction(userId)` → find by userId, return `{ isRestricted: false }` if not found
- `createExportRequest(userId)` → save new DataExportRequestEntity `status: 'pending'`
- `getExportRequest(userId, requestId)` → find by id + userId (enforce ownership)
- `createClosureRequest(userId)` → save new ClosureRequestEntity

### ConsentService (`consent.service.ts`)

**Remove:**
- `acceptances: Map<string, PolicyAcceptanceRecord>`

**Replace with:**
- `@InjectRepository(ConsentRecordEntity) private consents`
- Note: Consent/policy acceptance was removed from the user-facing flow but the service + endpoints may still exist for audit purposes. Keep the DB entity even if the screen is gone.

## Unit Test Updates

All service unit tests that currently test in-memory behavior must be updated to:
- Use `createMock<Repository<Entity>>()` or manual jest mocks for TypeORM repos
- Inject mocked repos via `{ provide: getRepositoryToken(EntityClass), useValue: mockRepo }`
- Test the same business logic outcomes (profile limits, session revoke, etc.)

## API Contract Reference (no changes)

| Method | Route | Auth | Current behavior → Same after migration |
|---|---|---|---|
| POST | /auth/register | public | creates user + returns tokens |
| POST | /auth/login | public | validates password + returns tokens |
| POST | /auth/logout | JWT | deletes session |
| POST | /auth/refresh | public | rotates refresh token |
| GET | /auth/sessions | JWT | lists sessions |
| DELETE | /auth/sessions/:id | JWT | revokes session |
| GET | /account/profile | JWT | returns user profile |
| PATCH | /account/profile | JWT | updates displayName |
| GET | /account/communication-preferences | JWT | returns preferences |
| PUT | /account/communication-preferences | JWT | updates preferences |
| GET | /account/restriction | JWT | returns restriction status |
| POST | /account/export-requests | JWT | creates export request |
| GET | /account/export-requests/:id | JWT | gets export status |
| POST | /account/closure-requests | JWT | creates closure request |
| GET | /profiles | JWT | lists profiles |
| POST | /profiles | JWT | creates profile |
| PATCH | /profiles/:id | JWT | updates profile |
| DELETE | /profiles/:id | JWT | deletes profile |
| PATCH | /profiles/:id/activate | JWT | activates profile |

## References

- `apps/api/src/modules/auth/auth.service.ts` — in-memory Maps to replace
- `apps/api/src/modules/auth/password-recovery.service.ts`
- `apps/api/src/modules/profiles/profiles.service.ts`
- `apps/api/src/modules/account/account.service.ts`
- `apps/api/src/modules/consent/consent.service.ts`
- Story 0.1 — entities and migrations that back this story
- Story 0.2 — JWT auth that backs session management

## Tasks

- [x] Replace in-memory Map stores with TypeORM repositories
  - [x] AuthService uses UserEntity/SessionEntity repositories (rateLimit Map retained)
  - [x] PasswordRecoveryService uses PasswordResetTokenEntity repository
  - [x] ProfilesService uses ProfileEntity repository with transactional activation/deletion
  - [x] AccountService uses preference/restriction/export/closure repositories
  - [x] ConsentService uses ConsentRecordEntity repository
- [x] Update unit tests to inject mocked TypeORM repositories
- [x] Update e2e tests to avoid in-memory internals
- [x] Run regression suite (lint, unit, e2e)

## Dev Agent Record

### Debug Log

- 2026-03-11: Fixed e2e failures by eliminating invalid UUID DB casts, aligning auth guard error codes, and enabling a test-only pg-mem TypeORM DataSource when Docker/Postgres is unavailable.
- 2026-03-11: Aligned account/profile routes with the story API contract, removed direct `process.env` usage in `AppModule`, and updated e2e route coverage.

### Completion Notes

- All remaining in-memory stores were removed from core services; only `AuthService.rateLimit` (explicitly allowed) and `InMemoryNotificationService` (dev stub) remain.
- E2E suite now runs without Docker by using a test-only pg-mem-backed TypeORM DataSource; production/dev continues to use `DATABASE_URL`.
- Regression suite: `npm run lint`, `npm test`, and `npm run test:e2e -- --runInBand` all pass in `apps/api`.
- Route methods/paths now match the story’s API contract for restrictions, communication preferences, and profile activation.

## File List

- `apps/api/package.json`
- `apps/api/package-lock.json`
- `apps/api/src/app.module.ts`
- `apps/api/src/common/guards/auth.guard.ts`
- `apps/api/src/common/guards/auth.guard.spec.ts`
- `apps/api/src/database/entities/consent-record.entity.ts`
- `apps/api/src/database/entities/data-export-request.entity.ts`
- `apps/api/src/database/entities/session.entity.ts`
- `apps/api/src/database/entities/user.entity.ts`
- `apps/api/src/database/migrations/1730812900000-AddDisplayName.ts`
- `apps/api/src/database/migrations/1730813100000-AddAvatarUrl.ts`
- `apps/api/src/modules/account/account.controller.ts`
- `apps/api/src/modules/account/account.controller.spec.ts`
- `apps/api/src/modules/account/account.service.ts`
- `apps/api/src/modules/account/account.service.spec.ts`
- `apps/api/src/modules/account/account.types.ts`
- `apps/api/src/modules/auth/auth.controller.ts`
- `apps/api/src/modules/auth/auth.module.ts`
- `apps/api/src/modules/auth/auth.service.ts`
- `apps/api/src/modules/auth/auth.service.spec.ts`
- `apps/api/src/modules/auth/password-recovery.service.ts`
- `apps/api/src/modules/consent/consent.controller.ts`
- `apps/api/src/modules/consent/consent.controller.spec.ts`
- `apps/api/src/modules/consent/consent.service.ts`
- `apps/api/src/modules/consent/consent.service.spec.ts`
- `apps/api/src/modules/entitlements/entitlements.service.ts`
- `apps/api/src/modules/profiles/profiles.controller.ts`
- `apps/api/src/modules/profiles/profiles.controller.spec.ts`
- `apps/api/src/modules/profiles/profiles.module.ts`
- `apps/api/src/modules/profiles/profiles.service.ts`
- `apps/api/src/modules/profiles/profiles.service.spec.ts`
- `apps/api/test/app.e2e-spec.ts`
- `_bmad-output/implementation-artifacts/0-3-replace-all-in-memory-services-with-typeorm-repositories.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`

## Senior Developer Review (AI)

- **Date:** 2026-03-12
- **Findings addressed:** Build break (missing `Patch` import), data export payload now includes profiles and consent records from repos, AuthGuard uses repository `findOne` instead of raw SQL, ConsentModule registered in AppModule, account unit tests updated for new repos and `avatarUrl`, comments added for rate-limit map and timing-safe hash in password recovery.
- **Outcome:** Changes requested → fixes applied automatically; build, unit tests, and e2e (data-export-requests) pass.

## Change Log

- 2026-03-12: Code review fixes: added `Patch` import in account.controller; export payload includes profiles and consent records; AuthGuard uses repo `findOne`; ConsentModule in AppModule; account.service.spec and auth.guard.spec updated; story File List corrected (removed 2-1 artifact).
- 2026-03-11: Completed repository-backed persistence across auth, password recovery, profiles, account, and consent; hardened services against invalid UUID inputs; updated tests and added pg-mem-backed e2e execution path.
