# Story 5.2: Plan Definition and Limit Configuration Management

Status: done

## Story

As a superadmin,
I want plan configuration controls,
so that entitlements can be managed operationally.

## Acceptance Criteria

1. Given plan config changes, when saved, then validated changes persist with versioned audit trace.
2. Given limit keys (maxProfilesPerPlan, report cap, share-link limit), when invalid values are submitted, then validation rejects with clear error messages.
3. Given active user entitlements, when plan definitions are updated, then recalculation rules are deterministic and backward-compatible.
4. Given concurrent edits, when conflicts occur, then optimistic locking/version checks prevent silent overwrites.

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

- Story focus files/modules: apps/api/src/modules/entitlements, apps/api/src/modules/billing, apps/api/src/database/entities/user-entitlement.entity.ts
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
- [Source: _bmad-output/planning-artifacts/epics.md#Story 5.2]
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
- Added superadmin plan-config endpoints and DTO/type contracts under `entitlements` module.
- Added optimistic versioning + plan config audit persistence (`config_version`, `plan_config_audit_events`).
- Added API-first web admin contract stub for this story.

### Completion Notes List

- Implemented `GET /v1/entitlements/admin/plan-configs` and `PUT /v1/entitlements/admin/plan-configs/:planId` with `AuthGuard + SuperadminGuard`, correlation ID propagation, and stable response envelopes.
- Added explicit plan config DTO/type contracts and domain error codes for not found, invalid limits, and optimistic-lock conflicts.
- Implemented deterministic/idempotent update semantics: no-op updates keep version stable, changed updates increment `config_version`, and conflict checks enforce `expectedConfigVersion`.
- Added versioned audit trace persistence via `plan_config_audit_events` with actor/action/target/time/outcome, correlation ID, version transition, and PHI-safe metadata.
- Added web admin API contract stub (`apps/web/server/api/admin/plan-config-contracts.get.ts`) with explicit `pending/success/failure/reverted` states.
- Manual QA checklist executed:
  - Confirm `GET /v1/entitlements/admin/plan-configs` requires auth and superadmin role.
  - Confirm `PUT /v1/entitlements/admin/plan-configs/:planId` rejects invalid `maxProfilesPerPlan`, `reportCap`, and `shareLinkLimit` values with clear validation errors.
  - Confirm `PUT` with stale `expectedConfigVersion` returns conflict (`PLAN_CONFIG_VERSION_CONFLICT`) and no silent overwrite occurs.
  - Confirm `PUT` with unchanged payload is idempotent (no version bump) and returns deterministic recalculation descriptor.
  - Confirm successful `PUT` updates limits, increments `config_version`, and writes audit event row with `success` outcome.
  - Confirm logs/audit metadata contain no PHI payload fields.
- Validation run summary:
  - `npm run build` (apps/api): passed.
  - `npm run lint` (apps/api): failed due to unrelated pre-existing repo lint errors outside this story scope.
  - `npx eslint` on touched files only: passed.

### File List

- apps/api/src/app.module.ts
- apps/api/src/database/entities/plan.entity.ts
- apps/api/src/database/entities/plan-config-audit-event.entity.ts
- apps/api/src/database/migrations/1730814900000-CreatePlanConfigAuditAndVersioning.ts
- apps/api/src/database/migrations/index.ts
- apps/api/src/modules/entitlements/entitlements.controller.ts
- apps/api/src/modules/entitlements/entitlements.dto.ts
- apps/api/src/modules/entitlements/entitlements.module.ts
- apps/api/src/modules/entitlements/entitlements.service.ts
- apps/api/src/modules/entitlements/entitlements.types.ts
- apps/api/src/modules/entitlements/exceptions/plan-config-not-found.exception.ts
- apps/api/src/modules/entitlements/exceptions/plan-config-validation.exception.ts
- apps/api/src/modules/entitlements/exceptions/plan-config-version-conflict.exception.ts
- apps/web/server/api/admin/plan-config-contracts.get.ts
- _bmad-output/implementation-artifacts/5-2-plan-definition-and-limit-configuration-management.md
- _bmad-output/implementation-artifacts/sprint-status.yaml

## Change Log

- 2026-03-29: Implemented Story 5.2 plan configuration management with optimistic locking/versioning, versioned audit trace, superadmin-protected endpoints, and web admin API contract stubs. Marked status to review.
