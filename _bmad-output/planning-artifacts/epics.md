---
stepsCompleted: [1, 2, 3, 4]
inputDocuments: ["prd.md", "architecture.md", "ux-design-specification.md"]
---

# doclyzer - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for doclyzer, decomposing the requirements from the PRD, UX Design if it exists, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

- FR1: Visitors can create a Doclyzer account.
- FR2: Registered users can sign in and sign out securely.
- FR3: Users can recover account access when credentials are lost.
- FR4: Users can view and update basic account information.
- FR5: Users can view and accept current legal and policy documents within the product context.
- FR6: Account holders can create multiple patient profiles.
- FR7: Account holders can edit profile details for each patient profile.
- FR8: Account holders can switch active profile context at any time.
- FR9: Users can assign each uploaded report to a specific patient profile.
- FR10: Users can delete a patient profile with confirmation and clear impact visibility.
- FR11: Users can upload supported medical report files to an active profile.
- FR12: Users can see report processing status from submission to final state.
- FR13: Users can retry report processing when processing fails.
- FR14: Users can keep an uploaded report as file-only when parsing is unsuccessful.
- FR15: Users can view original report files regardless of parse outcome.
- FR16: The system can detect and handle duplicate report submissions with explicit user choice.
- FR17: Users can view a timeline of reports scoped to the active profile.
- FR18: Users can view structured lab values when extraction is available.
- FR19: Users can view trend charts for chartable lab parameters over time.
- FR20: Users can view report-level summaries for uploaded reports.
- FR21: Users can view profile-level consolidated health history from available reports.
- FR22: Users can create share links for selected profile data.
- FR23: Users can configure share-link validity controls, including expiry and revocation.
- FR24: Users can distribute share links via copy/share actions.
- FR25: Recipients with a valid share link can view shared content in a browser without account creation.
- FR26: Recipients can access a readable, doctor-friendly shared view including timeline and key trends.
- FR27: Users can view current credit balance and entitlement status.
- FR28: Users can purchase credit packs through supported payment flows.
- FR29: Users can subscribe to supported paid plans.
- FR30: Users can apply valid promo codes during eligible checkout flows.
- FR31: The system can enforce free-tier and paid-tier usage limits consistently.
- FR32: Users can receive product notifications for relevant account, report, and billing events.
- FR33: Users can control notification preferences by category.
- FR34: Users can receive clear in-app messaging for success, failure, and recovery states during critical flows.
- FR35: Superadmins can manage plan definitions, limits, and pricing configuration.
- FR36: Superadmins can create, edit, activate, and deactivate promo codes.
- FR37: Superadmins can view promo redemption and revenue impact data.
- FR38: Superadmins can view core product metrics for signups, usage, and monetization.
- FR39: Superadmin actions are recorded with auditable change history.
- FR40: The system can enforce explicit informational-only medical disclaimers at the point of AI-derived interpretation and before share publication where relevant.
- FR41: Users can exercise account-level data rights workflows, including deletion-related actions.
- FR42: The system can enforce PHI-safe product telemetry and operational event handling policies.
- FR43: The system can provide access and sharing activity records needed for compliance and incident investigation.
- FR44: Users can grant and withdraw consent for data processing features that require explicit consent. (Deferred: Out of current release scope)
- FR45: Users can view which consent choices are currently active for their account. (Deferred: Out of current release scope)
- FR46: The system can enforce profile isolation across all user-facing views and share outputs unless explicitly authorized by the account holder.
- FR47: Users can see the outcome of billing actions and entitlement updates in pending, failed, and reconciled states.
- FR48: The system can maintain acceptance records for legal/policy versions tied to user actions.
- FR49: Superadmins can perform emergency containment actions, including reversible actions where applicable, with mandatory audit notes.
- FR50: Users can view a complete history of report processing attempts and outcomes per report.
- FR51: Users can view current plan/credit entitlements and the latest entitlement change reason.
- FR52: Users can define default share-link policies for newly created share links.
- FR53: Superadmins can retrieve auditable records for access, sharing, consent, and policy acceptance events.
- FR54: Users can request an export of their account data, including user-submitted data and available derived account artifacts, in a portable format.
- FR55: Users can view and manage active sessions/devices associated with their account.
- FR56: Users can immediately revoke account access from selected active sessions/devices.
- FR57: The system can detect and flag suspicious activity across both account and sharing surfaces for administrative review.
- FR58: Superadmins can suspend and restore risky share links and affected accounts with auditable justification.
- FR59: Users can view a history of share-link access events for links they created, including timestamp, link identifier, and outcome state.
- FR60: Users can manage account communication preferences for security and compliance notices.
- FR61: Users can correct report-to-profile assignment after upload with explicit confirmation.
- FR62: Users can request account closure and receive clear visibility into resulting data-access changes.
- FR63: Users can designate trusted delegates for profile management with explicit scope controls. (Deferred: Out of current release scope)
- FR64: Superadmins can enforce temporary protective restrictions during active security investigations.
- FR65: The system can provide user-facing status updates for major service incidents affecting core workflows.
- FR66: Users can revoke delegated profile-management access at any time. (Deferred: Out of current release scope)
- FR67: Users can view and acknowledge critical compliance or security notices that affect account use.
- FR68: Users can initiate in-product support requests tied to failed critical actions, including related action identifiers for triage.
- FR69: Superadmins can place accounts in restricted review mode without deleting user data.
- FR70: Users can view when protective restrictions are applied to their account and what actions are limited.
- FR71: Users can view a clear rationale and next steps when account restrictions are applied.
- FR72: Users can define delegation expiration conditions when granting delegated access. (Deferred: Out of current release scope)
- FR73: Superadmins can document resolution outcomes for restricted accounts with audit traceability.
- FR76: Superadmins can execute time-bound override actions with mandatory reason capture and expiration.
- FR77: The system provides an email pipeline for sending transactional and product emails (e.g. password reset, notifications, security/compliance notices) with delivery status and tracking.
- FR78: Superadmins can view email queue status, delivery analytics (sent, failed, bounced by type), and email sending history via an admin panel.
- FR79: Superadmins can send admin-level emails (e.g. announcements, support, incident notifications) through the admin panel with mandatory audit and recipient controls.

