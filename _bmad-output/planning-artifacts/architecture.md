---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
inputDocuments: ["product-brief-doclyzer-2026-03-01.md", "ux-design-specification.md"]
workflowType: 'architecture'
project_name: 'doclyzer'
user_name: 'Vishnu'
date: '2026-03-01'
lastStep: 8
status: 'complete'
completedAt: '2026-03-03'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:**
The product requires end-to-end support for patient profile lifecycle, report upload/parse/recovery workflows, longitudinal health views, share-link based recipient access, monetization (credits/subscription/promo), superadmin operations, and governance capabilities (consent, auditability, policy acceptance, account/session controls). Architecturally, this implies clear bounded contexts and explicit ownership of asynchronous state transitions.

**Non-Functional Requirements:**
Architecture must satisfy strict security/privacy constraints (PHI-safe telemetry, encryption, access isolation), availability/reliability targets for core journeys, scalability for parse/AI queues, accessibility standards, and operational observability with incident response readiness.

**Scale & Complexity:**
- Primary domain: mobile-first healthcare platform with web sharing and admin surfaces
- Complexity level: high-regulated, async-heavy, multi-surface
- Estimated architectural capability domains: identity/access, profile domain, report ingestion/parsing orchestration, timeline/query services, sharing/access control, billing/entitlements, compliance/audit, notification, admin analytics, integration adapters

### Technical Constraints & Dependencies

- Regulatory/privacy pressure (health data handling, consent, policy traceability) is a first-order architecture constraint.
- Parser/AI dependency behavior must be isolated from user-facing consistency and reliability guarantees.
- Payment and entitlement systems must remain consistent with asynchronous events and retries.
- Dependency map includes parser, AI, payment, and notification providers as critical external systems with required fallback behavior.
- External dependency failures must degrade to predefined safe behavior while preserving baseline access to existing user data.
- PHI-bearing clinical/report data domain is isolated from billing/entitlement and admin analytics domains with explicit controlled interfaces.
- Architecture currently lacks decision coverage in the existing artifact (`stepsCompleted: [1]` only), so core decisions remain open.

### Cross-Cutting Concerns Identified

- Authentication, authorization, and profile-level data isolation
- Consent lifecycle and legal-policy acceptance evidence
- Audit trails for access/share/admin/restriction actions
- Async workflow idempotency and reconciliation
- Security incident containment and recoverability
- PHI-safe analytics/logging and operational monitoring (no PHI in telemetry)
- UX-aligned performance and status transparency across mobile and share-web surfaces
- User-visible workflow states must be monotonic and reconcilable across app, share web, and admin surfaces

### Architecture Context ADR Baselines

- ADR-CX1: Domain Separation Baseline - PHI clinical/report domain is isolated from billing/entitlement and admin analytics domains.
- ADR-CX2: State Transparency Contract - user-visible lifecycle states must remain deterministic across all surfaces.
- ADR-CX3: Dependency Degradation Contract - parser/AI/payment failures must degrade safely without blocking baseline document access.
- ADR-CX4: Auditability Baseline - consent, policy acceptance, access, sharing, and incident actions must emit queryable audit events.
- ADR-CX5: Readiness Closure Objective - upcoming architecture decisions must explicitly close readiness blockers around architecture depth and FR traceability scaffolding.

## Starter Template Evaluation

### Primary Technology Domain

Mobile-first healthcare platform with three core surfaces:
- Flutter mobile application
- NestJS backend API
- Nuxt web surface for landing + share experience

### Starter Options Considered

- Flutter official scaffold via `flutter create`
- NestJS official scaffold via `nest new --strict`
- Nuxt official scaffold via `npx nuxi@latest init` (or `npm create nuxt@latest`)

### Selected Starter Foundation

Use official starters per surface, with a single Nuxt codebase initially for both landing and share routes, and explicit isolation controls for security and release boundaries.

### Initialization Commands

