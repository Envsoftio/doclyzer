# Story 1.1: Account Registration, Login, Logout

Status: done (reviewed + fixes applied)

## Story

As a visitor or registered user,  
I want to create an account and securely sign in/out,  
so that I can access my Doclyzer workspace safely.

## Acceptance Criteria

1. **Given** I am a new visitor on the auth screen  
   **When** I submit valid registration details and required policy acknowledgment  
   **Then** my account is created successfully  
   **And** I am routed through required verification/login flow.

## Tasks / Subtasks

- [x] Implement API auth module baseline for register/login/logout (AC: 1)
  - [x] Scaffold `apps/api` if missing using NestJS strict starter and create `auth` module as per architecture structure.
  - [x] Add register endpoint with input validation, password hashing, and policy-ack required gate.
  - [x] Add login endpoint with credential validation and secure token issuance.
  - [x] Add logout endpoint that revokes current session/token server-side.
  - [x] Enforce standardized error envelope with stable error codes and correlation ID.
- [x] Implement mobile auth flow in Flutter app (AC: 1)
  - [x] Scaffold `apps/mobile` if missing and add `features/auth` screens/services.
  - [x] Build signup and login screens with clear validation and minimal steps.
  - [x] Require explicit policy acknowledgment checkbox before allowing signup submit.
  - [x] Route successful signup into verification/login flow per backend response.
  - [x] Provide secure logout action from authenticated context.
- [x] Implement security and observability guardrails for auth (AC: 1)
  - [x] Apply rate limiting and abuse throttling for auth endpoints.
  - [x] Ensure no PHI/secrets in logs; include correlation IDs in auth error logs.
  - [x] Use short-lived access tokens and rotating refresh token strategy.
- [x] Add tests across API and app (AC: 1)
  - [x] API unit tests for validation, password hashing, and token/session behavior.
  - [x] API integration/e2e tests for register success/failure, login success/failure, logout revocation.
  - [x] Mobile widget/integration tests for signup/login form validation and auth state transitions.

## Story Requirements

- Scope this story to baseline auth lifecycle only: register, login, logout.
- Registration must block submission until required policy acknowledgment is provided.
- Successful registration must route user through required verification/login flow.
- Secure sign-in/out behavior is mandatory.
- Keep implementation aligned to Epic 1 sequencing:
  - Story 1.3 handles deeper account profile management.
  - Story 1.4 handles full policy acceptance version tracking.
  - Story 1.7 handles active session/device listing and per-device revoke UX.

## Developer Context Section

### Business and Product Context

- This is the first executable story in Epic 1 and unlocks all subsequent authenticated journeys.
- UX intent is minimal friction onboarding to first value; auth flow must be short, clear, and trustworthy.
- Tone and interaction should avoid friction-heavy onboarding before core value.

### In-Scope

- Visitor registration with required policy acknowledgment.
- Registered user login.
- Registered user logout.
- Verification/login routing after successful registration.
- Baseline secure session/token behavior.

### Out-of-Scope (Do Not Expand in This Story)

- Full policy version-history management UI/workflow (Story 1.4).
- Multi-session/device management UI (Story 1.7).
- Password recovery flow (Story 1.2).
- Social login providers.
- Billing or report domain functionality.

## Technical Requirements

- Implement auth endpoints in `apps/api/src/modules/auth`.
- Use strong server-side validation for request payloads.
- Hash passwords with a vetted algorithm and sane cost settings.
- Use short-lived access tokens + rotating refresh tokens with revocation.
- Enforce policy acknowledgment at registration.
- Emit structured, PHI-safe logs with correlation IDs.
- Apply endpoint rate limiting and abuse throttling.
- Return standardized API success/error envelopes.
- Keep all auth flows profile-safe and consistent with RBAC baseline.

## Architecture Compliance

- Respect architecture domain boundaries:
  - Auth logic in auth module.
  - No leakage of billing/report concerns into auth.
- Follow API contract conventions:
  - Versioned REST boundaries.
  - Stable error codes.
  - Correlation IDs in error responses.
- Apply security baseline:
  - TLS in transit.
  - Encrypted secret handling.
  - Server-side revocation on logout.
