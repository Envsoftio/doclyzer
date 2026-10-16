# Task 14: Superadmin Referral Page

## Objective

Add superadmin referral management covering policy configuration, analytics, review queue, referral details, reward state, and audit timeline.

## PRD Coverage

- SR-5 through SR-6
- RR-23 through RR-29
- RR-31

## Primary Areas

- `apps/web/pages`
- `apps/web/components`
- `apps/web/composables`
- `apps/api/src/modules/referrals`

## Implementation Checklist

- Add Referrals admin nav item.
- Add referral analytics cards for total codes, applied referrals, verified invitees, milestone rewards, blocked rewards, capped rewards, pending reviews, and credits issued.
- Add referral policy editor.
- Support invitee bonus credits.
- Support milestone A credits.
- Support milestone B tier credits.
- Support tier thresholds.
- Support monthly cap.
- Support zero-amount order eligibility toggle.
- Add review queue table.
- Show referrer, invitee, status, review status, fraud flags, reward state, and created date.
- Add referral detail view.
- Show referral log, reward events, invitee timeline, milestone B order references, and audit timeline.
- Add block referral action with required reason.
- Add mark under review action with required reason.
- Add release eligible reward action with required reason.

## Acceptance Criteria

- Superadmin can view referral analytics.
- Superadmin can update referral policy.
- Superadmin can filter review queue.
- Superadmin can inspect referral detail and audit timeline.
- Superadmin can block referral with reason.
- Superadmin can release eligible held reward once.
- Repeating release action does not duplicate credits.
- Non-superadmin cannot access referral admin operations.

## Tests

- Component test policy editor validation.
- Component test review queue empty/loading/error states.
- API authorization tests.
- Integration test admin release idempotency.
- E2E smoke test policy update and referral review action.

## Dependencies

- Task 03 referral data model.
- Task 07 fraud/review APIs.
- Task 08 referral email templates.

## Out of Scope

- Mobile referral screens. See Task 10.

