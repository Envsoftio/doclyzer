# Story 0.4: E2E Test Infrastructure with Real Test Database

**Status:** review  
**Epic:** 0 — Backend Foundation — Real Persistence, JWT Auth & API Wiring  
**Depends on:** Story 0.1, 0.2, 0.3 (all DB-backed services must be in place)

## User Story

As a developer,
I want E2E tests running against a real Postgres test database with automatic cleanup,
So that integration coverage is meaningful and CI doesn't rely on in-memory state.

## Acceptance Criteria

- **Given** `npm run test:e2e` executes
- **When** the test suite runs
- **Then** tests connect to the `doclyzer_test` database (never `doclyzer` dev DB)
- **And** each test suite begins with a clean state (no leftover rows from previous tests)
- **And** all existing E2E test cases from `apps/api/test/app.e2e-spec.ts` pass against the real DB

- **Given** a developer runs E2E tests locally
- **When** Postgres is running via `docker compose up -d postgres`
- **Then** `npm run test:e2e` bootstraps the test DB, runs migrations, and executes all tests

- **Given** CI executes the pipeline
- **When** the E2E job runs
- **Then** `docker compose up -d postgres` starts Postgres, migrations run, tests execute, and results are reported

## Technical Notes

### Test database setup

- Test DB name: `doclyzer_test` (separate from `doclyzer` dev DB)
- `.env.test` at `apps/api/`:
  ```
  DATABASE_URL=postgresql://doclyzer:doclyzer_dev_password@localhost:5432/doclyzer_test
  JWT_ACCESS_SECRET=test-access-secret
  JWT_REFRESH_SECRET=test-refresh-secret
  JWT_ACCESS_TTL_SECONDS=900
  JWT_REFRESH_TTL_DAYS=30
  ```

### AppModule in tests

- `jest-e2e.json` sets `testEnvironment: 'node'` and `globalSetup: './test/global-setup.ts'`
- `global-setup.ts`: creates `doclyzer_test` DB if missing + runs migrations via `AppDataSource`
- `global-teardown.ts`: optional — drop test DB or leave it for inspection

### Database cleanup between tests

Create `apps/api/test/db-cleaner.ts`:
```typescript
export async function clearDatabase(dataSource: DataSource): Promise<void> {
  const entities = dataSource.entityMetadatas;
  for (const entity of entities) {
    const repo = dataSource.getRepository(entity.name);
    await repo.query(`TRUNCATE TABLE "${entity.tableName}" RESTART IDENTITY CASCADE`);
  }
}
```

Each `describe` block in `app.e2e-spec.ts`:
```typescript
beforeEach(async () => {
  await clearDatabase(app.get(DataSource));
});
```

### E2E test updates required

The existing `app.e2e-spec.ts` tests (1.1–1.10) were written against in-memory services. After migrating to DB they need:
- Remove any assumptions about deterministic UUIDs (DB generates real UUIDs)
- Seed required data (user registration before login tests, etc.) using the API itself
- Remove any `policyAccepted` references (already done in previous session)
- Auth flow: register → login → get accessToken → use in subsequent requests

### AppModule test configuration

In `test/app.e2e-spec.ts` `beforeAll`:
```typescript
const moduleFixture = await Test.createTestingModule({
  imports: [AppModule],
})
  .overrideProvider('CONFIG') // override if needed for test DB URL
  .compile();
```

Alternatively: `process.env.DATABASE_URL` is set from `.env.test` before tests run via `dotenv` in globalSetup.

### CI configuration notes

```yaml
# .github/workflows/ci.yml (or equivalent)
- name: Start Postgres
  run: docker compose up -d postgres
- name: Wait for Postgres
  run: until docker compose exec -T postgres pg_isready; do sleep 1; done
- name: Run E2E tests
  run: npm run test:e2e
  working-directory: apps/api
  env:
    DATABASE_URL: postgresql://doclyzer:doclyzer_dev_password@localhost:5432/doclyzer_test
```

## References

- `apps/api/test/app.e2e-spec.ts` — existing E2E tests to migrate
- `apps/api/test/jest-e2e.json` — test runner config to update
- Story 0.1 — `AppDataSource` exported for use in globalSetup
- Story 0.3 — DB-backed services that this test infra validates

## Tasks / Subtasks

- [x] **Task 1: Test DB env and global setup** (AC: connect to doclyzer_test, bootstrap, migrations)
  - [x] 1.1 Create `apps/api/.env.test` with `DATABASE_URL` pointing to `doclyzer_test`, JWT secrets, and TTLs as specified in Technical Notes.
  - [x] 1.2 Create `apps/api/test/global-setup.ts`: load `.env.test` via dotenv, use `AppDataSource` from `data-source.ts` to create `doclyzer_test` DB if missing, run migrations, then initialize DataSource.
  - [x] 1.3 Create `apps/api/test/global-teardown.ts` (optional): leave DB for inspection or optionally drop; keep minimal.
  - [x] 1.4 Update `apps/api/test/jest-e2e.json`: add `globalSetup: './test/global-setup.ts'` and `globalTeardown: './test/global-teardown.ts'` (if implemented).

