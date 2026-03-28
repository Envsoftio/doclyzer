# Story 5.1: Superadmin Authentication Hardening (MFA + Role Guard Baseline)

Status: review

## Story

As a superadmin,
I want MFA and strict role guards,
so that admin operations are protected.

## Acceptance Criteria

1. Given admin login succeeds, when privilege elevation is attempted, then MFA challenge must be completed before admin action tokens are issued.
2. Given an authenticated non-superadmin user, when admin endpoints are called, then access is denied with stable authorization error codes.
3. Given an active superadmin session, when MFA trust expires or risk posture changes, then re-challenge is required before sensitive operations.
4. Given failed MFA attempts exceed threshold, when retry continues, then deterministic lockout/rate-limit controls apply and are auditable.

## Tasks / Subtasks

- [x] Task 1: Define API/domain contracts and error codes for this story
  - [x] Add or extend module types/DTOs and controller routes with stable response envelopes
  - [x] Ensure role checks and correlation IDs are enforced on all endpoints
- [x] Task 2: Implement service and persistence logic using existing architecture patterns
  - [x] Use TypeORM repositories via dependency injection and injected repositories
  - [x] Keep business rules deterministic and idempotent for retriable operations
- [x] Task 3: Integrate UI/consumer surface for superadmin workflows (API-first if UI not scaffolded)
  - [x] Add route-level stubs/contracts in web/admin surface plan when implementation surface is pending
  - [x] Ensure output states are explicit (pending/success/failure/reverted)
- [x] Task 4: Add audit and governance protections
  - [x] Emit auditable events for actor/action/target/time/outcome
  - [x] Apply PHI-safe telemetry and logging guardrails
- [x] Task 5: Validate manually (no automated tests per project policy)
  - [x] Record manual QA checklist and edge cases in completion notes

## Dev Notes

- Story focus files/modules: apps/api/src/modules/auth, apps/api/src/modules/account, apps/mobile/lib/features/auth
- Keep domain separation from architecture baseline: PHI-bearing clinical/report domain must stay isolated from billing/entitlement and admin analytics domains.
- Follow project context rules: no direct environment reads inside modules; use ConfigService, keep thin controllers and service-owned business logic.
- Enforce superadmin access controls with explicit guards; avoid introducing global auth shortcuts.
- Keep telemetry and logs PHI-safe: do not include PHI payloads in audit/search/analytics streams.

### Project Structure Notes

- Primary backend surface: apps/api/src/modules (extend current modules; introduce analytics_admin and audit_incident only when needed by this story).
- Entity and migration changes live under apps/api/src/database/entities and apps/api/src/database/migrations.
- Web admin surface target (when scaffolded): apps/web/pages/admin and apps/web/server/api/admin.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Epic 5: Superadmin Operations, Risk Controls & Product Analytics]
- [Source: _bmad-output/planning-artifacts/epics.md#Story 5.1]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX1: Domain Separation Baseline]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX4: Auditability Baseline]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-S3-03: Superadmin Analytics Capability]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-S3-04: Privacy-Safe Telemetry Guardrail]
- [Source: _bmad-output/project-context.md#Critical Implementation Rules]

## Dev Agent Record

### Agent Model Used

GPT-5 (Codex)

### Debug Log References

- `npm run build` (apps/api) passed after implementation updates.
- `npx eslint ...` focused lint run for touched API files passed.
- `npm run build` (apps/web) passed with superadmin contract stub route.
- `npm run lint` (apps/api full) reports pre-existing unrelated lint violations outside this story scope.

### Completion Notes List

- Implemented new superadmin elevation API routes: `/v1/auth/superadmin/elevation/challenge`, `/v1/auth/superadmin/elevation/verify`, and `/v1/auth/superadmin/elevation/token`.
- Added strict superadmin role guard (`AUTHZ_SUPERADMIN_REQUIRED`) and stable MFA error codes for challenge-required, invalid-code, lockout, and re-challenge-required outcomes.
- Added persistence layer for deterministic MFA challenge lifecycle and lockout/retry controls via `superadmin_mfa_challenges` (TypeORM entity + migration).
- Added auditable governance event persistence via `superadmin_auth_audit_events` with actor/action/target/time/outcome fields and PHI-safe metadata-only logging.
- Added API-first web admin stub contract route (`/api/admin/superadmin-auth-contracts`) with explicit `pending/success/failure/reverted` states.
- Manual QA checklist:
  - Build validation: API build passed, web build passed.
  - Executed endpoint flow with live server:
    - Non-superadmin challenge call returned `403 AUTHZ_SUPERADMIN_REQUIRED`.
    - Superadmin challenge call returned `200` with challenge ID.
    - Wrong MFA code returned `401 AUTH_MFA_INVALID_CODE`.
    - Correct MFA code returned `200` with `state=success`.
    - Token issuance after successful challenge returned `200` with admin action token.
    - Risk posture change (`x-risk-posture: high-risk`) returned `401 AUTH_MFA_CHALLENGE_REQUIRED`.
    - Lockout test (5 invalid attempts) returned `429 AUTH_MFA_LOCKED` on attempt 5.
  - Database migration validation: `CreateSuperadminMfaAndAuditTables1730814800000` present in `migrations` table.
- Edge cases tracked:
  - Missing/unknown `currentSessionId` falls back to `unknown-session`; challenge remains bound and deterministic for retry.
  - Repeated challenge creation with same active risk/session returns existing pending challenge for idempotent retries.

### File List

- .env
- .env.example
- _bmad-output/implementation-artifacts/5-1-superadmin-authentication-hardening-mfa-role-guard-baseline.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- apps/api/src/app.module.ts
- apps/api/src/database/entities/superadmin-auth-audit-event.entity.ts
- apps/api/src/database/entities/superadmin-mfa-challenge.entity.ts
- apps/api/src/database/migrations/1730814800000-CreateSuperadminMfaAndAuditTables.ts
- apps/api/src/database/migrations/index.ts
- apps/api/src/modules/auth/auth.dto.ts
- apps/api/src/modules/auth/auth.module.ts
- apps/api/src/modules/auth/auth.types.ts
- apps/api/src/modules/auth/superadmin-auth.controller.ts
- apps/api/src/modules/auth/superadmin-auth.service.ts
- apps/api/src/modules/auth/superadmin.guard.ts
- apps/web/app/pages/admin/index.vue
- apps/web/server/api/admin/superadmin-auth-contracts.get.ts

## Change Log

- 2026-03-29: Implemented Story 5.1 baseline for superadmin MFA hardening, role guard enforcement, auditable events, and API-first web contract stubs.
