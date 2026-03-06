---
project_name: 'doclyzer'
user_name: 'Vishnu'
date: '2026-03-05'
sections_completed: ['technology_stack', 'language_rules', 'framework_rules', 'testing_rules', 'architecture', 'security']
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing code in this project. Focus on unobvious details that agents might otherwise miss._

---

## Technology Stack & Versions

### Backend (apps/api)
- **Runtime:** Node.js v24 LTS
- **Framework:** NestJS ^11.0.1 (Express platform via @nestjs/platform-express)
- **Language:** TypeScript ^5.7.3 — strict mode; `emitDecoratorMetadata: true` in
  tsconfig is required for TypeORM decorators (already configured)
- **ORM:** TypeORM via `@nestjs/typeorm` — Data Mapper pattern only;
  inject repositories with `@InjectRepository(Entity)`; never use Active Record /
  `BaseEntity`
- **TypeORM setup:**
  - `TypeOrmModule.forRootAsync` with `ConfigService` injection in `AppModule`
  - `autoLoadEntities: true` — entities auto-registered via `forFeature` calls
  - `synchronize: false` in all environments except local dev
  - Standalone `src/database/data-source.ts` exports a bare `DataSource` using
    `process.env` directly (required for TypeORM CLI — NestJS DI is unavailable there)
  - Migrations at `src/database/migrations/`; registered via
    `src/database/migrations/index.ts` (import there, nowhere else); npm scripts:
    `migration:generate`, `migration:run`, `migration:revert`
  - **Migration generate usage:** `npm run migration:generate -- src/database/migrations/DescriptiveName`
    (the path arg is passed after `--`; TypeORM appends a timestamp prefix automatically)
- **Entity convention:** shared/cross-domain entities live in
  `src/database/entities/<name>.entity.ts`; domain-specific entities (if introduced
  later) would live in `src/modules/<domain>/entities/<name>.entity.ts`
- **Config:** `@nestjs/config` global; `ConfigModule.forRoot({ isGlobal: true,
  validate: validateSync })` in `AppModule`; per-domain config factories via
  `registerAs('database', ...)`, `registerAs('redis', ...)`, `registerAs('auth', ...)`;
  always inject via `ConfigService` — never read `process.env` directly inside modules
- **Redis:** `ioredis` via custom global `RedisModule`; injection token:
  string `'REDIS_CLIENT'`; factory uses `ConfigService`; module is `global: true`
- **Validation:** `class-validator ^0.15.1` + `class-transformer ^0.5.1`;
  `ValidationPipe({ whitelist: true, transform: true })` set globally in `main.ts`
- **Testing:** Jest ^30.0.0 + ts-jest; repositories mocked via
  `{ provide: getRepositoryToken(Entity), useValue: { findOne: jest.fn(), ... } }` —
  no SQLite or in-memory DB; e2e tests use the real NestJS app with supertest
- **Linting:** ESLint ^9.18.0 + typescript-eslint `recommendedTypeChecked` + Prettier
- **Prettier:** `singleQuote: true`, `trailingComma: 'all'`
- **Module system:** CommonJS (`sourceType: 'commonjs'`, `module: 'nodenext'`)

### Mobile (apps/mobile)
- **Framework:** Flutter stable 3.41.x
- **Language:** Dart SDK ^3.11.0
- **Dependencies:** `crypto: ^3.0.0`, `cupertino_icons: ^1.0.8`
- **Linting:** flutter_lints ^6.0.0
- **Testing:** flutter_test (widget tests in `test/`,
  integration tests in `integration_test/`)

### Infrastructure
- **Database:** PostgreSQL `postgres:16-alpine` — source of truth for all persistent state
- **Cache:** Redis 7-alpine — ephemeral only; never store authoritative state or PHI
- **DB access from client:** SSH tunnel, e.g. `ssh -L 5432:localhost:5432 user@server` then connect to localhost

### Web (apps/web — not yet scaffolded)
- **Framework:** Nuxt v4.x