- [x] **Task 2: Database cleanup between tests** (AC: clean state per suite)
  - [x] 2.1 Create `apps/api/test/db-cleaner.ts` with `clearDatabase(dataSource: DataSource): Promise<void>` that truncates all entity tables (RESTART IDENTITY CASCADE) per Technical Notes.
  - [x] 2.2 Add `beforeEach` in `app.e2e-spec.ts` that calls `clearDatabase(app.get(DataSource))` so each test starts with a clean DB.

- [x] **Task 3: E2E test updates for real DB** (AC: all existing E2E tests pass)
  - [x] 3.1 Ensure `app.e2e-spec.ts` loads `AppModule` with `DATABASE_URL` from `.env.test` (via globalSetup; no override needed if env is set before tests).
  - [x] 3.2 Remove any assumptions about deterministic UUIDs; use DB-generated IDs from responses.
  - [x] 3.3 Ensure auth flow: register → login → get accessToken → use in subsequent requests; seed required data via API.
  - [x] 3.4 Remove direct repository access for seeding where it creates cross-test pollution; use DB cleanup + API seeding where possible. (Exception: `restrictionRepo` and `resetTokenRepo` used for specific test scenarios like "expired token" are acceptable if cleanup is correct.)
  - [x] 3.5 Verify `npm run test:e2e` passes when Postgres is running (`docker compose up -d postgres`).

- [x] **Task 4: CI configuration** (AC: CI runs Postgres, migrations, tests)
  - [x] 4.1 Add or update `.github/workflows/ci.yml` (or equivalent): start Postgres, wait for readiness, run `npm run test:e2e` in `apps/api` with `DATABASE_URL` for `doclyzer_test`.

## Dev Notes

- **Data-source:** `data-source.ts` uses `process.env` (TypeORM CLI context). globalSetup must load `.env.test` before any DataSource usage.
- **Test DB creation:** Use `pg` or raw SQL via `CREATE DATABASE doclyzer_test` if not exists; then `AppDataSource.initialize()` and `runMigrations()`.
- **E2E tests:** `app.e2e-spec.ts` already uses real DB via `AppModule`; password recovery tests use `InMemoryNotificationService` (mock). Restriction test uses `restrictionRepo` and cleans up; with `clearDatabase` in beforeEach, each test starts clean.
- **Profiles limit:** `Profiles limit (free tier)` creates a second app instance without `E2E_MAX_PROFILES`; ensure it runs with clean DB.

## Dev Agent Record

### Agent Model Used

gpt-5.3-codex

### Debug Log References

- `npx eslint "test/**/*.ts"` (pass)
- `npm run test:e2e` (all 61 tests pass with real Postgres and doclyzer_test)

### Completion Notes List

- Added real test DB setup: `.env.test`, `global-setup.ts` (DB ensure + migrations), `global-teardown.ts`, and `setup-env.ts`.
- Added DB cleanup helper and wired per-describe/per-test cleanup in `app.e2e-spec.ts` using `DataSource`.
- Updated E2E Jest config with `globalSetup`, `globalTeardown`, and `setupFiles`; fixed paths to use `<rootDir>`.
- Added CI workflow at `.github/workflows/ci.yml` to start Postgres and run API E2E tests against `doclyzer_test`.
- AppModule: use real Postgres when `DATABASE_URL` contains `doclyzer_test` (e2e); otherwise pg-mem for unit Jest.
- setup-env.ts: force `DATABASE_URL` to doclyzer_test when not set so e2e always targets test DB.
- E2E cleanup strategy: "Auth flows (per-test clean)" and password recovery/sessions use `beforeEach(clear)`; stateful describes (Account Profile, Profiles, etc.) use `beforeAll(clear, register, login)` so tests in the same describe share one user.
- All 61 E2E tests pass against real `doclyzer_test` after creating DB and running migrations (create DB manually or via global-setup; global-setup uses defaultTestUrl when .env.test path fails).

## File List

*(Other modified files in the repo (account, auth, consent, profiles, entities, migrations) are from Story 0.3 or shared work; this story's scope is E2E infra only.)*

- _bmad-output/implementation-artifacts/0-4-e2e-test-infrastructure-with-real-test-database.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- .github/workflows/ci.yml
- apps/api/.env.test
- apps/api/test/app.e2e-spec.ts
- apps/api/test/db-cleaner.ts
- apps/api/test/global-setup.ts
- apps/api/test/global-teardown.ts
- apps/api/test/jest-e2e.json
- apps/api/test/setup-env.ts
- apps/api/src/app.module.ts

## Change Log

- (Initial story structure created with Tasks/Subtasks, Dev Agent Record, File List, Change Log. Status set to ready-for-dev.)
- Added real Postgres-backed E2E infrastructure (env/test setup/cleanup/CI) and moved story to in-progress; final E2E pass verification pending Docker availability.
- Resumed with Docker up: fixed Jest paths, AppModule e2e real DB detection, setup-env DATABASE_URL fallback, global-setup DB creation from URL; per-describe/per-test cleanup; all 61 E2E tests pass. Status set to review.
- Code review fixes: .gitignore .env.test; CI ensure doclyzer_test exists before E2E; db-cleaner comment (tablePath); global-setup apiRoot path; e2e-spec indentation and Profiles limit comment; File List note on other modified files.
