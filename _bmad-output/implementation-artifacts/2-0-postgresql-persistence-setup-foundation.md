# Story 2.0: PostgreSQL Persistence Setup (Foundation)

Status: in-progress

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a developer,
I want the API backed by PostgreSQL instead of in-memory stores,
so that data persists across restarts and meets architecture/PRD requirements.

## Acceptance Criteria

1. **Given** the NestJS API runs
   **When** connected to PostgreSQL (via docker-compose)
   **Then** auth (users, sessions), profiles, consent, account (prefs, restrictions, export/closure requests) are persisted.
2. **Given** persistence is configured
   **When** schema changes are needed
   **Then** migrations are versioned and runnable.
3. **Given** DB-backed persistence is active
   **When** regression validation is executed
   **Then** existing e2e tests pass with DB-backed implementation.
4. **Given** a local developer starts the stack
   **When** they run Docker services
   **Then** local development uses `docker compose up` for Postgres + API.

## Tasks / Subtasks

- [x] Task 1: Reconcile current implementation against AC baselines without reinventing completed Epic 0 work (AC: 1, 2, 4)
  - [x] Confirm `TypeOrmModule.forRootAsync` + `ConfigService` DB wiring is active and uses environment config (not in-memory fallback) in runtime modules.
  - [x] Confirm persistence coverage for auth, profiles, consent, and account modules is repository/DB-backed, and identify any remaining in-memory edge paths.
  - [x] Confirm migration pipeline (`migration:generate`, `migration:run`, `migration:revert`) is runnable with current `src/database/data-source.ts` wiring.
  - [x] Confirm local `docker compose up` path for API + Postgres is documented and accurate.

- [x] Task 2: Close any gaps found in Task 1 with minimal, architecture-compliant changes (AC: 1, 2, 4)
  - [x] Implement only missing persistence/migration/documentation deltas.
  - [x] Keep module boundaries intact (no cross-module repository injection).
  - [x] Avoid introducing new persistence frameworks or schema stacks.

- [ ] Task 3: Validate DB-backed behavior and regression safety (AC: 3)
  - [ ] Run existing API tests relevant to auth/profiles/account persistence paths.
  - [ ] Run existing e2e suite that exercises DB-backed lifecycle paths.
  - [x] Capture evidence in Dev Agent Record (commands + outcomes + follow-up fixes).

- [x] Task 4: Finalize implementation traceability (AC: 1-4)
  - [x] Update story File List with every changed file.
  - [x] Add completion notes summarizing what was validated vs. newly changed.
  - [x] Keep scope strictly to this story's persistence foundation outcomes.

## Dev Notes

### Developer Context and Guardrails

- This story is a **foundation reconciliation story**: Epic 0 already delivered major persistence migration work; reuse and verify that implementation rather than rebuilding it.
- Existing completed stories that should be treated as primary prior art:
  - `0-1-typeorm-integration-database-entities-migrations`
  - `0-2-jwt-access-refresh-token-auth-db-backed-sessions`
  - `0-3-replace-all-in-memory-services-with-typeorm-repositories`
- Do not reintroduce in-memory maps as source-of-truth for domains covered by this story.
- Do not add Prisma or alternate ORM paths. The project context standard is TypeORM Data Mapper.

### Architecture Compliance Requirements

- PostgreSQL remains the transactional source of truth.
- Redis remains ephemeral only (sessions/rate-limits/caching), never authoritative state.
- Use versioned forward migrations with verification and rollback readiness.
- Enforce strict module boundaries and standardized API error envelopes/correlation handling.

### Library / Framework Requirements

- Backend framework: NestJS 11.x patterns already used by the codebase.
- ORM: TypeORM 0.3.x Data Mapper pattern with repository injection.
- Database: PostgreSQL 16 baseline in infrastructure and local docker flow.
- Runtime config: `@nestjs/config` + `ConfigService`; no direct `process.env` reads in feature modules.

### Latest Technical Information (Web Research)

- npm package metadata indicates active/stable tracks for current stack components used here:
  - `typeorm` package page shows `0.3.25` as latest on the crawled snapshot.
  - `@nestjs/core` package page shows `11.1.6` as latest on the crawled snapshot.
- PostgreSQL 16 remains an actively patched major line; PostgreSQL 16.11 release notes (2025-11-13) include security/bug fixes, reinforcing patch-level update hygiene for environments.
- Implementation implication: keep current major architecture, prioritize patch-level maintenance and migration discipline over framework churn in this story.

### File Structure Requirements

