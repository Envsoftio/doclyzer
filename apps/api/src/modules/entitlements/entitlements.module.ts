import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PlanEntity } from '../../database/entities/plan.entity';
import { PlanConfigAuditEventEntity } from '../../database/entities/plan-config-audit-event.entity';
import { ReportEntity } from '../../database/entities/report.entity';
import { ShareLinkEntity } from '../../database/entities/share-link.entity';
import { UserEntitlementEntity } from '../../database/entities/user-entitlement.entity';
import { AuthModule } from '../auth/auth.module';
import { EntitlementsController } from './entitlements.controller';
import { EntitlementsService } from './entitlements.service';
import { UsageLimitsService } from './usage-limits.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      PlanEntity,
      PlanConfigAuditEventEntity,
      UserEntitlementEntity,
      ReportEntity,
      ShareLinkEntity,
    ]),
    forwardRef(() => AuthModule),
  ],
  controllers: [EntitlementsController],
  providers: [EntitlementsService, UsageLimitsService],
  exports: [EntitlementsService, UsageLimitsService],
})
export class EntitlementsModule {}