### NonFunctional Requirements

- NFR1: Core authenticated screens load usable content within 2 seconds under normal mobile network conditions.
- NFR2: Report upload initiation feedback appears within 1 second of user action.
- NFR3: Timeline interactions (scroll/filter/open report) respond within 300 ms for typical profile data volumes.
- NFR4: Share-link web view renders primary summary content within 2 seconds on modern mobile browsers.
- NFR5: All data in transit is protected with TLS.
- NFR6: Sensitive stored data is encrypted at rest using approved key-management practices.
- NFR7: PHI is excluded from analytics, crash telemetry, and operational logs.
- NFR8: Access to profile-scoped data is enforced by account and authorization context across all surfaces.
- NFR9: Security-relevant admin and user actions are auditable and tamper-evident.
- NFR10: Critical user workflows (auth, upload, timeline view, share view, entitlement check) achieve 99.9% monthly availability target.
- NFR11: Background processing failures use retry/backoff with deterministic terminal states.
- NFR12: User-facing error states provide recovery paths for all critical workflows.
- NFR13: Backup and restore procedures support recovery point and recovery time targets appropriate for healthcare data handling.
- NFR14: System supports 10x growth from initial launch load without architecture redesign of core workflows.
- NFR15: Peak-time traffic spikes are handled without loss of data consistency for uploads, entitlements, or share access.
- NFR16: Asynchronous processing capacity can be increased horizontally for parse and AI workloads.
- NFR17: Mobile and share-web interfaces conform to WCAG 2.1 AA criteria for applicable components.
- NFR18: Critical flows are operable with screen readers and scalable text settings.
- NFR19: Color and contrast choices meet accessibility thresholds for health-information readability.
- NFR20: External integrations (payment, parser/AI services) use versioned contracts with explicit error semantics.
- NFR21: Integration failures degrade gracefully without corrupting user-visible state.
- NFR22: Integration latency and failure rates are continuously monitored with alert thresholds.
- NFR23: Legal/policy version acceptance is retained for audit and dispute handling.
- NFR24: Consent-state changes are traceable with timestamped records.
- NFR25: Region-aware compliance controls can be configured without requiring core product redesign.
- NFR26: Production systems emit structured, searchable operational events for critical flows.
- NFR27: Alerting exists for security incidents, entitlement drift, and parser/processing failures.
- NFR28: Incident response procedures define severity tiers, notification paths, and restoration expectations.

### Additional Requirements

- Web framework is Nuxt (not Next), with strict route partitioning for landing and share surfaces.
- Landing page must be SEO-ready (metadata, canonical tags, sitemap/robots, social tags, and structured data).
- Share routes are non-indexable by default and protected with signed scoped tokens, expiry, and revocation.
- Superadmin analytics must cover app usage and user behavior (funnel, retention, conversion, promo performance, anomaly insights).
- Analytics/telemetry must remain PHI-safe; no PHI in logs, analytics, or crash payloads.
- Superadmin requires MFA and elevated-action audit trails.
- Deterministic async lifecycle states are required across mobile, web, and API for parse/payment/share flows.
- API contracts must include standardized error envelopes with stable error codes and correlation IDs.
- Idempotency is required for upload, payment, and share-link creation operations.
- Domain separation is required: PHI clinical/report domain isolated from billing/entitlement and analytics/admin domains.
- CI/CD gates must enforce security policy checks, no-PHI telemetry checks, migration validation, and landing SEO checks.
- Deployment requires independent blast-radius controls across mobile, API, and web releases.
- Observability requires searchable metrics/logs/traces/audit events and incident-response playbooks.
- Docker-based local orchestration is required (`docker-compose.yml`, documented env setup).
- UX requires upload -> parse status transparency with clear failure recovery: Retry and Keep file anyway.
- UX requires profile-scoped sharing clarity with explicit “Link for [Profile]” and scope confirmation.
- Share page UX must be doctor-friendly, readable, print-friendly, and accessible.
- Accessibility baseline is WCAG 2.1 AA across mobile and web critical flows.
- Responsive behavior is required for landing/share web across mobile, tablet, and desktop breakpoints.
- AI summary/lifestyle surfaces must show visible informational-only disclaimers and safety framing.
- Legal pages (Terms/Privacy/Refund) must be linked from product and landing surfaces.

### FR Coverage Map

FR1: Epic 1 - User registration
FR2: Epic 1 - Secure sign in and sign out
FR3: Epic 1 - Account recovery
FR4: Epic 1 - Account profile management
FR5: Epic 1 - Policy visibility and acceptance
FR6: Epic 1 - Multi-profile creation (free: 1 profile; paid: multiple)
FR7: Epic 1 - Multi-profile editing
FR8: Epic 1 - Active profile switching
FR9: Epic 2 - Report assignment to profile
FR10: Epic 1 - Profile deletion with safeguards
FR11: Epic 2 - Report upload
FR12: Epic 2 - Processing status visibility
FR13: Epic 2 - Parse retry flow
FR14: Epic 2 - Keep file on parse failure
FR15: Epic 2 - Original file viewing
FR16: Epic 2 - Duplicate detection handling
FR17: Epic 2 - Profile timeline view
FR18: Epic 2 - Structured lab values
FR19: Epic 2 - Trend charts
FR20: Epic 2 - Report summaries
FR21: Epic 2 - Consolidated health history
FR22: Epic 3 - Share link creation
FR23: Epic 3 - Share expiry/revocation controls
FR24: Epic 3 - Share distribution actions
FR25: Epic 3 - Recipient access without account
FR26: Epic 3 - Doctor-friendly recipient view
FR27: Epic 4 - Credit and entitlement visibility
FR28: Epic 4 - Credit pack purchase
FR29: Epic 4 - Subscription purchase
FR30: Epic 4 - Promo code application
FR31: Epic 4 - Usage limit enforcement
FR32: Epic 6 - Product notifications
FR33: Epic 6 - Notification preferences
FR34: Epic 6 - In-app status messaging
FR35: Epic 5 - Plan management
FR36: Epic 5 - Promo CRUD
FR37: Epic 5 - Promo performance analytics
FR38: Epic 5 - Usage and monetization analytics
FR39: Epic 5 - Superadmin auditability
FR40: Epic 7 - AI disclaimer enforcement
FR41: Epic 1 - Data rights workflows
FR42: Epic 7 - PHI-safe telemetry enforcement
FR43: Epic 5 - Compliance activity records
FR44: Deferred - Out of current release scope
FR45: Deferred - Out of current release scope
FR46: Epic 3 - Profile isolation in sharing
FR47: Epic 4 - Billing and entitlement state outcomes
FR48: Epic 1 - Legal/policy acceptance records
FR49: Epic 5 - Emergency containment actions
FR50: Epic 2 - Processing attempt history
FR51: Epic 4 - Entitlement change reason visibility
FR52: Epic 3 - Default share policies
FR53: Epic 5 - Auditable access/share/consent/policy records
FR54: Epic 1 - Account data export
FR55: Epic 1 - Active session/device management
FR56: Epic 1 - Session revocation
FR57: Epic 5 - Suspicious activity flagging
FR58: Epic 5 - Risky link/account suspension and restore
FR59: Epic 3 - Share access event history
FR60: Epic 1 - Communication preferences
FR61: Epic 2 - Post-upload profile reassignment
FR62: Epic 1 - Account closure workflow
FR63: Deferred - Out of current release scope
FR64: Epic 5 - Temporary protective restrictions
FR65: Epic 6 - Major incident status updates
FR66: Deferred - Out of current release scope
FR67: Epic 1 - Compliance/security notice acknowledgement
FR68: Epic 6 - In-product support requests for failures
FR69: Epic 5 - Restricted review mode
FR70: Epic 1 - Restriction visibility
FR71: Epic 1 - Restriction rationale and next steps
FR72: Deferred - Out of current release scope
FR73: Epic 5 - Restricted account resolution documentation
FR76: Epic 5 - Time-bound override actions

