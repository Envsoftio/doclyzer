import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReportEntity } from '../../database/entities/report.entity';
import { ReportLabValueEntity } from '../../database/entities/report-lab-value.entity';
import { ReportProcessingAttemptEntity } from '../../database/entities/report-processing-attempt.entity';
import { AuthModule } from '../auth/auth.module';
import { EntitlementsModule } from '../entitlements/entitlements.module';
import { ProfilesModule } from '../profiles/profiles.module';
import { StorageModule } from '../../common/storage/storage.module';
import { NotificationPipelineModule } from '../../common/notification-pipeline/notification-pipeline.module';
import { ReportsController } from './reports.controller';
import { ReportsService } from './reports.service';
import { ReportSummaryService } from './report-summary/report-summary.service';
import { DoclingClient } from './docling.client';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      ReportEntity,
      ReportLabValueEntity,
      ReportProcessingAttemptEntity,
    ]),
    AuthModule,
    EntitlementsModule,
    ProfilesModule,
    StorageModule,
    NotificationPipelineModule,
  ],
  controllers: [ReportsController],
  providers: [ReportsService, ReportSummaryService, DoclingClient],
})
export class ReportsModule {}
