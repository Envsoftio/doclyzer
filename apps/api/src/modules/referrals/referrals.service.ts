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
import {
  DataSource,
  EntityManager,
  In,
  QueryFailedError,
  Repository,
} from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { NotificationPipelineService } from '../../common/notification-pipeline/notification-pipeline.service';
import { NotifiableEventType } from '../../common/notification-pipeline/notification-event.types';
import { OrderEntity } from '../../database/entities/order.entity';
import { ReferralAuditEventEntity } from '../../database/entities/referral-audit-event.entity';
import { ReferralLogEntity } from '../../database/entities/referral-log.entity';
import { ReferralPolicyConfigEntity } from '../../database/entities/referral-policy-config.entity';
import { ReferralRewardEventEntity } from '../../database/entities/referral-reward-event.entity';
import { ReportEntity } from '../../database/entities/report.entity';
import { UserReferralProfileEntity } from '../../database/entities/user-referral-profile.entity';
import { UserEntity } from '../../database/entities/user.entity';
import { EntitlementsService } from '../entitlements/entitlements.service';
import {
  DEFAULT_REFERRAL_POLICY,
  type ReferralDashboardDto,
  type ReferralFriendProgressDto,
  type ReferralPolicySnapshot,
  type ReferralProgressTimelineItemDto,
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
const MILESTONE_A_RELEASE_REASON = 'FIRST_SUCCESSFUL_ANALYSIS';
const MILESTONE_B_RELEASE_REASON = 'FIRST_PAID_ORDER_RECONCILED';

type ReferralMilestoneType = 'milestone_a' | 'milestone_b';

type ReferralRewardResolutionStatus =
  | 'released'
  | 'blocked'
  | 'capped'
  | 'already_resolved'
  | 'not_found';

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

interface TriggerReferralMilestoneResult {
  released: boolean;
  referralLogId: string | null;
  rewardEventId: string | null;
  status:
    | 'not_found'
    | 'not_eligible'
    | 'already_resolved'
    | 'blocked'
    | 'capped'
    | 'released';
  creditsGranted: number;
  referrerUserId: string | null;
}

interface ResolveReferralMilestoneInput {
  milestone: ReferralMilestoneType;
  inviteeUserId: string;
  creditAmount: number;
  releaseReasonCode: string;
  correlationId: string;
  eligibilityMetadata: Record<string, unknown>;
}

@Injectable()
export class ReferralsService implements OnModuleInit {
  private readonly logger = new Logger(ReferralsService.name);

  constructor(
    private readonly dataSource: DataSource,
    private readonly configService: ConfigService,
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
    @InjectRepository(ReportEntity)
    private readonly reportRepo: Repository<ReportEntity>,
    @InjectRepository(OrderEntity)
    private readonly orderRepo: Repository<OrderEntity>,
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

  async getReferralDashboard(userId: string): Promise<ReferralDashboardDto> {
    const [profile, policy, logs, rewardEvents] = await Promise.all([
      this.ensureReferralProfileForUser(userId),
      this.getReferralPolicy(),
      this.referralLogRepo.find({
        where: { referrerUserId: userId },
        order: { createdAt: 'DESC' },
      }),
      this.referralRewardEventRepo.find({
        where: { beneficiaryUserId: userId },
      }),
    ]);

    const inviteeIds = logs.map((log) => log.inviteeUserId);
    const invitees = inviteeIds.length
      ? await this.userRepo.find({ where: { id: In(inviteeIds) } })
      : [];
    const inviteeById = new Map(
      invitees.map((invitee) => [invitee.id, invitee]),
    );

    const logIds = logs.map((log) => log.id);
    const allLogRewardEvents = logIds.length
      ? await this.referralRewardEventRepo.find({
          where: { referralLogId: In(logIds) },
          order: { createdAt: 'ASC' },
        })
      : [];
    const rewardsByLogId = new Map<string, ReferralRewardEventEntity[]>();
    for (const rewardEvent of allLogRewardEvents) {
      const current = rewardsByLogId.get(rewardEvent.referralLogId) ?? [];
      current.push(rewardEvent);
      rewardsByLogId.set(rewardEvent.referralLogId, current);
    }

    const milestoneRewardEvents = rewardEvents.filter((rewardEvent) =>
      ['milestone_a', 'milestone_b'].includes(rewardEvent.rewardType),
    );
    const creditsEarned = milestoneRewardEvents
      .filter((rewardEvent) => rewardEvent.status === 'released')
      .reduce(
        (sum, rewardEvent) => sum + parseFloat(rewardEvent.creditAmount),
        0,
      );
    const pendingRewards = milestoneRewardEvents.filter(
      (rewardEvent) => rewardEvent.status === 'pending',
    ).length;
    const blockedRewards = milestoneRewardEvents.filter((rewardEvent) =>
      ['blocked', 'capped', 'under_review'].includes(rewardEvent.status),
    ).length;

    return {
      referralCode: profile.referralCode,
      referralLink: this.buildReferralLink(profile.referralCode),
      totalReferredCount: logs.length,
      creditsEarned,
      pendingRewards,
      blockedRewards,
      policySummary: {
        inviteeBonusCredits: policy.inviteeBonusCredits,
        milestoneACredits: policy.milestoneACredits,
        milestoneBTiers: policy.milestoneBTiers,
        monthlyRewardCap: policy.monthlyRewardCap,
        zeroAmountOrderEligible: policy.zeroAmountOrderEligible,
      },
      referredFriends: logs.map((log) =>
        this.toReferralFriendProgressDto(
          log,
          inviteeById.get(log.inviteeUserId) ?? null,
          rewardsByLogId.get(log.id) ?? [],
        ),
      ),
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

    const referrerProfile = await this.lookupReferrerProfile(
      normalizedCode,
    ).catch(async (error: unknown) => {
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
    });

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
    const result = await this.dataSource.transaction<ApplyReferralCodeResult>(
      async (manager) => {
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
            message:
              'A referral code has already been applied to this account.',
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
            idempotencyKey: this.buildInviteeBonusIdempotencyKey(
              referralLog.id,
            ),
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
      },
    );

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

    const release =
      await this.dataSource.transaction<ReleaseInviteeBonusResult>(
        async (manager) => {
          const referralLog = await manager
            .getRepository(ReferralLogEntity)
            .createQueryBuilder('referral_log')
            .setLock('pessimistic_write')
            .where('referral_log.invitee_user_id = :userId', {
              userId: input.userId,
            })
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
              await manager
                .getRepository(ReferralRewardEventEntity)
                .save(rewardEvent);
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

          await manager
            .getRepository(ReferralRewardEventEntity)
            .save(rewardEvent);
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
        },
      );

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

  async triggerMilestoneAForSuccessfulAnalysis(input: {
    inviteeUserId: string;
    reportId: string;
    correlationId: string;
    trigger: 'upload' | 'retry';
  }): Promise<TriggerReferralMilestoneResult> {
    const report = await this.reportRepo.findOne({
      where: {
        id: input.reportId,
        userId: input.inviteeUserId,
        status: 'parsed',
      },
    });

    if (!report) {
      return this.emptyMilestoneTriggerResult('not_found');
    }

    const priorParsedCount = await this.reportRepo
      .createQueryBuilder('report')
      .where('report.user_id = :userId', { userId: input.inviteeUserId })
      .andWhere('report.status = :status', { status: 'parsed' })
      .andWhere('report.id <> :reportId', { reportId: input.reportId })
      .getCount();

    if (priorParsedCount > 0) {
      return this.emptyMilestoneTriggerResult('not_eligible');
    }

    const release = await this.resolveReferralMilestone({
      milestone: 'milestone_a',
      inviteeUserId: input.inviteeUserId,
      creditAmount: (await this.getReferralPolicy()).milestoneACredits,
      releaseReasonCode: MILESTONE_A_RELEASE_REASON,
      correlationId: input.correlationId,
      eligibilityMetadata: {
        reportId: report.id,
        profileId: report.profileId,
        reportStatus: report.status,
        trigger: input.trigger,
      },
    });

    await this.dispatchReferralMilestoneNotification(
      release,
      input.correlationId,
      NotifiableEventType.REFERRAL_MILESTONE_A_RELEASED,
    );

    return release;
  }

  async triggerMilestoneBForReconciledOrder(input: {
    inviteeUserId: string;
    orderId: string;
    correlationId: string;
    provider: 'razorpay' | 'revenuecat';
    transactionId?: string | null;
  }): Promise<TriggerReferralMilestoneResult> {
    const policy = await this.getReferralPolicy();
    const order = await this.orderRepo.findOne({
      where: {
        id: input.orderId,
        userId: input.inviteeUserId,
        status: 'reconciled',
        credited: true,
      },
    });

    if (!order) {
      return this.emptyMilestoneTriggerResult('not_found');
    }

    const orderAmount = this.getOrderPaidAmount(order);
    if (orderAmount <= 0 && !policy.zeroAmountOrderEligible) {
      return this.emptyMilestoneTriggerResult('not_eligible');
    }

    const priorEligibleOrderCount = await this.orderRepo
      .createQueryBuilder('order')
      .where('order.user_id = :userId', { userId: input.inviteeUserId })
      .andWhere('order.status = :status', { status: 'reconciled' })
      .andWhere('order.credited = true')
      .andWhere('order.id <> :orderId', { orderId: input.orderId })
      .andWhere(
        policy.zeroAmountOrderEligible
          ? '1 = 1'
          : 'COALESCE(order.final_amount, order.amount) > 0',
      )
      .getCount();

    if (priorEligibleOrderCount > 0) {
      return this.emptyMilestoneTriggerResult('not_eligible');
    }

    const tier = this.selectMilestoneBTier(policy, orderAmount);
    const release = await this.resolveReferralMilestone({
      milestone: 'milestone_b',
      inviteeUserId: input.inviteeUserId,
      creditAmount: tier.rewardCredits,
      releaseReasonCode: MILESTONE_B_RELEASE_REASON,
      correlationId: input.correlationId,
      eligibilityMetadata: {
        orderId: order.id,
        provider: input.provider,
        transactionId: input.transactionId ?? null,
        orderAmount,
        currency: order.currency,
        tierLabel: tier.label,
        thresholdAmount: tier.thresholdAmount,
      },
    });

    await this.dispatchReferralMilestoneNotification(
      release,
      input.correlationId,
      NotifiableEventType.REFERRAL_MILESTONE_B_RELEASED,
    );

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

  private toReferralFriendProgressDto(
    log: ReferralLogEntity,
    invitee: UserEntity | null,
    rewardEvents: ReferralRewardEventEntity[],
  ): ReferralFriendProgressDto {
    const inviteeBonus = rewardEvents.find(
      (event) => event.rewardType === 'invitee_bonus',
    );
    const milestoneA = rewardEvents.find(
      (event) => event.rewardType === 'milestone_a',
    );
    const milestoneB = rewardEvents.find(
      (event) => event.rewardType === 'milestone_b',
    );

    return {
      referralLogId: log.id,
      inviteeDisplayName:
        invitee?.displayName?.trim() ||
        this.maskEmail(invitee?.email ?? null) ||
        'Referred user',
      inviteeEmailMasked: this.maskEmail(invitee?.email ?? null),
      reviewStatus: log.reviewStatus,
      inviteeBonusStatus: inviteeBonus?.status ?? log.inviteeBonusStatus,
      milestoneAStatus: milestoneA?.status ?? log.milestoneAStatus,
      milestoneBStatus: milestoneB?.status ?? log.milestoneBStatus,
      blockedReasonCode: log.blockedReasonCode,
      createdAt: log.createdAt.toISOString(),
      timeline: this.buildReferralTimeline(log, invitee, {
        inviteeBonus,
        milestoneA,
        milestoneB,
      }),
    };
  }

  private buildReferralTimeline(
    log: ReferralLogEntity,
    invitee: UserEntity | null,
    rewards: {
      inviteeBonus?: ReferralRewardEventEntity;
      milestoneA?: ReferralRewardEventEntity;
      milestoneB?: ReferralRewardEventEntity;
    },
  ): ReferralProgressTimelineItemDto[] {
    return [
      {
        key: 'signed_up',
        label: 'Signed up',
        status: 'completed',
        occurredAt: log.createdAt.toISOString(),
      },
      {
        key: 'email_verified',
        label: 'Email verified',
        status: invitee?.emailVerified ? 'completed' : 'pending',
        occurredAt: invitee?.emailVerified ? log.updatedAt.toISOString() : null,
      },
      {
        key: 'invitee_bonus',
        label: 'Invitee bonus',
        status: this.toTimelineStatus(
          rewards.inviteeBonus?.status ?? log.inviteeBonusStatus,
        ),
        occurredAt:
          rewards.inviteeBonus?.resolvedAt?.toISOString() ??
          log.inviteeBonusReleasedAt?.toISOString() ??
          null,
      },
      {
        key: 'first_analysis',
        label: 'First analysis',
        status: this.toTimelineStatus(
          rewards.milestoneA?.status ?? log.milestoneAStatus,
        ),
        occurredAt:
          rewards.milestoneA?.resolvedAt?.toISOString() ??
          log.milestoneAReleasedAt?.toISOString() ??
          null,
      },
      {
        key: 'first_paid_purchase',
        label: 'First paid purchase',
        status: this.toTimelineStatus(
          rewards.milestoneB?.status ?? log.milestoneBStatus,
        ),
        occurredAt:
          rewards.milestoneB?.resolvedAt?.toISOString() ??
          log.milestoneBReleasedAt?.toISOString() ??
          null,
      },
    ];
  }

  private toTimelineStatus(
    status:
      | ReferralRewardEventEntity['status']
      | ReferralLogEntity['milestoneAStatus'],
  ): ReferralProgressTimelineItemDto['status'] {
    if (status === 'released') {
      return 'completed';
    }
    if (status === 'blocked' || status === 'under_review') {
      return 'blocked';
    }
    if (status === 'capped') {
      return 'capped';
    }
    return 'pending';
  }

  private maskEmail(email: string | null): string | null {
    if (!email) return null;
    const [localPart, domain] = email.split('@');
    if (!localPart || !domain) return null;
    if (localPart.length <= 2) {
      return `${localPart[0] ?? '*'}***@${domain}`;
    }
    return `${localPart.slice(0, 2)}***@${domain}`;
  }

  private buildReferralLink(referralCode: string): string | null {
    const configuredBase =
      this.configService.get<string>('PUBLIC_WEB_BASE_URL') ??
      this.configService.get<string>('APP_PUBLIC_URL') ??
      '';
    const base = configuredBase.trim().replace(/\/+$/, '');
    if (!base) return null;
    return `${base}/register?ref=${encodeURIComponent(referralCode)}`;
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

  private buildMilestoneIdempotencyKey(
    referralLogId: string,
    milestone: ReferralMilestoneType,
  ): string {
    return `referral:${milestone}:${referralLogId}`;
  }

  private async resolveReferralMilestone(
    input: ResolveReferralMilestoneInput,
  ): Promise<TriggerReferralMilestoneResult> {
    return this.dataSource.transaction<TriggerReferralMilestoneResult>(
      async (manager) => {
        const invitee = await manager.getRepository(UserEntity).findOne({
          where: { id: input.inviteeUserId },
        });
        if (!invitee) {
          return this.emptyMilestoneTriggerResult('not_found');
        }

        const referralLog = await manager
          .getRepository(ReferralLogEntity)
          .createQueryBuilder('referral_log')
          .setLock('pessimistic_write')
          .where('referral_log.invitee_user_id = :inviteeUserId', {
            inviteeUserId: input.inviteeUserId,
          })
          .getOne();

        if (!referralLog) {
          return this.emptyMilestoneTriggerResult('not_found');
        }

        let rewardEvent = await manager
          .getRepository(ReferralRewardEventEntity)
          .createQueryBuilder('reward_event')
          .setLock('pessimistic_write')
          .where('reward_event.referral_log_id = :referralLogId', {
            referralLogId: referralLog.id,
          })
          .andWhere('reward_event.reward_type = :rewardType', {
            rewardType: input.milestone,
          })
          .getOne();

        if (
          rewardEvent &&
          (rewardEvent.status === 'released' ||
            rewardEvent.status === 'blocked' ||
            rewardEvent.status === 'capped')
        ) {
          this.syncResolvedMilestoneStatus(
            referralLog,
            input.milestone,
            rewardEvent,
          );
          await manager.getRepository(ReferralLogEntity).save(referralLog);
          return {
            released: false,
            referralLogId: referralLog.id,
            rewardEventId: rewardEvent.id,
            status: 'already_resolved',
            creditsGranted: 0,
            referrerUserId: referralLog.referrerUserId,
          };
        }

        rewardEvent =
          rewardEvent ??
          manager.getRepository(ReferralRewardEventEntity).create({
            referralLogId: referralLog.id,
            beneficiaryUserId: referralLog.referrerUserId,
            rewardType: input.milestone,
            status: 'pending',
            creditAmount: input.creditAmount.toFixed(2),
            idempotencyKey: this.buildMilestoneIdempotencyKey(
              referralLog.id,
              input.milestone,
            ),
            reasonCode: null,
            metadata: null,
            resolvedAt: null,
          });

        rewardEvent.creditAmount = input.creditAmount.toFixed(2);
        rewardEvent.metadata = {
          ...(rewardEvent.metadata ?? {}),
          ...input.eligibilityMetadata,
          correlationId: input.correlationId,
        };

        if (referralLog.reviewStatus === 'blocked') {
          return this.finalizeReferralMilestoneResolution(manager, {
            referralLog,
            rewardEvent,
            milestone: input.milestone,
            resolutionStatus: 'blocked',
            outcome: 'blocked',
            reasonCode: referralLog.blockedReasonCode ?? 'REFERRAL_BLOCKED',
            actorUserId: input.inviteeUserId,
            metadata: input.eligibilityMetadata,
          });
        }

        if (referralLog.reviewStatus === 'under_review') {
          return this.finalizeReferralMilestoneResolution(manager, {
            referralLog,
            rewardEvent,
            milestone: input.milestone,
            resolutionStatus: 'blocked',
            outcome: 'blocked',
            reasonCode: 'REFERRAL_UNDER_REVIEW',
            actorUserId: input.inviteeUserId,
            metadata: input.eligibilityMetadata,
          });
        }

        if (!invitee.emailVerified) {
          return this.finalizeReferralMilestoneResolution(manager, {
            referralLog,
            rewardEvent,
            milestone: input.milestone,
            resolutionStatus: 'blocked',
            outcome: 'blocked',
            reasonCode: 'INVITEE_EMAIL_NOT_VERIFIED',
            actorUserId: input.inviteeUserId,
            metadata: input.eligibilityMetadata,
          });
        }

        const policy = await this.getReferralPolicy();
        const monthlyCreditsAwarded = await this.getMonthlyReleasedRewardTotal(
          manager,
          referralLog.referrerUserId,
        );
        if (
          monthlyCreditsAwarded + input.creditAmount >
          policy.monthlyRewardCap
        ) {
          return this.finalizeReferralMilestoneResolution(manager, {
            referralLog,
            rewardEvent,
            milestone: input.milestone,
            resolutionStatus: 'capped',
            outcome: 'capped',
            reasonCode: 'MONTHLY_REWARD_CAP_REACHED',
            actorUserId: input.inviteeUserId,
            metadata: {
              ...input.eligibilityMetadata,
              monthlyCreditsAwarded,
              monthlyRewardCap: policy.monthlyRewardCap,
            },
          });
        }

        await this.entitlementsService.addCreditsInTransaction(
          manager,
          referralLog.referrerUserId,
          input.creditAmount,
          input.milestone === 'milestone_a'
            ? 'referral_milestone_a'
            : 'referral_milestone_b',
        );

        return this.finalizeReferralMilestoneResolution(manager, {
          referralLog,
          rewardEvent,
          milestone: input.milestone,
          resolutionStatus: 'released',
          outcome: 'success',
          reasonCode: input.releaseReasonCode,
          actorUserId: input.inviteeUserId,
          metadata: input.eligibilityMetadata,
          creditsGranted: input.creditAmount,
        });
      },
    );
  }

  private async finalizeReferralMilestoneResolution(
    manager: EntityManager,
    input: {
      referralLog: ReferralLogEntity;
      rewardEvent: ReferralRewardEventEntity;
      milestone: ReferralMilestoneType;
      resolutionStatus: 'released' | 'blocked' | 'capped';
      outcome: ReferralAuditEventEntity['outcome'];
      reasonCode: string;
      actorUserId: string;
      metadata: Record<string, unknown>;
      creditsGranted?: number;
    },
  ): Promise<TriggerReferralMilestoneResult> {
    const now = new Date();
    input.rewardEvent.status = input.resolutionStatus;
    input.rewardEvent.reasonCode = input.reasonCode;
    input.rewardEvent.resolvedAt = now;
    input.rewardEvent.metadata = {
      ...(input.rewardEvent.metadata ?? {}),
      ...input.metadata,
      correlationId:
        (input.rewardEvent.metadata?.correlationId as string | undefined) ??
        null,
    };

    this.setReferralLogMilestoneStatus(
      input.referralLog,
      input.milestone,
      input.resolutionStatus,
      now,
      input.reasonCode,
    );

    const savedRewardEvent = await manager
      .getRepository(ReferralRewardEventEntity)
      .save(input.rewardEvent);
    await manager.getRepository(ReferralLogEntity).save(input.referralLog);
    await this.saveAuditEvent(manager, {
      referralLogId: input.referralLog.id,
      rewardEventId: savedRewardEvent.id,
      actorUserId: input.actorUserId,
      eventType:
        input.milestone === 'milestone_a'
          ? 'REFERRAL_MILESTONE_A_RELEASE'
          : 'REFERRAL_MILESTONE_B_RELEASE',
      outcome: input.outcome,
      reasonCode: input.reasonCode,
      metadata: {
        ...input.metadata,
        creditAmount: parseFloat(savedRewardEvent.creditAmount),
        rewardStatus: input.resolutionStatus,
      },
    });

    return {
      released: input.resolutionStatus === 'released',
      referralLogId: input.referralLog.id,
      rewardEventId: savedRewardEvent.id,
      status:
        input.resolutionStatus === 'released'
          ? 'released'
          : input.resolutionStatus,
      creditsGranted:
        input.resolutionStatus === 'released' ? (input.creditsGranted ?? 0) : 0,
      referrerUserId: input.referralLog.referrerUserId,
    };
  }

  private async getMonthlyReleasedRewardTotal(
    manager: EntityManager,
    beneficiaryUserId: string,
  ): Promise<number> {
    const monthStart = new Date();
    monthStart.setUTCDate(1);
    monthStart.setUTCHours(0, 0, 0, 0);

    const nextMonthStart = new Date(monthStart);
    nextMonthStart.setUTCMonth(nextMonthStart.getUTCMonth() + 1);

    const raw = await manager
      .getRepository(ReferralRewardEventEntity)
      .createQueryBuilder('reward_event')
      .select('COALESCE(SUM(reward_event.credit_amount), 0)', 'total')
      .where('reward_event.beneficiary_user_id = :beneficiaryUserId', {
        beneficiaryUserId,
      })
      .andWhere('reward_event.status = :status', { status: 'released' })
      .andWhere('reward_event.reward_type IN (:...rewardTypes)', {
        rewardTypes: ['milestone_a', 'milestone_b'],
      })
      .andWhere('reward_event.resolved_at >= :monthStart', { monthStart })
      .andWhere('reward_event.resolved_at < :nextMonthStart', {
        nextMonthStart,
      })
      .getRawOne<{ total: string }>();

    return parseFloat(raw?.total ?? '0');
  }

  private selectMilestoneBTier(
    policy: ReferralPolicySnapshot,
    orderAmount: number,
  ) {
    const tiers = [...policy.milestoneBTiers].sort(
      (left, right) => left.thresholdAmount - right.thresholdAmount,
    );
    let selected = tiers[0];

    for (const tier of tiers) {
      if (orderAmount >= tier.thresholdAmount) {
        selected = tier;
      }
    }

    return selected;
  }

  private getOrderPaidAmount(order: OrderEntity): number {
    return parseFloat(order.finalAmount ?? order.amount ?? '0');
  }

  private setReferralLogMilestoneStatus(
    referralLog: ReferralLogEntity,
    milestone: ReferralMilestoneType,
    status: ReferralRewardEventEntity['status'],
    resolvedAt: Date,
    reasonCode: string,
  ): void {
    if (milestone === 'milestone_a') {
      referralLog.milestoneAStatus =
        status as ReferralLogEntity['milestoneAStatus'];
      referralLog.milestoneAReleasedAt =
        status === 'released' ? resolvedAt : referralLog.milestoneAReleasedAt;
    } else {
      referralLog.milestoneBStatus =
        status as ReferralLogEntity['milestoneBStatus'];
      referralLog.milestoneBReleasedAt =
        status === 'released' ? resolvedAt : referralLog.milestoneBReleasedAt;
    }

    if (status === 'blocked') {
      referralLog.blockedReasonCode = reasonCode;
    }
  }

  private syncResolvedMilestoneStatus(
    referralLog: ReferralLogEntity,
    milestone: ReferralMilestoneType,
    rewardEvent: ReferralRewardEventEntity,
  ): void {
    this.setReferralLogMilestoneStatus(
      referralLog,
      milestone,
      rewardEvent.status,
      rewardEvent.resolvedAt ?? new Date(),
      rewardEvent.reasonCode ?? 'REFERRAL_MILESTONE_ALREADY_RESOLVED',
    );
  }

  private emptyMilestoneTriggerResult(
    status: TriggerReferralMilestoneResult['status'],
  ): TriggerReferralMilestoneResult {
    return {
      released: false,
      referralLogId: null,
      rewardEventId: null,
      status,
      creditsGranted: 0,
      referrerUserId: null,
    };
  }

  private async dispatchReferralMilestoneNotification(
    result: TriggerReferralMilestoneResult,
    correlationId: string,
    eventType: NotifiableEventType,
  ): Promise<void> {
    if (
      !result.released ||
      !result.rewardEventId ||
      !result.referrerUserId ||
      !result.referralLogId
    ) {
      return;
    }

    await this.notificationPipeline.dispatch({
      eventType,
      userId: result.referrerUserId,
      correlationId,
      idempotencyKey: `referral-email:${result.rewardEventId}`,
      metadata: {
        referralLogId: result.referralLogId,
        rewardEventId: result.rewardEventId,
        creditsGranted: result.creditsGranted,
      },
    });
  }

  private async saveAuditEvent(
    manager: EntityManager,
    input: {
      referralLogId?: string | null;
      rewardEventId?: string | null;
      actorUserId?: string | null;
      eventType: string;
      outcome: ReferralAuditEventEntity['outcome'];
      reasonCode?: string | null;
      metadata?: Record<string, unknown> | null;
    },
  ): Promise<void> {
    await manager.getRepository(ReferralAuditEventEntity).save(
      manager.getRepository(ReferralAuditEventEntity).create({
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

  private async recordAuditEvent(input: {
    referralLogId?: string | null;
    rewardEventId?: string | null;
    actorUserId?: string | null;
    eventType: string;
    outcome: ReferralAuditEventEntity['outcome'];
    reasonCode?: string | null;
    metadata?: Record<string, unknown> | null;
  }): Promise<void> {
    await this.saveAuditEvent(this.dataSource.manager, input);
  }
}
