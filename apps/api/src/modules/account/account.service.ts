import {
  ConflictException,
  Inject,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { isUUID } from 'class-validator';
import { Repository } from 'typeorm';
import { AccountPreferenceEntity } from '../../database/entities/account-preference.entity';
import { RestrictionEntity } from '../../database/entities/restriction.entity';
import { DataExportRequestEntity } from '../../database/entities/data-export-request.entity';
import { ClosureRequestEntity } from '../../database/entities/closure-request.entity';
import { ProfileEntity } from '../../database/entities/profile.entity';
import { ConsentRecordEntity } from '../../database/entities/consent-record.entity';
import { UserEntity } from '../../database/entities/user.entity';
import { ReportEntity } from '../../database/entities/report.entity';
import { AuthService } from '../auth/auth.service';
import { AccountOverrideService } from '../audit-incident/account-override.service';
import { NotificationPipelineService } from '../../common/notification-pipeline/notification-pipeline.service';
import { NotifiableEventType } from '../../common/notification-pipeline/notification-event.types';
import type { FileStorageService } from '../../common/storage/file-storage.interface';
import { FILE_STORAGE } from '../../common/storage/storage.module';
import { ReferralsService } from '../referrals/referrals.service';
import type {
  UpdateAccountProfileDto,
  UpdateCommunicationPreferencesDto,
  CreateClosureRequestDto,
} from './account.dto';
import type {
  AccountProfile,
  CommunicationPreferences,
  DataExportRequest,
  ClosureRequest,
  RestrictionStatus,
} from './account.types';
import {
  COMM_PREF_CATEGORY,
  ClosureConfirmationRequiredException,
} from './account.types';
import {
  ACCOUNT_SUSPENDED_RESTRICTED_ACTIONS,
  RESTRICTED_REVIEW_ACTIONS,
} from '../../common/restriction/restriction.constants';

@Injectable()
export class AccountService {
  private readonly logger = new Logger(AccountService.name);

  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(AccountPreferenceEntity)
    private readonly prefRepo: Repository<AccountPreferenceEntity>,
    @InjectRepository(RestrictionEntity)
    private readonly restrictionRepo: Repository<RestrictionEntity>,
    @InjectRepository(DataExportRequestEntity)
    private readonly exportRepo: Repository<DataExportRequestEntity>,
    @InjectRepository(ClosureRequestEntity)
    private readonly closureRepo: Repository<ClosureRequestEntity>,
    @InjectRepository(ProfileEntity)
    private readonly profileRepo: Repository<ProfileEntity>,
    @InjectRepository(ConsentRecordEntity)
    private readonly consentRepo: Repository<ConsentRecordEntity>,
    private readonly authService: AuthService,
    private readonly accountOverrideService: AccountOverrideService,
    @Inject(FILE_STORAGE) private readonly fileStorage: FileStorageService,
    private readonly notificationPipeline: NotificationPipelineService,
    private readonly referralsService: ReferralsService,
  ) {}

  async getRestrictionStatus(userId: string): Promise<RestrictionStatus> {
    const entry = await this.restrictionRepo.findOne({ where: { userId } });

    // Evaluate active overrides regardless of restriction state (auto-reverts expired ones)
    const { overriddenActions, overrides: activeOverrides } =
      await this.accountOverrideService.evaluateActiveOverrides(userId);

    if (!entry) {
      if (activeOverrides.length === 0) return { isRestricted: false };
      // No restriction but active overrides exist — surface them for visibility
      return {
        isRestricted: false,
        activeOverrides: activeOverrides.map((o) => ({
          id: o.id,
          overriddenActions: o.overriddenActions,
          expiresAt: o.expiresAt,
          reason: o.reason,
        })),
      };
    }

    if (this.isRestrictionExpired(entry)) {
      await this.clearExpiredRestriction(entry);
      if (activeOverrides.length === 0) return { isRestricted: false };
      return {
        isRestricted: false,
        activeOverrides: activeOverrides.map((o) => ({
          id: o.id,
          overriddenActions: o.overriddenActions,
          expiresAt: o.expiresAt,
          reason: o.reason,
        })),
      };
    }

    if (!entry.isRestricted && !entry.restrictedReviewMode) {
      if (activeOverrides.length === 0) return { isRestricted: false };
      return {
        isRestricted: false,
        activeOverrides: activeOverrides.map((o) => ({
          id: o.id,
          overriddenActions: o.overriddenActions,
          expiresAt: o.expiresAt,
          reason: o.reason,
        })),
      };
    }

    const mode = entry.isRestricted ? 'suspended' : 'review';
    const allRestrictedActions =
      mode === 'suspended'
        ? [...ACCOUNT_SUSPENDED_RESTRICTED_ACTIONS]
        : [...RESTRICTED_REVIEW_ACTIONS];

    // Precedence rule: active override lifts specific restricted actions.
    // Overridden actions are removed from the effective restricted list.
    const overriddenSet = new Set(overriddenActions);
    const effectiveRestrictedActions = allRestrictedActions.filter(
      (a) => !overriddenSet.has(a),
    );

    return {
      isRestricted: true,
      mode,
      restrictedUntil: entry.restrictedUntil?.toISOString(),
      rationale: entry.rationale ?? undefined,
      nextSteps: entry.nextSteps ?? undefined,
      restrictedActions: effectiveRestrictedActions,
      ...(activeOverrides.length > 0 && {
        activeOverrides: activeOverrides.map((o) => ({
          id: o.id,
          overriddenActions: o.overriddenActions,
          expiresAt: o.expiresAt,
          reason: o.reason,
        })),
      }),
    };
  }

  async getProfile(userId: string): Promise<AccountProfile> {
    await this.referralsService.releasePendingInviteeBonusForUser({
      userId,
      correlationId: `account-profile:${userId}`,
      trigger: 'account_profile',
    });

    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException({
        code: 'ACCOUNT_NOT_FOUND',
        message: 'Account not found',
      });
    }
    let avatarUrl: string | null = null;
    if (user.avatarUrl) {
      avatarUrl = await this.fileStorage.getSignedUrl(user.avatarUrl, 300);
    }
    return {
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      avatarUrl,
      createdAt: user.createdAt,
    };
  }

  async getCommunicationPreferences(
    userId: string,
  ): Promise<CommunicationPreferences> {
    const pref = await this.prefRepo.findOne({ where: { userId } });
    const productEnabled = pref?.productEmailsEnabled ?? true;
    return {
      preferences: [
        {
          category: COMM_PREF_CATEGORY.SECURITY,
          enabled: true,
          mandatory: true,
        },
        {
          category: COMM_PREF_CATEGORY.COMPLIANCE,
          enabled: true,
          mandatory: true,
        },
        {
          category: COMM_PREF_CATEGORY.PRODUCT,
          enabled: productEnabled,
          mandatory: false,
        },
      ],
    };
  }

  async updateCommunicationPreferences(
    userId: string,
    dto: UpdateCommunicationPreferencesDto,
  ): Promise<CommunicationPreferences> {
    let pref = await this.prefRepo.findOne({ where: { userId } });
    if (!pref) {
      pref = this.prefRepo.create({ userId, productEmailsEnabled: true });
    }
    if (dto.productEmails !== undefined)
      pref.productEmailsEnabled = dto.productEmails;
    await this.prefRepo.save(pref);
    return this.getCommunicationPreferences(userId);
  }

  async updateProfile(
    userId: string,
    dto: UpdateAccountProfileDto,
  ): Promise<AccountProfile> {
    await this.userRepo.manager.transaction(async (manager) => {
      const user = await manager.findOne(UserEntity, {
        where: { id: userId },
        lock: { mode: 'pessimistic_write' },
      });
      if (!user)
        throw new NotFoundException({
          code: 'ACCOUNT_NOT_FOUND',
          message: 'Account not found',
        });
      if (dto.displayName !== undefined) user.displayName = dto.displayName;
      if (dto.avatarUrl !== undefined) {
        if (user.avatarUrl)
          await this.fileStorage.delete(user.avatarUrl, { allVersions: true });
        user.avatarUrl = dto.avatarUrl;
      }
      await manager.save(UserEntity, user);
    });
    return this.getProfile(userId);
  }

  async updateAvatar(
    userId: string,
    buffer: Buffer,
    contentType: string,
  ): Promise<AccountProfile> {
    // A stable key also handles changes between JPEG, PNG, GIF and WebP.
    const defaultKey = `avatars/${userId}/photo`;
    await this.userRepo.manager.transaction(async (manager) => {
      const user = await manager.findOne(UserEntity, {
        where: { id: userId },
        lock: { mode: 'pessimistic_write' },
      });
      if (!user)
        throw new NotFoundException({
          code: 'ACCOUNT_NOT_FOUND',
          message: 'Account not found',
        });
      // Keep existing avatar keys stable too; the content type comes from
      // image bytes, not the old filename extension. No delete-after-write.
      const legacyKeys = ['.jpg', '.jpeg', '.png', '.gif', '.webp'].map(
        (ext) => `avatars/${userId}${ext}`,
      );
      const key =
        user.avatarUrl && legacyKeys.includes(user.avatarUrl)
          ? user.avatarUrl
          : defaultKey;
      await this.fileStorage.upload(key, buffer, contentType, {
        singleVersion: true,
      });
      user.avatarUrl = key;
      await manager.save(UserEntity, user);
    });
    // Do not delete the stable key on a DB/response failure: it may already
    // be the account's current photo. A retry safely replaces the same key.
    return this.getProfile(userId);
  }

  async createDataExportRequest(
    userId: string,
    correlationId: string,
  ): Promise<DataExportRequest> {
    const entity = this.exportRepo.create({
      userId,
      status: 'pending',
      completedAt: null,
      downloadUrl: null,
      failureReason: null,
    });
    const saved = await this.exportRepo.save(entity);

    this.logger.log(
      JSON.stringify({
        action: 'DATA_EXPORT_REQUESTED',
        requestId: saved.id,
        correlationId,
      }),
    );
    return this.toExportDto(saved);
  }

  async getDataExportRequest(
    userId: string,
    requestId: string,
  ): Promise<DataExportRequest | null> {
    if (!isUUID(requestId)) return null;
    const entity = await this.exportRepo.findOne({
      where: { id: requestId, userId },
    });
    if (!entity) return null;

    if (entity.status === 'pending') {
      const user = await this.userRepo.findOne({ where: { id: userId } });
      const profiles = await this.profileRepo.find({
        where: { userId },
        order: { createdAt: 'ASC' },
      });
      const consentRecords = await this.consentRepo.find({
        where: { userId },
        order: { acceptedAt: 'ASC' },
      });
      const exportPayload = user
        ? {
            profile: {
              id: user.id,
              email: user.email,
              displayName: user.displayName,
              createdAt: user.createdAt,
            },
            profiles: profiles.map((profile) => ({
              id: profile.id,
              name: profile.name,
              dateOfBirth: profile.dateOfBirth,
              relation: profile.relation,
              isActive: profile.isActive,
              createdAt: profile.createdAt,
            })),
            consentRecords: consentRecords.map((record) => ({
              id: record.id,
              policyType: record.policyType,
              policyVersion: record.policyVersion,
              acceptedAt: record.acceptedAt,
            })),
          }
        : null;

      entity.status = exportPayload ? 'completed' : 'failed';
      entity.completedAt = exportPayload ? new Date() : null;
      entity.downloadUrl = exportPayload
        ? `data:application/json;base64,${Buffer.from(JSON.stringify(exportPayload)).toString('base64')}`
        : null;
      entity.failureReason = exportPayload ? null : 'USER_NOT_FOUND';
      await this.exportRepo.save(entity);
    }
    return this.toExportDto(entity);
  }

  async createClosureRequest(
    userId: string,
    dto: CreateClosureRequestDto,
    correlationId: string,
  ): Promise<ClosureRequest> {
    if (!dto.confirmClosure) throw new ClosureConfirmationRequiredException();
    await this.authService.verifyPasswordForUser(userId, dto.password);

    const saved = await this.userRepo.manager.transaction(async (manager) => {
      const user = await manager.findOne(UserEntity, {
        where: { id: userId },
        lock: { mode: 'pessimistic_write' },
      });
      if (!user) throw new NotFoundException('Account not found');
      if (user.role === 'superadmin') {
        throw new ConflictException(
          'Superadmin accounts cannot be deleted here',
        );
      }
      const existing = await manager.findOne(ClosureRequestEntity, {
        where: { userId, status: 'pending' },
        order: { createdAt: 'DESC' },
      });
      if (existing) return existing;
      const now = new Date();
      user.deletionRequestedAt = now;
      await manager.save(UserEntity, user);
      // A closed account's existing share links must stop working immediately.
      await manager.query(
        'UPDATE share_links SET is_active = false, expires_at = $1 WHERE user_id = $2 AND is_active = true',
        [now, userId],
      );
      return manager.save(
        ClosureRequestEntity,
        manager.create(ClosureRequestEntity, {
          userId,
          status: 'pending',
          purgeAfterAt: new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000),
          message:
            'Account access is disabled. Sign in to restore within 30 days.',
        }),
      );
    });
    await this.authService.revokeAllSessionsForUser(userId);

    this.logger.log(
      JSON.stringify({
        action: 'CLOSURE_REQUESTED',
        requestId: saved.id,
        correlationId,
      }),
    );

    void this.notificationPipeline
      .dispatch({
        eventType: NotifiableEventType.ACCOUNT_CLOSURE_CONFIRMED,
        userId,
        correlationId,
      })
      .catch((err) => {
        this.logger.warn(
          JSON.stringify({
            action: 'NOTIFICATION_DISPATCH_FAILED',
            eventType: NotifiableEventType.ACCOUNT_CLOSURE_CONFIRMED,
            correlationId,
            error: err instanceof Error ? err.message : String(err),
          }),
        );
      });
    return this.toClosureDto(saved);
  }

  async getClosureRequest(userId: string): Promise<ClosureRequest | null> {
    const entity = await this.closureRepo.findOne({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
    if (!entity) return null;
    return this.toClosureDto(entity);
  }

  async restoreClosure(userId: string): Promise<ClosureRequest> {
    const restored = await this.userRepo.manager.transaction(
      async (manager) => {
        const user = await manager.findOne(UserEntity, {
          where: { id: userId },
          lock: { mode: 'pessimistic_write' },
        });
        if (!user) throw new NotFoundException('Account not found');
        const request = await manager.findOne(ClosureRequestEntity, {
          where: { userId, status: 'pending' },
          order: { createdAt: 'DESC' },
        });
        if (
          !request ||
          !request.purgeAfterAt ||
          request.purgeAfterAt <= new Date()
        ) {
          throw new ConflictException('The restoration period has ended');
        }
        user.deletionRequestedAt = null;
        request.status = 'restored';
        request.message = 'Your account has been restored.';
        await manager.save(UserEntity, user);
        return manager.save(ClosureRequestEntity, request);
      },
    );
    return this.toClosureDto(restored);
  }

  async purgeExpiredClosures(): Promise<number> {
    const due = await this.closureRepo
      .createQueryBuilder('c')
      .select(['c.id', 'c.userId'])
      .where('c.status = :status AND c.purgeAfterAt <= :now', {
        status: 'pending',
        now: new Date(),
      })
      .orderBy('c.purgeAfterAt', 'ASC')
      .take(20)
      .getMany();
    let purged = 0;
    for (const candidate of due) {
      try {
        await this.userRepo.manager.transaction(async (manager) => {
          const user = await manager.findOne(UserEntity, {
            where: { id: candidate.userId },
            lock: { mode: 'pessimistic_write' },
          });
          if (!user?.deletionRequestedAt) return;
          const closure = await manager.findOne(ClosureRequestEntity, {
            where: { userId: user.id, status: 'pending' },
            order: { createdAt: 'DESC' },
          });
          if (!closure?.purgeAfterAt || closure.purgeAfterAt > new Date())
            return;
          // B2 versions and delete markers are removed before the database owner.
          // A failure rolls back the transaction, so the next sweep can retry.
          await this.fileStorage.deletePrefix(`reports/${user.id}/`);
          await this.fileStorage.deletePrefix(`avatars/${user.id}/`);
          for (const extension of ['.jpg', '.jpeg', '.png', '.gif', '.webp']) {
            await this.fileStorage.delete(`avatars/${user.id}${extension}`, {
              allVersions: true,
            });
          }
          if (
            user.avatarUrl &&
            !user.avatarUrl.startsWith(`avatars/${user.id}/`)
          ) {
            await this.fileStorage.delete(user.avatarUrl, {
              allVersions: true,
            });
          }
          // Older async report sources used report-sources/v1/<intent> outside
          // the account prefix; keep explicit cleanup for those legacy keys.
          const reports = await manager.find(ReportEntity, {
            where: { userId: user.id },
            select: ['id', 'originalFileStorageKey'],
          });
          for (const report of reports) {
            if (
              !report.originalFileStorageKey.startsWith(`reports/${user.id}/`)
            ) {
              await this.fileStorage.delete(report.originalFileStorageKey, {
                allVersions: true,
              });
            }
          }
          const intents: Array<{ storage_key: string }> = await manager.query(
            'SELECT storage_key FROM report_upload_intents WHERE user_id = $1',
            [user.id],
          );
          for (const intent of intents) {
            await this.fileStorage.delete(intent.storage_key, {
              allVersions: true,
            });
          }
          await manager.query(
            'DELETE FROM report_upload_intents WHERE user_id = $1',
            [user.id],
          );
          // These operational rows use SET NULL rather than CASCADE, or carry
          // the account ID in metadata. Remove account-specific records first.
          await manager.query(
            'DELETE FROM billing_provider_events WHERE order_id IN (SELECT id FROM orders WHERE user_id = $1)',
            [user.id],
          );
          await manager.query(
            'DELETE FROM promo_lifecycle_events WHERE user_id = $1 OR order_id IN (SELECT id FROM orders WHERE user_id = $1)',
            [user.id],
          );
          await manager.query(
            'DELETE FROM push_delivery_events WHERE user_id = $1',
            [user.id],
          );
          await manager.query(
            'DELETE FROM referral_audit_events WHERE actor_user_id = $1 OR referral_log_id IN (SELECT id FROM referral_logs WHERE referrer_user_id = $1 OR invitee_user_id = $1) OR reward_event_id IN (SELECT id FROM referral_reward_events WHERE beneficiary_user_id = $1)',
            [user.id],
          );
          await manager.query(
            'DELETE FROM gift_voucher_events WHERE actor_user_id = $1',
            [user.id],
          );
          await manager.query(
            'DELETE FROM report_operator_actions WHERE report_id IN (SELECT id FROM reports WHERE user_id = $1)',
            [user.id],
          );
          await manager.query(
            "DELETE FROM suspicious_activity_queue_items WHERE target_id = $1 AND target_type = 'user'",
            [user.id],
          );
          await manager.query(
            "DELETE FROM email_delivery_events WHERE metadata->>'userId' = $1 OR metadata->>'recipientUserId' = $1 OR metadata->>'queueItemId' IN (SELECT id::text FROM email_queue_items WHERE metadata->>'userId' = $1 OR metadata->>'recipientUserId' = $1)",
            [user.id],
          );
          await manager.query(
            "DELETE FROM email_queue_items WHERE metadata->>'userId' = $1 OR metadata->>'recipientUserId' = $1",
            [user.id],
          );
          await manager.query(
            'INSERT INTO account_deletion_records(user_id,email,requested_at) VALUES ($1,$2,$3) ON CONFLICT (user_id) DO NOTHING',
            [user.id, user.email, user.deletionRequestedAt],
          );
          await manager.delete(UserEntity, user.id);
          purged++;
        });
      } catch (error) {
        this.logger.warn(
          `Account purge failed for userId=${candidate.userId}: ${error instanceof Error ? error.message : String(error)}`,
        );
      }
    }
    return purged;
  }

  async listDeletionRecords(): Promise<
    Array<{
      userId: string;
      email: string;
      requestedAt: string;
      purgedAt: string;
    }>
  > {
    const rows: Array<{
      user_id: string;
      email: string;
      requested_at: Date;
      purged_at: Date;
    }> = await this.userRepo.query(
      'SELECT user_id, email, requested_at, purged_at FROM account_deletion_records ORDER BY purged_at DESC',
    );
    return rows.map((row) => ({
      userId: row.user_id,
      email: row.email,
      requestedAt: row.requested_at.toISOString(),
      purgedAt: row.purged_at.toISOString(),
    }));
  }

  private toExportDto(e: DataExportRequestEntity): DataExportRequest {
    return {
      requestId: e.id,
      userId: e.userId,
      status: e.status,
      createdAt: e.createdAt.toISOString(),
      completedAt: e.completedAt?.toISOString(),
      downloadUrl: e.downloadUrl ?? undefined,
      failureReason: e.failureReason ?? undefined,
    };
  }

  private toClosureDto(e: ClosureRequestEntity): ClosureRequest {
    return {
      requestId: e.id,
      userId: e.userId,
      status: e.status as 'pending' | 'restored' | 'completed',
      createdAt: e.createdAt.toISOString(),
      purgeAfterAt: e.purgeAfterAt?.toISOString(),
      message: e.message ?? '',
    };
  }

  private isRestrictionExpired(entry: RestrictionEntity): boolean {
    if (!entry.restrictedUntil) return false;
    return entry.restrictedUntil.getTime() <= Date.now();
  }

  private async clearExpiredRestriction(
    entry: RestrictionEntity,
  ): Promise<void> {
    if (!entry.isRestricted && !entry.restrictedReviewMode) return;
    entry.isRestricted = false;
    entry.restrictedReviewMode = false;
    entry.restrictedUntil = null;
    entry.rationale = null;
    entry.nextSteps = null;
    await this.restrictionRepo.save(entry);
  }
}
