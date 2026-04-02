# Story 5.15: Email Queue, Delivery Analytics & Sending History (Admin Panel)

Status: done

## Story

As a superadmin,
I want to view email queue status, delivery analytics, and sending history in the admin panel,
so that I can monitor and troubleshoot all email types (transactional and admin-sent).

## Acceptance Criteria

1. Given an authenticated superadmin opens email admin, when dashboard loads, then queue status (pending/processing/completed) is visible.
2. Given delivery analytics filters are applied, when query runs, then counts by type and outcome (sent/failed/bounced) are returned for the selected window.
3. Given sending history is displayed, when pagination changes, then timestamp/type/recipient-scope/outcome remain consistent and PHI-safe.
4. Given admin reads analytics, when actions occur, then access and filter use are auditable per policy.

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

- Story focus files/modules: apps/api/src/modules (email pipeline integration), apps/web/pages/admin/email (future), story 6.6 email pipeline contracts
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
- [Source: _bmad-output/planning-artifacts/epics.md#Story 5.15]
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

- Story context prepared with implementation guardrails, acceptance criteria expansion, and module-level guidance.
- Auditability and PHI-safe telemetry constraints are explicitly included for dev execution.
- Implemented email admin API endpoints (queue status, delivery analytics, sending history) with PHI-safe responses and correlation-aware audit logging.
- Added email queue and delivery event entities with migration and repository-backed analytics queries.
- Added admin API contract stubs for email endpoints in web surface planning.
- Manual QA checklist: verified response envelopes include correlationId, validated date window errors return EMAIL_ADMIN_INVALID_DATE_RANGE, confirmed analytics/history outputs contain no PHI and audit events are emitted with filter metadata.
- Per project testing policy, automated tests were not added or executed.

### File List

- _bmad-output/implementation-artifacts/5-15-email-queue-delivery-analytics-and-sending-history-admin-panel.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- apps/api/src/app.module.ts  # EmailAdminModule import — committed in story 5-15 batch
- apps/api/src/database/entities/email-delivery-event.entity.ts
- apps/api/src/database/entities/email-queue-item.entity.ts
- apps/api/src/database/migrations/1730815900000-CreateEmailAdminTables.ts
- apps/api/src/database/migrations/index.ts
- apps/api/src/modules/email-admin/email-admin.controller.ts
- apps/api/src/modules/email-admin/email-admin.dto.ts
- apps/api/src/modules/email-admin/email-admin.module.ts
- apps/api/src/modules/email-admin/email-admin.service.ts
- apps/api/src/modules/email-admin/email-admin.types.ts
- apps/web/server/api/admin/email-admin-contracts.get.ts

### Change Log

- 2026-04-01: Added email admin API contracts, persistence entities/migration, and audit-backed analytics endpoints.
- 2026-04-02: Code review fixes applied — queue status unknown-status handling, QB column names corrected, GIN index migration added for delivery event metadata lookup.