## Epic List

### Epic 0: Backend Foundation — Real Persistence, JWT Auth & API Wiring
All Epic 1 API endpoints are production-ready: PostgreSQL via TypeORM, JWT access + refresh token auth with DB-backed sessions, all in-memory Maps replaced, Flutter wired to real API, E2E tests passing against a real DB, and user-uploaded files (reports, avatars) stored in Backblaze B2.
**Technical Stories:** 0.1 TypeORM setup, 0.2 JWT auth, 0.3 DB-backed services, 0.4 E2E test infra, 0.5 Backblaze B2 object storage (reports, profile pics, file uploads)

### Epic 1: Account Security, Consent, Profile & Delegation Foundation
Users can securely onboard, manage account/session controls, accept legal policies, exercise consent and data rights, and manage multi-profile/delegation foundations needed by all later workflows.
**FRs covered:** FR1, FR2, FR3, FR4, FR5, FR6, FR7, FR8, FR10, FR41, FR48, FR54, FR55, FR56, FR60, FR62, FR67, FR70, FR71

### Epic 2: Report Ingestion, Processing Recovery & Timeline Insights
Users can upload reports to the correct profile, recover from parsing failures, and consume timeline/trend/summary value with deterministic status visibility.
**FRs covered:** FR9, FR11, FR12, FR13, FR14, FR15, FR16, FR17, FR18, FR19, FR20, FR21, FR50, FR61

### Epic 3: Web Experience - Share Recipient + SEO Landing (Nuxt)
Users can securely share profile-scoped health information to recipients, while the product also delivers an SEO-ready landing presence in the same Nuxt web surface with strict route isolation.
**FRs covered:** FR22, FR23, FR24, FR25, FR26, FR46, FR52, FR59
**Refinements:** include an early landing SEO MVP story (metadata, canonical tags, sitemap/robots, structured data) and enforce non-indexable share routes by default.

### Epic 4: Monetization, Entitlements & Checkout
Users can understand and manage credits/plans, complete purchases/subscriptions, apply promos, and receive clear entitlement outcomes.
**FRs covered:** FR27, FR28, FR29, FR30, FR31, FR47, FR51

### Epic 5: Superadmin Operations, Risk Controls & Product Analytics
Superadmins can configure plans/promos, monitor business and behavior analytics, execute auditable risk containment/incident controls, and manage email pipeline analytics and admin-level sending.
**FRs covered:** FR35, FR36, FR37, FR38, FR39, FR43, FR49, FR53, FR57, FR58, FR64, FR69, FR73, FR76, FR78, FR79
**Refinements:** include PHI-safe analytics taxonomy and governance gates as explicit story acceptance criteria.

### Epic 6: Notifications, Incident Communication & Support
Users can receive clear event/incident messaging, configure notifications, and request support from critical failure contexts; the system provides a unified email pipeline for all email types with delivery tracking.
**FRs covered:** FR32, FR33, FR34, FR65, FR68, FR77

### Epic 7: Cross-Cutting Compliance, Privacy & Safe AI Guardrails
System-wide controls enforce PHI-safe telemetry and AI disclaimer safety framing across all epic implementations.
**FRs covered:** FR40, FR42
**Refinements:** applies as mandatory acceptance criteria overlay across stories in Epics 1-6.

## Epic 0: Backend Foundation — Real Persistence, JWT Auth & API Wiring

All NestJS API services are production-ready: in-memory Maps are replaced with TypeORM + PostgreSQL, JWT access/refresh tokens are properly issued and rotated, DB-backed sessions drive the session-list and revoke flows, and E2E tests pass against a real test database.

### Story 0.1: TypeORM Integration, Database Entities & Migrations

As a developer,
I want the NestJS API connected to PostgreSQL via TypeORM with versioned migrations,
So that all Epic 1 data persists across restarts and is schema-controlled.

**Acceptance Criteria:**

**Given** the API starts
**When** DATABASE_URL points to a running Postgres instance
**Then** TypeORM connects, runs pending migrations, and the schema is present
**And** `npm run migration:run` applies migrations idempotently
**And** `docker compose up` starts Postgres and the schema is auto-migrated on API start in dev

**Entities required:** User, Session, Profile, AccountPreference, Restriction, DataExportRequest, ClosureRequest, PasswordResetToken, ConsentRecord

