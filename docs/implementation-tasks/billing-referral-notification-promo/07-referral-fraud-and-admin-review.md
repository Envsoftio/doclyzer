# Task 07: Referral Fraud and Admin Review

## Objective

Add referral fraud checks, review states, admin-safe release/block behavior, and audit trails so rewards can be controlled without double-crediting users.

## PRD Coverage

- RR-10 through RR-12
- RR-25 through RR-29
- Business rules

## Primary Areas

- `apps/api/src/modules/referrals`
- `apps/api/src/modules/billing`
- Future notification/device token module
- `apps/api/src/database`

## Implementation Checklist

- Add referral fraud evaluation service.
- Add disposable email domain denylist/config.
- Add self-referral checks.
- Add same-normalized-email checks.
- Add same-device or installation-id overlap checks after Task 09.
- Add safe payment metadata overlap checks where RevenueCat/Google Play payloads allow it.
- Add referral review statuses: `pending`, `released`, `blocked`, `under_review`.
- Add admin API to list referral review queue.
- Add admin API to get referral detail.
- Add admin API to block referral.
- Add admin API to release eligible held reward.
- Add admin API to mark referral under review.
- Ensure admin release is idempotent.
- Ensure admin release does not bypass monthly cap unless explicitly configured.
- Write audit event for every admin action.
- Add operational summaries for blocked, capped, and review referrals.

## Acceptance Criteria

- Disposable email invitee is blocked or placed under review by policy.
- Same-user and same-email self-referral attempts are blocked.
- Same-device referrals are blocked or reviewed after device data exists.
- Admin can block a referral and future rewards do not release automatically.
- Admin can release an eligible held reward once.
- Repeated admin release does not duplicate credits.
- Audit history shows fraud decision, admin actor, reason, and timestamp.

## Tests

- Unit test disposable domain detection.
- Unit test normalized email matching.
- Unit test admin block transition.
- Unit test admin release idempotency.
- Integration test blocked referral prevents milestone A and B.
- Authorization test non-superadmin cannot mutate review status.

## Dependencies

- Task 03 referral data model.
- Task 04 referral apply.
- Task 05 and Task 06 reward flows.
- Task 09 for device overlap checks.

## Out of Scope

- Superadmin UI. See Task 14.
