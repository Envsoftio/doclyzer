import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { AccountOverrideEntity } from '../../database/entities/account-override.entity';
import { RestrictionEntity } from '../../database/entities/restriction.entity';
import { ShareLinkEntity } from '../../database/entities/share-link.entity';
import { SuperadminActionAuditEventEntity } from '../../database/entities/superadmin-action-audit-event.entity';
import { SuspiciousActivityQueueItemEntity } from '../../database/entities/suspicious-activity-queue-item.entity';
import { UserEntity } from '../../database/entities/user.entity';
import { AccountOverrideController } from './account-override.controller';
import { AccountOverrideService } from './account-override.service';
import { AuditIncidentController } from './audit-incident.controller';
import { AuditIncidentService } from './audit-incident.service';
import { RiskContainmentController } from './risk-containment.controller';
import { RiskContainmentService } from './risk-containment.service';
import { SuspiciousActivityController } from './suspicious-activity.controller';
import { SuspiciousActivityService } from './suspicious-activity.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      AccountOverrideEntity,
      SuperadminActionAuditEventEntity,
      SuspiciousActivityQueueItemEntity,
      ShareLinkEntity,
      RestrictionEntity,
      UserEntity,
    ]),
    AuthModule,
  ],
  controllers: [
    AccountOverrideController,
    AuditIncidentController,
    SuspiciousActivityController,
    RiskContainmentController,
  ],
  providers: [
    AccountOverrideService,
    AuditIncidentService,
    SuspiciousActivityService,
    RiskContainmentService,
  ],
  exports: [AccountOverrideService, AuditIncidentService, RiskContainmentService],
})
export class AuditIncidentModule {}