**Technical Notes:**
- Install `@nestjs/typeorm`, `typeorm`, `pg`, `@nestjs/config`
- `TypeOrmModule.forRootAsync` reads `DATABASE_URL` from env
- Migrations in `src/database/migrations/`; entities in `src/database/entities/`
- `.env.example` documents all required env vars
- `npm run migration:generate` and `npm run migration:run` scripts added

### Story 0.2: JWT Access + Refresh Token Auth with DB-Backed Sessions

As an authenticated user,
I want access tokens (short-lived) and refresh tokens (long-lived, stored in DB),
So that my session survives app restarts, rotates on refresh, and can be revoked remotely.

**Acceptance Criteria:**

**Given** I log in successfully
**When** the API responds
**Then** I receive `{ accessToken, refreshToken, expiresIn }` where accessToken TTL is 15 min and refreshToken TTL is 30 days
**And** the refreshToken is stored hashed in the Session entity along with IP, user-agent, and timestamps

**Given** I call `POST /auth/refresh` with a valid refreshToken
**When** the token is valid and not revoked
**Then** I receive new accessToken + refreshToken (rotation)
**And** the old refreshToken is invalidated

**Given** I call `POST /auth/logout`
**When** my session exists
**Then** the Session is deleted from DB and both tokens are unusable

**Given** the AuthGuard validates a request
**When** the JWT is valid (signature + expiry)
**Then** the request proceeds without a DB lookup (stateless JWT verification)
**And** userId and sessionId are extracted from JWT claims

**Technical Notes:**
- Install `@nestjs/jwt`, `@nestjs/passport`, `passport`, `passport-jwt`, `bcryptjs`
- Access token payload: `{ sub: userId, sessionId, iat, exp }`
- Refresh token: 256-bit crypto random, stored as SHA-256 hash in Session entity
- `POST /auth/refresh` is public (no AuthGuard); validates hash match + expiry
- Session entity stores: userId, refreshTokenHash, ipAddress, userAgent, createdAt, expiresAt
- `GET /auth/sessions` returns all active sessions for current user from DB
- `DELETE /auth/sessions/:id` deletes that Session row (revoke)

### Story 0.3: Replace All In-Memory Services with TypeORM Repositories

As a developer,
I want all five in-memory Map stores replaced with TypeORM repositories,
So that all Epic 1 data is durable and the API behaves identically after restart.

**Acceptance Criteria:**

**Given** the API restarts
**When** I log in and create profiles/preferences/etc.
**Then** all data is present after restart (no in-memory state)
**And** all existing unit tests pass with mocked TypeORM repositories
**And** the external API contract (routes, request/response shapes) is unchanged

**Services to migrate:**
- `AuthService`: users from User repo (bcrypt password hash), sessions from Session repo, rate-limit state stays in-memory (Redis later)
- `PasswordRecoveryService`: reset tokens stored in PasswordResetToken repo (hashed, TTL enforced by expiry column)
- `ProfilesService`: profiles and activeProfileId from Profile repo (userId FK, isActive column)
- `AccountService`: AccountPreference, Restriction, DataExportRequest, ClosureRequest from their respective repos
- `ConsentService`: ConsentRecord repo (userId, policyVersion, acceptedAt)

**Technical Notes:**
- Each service receives TypeORM `Repository<Entity>` via `@InjectRepository`
- User passwords stored as bcrypt hash (cost 12); plaintext never stored
- EntitlementsService checks `maxProfiles` via DB query on Profile entity count

### Story 0.4: E2E Test Infrastructure with Real Test Database

As a developer,
I want E2E tests running against a real Postgres test database,
So that integration coverage is meaningful and the test suite is not fragile.

**Acceptance Criteria:**

**Given** `npm run test:e2e` executes
**When** the test suite runs
**Then** a separate test database (`doclyzer_test`) is used (never the dev DB)
**And** each test suite truncates relevant tables in `beforeEach` or `afterEach`
**And** all existing E2E test cases from stories 1.1–1.10 pass

**Technical Notes:**
- `test/jest-e2e.json` configured with `globalSetup` for DB bootstrap
- `AppModule` in tests uses `DATABASE_URL` from `.env.test`
- Helper `test/db-cleaner.ts` exports `clearDatabase(dataSource)` that truncates all tables
- CI can run `docker compose up -d postgres && npm run test:e2e`
- No mocking of TypeORM in E2E tests; real DB only

### Story 0.5: Backblaze B2 Object Storage for Reports, Profile Pictures, and File Uploads

As a developer,
I want all user-uploaded files (report PDFs, profile/account avatars, and other assets) stored in Backblaze B2 via an S3-compatible API,
So that storage is durable, scalable, and not tied to local disk, and access is controlled via signed URLs or application-served streams.

**Acceptance Criteria:**

**Given** the API is configured with valid B2 credentials (key ID, application key, bucket name, endpoint)
**When** a user uploads a report PDF or profile avatar
**Then** the file is uploaded to the configured B2 bucket with a deterministic key structure (e.g. `reports/{userId}/{profileId}/{reportId}.pdf`, `avatars/{userId}.{ext}`)
**And** the database record stores the B2 key (or URL path) for later retrieval
**And** no file is stored on local disk in production (local disk allowed only for dev/test when B2 is disabled or mocked)

**Given** a client requests to read an uploaded file (e.g. view PDF, avatar image)
**When** the user is authorized to access that resource
**Then** the API serves the file via a short-lived signed URL from B2 or streams it through the API
**And** bucket and keys are not publicly listable or directly accessible without authorization

**Given** a user deletes a report or account closure removes data
**When** the delete is committed
**Then** the corresponding object(s) in B2 are deleted (or scheduled for deletion) so that storage is not left with orphans

**Given** B2 is unavailable or misconfigured
**When** an upload is attempted
**Then** the API returns a clear error and does not leave the DB in an inconsistent state (no report/avatar record without a stored file)

**Technical Notes:**
- Use an S3-compatible client (e.g. `@aws-sdk/client-s3` with B2 endpoint, or `aws4fetch` / custom) and inject config from env: `B2_KEY_ID`, `B2_APPLICATION_KEY`, `B2_BUCKET_NAME`, `B2_ENDPOINT` (e.g. `https://s3.us-west-002.backblazeb2.com`).
- Introduce a small abstraction (e.g. `FileStorageService` or `ObjectStorageService`) so that upload/delete/get URL are in one place and B2 can be swapped or mocked in tests.
- Avatar upload (account controller) and report upload flows must use this service instead of `diskStorage` (multer); multipart still handled by multer, then stream or buffer to B2.
- Document key naming and lifecycle in project context or architecture; ensure account closure and data-export flows consider B2 objects.

