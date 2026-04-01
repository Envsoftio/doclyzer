import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EmailDeliveryEventEntity } from '../../database/entities/email-delivery-event.entity';
import { EmailQueueItemEntity } from '../../database/entities/email-queue-item.entity';
import { SuperadminAuthAuditEventEntity } from '../../database/entities/superadmin-auth-audit-event.entity';
import { EmailAdminController } from './email-admin.controller';
import { EmailAdminService } from './email-admin.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      EmailQueueItemEntity,
      EmailDeliveryEventEntity,
      SuperadminAuthAuditEventEntity,
    ]),
  ],
  controllers: [EmailAdminController],
  providers: [EmailAdminService],
})
export class EmailAdminModule {}
