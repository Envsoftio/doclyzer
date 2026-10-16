# Task 02: Promo Code Parity Improvements

## Objective

Bring promo codes to parity with the reference flow by adding percentage max discount caps, clean zero-amount checkout behavior, and robust promo lifecycle tracking.

## PRD Coverage

- PR-1 through PR-14
- BR-8, BR-11, BR-12
- Promo acceptance criteria

## Primary Areas

- `apps/api/src/modules/billing`
- `apps/api/src/database`
- `apps/api/src/modules/entitlements`
- `apps/api/src/common/notification-pipeline`

## Implementation Checklist

- Add optional `max_discount_amount` or equivalent for percentage promos.
- Update promo validation to apply max discount cap.
- Return validation response with original amount, discount amount, final amount, currency, promo id, promo label, and invalid reason.
- Keep validation non-consuming.
- Keep reservation at order creation.
- Keep final redemption only after paid reconciliation or zero-amount checkout.
- Add zero-amount checkout path.
- Avoid Google Pay/RevenueCat purchase flow when final amount is zero.
- Create auditable internal order for zero-amount checkout.
- Mark zero-amount promo redemption as redeemed.
- Grant zero-amount checkout credits immediately through entitlement service.
- Enqueue promo/billing receipt email.
- Return clear errors for expired, inactive, capped, wrong-pack, wrong-plan, and per-user-capped promos.
- Release or void reservations for failed, expired, or abandoned orders.
- Update analytics to distinguish validation, reservation, redeemed, failed, and voided states.

## Acceptance Criteria

- Percentage promo with max cap never discounts beyond configured cap.
- Promo validation does not increase redemption usage.
- Promo reservation does not count as final redemption.
- Paid promo order redeems only after webhook reconciliation.
- Zero-amount promo order grants credits without Google Pay or RevenueCat purchase flow.
- Zero-amount promo order appears in order history and admin billing data.
- Duplicate zero-amount checkout does not grant duplicate credits.
- Promo analytics show correct lifecycle counts.

## Tests

- Unit test flat discount, percentage discount, capped percentage discount, and final amount floor.
- Integration test zero-amount checkout grants credits once.
- Integration test paid checkout reserves then redeems on webhook.
- Integration test payment failure voids reservation.
- Integration test per-user usage cap.

## Dependencies

- Existing billing module.
- Existing promo entities.
- Existing entitlement service.
- Task 01 if shared order state names are changed.

## Out of Scope

- Admin promo UI. See Task 13.
- Mobile zero-amount checkout UX. See Task 11.
