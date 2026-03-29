import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { SuperadminActionAuditEventEntity } from '../../database/entities/superadmin-action-audit-event.entity';
import { SuspiciousActivityQueueItemEntity } from '../../database/entities/suspicious-activity-queue-item.entity';
import { AuditIncidentController } from './audit-incident.controller';
import { AuditIncidentService } from './audit-incident.service';
import { SuspiciousActivityController } from './suspicious-activity.controller';
import { SuspiciousActivityService } from './suspicious-activity.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      SuperadminActionAuditEventEntity,
      SuspiciousActivityQueueItemEntity,
    ]),
    AuthModule,
  ],
  controllers: [AuditIncidentController, SuspiciousActivityController],
  providers: [AuditIncidentService, SuspiciousActivityService],
  exports: [AuditIncidentService],
})
export class AuditIncidentModule {}
