import {
  ReportOperationsController,
  ReportProcessHealthController,
} from './processing/report-operations.controller';
import { ReportProcessingController } from './processing/report-processing.controller';
import { ReportWorkerService } from './processing/report-worker.service';
import { ReportVlShadowService } from './processing/report-vl-shadow.service';
import { ReportDispatcherService } from './processing/report-dispatcher.service';
import { ReportStreamService } from './processing/report-stream.service';
import { NotificationsModule } from '../notifications/notifications.module';
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReportEntity } from '../../database/entities/report.entity';
import { ReportLabValueEntity } from '../../database/entities/report-lab-value.entity';
import { ReportLabValueCorrectionEntity } from '../../database/entities/report-lab-value-correction.entity';
import { ReportProcessingAttemptEntity } from '../../database/entities/report-processing-attempt.entity';
import { ReportResultInsightEntity } from '../../database/entities/report-result-insight.entity';
import { ReportResultInsightUsageEntity } from '../../database/entities/report-result-insight-usage.entity';
import { AuthModule } from '../auth/auth.module';
import { EntitlementsModule } from '../entitlements/entitlements.module';
import { ProfilesModule } from '../profiles/profiles.module';
import { StorageModule } from '../../common/storage/storage.module';
import { NotificationPipelineModule } from '../../common/notification-pipeline/notification-pipeline.module';
import { ReferralsModule } from '../referrals/referrals.module';
import { ReportsController } from './reports.controller';
import { ReportsRecycleBinCleanupService } from './reports-recycle-bin-cleanup.service';
import { ReportsService } from './reports.service';
import { ReportSummaryService } from './report-summary/report-summary.service';
import { OpenDataLoaderClient } from './opendataloader.client';
import { ReportLabAiFallbackService } from './report-lab-ai-fallback.service';
import { ReportResultInsightService } from './report-result-insight.service';
import { ReportRangeSuggestionService } from './report-range-suggestion.service';
import { ReportValueSuggestionService } from './report-value-suggestion.service';
import { ImageToPdfService } from './image-to-pdf.service';
import { PaddleOcrClient } from './paddle-ocr.client';
import { DoclingOcrClient } from './docling-ocr.client';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      ReportEntity,
      ReportLabValueEntity,
      ReportLabValueCorrectionEntity,
      ReportProcessingAttemptEntity,
      ReportResultInsightEntity,
      ReportResultInsightUsageEntity,
    ]),
    AuthModule,
    NotificationsModule,
    EntitlementsModule,
    ProfilesModule,
    StorageModule,
    NotificationPipelineModule,
    ReferralsModule,
  ],
  controllers: [
    ReportProcessHealthController,
    ReportOperationsController,
    ReportProcessingController,
    ReportsController,
  ],
  providers: [
    ReportVlShadowService,
    ReportsService,
    ReportWorkerService,
    ReportDispatcherService,
    ReportStreamService,
    ReportsRecycleBinCleanupService,
    ReportSummaryService,
    OpenDataLoaderClient,
    DoclingOcrClient,
    PaddleOcrClient,
    ReportLabAiFallbackService,
    ReportResultInsightService,
    ReportRangeSuggestionService,
    ReportValueSuggestionService,
    ImageToPdfService,
  ],
  exports: [ReportWorkerService, ReportDispatcherService],
})
export class ReportsModule {}
