# Story 5.10: Share Link / Account Suspension and Restore Controls

Status: review

## Story

As a superadmin,
I want suspend/restore controls,
so that risk containment is immediate and reversible.

## Acceptance Criteria

1. Given target is risky, when suspend/restore action is executed, then target access state updates and is auditable.
2. Given suspended share links, when recipients attempt access, then deterministic denied outcomes are returned without leaking scope.
3. Given account suspension, when protected actions are attempted, then capability blocks apply consistently across API and mobile surfaces.
4. Given restore action is completed, when state propagates, then prior restrictions are lifted according to policy and recorded in audit trail.

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

- Story focus files/modules: apps/api/src/modules/sharing, apps/api/src/modules/account, apps/api/src/database/entities/restriction.entity.ts, apps/mobile/lib/features/account
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
- [Source: _bmad-output/planning-artifacts/epics.md#Story 5.10]
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
- 2026-03-30: Implemented superadmin suspend/restore controls for share links and accounts with idempotent state transitions.
- 2026-03-30: Added API/mobile capability blocking behavior for suspended accounts and auditable event recording for suspend/restore operations.

### Implementation Plan

- Extend audit-incident module with dedicated risk-containment controller/service and stable DTO/type contracts.
- Persist suspension state using existing entities (`share_links.is_active`, `restrictions.is_restricted`) with deterministic, idempotent updates.
- Enforce suspended-account capability blocking centrally in auth guard and expose restricted action hints to mobile consumers.
- Add API-first admin contract stub in web surface for pending superadmin UI wiring.

### Completion Notes List

- Story context prepared with implementation guardrails, acceptance criteria expansion, and module-level guidance.
- Auditability and PHI-safe telemetry constraints are explicitly included for dev execution.
- Status moved to review and sprint tracking has been updated accordingly.
- Added superadmin-protected endpoints for share-link/account suspension state updates:
  - `PATCH /v1/admin/risk-controls/share-links/:shareLinkId/suspension`
  - `PATCH /v1/admin/risk-controls/accounts/:userId/suspension`
- Added idempotent service behavior with explicit output states (`success` for suspend, `reverted` for restore), `changed` flag, and `actedAt`.
- Added audit event emission for `SHARE_LINK_SUSPENDED`, `SHARE_LINK_RESTORED`, `ACCOUNT_SUSPENDED`, and `ACCOUNT_RESTORED` with PHI-safe metadata.
- Enforced account suspension blocks on protected API endpoints in `AuthGuard` while allowing restriction-status retrieval and logout handling.
- Extended account restriction payload to include stable `restrictedActions` list for consumer surfaces.
- Mobile capability-block integration added for restricted actions in Home and Account Profile screens with user-visible guidance messaging.
- Manual QA checklist:
  - Verify superadmin suspend share-link request deactivates link and logs audit entry with correlation ID.
  - Verify suspended share links return deterministic denied response from public access endpoint without scope leakage.
  - Verify superadmin suspend account request revokes active sessions and blocks protected actions with `ACCOUNT_SUSPENDED`.
  - Verify restriction-status endpoint remains accessible and includes `restrictedActions`, rationale, and next-steps.
  - Verify restore actions return `reverted`, lift restrictions, and produce auditable restore events.
  - Verify mobile Home/Profile guarded actions show restriction messaging and avoid restricted operations.
- Validation notes:
  - `apps/api`: targeted ESLint on changed files passed.
  - `apps/mobile`: targeted `dart analyze` on changed files passed (only existing deprecation infos).
  - Full repo lint/build/analyze currently has pre-existing unrelated failures outside story 5.10 scope.

### File List

- _bmad-output/implementation-artifacts/5-10-share-link-account-suspension-and-restore-controls.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- apps/api/src/common/guards/auth.guard.ts
- apps/api/src/common/restriction/restriction.constants.ts
- apps/api/src/modules/account/account.service.ts
- apps/api/src/modules/account/account.types.ts
- apps/api/src/modules/audit-incident/audit-incident.module.ts
- apps/api/src/modules/audit-incident/risk-containment.controller.ts
- apps/api/src/modules/audit-incident/risk-containment.dto.ts
- apps/api/src/modules/audit-incident/risk-containment.service.ts
- apps/api/src/modules/audit-incident/risk-containment.types.ts
- apps/api/src/modules/auth/auth.module.ts
- apps/mobile/lib/features/account/screens/account_profile_screen.dart
- apps/mobile/lib/features/auth/screens/home_screen.dart
- apps/web/server/api/admin/risk-containment-contracts.get.ts

### Change Log

- 2026-03-30: Implemented Story 5.10 suspend/restore controls, account capability blocking, audit logging integration, and admin/web/mobile contract updates.
