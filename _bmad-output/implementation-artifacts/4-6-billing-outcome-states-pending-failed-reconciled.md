# Story 4.6: Billing Outcome States (Pending/Failed/Reconciled)

Status: ready-for-dev

## Story

As an authenticated user,
I want clear billing lifecycle states,
so that payment outcomes are understandable.

## Acceptance Criteria

1. **Plan & Credits & order history display:** Given one or more credit pack orders exist, the Plan & Credits screen surfaces the three most recent orders with the Razorpay order id, friendly status label (Pending payment / Failed / Reconciled), final amount, and timestamp so users can always see whether a purchase is still under review, failed, or has been reconciled, mirroring FR47’s “visible billing outcome” requirement and the `orders.status` column (`pending` | `failed` | `reconciled`) defined in `apps/api/src/database/entities/order.entity.ts`.
2. **Payment failure guidance:** Given the webhook marks an order `failed`, the order history row immediately shows “Payment failed” (with the Razorpay reason when available), surfaces a Retry/Return to checkout CTA, stops any duplicate credit topping, and lets the user open the Credit Pack checkout again using the existing Razorpay flow plus the limit guard introduced in story 4.5 so failed attempts do not credit twice (`apps/api/src/modules/billing/billing.service.ts#handleWebhookPaymentFailed`).
3. **Pending/reconciliation transparency:** Given an order is still `pending` or `paid` before the capture webhook reconciles it, the UI shows a status such as “Payment pending – awaiting Razorpay capture,” disables duplicate checkout buttons, and offers a “Refresh status” action that polls the new order-status endpoint so users know the backend is waiting for the captured event that eventually sets the row to `reconciled` and `credited` (`billing.service.ts#handleWebhookPaymentCaptured`).
4. **Status data contract:** The billing API exposes the user’s recent orders (status, final amount, Razorpay ids, credited flag) via a new `GET /billing/orders` (or equivalent) endpoint/DTO so Flutter can keep the status badges in sync; this contract must keep `OrderStatus` values (`pending`, `failed`, `reconciled`, `paid`) in sync with the DB/state machine described in `apps/api/src/modules/billing/billing.types.ts`.

## Tasks / Subtasks

- [ ] **Task 1: Extend the billing module to serve recent order statuses and reason data**
  - [ ] Capture the last 3–5 credit pack orders for the current user from `OrderEntity`, include `status`, `finalAmount`, `credited`, `razorpayOrderId`, `updatedAt`, and any `metadata.reason` in a new DTO (e.g., `OrderStatusDto`).
  - [ ] Add a `GET /billing/orders` (or augment `EntitlementSummaryDto`) in `BillingController` that returns that DTO and keep the route guarded by `AuthGuard`.
  - [ ] Update `billing.service.ts` to fetch this data via the order repository and to keep the returned status labels aligned with `handleWebhookPaymentCaptured` / `handleWebhookPaymentFailed` transitions so reconciled/failed states are never overwritten.

- [ ] **Task 2: Wire the new data through the API layer**
  - [ ] Update `billing.types.ts` with the new DTO, swagger-friendly transformation helpers, and ensure error codes (e.g., `BILLING_ORDER_NOT_FOUND`) stay centralized.
  - [ ] Keep TypeORM data mapper conventions (no `process.env` inside modules, use `@InjectRepository`) and reuse the existing `entitlementsService.getEntitlementSummary` wherever the credited balance should refresh after reconciliation.

- [ ] **Task 3: Add new billing status data to the mobile repository**
  - [ ] Extend `BillingRepository` + `ApiBillingRepository` to fetch the new order statuses (method like `listRecentOrders` or `getOrderStatuses`).
  - [ ] Decode `status` strings into an enum so UI components know when to show Pending (await capture), Failed (render reason + Retry), or Reconciled (credits added) without leaking Razorpay internals.

- [ ] **Task 4: Show statuses on the Plan & Credits summary screen**
  - [ ] Surface the recent order list (with status chip, human-friendly status text, Razorpay id truncated to 8 chars, amount, timestamp) in `entitlement_summary_screen.dart` below the limit cards; include CTA buttons for “Refresh status,” “Retry payment,” or “View receipt” depending on the status and keep the rest of the screen scrollable.
  - [ ] Reuse the existing `DoclyzerApp` navigation (`onUpgrade`, `onBuyCredits`) so the new CTAs reuse the billing flow and never duplicate navigation logic.

