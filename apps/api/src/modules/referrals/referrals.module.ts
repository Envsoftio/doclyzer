import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EntitlementsModule } from '../entitlements/entitlements.module';
import { NotificationPipelineModule } from '../../common/notification-pipeline/notification-pipeline.module';
import { AuthModule } from '../auth/auth.module';
import { ReferralAuditEventEntity } from '../../database/entities/referral-audit-event.entity';
import { ReferralLogEntity } from '../../database/entities/referral-log.entity';
import { ReferralPolicyConfigEntity } from '../../database/entities/referral-policy-config.entity';
import { ReferralRewardEventEntity } from '../../database/entities/referral-reward-event.entity';
import { UserReferralProfileEntity } from '../../database/entities/user-referral-profile.entity';
import { UserEntity } from '../../database/entities/user.entity';
import { ReferralsController } from './referrals.controller';
import { ReferralsService } from './referrals.service';

@Module({
  imports: [
    forwardRef(() => AuthModule),
    EntitlementsModule,
    NotificationPipelineModule,
    TypeOrmModule.forFeature([
      UserEntity,
      UserReferralProfileEntity,
      ReferralLogEntity,
      ReferralRewardEventEntity,
      ReferralAuditEventEntity,
      ReferralPolicyConfigEntity,
    ]),
  ],
  controllers: [ReferralsController],
  providers: [ReferralsService],
  exports: [ReferralsService],
})
export class ReferralsModule {}
