# Story 5.7: Auditable Superadmin Action Logging

Status: done

## Story

As a compliance stakeholder,
I want immutable admin audit logs,
so that high-risk actions are traceable.

## Acceptance Criteria

1. Given admin action executes, when logging occurs, then actor/action/target/time/outcome are captured.
2. Given audit event write attempts fail, when fallback handling runs, then action outcome and integrity alerts are emitted deterministically.
3. Given query operations, when audit records are retrieved, then pagination/filtering and tamper-evidence metadata are preserved.
4. Given sensitive targets, when logged, then identifiers are minimized/redacted per PHI-safe policy.

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

- Story focus files/modules: apps/api/src/modules (new audit_incident), apps/api/src/common/filters, correlation-id middleware
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
- [Source: _bmad-output/planning-artifacts/epics.md#Story 5.7]
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

### Completion Notes List

- Built the `audit_incident` module (controller, service, DTOs, types) so `/admin/audit/actions` can record and query superadmin audit events through the shared response envelope with all the required guards/correlation IDs.
- Added `SuperadminActionAuditEvent` persistence (entity + migration + data-source/app.module wiring) plus sanitized metadata, tamper-hash chaining, and deterministic fallback logging to capture actor/action/target/time/outcome without leaking PHI.
- Manual QA checklist (per policy):
  - [x] Verified guards, correlation IDs, and response envelopes for both POST and GET endpoints.
  - [x] Reviewed tamper hash sequence, target redaction, and fallback logging code paths to confirm deterministic alert emission and PHI-safe metadata.
  - [x] Confirmed query filtering/pagination still returns tamper-evidence metadata and documented the API surface via the new admin contract stub.

### File List

- _bmad-output/implementation-artifacts/5-7-auditable-superadmin-action-logging.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- apps/api/src/app.module.ts
- apps/api/src/database/data-source.ts
- apps/api/src/database/entities/superadmin-action-audit-event.entity.ts
- apps/api/src/database/migrations/1730815200000-CreateSuperadminActionAuditTables.ts
- apps/api/src/database/migrations/index.ts
- apps/api/src/modules/audit-incident/audit-incident.module.ts
- apps/api/src/modules/audit-incident/audit-incident.controller.ts
- apps/api/src/modules/audit-incident/audit-incident.service.ts
- apps/api/src/modules/audit-incident/audit-incident.dto.ts
- apps/api/src/modules/audit-incident/audit-incident.types.ts
- apps/web/server/api/admin/audit-action-logging-contracts.get.ts

### Change Log

- 2026-03-30: Added the `audit_incident` module, tamper-hash persistence/migration, PHI-safe metadata handling, deterministic fallback alerts, and the admin audit API stub; sprint status/story now in review with tagging updated accordingly.
- 2026-03-30: Code review fixes — changed `actor_user_id` FK from `ON DELETE CASCADE` to `ON DELETE SET NULL` (nullable column) so audit records survive user deletion, preserving immutability guarantee (H1); wrapped tamper-chain sequence fetch + insert in a `DataSource.transaction` with `pg_advisory_xact_lock` to prevent race conditions under concurrent writes (H2); added migration `1730815300000-FixAuditEventImmutabilityAndTamperChain` with SET NULL FK and UNIQUE constraint on `tamper_sequence`.
