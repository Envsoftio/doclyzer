# Story 3.7: Share Access Event History for Link Owner

Status: review

## Story

As a link owner,
I want access-event history,
So that I can monitor usage.

## Acceptance Criteria

1. **Given** a recipient accesses a valid share link, **When** the public endpoint is called, **Then** an access event with outcome `accessed` is recorded against that link.
2. **Given** a recipient attempts to access an expired or revoked share link, **When** the public endpoint is called, **Then** an access event with outcome `expired_or_revoked` is recorded against that link (and the appropriate error is still returned to the recipient).
3. **Given** access events exist for a link, **When** the authenticated link owner calls `GET /v1/sharing/links/:id/access-events`, **Then** a chronological list of events is returned (most recent first) with `id`, `accessedAt` (ISO string), and `outcome` per event.
4. **Given** a link ID that does not belong to the authenticated user, **When** they call the access-events endpoint, **Then** a `SHARE_LINK_NOT_FOUND` 404 error is returned.
5. **Given** a link has had no access attempts, **When** the owner calls the access-events endpoint, **Then** an empty array is returned with HTTP 200.
6. **Given** the mobile app shows the active share links list, **When** the user taps "History" on a link, **Then** a screen loads showing the access events for that link (accessedAt timestamp + outcome label).

## Tasks / Subtasks

