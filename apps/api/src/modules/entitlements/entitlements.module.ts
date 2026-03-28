import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PlanEntity } from '../../database/entities/plan.entity';
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
      UserEntitlementEntity,
      ReportEntity,
      ShareLinkEntity,
    ]),
    AuthModule,
  ],
  controllers: [EntitlementsController],
  providers: [EntitlementsService, UsageLimitsService],
  exports: [EntitlementsService, UsageLimitsService],
})
export class EntitlementsModule {}
