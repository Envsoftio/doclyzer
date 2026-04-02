import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AnalyticsAdminController } from './analytics-admin.controller';
import { AnalyticsAdminService } from './analytics-admin.service';
import { AnalyticsGovernanceService } from './analytics-governance.service';
import { UserActivityService } from './user-activity.service';
import { AuthModule } from '../auth/auth.module';
import { UserEntity } from '../../database/entities/user.entity';
import { SessionEntity } from '../../database/entities/session.entity';
import { ProfileEntity } from '../../database/entities/profile.entity';
import { ReportEntity } from '../../database/entities/report.entity';
import { OrderEntity } from '../../database/entities/order.entity';
import { AnalyticsTaxonomyFieldEntity } from '../../database/entities/analytics-taxonomy-field.entity';
import { AnalyticsGovernanceReviewEntity } from '../../database/entities/analytics-governance-review.entity';
import { SuperadminAuthAuditEventEntity } from '../../database/entities/superadmin-auth-audit-event.entity';
import { ShareAccessEventEntity } from '../../database/entities/share-access-event.entity';
import { ShareLinkEntity } from '../../database/entities/share-link.entity';
import { ConsentRecordEntity } from '../../database/entities/consent-record.entity';
import { UserSharePolicyEntity } from '../../database/entities/user-share-policy.entity';
import { SubscriptionEntity } from '../../database/entities/subscription.entity';
import { AuditIncidentModule } from '../audit-incident/audit-incident.module';
import { EntitlementsModule } from '../entitlements/entitlements.module';

@Module({
  imports: [
    AuthModule,
    AuditIncidentModule,
    EntitlementsModule,
    TypeOrmModule.forFeature([
      UserEntity,
      SessionEntity,
      ProfileEntity,
      ReportEntity,
      OrderEntity,
      SubscriptionEntity,
      SuperadminAuthAuditEventEntity,
      AnalyticsTaxonomyFieldEntity,
      AnalyticsGovernanceReviewEntity,
      ShareAccessEventEntity,
      ShareLinkEntity,
      ConsentRecordEntity,
      UserSharePolicyEntity,
    ]),
  ],
  controllers: [AnalyticsAdminController],
  providers: [AnalyticsAdminService, AnalyticsGovernanceService, UserActivityService],
})
export class AnalyticsAdminModule {}
