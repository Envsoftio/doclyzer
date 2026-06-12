import { randomBytes } from 'node:crypto';
import {
  BadRequestException,
  ConflictException,
  Injectable,
  InternalServerErrorException,
  Logger,
  OnModuleInit,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, QueryFailedError, Repository } from 'typeorm';
import { NotificationPipelineService } from '../../common/notification-pipeline/notification-pipeline.service';
import { NotifiableEventType } from '../../common/notification-pipeline/notification-event.types';
import { ReferralAuditEventEntity } from '../../database/entities/referral-audit-event.entity';
import { ReferralLogEntity } from '../../database/entities/referral-log.entity';
import { ReferralPolicyConfigEntity } from '../../database/entities/referral-policy-config.entity';
import { ReferralRewardEventEntity } from '../../database/entities/referral-reward-event.entity';
import { UserReferralProfileEntity } from '../../database/entities/user-referral-profile.entity';
import { UserEntity } from '../../database/entities/user.entity';
import { EntitlementsService } from '../entitlements/entitlements.service';
import {
  DEFAULT_REFERRAL_POLICY,
  type ReferralPolicySnapshot,
} from './referrals.types';

interface PostgresDriverError {
  code?: string;
  constraint?: string;
  detail?: string;
}

const REFERRAL_CODE_ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const REFERRAL_CODE_PREFIX = 'DOC';
const REFERRAL_CODE_RANDOM_LENGTH = 8;
const REFERRAL_CODE_MAX_RETRIES = 10;
const BACKFILL_BATCH_SIZE = 100;
const INVITEE_BONUS_RELEASE_REASON = 'EMAIL_VERIFIED';

interface ApplyReferralCodeResult {
  referralLogId: string;
  referrerUserId: string;
  appliedReferralCode: string;
  inviteeBonusStatus: ReferralLogEntity['inviteeBonusStatus'];
  inviteeBonusCredits: number;
  emailVerificationRequired: boolean;
}

interface ReleaseInviteeBonusResult {
  released: boolean;
  referralLogId: string | null;
  rewardEventId: string | null;
  status: 'not_found' | 'not_verified' | 'already_released' | 'released';
  creditsGranted: number;
}

@Injectable()
export class ReferralsService implements OnModuleInit {
  private readonly logger = new Logger(ReferralsService.name);

  constructor(
    private readonly dataSource: DataSource,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(UserReferralProfileEntity)
    private readonly referralProfileRepo: Repository<UserReferralProfileEntity>,
    @InjectRepository(ReferralLogEntity)
    private readonly referralLogRepo: Repository<ReferralLogEntity>,
    @InjectRepository(ReferralRewardEventEntity)
    private readonly referralRewardEventRepo: Repository<ReferralRewardEventEntity>,
    @InjectRepository(ReferralAuditEventEntity)
    private readonly referralAuditEventRepo: Repository<ReferralAuditEventEntity>,
    @InjectRepository(ReferralPolicyConfigEntity)
    private readonly referralPolicyConfigRepo: Repository<ReferralPolicyConfigEntity>,
    private readonly entitlementsService: EntitlementsService,
    private readonly notificationPipeline: NotificationPipelineService,
  ) {}

  onModuleInit(): void {
    void this.backfillMissingReferralProfiles();
  }

  generateReferralCode(): string {
    const bytes = randomBytes(REFERRAL_CODE_RANDOM_LENGTH);
    let suffix = '';

    for (let index = 0; index < REFERRAL_CODE_RANDOM_LENGTH; index += 1) {
      suffix +=
        REFERRAL_CODE_ALPHABET[bytes[index] % REFERRAL_CODE_ALPHABET.length];
    }

    return `${REFERRAL_CODE_PREFIX}${suffix}`;
  }

