# Task 04: Referral Apply and Invitee Bonus

## Objective

Allow a new user to apply a referral code during signup or onboarding, hold the invitee reward until email verification, and release the invitee bonus idempotently after verification.

## PRD Coverage

- RR-8 through RR-16
- RR-30 through RR-32
- ER-4, ER-5

## Primary Areas

- `apps/api/src/modules/referrals`
- Auth/signup module
- `apps/api/src/modules/entitlements`
- `apps/api/src/common/notification-pipeline`

## Implementation Checklist

- Add referral apply service method.
- Add authenticated endpoint to apply referral code during onboarding.
- Add signup payload support for optional referral code if current auth flow allows it.
- Validate referral code exists and is active.
- Reject self-referral.
- Reject users who already applied a referral.
- Validate invitee and referrer eligibility.
- Create referral log with pending invitee bonus event.
- Return clear API errors for invalid, self, and already-used referral codes.
- Hook email verification event to release pending invitee bonus.
- If no direct hook exists, add idempotent release check after login/profile refresh when `email_verified` becomes true.
- Grant invitee credits through `EntitlementsService`.
- Write referral audit events for apply, block, and release.
- Enqueue invitee bonus released email.
- Dispatch push event if Task 09 exists; otherwise no-op safely.

## Acceptance Criteria

- User can apply a valid referral code once.
- User cannot apply their own referral code.
- User cannot apply multiple referral codes.
- Invalid referral code returns clear error.
- Invitee receives no credits before email verification.
- Invitee receives credits once after email verification.
- Re-running verification release does not duplicate credits.
- Referral log and reward event show correct pending/released state.

## Tests

- Unit test valid referral apply.
- Unit test self-referral rejection.
- Unit test duplicate apply rejection.
- Unit test missing/invalid code.
- Integration test email verification releases invitee bonus once.
- Integration test repeated release call is idempotent.

## Dependencies

- Task 03 referral data model.
- Existing auth/email verification flow.
- Existing entitlement service.
- Task 08 for final email template content.

## Out of Scope

- Referrer milestone rewards. See Tasks 05 and 06.
- Device fraud checks. See Task 07.

