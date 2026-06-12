import { randomBytes } from 'node:crypto';
import {
  Injectable,
  InternalServerErrorException,
  Logger,
  OnModuleInit,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, QueryFailedError, Repository } from 'typeorm';
import { ReferralPolicyConfigEntity } from '../../database/entities/referral-policy-config.entity';
import { UserReferralProfileEntity } from '../../database/entities/user-referral-profile.entity';
import { UserEntity } from '../../database/entities/user.entity';
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

@Injectable()
export class ReferralsService implements OnModuleInit {
  private readonly logger = new Logger(ReferralsService.name);

  constructor(
    private readonly dataSource: DataSource,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(UserReferralProfileEntity)
    private readonly referralProfileRepo: Repository<UserReferralProfileEntity>,
    @InjectRepository(ReferralPolicyConfigEntity)
    private readonly referralPolicyConfigRepo: Repository<ReferralPolicyConfigEntity>,
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
}
