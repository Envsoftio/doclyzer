# PRD Addendum: Flutter App — API Wiring & Alignment

**Date:** 2026-03-06  
**Scope:** Mobile app (Flutter) integration with NestJS API after backend persistence and Epic 1 API work.

## Current State (Already Done)

The Flutter app is **already wired to the real API** when no test doubles are injected:

- **Bootstrap:** `main.dart` builds `ApiClient`, `TokenStorage`, and all `Api*` repositories by default (auth, account, profiles, sessions, communication preferences, data rights, restriction).
- **HTTP:** `ApiClient` uses `apiBaseUrl` (see `api_config.dart`), sends `Bearer` access token, handles 401 via refresh (calls `ApiAuthRepository.refreshTokens()`), and parses API envelope (`data` for success, `error.code` / `error.message` for errors).
- **Auth:** `ApiAuthRepository` implements register, login, logout, password reset, and refresh; tokens are stored in `TokenStorage` (flutter_secure_storage).
- **Endpoints:** Repositories call `v1/auth/*`, `v1/account/*`, `v1/profiles/*`, etc., matching the API’s global prefix and route structure.

So **no Flutter code change was required for the API-side TypeORM work (Story 0-1)** — that story did not change HTTP contracts. Epic 1 backend stories (sessions, account, profiles, etc.) are already reflected in the existing Api* repositories and screens.

## Remaining / Optional Work

| Item | Description | Priority |
|------|-------------|----------|
| **Configurable base URL** | `apiBaseUrl` is hardcoded in `api_config.dart` (e.g. `http://localhost:3000`). For physical devices or different environments, base URL should be configurable (e.g. build flavors, env file, or run-time config). | Medium |
| **Contract validation** | After API evolves (e.g. 0-2 JWT/DB sessions, new fields), run full flows (register, login, refresh, account, profiles, sessions, communication prefs, data rights) against the real API and fix any request/response drift (field renames, new required fields). | Medium |
| **Verification flow** | If the API gains an explicit “verify email” step (e.g. token/link), Flutter may need a dedicated verify endpoint call and UI; currently verification is a post-register screen that leads to login. | Low (when API adds it) |
| **Error handling** | Ensure all repository calls map API error codes to user-friendly messages and that network/connectivity errors are handled consistently. | Low |

## Out of Scope Here

- New features that require new API endpoints (handled by their own stories).
- Push notifications or deep linking (separate scope).

## References

- API: NestJS in `apps/api`, global prefix `v1`, envelope `{ success, data | error, correlationId }`.
- Flutter: `apps/mobile`, `lib/core/api_client.dart`, `lib/core/api_config.dart`, `lib/features/*/api_*_repository.dart`.
- Project context: `_bmad-output/project-context.md` (mobile architecture, repository pattern, no PHI in logs).
