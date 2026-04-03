import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AccountPreferenceEntity } from '../../database/entities/account-preference.entity';
import { EmailDeliveryEventEntity } from '../../database/entities/email-delivery-event.entity';
import { EmailQueueItemEntity } from '../../database/entities/email-queue-item.entity';
import { NotificationPipelineService } from './notification-pipeline.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      AccountPreferenceEntity,
      EmailQueueItemEntity,
      EmailDeliveryEventEntity,
    ]),
  ],
  providers: [NotificationPipelineService],
  exports: [NotificationPipelineService],
})
export class NotificationPipelineModule {}
