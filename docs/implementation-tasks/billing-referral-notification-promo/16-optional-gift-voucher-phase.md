# Task 16: Optional Gift Voucher Phase

## Objective

Optionally add secure gift voucher functionality after core billing, promo, referral, email, and notification tasks are stable.

## PRD Coverage

- Optional gift voucher scope GV-1 through GV-6

## Primary Areas

- `apps/api/src/modules/gift-vouchers`
- `apps/api/src/modules/entitlements`
- `apps/api/src/common/notification-pipeline`
- `apps/mobile/lib/features/gift_vouchers`
- `apps/web/pages`

## Implementation Checklist

- Add voucher entity.
- Add voucher event entity.
- Add optional voucher order entity only if online purchase is included.
- Store voucher code hash for lookup.
- Show plaintext voucher code only once at creation.
- Add statuses: `active`, `redeemed`, `voided`, `expired`.
- Add admin voucher generation.
- Add admin voucher voiding.
- Add admin expiry update.
- Add voucher redemption endpoint.
- Add mobile voucher redemption screen.
- Grant credits through `EntitlementsService`.
- Add voucher email templates if delivery/resend is supported.
- Add voucher audit events.

## Acceptance Criteria

- Superadmin can generate voucher and see plaintext code once.
- Voucher lookup uses hash and does not require storing plaintext code.
- User can redeem active voucher once.
- Redeeming voucher grants credits once.
- Expired, voided, or already redeemed voucher cannot be redeemed.
- Admin actions are audited.

## Tests

- Unit test voucher code hashing and lookup.
- Unit test redeem idempotency.
- Integration test active voucher redemption grants credits once.
- Integration test expired/voided/redeemed rejection.
- Admin authorization tests.

## Dependencies

- Existing entitlement service.
- Task 08 if voucher emails are required.
- Task 13 or a new admin page task if voucher admin UI is included.

## Out of Scope

- Online purchased gift vouchers by default.
- Scheduled delivery/resend unless explicitly added as a follow-up task.

