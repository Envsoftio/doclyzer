# Story 3.2: Share-Link Expiry and Revocation Controls

Status: review

## Story

As an authenticated user,
I want to set an optional expiry and revoke any active share link for my profile,
so that I can deterministically stop recipient access when I choose to or when a time limit elapses.

## Acceptance Criteria

1. **Given** a share link is being created via `POST /v1/sharing/links`
   **When** the request body includes an optional `expiresAt` (ISO-8601 future datetime string)
   **Then** the link is created with that expiry timestamp stored in `expires_at`
   **And** if `expiresAt` is in the past, the API returns 400 Bad Request with code `EXPIRY_MUST_BE_FUTURE`
   **And** if `expiresAt` is omitted, the link has no expiry (`expires_at` = NULL)

2. **Given** an authenticated user owns a share link
   **When** they call `DELETE /v1/sharing/links/:id`
   **Then** the link's `is_active` is set to `false`
   **And** the API returns 200 with `{ data: null }`
   **And** if the link ID does not exist or is not owned by the user, the API returns 404 with code `SHARE_LINK_NOT_FOUND`

3. **Given** a share link exists
   **When** `is_active = false` OR `expires_at <= NOW()`
   **Then** the link is treated as **invalid** (recipient access denied — enforced in story 3.5's public endpoint)
   **And** `isLinkValid(entity)` helper in `SharingService` correctly reflects this

4. **Given** an authenticated user owns a share link
   **When** they call `PATCH /v1/sharing/links/:id/expiry` with `{ expiresAt: "<iso-string>" }` or `{ expiresAt: null }`
   **Then** the link's `expires_at` is updated
   **And** the API returns 200 with the updated `ShareLinkDto`
   **And** past `expiresAt` is rejected with 400 / `EXPIRY_MUST_BE_FUTURE`
   **And** unowned link IDs return 404 / `SHARE_LINK_NOT_FOUND`

5. **Given** an authenticated user calls `GET /v1/sharing/links?profileId=<uuid>`
   **When** the request is processed
   **Then** the API returns all links where `user_id = userId` AND `profile_id = profileId` AND `is_active = true` AND (`expires_at IS NULL OR expires_at > NOW()`)
   **And** if `profileId` is missing from query, returns 400 / `PROFILE_ID_REQUIRED`
   **And** if user does not own the profile, returns 404 / `PROFILE_NOT_FOUND` (reuse existing `ProfileNotFoundException`)

6. **Given** the Flutter app's `CreateShareLinkScreen` opens for a profile
   **When** the screen loads
   **Then** existing active (non-expired) share links for the profile are fetched and shown at the top
   **And** each listed link shows its `shareUrl`, creation date, expiry (or "No expiry"), and a "Revoke" button

7. **Given** the user taps "Revoke" on an existing link
   **When** the confirmation dialog is accepted ("This link will stop working. You can create a new one.")
   **Then** the link is revoked via the API and removed from the list
   **And** if the user cancels the dialog, no action is taken

8. **Given** the user creates a new link
   **When** the idle state is shown
   **Then** an optional expiry date picker row is visible (default: "No expiry")
   **And** the selected expiry (if any) is passed to the `createShareLink` API call

9. **Given** a link was just created (created state)
   **When** shown to the user
   **Then** a "Revoke" button is shown below "Copy Link"
   **And** tapping "Revoke" shows the same confirmation dialog as AC7

## Tasks / Subtasks

- [x] Backend: Add `expires_at` column to `share_links` table via migration (AC: 1, 3)
  - [x] Create `apps/api/src/database/migrations/1730813900000-AddExpiresAtToShareLinks.ts`
  - [x] `up`: `ALTER TABLE "share_links" ADD COLUMN "expires_at" TIMESTAMPTZ NULL`
  - [x] `down`: `ALTER TABLE "share_links" DROP COLUMN "expires_at"`
  - [x] Add `AddExpiresAtToShareLinks1730813900000` to `apps/api/src/database/migrations/index.ts`

- [x] Backend: Update `ShareLinkEntity` to include `expiresAt` field (AC: 1, 3)
  - [x] Add `@Column({ type: 'timestamptz', name: 'expires_at', nullable: true }) expiresAt!: Date | null;` to `apps/api/src/database/entities/share-link.entity.ts`

- [x] Backend: Add error codes + exception to sharing module (AC: 2, 4)
  - [x] Add `export const SHARE_LINK_NOT_FOUND = 'SHARE_LINK_NOT_FOUND';` and `export const EXPIRY_MUST_BE_FUTURE = 'EXPIRY_MUST_BE_FUTURE';` to `apps/api/src/modules/sharing/sharing.types.ts`
  - [x] Create `apps/api/src/modules/sharing/exceptions/share-link-not-found.exception.ts` (follows `report-not-found.exception.ts` pattern)

- [x] Backend: Extend `SharingService` with list, revoke, updateExpiry, isLinkValid methods (AC: 2, 3, 4, 5)
  - [x] Update `ShareLinkDto` in `sharing.service.ts` to include `isActive: boolean` and `expiresAt: string | null`
  - [x] Update `createShareLink` to accept optional `expiresAt?: Date` and validate it's in the future
  - [x] Add `listShareLinks(userId: string, profileId: string): Promise<ShareLinkDto[]>` method
  - [x] Add `revokeShareLink(userId: string, linkId: string): Promise<void>` method
  - [x] Add `updateExpiry(userId: string, linkId: string, expiresAt: Date | null): Promise<ShareLinkDto>` method
  - [x] Add `isLinkValid(entity: ShareLinkEntity): boolean` helper method

- [x] Backend: Extend `SharingController` with list, revoke, update-expiry endpoints (AC: 1, 2, 4, 5)
  - [x] Add `GET /links?profileId=...` endpoint
  - [x] Add `DELETE /links/:id` endpoint (returns 200 with `{ data: null }`)
  - [x] Add `PATCH /links/:id/expiry` endpoint
  - [x] Update `POST /links` to accept optional `expiresAt` in body and validate

- [x] Flutter: Update `ShareLink` model and `SharingRepository` (AC: 6, 7, 8, 9)
  - [x] Add `isActive` (`bool`) and `expiresAt` (`DateTime?`) to `ShareLink` class in `sharing_repository.dart`
  - [x] Add abstract methods: `listShareLinks(String profileId)`, `revokeShareLink(String id)`, `setShareLinkExpiry(String id, DateTime? expiresAt)` to `SharingRepository`
  - [x] Update `createShareLink` abstract signature to `createShareLink(String profileId, {DateTime? expiresAt})`

- [x] Flutter: Implement new methods in `ApiSharingRepository` (AC: 6, 7, 8, 9)
  - [x] Implement `listShareLinks`: `GET v1/sharing/links?profileId=...`
  - [x] Implement `revokeShareLink`: `DELETE v1/sharing/links/$id` (uses `_client.delete()` which returns `void`)
  - [x] Implement `setShareLinkExpiry`: `PATCH v1/sharing/links/$id/expiry` with `body: {'expiresAt': expiresAt?.toIso8601String()}`
  - [x] Update `createShareLink` to pass optional `expiresAt` in POST body
  - [x] Update `ShareLink.fromJson` helper to parse `isActive` and `expiresAt` fields

- [x] Flutter: Update `CreateShareLinkScreen` with expiry picker, existing links list, revoke flow (AC: 6, 7, 8, 9)
  - [x] Load existing links on init; show loading indicator for list, idle create form below
  - [x] Render each existing link with url, dates, and "Revoke" button
  - [x] Add `showDatePicker` expiry picker row to idle create state
  - [x] Pass `expiresAt` to `createShareLink` call
  - [x] Show "Revoke" button in created state; show confirmation dialog before revoking

## Dev Notes

### Scope: What this story builds and what it does NOT
- **Builds:** DB column for expiry, revoke + expiry update APIs, list API, Flutter UI for listing/revoking/setting expiry at creation time
- **Does NOT build:** The public recipient access endpoint that enforces validity (story 3.5 calls `isLinkValid()` which is added here); default share policy settings (story 3.3); copy/distribute UX beyond what was in 3.1 (story 3.4)
- `isLinkValid()` is added here as a service helper and intentionally left unused until story 3.5

### Backend: Migration — exact file
```typescript
// apps/api/src/database/migrations/1730813900000-AddExpiresAtToShareLinks.ts
import type { MigrationInterface, QueryRunner } from 'typeorm';

export class AddExpiresAtToShareLinks1730813900000 implements MigrationInterface {
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "share_links" ADD COLUMN "expires_at" TIMESTAMPTZ NULL`
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "share_links" DROP COLUMN "expires_at"`
    );
  }
}
```

Add to `migrations/index.ts`:
```typescript
import { AddExpiresAtToShareLinks1730813900000 } from './1730813900000-AddExpiresAtToShareLinks';
// ...in migrations array:
AddExpiresAtToShareLinks1730813900000,
```

### Backend: Entity update — exact line to add
File: `apps/api/src/database/entities/share-link.entity.ts`
Add after the `isActive` line:
```typescript
@Column({ type: 'timestamptz', name: 'expires_at', nullable: true }) expiresAt!: Date | null;
```

### Backend: Exception file — follow exact report pattern
```typescript
// apps/api/src/modules/sharing/exceptions/share-link-not-found.exception.ts
import { NotFoundException } from '@nestjs/common';
import { SHARE_LINK_NOT_FOUND } from '../sharing.types';

export class ShareLinkNotFoundException extends NotFoundException {
  constructor() {
    super({ code: SHARE_LINK_NOT_FOUND, message: 'Share link not found' });
  }
}
```

### Backend: Updated `sharing.types.ts`
```typescript
export const PROFILE_ID_REQUIRED = 'PROFILE_ID_REQUIRED';
export const SHARE_LINK_NOT_FOUND = 'SHARE_LINK_NOT_FOUND';
export const EXPIRY_MUST_BE_FUTURE = 'EXPIRY_MUST_BE_FUTURE';
```

### Backend: Updated `ShareLinkDto` + full `SharingService`
```typescript
// sharing.service.ts
import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { IsNull, MoreThan, Or, Repository } from 'typeorm';
import { randomUUID } from 'node:crypto';
import { ShareLinkEntity } from '../../database/entities/share-link.entity';
import { ProfilesService } from '../profiles/profiles.service';
import { ShareLinkNotFoundException } from './exceptions/share-link-not-found.exception';
import { EXPIRY_MUST_BE_FUTURE } from './sharing.types';

export interface ShareLinkDto {
  id: string;
  token: string;
  shareUrl: string;
  profileId: string;
  scope: string;
  isActive: boolean;
  expiresAt: string | null; // ISO string or null
  createdAt: string;        // ISO string
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

  private toDto(entity: ShareLinkEntity): ShareLinkDto {
    return {
      id: entity.id,
      token: entity.token,
      shareUrl: `${this.shareBaseUrl}/share/${entity.token}`,
      profileId: entity.profileId,
      scope: entity.scope,
      isActive: entity.isActive,
      expiresAt: entity.expiresAt ? entity.expiresAt.toISOString() : null,
      createdAt: entity.createdAt.toISOString(),
    };
  }

  /** Returns true when link can be used by a recipient. Called by story 3.5 public endpoint. */
  isLinkValid(entity: ShareLinkEntity): boolean {
    if (!entity.isActive) return false;
    if (entity.expiresAt && entity.expiresAt <= new Date()) return false;
    return true;
  }

  async createShareLink(
    userId: string,
    profileId: string,
    scope = 'all',
    expiresAt?: Date,
  ): Promise<ShareLinkDto> {
    if (expiresAt && expiresAt <= new Date()) {
      throw new BadRequestException({ code: EXPIRY_MUST_BE_FUTURE, message: 'expiresAt must be a future date' });
    }
    // Throws ProfileNotFoundException (404) if user doesn't own profile
    await this.profilesService.getProfile(userId, profileId);
    const token = randomUUID();
    const entity = this.shareLinkRepo.create({ userId, profileId, token, scope, expiresAt: expiresAt ?? null });
    const saved = await this.shareLinkRepo.save(entity);
    return this.toDto(saved);
  }

  async listShareLinks(userId: string, profileId: string): Promise<ShareLinkDto[]> {
    // Ownership check: ProfilesService throws ProfileNotFoundException if not owned
    await this.profilesService.getProfile(userId, profileId);
    const now = new Date();
    const links = await this.shareLinkRepo.find({
      where: {
        userId,
        profileId,
        isActive: true,
        expiresAt: Or(IsNull(), MoreThan(now)),
      },
      order: { createdAt: 'DESC' },
    });
    return links.map((l) => this.toDto(l));
  }

  async revokeShareLink(userId: string, linkId: string): Promise<void> {
    const link = await this.shareLinkRepo.findOne({ where: { id: linkId, userId } });
    if (!link) throw new ShareLinkNotFoundException();
    link.isActive = false;
    await this.shareLinkRepo.save(link);
  }

  async updateExpiry(userId: string, linkId: string, expiresAt: Date | null): Promise<ShareLinkDto> {
    if (expiresAt && expiresAt <= new Date()) {
      throw new BadRequestException({ code: EXPIRY_MUST_BE_FUTURE, message: 'expiresAt must be a future date' });
    }
    const link = await this.shareLinkRepo.findOne({ where: { id: linkId, userId } });
    if (!link) throw new ShareLinkNotFoundException();
    link.expiresAt = expiresAt;
    const saved = await this.shareLinkRepo.save(link);
    return this.toDto(saved);
  }
}
```

**TypeORM import note:** `Or`, `IsNull`, `MoreThan` are from `'typeorm'` (all already available). If TypeORM version doesn't support `Or(IsNull(), MoreThan(now))` directly in the `where` clause (version < 0.3.12), use a `QueryBuilder` instead:
```typescript
const links = await this.shareLinkRepo
  .createQueryBuilder('sl')
  .where('sl.user_id = :userId', { userId })
  .andWhere('sl.profile_id = :profileId', { profileId })
  .andWhere('sl.is_active = true')
  .andWhere('(sl.expires_at IS NULL OR sl.expires_at > :now)', { now })
  .orderBy('sl.created_at', 'DESC')
  .getMany();
```
Check TypeORM version in `apps/api/package.json` before choosing approach. The QueryBuilder version is always safe.

### Backend: Updated `SharingController`
```typescript
// sharing.controller.ts
import {
  BadRequestException, Body, Controller, Delete, Get, HttpCode,
  HttpStatus, Param, Patch, Post, Query, Req, UseGuards
} from '@nestjs/common';
import type { Request } from 'express';
import type { RequestUser } from '../auth/auth.types';
import { AuthGuard } from '../../common/guards/auth.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import { SharingService } from './sharing.service';
import { EXPIRY_MUST_BE_FUTURE, PROFILE_ID_REQUIRED } from './sharing.types';

@Controller('sharing')
@UseGuards(AuthGuard)
export class SharingController {
  constructor(private readonly sharingService: SharingService) {}

  @Post('links')
  @HttpCode(HttpStatus.CREATED)
  async createShareLink(
    @Body() body: { profileId?: string; expiresAt?: string },
    @Req() req: Request,
  ): Promise<object> {
    if (!body?.profileId) {
      throw new BadRequestException({ code: PROFILE_ID_REQUIRED, message: 'profileId is required' });
    }
    const { id: userId } = req.user as RequestUser;
    let expiresAt: Date | undefined;
    if (body.expiresAt) {
      expiresAt = new Date(body.expiresAt);
      if (isNaN(expiresAt.getTime())) {
        throw new BadRequestException({ code: EXPIRY_MUST_BE_FUTURE, message: 'expiresAt must be a valid ISO datetime' });
      }
    }
    const data = await this.sharingService.createShareLink(userId, body.profileId, 'all', expiresAt);
    return successResponse(data, getCorrelationId(req));
  }

  @Get('links')
  async listShareLinks(
    @Query('profileId') profileId: string | undefined,
    @Req() req: Request,
  ): Promise<object> {
    if (!profileId) {
      throw new BadRequestException({ code: PROFILE_ID_REQUIRED, message: 'profileId is required' });
    }
    const { id: userId } = req.user as RequestUser;
    const data = await this.sharingService.listShareLinks(userId, profileId);
    return successResponse(data, getCorrelationId(req));
  }

  @Delete('links/:id')
  @HttpCode(HttpStatus.OK)
  async revokeShareLink(
    @Param('id') linkId: string,
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    await this.sharingService.revokeShareLink(userId, linkId);
    return successResponse(null, getCorrelationId(req));
  }

  @Patch('links/:id/expiry')
  async updateExpiry(
    @Param('id') linkId: string,
    @Body() body: { expiresAt: string | null },
    @Req() req: Request,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    let expiresAt: Date | null = null;
    if (body.expiresAt) {
      expiresAt = new Date(body.expiresAt);
      if (isNaN(expiresAt.getTime())) {
        throw new BadRequestException({ code: EXPIRY_MUST_BE_FUTURE, message: 'expiresAt must be a valid ISO datetime' });
      }
    }
    const data = await this.sharingService.updateExpiry(userId, linkId, expiresAt);
    return successResponse(data, getCorrelationId(req));
  }
}
```

### Flutter: Updated `ShareLink` model and `SharingRepository`
```dart
// sharing_repository.dart
class ShareLink {
  const ShareLink({
    required this.id,
    required this.token,
    required this.shareUrl,
    required this.profileId,
    required this.scope,
    required this.isActive,
    required this.createdAt,
    this.expiresAt,
  });
  final String id;
  final String token;
  final String shareUrl;
  final String profileId;
  final String scope;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;

  // Factory for parsing JSON — both GET list and POST/PATCH responses use this
  factory ShareLink.fromJson(Map<String, dynamic> d) {
    return ShareLink(
      id: d['id'] as String,
      token: d['token'] as String,
      shareUrl: d['shareUrl'] as String,
      profileId: d['profileId'] as String,
      scope: d['scope'] as String,
      isActive: d['isActive'] as bool,
      createdAt: DateTime.parse(d['createdAt'] as String),
      expiresAt: d['expiresAt'] != null
          ? DateTime.parse(d['expiresAt'] as String)
          : null,
    );
  }
}

abstract class SharingRepository {
  Future<ShareLink> createShareLink(String profileId, {DateTime? expiresAt});
  Future<List<ShareLink>> listShareLinks(String profileId);
  Future<void> revokeShareLink(String id);
  Future<ShareLink> setShareLinkExpiry(String id, DateTime? expiresAt);
}
```

### Flutter: Updated `ApiSharingRepository`
```dart
// api_sharing_repository.dart
import '../../core/api_client.dart';
import 'sharing_repository.dart';

class ApiSharingRepository implements SharingRepository {
  ApiSharingRepository(this._client);
  final ApiClient _client;

  @override
  Future<ShareLink> createShareLink(String profileId, {DateTime? expiresAt}) async {
    final body = <String, dynamic>{'profileId': profileId};
    if (expiresAt != null) body['expiresAt'] = expiresAt.toIso8601String();
    final data = await _client.post('v1/sharing/links', body: body);
    return ShareLink.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<ShareLink>> listShareLinks(String profileId) async {
    final data = await _client.get('v1/sharing/links?profileId=$profileId');
    final list = data['data'] as List<dynamic>;
    return list.map((e) => ShareLink.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> revokeShareLink(String id) async {
    // ApiClient.delete() returns Future<void> — no response to parse
    await _client.delete('v1/sharing/links/$id');
  }

  @override
  Future<ShareLink> setShareLinkExpiry(String id, DateTime? expiresAt) async {
    final data = await _client.patch(
      'v1/sharing/links/$id/expiry',
      body: {'expiresAt': expiresAt?.toIso8601String()},
    );
    return ShareLink.fromJson(data['data'] as Map<String, dynamic>);
  }
}
```

### Flutter: Updated `CreateShareLinkScreen` — full structure
```dart
// create_share_link_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../sharing_repository.dart';

enum _CreateState { idle, loading, created, error }

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

  @override
  State<CreateShareLinkScreen> createState() => _CreateShareLinkScreenState();
}

class _CreateShareLinkScreenState extends State<CreateShareLinkScreen> {
  // Existing links loading state
  bool _loadingExistingLinks = false;
  List<ShareLink> _existingLinks = [];
  String? _listError;

  // Create new link state
  _CreateState _createState = _CreateState.idle;
  ShareLink? _newLink;
  String? _createError;
  DateTime? _selectedExpiry; // null = no expiry

  @override
  void initState() {
    super.initState();
    _loadExistingLinks();
  }

  Future<void> _loadExistingLinks() async {
    setState(() { _loadingExistingLinks = true; _listError = null; });
    try {
      final links = await widget.sharingRepository.listShareLinks(widget.profileId);
      if (mounted) setState(() { _existingLinks = links; _loadingExistingLinks = false; });
    } catch (e) {
      if (mounted) setState(() { _loadingExistingLinks = false; _listError = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  Future<void> _createLink() async {
    setState(() { _createState = _CreateState.loading; _createError = null; });
    try {
      final link = await widget.sharingRepository.createShareLink(
        widget.profileId,
        expiresAt: _selectedExpiry,
      );
      if (mounted) setState(() { _newLink = link; _createState = _CreateState.created; });
    } catch (e) {
      if (mounted) setState(() { _createState = _CreateState.error; _createError = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  Future<void> _copyLink(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copied to clipboard')),
      );
    }
  }

  Future<void> _revokeLink(String linkId, {bool isNewLink = false}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke share link?'),
        content: const Text('This link will stop working. You can create a new one.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            key: const Key('revoke-confirm-button'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.sharingRepository.revokeShareLink(linkId);
      if (!mounted) return;
      if (isNewLink) {
        setState(() { _newLink = null; _createState = _CreateState.idle; });
      } else {
        setState(() { _existingLinks.removeWhere((l) => l.id == linkId); });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to revoke: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    }
  }

  Future<void> _pickExpiry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() { _selectedExpiry = picked; });
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Share ${widget.profileName}\'s Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Existing links section ---
              if (_loadingExistingLinks)
                const Center(child: CircularProgressIndicator(key: Key('existing-links-loading')))
              else if (_existingLinks.isNotEmpty) ...[
                const Text('Active share links', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...List.generate(_existingLinks.length, (i) {
                  final link = _existingLinks[i];
                  final expiry = link.expiresAt != null
                      ? 'Expires ${_formatDate(link.expiresAt!)}'
                      : 'No expiry';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(link.shareUrl, style: const TextStyle(fontSize: 12)),
                      subtitle: Text('Created ${_formatDate(link.createdAt)} · $expiry'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy_outlined),
                            tooltip: 'Copy link',
                            onPressed: () => _copyLink(link.shareUrl),
                          ),
                          TextButton(
                            key: Key('revoke-existing-link-${link.id}'),
                            onPressed: () => _revokeLink(link.id),
                            child: const Text('Revoke'),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const Divider(height: 24),
              ],
              if (_listError != null) ...[
                Text(_listError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                const SizedBox(height: 8),
              ],

              // --- Create new link section ---
              if (_createState == _CreateState.idle || _createState == _CreateState.error) ...[
                const Text('Create a new share link'),
                const SizedBox(height: 12),
                // Expiry picker row
                Row(
                  children: [
                    const Text('Expiry:'),
                    const SizedBox(width: 8),
                    TextButton(
                      key: const Key('share-link-expiry-picker'),
                      onPressed: _pickExpiry,
                      child: Text(_selectedExpiry != null ? _formatDate(_selectedExpiry!) : 'No expiry'),
                    ),
                    if (_selectedExpiry != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _selectedExpiry = null),
                        tooltip: 'Clear expiry',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  key: const Key('create-share-link-button'),
                  onPressed: _createState == _CreateState.loading ? null : _createLink,
                  child: const Text('Create Share Link'),
                ),
                if (_createState == _CreateState.error) ...[
                  const SizedBox(height: 8),
                  Text(
                    _createError ?? 'Something went wrong',
                    key: const Key('share-link-error'),
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  TextButton(onPressed: _createLink, child: const Text('Try Again')),
                ],
              ],
              if (_createState == _CreateState.loading)
                const Center(child: CircularProgressIndicator(key: Key('create-share-link-loading'))),
              if (_createState == _CreateState.created && _newLink != null) ...[
                const Text('Share link created!'),
                const SizedBox(height: 8),
                SelectableText(_newLink!.shareUrl, key: const Key('share-url-text')),
                if (_newLink!.expiresAt != null) ...[
                  const SizedBox(height: 4),
                  Text('Expires: ${_formatDate(_newLink!.expiresAt!)}',
                      style: const TextStyle(fontSize: 12)),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  key: const Key('copy-link-button'),
                  onPressed: () => _copyLink(_newLink!.shareUrl),
                  child: const Text('Copy Link'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  key: const Key('new-link-revoke-button'),
                  onPressed: () => _revokeLink(_newLink!.id, isNewLink: true),
                  child: const Text('Revoke Link'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

### Flutter: No changes to `timeline_screen.dart` or `main.dart`
The `TimelineScreen` still opens `CreateShareLinkScreen` — no change to the navigation call or constructor. The screen is now richer but the call site is unchanged.

### Flutter: `mocks.dart` update for tests
`MockSharingRepository` in `apps/mobile/test/mocks.dart` must implement the new abstract methods. Add:
```dart
// In MockSharingRepository class:
@override
Future<ShareLink> createShareLink(String profileId, {DateTime? expiresAt}) async {
  return /* existing mock return */;
}

@override
Future<List<ShareLink>> listShareLinks(String profileId) async => [];

@override
Future<void> revokeShareLink(String id) async {}

@override
Future<ShareLink> setShareLinkExpiry(String id, DateTime? expiresAt) async {
  throw UnimplementedError();
}
```

### Widget keys summary (kebab-case, consistent with project convention)
| Key | State / Purpose |
|-----|----------------|
| `Key('existing-links-loading')` | CircularProgressIndicator during list load |
| `Key('revoke-existing-link-$id')` | Revoke TextButton per existing link (dynamic ID) |
| `Key('share-link-expiry-picker')` | Date picker TextButton in idle state |
| `Key('create-share-link-button')` | Create button in idle/error state |
| `Key('create-share-link-loading')` | Loading indicator during create |
| `Key('share-link-error')` | Error text in error state |
| `Key('share-url-text')` | SelectableText for new link URL |
| `Key('copy-link-button')` | Copy link button in created state |
| `Key('new-link-revoke-button')` | Revoke button for newly created link |
| `Key('revoke-confirm-button')` | Confirm button inside revoke AlertDialog |

### API patterns followed (critical)
- All existing patterns from story 3.1 continue: `successResponse()` envelope, `getCorrelationId(req)`, `@UseGuards(AuthGuard)` at class level (inherited), `req.user as RequestUser` for userId
- `DELETE /links/:id` returns `successResponse(null, correlationId)` with HTTP 200 (not 204) — consistent with project's response envelope pattern which always wraps in `{ data: ... }`
- Ownership check for list uses `ProfilesService.getProfile()` (throws `ProfileNotFoundException` 404 automatically) — same pattern as create
- Ownership check for revoke/updateExpiry uses `shareLinkRepo.findOne({ where: { id, userId } })` — direct user_id check without going through profiles (faster, no additional join)
- No PHI in logs — do not log token, profileId, or user data

### TypeORM `Or/IsNull/MoreThan` availability check
```bash
# In project root or apps/api:
grep '"typeorm"' apps/api/package.json
```
`Or()` operator was added in TypeORM 0.3.12. If version is < 0.3.12, use the QueryBuilder approach shown in the service notes above. The QueryBuilder approach is always safe regardless of version.

### Project structure compliance
- New exception file path: `apps/api/src/modules/sharing/exceptions/share-link-not-found.exception.ts`
- Migration file path: `apps/api/src/database/migrations/1730813900000-AddExpiresAtToShareLinks.ts`
- No changes to `sharing.module.ts` — no new providers or imports needed
- No changes to `app.module.ts` — entity already registered in story 3.1

### References
- [Source: _bmad-output/planning-artifacts/epics.md#Story 3.2]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Journey 3] — revoke UX, "Link will stop working" confirm copy
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#2.7 Stress-Tested Requirements] — manage links, revoke placement, confirm dialog
- [Source: _bmad-output/implementation-artifacts/3-1-create-share-link-for-active-profile-scope.md] — full 3.1 implementation context
- [Source: apps/api/src/modules/sharing/sharing.service.ts] — existing service to extend
- [Source: apps/api/src/modules/sharing/sharing.controller.ts] — existing controller to extend
- [Source: apps/api/src/database/entities/share-link.entity.ts] — entity to add column to
- [Source: apps/api/src/database/migrations/index.ts] — migration registration
- [Source: apps/api/src/modules/reports/exceptions/report-not-found.exception.ts] — exception pattern
- [Source: apps/api/src/modules/reports/reports.controller.ts] — controller HTTP decorator patterns (Get, Delete, Patch, Query, Param)
- [Source: apps/mobile/lib/core/api_client.dart:46,100,140] — `get()`, `patch({body:})`, `delete()` signatures
- [Source: apps/mobile/lib/features/sharing/sharing_repository.dart] — existing ShareLink model to extend
- [Source: apps/mobile/lib/features/sharing/api_sharing_repository.dart] — ApiSharingRepository to extend
- [Source: apps/mobile/lib/features/sharing/screens/create_share_link_screen.dart] — screen to extend
- [Source: apps/mobile/test/mocks.dart] — MockSharingRepository to update

## Dev Agent Record

### Agent Model Used

claude-sonnet-4-6

### Debug Log References

### Completion Notes List

- Implemented all 9 tasks: migration, entity, error codes, exception, service (list/revoke/updateExpiry/isLinkValid/createShareLink extended), controller (GET/DELETE/PATCH/POST updated), Flutter ShareLink model, SharingRepository abstract interface, ApiSharingRepository, and CreateShareLinkScreen full rewrite.
- Used TypeORM `Or(IsNull(), MoreThan(now))` for active link filtering (confirmed TypeORM 0.3.28 supports it).
- `isLinkValid()` added to SharingService but unused until story 3.5 (by design).
- `MockSharingRepository extends Mock implements SharingRepository` — no changes needed; mocktail handles new abstract methods via noSuchMethod.
- TypeScript and Flutter `flutter analyze` pass with no errors in sharing module.

### File List

- apps/api/src/database/migrations/1730813900000-AddExpiresAtToShareLinks.ts (new)
- apps/api/src/database/migrations/index.ts (modified)
- apps/api/src/database/entities/share-link.entity.ts (modified)
- apps/api/src/modules/sharing/sharing.types.ts (modified)
- apps/api/src/modules/sharing/exceptions/share-link-not-found.exception.ts (new)
- apps/api/src/modules/sharing/sharing.service.ts (modified)
- apps/api/src/modules/sharing/sharing.controller.ts (modified)
- apps/mobile/lib/features/sharing/sharing_repository.dart (modified)
- apps/mobile/lib/features/sharing/api_sharing_repository.dart (modified)
- apps/mobile/lib/features/sharing/screens/create_share_link_screen.dart (modified)

## Change Log

- 2026-03-22: Implemented story 3.2 — added expires_at migration, entity field, error codes/exception, SharingService methods (list/revoke/updateExpiry/isLinkValid), SharingController endpoints (GET list, DELETE revoke, PATCH expiry, POST extended), Flutter ShareLink model with isActive/expiresAt, SharingRepository abstract interface, ApiSharingRepository, and full CreateShareLinkScreen rewrite with existing links list, expiry picker, and revoke flow.