  async ensureReferralProfileForUser(
    userId: string,
  ): Promise<UserReferralProfileEntity> {
    const existing = await this.referralProfileRepo.findOne({
      where: { userId },
    });
    if (existing) {
      return existing;
    }

    for (let attempt = 1; attempt <= REFERRAL_CODE_MAX_RETRIES; attempt += 1) {
      try {
        const created = this.referralProfileRepo.create({
          userId,
          referralCode: this.generateReferralCode(),
        });
        return await this.referralProfileRepo.save(created);
      } catch (error: unknown) {
        if (this.isRetryableReferralCodeConflict(error)) {
          continue;
        }

        if (this.isExistingUserProfileConflict(error)) {
          const concurrent = await this.referralProfileRepo.findOne({
            where: { userId },
          });
          if (concurrent) {
            return concurrent;
          }
        }

        throw error;
      }
    }

    throw new InternalServerErrorException({
      code: 'REFERRAL_CODE_GENERATION_FAILED',
      message: 'Unable to generate a unique referral code at this time.',
    });
  }

  async getReferralPolicy(): Promise<ReferralPolicySnapshot> {
    const config = await this.referralPolicyConfigRepo.findOne({
      where: { configKey: 'default' },
    });

    if (!config) {
      return DEFAULT_REFERRAL_POLICY;
    }

    return {
      inviteeBonusCredits: parseFloat(config.inviteeBonusCredits),
      milestoneACredits: parseFloat(config.milestoneACredits),
      milestoneBTiers: config.milestoneBTiers,
      monthlyRewardCap: parseFloat(config.monthlyRewardCap),
      zeroAmountOrderEligible: config.zeroAmountOrderEligible,
    };
  }

  async prevalidateReferralCode(referralCode: string): Promise<void> {
    await this.lookupReferrerProfile(this.normalizeReferralCode(referralCode));
  }

