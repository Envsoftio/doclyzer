import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReferralAuditEventEntity } from '../../database/entities/referral-audit-event.entity';
import { ReferralLogEntity } from '../../database/entities/referral-log.entity';
import { ReferralPolicyConfigEntity } from '../../database/entities/referral-policy-config.entity';
import { ReferralRewardEventEntity } from '../../database/entities/referral-reward-event.entity';
import { UserReferralProfileEntity } from '../../database/entities/user-referral-profile.entity';
import { UserEntity } from '../../database/entities/user.entity';
import { ReferralsService } from './referrals.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      UserEntity,
      UserReferralProfileEntity,
      ReferralLogEntity,
      ReferralRewardEventEntity,
      ReferralAuditEventEntity,
      ReferralPolicyConfigEntity,
    ]),
  ],
  providers: [ReferralsService],
  exports: [ReferralsService],
})
export class ReferralsModule {}
