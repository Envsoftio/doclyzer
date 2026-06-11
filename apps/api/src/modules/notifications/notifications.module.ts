import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AccountPreferenceEntity } from '../../database/entities/account-preference.entity';
import { PushDeliveryEventEntity } from '../../database/entities/push-delivery-event.entity';
import { PushOpenEventEntity } from '../../database/entities/push-open-event.entity';
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
    ]),
  ],
  controllers: [NotificationsController, NotificationsAdminController],
  providers: [NotificationsService, PushProviderService],
  exports: [NotificationsService],
})
export class NotificationsModule {}