  async applyReferralCode(input: {
    inviteeUserId: string;
    referralCode: string;
    correlationId: string;
  }): Promise<ApplyReferralCodeResult> {
    const normalizedCode = this.normalizeReferralCode(input.referralCode);
    const inviteeProfile = await this.ensureReferralProfileForUser(
      input.inviteeUserId,
    );
    const invitee = await this.userRepo.findOne({
      where: { id: input.inviteeUserId },
    });
    if (!invitee) {
      throw new BadRequestException({
        code: 'REFERRAL_INVITEE_NOT_FOUND',
        message: 'Invitee account was not found.',
      });
    }

    const existingLog = await this.referralLogRepo.findOne({
      where: { inviteeUserId: input.inviteeUserId },
    });
    if (existingLog) {
      await this.recordAuditEvent({
        actorUserId: input.inviteeUserId,
        eventType: 'REFERRAL_APPLY',
        outcome: 'blocked',
        reasonCode: 'REFERRAL_ALREADY_APPLIED',
        metadata: {
          appliedReferralCode: normalizedCode,
          correlationId: input.correlationId,
        },
      });
      throw new ConflictException({
        code: 'REFERRAL_ALREADY_APPLIED',
        message: 'A referral code has already been applied to this account.',
      });
    }

    if (inviteeProfile.referralCode.toUpperCase() === normalizedCode) {
      await this.recordAuditEvent({
        actorUserId: input.inviteeUserId,
        eventType: 'REFERRAL_APPLY',
        outcome: 'blocked',
        reasonCode: 'REFERRAL_SELF_REFERRAL',
        metadata: {
          appliedReferralCode: normalizedCode,
          correlationId: input.correlationId,
        },
      });
      throw new BadRequestException({
        code: 'REFERRAL_SELF_REFERRAL',
        message: 'You cannot apply your own referral code.',
      });
    }

    const referrerProfile = await this.lookupReferrerProfile(normalizedCode).catch(
      async (error: unknown) => {
        await this.recordAuditEvent({
          actorUserId: input.inviteeUserId,
          eventType: 'REFERRAL_APPLY',
          outcome: 'blocked',
          reasonCode: 'REFERRAL_CODE_INVALID',
          metadata: {
            appliedReferralCode: normalizedCode,
            correlationId: input.correlationId,
          },
        });
        throw error;
      },
    );

    if (referrerProfile.userId === input.inviteeUserId) {
      await this.recordAuditEvent({
        actorUserId: input.inviteeUserId,
        eventType: 'REFERRAL_APPLY',
        outcome: 'blocked',
        reasonCode: 'REFERRAL_SELF_REFERRAL',
        metadata: {
          appliedReferralCode: normalizedCode,
          correlationId: input.correlationId,
        },
      });
      throw new BadRequestException({
        code: 'REFERRAL_SELF_REFERRAL',
        message: 'You cannot apply your own referral code.',
      });
    }

    const policy = await this.getReferralPolicy();
    const result = await this.dataSource.transaction<
      ApplyReferralCodeResult
    >(async (manager) => {
      const lockedExisting = await manager
        .getRepository(ReferralLogEntity)
        .createQueryBuilder('referral_log')
        .setLock('pessimistic_write')
        .where('referral_log.invitee_user_id = :inviteeUserId', {
          inviteeUserId: input.inviteeUserId,
        })
        .getOne();

      if (lockedExisting) {
        throw new ConflictException({
          code: 'REFERRAL_ALREADY_APPLIED',
          message: 'A referral code has already been applied to this account.',
        });
      }

      const referralLog = await manager.getRepository(ReferralLogEntity).save(
        manager.getRepository(ReferralLogEntity).create({
          referrerUserId: referrerProfile.userId,
          inviteeUserId: input.inviteeUserId,
          referrerProfileId: referrerProfile.id,
          appliedReferralCode: normalizedCode,
          reviewStatus: 'pending',
          inviteeBonusStatus: 'pending',
          milestoneAStatus: 'pending',
          milestoneBStatus: 'pending',
          metadata: {
            appliedAt: new Date().toISOString(),
            correlationId: input.correlationId,
          },
        }),
      );

      await manager.getRepository(ReferralRewardEventEntity).save(
        manager.getRepository(ReferralRewardEventEntity).create({
          referralLogId: referralLog.id,
          beneficiaryUserId: input.inviteeUserId,
          rewardType: 'invitee_bonus',
          status: 'pending',
          creditAmount: policy.inviteeBonusCredits.toFixed(2),
          idempotencyKey: this.buildInviteeBonusIdempotencyKey(referralLog.id),
          reasonCode: null,
          metadata: {
            appliedReferralCode: normalizedCode,
            correlationId: input.correlationId,
          },
          resolvedAt: null,
        }),
      );

      await manager.getRepository(ReferralAuditEventEntity).save(
        manager.getRepository(ReferralAuditEventEntity).create({
          referralLogId: referralLog.id,
          rewardEventId: null,
          actorUserId: input.inviteeUserId,
          eventType: 'REFERRAL_APPLY',
          outcome: 'success',
          reasonCode: null,
          metadata: {
            appliedReferralCode: normalizedCode,
            correlationId: input.correlationId,
            inviteeBonusStatus: 'pending',
          },
        }),
      );

      return {
        referralLogId: referralLog.id,
        referrerUserId: referrerProfile.userId,
        appliedReferralCode: normalizedCode,
        inviteeBonusStatus: referralLog.inviteeBonusStatus,
        inviteeBonusCredits: policy.inviteeBonusCredits,
        emailVerificationRequired: !invitee.emailVerified,
      };
    });

    if (invitee.emailVerified) {
      const release = await this.releasePendingInviteeBonusForUser({
        userId: input.inviteeUserId,
        correlationId: input.correlationId,
        trigger: 'referral_apply',
      });
      if (release.released) {
        result.inviteeBonusStatus = 'released';
        result.emailVerificationRequired = false;
      }
    }

    return result;
  }

