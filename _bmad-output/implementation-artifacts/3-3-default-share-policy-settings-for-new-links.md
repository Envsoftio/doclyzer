# Story 3.3: Default Share Policy Settings for New Links

Status: done

## Story

As an authenticated user,
I want to configure a default expiry for share links I create,
so that repeated link creation is faster without re-entering the same expiry each time.

## Acceptance Criteria

1. **Given** the user calls `GET /v1/sharing/policy`
   **When** no policy has been saved yet
   **Then** the API returns 200 with `{ data: { defaultExpiresInDays: null } }` (null = no default expiry)

2. **Given** the user calls `PUT /v1/sharing/policy` with `{ "defaultExpiresInDays": 7 }`
   **When** the request is processed
   **Then** the policy is upserted and the API returns 200 with `{ data: { defaultExpiresInDays: 7 } }`
   **And** subsequent `GET /v1/sharing/policy` calls reflect the new value

3. **Given** the user calls `PUT /v1/sharing/policy` with `{ "defaultExpiresInDays": null }`
   **When** the request is processed
   **Then** the default is cleared and `GET` returns `{ data: { defaultExpiresInDays: null } }`

4. **Given** the user calls `PUT /v1/sharing/policy` with a non-positive integer (e.g., 0 or -5)
   **When** the request is processed
   **Then** the API returns 400 with code `INVALID_EXPIRES_IN_DAYS`

5. **Given** the user opens `CreateShareLinkScreen` for a profile
   **When** the screen loads and a default policy exists (e.g., `defaultExpiresInDays: 7`)
   **Then** the expiry picker is pre-filled to today + 7 days (formatted as the date)
   **And** the user can still clear it or change it before creating the link

6. **Given** the user opens `CreateShareLinkScreen`
   **When** no default policy is set (`defaultExpiresInDays: null`)
   **Then** the expiry picker shows "No expiry" (current behavior — no regression)

7. **Given** a settings icon (gear) in the `CreateShareLinkScreen` AppBar
   **When** the user taps it
   **Then** `SharePolicyScreen` opens showing the current default expiry option

8. **Given** `SharePolicyScreen` is open
   **When** the user selects an option ("No expiry", "7 days", "30 days", "90 days") and taps "Save"
   **Then** the policy is saved via `PUT /v1/sharing/policy`
   **And** the screen pops back and `CreateShareLinkScreen` reloads the policy so the expiry picker reflects the new default

9. **Given** `SharePolicyScreen` fails to load the current policy
   **When** the API call errors
   **Then** an inline error is shown with a retry button

## Tasks / Subtasks

- [x] Backend: Create `UserSharePolicyEntity` and migration (AC: 1, 2, 3)
  - [x] Create `apps/api/src/database/entities/user-share-policy.entity.ts` — follow `AccountPreferenceEntity` pattern: `id` (uuid PK), `userId` (uuid, unique, FK→users CASCADE), `defaultExpiresInDays` (int nullable, `name: 'default_expires_in_days'`), `updatedAt` (UpdateDateColumn)
  - [x] Create `apps/api/src/database/migrations/1730814000000-CreateUserSharePoliciesTable.ts` — `up`: CREATE TABLE `user_share_policies` with PK, unique index on `user_id`, FK to `users`; `down`: DROP TABLE
  - [x] Add `CreateUserSharePoliciesTable1730814000000` to `apps/api/src/database/migrations/index.ts`

- [x] Backend: Register entity in AppModule (AC: 1, 2)
  - [x] Add `UserSharePolicyEntity` to `typeOrmEntities` array in `apps/api/src/app.module.ts`

- [x] Backend: Add error code + DTO to sharing.types.ts (AC: 4)
  - [x] Add `export const INVALID_EXPIRES_IN_DAYS = 'INVALID_EXPIRES_IN_DAYS';` to `apps/api/src/modules/sharing/sharing.types.ts`

