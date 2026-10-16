# Task 01: Billing Reconciliation Hardening

Status: Done

## Objective

Harden credit pack payment reconciliation so paid credits are granted only after trusted RevenueCat webhook reconciliation, duplicate provider events are safe, payment mismatch cases are reviewable, and mobile can reliably poll order status after Google Pay/RevenueCat checkout.

## PRD Coverage

- BR-1 through BR-15
- ER-2, ER-5
- Billing acceptance criteria

## Primary Areas

- `apps/api/src/modules/billing`
- `apps/api/src/modules/entitlements`
- `apps/api/src/common/notification-pipeline`
- `apps/api/src/email/templates`
- `apps/api/src/database`

## Implementation Checklist

- [x] Add or confirm order states: `created`, `payment_pending`, `client_purchase_confirmed`, `webhook_pending`, `reconciled`, `failed`, `pending_review`.
- [x] Ensure client purchase confirmation from the RevenueCat SDK does not grant credits.
- [x] Ensure RevenueCat webhook reconciliation is the only paid-credit allocation trigger.
- [x] Persist RevenueCat event ids or equivalent idempotency keys.
- [x] Validate expected amount before credit allocation.
- [x] Validate expected currency before credit allocation.
- [x] Mark amount/currency mismatches as `pending_review`.
- [x] Prevent credit allocation for mismatched orders.
- [x] Dispatch ops alert for invalid RevenueCat webhook authorization/signature checks.
- [x] Dispatch ops alert for amount/currency mismatches.
- [x] Mark failed payment events as failed orders.
- [x] Release or void promo reservations for failed orders.
- [x] Add `GET /billing/orders/:orderId/status` or equivalent mobile-safe status endpoint.
- [x] Ensure users cannot inspect another user's order.

## Acceptance Criteria

- Successful Google Pay/RevenueCat purchase adds credits exactly once after RevenueCat webhook reconciliation.
- Replayed RevenueCat purchase webhook does not add duplicate credits.
- Client purchase confirmation without RevenueCat webhook reconciliation does not add credits.
- Amount mismatch prevents credit allocation and marks order pending review.
- Currency mismatch prevents credit allocation and marks order pending review.
- Invalid RevenueCat webhook authorization/signature does not mutate credits and creates an ops alert event.
- Failed payment changes order state and clears related promo reservation.
- Mobile can poll a single endpoint for current reconciliation state.

## Tests

- Unit test client purchase confirmation transitions.
- Unit test duplicate webhook idempotency.
- Unit test amount mismatch handling.
- Unit test currency mismatch handling.
- Integration test order create, client confirmation, RevenueCat webhook reconciliation, entitlement balance changed once.
- Integration test failed webhook releases promo reservation.
- Authorization test order status ownership.

## Dependencies

- Existing billing and order entities.
- Existing entitlement credit grant service.
- Existing notification pipeline.

## Out of Scope

- Superadmin billing UI. See Task 13.
- Mobile checkout UX. See Task 11.
