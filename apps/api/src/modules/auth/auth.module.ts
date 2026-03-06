import { Module } from '@nestjs/common';
import { AuthGuard } from '../../common/guards/auth.guard';
import { InMemoryNotificationService } from '../../common/notification/in-memory-notification.service';
import { NotificationService } from '../../common/notification/notification.service';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { PasswordRecoveryService } from './password-recovery.service';

@Module({
  controllers: [AuthController],
  providers: [
    AuthService,
    AuthGuard,
    PasswordRecoveryService,
    {
      provide: NotificationService,
      useClass: InMemoryNotificationService,
    },
  ],
  exports: [AuthService, PasswordRecoveryService, NotificationService],
})
export class AuthModule {}