- Preserve observability constraints:
  - No PHI in logs/analytics/crash telemetry payloads.

## Library / Framework Requirements

- **Backend framework:** NestJS `v11.x` (latest release track currently `v11.1.15`).
- **Mobile framework:** Flutter stable `3.41.x` track (docs reflect `3.41.2`).
- **Web framework (project baseline):** Nuxt `v4.x` (latest release track currently `v4.3.1`) for web surfaces; this story is primarily mobile + API.
- **Runtime recommendation for new scaffolds:** Node.js Active LTS (`v24` as of 2026-03-05) unless team policy pins differently.
- **Database compatibility:** Current repo baseline uses PostgreSQL 16 (`postgres:16-alpine`) and Redis 7 (`redis:7-alpine`); auth persistence and session storage choices must remain compatible.

### Latest Tech Information (Web Research)

- NestJS latest release line includes security and dependency updates (e.g., fastify security patch updates), so prefer current `11.x` patch level.
- Flutter stable docs currently map to `3.41.2`; align Flutter dependencies with this stable line when scaffolding.
- Node.js release schedule currently marks `v24` as Active LTS and `v22` as Maintenance LTS; choose one and standardize in project tooling.
- PostgreSQL currently supports `16.13` as latest minor on the `16` major line; staying on 16 is valid for baseline stability.

Sources:
- https://github.com/nestjs/nest/releases
- https://docs.nestjs.com/security/authentication
- https://github.com/nuxt/nuxt/releases
- https://docs.flutter.dev/release/release-notes
- https://nodejs.org/en/about/previous-releases
- https://www.postgresql.org/support/versioning/

## File Structure Requirements

- Current repo does not yet contain app scaffolds; initialize structure per architecture before implementing story code:
  - `apps/api/src/modules/auth/*`
  - `apps/mobile/lib/features/auth/*`
  - Shared contracts in `packages/contracts/*` (if created during setup)
- Keep naming conventions:
  - DB: `snake_case`
  - API JSON: `camelCase`
  - TS/Dart code: standard idiomatic naming
- Keep auth feature files cohesive; avoid scattering auth logic across unrelated modules.

## Testing Requirements

- API unit tests:
  - registration input validation
  - password hashing and compare behavior
  - token generation and revocation logic
- API integration/e2e:
  - register success with policy acknowledgment
  - register failure without policy acknowledgment
  - login success/failure
  - logout invalidates/revokes active session token
  - error envelope and correlation ID assertions
- Mobile tests:
  - signup form validation (including policy acknowledgment gating)
  - login form validation and submit behavior
  - logout clears local auth state and routes correctly
- Non-functional checks:
  - no PHI/secrets in logs
  - auth endpoints protected by rate limiting

## Project Context Reference

- `project-context.md` was not found in this repository during story generation.
- Primary references used for this story:
  - `_bmad-output/planning-artifacts/epics.md`
  - `_bmad-output/planning-artifacts/architecture.md`
  - `_bmad-output/planning-artifacts/ux-design-specification.md`
  - `_bmad-output/planning-artifacts/prd.md`
  - `docs/docker.md`
  - `docker-compose.yml`

## Story Completion Status

- Story context file generated with implementation guardrails, architecture constraints, UX alignment, and testing expectations.
- Ready for `dev-story` execution.
- Completion note: Ultimate context engine analysis completed - comprehensive developer guide created.

## Dev Notes

- Implement only what Story 1.1 requires; avoid pulling forward Story 1.2/1.4/1.7 scope.
- Keep auth API contracts stable to reduce downstream rework in upcoming stories.
- Ensure policy acknowledgment is explicit and auditable enough for baseline enforcement, while deferring full version-tracking mechanics to Story 1.4.

### Project Structure Notes

