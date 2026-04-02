# Story 5.16: Admin-Level Email Sending with Audit & Recipient Controls

Status: review

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

### Implementation Plan

- Extend email-admin DTO/types to cover admin send requests and response envelopes.
- Add POST admin email endpoint with superadmin guard + correlation ID enforcement.
- Persist queued send requests (idempotent by key) and emit delivery tracking events.
- Enforce approval/rate-limit policy hooks and PHI-safe audit logging.
- Document manual QA checklist per project policy (no automated tests).

### Completion Notes List

- Implemented admin email send contract, validation, and response envelope with explicit states.
- Added idempotency support for admin email queue items and migration/index registration.
- Enqueued admin sends with delivery event creation so analytics/history surfaces pick them up.
- Added approval/rate-limit policy hooks and PHI-safe audit metadata (no subject/body logging).
- Manual QA checklist (per policy, no automated tests):
  - Verify POST /v1/admin/email/send accepts type/subject/body/recipient scope and returns state= pending.
  - Confirm recipientScope=single requires recipientUserId; recipientScope=segment requires recipientSegment.
  - Confirm approval-required scope without approvalToken returns approval required error.
  - Trigger rate-limit threshold and confirm rate limit error.
  - Verify queue item persisted and delivery event shows in sending history/analytics views.
  - Validate audit event stored with actor/action/scope/outcome and no PHI payload.

### File List

- _bmad-output/implementation-artifacts/5-16-admin-level-email-sending-with-audit-and-recipient-controls.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- apps/api/src/database/entities/email-queue-item.entity.ts
- apps/api/src/database/migrations/1730816000000-AddIdempotencyKeyToEmailQueue.ts
- apps/api/src/database/migrations/index.ts
- apps/api/src/modules/email-admin/email-admin.controller.ts
- apps/api/src/modules/email-admin/email-admin.dto.ts
- apps/api/src/modules/email-admin/email-admin.service.ts
- apps/api/src/modules/email-admin/email-admin.types.ts
- apps/web/server/api/admin/email-admin-contracts.get.ts

### Change Log

- 2026-04-02: Added admin email send endpoint, queue/delivery tracking, idempotency support, and PHI-safe audit policy hooks.
