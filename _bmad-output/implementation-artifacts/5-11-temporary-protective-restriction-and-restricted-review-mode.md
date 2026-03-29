# Story 5.11: Temporary Protective Restriction and Restricted Review Mode

Status: ready-for-dev

## Story

As a superadmin,
I want temporary restriction controls,
so that investigations can proceed safely.

## Acceptance Criteria

1. Given restriction is applied, when account is evaluated, then configured capability limits are enforced deterministically.
2. Given restriction rationale/next steps are set, when user checks status, then rationale and next steps are visible in existing restriction surfaces.
3. Given restricted review mode is active, when high-risk operations are attempted, then operation-specific denials include stable error codes.
4. Given restriction expires or is removed, when status refreshes, then enforcement changes take effect without stale authorization windows.

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

- Story focus files/modules: apps/api/src/modules/account, apps/api/src/database/entities/restriction.entity.ts, apps/mobile/lib/features/account/api_restriction_repository.dart
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
- [Source: _bmad-output/planning-artifacts/epics.md#Story 5.11]
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
- Implemented temporary restriction fields, restricted review mode enforcement, and expiry handling in API guard and account status.
- Added risk-control endpoint for superadmin restriction mode updates with audit logging and deterministic state transitions.
- Mobile restriction repository now captures review mode and restriction expiry metadata for UI surfaces.
- Manual QA checklist:
  - Set restriction mode to `review` with future `restrictedUntil`; confirm restricted actions return review-mode error codes and include rationale/nextSteps.
  - Set restriction mode to `suspended`; confirm all protected endpoints block with `ACCOUNT_SUSPENDED` and session revocation occurs.
  - Set restriction mode to `none` and verify restriction status clears and blocked actions are restored.
  - Use `restrictedUntil` in the past to confirm expiry clears enforcement on next request.

### File List

- _bmad-output/implementation-artifacts/5-11-temporary-protective-restriction-and-restricted-review-mode.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- apps/api/src/common/guards/auth.guard.ts
- apps/api/src/common/restriction/restriction.constants.ts
- apps/api/src/database/entities/restriction.entity.ts
- apps/api/src/database/migrations/1730815600000-AddRestrictionReviewMode.ts
- apps/api/src/database/migrations/index.ts
- apps/api/src/modules/account/account.service.ts
- apps/api/src/modules/account/account.types.ts
- apps/api/src/modules/audit-incident/risk-containment.controller.ts
- apps/api/src/modules/audit-incident/risk-containment.dto.ts
- apps/api/src/modules/audit-incident/risk-containment.service.ts
- apps/api/src/modules/audit-incident/risk-containment.types.ts
- apps/mobile/lib/features/account/api_restriction_repository.dart
- apps/mobile/lib/features/account/restriction_repository.dart

### Change Log

- 2026-03-30: Added restriction review mode fields, superadmin restriction endpoint, expiry handling, and mobile status parsing for temporary protective restriction.

### Status

review
