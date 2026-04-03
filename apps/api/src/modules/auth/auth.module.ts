import { forwardRef, Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserEntity } from '../../database/entities/user.entity';
import { SessionEntity } from '../../database/entities/session.entity';
import { RestrictionEntity } from '../../database/entities/restriction.entity';
import { AuthGuard } from '../../common/guards/auth.guard';
import { NotificationService } from '../../common/notification/notification.service';
import { PipelineNotificationService } from '../../common/notification/pipeline-notification.service';
import { NotificationPipelineModule } from '../../common/notification-pipeline/notification-pipeline.module';
import { AuthController } from './auth.controller';
import { BetterAuthService } from './better-auth.service';
import { AuthService } from './auth.service';
import { PasswordRecoveryService } from './password-recovery.service';
import { SuperadminGuard } from './superadmin.guard';
import { ProfilesModule } from '../profiles/profiles.module';

@Module({
  imports: [
    forwardRef(() => ProfilesModule),
    NotificationPipelineModule,
    TypeOrmModule.forFeature([
      UserEntity,
      SessionEntity,
      RestrictionEntity,
    ]),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    BetterAuthService,
    AuthGuard,
    SuperadminGuard,
    PasswordRecoveryService,
    {
      provide: NotificationService,
      useClass: PipelineNotificationService,
    },
  ],
  exports: [
    AuthService,
    BetterAuthService,
    AuthGuard,
    SuperadminGuard,
    PasswordRecoveryService,
    NotificationService,
    TypeOrmModule,
  ],
})
export class AuthModule {}