## Epic 1: Account Security, Consent, Profile & Delegation Foundation

Users can securely onboard, manage account/session controls, accept legal policies, exercise data rights, and manage multi-profile account safety foundations.

### Story 1.1: Account Registration, Login, Logout

As a visitor or registered user,
I want to create an account and securely sign in/out,
So that I can access my Doclyzer workspace safely.

**Acceptance Criteria:**

**Given** I am a new visitor on the auth screen
**When** I submit valid registration details and required policy acknowledgment
**Then** my account is created successfully
**And** I am routed through required verification/login flow.

### Story 1.2: Password Recovery and Secure Session Rotation

As a registered user,
I want to recover access when I forget credentials,
So that I can regain access without compromising security.

**Acceptance Criteria:**

**Given** I trigger forgot-password
**When** I complete valid recovery challenge
**Then** my password is reset
**And** session/token rotation and revocation policies are enforced.

### Story 1.3: Account Profile Management (View/Update Basic Info)

As an authenticated user,
I want to view and update account basics,
So that my profile remains accurate.

**Acceptance Criteria:**

**Given** I submit valid editable fields
**When** I save changes
**Then** updates persist
**And** invalid/restricted fields are rejected safely.

### Story 1.4: Policy Acceptance with Version Tracking

As an authenticated user,
I want to accept Terms/Privacy with version tracking,
So that compliance state is explicit and current.

**Acceptance Criteria:**

**Given** a required policy version is pending
**When** I accept it
**Then** acceptance record stores user, version, and timestamp
**And** I am only reprompted when versions change.

### Story 1.5: Multi-Profile Create/Edit/Switch

As an account holder,
I want to create, edit, and switch profiles,
So that I can manage self/family safely.

**Acceptance Criteria:**

**Given** multiple profiles exist
**When** I switch active profile
**Then** all subsequent views/actions are scoped to that profile.

**Given** I am on the free tier and already have 1 profile
**When** I attempt to create another profile
**Then** creation is blocked with clear upgrade guidance (API returns 403 PROFILE_LIMIT_EXCEEDED; app shows upgrade CTA).

### Story 1.6: Profile Deletion with Confirmation and Impact Messaging

As an account holder,
I want guarded profile deletion,
So that I avoid accidental data-context loss.

**Acceptance Criteria:**

**Given** I initiate deletion
**When** I confirm with impact awareness
**Then** eligible profile is deleted/deactivated per policy
**And** unsafe deletions are blocked with guidance.

### Story 1.7: Active Session/Device List and Revoke

As an authenticated user,
I want to view and revoke sessions,
So that I can secure my account.

**Acceptance Criteria:**

**Given** I revoke a selected active session
**When** revocation succeeds
**Then** that session loses access immediately
**And** audit logs record the action.

### Story 1.8: Communication Preferences Management

As an authenticated user,
I want communication preference controls,
So that I receive relevant notices.

**Acceptance Criteria:**

**Given** I update preferences
**When** changes are saved
**Then** future delivery respects settings
**And** mandatory notices remain enforced by policy.

### Story 1.9: Data Export and Account Closure Requests

As an authenticated user,
I want export/closure workflows,
So that I can exercise data rights.

**Acceptance Criteria:**

**Given** I request export or closure
**When** workflow progresses
**Then** status is visible and auditable
**And** access-state changes follow policy.

### Story 1.10: Restriction Visibility, Rationale, and User Next Steps

As an authenticated user,
I want restriction clarity,
So that blocked actions are understandable and recoverable.

**Acceptance Criteria:**

**Given** my account is restricted
**When** I access affected surfaces
**Then** I see restriction status, rationale, and next steps.

## Epic 2: Report Ingestion, Processing Recovery & Timeline Insights

Users can upload reports, recover from parsing failures, and consume timeline/trend/summary value with deterministic lifecycle states.

### Story 2.0: PostgreSQL Persistence Setup (Foundation)

As a developer,
I want the API backed by PostgreSQL instead of in-memory stores,
So that data persists across restarts and meets architecture/PRD requirements.

**Acceptance Criteria:**

**Given** the NestJS API runs
**When** connected to PostgreSQL (via docker-compose)
**Then** auth (users, sessions), profiles, consent, account (prefs, restrictions, export/closure requests) are persisted
**And** migrations are versioned and runnable
**And** existing e2e tests pass with DB-backed implementation
**And** local dev uses `docker compose up` for Postgres + API

**Technical Notes:**
- Use TypeORM or Prisma per architecture; entities for users, sessions, profiles, consent, account data
- Replace in-memory Map usage in AuthService, AccountService, ProfilesService, ConsentService, PasswordRecoveryService
- Wire API to DATABASE_URL from env; document in README

### Story 2.1: Upload Report to Active Profile

As an authenticated user,
I want to upload a supported report to active profile,
So that it enters my health record.

**Acceptance Criteria:**

**Given** I upload a valid file
**When** upload completes
**Then** report is stored against active profile
**And** processing lifecycle starts.

### Story 2.2: Parsing Status Lifecycle Visibility

As an authenticated user,
I want clear processing states,
So that I understand progress and outcomes.

**Acceptance Criteria:**

**Given** processing runs
**When** state changes occur
**Then** deterministic states are shown consistently across surfaces.

### Story 2.3: Parse Failure Recovery (Retry + Keep File Anyway)

As an authenticated user,
I want retry and keep-file options,
So that failed parsing does not block usage.

**Acceptance Criteria:**

**Given** parsing fails
**When** I choose retry or keep-file
**Then** system executes selected recovery path deterministically.

### Story 2.4: Original PDF Viewing (Parsed and Unparsed)

As an authenticated user,
I want original file access always,
So that source documents remain available.

**Acceptance Criteria:**

**Given** I have authorization
**When** I open original file
**Then** document is accessible regardless of parse status.

### Story 2.5: Duplicate Report Detection and User Choice

As an authenticated user,
I want duplicate detection with explicit choice,
So that accidental duplicates are reduced.

