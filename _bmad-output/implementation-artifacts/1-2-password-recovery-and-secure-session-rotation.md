# Story 1.2: Password Recovery and Secure Session Rotation

Status: done

## Story

As a registered user,  
I want to recover access when I forget credentials,  
so that I can regain access without compromising security.

## Acceptance Criteria

1. **Given** I trigger forgot-password  
   **When** I complete valid recovery challenge  
   **Then** my password is reset  
   **And** session/token rotation and revocation policies are enforced.

## Tasks / Subtasks

- [x] Implement password recovery request + reset APIs in auth module (AC: 1)
  - [x] Add forgot-password request endpoint in `apps/api/src/modules/auth` using enumeration-safe responses.
  - [x] Generate cryptographically secure, single-use, expiring reset tokens and store them securely.
  - [x] Deliver reset challenge via side-channel (email/SMS abstraction), without leaking account existence.
  - [x] Add reset-password confirm endpoint validating token, expiry, and new password policy.
  - [x] On successful reset, rotate/revoke active auth sessions/tokens per policy.
- [x] Implement secure session rotation/revocation behavior (AC: 1)
  - [x] Invalidate existing refresh sessions for the account on successful password reset.
  - [x] Ensure subsequent API calls with revoked sessions fail deterministically.
  - [x] Keep login flow explicit after reset (do not auto-login via reset flow).
- [x] Implement Flutter recovery UX in `features/auth` (AC: 1)
  - [x] Add “Forgot Password” entry point from sign-in.
  - [x] Add recovery request screen and reset screen with clear validation and non-enumerating copy.
  - [x] Show trust-preserving status messages and next steps for expired/invalid tokens.
- [x] Implement security guardrails and observability (AC: 1)
  - [x] Add per-account/per-IP rate limiting for forgot-password requests.
  - [x] Use consistent response body and timing characteristics to reduce account enumeration risk.
  - [x] Ensure no PHI or credential artifacts are written to logs/analytics.
  - [x] Emit auditable security events for reset request, reset success, and session revocation.
- [x] Add comprehensive tests (AC: 1)
  - [x] Unit tests: token generation/expiry/single-use behavior, reset validation, session invalidation.
  - [x] API integration/e2e: forgot-password flow, invalid/expired token, reset success, revoked-session denial.
  - [x] UI tests: forgot-password request and reset forms, error and recovery states.

## Story Requirements

- Must satisfy Epic 1 Story 1.2 recovery acceptance criteria exactly.
- Password reset flow must preserve account privacy and prevent user enumeration.
- Successful reset must enforce session/token rotation and revocation.
- Keep implementation constrained to account recovery + secure session rotation.
- Reuse auth foundations from Story 1.1; do not reimplement parallel auth primitives.

## Developer Context Section

### Business and Product Context

- Story 1.2 extends Story 1.1 auth baseline to close an essential account-security gap.
- The experience must preserve user trust with clear, non-alarmist guidance during account recovery.
- This is a high-sensitivity flow in a healthcare product context, so security and reliability are primary.

### Dependencies and Sequencing

- Depends on Story 1.1 auth baseline (`register/login/logout`, session model, error envelope) for clean implementation.
- If Story 1.1 is not yet implemented in code, scaffold both in one cohesive auth module while keeping story boundaries explicit.
- Do not pull in Story 1.4 (policy version tracking) or Story 1.7 (session/device list UI) scope.

### In-Scope

- Forgot-password request and secure reset completion flow.
- Reset token issuance/validation/expiry/single-use behavior.
- Session/token revocation and rotation policy enforcement after reset.
- Mobile UX for requesting and completing reset.

### Out-of-Scope (Do Not Expand in This Story)

- MFA reset flows.
- Session/device management UI.
- Social login recovery.
- Broader account profile or policy acceptance workflows.

## Technical Requirements

- Implement endpoints in `apps/api/src/modules/auth` with standardized API envelope and correlation IDs.
- Token rules:
  - cryptographically secure random generation
  - single-use
  - bounded expiry window
  - securely stored
- Forgot-password request must:
  - return consistent message regardless of account existence
  - avoid timing differences that leak account existence
  - apply anti-automation controls (rate limiting, optional CAPTCHA hook)
- Reset completion must:
  - require valid token/challenge
  - enforce password policy
  - revoke/rotate existing sessions as part of success path
  - avoid automatic login side effects
- Security telemetry and logs must be PHI-safe and free of secrets/tokens.

## Architecture Compliance

- Follow architecture `Authentication & Security` model:
  - short-lived access tokens
  - rotating refresh tokens
  - server-side revocation
- Follow `API & Communication Patterns`:
  - REST-first contracts
  - standardized error envelope
  - stable error codes + correlation IDs
- Follow project structure mapping:
  - API auth logic in `apps/api/src/modules/auth`
  - mobile auth UI in `apps/mobile/lib/features/auth`