  async releasePendingInviteeBonusForUser(input: {
    userId: string;
    correlationId: string;
    trigger: 'login' | 'refresh' | 'account_profile' | 'referral_apply';
  }): Promise<ReleaseInviteeBonusResult> {
    const user = await this.userRepo.findOne({ where: { id: input.userId } });
    if (!user) {
      return {
        released: false,
        referralLogId: null,
        rewardEventId: null,
        status: 'not_found',
        creditsGranted: 0,
      };
    }

    if (!user.emailVerified) {
      return {
        released: false,
        referralLogId: null,
        rewardEventId: null,
        status: 'not_verified',
        creditsGranted: 0,
      };
    }

    const release = await this.dataSource.transaction<
      ReleaseInviteeBonusResult
    >(async (manager) => {
      const referralLog = await manager
        .getRepository(ReferralLogEntity)
        .createQueryBuilder('referral_log')
        .setLock('pessimistic_write')
        .where('referral_log.invitee_user_id = :userId', { userId: input.userId })
        .getOne();

      if (!referralLog) {
        return {
          released: false,
          referralLogId: null,
          rewardEventId: null,
          status: 'not_found',
          creditsGranted: 0,
        };
      }

      const rewardEvent = await manager
        .getRepository(ReferralRewardEventEntity)
        .createQueryBuilder('reward_event')
        .setLock('pessimistic_write')
        .where('reward_event.referral_log_id = :referralLogId', {
          referralLogId: referralLog.id,
        })
        .andWhere('reward_event.reward_type = :rewardType', {
          rewardType: 'invitee_bonus',
        })
        .getOne();

      if (!rewardEvent) {
        return {
          released: false,
          referralLogId: referralLog.id,
          rewardEventId: null,
          status: 'not_found',
          creditsGranted: 0,
        };
      }

      if (
        rewardEvent.status === 'released' ||
        referralLog.inviteeBonusStatus === 'released'
      ) {
        if (rewardEvent.status !== 'released') {
          rewardEvent.status = 'released';
          rewardEvent.reasonCode = INVITEE_BONUS_RELEASE_REASON;
          rewardEvent.resolvedAt = rewardEvent.resolvedAt ?? new Date();
          rewardEvent.metadata = {
            ...(rewardEvent.metadata ?? {}),
            releasedByTrigger: input.trigger,
          };
          await manager.getRepository(ReferralRewardEventEntity).save(rewardEvent);
        }

        if (referralLog.inviteeBonusStatus !== 'released') {
          referralLog.inviteeBonusStatus = 'released';
          referralLog.inviteeBonusReleasedAt =
            referralLog.inviteeBonusReleasedAt ?? rewardEvent.resolvedAt;
          await manager.getRepository(ReferralLogEntity).save(referralLog);
        }

        return {
          released: false,
          referralLogId: referralLog.id,
          rewardEventId: rewardEvent.id,
          status: 'already_released',
          creditsGranted: 0,
        };
      }

      const creditAmount = parseFloat(rewardEvent.creditAmount);
      await this.entitlementsService.addCreditsInTransaction(
        manager,
        input.userId,
        creditAmount,
        'referral_invitee_bonus',
      );

      const now = new Date();
      rewardEvent.status = 'released';
      rewardEvent.reasonCode = INVITEE_BONUS_RELEASE_REASON;
      rewardEvent.resolvedAt = now;
      rewardEvent.metadata = {
        ...(rewardEvent.metadata ?? {}),
        correlationId: input.correlationId,
        releasedByTrigger: input.trigger,
      };
      referralLog.inviteeBonusStatus = 'released';
      referralLog.inviteeBonusReleasedAt = now;

      await manager.getRepository(ReferralRewardEventEntity).save(rewardEvent);
      await manager.getRepository(ReferralLogEntity).save(referralLog);
      await manager.getRepository(ReferralAuditEventEntity).save(
        manager.getRepository(ReferralAuditEventEntity).create({
          referralLogId: referralLog.id,
          rewardEventId: rewardEvent.id,
          actorUserId: input.userId,
          eventType: 'REFERRAL_INVITEE_BONUS_RELEASE',
          outcome: 'success',
          reasonCode: INVITEE_BONUS_RELEASE_REASON,
          metadata: {
            correlationId: input.correlationId,
            releasedByTrigger: input.trigger,
            creditAmount,
          },
        }),
      );

      return {
        released: true,
        referralLogId: referralLog.id,
        rewardEventId: rewardEvent.id,
        status: 'released',
        creditsGranted: creditAmount,
      };
    });

    if (release.released && release.referralLogId && release.rewardEventId) {
      await this.notificationPipeline.dispatch({
        eventType: NotifiableEventType.REFERRAL_INVITEE_BONUS_RELEASED,
        userId: input.userId,
        correlationId: input.correlationId,
        idempotencyKey: `referral-invitee-bonus-email:${release.rewardEventId}`,
        metadata: {
          referralLogId: release.referralLogId,
          rewardEventId: release.rewardEventId,
          creditsGranted: release.creditsGranted,
        },
      });
    }

    return release;
  }

