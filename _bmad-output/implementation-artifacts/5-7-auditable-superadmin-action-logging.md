# Story 5.7: Auditable Superadmin Action Logging

Status: ready-for-dev

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

- [ ] Task 1: Define API/domain contracts and error codes for this story
  - [ ] Add or extend module types/DTOs and controller routes with stable response envelopes
  - [ ] Ensure role checks and correlation IDs are enforced on all endpoints
- [ ] Task 2: Implement service and persistence logic using existing architecture patterns
  - [ ] Use TypeORM repositories via dependency injection and injected repositories
  - [ ] Keep business rules deterministic and idempotent for retriable operations
- [ ] Task 3: Integrate UI/consumer surface for superadmin workflows (API-first if UI not scaffolded)
  - [ ] Add route-level stubs/contracts in web/admin surface plan when implementation surface is pending
  - [ ] Ensure output states are explicit (pending/success/failure/reverted)
- [ ] Task 4: Add audit and governance protections
  - [ ] Emit auditable events for actor/action/target/time/outcome
  - [ ] Apply PHI-safe telemetry and logging guardrails
- [ ] Task 5: Validate manually (no automated tests per project policy)
  - [ ] Record manual QA checklist and edge cases in completion notes

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

- Story context prepared with implementation guardrails, acceptance criteria expansion, and module-level guidance.
- Auditability and PHI-safe telemetry constraints are explicitly included for dev execution.
- Status is ready-for-dev and sprint tracking has been updated accordingly.

### File List

- _bmad-output/implementation-artifacts/5-7-auditable-superadmin-action-logging.md
