# Story 5.3: Promo Code CRUD and Lifecycle Management

Status: review

## Story

As a superadmin,
I want promo lifecycle controls,
so that campaign operations are manageable.

## Acceptance Criteria

1. Given promo CRUD actions occur, when validated and saved, then promo lifecycle state updates safely.
2. Given overlapping validity windows or duplicate codes, when creation/update is attempted, then uniqueness and date constraints are enforced.
3. Given deactivation, when checkout validation runs, then inactive promos are rejected deterministically.
4. Given lifecycle changes, when persisted, then impacted reservations/redemptions remain internally consistent and auditable.

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

- Story focus files/modules: apps/api/src/modules/billing, apps/api/src/database/entities/promo-code.entity.ts, apps/api/src/database/entities/promo-redemption.entity.ts
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
- [Source: _bmad-output/planning-artifacts/epics.md#Story 5.3]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX1: Domain Separation Baseline]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX4: Auditability Baseline]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-S3-03: Superadmin Analytics Capability]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-S3-04: Privacy-Safe Telemetry Guardrail]
- [Source: _bmad-output/project-context.md#Critical Implementation Rules]

## Dev Agent Record

### Agent Model Used

GPT-5 (Codex)

### Debug Log References

- Generated via BMAD create-story equivalent workflow for Epic 5 batch.
- `npm run lint --workspace apps/api` (fails due missing root `package.json`; reran in `apps/api`)
- `npm run lint` in `apps/api` (fails on pre-existing unrelated lint debt in other modules/specs)
- `npx eslint src/modules/billing/billing.controller.ts src/modules/billing/billing.service.ts src/modules/billing/billing.types.ts src/modules/billing/billing.module.ts src/database/entities/promo-code-audit-event.entity.ts src/database/migrations/1730815000000-CreatePromoCodeAuditEvents.ts src/database/migrations/index.ts` (pass)
- `npm run build` in `apps/api` (pass)

### Completion Notes List

- Added superadmin promo lifecycle admin API endpoints under billing: list, create, update, deactivate, reactivate. All endpoints enforce `AuthGuard + SuperadminGuard`, use correlation IDs, and return stable envelope/state payloads.
- Added billing admin DTO/type contracts and lifecycle error codes (`BILLING_PROMO_CODE_DUPLICATE`, `BILLING_PROMO_DATE_RANGE_INVALID`) with deterministic lifecycle `state` values (`pending|success|failure|reverted`).
- Implemented promo CRUD/lifecycle service logic with TypeORM repositories and transactional pessimistic locking for deterministic/idempotent updates.
- Enforced duplicate-code and date-range constraints in lifecycle operations; existing checkout promo validation already rejects inactive promos deterministically.
- Added auditable promo lifecycle event persistence (`promo_code_audit_events`) and PHI-safe structured lifecycle logs with actor/action/target/outcome/correlationId metadata only.
- Ensured reservation consistency on lifecycle changes: deactivating or disabling promo codes voids only `reserved` redemptions while preserving redeemed history for auditability.
- Manual QA checklist (project policy: no automated tests for story completion):
  - [x] Linted all changed story files with ESLint directly
  - [x] Built backend (`nest build`) successfully
  - [x] Verified admin endpoint guard + correlation-id wiring in controller paths
  - [x] Verified lifecycle response states (`success`/`reverted`) and deterministic no-op behavior
  - [x] Verified redemptions consistency path (reserved -> void on deactivate/update-to-inactive)
  - [x] Verified audit entity+migration wiring and migration index registration
  - [ ] Runtime API smoke via authenticated superadmin token in local env (pending interactive env execution)

### File List

- _bmad-output/implementation-artifacts/5-3-promo-code-crud-and-lifecycle-management.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- apps/api/src/modules/billing/billing.types.ts
- apps/api/src/modules/billing/billing.controller.ts
- apps/api/src/modules/billing/billing.service.ts
- apps/api/src/modules/billing/billing.module.ts
- apps/api/src/database/entities/promo-code-audit-event.entity.ts
- apps/api/src/database/migrations/1730815000000-CreatePromoCodeAuditEvents.ts
- apps/api/src/database/migrations/index.ts

### Change Log

- 2026-03-29: Implemented Story 5.3 promo code CRUD/lifecycle management with superadmin endpoints, deterministic lifecycle state handling, audit persistence, and reservation consistency updates.