- [x] Backend: Extend `SharingService` with policy methods (AC: 1, 2, 3, 4)
  - [x] Inject `@InjectRepository(UserSharePolicyEntity) private readonly policyRepo: Repository<UserSharePolicyEntity>` (alongside existing repos)
  - [x] Add `export interface SharePolicyDto { defaultExpiresInDays: number | null; }` to `sharing.service.ts` (above/near `ShareLinkDto`)
  - [x] Add `getPolicy(userId: string): Promise<SharePolicyDto>` — find by `userId`; if not found return `{ defaultExpiresInDays: null }`
  - [x] Add `upsertPolicy(userId: string, defaultExpiresInDays: number | null): Promise<SharePolicyDto>` — validate `defaultExpiresInDays === null || defaultExpiresInDays > 0` else throw `BadRequestException({ code: INVALID_EXPIRES_IN_DAYS })`; upsert using TypeORM `save` with existing row or new entity

- [x] Backend: Add policy endpoints to `SharingController` (AC: 1, 2, 3, 4)
  - [x] Add `GET /policy` route — `getPolicy(userId)` → `successResponse(data, getCorrelationId(req))`
  - [x] Add `PUT /policy` route — accept `{ defaultExpiresInDays: number | null }`; delegate to `upsertPolicy`; `successResponse(data, getCorrelationId(req))`
  - [x] Register `UserSharePolicyEntity` in `SharingModule` via `TypeOrmModule.forFeature([ShareLinkEntity, UserSharePolicyEntity])`

- [x] Flutter: Add `SharePolicy` model and repository methods (AC: 5, 6, 7, 8)
  - [x] Add `SharePolicy` class and `fromJson` to `apps/mobile/lib/features/sharing/sharing_repository.dart` — fields: `final int? defaultExpiresInDays;`
  - [x] Add abstract methods to `SharingRepository`:
    - `Future<SharePolicy> getSharePolicy()`
    - `Future<SharePolicy> setSharePolicy(int? defaultExpiresInDays)`

- [x] Flutter: Implement in `ApiSharingRepository` (AC: 5, 6, 8)
  - [x] `getSharePolicy`: `GET v1/sharing/policy` → parse `data['data']` into `SharePolicy`
  - [x] `setSharePolicy`: `PUT v1/sharing/policy` with `body: {'defaultExpiresInDays': defaultExpiresInDays}` → parse response into `SharePolicy`

- [x] Flutter: Create `SharePolicyScreen` (AC: 7, 8, 9)
  - [x] Create `apps/mobile/lib/features/sharing/screens/share_policy_screen.dart`
  - [x] Constructor: `SharePolicyScreen({ required SharingRepository sharingRepository })`
  - [x] States: loading, loaded, saving, error
  - [x] On load: call `getSharePolicy()`, set selected option from result
  - [x] Options: `null` → "No expiry", `7` → "7 days", `30` → "30 days", `90` → "90 days"; render as `RadioListTile`s (or `ListTile` with leading `Radio`)
  - [x] "Save" button: calls `setSharePolicy(selectedDays)` then `Navigator.pop(context, true)` (returns `true` to indicate policy was updated)
  - [x] Error state: inline `Text` (red) + "Retry" `TextButton`
  - [x] Widget keys: `Key('share-policy-loading')`, `Key('share-policy-option-null')`, `Key('share-policy-option-7')`, `Key('share-policy-option-30')`, `Key('share-policy-option-90')`, `Key('share-policy-save-button')`

- [x] Flutter: Update `CreateShareLinkScreen` to load policy and prefill (AC: 5, 6, 7, 8)
  - [x] Add `SharePolicy? _policy;` field to `_CreateShareLinkScreenState`
  - [x] In `initState`, call both `_loadExistingLinks()` and `_loadPolicy()` (parallel — do NOT await one before starting the other; fire both with `unawaited` or just call both without await then use setState when each completes)
  - [x] Add `_loadPolicy()`: call `getSharePolicy()`; in setState, set `_policy = policy`; if `policy.defaultExpiresInDays != null` AND `_selectedExpiry == null`, then `_selectedExpiry = DateTime.now().add(Duration(days: policy.defaultExpiresInDays!))`
  - [x] Add gear icon to `AppBar` actions: `IconButton(key: const Key('share-policy-settings-button'), icon: const Icon(Icons.settings_outlined), onPressed: _openPolicySettings)`
  - [x] Add `_openPolicySettings()`: push `SharePolicyScreen`; if result is `true`, call `_loadPolicy()` to refresh prefill