- [ ] **Task 5: Guard the credit pack checkout with status awareness**
  - [ ] During checkout in `credit_pack_list_screen.dart`, show inline banners when the pending order is still waiting for Razorpay (disable `Buy` while `_purchasingPackId == order.id` and show a spinner + “Awaiting capture”), and when a failure occurs keep the `Retry` action visible (call `widget.onPurchaseComplete` only after `verifyPayment` returns a reconciled state).
  - [ ] When the order becomes `reconciled`, call the new status endpoint to refresh the pending list so the “Credits added” badge replaces the spinner immediately.

## Dev Notes

- **Architecture guardrails:** Keep billing/entitlements isolated (per Architecture ADRs), so the new order-status query lives inside the billing module and only talks to `OrderEntity`/`EntitlementsService`. Any UI copy referencing “Pending payment,” “Reconciled,” or “Failed” must tie back to the deterministic lifecycle states described in `_bmad-output/planning-artifacts/architecture.md` (Domain Separation + State Transparency contracts) and must never reference PHI or user ids.
- **Project context:** Follow `_bmad-output/project-context.md` for TypeORM injection, error-code constants, and testing policy (manual QA only; do not add Jest or flutter tests for this story).
- **UX reminder:** Align statuses with the user-facing mental model—per `ux-design-specification.md`, every status must explain what to expect (“waiting for capture”, “retry or contact support”, “credits already added”) and keep the tone calm/professional. Maintain Material 3 theming + k-extension key conventions for new widgets.
- **Testing policy:** Story implementation is strictly production code; skip unit/integration/widget tests per the Dev Agent Testing Policy, but document manual QA steps (refresh entitlement summary + promo flow) so future testers know what to validate.

### Project Structure Notes

- Backend changes live under `apps/api/src/modules/billing` (controller, service, types) plus the shared `entitlements` module for refreshing credit balances (per project-context rules about module exports, repository injection, and ConfigService usage).
- Flutter screens live under `apps/mobile/lib/features/billing/screens`; keep callbacks declarative (passing `onUpgrade`, `onPurchaseComplete`) and reuse existing repositories (`ApiBillingRepository`, `BillingRepository`).
- No new directories should be created—add helpers next to existing service/controller files and extend DTOs in the same `billing` module.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 4.6: Billing Outcome States (Pending/Failed/Reconciled)]
- [Source: _bmad-output/planning-artifacts/prd.md#FR47 Users can see the outcome of billing actions and entitlement updates in pending, failed, and reconciled states]
- [Source: apps/api/src/database/entities/order.entity.ts#status field definitions]
- [Source: apps/api/src/modules/billing/billing.service.ts#handleWebhookPaymentCaptured & handleWebhookPaymentFailed]
- [Source: apps/api/src/modules/billing/billing.types.ts#OrderStatus type & DTO definitions]
- [Source: _bmad-output/planning-artifacts/architecture.md#Architecture Context ADR Baselines / Data Boundaries (ensure billing domain isolation)]
- [Source: _bmad-output/project-context.md#Critical Implementation Rules & Dev Agent Testing Policy]
- [Source: apps/mobile/lib/features/billing/screens/entitlement_summary_screen.dart & credit_pack_list_screen.dart]
- [Source: ux-design-specification.md#Experience Principles / Core User Experience (status transparency & calm tone)]

## Dev Agent Record

### Agent Model Used

GPT-5 (Codex)

### Debug Log References

None.

### Completion Notes List

- Captured the need for a deterministic billing state machine so Pending/Failed/Reconciled labels cannot drift from the Order table.
- Documented the API contract (status DTO + endpoint) that Flutter screens will poll so the UI always shows the latest Razorpay outcome.
- Highlighted the UX scenario (Plan & Credits + credit pack checkout) where this information is critical and referenced the relevant files for context.
- Reinforced the no-tests policy while still asking for manual QA steps in the completion notes.

### File List

- `_bmad-output/implementation-artifacts/4-6-billing-outcome-states-pending-failed-reconciled.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
- `apps/api/src/modules/billing/billing.service.ts`
- `apps/api/src/modules/billing/billing.controller.ts`
- `apps/api/src/modules/billing/billing.types.ts`
- `apps/api/src/modules/entitlements/entitlements.service.ts`
- `apps/api/src/modules/entitlements/entitlements.controller.ts`
- `apps/mobile/lib/features/billing/api_billing_repository.dart`
- `apps/mobile/lib/features/billing/billing_repository.dart`
- `apps/mobile/lib/features/billing/screens/entitlement_summary_screen.dart`
- `apps/mobile/lib/features/billing/screens/credit_pack_list_screen.dart`
