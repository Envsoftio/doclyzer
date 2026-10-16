# Task 06: Referral Milestone B

## Objective

Reward the referrer once when the invitee completes their first paid reconciled purchase, with optional amount-based reward tiers.

## PRD Coverage

- RR-20 through RR-27
- BR-2 through BR-4
- RR-31 through RR-32

## Primary Areas

- `apps/api/src/modules/billing`
- `apps/api/src/modules/referrals`
- `apps/api/src/modules/entitlements`
- `apps/api/src/common/notification-pipeline`

## Implementation Checklist

- Add referral milestone B trigger after paid order reconciliation.
- Exclude zero-amount promo-only orders by default.
- Check whether this is the invitee's first paid reconciled order.
- Calculate tier reward using referral policy.
- Require invitee email verified.
- Ensure milestone B was not previously released.
- Check blocked/review referral state.
- Check monthly reward cap.
- Grant referrer credits through `EntitlementsService`.
- Mark reward event released, capped, or blocked.
- Mark referral log milestone B released when successful.
- Write audit event.
- Enqueue referrer milestone B email.
- Dispatch push notification if Task 09 exists.

## Suggested Tier Inputs

- Use final paid order amount and currency.
- Store exact thresholds in referral policy config.
- Default tier names: tier 1, tier 2, tier 3.

## Acceptance Criteria

- First paid reconciled order releases milestone B reward to referrer.
- Zero-amount promo order does not release milestone B unless policy allows it.
- Duplicate webhook/order reconciliation does not release milestone B twice.
- Reconciled order by user without referral does nothing safely.
- Monthly cap prevents reward and records capped state.
- Tier reward amount is selected from policy.

## Tests

- Unit test tier calculation.
- Unit test zero-amount order exclusion.
- Unit test duplicate webhook/reconciliation idempotency.
- Integration test first paid order grants referrer credits once.
- Integration test second paid order does not grant another milestone B reward.

## Dependencies

- Task 01 billing reconciliation hardening.
- Task 03 referral data model.
- Task 04 referral apply.
- Task 08 email event/template for milestone B.

## Out of Scope

- Admin policy UI. See Task 14.
- Advanced payment-instrument overlap checks. See Task 07.

