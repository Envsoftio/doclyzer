# Task 12: Mobile Notifications

## Objective

Register mobile push tokens, let users manage notification preferences, deactivate tokens on logout, and handle push deep links.

## PRD Coverage

- MR-9 through MR-11
- NR-2 through NR-10

## Primary Areas

- `apps/mobile/lib/features/notifications`
- `apps/mobile/lib/features/auth`
- `apps/mobile/lib/core/router`
- Android and iOS platform configuration

## Implementation Checklist

- Add Firebase Messaging or selected push provider package if missing.
- Configure Android notification permissions.
- Configure iOS notification permissions.
- Register push token after login.
- Refresh token when provider token changes.
- Send app version, platform, installation id, and preferences to API.
- Deactivate token on logout.
- Add notification preferences screen or settings section.
- Support preferences for billing, referrals, product updates, and admin announcements.
- Handle push open events.
- Route push deep links to billing order status, referral dashboard, and referral progress.
- Gracefully handle denied notification permission.
- Gracefully handle missing provider token.

## Acceptance Criteria

- Logged-in mobile user registers a push token.
- Token refresh updates API.
- Logout deactivates token.
- User can update push preferences.
- Denied permission does not break app login or navigation.
- Push open routes to expected screen when payload is valid.
- Push open records event with API when possible.

## Tests

- Repository test token register/update/deactivate calls.
- Widget test preferences screen.
- Manual QA notification permission prompt.
- Manual QA Android token registration.
- Manual QA iOS token registration if iOS setup is available.

## Dependencies

- Task 09 push notification API.
- FCM/APNS credentials for real device testing.

## Out of Scope

- Admin broadcast UI. See Task 15.