**Acceptance Criteria:**

**Given** potential duplicate is detected
**When** I choose keep-existing or upload-anyway
**Then** outcome follows my choice and is auditable.

### Story 2.6: Timeline View Scoped to Active Profile

As an authenticated user,
I want timeline scoped to active profile,
So that cross-profile leakage is prevented.

**Acceptance Criteria:**

**Given** timeline renders
**When** active profile changes
**Then** data updates strictly to new scope.

### Story 2.7: Structured Lab Extraction Display

As an authenticated user,
I want structured lab values,
So that I can quickly read parameters.

**Acceptance Criteria:**

**Given** extraction exists
**When** report details load
**Then** parameter/value/unit/date fields render safely.

### Story 2.8: Trend Chart Rendering for Chartable Parameters

As an authenticated user,
I want trend charts over time,
So that longitudinal changes are visible.

**Acceptance Criteria:**

**Given** chartable data points exist
**When** trend view opens
**Then** chart renders with deterministic fallback for insufficient points.

### Story 2.9: Report-Level Summary Display with Safe Framing

As an authenticated user,
I want concise summaries,
So that report meaning is quickly understandable.

**Acceptance Criteria:**

**Given** summary is available
**When** displayed
**Then** informational-only safety framing is visible.

### Story 2.10: Profile-Level Consolidated Health History

As an authenticated user,
I want consolidated profile history,
So that I can review aggregated insights.

**Acceptance Criteria:**

**Given** profile has multiple reports
**When** consolidated view loads
**Then** aggregated state is consistent and profile-scoped.

### Story 2.11: Processing Attempt History per Report

As an authenticated user,
I want attempt history visibility,
So that retries/outcomes are transparent.

**Acceptance Criteria:**

**Given** report has attempts
**When** I open attempt history
**Then** attempts are chronologically visible and immutable.

### Story 2.12: Post-Upload Report Reassignment to Correct Profile

As an authenticated user,
I want reassignment of mistakenly scoped reports,
So that profile organization remains accurate.

**Acceptance Criteria:**

**Given** I confirm reassignment
**When** operation succeeds
**Then** report and derived views move to target profile without leakage.

### Story 2.13: Real AI Report Summary Pipeline (Replace Stub)

As an authenticated user,
I want each parsed report to have a real AI-generated summary (not stub text),
so that I get meaningful, report-specific summaries.

**Acceptance Criteria:**

**Given** a report is successfully parsed
**When** the parse pipeline completes
**Then** the AI summariser is invoked and the result is persisted to `report.summary`
**And** the same summary is returned via existing report endpoints (no API contract change)

**Given** the AI summariser fails or is disabled
**When** the report is saved with status `parsed`
**Then** `report.summary` is null (or a defined fallback); no PHI in logs

**Given** parsing fails
**Then** no AI call; `report.summary` remains null

### Story 2.14: Persist Docling Parsed Report Transcript in DB

As a developer,
I want the parsed report transcript (Docling output) stored in the database,
so that we have a durable record for summarisation, re-use without re-parsing, and optional future display.

**Acceptance Criteria:**

**Given** a report is successfully parsed
**When** the parser returns a transcript
**Then** the transcript is persisted (e.g. `parsed_transcript` column on `reports`)

**Given** parsing fails or no transcript is returned
**Then** the transcript column remains `null`

**Given** a report has a stored transcript
**When** the API returns the report via `GET /reports/:id`
**Then** the response includes the transcript for backend and client use; no transcript content in logs (PHI-safe)

## Epic 3: Web Experience - Share Recipient + SEO Landing (Nuxt)

Users can share profile-scoped data to recipients and provide SEO-ready landing experience with route isolation.

### Story 3.1: Create Share Link for Active Profile Scope

As an authenticated user,
I want scoped share-link creation,
So that recipients access intended data only.

**Acceptance Criteria:**

**Given** I create a link for active profile scope
**When** creation succeeds
**Then** signed token is generated with scope metadata.

### Story 3.2: Share-Link Expiry and Revocation Controls

As an authenticated user,
I want expiry/revoke controls,
So that access can be limited or stopped.

**Acceptance Criteria:**

**Given** link exists
**When** I revoke or it expires
**Then** recipient access is denied deterministically.

### Story 3.3: Default Share Policy Settings for New Links

As an authenticated user,
I want default share policies,
So that repeated link creation is faster.

**Acceptance Criteria:**

**Given** defaults are configured
**When** new link flow opens
**Then** defaults prefill and remain overridable.

### Story 3.4: Copy/Distribute Share Link UX

As an authenticated user,
I want copy/share actions,
So that distribution is low-friction.

**Acceptance Criteria:**

**Given** link exists
**When** I choose copy/share
**Then** action succeeds with clear feedback.

### Story 3.5: Recipient Access via Valid Link (No Account)

As a recipient,
I want no-login access to valid links,
So that shared context is easy to consume.

**Acceptance Criteria:**

**Given** link is valid
**When** opened
**Then** shared view loads without account requirement.

### Story 3.6: Doctor-Friendly Share Page (Timeline + Trends, Print-Friendly)

As a recipient,
I want a readable doctor-friendly page,
So that consultation usage is practical.

**Acceptance Criteria:**

**Given** share page renders
**When** viewed or printed
**Then** timeline/trends remain readable and structured.

### Story 3.7: Share Access Event History for Link Owner

As a link owner,
I want access-event history,
So that I can monitor usage.

**Acceptance Criteria:**

**Given** access attempts occur
**When** I open history
**Then** timestamp/link/outcome records are visible.

### Story 3.8: Enforce Profile Isolation in Shared Output

As an account holder,
I want strict scope isolation,
So that non-shared profiles never leak.

**Acceptance Criteria:**

**Given** link is scoped
**When** recipient loads it
**Then** only scoped data is returned.

### Story 3.9: Landing SEO MVP (Metadata, Canonical, Sitemap/Robots, Structured Data)

As a prospective user,
I want SEO-ready landing pages,
So that discovery and value communication improve.

**Acceptance Criteria:**

**Given** landing routes are public
**When** crawled
**Then** metadata, canonical, sitemap/robots, and structured data are valid.

