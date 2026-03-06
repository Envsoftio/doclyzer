# Story 0.4: E2E Test Infrastructure with Real Test Database

**Status:** backlog  
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
