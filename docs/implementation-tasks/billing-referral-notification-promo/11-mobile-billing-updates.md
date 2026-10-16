# Task 11: Mobile Billing Updates

## Objective

Update Flutter billing checkout to support zero-amount promo checkout, richer order status polling, and clearer pending/reconciled/failed/review states.

## PRD Coverage

- MR-6 through MR-8
- BR-9
- PR-10 through PR-11

## Primary Areas

- `apps/mobile/lib/features/billing`
- `apps/mobile/lib/features/entitlements`
- `apps/mobile/lib/core/network`

## Implementation Checklist

- Update billing API models for zero-amount checkout result.
- Add model states for payment pending, client purchase confirmed, webhook pending, reconciled, failed, and pending review.
- Skip Google Pay/RevenueCat purchase sheet when API returns zero final amount.
- Show immediate success state for zero-amount promo checkout.
- Poll order status after RevenueCat/Google Pay purchase success.
- Stop polling on reconciled, failed, or pending review.
- Show pending webhook state after client purchase confirmation.
- Show failed state with retry/support guidance.
- Show pending review state with support-oriented message.
- Refresh entitlement summary after reconciled or zero-amount success.
- Improve promo validation failure copy for expired, inactive, total cap, per-user cap, wrong pack/plan, and minimum amount issues.

## Acceptance Criteria

- Valid zero-amount promo checkout grants credits without opening Google Pay or RevenueCat purchase flow.
- Paid checkout still opens Google Pay/RevenueCat purchase flow normally.
- After RevenueCat/Google Pay purchase success, mobile waits for status confirmation before showing credits as added.
- User sees pending state while webhook reconciliation is pending.
- User sees updated credits after reconciliation.
- Failed order displays clear failure message.
- Pending review order displays support-oriented message.
- Promo error reasons are user-readable.

## Tests

- Widget test zero-amount success path.
- Widget test paid pending/reconciled/failed states.
- Repository test order status parsing.
- Manual QA with RevenueCat sandbox and Google Pay test flow.
- Manual QA duplicate app resume/status refresh.

## Dependencies

- Task 01 order status endpoint.
- Task 02 zero-amount promo API behavior.

## Out of Scope

- Promo admin management. See Task 13.
- Referral mobile screens. See Task 10.
