# Story 2.0: PostgreSQL Persistence Setup (Foundation)

**Status:** backlog  
**Epic:** 2 - Report Ingestion, Processing Recovery & Timeline Insights

## User Story

As a developer,
I want the API backed by PostgreSQL instead of in-memory stores,
So that data persists across restarts and meets architecture/PRD requirements.

## Acceptance Criteria

- **Given** the NestJS API runs
- **When** connected to PostgreSQL (via docker-compose)
- **Then** auth (users, sessions), profiles, consent, account (prefs, restrictions, export/closure requests) are persisted
- **And** migrations are versioned and runnable
- **And** existing e2e tests pass with DB-backed implementation
- **And** local dev uses `docker compose up` for Postgres + API

## Technical Notes

- Use TypeORM or Prisma per architecture; entities for users, sessions, profiles, consent, account data
- Replace in-memory Map usage in AuthService, AccountService, ProfilesService, ConsentService, PasswordRecoveryService
- Wire API to DATABASE_URL from env; document in README

## References

- Architecture: PostgreSQL as transactional source of truth
- Product brief: DB (e.g. PostgreSQL) in docker-compose
- Current: apps/api uses Map-based in-memory storage