- [x] Task 1: Create `ShareAccessEventEntity` and migration (AC: #1, #2, #3)
  - [x] Create `apps/api/src/database/entities/share-access-event.entity.ts` with fields: `id` (uuid PK), `shareLinkId` (uuid FK → share_links ON DELETE CASCADE), `outcome` (varchar 32, default `'accessed'`), `accessedAt` (timestamptz, CreateDateColumn)
  - [x] Create migration `apps/api/src/database/migrations/1730814100000-CreateShareAccessEventsTable.ts` — see SQL below
  - [x] Add migration import + entry to `apps/api/src/database/migrations/index.ts`

- [x] Task 2: Wire entity into sharing module and service (AC: #1, #2, #3, #4, #5)
  - [x] Add `ShareAccessEventEntity` to `TypeOrmModule.forFeature([...])` in `sharing.module.ts`
  - [x] Inject `@InjectRepository(ShareAccessEventEntity) private readonly accessEventRepo: Repository<ShareAccessEventEntity>` in `SharingService` constructor
  - [x] In `getPublicShareData()`, after the `if (!link)` guard: determine outcome, save event, **then** check validity and conditionally throw — see exact code below
  - [x] Add `listAccessEvents(userId: string, linkId: string): Promise<AccessEventDto[]>` method to `SharingService` — see code below
  - [x] Add `AccessEventDto` interface to `SharingService` (top of file alongside other interfaces): `{ id: string; accessedAt: string; outcome: string }`

- [x] Task 3: Add authenticated API endpoint (AC: #3, #4, #5)
  - [x] Add `GET sharing/links/:id/access-events` endpoint to `SharingController` — see code below
  - [x] Controller must call `this.sharingService.listAccessEvents(userId, linkId)` and wrap with `successResponse(data, getCorrelationId(req))`

- [x] Task 4: Mobile — model, repository, screen (AC: #6)
  - [x] Add `ShareAccessEvent` model and `listAccessEvents(String linkId)` abstract method to `sharing_repository.dart`
  - [x] Implement `listAccessEvents` in `api_sharing_repository.dart` — calls `GET v1/sharing/links/$linkId/access-events`
  - [x] Create `apps/mobile/lib/features/sharing/screens/share_access_history_screen.dart` — see structure below
  - [x] In `create_share_link_screen.dart`, add an `IconButton` (history icon) to each existing link's trailing row that navigates to `ShareAccessHistoryScreen`

## Dev Notes

### New Entity: `share-access-event.entity.ts`

```typescript
import { Column, CreateDateColumn, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import type { ShareLinkEntity } from './share-link.entity';

@Entity('share_access_events')
export class ShareAccessEventEntity {
  @PrimaryGeneratedColumn('uuid') id!: string;
  @Column({ type: 'uuid', name: 'share_link_id' }) shareLinkId!: string;
  @ManyToOne('ShareLinkEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'share_link_id' }) shareLink!: ShareLinkEntity;
  @Column({ type: 'varchar', length: 32, default: 'accessed' }) outcome!: string;
  @CreateDateColumn({ name: 'accessed_at', type: 'timestamptz' }) accessedAt!: Date;
}
```

### New Migration: `1730814100000-CreateShareAccessEventsTable.ts`

```typescript
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateShareAccessEventsTable1730814100000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE "share_access_events" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "share_link_id" uuid NOT NULL,
        "outcome" varchar(32) NOT NULL DEFAULT 'accessed',
        "accessed_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT "PK_share_access_events" PRIMARY KEY ("id"),
        CONSTRAINT "FK_share_access_events_share_link_id" FOREIGN KEY ("share_link_id")
          REFERENCES "share_links"("id") ON DELETE CASCADE
      )
    `);
    await queryRunner.query(
      `CREATE INDEX "IDX_share_access_events_share_link_id" ON "share_access_events" ("share_link_id")`
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "share_access_events"`);
  }
}
```

### Migration Index Update

Add to `apps/api/src/database/migrations/index.ts`:
```typescript
import { CreateShareAccessEventsTable1730814100000 } from './1730814100000-CreateShareAccessEventsTable';
// ... in the migrations array:
CreateShareAccessEventsTable1730814100000,
```
The existing last migration is `CreateUserSharePoliciesTable1730814000000`. The new one goes after it.

### `SharingService` Changes

**Add `AccessEventDto` interface near the top** (alongside `ShareLinkDto`, `PublicShareDto`, etc.):
```typescript
export interface AccessEventDto {
  id: string;
  accessedAt: string; // ISO string
  outcome: string;    // 'accessed' | 'expired_or_revoked'
}
```

**Updated `getPublicShareData()` with event recording:**
```typescript
async getPublicShareData(token: string): Promise<PublicShareDto> {
  const link = await this.shareLinkRepo.findOne({ where: { token } });
  if (!link) throw new ShareLinkNotFoundException(); // no recording — no link to associate

  // Record event BEFORE validity check — captures both 'accessed' and 'expired_or_revoked'
  const outcome = this.isLinkValid(link) ? 'accessed' : 'expired_or_revoked';
  await this.accessEventRepo.save(
    this.accessEventRepo.create({ shareLinkId: link.id, outcome }),
  );

  if (!this.isLinkValid(link)) throw new ShareLinkExpiredException();

  // ... rest of the method unchanged (profile fetch, reports fetch, lab values, return)
}
```

**Add `listAccessEvents()` method:**
```typescript
async listAccessEvents(userId: string, linkId: string): Promise<AccessEventDto[]> {
  // Ownership check — reuse same ownership pattern as revokeShareLink
  const link = await this.shareLinkRepo.findOne({ where: { id: linkId, userId } });
  if (!link) throw new ShareLinkNotFoundException();
  const events = await this.accessEventRepo.find({
    where: { shareLinkId: linkId },
    order: { accessedAt: 'DESC' },
  });
  return events.map((e) => ({
    id: e.id,
    accessedAt: e.accessedAt.toISOString(),
    outcome: e.outcome,
  }));
}
```

**Import to add to `sharing.service.ts`:**
```typescript
import { ShareAccessEventEntity } from '../../database/entities/share-access-event.entity';
```
Add to constructor:
```typescript
@InjectRepository(ShareAccessEventEntity)
private readonly accessEventRepo: Repository<ShareAccessEventEntity>,
```

### `SharingController` Changes

Add this endpoint (after `revokeShareLink`, before `getSharePolicy`):
```typescript
@Get('links/:id/access-events')
async listAccessEvents(
  @Param('id') linkId: string,
  @Req() req: Request,
): Promise<object> {
  const { id: userId } = req.user as RequestUser;
  const data = await this.sharingService.listAccessEvents(userId, linkId);
  return successResponse(data, getCorrelationId(req));
}
```

The controller already has `@UseGuards(AuthGuard)` at class level — no additional guard needed.

### `SharingModule` Changes

Add `ShareAccessEventEntity` to the `forFeature` array:
```typescript
TypeOrmModule.forFeature([ShareLinkEntity, UserSharePolicyEntity, ReportEntity, ReportLabValueEntity, ShareAccessEventEntity]),
```
Add import:
```typescript
import { ShareAccessEventEntity } from '../../database/entities/share-access-event.entity';
```

### Mobile: `sharing_repository.dart` Additions

Add `ShareAccessEvent` model (after `SharePolicy`):
```dart
class ShareAccessEvent {
  const ShareAccessEvent({
    required this.id,
    required this.accessedAt,
    required this.outcome,
  });
  final String id;
  final DateTime accessedAt;
  final String outcome; // 'accessed' | 'expired_or_revoked'

  factory ShareAccessEvent.fromJson(Map<String, dynamic> d) {
    return ShareAccessEvent(
      id: d['id'] as String,
      accessedAt: DateTime.parse(d['accessedAt'] as String),
      outcome: d['outcome'] as String,
    );
  }
}
```

Add abstract method to `SharingRepository`:
```dart
Future<List<ShareAccessEvent>> listAccessEvents(String linkId);
```

### Mobile: `api_sharing_repository.dart` Addition

```dart
@override
Future<List<ShareAccessEvent>> listAccessEvents(String linkId) async {
  final data = await _client.get('v1/sharing/links/$linkId/access-events');
  final list = data['data'] as List<dynamic>;
  return list.map((e) => ShareAccessEvent.fromJson(e as Map<String, dynamic>)).toList();
}
```

### Mobile: `share_access_history_screen.dart`

File: `apps/mobile/lib/features/sharing/screens/share_access_history_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../sharing_repository.dart';

class ShareAccessHistoryScreen extends StatefulWidget {
  const ShareAccessHistoryScreen({
    super.key,
    required this.linkId,
    required this.sharingRepository,
  });
  final String linkId;
  final SharingRepository sharingRepository;

  @override
  State<ShareAccessHistoryScreen> createState() => _ShareAccessHistoryScreenState();
}

class _ShareAccessHistoryScreenState extends State<ShareAccessHistoryScreen> {
  bool _loading = true;
  List<ShareAccessEvent> _events = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final events = await widget.sharingRepository.listAccessEvents(widget.linkId);
      if (mounted) setState(() { _events = events; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  String _formatDateTime(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _outcomeLabel(String outcome) => switch (outcome) {
    'accessed' => 'Viewed',
    'expired_or_revoked' => 'Blocked (expired/revoked)',
    _ => outcome,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Link Access History')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
          ? const Center(child: CircularProgressIndicator(key: Key('access-history-loading')))
          : _error != null
            ? Column(
                children: [
                  Text(_error!, key: const Key('access-history-error'),
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ],
              )
            : _events.isEmpty
              ? const Center(child: Text('No access events yet.', key: Key('access-history-empty')))
              : ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (_, i) {
                    final ev = _events[i];
                    return ListTile(
                      key: Key('access-event-${ev.id}'),
                      leading: Icon(
                        ev.outcome == 'accessed' ? Icons.check_circle_outline : Icons.block_outlined,
                        color: ev.outcome == 'accessed'
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                      ),
                      title: Text(_outcomeLabel(ev.outcome)),
                      subtitle: Text(_formatDateTime(ev.accessedAt.toLocal())),
                    );
                  },
                ),
      ),
    );
  }
}
```

### Mobile: `create_share_link_screen.dart` Change

In the `_existingLinks` list tile trailing `Row`, add a history `IconButton` before the share button:

```dart
IconButton(
  key: Key('access-history-link-${link.id}'),
  icon: const Icon(Icons.history_outlined),
  tooltip: 'View access history',
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ShareAccessHistoryScreen(
        linkId: link.id,
        sharingRepository: widget.sharingRepository,
      ),
    ),
  ),
),
```

Add import at the top of `create_share_link_screen.dart`:
```dart
import 'share_access_history_screen.dart';
```

### PHI / Security Rules

- **Do NOT record the token value in access events** — `shareLinkId` (UUID) is the identifier; the raw token string must never appear in logs or event records
- **Do NOT record IP address or user-agent** — no PII in event data; outcome + timestamp is sufficient per the architecture's PHI-safe telemetry guardrail
- **Event recording must not break the response** — if the `accessEventRepo.save()` throws unexpectedly, it will surface as a 500; this is acceptable (better to fail visibly than to silently skip). Do NOT add a try/catch that swallows the error.

### Project Structure Notes

- New entity path: `apps/api/src/database/entities/share-access-event.entity.ts` — matches pattern for cross-domain entities
- No new module directory needed — `ShareAccessEventEntity` extends the existing `sharing` module
- Mobile screen path: `apps/mobile/lib/features/sharing/screens/share_access_history_screen.dart` — follows feature screen pattern
- No new routes, guards, or module files needed beyond what's listed

### References

- `SharingService.getPublicShareData()` [Source: apps/api/src/modules/sharing/sharing.service.ts#L88]
- `SharingService.revokeShareLink()` — ownership check pattern to reuse [Source: apps/api/src/modules/sharing/sharing.service.ts#L165]
- `ShareLinkEntity` [Source: apps/api/src/database/entities/share-link.entity.ts]
- Existing entity pattern (CreateDateColumn, ManyToOne with string reference) [Source: apps/api/src/database/entities/share-link.entity.ts]
- Migration pattern [Source: apps/api/src/database/migrations/1730813800000-CreateShareLinksTable.ts]
- Migration registration pattern [Source: apps/api/src/database/migrations/index.ts]
- `SharingController` pattern (guards, `successResponse`, `getCorrelationId`) [Source: apps/api/src/modules/sharing/sharing.controller.ts]
- `SharingModule.forFeature` [Source: apps/api/src/modules/sharing/sharing.module.ts]
- Mobile `ApiSharingRepository` pattern [Source: apps/mobile/lib/features/sharing/api_sharing_repository.dart]
- Mobile `CreateShareLinkScreen` existing link tile [Source: apps/mobile/lib/features/sharing/screens/create_share_link_screen.dart#L182]
- Architecture: share-link security — "audited access events" [Source: _bmad-output/planning-artifacts/architecture.md — Authentication & Security section]
- Architecture: PHI-safe telemetry — no PHI in logs/events [Source: _bmad-output/planning-artifacts/architecture.md — Security & Telemetry Guardrails section]

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- Created `ShareAccessEventEntity` with uuid PK, shareLinkId FK (CASCADE), outcome varchar(32), accessedAt timestamptz
- Added migration `1730814100000-CreateShareAccessEventsTable` with index on share_link_id
- Registered migration in index.ts after CreateUserSharePoliciesTable
- Added `ShareAccessEventEntity` to SharingModule forFeature array
- Injected `accessEventRepo` in SharingService constructor
- Updated `getPublicShareData()` to record access event (outcome: accessed/expired_or_revoked) before validity check
- Added `AccessEventDto` interface and `listAccessEvents(userId, linkId)` method to SharingService
- Added `GET sharing/links/:id/access-events` endpoint to SharingController (ownership-checked via userId)
- Added `ShareAccessEvent` model and `listAccessEvents` abstract method to `sharing_repository.dart`
- Implemented `listAccessEvents` in `api_sharing_repository.dart`
- Created `share_access_history_screen.dart` with loading/error/empty/list states
- Added history IconButton to each existing link tile in `create_share_link_screen.dart`

### File List

- apps/api/src/database/entities/share-access-event.entity.ts (new)
- apps/api/src/database/migrations/1730814100000-CreateShareAccessEventsTable.ts (new)
- apps/api/src/database/migrations/index.ts (modified)
- apps/api/src/modules/sharing/sharing.module.ts (modified)
- apps/api/src/modules/sharing/sharing.service.ts (modified)
- apps/api/src/modules/sharing/sharing.controller.ts (modified)
- apps/mobile/lib/features/sharing/sharing_repository.dart (modified)
- apps/mobile/lib/features/sharing/api_sharing_repository.dart (modified)
- apps/mobile/lib/features/sharing/screens/share_access_history_screen.dart (new)
- apps/mobile/lib/features/sharing/screens/create_share_link_screen.dart (modified)

## Change Log

- 2026-03-23: Implemented story 3-7 — share access event history for link owner. Added ShareAccessEventEntity, migration, wired into SharingModule/Service/Controller, added GET access-events endpoint, mobile ShareAccessEvent model/repo/screen, history button on share link tiles.
