# Task 10: Mobile Referral Experience

## Objective

Add Flutter screens and API integration for referral dashboard, sharing, referral progress, referral code entry, and referral deep-link handling.

## PRD Coverage

- MR-1 through MR-5
- MR-12
- RR-30 through RR-32

## Primary Areas

- `apps/mobile/lib/features/referrals`
- `apps/mobile/lib/features/auth`
- `apps/mobile/lib/features/billing`
- Mobile router/navigation code

## Implementation Checklist

- Add referral API repository.
- Add referral status model.
- Add referral policy summary model.
- Add referral progress item model.
- Add referred friend timeline model.
- Add reward outcome model.
- Add referral dashboard screen.
- Show referral code and share link.
- Add copy referral code action.
- Add share action using `share_plus`.
- Show total referred, credits earned, pending rewards, and review/blocked state.
- Add referral progress screen.
- Render timeline stages: signed up, email verified, milestone A, first paid purchase, reward outcome.
- Add referral code entry during signup or post-signup onboarding.
- Add manual referral apply screen if signup integration is risky.
- Add referral link/deep-link parsing.
- Refresh entitlement summary after referral reward events.

## Acceptance Criteria

- User can view referral code and share link.
- User can copy referral code.
- User can share referral link through native share sheet.
- User can enter referral code during signup/onboarding.
- User sees clear error for invalid, already-used, or self referral code.
- Referral progress shows referred users and reward states.
- Referral screen updates after pull-to-refresh or app resume.
- Referral reward changes refresh entitlement summary.

## Tests

- Widget test referral dashboard loaded state.
- Widget test empty state.
- Widget test error state.
- Widget test progress timeline rendering.
- Repository test API parsing.
- Manual QA for share sheet and deep-link handling.

## Dependencies

- Task 03 referral data model.
- Task 04 referral apply/status endpoints.
- Task 05 and Task 06 for milestone progress.

## Out of Scope

- API referral implementation. See Tasks 03 through 07.
- Push token registration. See Task 12.

