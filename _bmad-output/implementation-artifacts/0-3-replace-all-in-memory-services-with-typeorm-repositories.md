# Story 0.3: Replace All In-Memory Services with TypeORM Repositories

**Status:** backlog  
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
