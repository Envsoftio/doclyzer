# Story 4.1: Credit Balance and Entitlement Summary View

Status: review

## Story

As an authenticated user,
I want to view my current credit balance and entitlement status,
so that my usage posture is clear and I know what actions are available to me.

## Acceptance Criteria

1. **Given** the billing/entitlement view loads, **When** data is fetched, **Then** the current credit balance is displayed accurately.
2. **Given** the user is on the free tier, **When** the entitlement summary loads, **Then** it shows free-tier limits (1 profile, ~5 reports, 1 share link, no AI chat).
3. **Given** the user has a paid subscription or credits, **When** the entitlement summary loads, **Then** it shows the active plan name, credit balance, and unlocked capabilities.
4. **Given** the user has no credits remaining, **When** viewing the summary, **Then** a clear upgrade CTA is shown with "Buy credits" or "Upgrade" action.
5. **Given** the backend entitlements endpoint is called, **When** the user is authenticated, **Then** it returns the full entitlement summary scoped to the requesting user only.

## Tasks / Subtasks

- [x] Task 1: Create database entities and migration (AC: #1, #2, #3)
  - [x] 1.1 Create `PlanEntity` (plans table: id, name, tier enum, limits JSON, price info, is_active, timestamps)
  - [x] 1.2 Create `UserEntitlementEntity` (user_entitlements table: id, user_id FK, plan_id FK, credit_balance numeric, status enum, activated_at, expires_at, timestamps)
  - [x] 1.3 Create migration to create both tables with a seed for the default free-tier plan
  - [x] 1.4 Register entities in `app.module.ts` typeOrmEntities array and `data-source.ts`
- [x] Task 2: Extend EntitlementsModule with real data (AC: #1, #2, #3, #5)
  - [x] 2.1 Add TypeOrmModule.forFeature([PlanEntity, UserEntitlementEntity]) to EntitlementsModule
  - [x] 2.2 Extend EntitlementsService with `getEntitlementSummary(userId): Promise<EntitlementSummaryDto>`
  - [x] 2.3 Implement auto-provisioning: if no UserEntitlement row exists for user, create one with free-tier plan and 0 credits
  - [x] 2.4 Refactor `getMaxProfiles()` to read from UserEntitlement instead of hardcoded value
  - [x] 2.5 Add `getCreditBalance(userId): Promise<number>` method
- [x] Task 3: Create EntitlementsController with API endpoint (AC: #5)
  - [x] 3.1 `GET /entitlements/summary` — returns EntitlementSummaryDto for authenticated user
  - [x] 3.2 Apply AuthGuard, extract userId from request, use successResponse envelope
- [x] Task 4: Define DTOs and types (AC: #1, #2, #3)
  - [x] 4.1 Create `EntitlementSummaryDto` interface (planName, tier, creditBalance, limits object, capabilities list, status)
  - [x] 4.2 Define tier enum: `free`, `paid`
  - [x] 4.3 Define entitlement status enum: `active`, `expired`, `cancelled`
  - [x] 4.4 Define error codes: `ENTITLEMENT_NOT_FOUND`
- [x] Task 5: Flutter entitlement summary screen (AC: #1, #2, #3, #4)
  - [x] 5.1 Create `billing/` feature directory under `apps/mobile/lib/features/`
  - [x] 5.2 Create `EntitlementsRepository` interface and `ApiEntitlementsRepository` implementation
  - [x] 5.3 Create `EntitlementSummaryScreen` showing plan name, tier badge, credit balance, limits breakdown
  - [x] 5.4 Show upgrade CTA when on free tier or zero credits (primary filled button "Buy Credits" / "Upgrade")
  - [x] 5.5 Wire screen into app navigation (e.g. Settings or dedicated Billing tab)

## Dev Notes

### Architecture Compliance

- **Domain isolation**: Billing/entitlements is a separate logical domain from clinical/report and identity/profile per ADR-CX1. Do NOT add billing columns to UserEntity or ProfileEntity.
- **Profile isolation**: Every query must filter by `userId`. The entitlement summary endpoint returns data scoped to the authenticated user only.
- **Response envelope**: All endpoints must return `successResponse(data, correlationId)` format.
- **No PHI in billing domain**: Credit/plan data is non-PHI. Keep billing tables logically separate.

### Existing Code to Extend (NOT Reinvent)

- **EntitlementsModule** already exists at `apps/api/src/modules/entitlements/` with a stub `EntitlementsService`. Extend this module — do NOT create a new billing module yet.
- **EntitlementsService.getMaxProfiles()** is currently called by `ProfilesService` for profile creation limits. Refactor it to read from the new `UserEntitlementEntity` instead of hardcoded `1`. Preserve the `E2E_MAX_PROFILES` env override for tests.
- The module currently has no controller — you need to add one.
- The module currently does not import TypeOrmModule — you need to add entity imports.

### Database Design Guidance

- **plans table**: Stores plan definitions (free, paid tiers). Seed the free-tier plan in the migration so it exists on first run.
- **user_entitlements table**: One row per user linking them to a plan with their credit balance. Auto-provision a free-tier entitlement when `getEntitlementSummary()` is called and no row exists (lazy provisioning pattern used elsewhere in codebase).
- Use `numeric(10,2)` for credit_balance to avoid floating-point issues.
- Table/column names: `snake_case` per project convention.
- Foreign keys: `user_id` references `users(id)`, `plan_id` references `plans(id)`.
- Timestamps: `timestamptz` type with `@CreateDateColumn()` / `@UpdateDateColumn()`.
- UUID primary keys: `@PrimaryGeneratedColumn('uuid')`.

### Free vs Paid Tier Limits (from PRD)

| Limit / Feature | Free | Paid |
|-----------------|------|------|
| Patient profiles | 1 | Multiple |
| Reports / files | ~5 total (configurable) | Higher cap or credits |
| Share links | 1 | Higher cap |
| Timeline, lab trends, charts | Yes | Yes |
| Basic per-report summary | Yes | Yes |
| AI chat / lifestyle suggestions | No | Yes |

Store limits as a JSON column on `plans` table (e.g. `{ maxProfiles: 1, maxReports: 5, maxShareLinks: 1, aiChatEnabled: false }`). This allows Epic 5.2 (superadmin plan management) to configure limits without schema changes.

### API Endpoint Design

```
GET /entitlements/summary
Authorization: Bearer <token>

Response 200:
{
  "success": true,
  "data": {
    "planName": "Free",
    "tier": "free",
    "creditBalance": 0,
    "status": "active",
    "limits": {
      "maxProfiles": 1,
      "maxReports": 5,
      "maxShareLinks": 1,
      "aiChatEnabled": false
    },
    "activatedAt": "2026-03-23T00:00:00Z",
    "expiresAt": null
  },
  "correlationId": "..."
}
```

### Flutter Implementation

- Follow the repository pattern: abstract `EntitlementsRepository` + `ApiEntitlementsRepository`.
- API call: `_client.get('v1/entitlements/summary')` using existing `ApiClient`.
- Screen layout: Card with plan badge, credit balance prominently displayed, limits list, upgrade CTA button.
- Use Material 3 `FilledButton` for primary CTAs ("Buy Credits", "Upgrade") per UX spec.
- Success feedback: auto-dismiss SnackBar 3-5s per UX patterns.
- Error state: clear message with retry action.
- The `billing/` feature directory does not exist yet in Flutter — create it fresh.

### Migration Pattern

Follow existing convention in `apps/api/src/database/migrations/`:
- Filename: `{timestamp}-CreateBillingTables.ts`
- Register in `apps/api/src/database/migrations/index.ts`
- Include `uuid_generate_v4()` for PK defaults
- Include `DOWN` migration that drops tables
- Seed default free-tier plan row in the UP migration

### Entity Registration

New entities must be added to TWO places:
1. `apps/api/src/app.module.ts` → `typeOrmEntities` array
2. `apps/api/src/database/data-source.ts` → entities array (for CLI migration tooling)

### Key Dependencies (already installed, do NOT add new ones)

- Backend: `typeorm`, `@nestjs/typeorm`, `class-validator`, `class-transformer`, `@nestjs/jwt`, `@nestjs/passport`
- Flutter: `http`, `flutter_secure_storage`
- No payment provider SDK needed for this story (that's Story 4.2+)

### Project Structure Notes

- Backend module: `apps/api/src/modules/entitlements/` (extend existing)
- New entities: `apps/api/src/database/entities/plan.entity.ts`, `apps/api/src/database/entities/user-entitlement.entity.ts`
- New migration: `apps/api/src/database/migrations/{timestamp}-CreateBillingTables.ts`
- Flutter feature: `apps/mobile/lib/features/billing/` (new directory)
- No changes needed to `apps/web/` for this story

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Epic 4 - Story 4.1]
- [Source: _bmad-output/planning-artifacts/prd.md#FR27 - Credit balance and entitlement status visibility]
- [Source: _bmad-output/planning-artifacts/architecture.md#ADR-CX1 Domain Separation]
- [Source: _bmad-output/planning-artifacts/architecture.md#Billing module structure]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Upgrade Flow, Checkout Form Pattern]
- [Source: apps/api/src/modules/entitlements/entitlements.service.ts - Existing stub to extend]

## Dev Agent Record

### Agent Model Used
Claude Opus 4.6

### Debug Log References
- Backend type-check passed (all errors pre-existing in spec files)
- Flutter analyze passed (all errors pre-existing in test files)
- getMaxProfiles() changed from sync to async — updated caller in ProfilesService

### Completion Notes List
- Created PlanEntity and UserEntitlementEntity with proper TypeORM decorators, UUID PKs, timestamptz columns
- Created migration with plans + user_entitlements tables and free-tier plan seed
- Extended EntitlementsService with getEntitlementSummary(), getCreditBalance(), and async getMaxProfiles() reading from DB
- Implemented lazy auto-provisioning: first call creates free-tier entitlement row for user
- Created EntitlementsController with GET /entitlements/summary behind AuthGuard
- Defined EntitlementSummaryDto interface and PlanTier/EntitlementStatus types
- Created Flutter billing feature: BillingRepository (abstract), ApiBillingRepository (API impl), EntitlementSummaryScreen
- Screen shows plan card with tier badge, credit balance, plan limits breakdown, and upgrade CTA
- Wired billing screen into main.dart navigation with "Plan & Credits" nav card on HomeScreen

### Change Log
- 2026-03-23: Implemented all 5 tasks for Story 4.1 — full backend + Flutter implementation

### File List
- apps/api/src/database/entities/plan.entity.ts (new)
- apps/api/src/database/entities/user-entitlement.entity.ts (new)
- apps/api/src/database/migrations/1730814200000-CreateBillingTables.ts (new)
- apps/api/src/database/migrations/index.ts (modified — registered new migration)
- apps/api/src/app.module.ts (modified — added PlanEntity, UserEntitlementEntity to typeOrmEntities)
- apps/api/src/database/data-source.ts (modified — added entities for CLI)
- apps/api/src/modules/entitlements/entitlements.module.ts (modified — added TypeOrmModule, controller)
- apps/api/src/modules/entitlements/entitlements.service.ts (modified — extended with real DB logic)
- apps/api/src/modules/entitlements/entitlements.controller.ts (new)
- apps/api/src/modules/entitlements/entitlements.types.ts (new)
- apps/api/src/modules/profiles/profiles.service.ts (modified — await getMaxProfiles)
- apps/mobile/lib/features/billing/billing_repository.dart (new)
- apps/mobile/lib/features/billing/api_billing_repository.dart (new)
- apps/mobile/lib/features/billing/screens/entitlement_summary_screen.dart (new)
- apps/mobile/lib/features/auth/screens/home_screen.dart (modified — added onGoToBilling + nav card)
- apps/mobile/lib/main.dart (modified — billing repository + screen wiring)