```bash
# Flutter app
flutter create --org com.envsoft.doclyzer --platforms=android,ios doclyzer_app

# NestJS backend
npm i -g @nestjs/cli
nest new doclyzer_api --strict

# Nuxt web app (landing + share)
npx nuxi@latest init doclyzer_web
```

### Architectural Decisions Provided by Starters

**Flutter Starter**
- Standard project layout and platform scaffolding for iOS/Android.
- Baseline build/test/dev workflow conventions.

**NestJS Starter**
- Module/controller/service architecture baseline.
- Strict TypeScript setup and test scaffold.

**Nuxt Starter**
- SSR-capable web foundation suitable for SEO-sensitive landing routes.
- Server-rendered/public web baseline for share and landing surfaces.

### ADR Refinements from Starter Evaluation

- ADR-S3-01: Web Framework Choice - Nuxt selected for web surfaces.
- ADR-S3-02: Landing SEO Baseline - metadata, social tags, sitemap/robots, canonical strategy, structured data are mandatory.
- ADR-S3-03: Superadmin Analytics Capability - analytics must support usage behavior, funnel, retention, conversion, promo, and anomaly insights.
- ADR-S3-04: Privacy-Safe Telemetry Guardrail - no PHI in analytics payloads.
- ADR-S3-05: Surface Partitioning - Flutter mobile, NestJS API, Nuxt web.

### Operating Constraints from Evaluation

- Landing routes are indexable; share routes are non-indexable by default.
- Single Nuxt codebase is acceptable initially, but route-level trust boundaries are mandatory.
- A split-share-surface decision is allowed later if threat model or scale requires stronger isolation.
- Independent release gates are required so landing changes cannot degrade share reliability.
- Analytics taxonomy/governance ownership must be explicit before superadmin analytics rollout.
- SEO schema ownership and privacy compliance review ownership must be explicit.
- Dependency failures (parser/AI/payment/analytics pipeline) must degrade safely without blocking baseline user access to existing documents.
- Starter decisions must directly support closure of readiness blockers: architecture depth and FR-to-implementation traceability scaffolding.

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
- Data architecture baseline and domain partitioning
- Authentication and authorization model
- API communication contracts and async state handling
- Frontend state transparency and route-boundary policies
- Infrastructure deployment isolation and release gates

**Important Decisions (Shape Architecture):**
- Caching and reconciliation behavior
- Observability/correlation standards
- Accessibility/performance posture in frontend surfaces
- CI/CD quality gates for compliance and SEO

**Deferred Decisions (Post-MVP):**
- Social login expansion
- Nuxt surface split into separate deployables (if threat model or scale requires)
- Advanced analytics warehouse optimization

### Data Architecture

- Primary database: PostgreSQL as transactional source of truth.
- Domain partitioning: separate logical domains for clinical/report, identity/profile, billing/entitlements, and audit/compliance.
- Event/reconciliation model: durable event-log pattern for parse/payment/entitlement convergence.
- Caching strategy: Redis for ephemeral acceleration only; no authoritative PHI state in cache.
- Migration strategy: versioned forward migrations with mandatory rollback planning and verification checks.
- Validation strategy: strict server-side validation at domain boundaries with schema versioning for key payloads.
- Idempotency baseline: required for upload/payment mutation paths.
- Analytics boundary: derived/de-identified analytics views only; never source of truth.

### Authentication & Security

- Authentication baseline: email/password plus verification/OTP baseline; social auth deferred.
- Session model: short-lived access tokens with rotating refresh tokens and server-side revocation.
- Authorization model: RBAC + profile-scoped ownership checks on PHI-bearing operations.
- Superadmin security: mandatory MFA and elevated-action audit trails.
- API security baseline: signed tokens, rate limiting, abuse throttling, strict input validation.
- Encryption boundaries: TLS in transit and encryption at rest with key isolation policies between PHI and analytics/admin derivatives.
- Share-link security: signed scoped tokens, expiry/revoke, non-indexable by default, audited access events.
- Restriction controls: suspicious-activity flagging, reversible containment actions, deterministic user-visible restriction states.

### API & Communication Patterns

