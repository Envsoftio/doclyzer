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
import { ReportsRecycleBinCleanupService } from './reports-recycle-bin-cleanup.service';
import { ReportsService } from './reports.service';
import { ReportSummaryService } from './report-summary/report-summary.service';
import { OpenDataLoaderClient } from './opendataloader.client';
import { ReportLabAiFallbackService } from './report-lab-ai-fallback.service';
import { ImageToPdfService } from './image-to-pdf.service';
import { DoclingOcrClient } from './docling-ocr.client';

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
  providers: [
    ReportsService,
    ReportsRecycleBinCleanupService,
    ReportSummaryService,
    OpenDataLoaderClient,
    DoclingOcrClient,
    ReportLabAiFallbackService,
    ImageToPdfService,
  ],
})
export class ReportsModule {}