## Dev Notes

### Scope
- **Builds:** `user_share_policies` DB table/entity, `GET /sharing/policy` + `PUT /sharing/policy` API, `SharePolicyScreen` in Flutter, policy pre-fill in `CreateShareLinkScreen`
- **Does NOT build:** Copy/distribute UX (story 3.4), recipient access (story 3.5)
- **Policy applies per user (not per profile)** — one default across all profiles' share link creation

### Backend: Migration exact content
```typescript
// apps/api/src/database/migrations/1730814000000-CreateUserSharePoliciesTable.ts
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateUserSharePoliciesTable1730814000000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "user_share_policies" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL,
        "default_expires_in_days" integer,
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT "PK_user_share_policies" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_user_share_policies_user_id" UNIQUE ("user_id"),
        CONSTRAINT "FK_user_share_policies_user_id" FOREIGN KEY ("user_id")
          REFERENCES "users"("id") ON DELETE CASCADE
      )
    `);
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "user_share_policies"`);
  }
}
```

Add to `migrations/index.ts`:
```typescript
import { CreateUserSharePoliciesTable1730814000000 } from './1730814000000-CreateUserSharePoliciesTable';
// in migrations array:
CreateUserSharePoliciesTable1730814000000,
```

### Backend: Entity exact content
```typescript
// apps/api/src/database/entities/user-share-policy.entity.ts
import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';
import type { UserEntity } from './user.entity';

@Entity('user_share_policies')
export class UserSharePolicyEntity {
  @PrimaryGeneratedColumn('uuid') id!: string;
  @Column({ type: 'uuid', name: 'user_id', unique: true }) userId!: string;
  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' }) user!: UserEntity;
  @Column({ type: 'int', name: 'default_expires_in_days', nullable: true }) defaultExpiresInDays!: number | null;
  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' }) updatedAt!: Date;
}
```

### Backend: `sharing.types.ts` — add error code
```typescript
// Existing codes stay. Add:
export const INVALID_EXPIRES_IN_DAYS = 'INVALID_EXPIRES_IN_DAYS';
```

### Backend: Policy service methods (add to existing `SharingService`)
```typescript
// Add import:
import { UserSharePolicyEntity } from '../../database/entities/user-share-policy.entity';
import { INVALID_EXPIRES_IN_DAYS } from './sharing.types';

// New DTO interface (add near ShareLinkDto):
export interface SharePolicyDto { defaultExpiresInDays: number | null; }

// In constructor, inject:
@InjectRepository(UserSharePolicyEntity)
private readonly policyRepo: Repository<UserSharePolicyEntity>,

// Methods:
async getPolicy(userId: string): Promise<SharePolicyDto> {
  const row = await this.policyRepo.findOne({ where: { userId } });
  return { defaultExpiresInDays: row?.defaultExpiresInDays ?? null };
}

async upsertPolicy(userId: string, defaultExpiresInDays: number | null): Promise<SharePolicyDto> {
  if (defaultExpiresInDays !== null && (defaultExpiresInDays <= 0 || !Number.isInteger(defaultExpiresInDays))) {
    throw new BadRequestException({ code: INVALID_EXPIRES_IN_DAYS, message: 'defaultExpiresInDays must be a positive integer or null' });
  }
  let row = await this.policyRepo.findOne({ where: { userId } });
  if (row) {
    row.defaultExpiresInDays = defaultExpiresInDays;
  } else {
    row = this.policyRepo.create({ userId, defaultExpiresInDays });
  }
  await this.policyRepo.save(row);
  return { defaultExpiresInDays };
}
```

