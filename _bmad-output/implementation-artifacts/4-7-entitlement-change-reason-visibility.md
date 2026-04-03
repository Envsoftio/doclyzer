# Story 4.7: Entitlement Change Reason Visibility

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As an authenticated user,
I want to see why my entitlement changed and when,
so that billing and access changes are transparent and trustworthy.

## Acceptance Criteria

1. **Reason + timestamp visibility:** Given a user’s entitlement changes (plan upgrade/downgrade, credit pack applied, admin adjustment, system reconciliation), when the user opens Plan & Credits, then the latest entitlement change reason and timestamp are visible in a calm, user-friendly summary.
2. **API contract exposure:** Given the client requests entitlement summary, when the API responds, then the response includes deterministic fields for `lastChangeReason` and `lastChangeAt` (ISO string) sourced from persisted entitlement-change data and aligned with the backend lifecycle rules.
3. **Graceful empty state:** Given no prior entitlement change events beyond initial provisioning, when the user opens Plan & Credits, then the UI shows a sensible default (e.g., “Initial entitlement” or “Not yet changed”) without errors or PHI leakage.

## Tasks / Subtasks

- [x] **Task 1: Persist entitlement change reason + timestamp** (AC: #1, #2)
  - [x] Add a durable place for the latest entitlement change reason and timestamp (prefer explicit columns on `user_entitlements` or a small `entitlement_change_events` table with a “latest” query path) and create the migration in `apps/api/src/database/migrations/`.
  - [x] Update entitlement mutation flows to set reason + time: auto-provision free plan, credit pack reconciliation, subscription upgrades/downgrades, and any admin/manual adjustments in the entitlements/billing modules.
  - [x] Use a controlled reason enum or label set (e.g., `initial_provision`, `credit_pack_purchase`, `subscription_upgrade`, `plan_downgrade`, `admin_adjustment`, `system_reconciliation`) and keep it PHI-safe.

- [x] **Task 2: Expose entitlement change fields in API** (AC: #2)
  - [x] Extend `EntitlementSummaryDto` in `apps/api/src/modules/entitlements/entitlements.types.ts` to include `lastChangeReason` and `lastChangeAt`.
  - [x] Update `EntitlementsService.getEntitlementSummary()` to populate the new fields from the persisted data.
  - [x] Ensure response envelopes, error codes, and correlation IDs follow the standard API contract.

- [x] **Task 3: Show entitlement change reason on mobile** (AC: #1, #3)
  - [x] Extend Flutter `EntitlementSummary` model + API parsing to include `lastChangeReason` and `lastChangeAt`.
  - [x] Update `entitlement_summary_screen.dart` to display a concise “Last change” row near the credit balance/status section (e.g., “Last change: Credit pack purchase · 2026-04-02 17:00”).
  - [x] Ensure Material 3 styling and calm tone; do not add new navigation paths.

- [x] **Task 4: Guardrails + consistency checks** (AC: #1–#3)
  - [x] Validate required params in any new endpoints or query handling per project rules (avoid missing filters).
  - [x] Confirm the change reason text is PHI-safe and does not expose user identifiers or report content.

## Dev Notes

- **Architecture guardrails:** This is a billing/entitlements concern. Keep data changes and query logic inside the entitlements/billing modules and do not leak PHI in analytics, logs, or UI strings. Enforce deterministic state transparency (Architecture ADRs).
- **Existing patterns:** Story 4.6 added billing order status history and UI status chips. Reuse the same Plan & Credits screen patterns and API envelope style rather than inventing new UI flows. [Source: `_bmad-output/implementation-artifacts/4-6-billing-outcome-states-pending-failed-reconciled.md`]
- **Project context rules:** Follow TypeORM Data Mapper conventions, ConfigService usage, and error code patterns. **Testing policy: skip tests** (no Jest / Flutter tests). [Source: `_bmad-output/project-context.md`]
- **API contract:** All success responses must use `successResponse(data, correlationId)`; all errors should flow through `ApiExceptionFilter` with structured error codes.
- **UX guidance:** Maintain calm, professional copy; user-facing reason text should explain the change without exposing PHI. [Source: `_bmad-output/planning-artifacts/ux-design-specification.md`]

### Project Structure Notes

- Backend changes: `apps/api/src/modules/entitlements`, `apps/api/src/modules/billing`, and `apps/api/src/database/entities` + `apps/api/src/database/migrations`.
- Flutter changes: `apps/mobile/lib/features/billing/billing_repository.dart`, `apps/mobile/lib/features/billing/api_billing_repository.dart`, `apps/mobile/lib/features/billing/screens/entitlement_summary_screen.dart`.
- Do not add new directories; extend existing modules and DTOs in place.

### Latest Technical Information (as of 2026-04-02)

- **NestJS:** Latest release reported as `v11.1.11` (Dec 29, 2025). Keep NestJS usage consistent with current repo patterns (controllers thin, services encapsulate logic). citeturn1search3
- **TypeORM:** Latest release reported as `0.3.28` (Dec 3, 2025). Keep TypeORM Data Mapper patterns; use migrations for schema changes. citeturn0search2
- **Flutter:** Latest stable release listed as `3.41` (Feb 11, 2026). Maintain Material 3 usage and existing app patterns. citeturn0search10

### References

- [Source: `_bmad-output/planning-artifacts/epics.md#Story 4.7: Entitlement Change Reason Visibility`]
- [Source: `_bmad-output/planning-artifacts/prd.md#FR51 Users can view current plan/credit entitlements and the latest entitlement change reason`]
- [Source: `_bmad-output/planning-artifacts/architecture.md#Architecture Context ADR Baselines / Data Boundaries / State Transparency`]
- [Source: `_bmad-output/project-context.md#Critical Implementation Rules & Dev Agent Testing Policy`]
- [Source: `_bmad-output/implementation-artifacts/4-6-billing-outcome-states-pending-failed-reconciled.md`]
- [Source: `apps/api/src/modules/entitlements/entitlements.service.ts`]
- [Source: `apps/api/src/modules/entitlements/entitlements.types.ts`]
- [Source: `apps/mobile/lib/features/billing/screens/entitlement_summary_screen.dart`]
- [Source: `_bmad-output/planning-artifacts/ux-design-specification.md`]

## Dev Agent Record

### Agent Model Used

GPT-5 (Codex)

### Debug Log References

### Completion Notes List
- Implemented entitlement change reason + timestamp persistence on `user_entitlements` with migration and service updates across provisioning, credit reconciliation, and plan upgrades/downgrades.
- Exposed `lastChangeReason` / `lastChangeAt` in entitlement summaries and surfaced a calm “Last change” row in Plan & Credits.
- Tests skipped per project testing policy.
- Code review fix: `findOrProvision` reload now passes explicit `relations: ['plan']` as belt-and-suspenders over `eager: true`, preventing a potential null crash on first-ever entitlement creation.

### Review Follow-ups (AI)
- [ ] [AI-Review][LOW] `_buildLastChangeLine` shows “Last change: Not yet changed” when both fields are null (legacy entitlement). Consider hiding the row entirely or using “No entitlement changes yet.” for better UX. [entitlement_summary_screen.dart:505-511]

### File List
- apps/api/src/database/entities/user-entitlement.entity.ts
- apps/api/src/database/migrations/1730816200000-AddEntitlementChangeReasonToUserEntitlements.ts
- apps/api/src/database/migrations/index.ts
- apps/api/src/modules/billing/billing.service.ts
- apps/api/src/modules/entitlements/entitlements.service.ts
- apps/api/src/modules/entitlements/entitlements.types.ts
- apps/mobile/lib/features/billing/api_billing_repository.dart
- apps/mobile/lib/features/billing/billing_repository.dart
- apps/mobile/lib/features/billing/screens/entitlement_summary_screen.dart

### Change Log
- Updated entitlement change reason/timestamp persistence and surfaced last change in Plan & Credits. (Date: 2026-04-02)
- 2026-04-03: Code review fix — explicit relations: ['plan'] on findOrProvision reload.