- Primary backend paths to inspect/update:
  - `apps/api/src/app.module.ts`
  - `apps/api/src/database/data-source.ts`
  - `apps/api/src/database/entities/`
  - `apps/api/src/database/migrations/`
  - `apps/api/src/modules/auth/`
  - `apps/api/src/modules/profiles/`
  - `apps/api/src/modules/consent/` or `apps/api/src/modules/consent-policy/`
  - `apps/api/src/modules/account/` (or equivalent account domain module)
- Documentation/infrastructure alignment paths:
  - `docker-compose.yml`
  - `README.md`
  - `.env.example` (if environment shape changes are required)

### Testing Requirements

- Validate with existing Jest/e2e infrastructure in `apps/api`.
- Prefer running existing persistence/auth/profile/account tests over creating new broad suites unless a true gap requires targeted additions.
- Ensure no regressions in DB-backed auth/session behavior before moving to review.

### Previous Story Intelligence

- Story number is `2.0`, so there is no prior story within Epic 2.
- Practical predecessor context comes from completed Epic 0 persistence stories; treat them as implementation baselines and avoid duplicating already-merged migration work.

### Project Structure Notes

- Current repo is a monorepo with API at `apps/api` and implementation artifacts in `_bmad-output/implementation-artifacts`.
- Sprint tracking currently includes this story as backlog and expects it to move to `ready-for-dev` once this context file is created.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.0]
- [Source: _bmad-output/planning-artifacts/architecture.md#Data Architecture]
- [Source: _bmad-output/planning-artifacts/architecture.md#API & Communication Patterns]
- [Source: _bmad-output/project-context.md#Technology Stack & Versions]
- [Source: _bmad-output/project-context.md#Critical Implementation Rules]
- [Source: _bmad-output/project-context.md#Architecture & Data Flow Rules]
- [Source: _bmad-output/implementation-artifacts/0-1-typeorm-integration-database-entities-migrations.md]
- [Source: _bmad-output/implementation-artifacts/0-2-jwt-access-refresh-token-auth-db-backed-sessions.md]
- [Source: _bmad-output/implementation-artifacts/0-3-replace-all-in-memory-services-with-typeorm-repositories.md]
- External: https://www.npmjs.com/package/typeorm
- External: https://www.npmjs.com/package/@nestjs/core
- External: https://www.postgresql.org/docs/release/16.11/
- External: https://docs.nestjs.com/techniques/database
- External: https://typeorm.io/docs/data-source/data-source/

## Dev Agent Record

### Agent Model Used

gpt-5 (Codex)

### Debug Log References

- `npm run test` (apps/api) → failed: missing script `test`.
- `npm run test:e2e` (apps/api) → failed: missing script `test:e2e`.
- `npm run build` (apps/api) → failed with pre-existing TypeScript errors in unrelated modules/files.
- `npx eslint "src/**/*.ts"` (apps/api) → failed with many pre-existing lint/prettier/type issues in unrelated files.
- `npm run migration:run` (apps/api) → wiring valid, but runtime failed with `ECONNREFUSED` because local Postgres was not reachable.
- `docker compose config --services` (repo root) → validated compose file and confirmed services include `api`, `postgres`, `redis`, `docling`.
- `docker compose up -d postgres` (repo root) → failed because local Docker daemon socket was unavailable.

### Implementation Plan

- Reconcile ACs against existing Epic 0 persistence implementation.
- Implement only minimal deltas (if any) for migration/runtime/documentation compliance.
- Validate DB-backed regressions and e2e behavior.

### Completion Notes List

- Reconciled persistence foundation against Epic 0 implementation: TypeORM runtime wiring, repository-backed auth/profiles/consent/account domains, and migration scripts are present and connected to `src/database/data-source.ts`.
- Identified only material AC gap as local operational path for API + Postgres via compose; implemented minimal infra/doc updates without changing persistence architecture.
- Added `api` service to compose and updated root README commands to standard `docker compose` flow for API + Postgres startup.
- Remaining blocker for AC3 completion: test/e2e scripts are not present in `apps/api/package.json`, and baseline build/lint currently fail due pre-existing unrelated issues.
- Story remains `in-progress` until regression/e2e validation can be executed in a clean baseline.

### File List

- _bmad-output/implementation-artifacts/2-0-postgresql-persistence-setup-foundation.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- docker-compose.yml
- README.md

### Change Log

- 2026-04-16: Created story context with architecture guardrails, prior-work reuse guidance, and implementation/test constraints.
- 2026-04-16: Reconciled persistence baseline, added compose API runtime path, updated docker compose documentation, and logged validation blockers (missing test scripts + pre-existing regression failures).
