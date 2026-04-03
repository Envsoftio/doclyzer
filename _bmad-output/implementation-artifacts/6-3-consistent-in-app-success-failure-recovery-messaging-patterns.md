# Story 6.3: Consistent In-App Success/Failure/Recovery Messaging Patterns

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a product user,
I want clear in-app status messaging,
so that critical flows are understandable and recoverable.

## Acceptance Criteria

1. Given flow outcome changes, when message renders, then standardized success/failure/recovery patterns are shown.

## Tasks / Subtasks

- [x] Task 1: Define the unified messaging taxonomy and UX rules across critical flows (AC: #1)
  - [x] Enumerate critical flows and their success/failure/recovery messages: auth, report upload/parse, share link creation/revocation, billing/entitlements, notification preferences, account/profile updates.
  - [x] Map each outcome to a standard pattern: inline error (form validation), SnackBar (transient success), Banner/inline callout (recovery or persistent state), and ensure copy aligns with UX spec.
  - [x] Confirm PHI-safe copy (no report contents, names, identifiers beyond generic terms).

- [x] Task 2: Implement a shared messaging helper in Flutter to remove ad-hoc SnackBar usage (AC: #1)
  - [x] Create a small utility (e.g., `apps/mobile/lib/core/feedback/status_messenger.dart`) that centralizes SnackBar configuration (floating behavior, duration, action placement) and enforces consistent tone.
  - [x] Use `ScaffoldMessenger` for SnackBar delivery; ensure helpers accept `BuildContext` and keep them synchronous unless awaiting work.
  - [x] Reuse existing `SnackBarThemeData` in `apps/mobile/lib/core/theme/app_theme.dart`.

- [x] Task 3: Refactor existing screens to use the unified patterns (AC: #1)
  - [x] Replace direct `ScaffoldMessenger.of(context).showSnackBar(...)` calls in key screens with the shared helper:
    - `apps/mobile/lib/main.dart`
    - `apps/mobile/lib/features/auth/screens/login_screen.dart`
    - `apps/mobile/lib/features/auth/screens/home_screen.dart`
    - `apps/mobile/lib/features/account/screens/account_profile_screen.dart`
    - `apps/mobile/lib/features/sharing/screens/create_share_link_screen.dart`
    - `apps/mobile/lib/features/billing/screens/plan_selection_screen.dart`
    - `apps/mobile/lib/features/billing/screens/credit_pack_list_screen.dart`
    - `apps/mobile/lib/features/billing/screens/entitlement_summary_screen.dart`
  - [x] Keep form validation errors inline (`String? _error`) instead of SnackBars.
  - [x] Ensure recovery actions are present where specified (Retry/Keep file anyway, Revoke/Undo, etc.) and match UX patterns.

- [x] Task 4: Align web admin in-app status messaging with accessibility standards (AC: #1)
  - [x] For admin pages that render status or error callouts (e.g., dashboard or admin actions), ensure status messages use `role="status"` and errors use `role="alert"` or `aria-live` to support screen readers.
  - [x] Keep message containers in the DOM so updates are announced without focus changes.

## Dev Notes

### Developer Context (What this story is and isn’t)

- This story standardizes **in-app** success/failure/recovery messaging patterns for critical flows; it does not add new notification delivery features (Story 6.1) or preference logic (Story 6.2).
- Focus is on consistent UX and implementation reuse, not on changing business logic or API contracts.

### Technical Requirements (Must Follow)

- **Form validation errors must be inline** (no SnackBars for validation). Use `String? _error` pattern in Flutter forms. [Source: `_bmad-output/project-context.md#Flutter Framework Rules`]
- **Use `ScaffoldMessenger` for SnackBars**; it is the widget responsible for showing SnackBars for descendant `Scaffold`s. [Source: Flutter API docs – ScaffoldMessenger]
- **PHI-safe messaging:** No PHI in UI copy, logs, or telemetry. Keep messages generic (e.g., “Report upload failed” not “HbA1c report failed”). [Source: `_bmad-output/project-context.md#Security & Sensitive Data Rules`]
- **Material 3 active:** Use Material 3 components (`FilledButton`, etc.) and respect the app theme. [Source: `_bmad-output/project-context.md#Flutter Framework Rules`]

### Architecture & UX Compliance

- **Deterministic async states** must remain visible (uploading/parsing/success/failure) across mobile and web surfaces. [Source: `_bmad-output/planning-artifacts/architecture.md#API & Communication Patterns`]
- **UX feedback patterns** are defined in the UX spec (success, error, warning, info/progress, loading). Align copy and placement to those patterns. [Source: `_bmad-output/planning-artifacts/ux-design-specification.md#Feedback Patterns`]
- **Share flow messaging** must keep profile context explicit (“Share [Profile]’s reports”). [Source: `_bmad-output/planning-artifacts/ux-design-specification.md#Share flow`]

### Library / Framework Requirements (Latest Guidance)

- **Flutter:** SnackBars should be shown via `ScaffoldMessenger` to ensure proper behavior across descendant `Scaffold`s. [Source: https://api.flutter.dev/flutter/material/ScaffoldMessenger/ScaffoldMessenger.html]
- **Web accessibility:** Status updates should use `role="status"` (polite live region) and error updates `role="alert"` (assertive) so assistive tech announces changes without focus management. [Source: https://www.w3.org/WAI/WCAG21/Techniques/aria/ARIA22] [Source: https://www.w3.org/WAI/WCAG21/Techniques/aria/ARIA19]

### File Structure Requirements

- **Flutter shared helper** should live under `apps/mobile/lib/core/` to avoid cross-feature duplication.
- **No new module-level globals**; keep helpers lightweight and importable from feature screens.
- **Do not alter** API contracts or server-side response envelopes.

### Testing Requirements

- **Do not add tests** and **do not run tests**. Manual QA only. [Source: `_bmad-output/project-context.md#Dev Agent Testing Policy`]

### Previous Story Intelligence (6.2)

- Notification preference logic already exists and uses `NotificationPipelineService` with PHI-safe metadata; do not duplicate that logic for messaging. [Source: `_bmad-output/implementation-artifacts/6-2-notification-preference-controls-by-category.md`]
- Several flows already dispatch notification events; ensure in-app messaging complements (not replaces) those notifications. [Source: `_bmad-output/implementation-artifacts/6-2-notification-preference-controls-by-category.md`]

### Git Intelligence (Recent Commit Patterns)

- Recent work introduced notification pipeline helpers and expanded admin dashboard behavior. Use those existing patterns and avoid creating new parallel systems for user-facing status messages. [Source: `git log` 2026-04-02 to 2026-04-03]
- Mobile and API changes have recently touched billing and notification flows; be careful to avoid regressions in those screens when standardizing message delivery.

### Project Context Reference

- `_bmad-output/project-context.md` (Flutter rules, error patterns, PHI-safe rules)
- `_bmad-output/planning-artifacts/ux-design-specification.md` (feedback patterns)
- `_bmad-output/planning-artifacts/architecture.md` (async state transparency)
- `_bmad-output/planning-artifacts/epics.md#Story 6.3`

### References

- `_bmad-output/planning-artifacts/epics.md#Story 6.3`
- `_bmad-output/planning-artifacts/ux-design-specification.md#Feedback Patterns`
- `_bmad-output/planning-artifacts/architecture.md#API & Communication Patterns`
- `_bmad-output/project-context.md#Flutter Framework Rules`
- `_bmad-output/project-context.md#Security & Sensitive Data Rules`
- `_bmad-output/implementation-artifacts/6-2-notification-preference-controls-by-category.md`
- Flutter ScaffoldMessenger API: https://api.flutter.dev/flutter/material/ScaffoldMessenger/ScaffoldMessenger.html
- W3C ARIA status messages: https://www.w3.org/WAI/WCAG21/Techniques/aria/ARIA22
- W3C ARIA error alerts: https://www.w3.org/WAI/WCAG21/Techniques/aria/ARIA19

## Dev Agent Record

### Agent Model Used

gpt-5

### Debug Log References

- 2026-04-03 Messaging taxonomy:
  - Inline validation errors: missing email/password, promo code required, other form field validation (`String? _error` stays inline).
  - SnackBar success (transient): profile updated, avatar updated, plan upgraded, credits added, share link copied.
  - SnackBar warning/recovery: account restrictions next steps, payment capture pending, verification pending, blocked actions.
  - Banner/inline callout (persistent state): restriction banners, billing status banner, share link limit/error callouts.
  - PHI-safe copy maintained (no report contents or identifiers exposed).

### Completion Notes List

- Story created from sprint status backlog (Epic 6, Story 6.3).
- UX feedback patterns and Flutter error-display rules captured for standardization.
- Implemented unified mobile `StatusMessenger` helper and refactored key screens to use it.
- Admin status/error callouts now include ARIA live regions for accessibility.
- Tests not added or run per project testing policy.

### File List

- _bmad-output/implementation-artifacts/6-3-consistent-in-app-success-failure-recovery-messaging-patterns.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- apps/mobile/lib/core/feedback/status_messenger.dart
- apps/mobile/lib/main.dart
- apps/mobile/lib/features/auth/screens/login_screen.dart
- apps/mobile/lib/features/auth/screens/home_screen.dart
- apps/mobile/lib/features/account/screens/account_profile_screen.dart
- apps/mobile/lib/features/sharing/screens/create_share_link_screen.dart
- apps/mobile/lib/features/billing/screens/plan_selection_screen.dart
- apps/mobile/lib/features/billing/screens/credit_pack_list_screen.dart
- apps/mobile/lib/features/billing/screens/entitlement_summary_screen.dart
- apps/web/app/pages/admin/login/index.vue
- apps/web/app/pages/admin/users/index.vue
- apps/web/app/pages/admin/users/[id].vue
- apps/web/app/pages/admin/risk/index.vue
- apps/web/app/pages/admin/files/index.vue
- apps/web/app/pages/admin/dashboard/index.vue

### Change Log

- 2026-04-03: Created story file for Epic 6 Story 6.3.
- 2026-04-03: Standardized in-app messaging helper and refactored mobile/admin status callouts.
- 2026-04-03: Code review fix — added `role="status" aria-live="polite"` to `modalSuccess` callout in risk/index.vue (was missing; error box already had `role="alert"`). Marked story done.