  async backfillMissingReferralProfiles(): Promise<number> {
    let createdCount = 0;

    try {
      while (true) {
        const missingUsers = await this.userRepo
          .createQueryBuilder('user')
          .leftJoin(
            UserReferralProfileEntity,
            'referral_profile',
            'referral_profile.user_id = user.id',
          )
          .select('user.id', 'id')
          .where('referral_profile.id IS NULL')
          .orderBy('user.created_at', 'ASC')
          .limit(BACKFILL_BATCH_SIZE)
          .getRawMany<{ id: string }>();

        if (missingUsers.length === 0) {
          break;
        }

        for (const user of missingUsers) {
          await this.ensureReferralProfileForUser(user.id);
          createdCount += 1;
        }

        if (missingUsers.length < BACKFILL_BATCH_SIZE) {
          break;
        }
      }

      if (createdCount > 0) {
        this.logger.log(
          `Referral profile backfill created ${createdCount} profile(s).`,
        );
      }
    } catch (error: unknown) {
      this.logger.warn(
        `Referral profile backfill failed: ${error instanceof Error ? error.message : String(error)}`,
      );
    }

    return createdCount;
  }

  private isRetryableReferralCodeConflict(error: unknown): boolean {
    if (!(error instanceof QueryFailedError)) {
      return false;
    }

    const driverError = error.driverError as PostgresDriverError | undefined;
    return (
      driverError?.code === '23505' &&
      driverError.constraint === 'UQ_user_referral_profiles_referral_code_upper'
    );
  }

  private isExistingUserProfileConflict(error: unknown): boolean {
    if (!(error instanceof QueryFailedError)) {
      return false;
    }

    const driverError = error.driverError as PostgresDriverError | undefined;
    return (
      driverError?.code === '23505' &&
      driverError.constraint === 'UQ_user_referral_profiles_user_id'
    );
  }

  private normalizeReferralCode(referralCode: string): string {
    if (typeof referralCode !== 'string' || referralCode.trim().length === 0) {
      throw new BadRequestException({
        code: 'REFERRAL_CODE_INVALID',
        message: 'Referral code is invalid.',
      });
    }

    return referralCode.trim().toUpperCase();
  }

  private async lookupReferrerProfile(
    normalizedCode: string,
  ): Promise<UserReferralProfileEntity> {
    const referrerProfile = await this.referralProfileRepo
      .createQueryBuilder('referral_profile')
      .where('UPPER(referral_profile.referral_code) = :referralCode', {
        referralCode: normalizedCode,
      })
      .getOne();

    if (!referrerProfile) {
      throw new BadRequestException({
        code: 'REFERRAL_CODE_INVALID',
        message: 'Referral code is invalid.',
      });
    }

    return referrerProfile;
  }

  private buildInviteeBonusIdempotencyKey(referralLogId: string): string {
    return `referral:invitee_bonus:${referralLogId}`;
  }

  private async recordAuditEvent(input: {
    referralLogId?: string | null;
    rewardEventId?: string | null;
    actorUserId?: string | null;
    eventType: string;
    outcome: ReferralAuditEventEntity['outcome'];
    reasonCode?: string | null;
    metadata?: Record<string, unknown> | null;
  }): Promise<void> {
    await this.referralAuditEventRepo.save(
      this.referralAuditEventRepo.create({
        referralLogId: input.referralLogId ?? null,
        rewardEventId: input.rewardEventId ?? null,
        actorUserId: input.actorUserId ?? null,
        eventType: input.eventType,
        outcome: input.outcome,
        reasonCode: input.reasonCode ?? null,
        metadata: input.metadata ?? null,
      }),
    );
  }
}