- Preserve security controls:
  - strict input validation
  - rate limiting and abuse throttling
  - no PHI in logs.

## Library / Framework Requirements

- **Backend framework:** NestJS `v11.x` (latest observed release: `v11.1.15`).
- **Mobile framework:** Flutter `3.41.x` line (release notes for `3.41.0`; docs reflect `3.41.2`).
- **Runtime baseline:** Node.js `v24.14.0` (Latest LTS as of 2026-03-05).
- **Database baseline:** PostgreSQL `16.x` (current minor listed `16.13`), Redis `7.x` for ephemeral session/queue support.
- **Web baseline (project-level):** Nuxt `v4.x` (latest observed release: `v4.3.1`), not primary surface for this story.

### Latest Tech Information (Web Research)

- NestJS `v11.1.15` is current and includes security-relevant dependency updates in release notes (e.g., `@fastify/middie` and `multer` security updates).
- OWASP Forgot Password guidance recommends:
  - consistent messaging for existent/non-existent accounts
  - consistent response timing
  - side-channel reset delivery
  - secure, single-use, expiring tokens
  - anti-automation protections (rate limiting/CAPTCHA)
  - no account lockout as a response to forgot-password abuse.
- Node.js release page currently lists `v24.14.0` as Latest LTS and `v25.8.0` as Latest Release; use LTS for project stability.
- PostgreSQL support table lists `16.13` as current supported minor in the `16` branch.

Sources:
- https://github.com/nestjs/nest/releases
- https://docs.nestjs.com/security/authentication
- https://cheatsheetseries.owasp.org/cheatsheets/Forgot_Password_Cheat_Sheet.html
- https://nodejs.org/en/about/previous-releases
- https://www.postgresql.org/support/versioning/
- https://docs.flutter.dev/release/release-notes/release-notes-3.41.0
- https://github.com/nuxt/nuxt/releases

## File Structure Requirements

- API implementation:
  - `apps/api/src/modules/auth/controllers/*`
  - `apps/api/src/modules/auth/services/password-recovery.service.ts`
  - `apps/api/src/modules/auth/entities|repos/*` for reset challenge persistence
  - `apps/api/test/*` for integration/e2e
- Mobile implementation:
  - `apps/mobile/lib/features/auth/forgot_password/*`
  - `apps/mobile/lib/features/auth/reset_password/*`
  - `apps/mobile/test|integration_test/*`
- Keep naming conventions and error contracts aligned with architecture rules.
- If codebase scaffolding is still absent, create structure exactly as architecture baseline before adding feature code.

## Testing Requirements

- API unit tests:
  - token generation quality and hashing/storage behavior
  - single-use and expiry semantics
  - validation and policy checks
- API integration/e2e:
  - forgot-password request for existing and non-existing account returns same outward result
  - reset succeeds with valid token and fails with invalid/expired/reused token
  - reset success revokes prior sessions and requires re-auth
  - standardized error envelope and correlation ID present
- Mobile tests:
  - forgot-password request UX states
  - reset password form validation and submission
  - invalid/expired token user guidance
- Security and abuse tests:
  - request throttling limits
  - no sensitive token content in logs

## Previous Story Intelligence

- Story 1.1 established these guardrails to preserve:
  - strict auth scope boundaries and no cross-domain leakage
  - standardized API error envelope with stable codes + correlation IDs
  - no PHI/secrets in logs
  - repo may require initial app scaffolding before feature implementation
- Reuse expected building blocks from Story 1.1 (auth module, token/session base, mobile auth shell) instead of creating parallel implementations.
- Maintain story boundary discipline from Story 1.1 notes: do not pull forward later epic scope unless required for acceptance criteria.

## Project Context Reference

- `project-context.md` was not found in this repository during story generation.
- Primary references used for this story:
  - `_bmad-output/planning-artifacts/epics.md`
  - `_bmad-output/planning-artifacts/architecture.md`
  - `_bmad-output/planning-artifacts/ux-design-specification.md`
  - `_bmad-output/planning-artifacts/prd.md`
  - `_bmad-output/implementation-artifacts/1-1-account-registration-login-logout.md`
  - `docs/docker.md`
  - `docker-compose.yml`

## Story Completion Status

- Story context file generated with implementation guardrails, architecture constraints, UX alignment, and secure-recovery standards.
- Ready for `dev-story` execution.
- Completion note: Ultimate context engine analysis completed - comprehensive developer guide created.

## Dev Notes

- Implement this story only after or alongside Story 1.1 auth foundations.
- Do not auto-login post-reset; require normal login flow with newly set password.
- Ensure reset event handling and token revocation are deterministic and test-covered.

### Project Structure Notes

