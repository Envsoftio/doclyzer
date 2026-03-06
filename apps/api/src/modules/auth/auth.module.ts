import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserEntity } from '../../database/entities/user.entity';
import { SessionEntity } from '../../database/entities/session.entity';
import { PasswordResetTokenEntity } from '../../database/entities/password-reset-token.entity';
import { AuthGuard } from '../../common/guards/auth.guard';
import { InMemoryNotificationService } from '../../common/notification/in-memory-notification.service';
import { NotificationService } from '../../common/notification/notification.service';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { PasswordRecoveryService } from './password-recovery.service';

@Module({
  imports: [TypeOrmModule.forFeature([UserEntity, SessionEntity, PasswordResetTokenEntity])],
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