---

## Critical Implementation Rules

### TypeScript Rules (apps/api)

- **No `async` on methods that don't `await`** — ESLint `require-await` is enforced;
  synchronous methods return `T` directly, not `Promise<T>`; only methods touching
  DB / Redis / external I/O are `async`; never use `void` as a lazy `Promise<void>`
- **No `process.env` inside modules** — always inject `ConfigService`; only exception
  is `src/database/data-source.ts` (TypeORM CLI has no NestJS DI context)
- **Interfaces for domain types, classes for DTOs** — plain interfaces in
  `<module>.types.ts`; class-validator decorated classes in `<module>.dto.ts`
- **`import type` for interfaces/types** — use `import type { Foo }` when the import
  is not used as a value at runtime
- **Error codes are screaming snake case constants** — e.g. `AUTH_INVALID_CREDENTIALS`;
  never inline string codes; define constants in the module's types file
- **Domain exceptions use subclasses** — each domain creates typed subclasses of
  NestJS built-ins e.g. `ProfileNotFoundException extends NotFoundException`;
  always constructed with `{ code: 'DOMAIN_ERROR_CODE', message: '...' }` shape
  so `ApiExceptionFilter` can extract them into the standard error envelope
- **Auth protection via `@UseGuards(AuthGuard)`** — applied at controller or route
  level on all protected endpoints; public endpoints are explicitly unguarded;
  no global guard pattern
- **Module exports are minimal** — only export services that another module must
  inject; internal helpers and repositories stay private to the module

### Dart/Flutter Rules (apps/mobile)

- **Repository pattern for all data access** — abstract class in
  `lib/features/<domain>/<domain>_repository.dart`; `InMemory` implementation for
  tests/dev; production `Http` implementation calls the API over TLS
- **No force-unwrap `!` in production code** — always handle null explicitly with
  `??`, `if (x == null)`, or early return; `!` is only acceptable in test files
  where null is a programming error that should surface immediately
- **No business logic in widgets** — widgets invoke callbacks injected from the root
  app state; never instantiate repositories or call services directly inside widgets
- **`TextEditingController` always disposed in `dispose()`**
- **Widget test keys use kebab-case strings** — e.g. `Key('login-submit')`;
  key names are part of the test contract and must not change without updating tests
- **`DoclyzerApp` accepts injectable repository** — optional constructor parameter
  for test isolation; defaults to `InMemory` implementation in `initState`;
  all future feature repositories follow the same injectable pattern

---

## Framework-Specific Rules

### NestJS Framework Rules

- **Module structure per domain:** `<domain>.module.ts`, `<domain>.controller.ts`,
  `<domain>.service.ts`, `<domain>.dto.ts`, `<domain>.types.ts`,
  `entities/<name>.entity.ts`; additional services (e.g. `password-recovery.service.ts`)
  live alongside the primary service in the same module folder
- **Every module registers its own entities** via `TypeOrmModule.forFeature([Entity])`
  — never import another module's entity directly; access cross-domain data through
  the owning module's exported service
- **Controllers are thin** — no business logic; call one service method per endpoint;
  extract IP/token from request then delegate immediately
- **Response envelope is mandatory** — all success responses use `successResponse(data,
  correlationId)` from `common/response-envelope.ts`; all errors flow through
  `ApiExceptionFilter`; never call `res.json()` or `res.send()` directly
- **Correlation IDs on every request** — `correlationIdMiddleware` is global;
  `getCorrelationId(req)` retrieves it; always include in success responses and logs;
  never log PHI alongside correlation IDs
- **Rate limiting lives in `AuthService.enforceRateLimit()`** for auth routes;
  future domains add rate limiting in their own service method following the same
  `routeKey:identifier` pattern; window is 60 s default
- **Custom pipes and interceptors live in `src/common/pipes/` and
  `src/common/interceptors/`** — none exist yet; when added, register globally in
  `main.ts` or via `APP_PIPE` / `APP_INTERCEPTOR` provider tokens; never register
  inside feature modules unless strictly route-scoped
