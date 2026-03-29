# Spike: Story 5.17 – Superadmin System Dashboard Contracts & UX

Status: backlog

## Purpose
Define the API contract surface and preliminary UI/UX structure for the Complete Superadmin System Dashboard (Story 5.17). This spike will unblock the backlog story by delivering precise contract definitions plus a wireframe brief so backend aggregation and UI implementation can proceed with alignment.

## Deliverables
1. **Contract catalog** for each telemetry slice (users, activity, payments, files/reports, governance signals, incident panel, exports) detailing endpoint, method, headers, query params, response envelope, and audit expectations. Contract states include `pending`, `success`, `failure` (and `reverted` where applicable) to mirror existing stub patterns.
2. **Stub responses** (JSON fixtures) to seed `apps/web/server/api/admin` endpoints, enabling the dashboard UI to show data-rich states during backend rollout.
3. **UI/UX wireframe brief** describing the dashboard layout, filters, widget states, incident/opportunity panel, and export/PHI guardrails so designers/developers can work against a clear blueprint.
4. **Next steps checklist** for backend aggregation and UI implementation once the contracts + wireframes are reviewed.

## Contract Catalog (draft)
| Slice | Endpoint | Method | Headers | Query Params | Response Envelope | Notes |
|---|---|---|---|---|---|---|
| User & Org Summary | `/admin/analytics/users` | GET | `X-Admin-Action-Token`, `Authorization: Bearer <token>` | `startDate`, `endDate`, `region`, `productSlice` | `{ state: 'pending|success|failure', data: { totalAccounts, activeUsers, accountsByTier: [{tier,count}], newSignups, churn }, statsId }` | Include `statsId` for audit correlation; `pending` returns `message`/`eta` while backend warms cache. |
| Activity Trends | `/admin/analytics/activity` | GET | `X-Admin-Action-Token` | `startDate`, `endDate`, `region`, `productSlice`, `seriesGranularity=hour|day` | `{ state: 'success', data: { logins: [ { timestamp, count } ], uploads: [...], shareLinks: [...], anomalies: [...] } }` | Provide `chartHint` for UI; `failure` returns `codes` and `details`. |
| Payments & Revenue | `/admin/analytics/payments` | GET | `X-Admin-Action-Token` | `startDate`, `endDate`, `region`, `productSlice`, `paymentType=credit|subscription|refund` | `{ state: 'success', data: { creditPackSales, subscriptionRevenue, refunds, invoices, paymentStatusBuckets }, totals }` | Totals include `mr`, `arr`, `revenueChangePct`. Use same envelope for exports. |
| File/Report Inventory | `/admin/analytics/files` | GET | `X-Admin-Action-Token` | `startDate`, `endDate`, `region`, `productSlice`, `status=queued|processing|succeeded|failed` | `{ state: 'success', data: { totalFiles, queued, processing, succeeded, failed, avgProcessingTime, worstAgents } }` | Provide sample `reportSamples` list for drill-down linking to `/admin/reports`. |
| Governance Signals | `/admin/analytics/governance` | GET | `X-Admin-Action-Token` | `startDate`, `endDate`, `region`, `productSlice`, `signalType=restrictions|audits|reviews` | `{ state: 'success', data: { protectiveRestrictions, auditSpikeCount, suspiciousActivityScore, reviewQueueCounts } }` | Each signal includes `trend` and `alertLevel`. |
| Incident/Opportunity Panel | `/admin/analytics/incidents` | GET | `X-Admin-Action-Token` | `startDate`, `endDate`, `region`, `productSlice`, `severity=critical|warning|info` | `{ state: 'success', data: { incidents: [ { id, title, description, severity, linkedQueues: [reviewQueue, incidentDocs], recommendedActions } ], correlationId } }` | `recommendedActions` link to review queue, account workbench, or protective restriction creation. |
| Export manifest | `/admin/analytics/exports/:slice` | POST | `X-Admin-Action-Token` | `slice=users|activity|payments|files|governance`, `format=csv|json`, filters same as GET | `{ state: 'pending|success|failure', exportId, downloadUrl? }` | Export response omits PHI, tag `exportId` for audit entry. |

### Stub Fixtures
Create files under `apps/web/server/api/admin/system-dashboard-*.get.ts` (or extend existing contract files) returning the above envelope structures with sample numeric data for positive path; include `state: 'pending'` variant for loading states and `state: 'failure'` with error codes (e.g., `API_RATE_LIMIT`, `AUTHZ_SUPERADMIN_REQUIRED`).

## UI/UX Wireframe Brief
1. **Layout:** Full-width dashboard with a top filter bar (date range picker, region dropdown, product slice chip group) above a scrollable grid.
   - **Summary tiles** (total accounts, active users, payment total, refunds) across two columns.
   - **Charts section**: two-row grid with activity trends chart (line with logins/uploads/share) and payments/revenue stacked area.
   - **Inventory & Governance row**: left column shows file/report inventory table with status chips and top failing agents; right column shows governance alerts (protective restrictions, audit spikes, review queue counts).
   - **Incident/Opportunity panel**: horizontal cards listing incidents with severity badges and recommended actions.
2. **Widget states:** Each widget handles `pending` (skeleton with “refreshing”), `success` (data), and `failure` (inline error + retry). Add “Export” button that opens format menu (CSV/JSON) and shows audit info after completion.
3. **Filters:** Changing filters re-fetches all slices; show active filter chips with “clear all.” Provide `Last 24h`, `Last 7d`, `Custom` presets.
4. **Drill-down cues:** Each widget provides tooltip/link to detail view (e.g., “Open reports list” linking to `/admin/reports`, “View payment ledger”). Incident action buttons open review queue or protective restriction flows.
5. **PHI/audit notes:** Banner reminding “PHI-safe view: account IDs only. All exports audited.” Each export triggers visual confirmation with audit reference (from contract). Include MFA/`X-Admin-Action-Token` guard mention near filters.

## Next Steps Post-Spike
- Peer review contract catalog + fixtures; update `apps/web/server/api/admin` stubs accordingly.
- Review wireframes with PM/designer and refine companion UX copy (filters, incidents, compliance notes). Convert to Figma/wireframe if needed.
- Once approved, start backend aggregation work per Task 2 of Story 5.17 and begin building the UI page per Task 3.

