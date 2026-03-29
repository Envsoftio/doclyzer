import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserEntity } from '../../database/entities/user.entity';
import { SessionEntity } from '../../database/entities/session.entity';
import { RestrictionEntity } from '../../database/entities/restriction.entity';
import { SuperadminAuthAuditEventEntity } from '../../database/entities/superadmin-auth-audit-event.entity';
import { SuperadminMfaChallengeEntity } from '../../database/entities/superadmin-mfa-challenge.entity';
import { AuthGuard } from '../../common/guards/auth.guard';
import { InMemoryNotificationService } from '../../common/notification/in-memory-notification.service';
import { NotificationService } from '../../common/notification/notification.service';
import { AuthController } from './auth.controller';
import { BetterAuthService } from './better-auth.service';
import { AuthService } from './auth.service';
import { PasswordRecoveryService } from './password-recovery.service';
import { SuperadminAuthController } from './superadmin-auth.controller';
import { SuperadminAuthService } from './superadmin-auth.service';
import { SuperadminGuard } from './superadmin.guard';
import { AdminActionTokenGuard } from './admin-action-token.guard';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      UserEntity,
      SessionEntity,
      RestrictionEntity,
      SuperadminMfaChallengeEntity,
      SuperadminAuthAuditEventEntity,
    ]),
  ],
  controllers: [AuthController, SuperadminAuthController],
  providers: [
    AuthService,
    BetterAuthService,
    AuthGuard,
    SuperadminGuard,
    SuperadminAuthService,
    PasswordRecoveryService,
    AdminActionTokenGuard,
    {
      provide: NotificationService,
      useClass: InMemoryNotificationService,
    },
  ],
  exports: [
    AuthService,
    BetterAuthService,
    AuthGuard,
    SuperadminGuard,
    SuperadminAuthService,
    PasswordRecoveryService,
    AdminActionTokenGuard,
    NotificationService,
    TypeOrmModule,
  ],
})
export class AuthModule {}