- **Module exports are minimal** — only export services another module must inject;
  entities, repositories, and internal helpers stay private to the module
- **TypeORM relationship loading is decided per entity** — no project-wide default;
  document the choice with an inline comment on each `@OneToMany` / `@ManyToOne`;
  avoid eager on collection relations (N+1 risk)
- **TypeORM cascade behaviour is decided per entity** — no project-wide default;
  document the choice with an inline comment; default to no cascade and explicit
  service-layer saves until there is a clear ownership reason to cascade
- **Auth protection via `@UseGuards(AuthGuard)`** — applied at controller or route
  level on all protected endpoints; public endpoints are explicitly unguarded;
  no global guard pattern

### Flutter Framework Rules

- **Navigation is state-based, not route-based** — `DoclyzerApp` uses an enum
  `_AuthView` (and future `_AppView`) to switch the `home` widget via a `switch`
  expression; `Navigator.push` is NOT used for primary auth/app flow navigation
- **State management roadmap: Riverpod** — current screens use `setState` + injected
  repositories; when complexity grows beyond a single screen owning its state, migrate
  to `flutter_riverpod` + `riverpod_annotation` (code-gen providers); never adopt
  flutter_bloc; do not introduce Riverpod until the second feature domain is started
- **Material 3 is active** — `useMaterial3: true`, seed color `0xFF0A7C8C`;
  always use Material 3 components (`FilledButton` not `ElevatedButton` for primary
  CTAs); never override theme color scheme with hardcoded colors
- **All screens are full `Scaffold` widgets** — `appBar`, `body` with `Padding(16)`;
  no bare `Column` or `Container` as a screen root
- **Feature screens live at:**
  `lib/features/<domain>/screens/<screen_name>_screen.dart` for primary screens;
  `lib/features/<domain>/<sub_feature>/<screen_name>_screen.dart` for sub-flows
  (e.g. `forgot_password/forgot_password_screen.dart`)
- **Error display pattern** — `String? _error` state variable; shown inline below
  the relevant field or button with `TextStyle(color: Colors.red)`; never use
  `SnackBar` for form validation errors

---

## Testing Rules

### Backend Testing (apps/api)

- **Unit tests mock all dependencies** — repositories via
  `{ provide: getRepositoryToken(Entity), useValue: { findOne: jest.fn(), ... } }`;
  services via `{ provide: ServiceName, useValue: { method: jest.fn() } }`;
  no SQLite, no in-memory DB, no real Redis in unit tests
- **e2e tests use the real NestJS app** — `Test.createTestingModule` + `supertest`;
  real InMemory* implementations; no real PostgreSQL or Redis in CI e2e tests
- **One `*.spec.ts` per source file** — named to match exactly:
  `auth.service.ts` → `auth.service.spec.ts`; co-located next to the source file
- **e2e tests live in `apps/api/test/`** — one file per feature area;
  use `beforeAll` / `afterAll` for app lifecycle
- **Test observable behaviour only** — HTTP status codes, response shapes, thrown
  exceptions; never assert on internal method calls unless testing integration wiring
- **Rate limit headroom in e2e** — limits are set high enough that the full suite
  does not exhaust them; tests that exercise rate limiting use a unique IP/account
  not shared with other tests in the suite

### Flutter Testing (apps/mobile)

- **Widget tests in `test/`** — one `*_test.dart` per screen; test form validation,
  error states, and callback invocations with `InMemory` repositories
- **Integration tests in `integration_test/`** — full happy-path flows only;
  use `InMemoryAuthRepository` with seeded state where needed
- **Find widgets by `Key`** — always use `Key('kebab-case-id')`;
  never find by text string in widget tests
- **Pump + settle pattern** — `await tester.pump()` after state changes;
  `await tester.pumpAndSettle()` only for animations

---

## Architecture & Data Flow Rules

### API Architecture

