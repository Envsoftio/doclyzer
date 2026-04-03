import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { EmailQueueItemEntity } from '../../database/entities/email-queue-item.entity';
import { EmailDeliveryEventEntity } from '../../database/entities/email-delivery-event.entity';
import { UserEntity } from '../../database/entities/user.entity';
import { VerificationEntity } from '../../database/entities/verification.entity';
import { EMAIL_PROVIDER } from './email-provider.interface';
import { DevEmailProviderService } from './providers/dev-email-provider.service';
import { EmailTemplateService } from './email-template.service';
import { EmailDeliveryWorkerService } from './email-delivery.worker';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      EmailQueueItemEntity,
      EmailDeliveryEventEntity,
      UserEntity,
      VerificationEntity,
    ]),
  ],
  providers: [
    EmailTemplateService,
    DevEmailProviderService,
    EmailDeliveryWorkerService,
    {
      provide: EMAIL_PROVIDER,
      useFactory: (
        configService: ConfigService,
        devProvider: DevEmailProviderService,
      ) => {
        const provider =
          configService.get<string>('email.provider') ?? 'dev';
        if (provider === 'dev') return devProvider;
        return devProvider;
      },
      inject: [ConfigService, DevEmailProviderService],
    },
  ],
  exports: [EmailDeliveryWorkerService],
})
export class EmailDeliveryModule {}
