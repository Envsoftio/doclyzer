# Story 5.9: Suspicious Activity Detection and Review Queue

Status: done

## Story

As a superadmin,
I want suspicious activity queueing,
so that risk triage is prioritized.

## Acceptance Criteria

1. Given detection rules trigger, when events are processed, then review queue items are created with severity/state.
2. Given duplicate signals for the same target, when ingestion occurs, then dedupe/idempotency rules avoid queue flooding.
3. Given triage updates, when status changes (open/in-review/resolved), then transitions are constrained and auditable.
4. Given confidence thresholds, when exceeded, then optional automatic containment actions can be suggested but not silently applied.

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

- Story focus files/modules: apps/api/src/modules/auth, apps/api/src/modules/sharing, apps/api/src/modules/account, apps/api/src/modules (new audit_incident)
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
- [Source: _bmad-output/planning-artifacts/epics.md#Story 5.9]
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
- 2026-03-30: Implemented suspicious activity review queue APIs, persistence, and audit logging with idempotent ingestion and constrained status transitions.

### Implementation Plan

- Add suspicious activity queue entity, migration, and admin API contracts (DTOs/types/routes) under audit-incident module.
- Implement deterministic ingestion with dedupe/idempotency and containment suggestions at confidence thresholds.
- Enforce triage status transitions with audit logging and PHI-safe metadata.
- Add web admin contract stub for API-first integration.

### Completion Notes List

- Story context prepared with implementation guardrails, acceptance criteria expansion, and module-level guidance.
- Auditability and PHI-safe telemetry constraints are explicitly included for dev execution.
- Status moved to review and sprint tracking has been updated accordingly.
- Implemented suspicious activity review queue persistence with dedupe key + idempotency handling and severity escalation rules.
- Added superadmin-guarded admin routes for ingesting signals, listing queue items, and updating triage status with explicit response states.
- Added optional containment suggestions for high-confidence signals without auto-applying actions, plus audit trails for ingestion and triage changes.
- Manual QA checklist:
  - Verify POST /v1/admin/risk/suspicious-activity creates or dedupes queue items with expected severity/state.
  - Verify GET /v1/admin/risk/suspicious-activity filters by status/severity/target and returns explicit success state.
  - Verify PATCH /v1/admin/risk/suspicious-activity/:queueItemId/status enforces allowed transitions and emits audit events.
  - Confirm no PHI payloads are included in audit metadata or response bodies.

### File List

- _bmad-output/implementation-artifacts/5-9-suspicious-activity-detection-and-review-queue.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- apps/api/src/database/entities/suspicious-activity-queue-item.entity.ts
- apps/api/src/database/migrations/1730815500000-CreateSuspiciousActivityQueue.ts
- apps/api/src/database/migrations/index.ts
- apps/api/src/modules/audit-incident/audit-incident.module.ts
- apps/api/src/modules/audit-incident/suspicious-activity.controller.ts
- apps/api/src/modules/audit-incident/suspicious-activity.dto.ts
- apps/api/src/modules/audit-incident/suspicious-activity.service.ts
- apps/api/src/modules/audit-incident/suspicious-activity.types.ts
- apps/web/server/api/admin/suspicious-activity-review-queue-contracts.get.ts

### Change Log

- 2026-03-30: Implemented suspicious activity review queue APIs, persistence, dedupe rules, and audit logging with admin contract stubs.