### Story 3.10: Route Isolation Rules (Indexable Landing vs Non-Indexable Share)

As a platform owner,
I want route policy isolation,
So that landing is indexable and share is private.

**Acceptance Criteria:**

**Given** routing policy is applied
**When** bots/users access routes
**Then** landing is indexable and share is non-indexable by default.

## Epic 4: Monetization, Entitlements & Checkout

Users can manage credits/plans, complete purchases, apply promos, and understand entitlement outcomes.

### Story 4.1: Credit Balance and Entitlement Summary View

As an authenticated user,
I want balance/entitlement visibility,
So that usage posture is clear.

**Acceptance Criteria:**

**Given** billing view loads
**When** data is fetched
**Then** balance and active entitlement are accurate.

### Story 4.2: Credit Pack Purchase Flow

As an authenticated user,
I want credit-pack checkout,
So that I can continue usage.

**Acceptance Criteria:**

**Given** payment succeeds
**When** reconciliation completes
**Then** credits are reflected in entitlement state.

### Story 4.3: Subscription Purchase Flow

As an authenticated user,
I want paid-plan subscription,
So that premium limits/features unlock.

**Acceptance Criteria:**

**Given** subscription purchase succeeds
**When** entitlement updates
**Then** new plan state is visible and enforceable.

### Story 4.4: Promo Code Apply/Validate at Checkout

As an authenticated user,
I want promo validation,
So that eligible discounts apply correctly.

**Acceptance Criteria:**

**Given** promo entered at checkout
**When** validated
**Then** eligible discounts apply or safe errors are shown.

### Story 4.5: Usage Limit Enforcement (Free/Paid Tiers)

As a product user,
I want consistent tier-limit enforcement,
So that actions are predictably allowed/blocked.

**Acceptance Criteria:**

**Given** usage action is limit-governed
**When** evaluated
**Then** action follows entitlement policy with clear guidance.

**Governed limits:** profile creation (free: 1; paid: multiple), reports (free: cap; paid: credits), share links (free: 1; paid: higher).

### Story 4.6: Billing Outcome States (Pending/Failed/Reconciled)

As an authenticated user,
I want clear billing lifecycle states,
So that payment outcomes are understandable.

**Acceptance Criteria:**

**Given** billing lifecycle changes
**When** status updates
**Then** pending/failed/reconciled states remain deterministic.

### Story 4.7: Entitlement Change Reason Visibility

As an authenticated user,
I want entitlement change reasons,
So that billing/access changes are transparent.

**Acceptance Criteria:**

**Given** entitlement changes
**When** I inspect details
**Then** reason and timestamp are visible.

## Epic 5: Superadmin Operations, Risk Controls & Product Analytics

Superadmins can manage plans/promos, analyze usage/revenue/behavior, and operate incident risk controls with full auditability.

### Story 5.1: Superadmin Authentication Hardening (MFA + Role Guard Baseline)

As a superadmin,
I want MFA and strict role guards,
So that admin operations are protected.

**Acceptance Criteria:**

**Given** admin login succeeds
**When** privilege elevation is attempted
**Then** MFA and role checks are enforced.

### Story 5.2: Plan Definition and Limit Configuration Management

As a superadmin,
I want plan configuration controls,
So that entitlements can be managed operationally.

**Acceptance Criteria:**

**Given** plan config changes
**When** saved
**Then** validated changes persist with audit trace.

**Configurable limits:** maxProfilesPerPlan (free: 1; paid: multiple or unlimited), report cap, share-link limit.

### Story 5.3: Promo Code CRUD and Lifecycle Management

As a superadmin,
I want promo lifecycle controls,
So that campaign operations are manageable.

**Acceptance Criteria:**

**Given** promo CRUD actions occur
**When** validated and saved
**Then** promo lifecycle state updates safely.

### Story 5.4: Promo Redemption and Revenue Impact Analytics

As a superadmin,
I want promo performance analytics,
So that campaign effectiveness is measurable.

**Acceptance Criteria:**

**Given** promo events are processed
**When** analytics are viewed
**Then** redemption and revenue impact are visible.

### Story 5.5: Core Product Analytics Dashboard (Signups/Usage/Monetization/Behavior)

As a superadmin,
I want core dashboard metrics,
So that product/business health is monitorable.

**Acceptance Criteria:**

**Given** analytics data is available
**When** dashboard loads
**Then** signups/usage/monetization/behavior metrics render consistently.

### Story 5.6: PHI-Safe Analytics Taxonomy and Governance Controls

As a platform owner,
I want PHI-safe taxonomy governance,
So that analytics never leak sensitive data.

**Acceptance Criteria:**

**Given** event instrumentation changes
**When** governance validation runs
**Then** PHI violations are blocked and surfaced.

### Story 5.7: Auditable Superadmin Action Logging

As a compliance stakeholder,
I want immutable admin audit logs,
So that high-risk actions are traceable.

**Acceptance Criteria:**

**Given** admin action executes
**When** logging occurs
**Then** actor/action/target/time/outcome are captured.

### Story 5.8: Access/Share/Consent/Policy Records Query Console

As a superadmin,
I want governance records query,
So that investigations are efficient.

**Acceptance Criteria:**

**Given** authorized query parameters
**When** query runs
**Then** access/share/consent/policy events are retrievable.

### Story 5.9: Suspicious Activity Detection and Review Queue

As a superadmin,
I want suspicious activity queueing,
So that risk triage is prioritized.

**Acceptance Criteria:**

**Given** detection rules trigger
**When** events are processed
**Then** review queue items are created with severity/state.

### Story 5.10: Share Link / Account Suspension and Restore Controls

As a superadmin,
I want suspend/restore controls,
So that risk containment is immediate and reversible.

**Acceptance Criteria:**

**Given** target is risky
**When** suspend/restore action is executed
**Then** target access state updates and is auditable.

### Story 5.11: Temporary Protective Restriction and Restricted Review Mode

As a superadmin,
I want temporary restriction controls,
So that investigations can proceed safely.

**Acceptance Criteria:**

**Given** restriction is applied
**When** account is evaluated
**Then** configured capability limits are enforced deterministically.

### Story 5.12: Time-Bound Override Actions with Expiry

As a superadmin,
I want expiring overrides,
So that exceptional controls are bounded.