- External API style: REST-first with explicit resource boundaries and versioning policy.
- Async workflow contract: long-running operations expose status resources and deterministic state transitions.
- Error contract: standardized envelope with stable error codes, user-safe messages, and correlation IDs.
- Idempotency: mandatory for upload, payment, and share-generation write operations.
- Internal communication: synchronous calls for core CRUD; event-driven messaging for cross-domain reconciliation.
- Retry/failure policy: bounded retries + dead-letter handling with deterministic terminal states.
- Traceability: correlation propagation across API and worker boundaries with no PHI in logs.

### Frontend Architecture

- Mobile state architecture: explicit domain slices (`auth`, `profiles`, `reports`, `share`, `billing`, `admin-insights-view`).
- Nuxt route partitioning: strict landing vs share route groups.
- UI-state transparency contract: frontend states map directly to backend lifecycle states for parse/payment/share.
- Performance posture: lazy loading and route-level optimization across landing/share surfaces.
- Accessibility baseline: shared standards for semantics, contrast, keyboard/screen-reader support on critical journeys.
- Failure UX patterns: deterministic fallback states for dependency outages and async delays.

### Infrastructure & Deployment

- Surface deployment model: independent deployable units for mobile, API, and web with blast-radius controls.
- Environment strategy: dev/staging/prod separation with config parity and secret isolation.
- CI/CD quality gates: migration validation, no-PHI telemetry checks, SEO quality checks for landing, and security policy checks.
- Runtime resilience: health checks, autoscaling policy for workers, graceful degradation playbooks.
- Observability contract: metrics/logs/traces/audit searchability with ownership routing.
- Recovery posture: backup/restore drills, incident severity model, and reconciliation jobs for async state convergence.
- Release safety: controlled rollouts/canaries; landing-only regressions must not degrade share reliability.

### Decision Impact Analysis

**Implementation Sequence:**
1. Data and security foundations
2. API contracts and async workflow models
3. Frontend state/route consistency contracts
4. Infrastructure controls and operational gates

**Cross-Component Dependencies:**
- Data consistency model constrains API async contracts.
- API state contracts constrain frontend status behavior.
- Security and audit boundaries constrain all domains.
- Infrastructure gates enforce compliance and reliability expectations across surfaces.

## Implementation Patterns & Consistency Rules

### Pattern Categories Defined

**Critical conflict points identified:**
- Naming drift across DB/API/client layers
- API/error/async state format inconsistencies
- Event vocabulary/version drift
- Directory/test placement divergence
- Loading/error fallback behavior mismatch
- PHI logging/telemetry leakage risk

### Naming Patterns

**Database naming conventions:**
- Tables/columns/indexes use `snake_case`.
- Foreign keys use `<entity>_id`.

**API naming conventions:**
- Route paths use `kebab-case` and plural resources where applicable.
- JSON payload fields use `camelCase`.
- Query params use `camelCase`.

**Code naming conventions:**
- Type/class names use `PascalCase`.
- Variables/functions use `camelCase`.
- Filenames follow surface convention consistently within each codebase.

### Structure Patterns

**Project organization:**
- Feature-first modules with explicit shared/common boundaries.
- Cross-domain utilities must live in shared packages only if reused by 2+ domains.

**Test organization:**
- Unit/integration/e2e scopes are explicitly separated.
- Contract tests required for API/event schemas.

### Format Patterns

**API response format:**
- Standard response envelope and standardized error envelope.
- Stable machine-readable error codes.
- Correlation ID included in all error responses.

**Async state format:**
- Shared lifecycle enums for parse/payment/share across API, Flutter, and Nuxt.
- No surface-specific lifecycle aliases.

### Communication Patterns

**Event naming/versioning:**
- Events use a stable domain-event naming convention with explicit versioning.
- Payload schemas are versioned and backward compatibility rules are explicit.

**Internal communication:**
- CRUD paths are synchronous request/response.
- Cross-domain reconciliation is event-driven.

### Process Patterns

**Validation contract:**
- Trust and business-rule validation happens server-side.
- Client-side validation is UX assistance only.