### Backend: Controller endpoints (add to existing `SharingController`)
```typescript
@Get('policy')
async getSharePolicy(@Req() req: Request): Promise<object> {
  const { id: userId } = req.user as RequestUser;
  const data = await this.sharingService.getPolicy(userId);
  return successResponse(data, getCorrelationId(req));
}

@Put('policy')
async upsertSharePolicy(
  @Body() body: { defaultExpiresInDays: number | null },
  @Req() req: Request,
): Promise<object> {
  const { id: userId } = req.user as RequestUser;
  const data = await this.sharingService.upsertPolicy(userId, body.defaultExpiresInDays ?? null);
  return successResponse(data, getCorrelationId(req));
}
```

### Backend: `SharingModule` update
```typescript
TypeOrmModule.forFeature([ShareLinkEntity, UserSharePolicyEntity])
// also import UserSharePolicyEntity at top
```

### Backend: `app.module.ts` update
```typescript
// Add to typeOrmEntities array:
UserSharePolicyEntity,
```

### Flutter: Model and repository additions
```dart
// In sharing_repository.dart — add class before SharingRepository abstract:
class SharePolicy {
  const SharePolicy({this.defaultExpiresInDays});
  final int? defaultExpiresInDays;

  factory SharePolicy.fromJson(Map<String, dynamic> d) {
    return SharePolicy(
      defaultExpiresInDays: d['defaultExpiresInDays'] as int?,
    );
  }
}

// In abstract SharingRepository — add methods:
Future<SharePolicy> getSharePolicy();
Future<SharePolicy> setSharePolicy(int? defaultExpiresInDays);
```

### Flutter: `ApiSharingRepository` implementations
```dart
@override
Future<SharePolicy> getSharePolicy() async {
  final data = await _client.get('v1/sharing/policy');
  return SharePolicy.fromJson(data['data'] as Map<String, dynamic>);
}

@override
Future<SharePolicy> setSharePolicy(int? defaultExpiresInDays) async {
  final data = await _client.put(
    'v1/sharing/policy',
    body: {'defaultExpiresInDays': defaultExpiresInDays},
  );
  return SharePolicy.fromJson(data['data'] as Map<String, dynamic>);
}
```

**IMPORTANT:** Check `ApiClient` for the actual `put` method signature — it follows the same pattern as `post` and `patch`. Use `body:` named parameter.

### Flutter: `CreateShareLinkScreen` changes (minimal, non-breaking)
```dart
// Add field:
SharePolicy? _policy;

// In initState — fire both without blocking each other:
_loadExistingLinks();
_loadPolicy();

// New method:
Future<void> _loadPolicy() async {
  try {
    final policy = await widget.sharingRepository.getSharePolicy();
    if (mounted) {
      setState(() {
        _policy = policy;
        if (policy.defaultExpiresInDays != null && _selectedExpiry == null) {
          _selectedExpiry = DateTime.now().add(Duration(days: policy.defaultExpiresInDays!));
        }
      });
    }
  } catch (_) {
    // Policy load failure is non-fatal; expiry picker stays at "No expiry"
  }
}

// Add to AppBar actions:
IconButton(
  key: const Key('share-policy-settings-button'),
  icon: const Icon(Icons.settings_outlined),
  onPressed: _openPolicySettings,
),

// New method:
Future<void> _openPolicySettings() async {
  final updated = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => SharePolicyScreen(sharingRepository: widget.sharingRepository),
    ),
  );
  if (updated == true) _loadPolicy();
}
```

**Import:** Add `import 'share_policy_screen.dart';` to `create_share_link_screen.dart`.

### Flutter: `SharePolicyScreen` structure
```dart
// apps/mobile/lib/features/sharing/screens/share_policy_screen.dart
// Options: null, 7, 30, 90
// RadioListTile for each option
// Save calls setSharePolicy then Navigator.pop(context, true)
// Error state: Text(error, style: errorStyle) + TextButton('Retry', onPressed: _load)
```

