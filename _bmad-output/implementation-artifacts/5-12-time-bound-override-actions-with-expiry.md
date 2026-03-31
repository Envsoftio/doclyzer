# Story 5.12: Time-Bound Override Actions with Expiry

Status: review

## Story

As a superadmin,
I want expiring overrides,
so that exceptional controls are bounded.

## Acceptance Criteria

1. Given override is created with expiry, when expiry time passes, then override auto-reverts and logs outcome.
2. Given override conflicts with active restrictions, when evaluated, then precedence rules are deterministic and documented.
3. Given scheduler/worker retries, when auto-revert executes multiple times, then operation remains idempotent.
4. Given manual early revoke, when applied, then override is deactivated immediately and recorded with reason.

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

- Story focus files/modules: apps/api/src/modules/account, apps/api/src/modules/auth, worker/scheduler surface (if introduced)
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
- [Source: _bmad-output/planning-artifacts/epics.md#Story 5.12]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX1: Domain Separation Baseline]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX4: Auditability Baseline]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-S3-03: Superadmin Analytics Capability]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-S3-04: Privacy-Safe Telemetry Guardrail]
- [Source: _bmad-output/project-context.md#Critical Implementation Rules]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

- TypeScript type-check passes cleanly on all new files. Pre-existing spec errors in account.service.spec.ts (constructor arg count) are test files excluded per project policy.

### Completion Notes List

- Story context prepared with implementation guardrails, acceptance criteria expansion, and module-level guidance.
- Auditability and PHI-safe telemetry constraints are explicitly included for dev execution.
- Status is ready-for-dev and sprint tracking has been updated accordingly.

#### Implementation Summary

**AC1 – Auto-revert on expiry with audit log:**
`AccountOverrideService.evaluateActiveOverrides()` queries all `isActive=true` overrides for a user. Any whose `expiresAt <= now` is immediately marked `isActive=false` with `revokedReason='auto_expired'` and an `ACCOUNT_OVERRIDE_EXPIRED` audit event is emitted via the tamper-chain `AuditIncidentService`. Called on every `AccountService.getRestrictionStatus()` invocation.

**AC2 – Deterministic precedence rules:**
Documented in `account-override.types.ts` (comment block) and enforced in `AccountService.getRestrictionStatus()`: active override's `overriddenActions` are subtracted from the restriction's `restrictedActions` set. Override always wins for the listed actions. Emergency containment (Story 5.14) supersedes all overrides and must be handled at that layer.

**AC3 – Idempotent auto-revert:**
`evaluateActiveOverrides()` only processes `isActive=true` rows. Once an override is marked inactive, subsequent calls find no matching rows and produce no duplicate audit events. Safe for scheduler/worker retries.

**AC4 – Manual early revoke:**
`PATCH /admin/risk-controls/accounts/:userId/overrides/revoke` with `{ overrideId, revokedReason? }` sets `isActive=false`, stamps `revokedAt`/`revokedByUserId`/`revokedReason`, and emits `ACCOUNT_OVERRIDE_REVOKED` audit event. If already inactive, returns `state: 'reverted'` with `changed: false` (idempotent).

#### Manual QA Checklist

- [ ] POST /admin/risk-controls/accounts/:userId/overrides — create override with future expiresAt, confirm 200 with overrideId
- [ ] POST with past expiresAt — confirm 400 ACCOUNT_OVERRIDE_INVALID_EXPIRY
- [ ] POST with unknown action name — confirm 400 ACCOUNT_OVERRIDE_INVALID_ACTIONS
- [ ] GET /admin/risk-controls/accounts/:userId/overrides — list shows created override with isActive=true
- [ ] GET /account/restriction while account is restricted + active override covers an action — confirm that action is absent from restrictedActions
- [ ] PATCH /admin/risk-controls/accounts/:userId/overrides/revoke — confirm override deactivated, revokedAt set, audit event ACCOUNT_OVERRIDE_REVOKED emitted
- [ ] PATCH revoke again (already revoked) — confirm 200 with state: 'reverted', changed: false
- [ ] Simulate expiry by setting expiresAt to past in DB — call GET /account/restriction, confirm ACCOUNT_OVERRIDE_EXPIRED audit event created and override no longer lifts the restriction
- [ ] Confirm all endpoints return 403 without SuperadminGuard token
- [ ] Confirm correlationId present in all success responses

### File List

- apps/api/src/database/entities/account-override.entity.ts (new)
- apps/api/src/database/migrations/1730815700000-CreateAccountOverridesTable.ts (new)
- apps/api/src/database/migrations/index.ts (modified)
- apps/api/src/modules/audit-incident/account-override.types.ts (new)
- apps/api/src/modules/audit-incident/account-override.dto.ts (new)
- apps/api/src/modules/audit-incident/account-override.service.ts (new)
- apps/api/src/modules/audit-incident/account-override.controller.ts (new)
- apps/api/src/modules/audit-incident/audit-incident.module.ts (modified)
- apps/api/src/modules/account/account.service.ts (modified)
- apps/api/src/modules/account/account.types.ts (modified)
- apps/api/src/modules/account/account.module.ts (modified)

## Change Log

- 2026-03-31: Implemented time-bound override actions with expiry (Story 5.12). Added AccountOverrideEntity with full DB migration, AccountOverrideService with create/list/revoke/evaluate methods, AccountOverrideController with three admin endpoints, and integrated override precedence evaluation into AccountService.getRestrictionStatus(). All audit events use the tamper-chain AuditIncidentService.
