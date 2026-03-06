# Story 0.1: TypeORM Integration, Database Entities & Migrations

**Status:** done  
**Epic:** 0 — Backend Foundation — Real Persistence, JWT Auth & API Wiring

## Dev Agent Record

- **Completion Notes:** TypeORM integrated with ConfigService; DataSource in `src/database/data-source.ts` for CLI; all 9 entities in `src/database/entities/`; initial migration `1730812800000-InitialSchema.ts`; `migration:generate` / `migration:run` / `migration:revert` scripts; `.env.example` with DATABASE_URL and JWT vars. Unit tests pass. E2E requires DATABASE_URL (and a running Postgres) — story 0-4 adds e2e test DB. Code review fixes applied: migration `down()` drops `uuid-ossp`, shared `migrations/index.ts` created, Docker images pinned to `postgres:16-alpine` / `redis:7-alpine`, entity convention and migration:generate usage documented in project-context.md, stale postgres version reference corrected.

## Tasks / Subtasks

- [x] TypeORM + pg dependencies installed; `AppModule` wired with `TypeOrmModule.forRootAsync`
- [x] All 9 entities created in `src/database/entities/`
- [x] Initial migration `1730812800000-InitialSchema.ts` created covering all 9 tables
- [x] `src/database/migrations/index.ts` shared migrations barrel (single registration point)
- [x] `src/database/data-source.ts` standalone DataSource for TypeORM CLI
- [x] `migration:generate` / `migration:run` / `migration:revert` scripts in `package.json`
- [x] `.env.example` with DATABASE_URL and JWT vars
- [x] Migration `down()` drops `uuid-ossp` extension for full reversibility
- [x] Docker images pinned: `postgres:16-alpine`, `redis:7-alpine`
- [x] `project-context.md` entity convention corrected to `src/database/entities/`
- [x] `project-context.md` migration:generate usage documented with example
- [x] `project-context.md` postgres version reference corrected to `postgres:16-alpine`

## File List

- `apps/api/package.json` — added TypeORM/pg deps and migration scripts
- `apps/api/src/app.module.ts` — TypeOrmModule.forRootAsync wired; imports migrations from index
- `apps/api/src/database/data-source.ts` — standalone DataSource for CLI
- `apps/api/src/database/migrations/index.ts` — shared migrations barrel (new)
- `apps/api/src/database/migrations/1730812800000-InitialSchema.ts` — initial schema; down() drops uuid-ossp
- `apps/api/src/database/entities/user.entity.ts`
- `apps/api/src/database/entities/session.entity.ts`
- `apps/api/src/database/entities/profile.entity.ts`
- `apps/api/src/database/entities/account-preference.entity.ts`
- `apps/api/src/database/entities/restriction.entity.ts`
- `apps/api/src/database/entities/data-export-request.entity.ts`
- `apps/api/src/database/entities/closure-request.entity.ts`
- `apps/api/src/database/entities/password-reset-token.entity.ts`
- `apps/api/src/database/entities/consent-record.entity.ts`
- `.env.example` — DATABASE_URL + JWT vars
- `docker-compose.yml` — pinned postgres:16-alpine and redis:7-alpine
- `_bmad-output/project-context.md` — entity convention, migration usage, postgres version corrected

## Change Log

- 2026-03-06: Initial implementation — TypeORM wired, 9 entities, initial migration, CLI DataSource, env example
- 2026-03-06: Code review fixes — migration down() drops uuid-ossp; shared migrations/index.ts; Docker images pinned; project-context.md docs corrected

## User Story

As a developer,
I want the NestJS API connected to PostgreSQL via TypeORM with versioned migrations,
So that all Epic 1 data persists across restarts and is schema-controlled.

## Acceptance Criteria

- **Given** the API starts with `DATABASE_URL` pointing to a running Postgres instance
- **When** the app module initializes
- **Then** TypeORM connects, runs pending migrations, and the full schema is present

- **Given** `npm run migration:run` is executed
- **When** migrations have not been applied
- **Then** they apply idempotently; re-running is a no-op

- **Given** `docker compose up` is run from the project root
- **When** Postgres becomes healthy
- **Then** `npm run start:dev` auto-migrates on startup in dev mode

- **Given** a developer needs a new migration
- **When** they run `npm run migration:generate -- src/database/migrations/MigrationName`
- **Then** a new timestamped migration file is generated reflecting entity changes

## Entities

All entities live in `apps/api/src/database/entities/`.

| Entity | Key columns |
|---|---|
| `UserEntity` | id (uuid), email (unique), passwordHash, createdAt, updatedAt |
| `SessionEntity` | id (uuid), userId (FK), refreshTokenHash, ipAddress, userAgent, createdAt, expiresAt |
| `ProfileEntity` | id (uuid), userId (FK), name, dateOfBirth (nullable), relation (nullable), isActive, createdAt, updatedAt |
| `AccountPreferenceEntity` | id (uuid), userId (FK unique), productEmailsEnabled (bool, default true), updatedAt |
| `RestrictionEntity` | id (uuid), userId (FK unique), isRestricted, rationale (nullable), nextSteps (nullable), updatedAt |
| `DataExportRequestEntity` | id (uuid), userId (FK), status (pending/completed/failed), createdAt, completedAt (nullable), downloadUrl (nullable), failureReason (nullable) |
| `ClosureRequestEntity` | id (uuid), userId (FK), status, message, createdAt |
| `PasswordResetTokenEntity` | id (uuid), userId (FK), tokenHash, expiresAt, usedAt (nullable), createdAt |
| `ConsentRecordEntity` | id (uuid), userId (FK), policyVersion, acceptedAt |

## Technical Notes

### Dependencies to install

```bash
npm install @nestjs/typeorm typeorm pg @nestjs/config
npm install -D @types/pg
```

### TypeORM DataSource configuration

- `TypeOrmModule.forRootAsync` in `AppModule`, reads from `ConfigService`
- `synchronize: false` always — use migrations only
- `migrationsRun: true` in dev and test environments
- DataSource also exported as `AppDataSource` from `src/database/data-source.ts` for CLI usage

### Scripts to add to package.json

```json
"migration:generate": "typeorm-ts-node-commonjs migration:generate -d src/database/data-source.ts",
"migration:run": "typeorm-ts-node-commonjs migration:run -d src/database/data-source.ts",
"migration:revert": "typeorm-ts-node-commonjs migration:revert -d src/database/data-source.ts"
```

### Environment variables (.env.example)

```
DATABASE_URL=postgresql://doclyzer:doclyzer_dev_password@localhost:5432/doclyzer
JWT_ACCESS_SECRET=change-me-in-production
JWT_REFRESH_SECRET=change-me-in-production-too
JWT_ACCESS_TTL_SECONDS=900
JWT_REFRESH_TTL_DAYS=30
```

### Docker compose (already exists)

`docker-compose.yml` at project root already has Postgres 16 + Redis 7. No changes needed unless adding an API service.

## References

- Architecture: PostgreSQL as transactional source of truth (architecture.md)
- docker-compose.yml: Postgres 16-alpine already configured at root
- Current: `apps/api` has no DB dependencies — zero TypeORM/pg in package.json
- Supersedes Story 2.0 (PostgreSQL Persistence Setup) which is absorbed here