The standard `_options` list: `[null, 7, 30, 90]` with labels `['No expiry', '7 days', '30 days', '90 days']`. Selected option tracks which `int?` is chosen. On init, load current policy and set `_selected` to matching option (default to `null` if policy not found or matches none of the preset values).

### Project Structure Notes
- Entity: `apps/api/src/database/entities/user-share-policy.entity.ts` (follows `account-preference.entity.ts` naming)
- Migration: `apps/api/src/database/migrations/1730814000000-CreateUserSharePoliciesTable.ts`
- Screen: `apps/mobile/lib/features/sharing/screens/share_policy_screen.dart`
- All changes are within existing `sharing` module — no new module needed
- No new NestJS module; inject entity into existing `SharingModule`

### Existing Pattern References
- Follow `AccountPreferenceEntity` pattern for `UserSharePolicyEntity` (one row per user, upsert)
- Follow `SharingController` existing patterns: `@UseGuards(AuthGuard)`, `successResponse()`, `getCorrelationId(req)`
- Follow `CreateShareLinkScreen` existing state machine pattern for `SharePolicyScreen`
- Migration numbering: `1730814000000` is next after `1730813900000`

### References
- [Source: apps/api/src/database/entities/account-preference.entity.ts] — upsert-per-user pattern
- [Source: apps/api/src/database/entities/share-link.entity.ts] — FK/column patterns
- [Source: apps/api/src/database/migrations/1730813900000-AddExpiresAtToShareLinks.ts] — migration structure
- [Source: apps/api/src/modules/sharing/sharing.service.ts] — `ShareLinkDto`, `SharingService` patterns
- [Source: apps/api/src/modules/sharing/sharing.controller.ts] — `@UseGuards`, `successResponse`, `getCorrelationId`
- [Source: apps/mobile/lib/features/sharing/screens/create_share_link_screen.dart] — existing screen to extend
- [Source: _bmad-output/planning-artifacts/epics.md#Story 3.3]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- Implemented `UserSharePolicyEntity` (one row per user, upsert pattern) with migration `1730814000000-CreateUserSharePoliciesTable`.
- Added `getPolicy` and `upsertPolicy` methods to `SharingService`; `upsertPolicy` validates positive integer or null.
- Added `GET /v1/sharing/policy` and `PUT /v1/sharing/policy` endpoints to `SharingController`.
- Registered `UserSharePolicyEntity` in `SharingModule` and `typeOrmEntities` in `AppModule`.
- Added `SharePolicy` model + abstract methods to `SharingRepository`; implemented in `ApiSharingRepository`.
- Added `put` method to `ApiClient` (was missing; needed for `PUT /v1/sharing/policy`).
- Created `SharePolicyScreen` with loading/loaded/saving/error states, RadioListTile options, and all specified widget keys.
- Updated `CreateShareLinkScreen`: parallel policy load in `initState`, expiry prefill from policy, gear icon in AppBar navigating to `SharePolicyScreen`.

### File List

- `apps/api/src/database/entities/user-share-policy.entity.ts` (new)
- `apps/api/src/database/migrations/1730814000000-CreateUserSharePoliciesTable.ts` (new)
- `apps/api/src/database/migrations/index.ts` (modified)
- `apps/api/src/app.module.ts` (modified)
- `apps/api/src/modules/sharing/sharing.types.ts` (modified)
- `apps/api/src/modules/sharing/sharing.service.ts` (modified)
- `apps/api/src/modules/sharing/sharing.controller.ts` (modified)
- `apps/api/src/modules/sharing/sharing.module.ts` (modified)
- `apps/mobile/lib/core/api_client.dart` (modified)
- `apps/mobile/lib/features/sharing/sharing_repository.dart` (modified)
- `apps/mobile/lib/features/sharing/api_sharing_repository.dart` (modified)
- `apps/mobile/lib/features/sharing/screens/share_policy_screen.dart` (new)
- `apps/mobile/lib/features/sharing/screens/create_share_link_screen.dart` (modified)
