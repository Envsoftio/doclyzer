# Story 5.17: Complete Superadmin System Dashboard

Status: backlog

## Story

As a superadmin,
I want one cohesive dashboard that surfaces every operational surface—users and their activity, payments, files, reports, alerts, and governance signals—so that I can trustingly operate, monitor, and act on the whole system from a single plane.

## Acceptance Criteria

1. Given a MFA-authenticated superadmin with an admin action token, when they open the system dashboard, then they can see connected widgets for user/organization counts, login/activity trends, payment/revenue roll-ups (credit packs, subscriptions, refunds, invoices), file and report inventories (queued, processing, succeeded, failed), and governance signals (alerts, audit trend spikes, protective restrictions). All widgets support consistent filtering (date range, region, product slice) and tooltip detail links.
2. Given any filter or drill-down, when the superadmin applies it, then the backend honors the request, the dashboard refreshes with PHI-safe data, and each request is emits an audit event (actor/action/target/outcome) so analytics access remains traceable.
3. Given an operational incident (e.g., upload job failures, suspicious activity spikes, protective restriction creation), when the superadmin inspects the incident/opportunity panel, then correlated insights (queue status anomalies, review queue counts, incident notes) and recommended next steps (link to review queue, account workbench, or protective actions) are surfaced.
4. Given exports are requested (CSV/JSON), when data is generated, then it omits PHI and includes audit metadata; any export triggers the same admin action token validation.

## Tasks / Subtasks

- [ ] Task 1: Define API-first contracts for every insight area (user metrics, activity streams, payment/revenue intensity, file/report inventory, governance signals, incident panel). Document query parameters (date ranges, product/region slices, pagination), required `X-Admin-Action-Token`, and response envelopes (states: pending/success/failure) so the UI can render stubs during backend rollout.
- [ ] Task 2: Build backend aggregation layers: extend analytics modules to expose `/admin/analytics/users`, `/admin/analytics/activity`, `/admin/analytics/payments`, `/admin/analytics/files`, `/admin/analytics/reports`, `/admin/analytics/governance`, and incident correlation endpoint. Apply caching, pagination, PHI-safe sanitization, and tie each call to audit logging and rate limits.
- [ ] Task 3: Implement the dashboard UI/UX in `apps/web/app/pages/admin/system-dashboard` (or similar), wiring widgets to the contracts, showing summaries, charts, queue tables, and compliance banners. Provide filtering controls (date, geography, product slice) and incident/policy call-outs. Stub states should fall back to “check back soon” messaging until backend data is available.
- [ ] Task 4: Harden governance: route all UI/contract calls through MFA+admin action token guards, ensure audit events (actor, action, target, request id, outcome) are persisted, and confirm exports and detail drill-downs remain PHI-safe per PRD.

## Dev Notes

- The dashboard depends on analytics modules under `apps/api/src/modules/analytics-admin` and governance modules (`audit-incident`, `analytics-governance`). Use existing service patterns (services + query builders) to assemble metrics.
- UI will live under `apps/web/app/pages/admin` (or `apps/web/pages/admin`). Follow existing stub pattern and reuse contract stub endpoints (`/api/admin/...-contracts`). Build new contract files under `apps/web/server/api/admin` for the dashboard if needed.
- Respect non-PHI policy: no patient or clinical report identifiers may surface outside approved dashboards (use account ids/aliases). Filtered exports must be sanitized.
- Provide documentation links back to the product brief section on superadmin dashboard expectations (especially plan table, promo management, analytics) so PMs and security reviewers can verify scope.

### References

- [Source: _bmad-output/planning-artifacts/product-brief-doclyzer-2026-03-01.md#Superadmin dashboard (v1)]
- [Source: _bmad-output/planning-artifacts/epics.md#Story 5.17: Complete Superadmin System Dashboard]

