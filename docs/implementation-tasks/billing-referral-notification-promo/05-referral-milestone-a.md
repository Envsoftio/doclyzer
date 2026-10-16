# Task 05: Referral Milestone A

## Objective

Reward the referrer once when the invitee completes their first successful meaningful Doclyzer product action.

## PRD Coverage

- RR-17 through RR-19
- RR-24 through RR-27
- RR-31 through RR-32

## Primary Areas

- `apps/api/src/modules/referrals`
- Report/document analysis completion module
- `apps/api/src/modules/entitlements`
- `apps/api/src/common/notification-pipeline`

## Recommended Milestone Definition

Milestone A should trigger on the invitee's first successfully processed report/document analysis that consumes or would normally consume credits.

## Implementation Checklist

- Identify the API point where report/document analysis completes successfully.
- Add referral milestone A trigger with invitee user id and product event metadata.
- Check referral log exists.
- Check referral log is eligible.
- Require invitee email verified.
- Ensure milestone A was not previously released.
- Run basic referral block checks.
- Check monthly reward cap.
- Grant referrer credits through `EntitlementsService`.
- Mark reward event released, capped, or blocked.
- Mark referral log milestone A released when successful.
- Write audit event.
- Enqueue referrer milestone A email.
- Dispatch push notification if Task 09 exists.

## Acceptance Criteria

- First eligible successful analysis releases milestone A reward to referrer.
- Repeated analyses do not release milestone A again.
- Unverified invitee does not release milestone A.
- Blocked referral does not release milestone A.
- Monthly cap prevents reward and records capped state.
- Reward and audit events are created for success, blocked, and capped cases.

## Tests

- Unit test milestone A eligibility.
- Unit test duplicate trigger idempotency.
- Unit test unverified invitee behavior.
- Unit test capped reward behavior.
- Integration test first successful analysis grants referrer credits once.

## Dependencies

- Task 03 referral data model.
- Task 04 referral apply and email verification release.
- Product analysis completion event/hook.
- Task 08 email event/template for milestone A.

## Out of Scope

- Milestone B paid purchase reward. See Task 06.
- Admin manual review tooling. See Task 14.