- This repo currently holds planning artifacts and infrastructure baseline only.
- First implementation step for this story is scaffolding `apps/mobile`, `apps/api`, and shared structure aligned to architecture.
- Keep module boundaries strict from day one to avoid refactors later in Epic 1.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.1: Account Registration, Login, Logout]
- [Source: _bmad-output/planning-artifacts/architecture.md#Authentication & Security]
- [Source: _bmad-output/planning-artifacts/architecture.md#API & Communication Patterns]
- [Source: _bmad-output/planning-artifacts/architecture.md#Project Structure & Boundaries]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Journey 1: Signup to first report (onboarding)]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Flow Optimization Principles]
- [Source: docs/docker.md#Docker Setup]

## Dev Agent Record

### Agent Model Used

GPT-5 Codex

### Debug Log References

- create-story workflow execution (2026-03-05)
- artifact discovery and synthesis from planning docs
- `npm run lint` (apps/api) passed
- `npm test -- --runInBand` (apps/api) passed
- `npm run test:e2e -- --runInBand` (apps/api) passed
- `flutter test` (apps/mobile) passed
- `flutter analyze` (apps/mobile) passed

### Completion Notes List

- Story selected from sprint status first backlog item: `1-1-account-registration-login-logout`
- No previous story exists in epic; previous-story intelligence section intentionally omitted
- Git intelligence section omitted because no previous-story implementation artifacts exist
- Latest-tech section included from official release/documentation sources
- Validation task file `_bmad/core/tasks/validate-workflow.xml` not present; manual checklist-aligned validation applied
- Implemented NestJS auth module with register/login/logout endpoints and correlation-id aware response envelopes
- Added in-memory session issuance and server-side session revocation on logout
- Added rate limiting hook for register/login endpoints
- Replaced Flutter starter app with auth flow: login, signup with policy acknowledgment, verification routing, and authenticated home/logout
- Added API unit tests, API e2e tests, and Flutter widget tests covering the story acceptance criteria

### File List

- _bmad-output/implementation-artifacts/1-1-account-registration-login-logout.md
- apps/api/src/app.module.ts
- apps/api/src/main.ts
- apps/api/src/common/api-exception.filter.ts
- apps/api/src/common/correlation-id.middleware.ts
- apps/api/src/common/response-envelope.ts
- apps/api/src/common/notification/notification.service.ts
- apps/api/src/common/notification/in-memory-notification.service.ts
- apps/api/src/types/express.d.ts
- apps/api/src/modules/auth/auth.module.ts
- apps/api/src/modules/auth/auth.controller.ts
- apps/api/src/modules/auth/auth.service.ts
- apps/api/src/modules/auth/auth.types.ts
- apps/api/src/modules/auth/auth.dto.ts
- apps/api/src/modules/auth/auth.service.spec.ts
- apps/api/test/app.e2e-spec.ts
- apps/mobile/lib/main.dart
- apps/mobile/lib/features/auth/auth_repository.dart
- apps/mobile/lib/features/auth/in_memory_auth_repository.dart
- apps/mobile/lib/features/auth/screens/login_screen.dart
- apps/mobile/lib/features/auth/screens/signup_screen.dart
- apps/mobile/lib/features/auth/screens/verification_screen.dart
- apps/mobile/lib/features/auth/screens/home_screen.dart
- apps/mobile/test/widget_test.dart
- apps/mobile/pubspec.yaml
- apps/mobile/pubspec.lock
- _bmad-output/implementation-artifacts/sprint-status.yaml

## Change Log

- 2026-03-05: Implemented Story 1.1 auth API + Flutter auth flow, added tests, and moved story to review.
- 2026-03-05: Code review fixes applied — added /auth/refresh endpoint with rotating refresh token support; enforced access token expiry server-side in logout(); purged unbounded rate limit Map on each call; added X-Forwarded-For proxy-aware IP extraction; added Express trust proxy config; added rate limit unit + e2e tests; added refresh token rotation e2e test; fixed InMemoryAuthRepository to use SHA-256 password hashing and Random.secure() token generation; added crypto package to mobile pubspec; added auth.types.ts to File List.
- 2026-03-05: Adversarial code review fixes — logout() now revokes sessions regardless of expiry (H1); policyAccepted enforces strict === true (H2); password validation requires uppercase+lowercase+digit+special char (H3); added class-validator DTOs + ValidationPipe with whitelist:true (M1); NotificationService abstraction created for email/SMS delivery stub (C1-1.2); per-account rate limiting added to forgot-password (H1-1.2); getLastResetTokenForTest moved to InMemoryNotificationService (H2-1.2); auth.dto.ts and notification/ added to File List; pubspec.yaml and pubspec.lock added to File List.