**Loading/error handling:**
- Every critical async flow must expose deterministic loading/success/failure/recovery states.
- No silent fallbacks on critical user workflows.

### Security & Telemetry Guardrails

- PHI is forbidden in analytics/logging payloads.
- Logging payload bodies on PHI-bearing endpoints is default-deny.
- Redaction rules are mandatory for all operational logs.

### Pattern Enforcement Guidelines

**All AI agents MUST:**
- Reuse canonical schemas/contracts and lifecycle enums.
- Follow naming/structure conventions exactly.
- Use standardized API/error/event formats.
- Add/maintain tests for contracts and critical workflows.

**Pattern enforcement:**
- Lint/format and schema validation checks in CI.
- Contract tests for API/event compatibility.
- PR checklist includes pattern compliance and PHI telemetry checks.

### Pattern Examples

**Good examples:**
- DB: `report_upload_attempts`
- API JSON: `shareLinkId`
- Error: stable `errorCode` + `correlationId`
- Async state: shared enum value reused across all surfaces

**Anti-patterns:**
- Mixing `snake_case` and `camelCase` in the same interface boundary
- Frontend-only lifecycle states not represented in backend contracts
- Event renames without version bump
- Logging PHI fields for debugging

## Project Structure & Boundaries

### Complete Project Directory Structure

```text
doclyzer/
├── README.md
├── docs/
│   ├── legal/
│   └── architecture/
│       ├── owners.md
│       ├── contract-compatibility-matrix.md
│       └── runbooks/
├── apps/
│   ├── mobile/                         # Flutter
│   │   ├── pubspec.yaml
│   │   ├── lib/
│   │   │   ├── app/
│   │   │   ├── features/
│   │   │   │   ├── auth/
│   │   │   │   ├── profiles/
│   │   │   │   ├── reports/
│   │   │   │   ├── timeline/
│   │   │   │   ├── sharing/
│   │   │   │   ├── billing/
│   │   │   │   └── admin_insights/
│   │   │   ├── shared/
│   │   │   └── contracts_client/
│   │   ├── test/
│   │   └── integration_test/
│   ├── api/                            # NestJS
│   │   ├── package.json
│   │   ├── src/
│   │   │   ├── main.ts
│   │   │   ├── app.module.ts
│   │   │   ├── modules/
│   │   │   │   ├── auth/
│   │   │   │   ├── profiles/
│   │   │   │   ├── reports/
│   │   │   │   ├── parsing/
│   │   │   │   ├── sharing/
│   │   │   │   ├── billing/
│   │   │   │   ├── analytics_admin/
│   │   │   │   ├── consent_policy/
│   │   │   │   └── audit_incident/
│   │   │   ├── workers/
│   │   │   │   ├── parsing/
│   │   │   │   ├── billing/
│   │   │   │   └── reconciliation/
│   │   │   ├── common/
│   │   │   └── infra/
│   │   ├── test/
│   │   └── prisma/
│   │       ├── schema.prisma
│   │       └── migrations/
│   └── web/                            # Nuxt (landing + share + admin)
│       ├── package.json
│       ├── nuxt.config.ts
│       ├── app/
│       ├── pages/
│       │   ├── index.vue               # landing
│       │   ├── pricing.vue
│       │   ├── legal/
│       │   ├── admin/
│       │   └── share/
│       │       └── [token].vue         # non-indexable
│       ├── server/
│       │   └── middleware/
│       │       └── share-access-guard.ts
│       ├── components/
│       ├── composables/
│       ├── public/
│       └── tests/
├── packages/
│   ├── contracts/
│   │   ├── api/
│   │   ├── event/
│   │   ├── state/
│   │   └── errors/
│   ├── config/
│   └── tooling/
├── infra/
│   ├── docker/
│   ├── observability/
│   └── ci/
│       ├── contracts-check.yml
│       ├── phi-telemetry-check.yml
│       ├── seo-quality.yml
│       └── security-policy.yml
└── scripts/
```

### Architectural Boundaries

