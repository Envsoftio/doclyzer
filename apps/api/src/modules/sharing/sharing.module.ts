import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ShareLinkEntity } from '../../database/entities/share-link.entity';
import { UserSharePolicyEntity } from '../../database/entities/user-share-policy.entity';
import { ReportEntity } from '../../database/entities/report.entity';
import { ReportLabValueEntity } from '../../database/entities/report-lab-value.entity';
import { ShareAccessEventEntity } from '../../database/entities/share-access-event.entity';
import { AuthModule } from '../auth/auth.module';
import { ProfilesModule } from '../profiles/profiles.module';
import { SharingController } from './sharing.controller';
import { PublicSharingController } from './public-sharing.controller';
import { SharingService } from './sharing.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([ShareLinkEntity, UserSharePolicyEntity, ReportEntity, ReportLabValueEntity, ShareAccessEventEntity]),
    AuthModule,
    ProfilesModule,
  ],
  controllers: [SharingController, PublicSharingController],
  providers: [SharingService],
})
export class SharingModule {}