- **Request flow:** HTTP → `correlationIdMiddleware` → rate limit check (auth routes)
  → `AuthGuard` (protected routes) → `ValidationPipe` → `Controller` →
  `Service` → `Repository` → response envelope
- **Standard success envelope:**
  ```json
  { "success": true, "data": { ... }, "correlationId": "uuid" }
  ```
- **Standard error envelope:**
  ```json
  { "success": false, "code": "AUTH_INVALID_CREDENTIALS", "message": "...", "correlationId": "uuid" }
  ```
  All errors flow through `ApiExceptionFilter`; unhandled errors are sanitized to
  `{ code: 'INTERNAL_ERROR', message: 'An unexpected error occurred' }`; stack
  traces and DB error details are never returned to clients
- **Redis key format:** `doclyzer:<namespace>:<identifier>` —
  e.g. `doclyzer:session:<tokenHash>`, `doclyzer:rl:register:<ip>`,
  `doclyzer:rl:forgot-password-account:<email>`; always prefix with `doclyzer:`
- **Sessions are server-side** — access token stored in Redis under
  `doclyzer:session:<tokenHash>`; refresh token stored hashed in DB; refresh token
  rotated on every use; logout deletes the Redis key regardless of token expiry
- **Redis is ephemeral** — rate limit counters and session tokens only; never store
  source-of-truth data in Redis; accept graceful degradation if Redis is unavailable
- **Database is source of truth** — all persistent state lives in PostgreSQL;
  `synchronize: false` in all non-local environments; migrations are required for
  any schema change and must be committed to the repo; never edit a migration after
  it has been run; migration workflow will be defined when first migration is needed
  (`migration:generate` → `migration:run` via npm scripts)
- **No cross-module repository injection** — never inject another module's
  `Repository` directly; always go through the owning module's exported service
- **Config never leaks to HTTP responses** — env vars, internal paths, stack traces,
  and DB error messages are always stripped by `ApiExceptionFilter`

### Mobile Architecture

- **All API calls go through `Http*Repository`** — no direct `http`/`dio` calls
  from widgets or services outside the repository layer
- **Auth token storage** — access token held in memory only (never
  `SharedPreferences`); refresh token stored in `flutter_secure_storage` (add dep
  when `HttpAuthRepository` is implemented — not yet in `pubspec.yaml`); both
  cleared on logout
- **Offline behaviour** — not supported in v1; show a generic connectivity error;
  no local caching of API responses

---

## Security & Sensitive Data Rules

### Security Rules

- **Passwords hashed with bcrypt** — never store plaintext; never log passwords or
  tokens; cost factor ≥ 12 in production
- **Reset tokens are single-use** — invalidated immediately on successful use;
  expired tokens purged from the store on every `requestReset` call
- **Access tokens are opaque and short-lived** — not JWTs (no client-decodable
  claims); stored hashed in Redis; 15-minute TTL default
- **Refresh tokens are long-lived and rotated** — stored hashed in DB;
  old token invalidated the moment a new one is issued; server-side revocation
  on logout or suspicious reuse
- **Rate limiting is per-IP and per-account** — IP limits defend against distributed
  abuse; per-account limits defend against targeted enumeration; both apply on
  `register`, `login`, `forgot-password`
- **No PHI in logs** — never log email addresses, passwords, tokens, user IDs, or
  document content; correlation IDs are safe to log; log level is `warn`+ in production
- **`policyAccepted` must be strictly `true`** — validated as `boolean` via
  `@IsBoolean()`; string `"true"` or integer `1` are rejected by `ValidationPipe`
- **Password policy enforced in `AuthService` only** — min 8 chars, uppercase,
  lowercase, digit, special character; DTOs do not duplicate this check

### Data Classification

- **PII:** `email`, `name`, `phone` — never log, never return in list endpoints
  without explicit need, never store unencrypted outside PostgreSQL
- **Credentials:** passwords, tokens, secrets — never log, never return in API
  responses, never commit to git
- **Public data:** document metadata titles (when user-defined as public) — can be
  indexed and returned freely