**API Boundaries:**
- External clients interact only through versioned API contracts.
- PHI-bearing operations enforce authz + profile ownership on every request.
- Admin analytics/query interfaces are separated from clinical-report mutation paths.

**Component Boundaries:**
- Flutter and Nuxt consume shared contracts, with no direct persistence coupling.
- API modules own domain rules; workers own async and reconciliation execution.

**Service Boundaries:**
- Auth, Profiles, Reports/Parsing, Sharing, Billing/Entitlements, Consent/Policy, and Audit/Incident remain isolated modules with explicit interfaces.

**Data Boundaries:**
- PostgreSQL is the source of truth.
- Redis remains ephemeral cache only.
- Analytics/admin datasets are derived and non-authoritative.

### Requirements to Structure Mapping

- Auth/session/access FRs map to `apps/api/src/modules/auth`, `apps/mobile/lib/features/auth`, and web protected surfaces.
- Profile/report/timeline/share FRs map to corresponding `profiles/reports/timeline/sharing` modules across app and API.
- Billing/promo/entitlement FRs map to `apps/api/src/modules/billing` and client billing features.
- Superadmin analytics/audit/restriction FRs map to `apps/api/src/modules/analytics_admin`, `apps/api/src/modules/audit_incident`, and `apps/web/pages/admin`.
- Security/compliance NFRs map to `consent_policy`, `audit_incident`, CI policy checks, and observability controls.

### Integration Points

**Internal Communication:**
- Module interfaces + domain events for cross-domain coordination.

**External Integrations:**
- Parser/AI providers, payment provider, notification provider.

**Data Flow:**
- Upload → parse async → lifecycle convergence → timeline/share availability → analytics aggregation.

### File Organization Patterns

- Shared contracts and enums live in `packages/contracts` as the canonical source.
- Config standards live in `packages/config` and `infra/ci`.
- Tests are split by scope (unit/integration/e2e) per surface.
- Landing SEO assets are indexable; share route policies remain non-indexable by default.

### Development Workflow Integration

- Independent local/dev targets for mobile, API, and web.
- Contract compatibility checks gate merges affecting shared schemas.
- Deployment pipelines enforce blast-radius controls so landing issues do not degrade share reliability.

## Architecture Validation Results

### Coherence Validation ✅

- Decision compatibility is consistent across data, auth/security, API contracts, frontend state model, and deployment controls.
- Pattern rules align with chosen stack (Flutter + NestJS + Nuxt) and reduce multi-agent implementation drift.
- Structure alignment supports declared module boundaries and operational controls.

### Requirements Coverage Validation ✅

- Functional capability domains are mapped to explicit modules and surfaces.
- Non-functional quality attributes (security, reliability, scalability, accessibility, observability) are represented by architecture constraints and boundaries.
- Cross-cutting concerns (consent, auditability, async reconciliation, PHI-safe telemetry) are covered.

### Implementation Readiness Validation ✅

- Critical decisions are documented and implementation-oriented.
- Project structure is concrete and maps requirements to directories and modules.
- Consistency rules are explicit enough for multi-agent implementation governance.

### Gap Analysis Results

- Architecture document gap status: no critical content gaps found.
- External planning traceability gap remains: epics/stories artifact is still required for full implementation-readiness sign-off.

### Architecture Completeness Checklist

- [x] Context analyzed
- [x] Critical decisions documented
- [x] Patterns and consistency rules defined
- [x] Project structure and boundaries mapped
- [x] Validation and coverage review completed

### Architecture Readiness Assessment

- Overall Status: READY FOR ARCHITECTURE HANDOFF
- Confidence Level: High
- Key Strengths: domain separation, deterministic async contracts, security/compliance posture, concrete project structure.
- Future Enhancements: split Nuxt share surface only if threat/scale triggers are met; deepen analytics governance docs during implementation planning.

### Implementation Handoff

- Treat this architecture document as the authoritative system design baseline.
- First implementation priority: initialize starter surfaces and shared contract package, then implement core auth/profile/report workflows with enforced consistency rules.
