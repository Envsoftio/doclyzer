import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { RestrictionEntity } from '../../database/entities/restriction.entity';
import { ShareLinkEntity } from '../../database/entities/share-link.entity';
import { SuperadminActionAuditEventEntity } from '../../database/entities/superadmin-action-audit-event.entity';
import { SuspiciousActivityQueueItemEntity } from '../../database/entities/suspicious-activity-queue-item.entity';
import { UserEntity } from '../../database/entities/user.entity';
import { AuditIncidentController } from './audit-incident.controller';
import { AuditIncidentService } from './audit-incident.service';
import { RiskContainmentController } from './risk-containment.controller';
import { RiskContainmentService } from './risk-containment.service';
import { SuspiciousActivityController } from './suspicious-activity.controller';
import { SuspiciousActivityService } from './suspicious-activity.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      SuperadminActionAuditEventEntity,
      SuspiciousActivityQueueItemEntity,
      ShareLinkEntity,
      RestrictionEntity,
      UserEntity,
    ]),
    AuthModule,
  ],
  controllers: [
    AuditIncidentController,
    SuspiciousActivityController,
    RiskContainmentController,
  ],
  providers: [
    AuditIncidentService,
    SuspiciousActivityService,
    RiskContainmentService,
  ],
  exports: [AuditIncidentService, RiskContainmentService],
})
export class AuditIncidentModule {}