- Current repository still appears planning-first; scaffolding may be required before implementation.
- Keep all recovery logic inside the auth bounded context and avoid ad hoc utilities outside module boundaries.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.2: Password Recovery and Secure Session Rotation]
- [Source: _bmad-output/planning-artifacts/architecture.md#Authentication & Security]
- [Source: _bmad-output/planning-artifacts/architecture.md#API & Communication Patterns]
- [Source: _bmad-output/planning-artifacts/architecture.md#Project Structure & Boundaries]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Journey 1: Signup to first report (onboarding)]
- [Source: _bmad-output/implementation-artifacts/1-1-account-registration-login-logout.md]
- [Source: https://cheatsheetseries.owasp.org/cheatsheets/Forgot_Password_Cheat_Sheet.html]

## Dev Agent Record

### Agent Model Used

claude-4.6-sonnet-medium-thinking

### Debug Log References

- dev-story workflow execution (2026-03-05)
- `npm run lint` (apps/api) passed
- `npm test -- --runInBand` (apps/api) passed — 19/19 unit tests
- `npm run test:e2e -- --runInBand` (apps/api) passed — 14/14 e2e tests
- `flutter test` (apps/mobile) passed — 7/7 widget tests

### Completion Notes List

- Implemented `PasswordRecoveryService` with SHA-256 token hashing, 1-hour expiry, single-use enforcement, and enumeration-safe `requestReset` path
- Added `POST /auth/forgot-password` (rate-limited, enumeration-safe generic response) and `POST /auth/reset-password` (validates token, resets password, revokes all sessions)
- Extended `AuthService` with `findUserByEmail`, `updatePasswordHash`, `revokeAllSessionsForUser`, `validatePasswordStrength` for use by recovery service
- `PasswordRecoveryService.pendingDeliveries` Map simulates side-channel delivery for in-memory/test environment; production implementation hooks here
- Added `ForgotPasswordScreen` and `ResetPasswordScreen` Flutter screens; added "Forgot password?" entry point to `LoginScreen`
- Extended `AuthRepository` abstract class and `InMemoryAuthRepository` with `requestPasswordReset` / `confirmPasswordReset` methods; `InMemoryAuthRepository` exposes `getLastResetTokenForTest()` utility for widget tests
- `DoclyzerApp` accepts injectable `AuthRepository` parameter to enable widget test isolation
- Session revocation on reset: `revokeAllSessionsForUser` marks all sessions `revokedAt`; subsequent API calls with revoked tokens return `AUTH_SESSION_REVOKED`
- Login is required after reset; no auto-login side effect
- Confirmed no PHI or token values in any log statements

### File List

- _bmad-output/implementation-artifacts/1-2-password-recovery-and-secure-session-rotation.md
- apps/api/src/modules/auth/auth.types.ts
- apps/api/src/modules/auth/auth.dto.ts
- apps/api/src/modules/auth/auth.service.ts
- apps/api/src/modules/auth/auth.module.ts
- apps/api/src/modules/auth/auth.controller.ts
- apps/api/src/modules/auth/password-recovery.service.ts
- apps/api/src/modules/auth/password-recovery.service.spec.ts
- apps/api/src/modules/auth/auth.service.spec.ts
- apps/api/src/common/notification/notification.service.ts
- apps/api/src/common/notification/in-memory-notification.service.ts
- apps/api/src/main.ts
- apps/api/test/app.e2e-spec.ts
- apps/mobile/lib/features/auth/auth_repository.dart
- apps/mobile/lib/features/auth/in_memory_auth_repository.dart
- apps/mobile/lib/features/auth/forgot_password/forgot_password_screen.dart
- apps/mobile/lib/features/auth/reset_password/reset_password_screen.dart
- apps/mobile/lib/features/auth/screens/login_screen.dart
- apps/mobile/lib/main.dart
- apps/mobile/test/widget_test.dart
- apps/mobile/pubspec.yaml
- apps/mobile/pubspec.lock

## Senior Developer Review (AI)

**Review date:** 2026-03-13  
**Outcome:** Verification pass — story was previously reviewed (adversarial code review fixes in changelog). No new issues found. **Approve.**

---

## Change Log

- 2026-03-05: Implemented Story 1.2 — password recovery + reset APIs, session revocation, Flutter recovery UX, security guardrails, and comprehensive test suite. Story moved to review.
- 2026-03-05: Adversarial code review fixes — NotificationService abstraction created (notification.service.ts + in-memory-notification.service.ts) replacing pendingDeliveries Map stub; getLastResetTokenForTest() removed from PasswordRecoveryService, now lives on InMemoryNotificationService.getLastTokenForEmail(); per-account rate limiting added to forgot-password endpoint (5/min per account, 20/min per IP); expired token purge added to resetTokensByHash; expired token e2e test added; InMemoryAuthRepository refactored to track reset tokens per-email (Map) instead of single field; ForgotPasswordScreen title fixed to "Forgot Password"; ResetPasswordScreen copy updated from "code" to "token"; pubspec.lock added to File List. Story status: done.