**Acceptance Criteria:**

**Given** override is created with expiry
**When** expiry time passes
**Then** override auto-reverts and logs outcome.

### Story 5.13: Restricted-Account Resolution Documentation Workflow

As a superadmin,
I want closure documentation for restrictions,
So that post-incident accountability is complete.

**Acceptance Criteria:**

**Given** case closes
**When** resolution details are submitted
**Then** outcome documentation is stored and linked to audit trail.

### Story 5.14: Emergency Containment Actions with Mandatory Audit Notes

As a superadmin,
I want emergency containment with required notes,
So that urgent response remains accountable.

**Acceptance Criteria:**

**Given** emergency action is executed
**When** completion occurs
**Then** mandatory audit notes are captured.

### Story 5.15: Email Queue, Delivery Analytics & Sending History (Admin Panel)

As a superadmin,
I want to view email queue status, delivery analytics, and sending history in the admin panel,
So that I can monitor and troubleshoot all email types (transactional and admin-sent).

**Acceptance Criteria:**

**Given** I am an authenticated superadmin
**When** I open the email section of the admin panel
**Then** I can see queue status (pending, processing, completed)
**And** I can see delivery analytics: counts by type (e.g. password reset, notification, admin), outcome (sent, failed, bounced) and time range filters
**And** I can view sending history (timestamp, type, recipient scope, outcome) with pagination; no PHI in recipient display beyond what is needed for support (e.g. redacted or scope-only)
**And** all views are PHI-safe per NFR7; admin actions are auditable (NFR9)

### Story 5.16: Admin-Level Email Sending with Audit & Recipient Controls

As a superadmin,
I want to send admin-level emails (announcements, support, incident notifications) from the admin panel,
So that I can communicate with users in a controlled, auditable way.

**Acceptance Criteria:**

**Given** I am an authenticated superadmin
**When** I use the admin panel to send an admin-level email
**Then** I can choose type (e.g. announcement, incident notice, support), subject, body (with template support where applicable), and recipient scope (e.g. all users, segment, single)
**And** sending uses the same email pipeline (Story 6.6); delivery is tracked and visible in email analytics (Story 5.15)
**And** each send is audited: actor, action, recipient scope, timestamp, outcome; no PHI in audit payload beyond scope description
**And** optional approval or rate limits can be applied for safety

## Epic 6: Notifications, Incident Communication & Support

Users can receive notifications, control preferences, get clear incident messaging, and open support requests from failure contexts.

### Story 6.1: Notification Event Delivery for Account/Report/Billing Updates

As an authenticated user,
I want relevant notification delivery,
So that I stay informed of important events.

**Acceptance Criteria:**

**Given** a notifiable event occurs
**When** delivery rules execute
**Then** notification is sent/queued with tracked outcome.

### Story 6.2: Notification Preference Controls by Category

As an authenticated user,
I want category preference controls,
So that communication matches my choices.

**Acceptance Criteria:**

**Given** I update category preferences
**When** saved
**Then** future deliveries follow settings (except mandatory notices).

### Story 6.3: Consistent In-App Success/Failure/Recovery Messaging Patterns

As a product user,
I want clear in-app status messaging,
So that critical flows are understandable and recoverable.

**Acceptance Criteria:**

**Given** flow outcome changes
**When** message renders
**Then** standardized success/failure/recovery patterns are shown.

### Story 6.4: Major Service Incident Status Communication to Users

As a product user,
I want major incident notices,
So that affected workflows are understandable.

**Acceptance Criteria:**

**Given** major incident is active
**When** I use affected surfaces
**Then** current incident notice and status are shown.

### Story 6.5: In-Product Support Requests Linked to Failed Critical Actions

As a product user,
I want support from failure context,
So that triage includes relevant action metadata.

**Acceptance Criteria:**

**Given** critical action fails
**When** support request is created from failure state
**Then** request includes linked action/correlation identifiers.

### Story 6.6: Email Pipeline — Delivery, Tracking & Template Support

As a platform,
I want a unified email pipeline for all outbound email types,
So that transactional and product emails are sent with consistent delivery, status tracking, and template support.

**Acceptance Criteria:**

**Given** the system sends any email (password reset, notifications, security/compliance, etc.)
**When** the email pipeline is invoked
**Then** the message is queued/sent via a configured provider with delivery status and tracking (sent, failed, bounced where available)
**And** templates are supported per email type and respect user communication preferences where applicable
**And** pipeline failures use retry/backoff and terminal state handling; no PHI in logs

**Technical Notes:** Single pipeline used by auth (password reset), account (notices), and future notification flows; admin sending (FR79) uses the same pipeline. Delivery analytics (FR78) consume pipeline status data.

## Epic 7: Cross-Cutting Compliance, Privacy & Safe AI Guardrails

System-wide controls enforce AI informational framing and PHI-safe telemetry across all epic implementations.

### Story 7.1: AI Informational-Only Disclaimer Enforcement Across Surfaces

As a platform owner,
I want AI disclaimers enforced wherever AI-derived output appears,
So that safety framing is consistent.

**Acceptance Criteria:**

**Given** AI-derived content is rendered
**When** surface loads
**Then** informational-only disclaimer is visible and non-optional.

### Story 7.2: PHI-Safe Telemetry and Operational Logging Enforcement

As a platform owner,
I want PHI-safe telemetry enforcement,
So that observability does not leak sensitive data.

**Acceptance Criteria:**

**Given** logs/events are emitted
**When** payload validation runs
**Then** PHI fields are blocked/redacted per policy.

### Story 7.3: Compliance Guardrail Test Gates (CI/CD Policy Checks)

As an engineering owner,
I want CI/CD compliance gates,
So that non-compliant changes are blocked before release.

**Acceptance Criteria:**

**Given** pipeline executes on relevant changes
**When** compliance checks fail
**Then** build/release is blocked with actionable failures.

### Story 7.4: Cross-Epic Guardrail Conformance Checklist and Audit Evidence

As a compliance stakeholder,
I want cross-epic conformance evidence,
So that audits can verify guardrail adoption.

**Acceptance Criteria:**

**Given** stories are completed across epics
**When** conformance review runs
**Then** checklist and evidence artifacts are produced and queryable.
