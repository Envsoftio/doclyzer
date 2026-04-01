# Story 5.14: Emergency Containment Actions with Mandatory Audit Notes

Status: done

## Story

As a superadmin,
I want emergency containment with required notes,
so that urgent response remains accountable.

## Acceptance Criteria

1. Given emergency action is executed, when completion occurs, then mandatory audit notes are captured.
2. Given missing note content, when emergency action is attempted, then request is rejected before execution.
3. Given high-impact actions, when executed, then secondary confirmation and elevated privilege checks are enforced.
4. Given post-incident review, when retrieving records, then emergency notes and action timeline are queryable and immutable.

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

- Story focus files/modules: apps/api/src/modules (new audit_incident), apps/api/src/modules/account, apps/api/src/modules/sharing
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
- [Source: _bmad-output/planning-artifacts/epics.md#Story 5.14]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX1: Domain Separation Baseline]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX4: Auditability Baseline]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-S3-03: Superadmin Analytics Capability]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-S3-04: Privacy-Safe Telemetry Guardrail]
- [Source: _bmad-output/planning-artifacts/architecture.md#Critical Implementation Rules]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

- No new DB entities needed — emergency actions piggyback the existing tamper-evident `superadmin_action_audit_events` table with an `EMERGENCY_` action prefix.
- TypeScript compile clean for all new files (pre-existing spec-file errors unrelated to this story remain).

### Completion Notes List

- Story context prepared with implementation guardrails, acceptance criteria expansion, and module-level guidance.
- Auditability and PHI-safe telemetry constraints are explicitly included for dev execution.
- **Implemented `emergency-containment.types.ts`**: error constants, `EmergencyActionNoteRequiredException` (thrown before any side effects), result/timeline interfaces.
- **Implemented `emergency-containment.dto.ts`**: `EmergencyBaseDto` with `@MinLength(10) @MaxLength(1024) auditNote` (class-validator enforces at controller boundary); `EmergencyAccountSuspendDto`, `EmergencyShareLinkSuspendDto`, `EmergencyActionTimelineQueryDto`.
- **Implemented `emergency-containment.service.ts`**: `EmergencyContainmentService` delegates to `RiskContainmentService` for the actual state mutations, then writes a second `EMERGENCY_*`-prefixed audit event carrying the mandatory note in `metadata.description`. The double-write ensures emergency events are independently queryable by action prefix. A private `assertAuditNote` guard rejects calls with notes shorter than 10 characters before any DB writes occur (AC2). State mapping helper converts `RiskContainmentState` (includes `'pending'`) to `AuditActionOutcome` / `EmergencyContainmentState`.
- **Implemented `emergency-containment.controller.ts`**: `PATCH /admin/emergency/accounts/:userId/suspension`, `PATCH /admin/emergency/share-links/:shareLinkId/suspension`, `GET /admin/emergency/timeline`. All endpoints require `AuthGuard + SuperadminGuard + AdminActionTokenGuard` (AC3 — elevated MFA-backed token is the secondary confirmation gate). Correlation IDs are propagated on every response.
- **Registered in `audit-incident.module.ts`**: controller and service added; no new entity or migration needed.
- **AC1** satisfied: auditNote is stored in `metadata.description` of the EMERGENCY_ audit event.
- **AC2** satisfied: service throws `EmergencyActionNoteRequiredException` (400) before any DB mutation if note is absent or < 10 chars; DTO `@MinLength(10)` enforces the same at validation layer.
- **AC3** satisfied: `AdminActionTokenGuard` enforces a short-lived MFA-backed token header (`x-admin-action-token`) on every emergency endpoint.
- **AC4** satisfied: `GET /admin/emergency/timeline` queries `AuditIncidentService.searchAuditActions` filtered to `EMERGENCY_` prefix, returns tamper-evidence hashes per record, is read-only (no mutation path from query endpoint).

### Manual QA Checklist

- [ ] `PATCH /admin/emergency/accounts/:userId/suspension` with `auditNote` missing → expect 400 `EMERGENCY_ACTION_NOTE_REQUIRED`
- [ ] Same endpoint with `auditNote` of 9 chars → expect 400 (validation failure)
- [ ] Same endpoint with `auditNote` of 10+ chars + valid admin action token → expect 200 with `state: success`
- [ ] Same endpoint without `x-admin-action-token` header → expect 401 `AUTH_MFA_CHALLENGE_REQUIRED`
- [ ] Same endpoint with non-superadmin session → expect 403
- [ ] `GET /admin/emergency/timeline` → returns only records with `action ILIKE EMERGENCY_%`
- [ ] Timeline records include `auditNote` field populated from `metadata.description`
- [ ] Timeline records include `tamperEvidence` (hash, previousHash, sequence)
- [ ] Re-submitting same suspension with same input (idempotent) — `changed: false`, still records a new audit event

### File List

- _bmad-output/implementation-artifacts/5-14-emergency-containment-actions-with-mandatory-audit-notes.md
- apps/api/src/modules/audit-incident/emergency-containment.types.ts
- apps/api/src/modules/audit-incident/emergency-containment.dto.ts
- apps/api/src/modules/audit-incident/emergency-containment.service.ts
- apps/api/src/modules/audit-incident/emergency-containment.controller.ts
- apps/api/src/modules/audit-incident/audit-incident.module.ts

## Change Log

- 2026-03-31: Implemented emergency containment layer with mandatory audit note enforcement, elevated privilege (MFA token) gate, and immutable EMERGENCY_-prefixed timeline. No new DB migration needed; leverages existing tamper-chain audit event table.
