# Story: Flutter API Wiring & Contract Alignment

**Status:** backlog  
**Epic:** Cross-cutting (mobile ↔ API alignment)  
**Suggested sprint:** After API stability (e.g. post 0-2/0-3) or when preparing for E2E/device testing.

## User Story

As a developer,
I want the Flutter app to be configurable and validated against the real API,
So that we can run the mobile app against local or remote backends and catch contract drift early.

## Context

The app already uses real API repositories by default (see PRD addendum `prd-flutter-api-wiring.md`). This story focuses on **configurable base URL**, **end-to-end validation** of all flows against the API, and **fixing any contract drift** (e.g. new or renamed fields after JWT/DB-backed sessions or other API changes).

## Acceptance Criteria

- **Given** the Flutter app is built for development or staging
- **When** the app starts
- **Then** the API base URL is taken from configuration (e.g. build flavor, env, or a config file) rather than a single hardcoded constant
- **And** a clear way to point to local (e.g. `http://10.0.2.2:3000` for Android emulator, `http://localhost:3000` for iOS simulator) or a remote API is documented

- **Given** the configured API is running (with migrations applied, real or test DB)
- **When** a developer runs through the main flows (register → login → home → account profile, profiles CRUD, sessions list, communication preferences, data rights, restriction if applicable)
- **Then** all flows complete without request/response contract errors
- **And** any API response shape or error-code changes are reflected in the Flutter repositories (and tests updated if needed)

- **Given** the API returns an error (e.g. 401, 409, 4xx)
- **When** the app receives the response
- **Then** the user sees an appropriate message (no raw codes or stack traces); repository layer maps API `error.code` / `error.message` to user-facing text where needed

## Tasks (suggested)

1. Introduce configurable base URL (e.g. `ApiConfig` from env or flavor; document how to set for local vs remote).
2. Run the app against the real API; for each flow that fails, fix request/response parsing or endpoint path in the corresponding `Api*` repository.
3. Optionally add a small “API connectivity” or “environment” indicator in dev builds (e.g. show base URL or “Dev” in app bar).
4. Update README or docs in `apps/mobile` (or project root) with: how to run API locally, how to point Flutter at it, and how to run full flow tests.

## Technical Notes

- **API envelope:** Success `{ success: true, data, correlationId }`; error `{ success: false, error: { code, message }, correlationId }`. `ApiClient` already parses these.
- **Auth:** Access token in memory; refresh token in `TokenStorage` (secure storage). On 401, `ApiClient` calls `onRefreshToken` (e.g. `ApiAuthRepository.refreshTokens()`), which POSTs to `v1/auth/refresh` with `refreshToken`. Ensure API refresh contract (body/response) matches once 0-2 is done.
- **Repositories:** Keep using the existing `Api*` implementations; only change URLs, request bodies, or response parsing to match the current API.

## Definition of Done

- Base URL is configurable; docs updated.
- All listed flows work against the real API without contract errors.
- Error handling is consistent and user-facing (no raw API codes where inappropriate).
- No new regressions in existing widget/unit tests; update tests if repository contracts change.

## References

- PRD addendum: `_bmad-output/planning-artifacts/prd-flutter-api-wiring.md`
- API: `apps/api`, NestJS, `v1` prefix
- Flutter: `apps/mobile`, `lib/core/api_client.dart`, `lib/core/api_config.dart`, `lib/features/*/api_*_repository.dart`
