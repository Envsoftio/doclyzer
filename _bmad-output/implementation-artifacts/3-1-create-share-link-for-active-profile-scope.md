# Story 3.1: Create Share Link for Active Profile Scope

Status: review

## Story

As an authenticated user,
I want to create a scoped share link for the active profile,
so that recipients can access intended data only via a unique, signed token.

## Acceptance Criteria

1. **Given** I am authenticated and have an active profile with at least one report
   **When** I trigger share link creation for the active profile
   **Then** the API creates a share link record and returns a signed (UUID) token with scope metadata (`profileId`, `scope: 'all'`)
   **And** the token is cryptographically random (UUID v4) and unique

2. **Given** a valid `POST /v1/sharing/links` request with `{ profileId }`
   **When** the user does NOT own the specified profile (or it doesn't exist)
   **Then** the API returns 404 Not Found with error code `PROFILE_NOT_FOUND`
   _(This matches the existing `ProfileNotFoundException` pattern used across all other modules — do NOT introduce a separate 403 response)_

3. **Given** a valid `POST /v1/sharing/links` request with missing `profileId`
   **When** the request is processed
   **Then** the API returns 400 Bad Request with error code `PROFILE_ID_REQUIRED`

4. **Given** the share link is created successfully
   **When** the API responds
   **Then** the response includes: `id`, `token`, `shareUrl`, `profileId`, `scope`, `createdAt`
   **And** `shareUrl` is constructed as `{SHARE_BASE_URL}/share/{token}`

5. **Given** the Flutter app's TimelineScreen is open for the active profile
   **When** the user taps the Share icon in the AppBar
   **Then** `CreateShareLinkScreen` opens, showing the profile name and a "Create Share Link" button

6. **Given** the user taps "Create Share Link" on `CreateShareLinkScreen`
   **When** the API call succeeds
   **Then** the screen shows the full share URL and a "Copy Link" button
   **And** tapping "Copy Link" copies the URL to the clipboard with a `SnackBar` confirmation

7. **Given** the `CreateShareLinkScreen` is generating a link
   **When** the API call is in flight
   **Then** a loading indicator is shown and the button is disabled

8. **Given** the API call fails
   **When** creating a share link
   **Then** an inline error message is shown with a retry option

## Tasks / Subtasks

- [x] Backend: ShareLinkEntity + migration (AC: 1, 4)
  - [x] Create `apps/api/src/database/entities/share-link.entity.ts` with fields: `id` (uuid PK), `userId` (uuid FK→users), `profileId` (uuid FK→profiles), `token` (varchar 64, unique), `scope` (varchar 32, default `'all'`), `isActive` (boolean, default true), `createdAt`, `updatedAt`
  - [x] Create `apps/api/src/database/migrations/1730813800000-CreateShareLinksTable.ts` with `up` (CREATE TABLE `share_links` with PK, FKs, unique index on `token`) and `down` (DROP TABLE)
  - [x] Add `CreateShareLinksTable1730813800000` to `apps/api/src/database/migrations/index.ts`

- [x] Backend: SharingModule — service, controller, module (AC: 1, 2, 3, 4)
  - [x] Create `apps/api/src/modules/sharing/sharing.service.ts`: inject `Repository<ShareLinkEntity>`, `ProfilesService`, and `ConfigService`; implement `createShareLink(userId, profileId, scope)` → call `profilesService.getProfile(userId, profileId)` (throws `ProfileNotFoundException` automatically if not owned), generate `randomUUID()` token, save entity, return `ShareLinkDto`
  - [x] Create `apps/api/src/modules/sharing/sharing.controller.ts`: `@Controller('sharing') @UseGuards(AuthGuard)`, `POST /links` route; validate `profileId` present (400 if missing), call `sharingService.createShareLink`; use `successResponse()` envelope + `getCorrelationId()`
  - [x] Create `apps/api/src/modules/sharing/sharing.module.ts`: import `TypeOrmModule.forFeature([ShareLinkEntity])`, `AuthModule`, `ProfilesModule`; declare controller + provider
  - [x] Create `apps/api/src/modules/sharing/sharing.types.ts`: define `PROFILE_ID_REQUIRED` error code constant

- [x] Backend: Register SharingModule in AppModule (AC: 1)
  - [x] Add `ShareLinkEntity` to `typeOrmEntities` array in `apps/api/src/app.module.ts`
  - [x] Add `SharingModule` to the `@Module({ imports: [...] })` array in `apps/api/src/app.module.ts`

- [x] Backend: Add `SHARE_BASE_URL` to `.env.example`
  - [x] Add line `SHARE_BASE_URL=http://localhost:3001` to `.env.example`

- [x] Flutter: SharingRepository + ApiSharingRepository (AC: 1, 4, 6)
  - [x] Create `apps/mobile/lib/features/sharing/sharing_repository.dart`: abstract class `SharingRepository` with `Future<ShareLink> createShareLink(String profileId)` method; define `ShareLink` model class with `id`, `token`, `shareUrl`, `profileId`, `scope`, `createdAt` fields
  - [x] Create `apps/mobile/lib/features/sharing/api_sharing_repository.dart`: `ApiSharingRepository implements SharingRepository`; call `_client.post('v1/sharing/links', body: {'profileId': profileId})` (named `body:` parameter — see ApiClient.post signature); parse response `data['data']` into `ShareLink`

- [x] Flutter: CreateShareLinkScreen (AC: 5, 6, 7, 8)
  - [x] Create `apps/mobile/lib/features/sharing/screens/create_share_link_screen.dart`
  - [x] Add `import 'package:flutter/services.dart';` for `Clipboard`
  - [x] Constructor: `CreateShareLinkScreen({ required String profileId, required String profileName, required SharingRepository sharingRepository })`
  - [x] States: idle (show profile name + "Create Share Link" `ElevatedButton`), loading (`CircularProgressIndicator`, button disabled), created (show `shareUrl` in a `SelectableText` + `ElevatedButton` "Copy Link"), error (inline error `Text` + "Try Again" `TextButton`)
  - [x] Scaffold with `AppBar(title: Text('Share ${widget.profileName}\'s Reports'))` and `Padding(all: 16)`
  - [x] On "Copy Link": `await Clipboard.setData(ClipboardData(text: _shareLink.shareUrl))` then `ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied to clipboard')))`
  - [x] Widget keys: `Key('create-share-link-button')`, `Key('create-share-link-loading')`, `Key('share-url-text')`, `Key('copy-link-button')`, `Key('share-link-error')`
  - [x] No `!` force-unwrap; use null-safe access; business logic in `_createLink()` method not in `build`

- [x] Flutter: Wire TimelineScreen + main.dart (AC: 5)
  - [x] In `apps/mobile/lib/features/reports/screens/timeline_screen.dart`:
    - Add `required this.sharingRepository` (type `SharingRepository`) and `required this.profileName` (type `String`) to constructor
    - Add import for sharing files at top of file
    - Append `IconButton(key: const Key('timeline-share-button'), icon: const Icon(Icons.share_outlined), tooltip: 'Share Profile')` to the **existing** `actions` list (after the health-history button — do NOT remove or replace the health-history button)
    - On tap: `Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CreateShareLinkScreen(profileId: widget.profileId, profileName: widget.profileName, sharingRepository: widget.sharingRepository)))`
  - [x] In `apps/mobile/lib/main.dart`:
    - Add `final SharingRepository? sharingRepository;` optional field to `DoclyzerApp` constructor (same pattern as all other repositories — for test injection)
    - Add `late final SharingRepository _sharingRepository;` to `_DoclyzerAppState`
    - In the `else` branch of `initState` (real app path): `_sharingRepository = widget.sharingRepository ?? ApiSharingRepository(_apiClient!);`
    - In the `if (widget.authRepository != null)` branch (test injection path): `_sharingRepository = widget.sharingRepository!;`
    - Add `String? _timelineProfileName;` state field to `_DoclyzerAppState`
    - In `onGoToTimeline` callback (where `_timelineProfileId = active!.id` is set), also set `_timelineProfileName = active!.name`
    - Pass `profileName: _timelineProfileName!` and `sharingRepository: _sharingRepository` to `TimelineScreen` at the existing call site (the `_AuthView.timeline` branch)
    - Add imports: `sharing/sharing_repository.dart`, `sharing/api_sharing_repository.dart`

## Dev Notes

### Scope: What this story builds (and what it does NOT)
- Builds: the entire `sharing` module on backend + Flutter entry point for creating a link
- Does NOT build: link expiry/revocation (story 3.2), default share policies (3.3), copy/distribute UX beyond basic clipboard (3.4), recipient web view (3.5), share access event history (3.7), profile isolation enforcement at share time (3.8)
- Entity `is_active` field and `scope` field are added now to avoid a migration in 3.2/3.3

### Backend: Token design
- Token = `randomUUID()` from `node:crypto` (same import already used in `reports.service.ts:9`)
- UUID v4 is 128-bit cryptographically random — satisfies "signed scoped token" for this story
- Stored in DB as `varchar(64)` with `UNIQUE` constraint
- `SHARE_BASE_URL` env var read via `ConfigService.get<string>('SHARE_BASE_URL', 'http://localhost:3001')`
- No UUID validation needed in `SharingService` — `profilesService.getProfile()` already validates UUID format and throws `ProfileNotFoundException` for non-UUID or non-existent profiles

### Backend: ProfilesService ownership check — exact method to use
`ProfilesService` exports `getProfile(userId: string, profileId: string): Promise<ProfileWithActive>`.
- If user does NOT own the profile (or profileId is not a valid UUID), it throws `ProfileNotFoundException` (404) automatically.
- Do NOT add any additional ownership check or UUID validation — just call `await this.profilesService.getProfile(userId, profileId)`.
- `ProfilesModule` already exports `ProfilesService` — just import `ProfilesModule` in `SharingModule`.

### Backend: SharingService shape
```typescript
// sharing.service.ts
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { Repository } from 'typeorm';
import { randomUUID } from 'node:crypto';
import { ShareLinkEntity } from '../../database/entities/share-link.entity';
import { ProfilesService } from '../profiles/profiles.service';

export interface ShareLinkDto {
  id: string;
  token: string;
  shareUrl: string;
  profileId: string;
  scope: string;
  createdAt: string; // ISO string
}

@Injectable()
export class SharingService {
  private readonly shareBaseUrl: string;

  constructor(
    @InjectRepository(ShareLinkEntity)
    private readonly shareLinkRepo: Repository<ShareLinkEntity>,
    private readonly profilesService: ProfilesService,
    private readonly configService: ConfigService,
  ) {
    this.shareBaseUrl = this.configService.get<string>('SHARE_BASE_URL', 'http://localhost:3001');
  }

  async createShareLink(userId: string, profileId: string, scope = 'all'): Promise<ShareLinkDto> {
    // Throws ProfileNotFoundException (404) if user doesn't own profile
    await this.profilesService.getProfile(userId, profileId);
    const token = randomUUID();
    const entity = this.shareLinkRepo.create({ userId, profileId, token, scope });
    const saved = await this.shareLinkRepo.save(entity);
    return {
      id: saved.id,
      token: saved.token,
      shareUrl: `${this.shareBaseUrl}/share/${saved.token}`,
      profileId: saved.profileId,
      scope: saved.scope,
      createdAt: saved.createdAt.toISOString(),
    };
  }
}
```

### Backend: Controller pattern (follow reports.controller.ts exactly)
```typescript
// sharing.controller.ts
import { BadRequestException, Body, Controller, HttpCode, HttpStatus, Post, Req, UseGuards } from '@nestjs/common';
import type { Request } from 'express';
import type { RequestUser } from '../auth/auth.types';
import { AuthGuard } from '../../common/guards/auth.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import { SharingService } from './sharing.service';
import { PROFILE_ID_REQUIRED } from './sharing.types';

@Controller('sharing')
@UseGuards(AuthGuard)
export class SharingController {
  constructor(private readonly sharingService: SharingService) {}

  @Post('links')
  @HttpCode(HttpStatus.CREATED)
  async createShareLink(
    @Body() body: { profileId?: string },
    @Req() req: Request,
  ): Promise<object> {
    if (!body?.profileId) {
      throw new BadRequestException({ code: PROFILE_ID_REQUIRED, message: 'profileId is required' });
    }
    const { id: userId } = req.user as RequestUser;
    const data = await this.sharingService.createShareLink(userId, body.profileId);
    return successResponse(data, getCorrelationId(req));
  }
}
```

### Backend: Migration pattern (follow 1730813600000 exactly)
```typescript
// 1730813800000-CreateShareLinksTable.ts
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateShareLinksTable1730813800000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "share_links" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "user_id" uuid NOT NULL,
        "profile_id" uuid NOT NULL,
        "token" varchar(64) NOT NULL,
        "scope" varchar(32) NOT NULL DEFAULT 'all',
        "is_active" boolean NOT NULL DEFAULT true,
        "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT "PK_share_links" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_share_links_token" UNIQUE ("token"),
        CONSTRAINT "FK_share_links_user_id" FOREIGN KEY ("user_id")
          REFERENCES "users"("id") ON DELETE CASCADE,
        CONSTRAINT "FK_share_links_profile_id" FOREIGN KEY ("profile_id")
          REFERENCES "profiles"("id") ON DELETE CASCADE
      )
    `);
    await queryRunner.query(
      `CREATE INDEX "IDX_share_links_profile_id" ON "share_links" ("profile_id")`
    );
    await queryRunner.query(
      `CREATE INDEX "IDX_share_links_user_id" ON "share_links" ("user_id")`
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "share_links"`);
  }
}
```

### Backend: Entity pattern (follow report.entity.ts exactly)
```typescript
// share-link.entity.ts
import { Column, CreateDateColumn, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';
import type { ProfileEntity } from './profile.entity';
import type { UserEntity } from './user.entity';

@Entity('share_links')
export class ShareLinkEntity {
  @PrimaryGeneratedColumn('uuid') id!: string;
  @Column({ type: 'uuid', name: 'user_id' }) userId!: string;
  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' }) user!: UserEntity;
  @Column({ type: 'uuid', name: 'profile_id' }) profileId!: string;
  @ManyToOne('ProfileEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'profile_id' }) profile!: ProfileEntity;
  @Column({ type: 'varchar', length: 64, unique: true }) token!: string;
  @Column({ type: 'varchar', length: 32, default: 'all' }) scope!: string;
  @Column({ type: 'boolean', name: 'is_active', default: true }) isActive!: boolean;
  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' }) createdAt!: Date;
  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' }) updatedAt!: Date;
}
```

### Backend: AppModule additions (exact lines to change)
File: `apps/api/src/app.module.ts`
1. Add import: `import { ShareLinkEntity } from './database/entities/share-link.entity';`
2. Add `ShareLinkEntity` to `typeOrmEntities` array after `ReportEntity` (line ~38)
3. Add import: `import { SharingModule } from './modules/sharing/sharing.module';`
4. Add `SharingModule` to `@Module({ imports: [...] })` array after `ReportsModule` (line ~134)

Note: `autoLoadEntities: true` is set but `ShareLinkEntity` must also be in `typeOrmEntities` for the pg-mem test path (which uses `synchronize: true` with the entity list directly).

### Flutter: SharingRepository model
```dart
// sharing_repository.dart
class ShareLink {
  const ShareLink({
    required this.id,
    required this.token,
    required this.shareUrl,
    required this.profileId,
    required this.scope,
    required this.createdAt,
  });
  final String id;
  final String token;
  final String shareUrl;
  final String profileId;
  final String scope;
  final DateTime createdAt;
}

abstract class SharingRepository {
  Future<ShareLink> createShareLink(String profileId);
}
```

### Flutter: ApiSharingRepository — correct ApiClient.post() signature
`ApiClient.post()` signature: `post(String path, {Map<String, dynamic>? body, bool auth = true})` — `body` is a **named parameter**.

```dart
// api_sharing_repository.dart
import '../../core/api_client.dart';
import 'sharing_repository.dart';

class ApiSharingRepository implements SharingRepository {
  ApiSharingRepository(this._client);
  final ApiClient _client;

  @override
  Future<ShareLink> createShareLink(String profileId) async {
    // IMPORTANT: 'body' is a named parameter in ApiClient.post()
    final data = await _client.post(
      'v1/sharing/links',
      body: {'profileId': profileId},
    );
    final d = data['data'] as Map<String, dynamic>;
    return ShareLink(
      id: d['id'] as String,
      token: d['token'] as String,
      shareUrl: d['shareUrl'] as String,
      profileId: d['profileId'] as String,
      scope: d['scope'] as String,
      createdAt: DateTime.parse(d['createdAt'] as String),
    );
  }
}
```

### Flutter: CreateShareLinkScreen structure
```dart
// create_share_link_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // REQUIRED for Clipboard

enum _ShareState { idle, loading, created, error }

class CreateShareLinkScreen extends StatefulWidget {
  const CreateShareLinkScreen({
    super.key,
    required this.profileId,
    required this.profileName,
    required this.sharingRepository,
  });
  final String profileId;
  final String profileName;
  final SharingRepository sharingRepository;
  // ...
}

// State: _ShareState _state = _ShareState.idle; ShareLink? _shareLink; String? _errorMessage;
// _createLink(): setState loading → await sharingRepository.createShareLink → setState created/_shareLink
// _copyLink(): await Clipboard.setData(ClipboardData(text: _shareLink!.shareUrl)) → showSnackBar
```

Full body structure:
```
Scaffold
  AppBar(title: Text('Share ${widget.profileName}\'s Reports'))
  body: Padding(all: 16)
    Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if idle:
        Text('Create a shareable link for ${widget.profileName}\'s reports')
        SizedBox(16)
        ElevatedButton(key: Key('create-share-link-button'), onPressed: _createLink, child: Text('Create Share Link'))
      if loading:
        Center(child: CircularProgressIndicator(key: Key('create-share-link-loading')))
      if created:
        Text('Share link created!')
        SizedBox(8)
        SelectableText(_shareLink!.shareUrl, key: Key('share-url-text'))
        SizedBox(16)
        ElevatedButton(key: Key('copy-link-button'), onPressed: _copyLink, child: Text('Copy Link'))
      if error:
        Text(_errorMessage ?? 'Something went wrong',
          key: Key('share-link-error'),
          style: TextStyle(color: Theme.of(context).colorScheme.error))
        TextButton(onPressed: _createLink, child: Text('Try Again'))
    ])
```

### Flutter: TimelineScreen modification — exact changes
File: `apps/mobile/lib/features/reports/screens/timeline_screen.dart`

Add to constructor:
```dart
const TimelineScreen({
  super.key,
  required this.reportsRepository,
  required this.profilesRepository,
  required this.profileId,
  required this.onBack,
  required this.sharingRepository, // ADD
  required this.profileName,       // ADD
});
final SharingRepository sharingRepository; // ADD
final String profileName;                  // ADD
```

Add to `AppBar.actions` — **append after** the existing health-history `IconButton`, do NOT remove it:
```dart
actions: [
  IconButton(
    key: const Key('timeline-health-history-button'), // existing — keep as-is
    icon: const Icon(Icons.health_and_safety_outlined),
    tooltip: 'Health History',
    onPressed: () => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HealthHistoryScreen(
          profileId: widget.profileId,
          reportsRepository: widget.reportsRepository,
        ),
      ),
    ),
  ),
  IconButton(                        // ADD THIS
    key: const Key('timeline-share-button'),
    icon: const Icon(Icons.share_outlined),
    tooltip: 'Share Profile',
    onPressed: () => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CreateShareLinkScreen(
          profileId: widget.profileId,
          profileName: widget.profileName,
          sharingRepository: widget.sharingRepository,
        ),
      ),
    ),
  ),
],
```

### Flutter: main.dart — exact changes
File: `apps/mobile/lib/main.dart`

1. Add imports (after existing report imports):
```dart
import 'features/sharing/sharing_repository.dart';
import 'features/sharing/api_sharing_repository.dart';
import 'features/sharing/screens/create_share_link_screen.dart';
```

2. Add to `DoclyzerApp` constructor (follow existing optional repo pattern):
```dart
this.sharingRepository,
// ...
final SharingRepository? sharingRepository;
```

3. Add to `_DoclyzerAppState`:
```dart
late final SharingRepository _sharingRepository;
String? _timelineProfileName; // ADD alongside _timelineProfileId
```

4. In `initState` — test injection branch (`if (widget.authRepository != null)`):
```dart
_sharingRepository = widget.sharingRepository!;
```

5. In `initState` — real app branch (`else`):
```dart
_sharingRepository = widget.sharingRepository ?? ApiSharingRepository(_apiClient!);
```

6. In `onGoToTimeline` callback (alongside `_timelineProfileId = active!.id`):
```dart
_timelineProfileId = active!.id;
_timelineProfileName = active.name; // ADD
```

7. At `TimelineScreen` call site (`_AuthView.timeline` branch):
```dart
TimelineScreen(
  reportsRepository: _reportsRepository,
  profilesRepository: _profilesRepository,
  profileId: _timelineProfileId!,
  profileName: _timelineProfileName!,    // ADD
  sharingRepository: _sharingRepository, // ADD
  onBack: () {
    setState(() => _authView = _AuthView.home);
  },
)
```

### State management pattern
Use `StatefulWidget` with a local `_state` enum — same pattern as `HealthHistoryScreen`, `TrendChartScreen`. No Provider/Bloc (not used in this codebase). Check `mounted` before `setState` after async calls.

### Project rules (from previous story intelligence)
- No `!` force-unwrap: only exception is `_shareLink!.shareUrl` inside the `created` state guard (safe because state is only `created` when `_shareLink` is set)
- Full `Scaffold` with `AppBar` and `Padding(all: 16)` body
- Widget keys use kebab-case: `Key('create-share-link-button')` etc.
- Repositories injected via constructor, not instantiated inside widget
- `Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ...))` — exact pattern from `timeline_screen.dart`
- Business logic in `_createLink()` / `_copyLink()`, not in `build`
- `Theme.of(context).colorScheme.error` for error color, not hardcoded red
- No PHI in logs; don't log token, profileId, or user data

### Architecture compliance
- New dedicated `sharing` module — isolated bounded context per architecture
- `profilesService.getProfile(userId, profileId)` enforces ownership on every call
- Token uniqueness: DB unique constraint + UUID v4
- Idempotency: each POST creates a new link; no dedup at 3.1 level
- No PHI in logs

### References
- [Source: _bmad-output/planning-artifacts/epics.md#Story 3.1]
- [Source: _bmad-output/planning-artifacts/architecture.md#Authentication & Security] — share-link signed scoped tokens
- [Source: _bmad-output/planning-artifacts/architecture.md#Project Structure] — module paths
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Journey 3] — share flow UX
- [Source: _bmad-output/implementation-artifacts/2-10-profile-level-consolidated-health-history.md] — no force-unwrap, widget keys, Navigator pattern, repository injection
- [Source: apps/api/src/modules/profiles/profiles.service.ts] — `getProfile(userId, profileId)` exact method signature
- [Source: apps/api/src/modules/profiles/profiles.module.ts] — `ProfilesService` is exported
- [Source: apps/api/src/modules/reports/reports.controller.ts] — controller pattern
- [Source: apps/api/src/database/migrations/1730813600000-CreateReportProcessingAttemptsTable.ts] — migration pattern
- [Source: apps/api/src/database/entities/report.entity.ts] — entity pattern
- [Source: apps/mobile/lib/core/api_client.dart:85] — `post(path, {body, auth})` — `body` is a named param
- [Source: apps/mobile/lib/main.dart:60-134] — `DoclyzerApp` constructor + `_DoclyzerAppState` init pattern
- [Source: apps/mobile/lib/features/reports/screens/timeline_screen.dart] — `AppBar.actions` existing buttons, `Navigator.of(context).push(MaterialPageRoute<void>(...))` exact pattern

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- Implemented full sharing module on NestJS backend: `ShareLinkEntity`, migration, `SharingService`, `SharingController`, `SharingModule`, and `sharing.types.ts`. ShareLinkEntity registered in AppModule (`typeOrmEntities` + imports).
- `SharingService.createShareLink` delegates ownership check to `ProfilesService.getProfile()` (throws `ProfileNotFoundException` 404 automatically), generates UUID v4 token, saves entity, returns `ShareLinkDto` with constructed `shareUrl`.
- `SharingController` POST `/v1/sharing/links` validates `profileId` presence (400 `PROFILE_ID_REQUIRED`), uses `successResponse()` envelope and `getCorrelationId()`.
- Added `SHARE_BASE_URL=http://localhost:3001` to `.env.example`.
- Flutter: Created `SharingRepository` (abstract + `ShareLink` model), `ApiSharingRepository` (uses `ApiClient.post()` named `body:` param), and `CreateShareLinkScreen` (idle/loading/created/error states, all widget keys, Clipboard copy, SnackBar confirmation).
- Flutter: Extended `TimelineScreen` with `sharingRepository` and `profileName` required props; added share `IconButton` to AppBar actions after health-history button.
- Flutter: Wired `DoclyzerApp` constructor with optional `SharingRepository?`, initialized `_sharingRepository` in both test-injection and real-app branches, added `_timelineProfileName` state field, passed `profileName` and `sharingRepository` to `TimelineScreen`.
- Fixed `timeline_test.dart` to pass new required parameters; added `MockSharingRepository` to `mocks.dart`. Flutter analyze: zero errors (only pre-existing warnings in unrelated test files).

### File List

- apps/api/src/database/entities/share-link.entity.ts (new)
- apps/api/src/database/migrations/1730813800000-CreateShareLinksTable.ts (new)
- apps/api/src/database/migrations/index.ts (modified)
- apps/api/src/app.module.ts (modified)
- apps/api/src/modules/sharing/sharing.types.ts (new)
- apps/api/src/modules/sharing/sharing.service.ts (new)
- apps/api/src/modules/sharing/sharing.controller.ts (new)
- apps/api/src/modules/sharing/sharing.module.ts (new)
- .env.example (modified)
- apps/mobile/lib/features/sharing/sharing_repository.dart (new)
- apps/mobile/lib/features/sharing/api_sharing_repository.dart (new)
- apps/mobile/lib/features/sharing/screens/create_share_link_screen.dart (new)
- apps/mobile/lib/features/reports/screens/timeline_screen.dart (modified)
- apps/mobile/lib/main.dart (modified)
- apps/mobile/test/mocks.dart (modified)
- apps/mobile/test/timeline_test.dart (modified)

## Change Log

| Date       | Author | Change |
|------------|--------|--------|
| 2026-03-22 | AI (claude-sonnet-4-6) | Story created: share link creation for active profile scope; introduces sharing module (NestJS) + sharing feature (Flutter); UUID token stored in DB scoped to profile. |
| 2026-03-22 | AI (claude-sonnet-4-6) | Validation pass: fixed ApiClient.post() named parameter; added profileName threading through main.dart→TimelineScreen; corrected AC#2 to 404/PROFILE_NOT_FOUND; added Clipboard import requirement; added DoclyzerApp SharingRepository injection pattern; added .env.example task; clarified Navigator.of(context).push pattern and exact AppBar.actions modification. |
| 2026-03-22 | AI (claude-sonnet-4-6) | Implementation complete: NestJS sharing module (entity, migration, service, controller, module); Flutter sharing feature (repositories, CreateShareLinkScreen, TimelineScreen wiring, main.dart wiring). All ACs satisfied. Flutter analyze: zero errors. |
