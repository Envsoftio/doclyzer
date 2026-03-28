# Story 5.16: Admin-Level Email Sending with Audit & Recipient Controls

Status: ready-for-dev

## Story

As a superadmin,
I want to send admin-level emails from the admin panel,
so that communication is controlled and auditable.

## Acceptance Criteria

1. Given an authenticated superadmin composes an admin email, when send is requested, then type/subject/body/recipient scope validation is enforced.
2. Given send operation executes, when pipeline accepts the job, then delivery tracking is visible in Story 5.15 analytics/history views.
3. Given send actions are high impact, when triggered, then approvals and/or rate limits can be applied according to policy.
4. Given audit logging runs, when send completes or fails, then actor/action/recipient-scope/timestamp/outcome are captured without PHI leakage.

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

- Story focus files/modules: apps/api/src/modules (email sending integration), apps/web/pages/admin/email-compose (future), story 6.6 email pipeline contracts
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
- [Source: _bmad-output/planning-artifacts/epics.md#Story 5.16]
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

- _bmad-output/implementation-artifacts/5-16-admin-level-email-sending-with-audit-and-recipient-controls.md
