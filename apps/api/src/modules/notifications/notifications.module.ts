import { PushCampaignService } from './push-campaign.service';
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AccountPreferenceEntity } from '../../database/entities/account-preference.entity';
import { PushDeliveryEventEntity } from '../../database/entities/push-delivery-event.entity';
import { PushOpenEventEntity } from '../../database/entities/push-open-event.entity';
import { NotificationReadEntity } from '../../database/entities/notification-read.entity';
import { EmailQueueItemEntity } from '../../database/entities/email-queue-item.entity';
import { ShareLinkEntity } from '../../database/entities/share-link.entity';
import { PushSendAuditEntity } from '../../database/entities/push-send-audit.entity';
import { UserDeviceTokenEntity } from '../../database/entities/user-device-token.entity';
import { AuthModule } from '../auth/auth.module';
import {
  NotificationsAdminController,
  NotificationsController,
} from './notifications.controller';
import { NotificationsService } from './notifications.service';
import { PushProviderService } from './push-provider.service';

@Module({
  imports: [
    AuthModule,
    TypeOrmModule.forFeature([
      AccountPreferenceEntity,
      UserDeviceTokenEntity,
      PushSendAuditEntity,
      PushDeliveryEventEntity,
      PushOpenEventEntity,
      NotificationReadEntity,
      EmailQueueItemEntity,
      ShareLinkEntity,
    ]),
  ],
  controllers: [NotificationsController, NotificationsAdminController],
  providers: [PushCampaignService, NotificationsService, PushProviderService],
  exports: [PushCampaignService, NotificationsService, PushProviderService],
})
export class NotificationsModule {}
