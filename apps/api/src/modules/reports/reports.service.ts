import {
  BadRequestException,
  Inject,
  Injectable,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { createHash, randomUUID } from 'node:crypto';
import { IsNull, LessThanOrEqual, Repository } from 'typeorm';
import { isUUID } from 'class-validator';
import { redactSecrets } from '../../common/redact-secrets';
import type { FileStorageService } from '../../common/storage/file-storage.interface';
import { FILE_STORAGE } from '../../common/storage/storage.module';
import type { ReportStatus } from '../../database/entities/report.entity';
import { ReportEntity } from '../../database/entities/report.entity';
import type { AttemptTrigger } from '../../database/entities/report-processing-attempt.entity';
import { ReportProcessingAttemptEntity } from '../../database/entities/report-processing-attempt.entity';
import { ReportLabValueEntity } from '../../database/entities/report-lab-value.entity';
import { ProfilesService } from '../profiles/profiles.service';
import { ReportSummaryService } from './report-summary/report-summary.service';
import { OpenDataLoaderClient } from './opendataloader.client';
import { DoclingOcrClient } from './docling-ocr.client';
import { ImageToPdfService } from './image-to-pdf.service';
import {
  OpenDataLoaderJsonParser,
  type OpenDataLoaderParsedWithDiagnosticsOutput,
} from './opendataloader-json-parser';
import { LabValueExtractor } from './lab-value-extractor';
import { LabDetailsExtractor } from './lab-details-extractor';
import { ReportLabAiFallbackService } from './report-lab-ai-fallback.service';
import { ReportDuplicateDetectedException } from './exceptions/report-duplicate-detected.exception';
import { ReportFileUnavailableException } from './exceptions/report-file-unavailable.exception';
import { ReportLimitExceededException } from './exceptions/report-limit-exceeded.exception';
import { ReportNotFoundException } from './exceptions/report-not-found.exception';
import { ReportUploadException } from './exceptions/report-upload.exception';
import { UsageLimitsService } from '../entitlements/usage-limits.service';
import { NotificationPipelineService } from '../../common/notification-pipeline/notification-pipeline.service';
import { NotifiableEventType } from '../../common/notification-pipeline/notification-event.types';
import {
  ALLOWED_CONTENT_TYPES,
  ALLOWED_IMAGE_CONTENT_TYPES,
  ALLOWED_UPLOAD_CONTENT_TYPES,
  MAX_REPORT_SIZE_BYTES,
  REPORT_ALREADY_PARSED,
  REPORT_CONTENT_NOT_RECOGNIZED,
  REPORT_FILE_EMPTY,
  REPORT_FILE_REQUIRED,
  REPORT_FILE_TOO_LARGE,
  REPORT_FILE_TYPE_UNSUPPORTED,
  REPORT_NO_ACTIVE_PROFILE,
} from './reports.types';

export interface UploadReportResult {
  reportId: string;
  profileId: string;
  fileName: string;
  contentType: string;
  sizeBytes: number;
  status: string;
}

export interface ExtractedLabValueDto {
  parameterName: string;
  value: string;
  unit?: string;
  sampleDate?: string;
  referenceRange?: string;
  isAbnormal?: boolean;
}

export interface ReportDto {
  id: string;
  profileId: string;
  profileName?: string;
  profileIsActive?: boolean;
  originalFileName: string;
  contentType: string;
  sizeBytes: number;
  status: string;
  createdAt: string;
  deletedAt?: string;
  purgeAfterAt?: string;
  summary?: string;
  parsedTranscript?: string;
  extractedLabValues: ExtractedLabValueDto[];
  structuredReport?: StructuredReportDto;
}

export interface StructuredPatientDetailsDto {
  name?: string;
  age?: string;
  gender?: string;
  bookingId?: string;
  sampleCollectionDate?: string;
}

export interface StructuredLabDetailsDto {
  name?: string;
  address?: string;
  phone?: string;
  email?: string;
  location?: string;
}

export interface StructuredSectionItemDto {
  parameterName: string;
  value: string;
  unit?: string;
  sampleDate?: string;
  referenceRange?: string;
  isAbnormal?: boolean;
}

export interface StructuredSectionDto {
  heading: string;
  tests: StructuredSectionItemDto[];
}

export interface StructuredReportDto {
  patientDetails: StructuredPatientDetailsDto;
  labDetails?: StructuredLabDetailsDto;
  sections: StructuredSectionDto[];
}

interface StructuredReportLabInput {
  parameterName: string;
  value: string;
  unit: string | null;
  sampleDate: string | null;
  referenceRange: string | null;
  isAbnormal: boolean | null;
}

interface SelectedOdlLabOutput {
  extractedLabValues: StructuredReportLabInput[];
  structuredReport: StructuredReportDto;
}

const OCR_TEXT_LOG_CHAR_LIMIT = 6000;

type ReportInputSource = 'pdf' | 'image';

interface ParsedBufferResult {
  status: ReportStatus;
  transcript: string | null;
  opendataloaderJson?: unknown;
}

export interface TrendDataPoint {
  date: string;
  value: number;
}

export interface TrendParameter {
  parameterName: string;
  unit?: string;
  dataPoints: TrendDataPoint[];
}

export interface LabTrendsResult {
  parameters: TrendParameter[];
}

export interface ProcessingAttemptDto {
  id: string;
  trigger: string;
  outcome: string;
  attemptedAt: string;
}

@Injectable()
export class ReportsService {
  private readonly logger = new Logger(ReportsService.name);
  private static readonly MIN_PARSE_TEXT_LENGTH = 120;
  private static readonly RECYCLE_BIN_RETENTION_DAYS = 30;

  constructor(
    @InjectRepository(ReportEntity)
    private readonly reportRepo: Repository<ReportEntity>,
    @InjectRepository(ReportLabValueEntity)
    private readonly reportLabValueRepo: Repository<ReportLabValueEntity>,
    @InjectRepository(ReportProcessingAttemptEntity)
    private readonly attemptRepo: Repository<ReportProcessingAttemptEntity>,
    private readonly profilesService: ProfilesService,
    @Inject(FILE_STORAGE) private readonly fileStorage: FileStorageService,
    private readonly reportSummaryService: ReportSummaryService,
    private readonly usageLimitsService: UsageLimitsService,
    private readonly openDataLoaderClient: OpenDataLoaderClient,
    private readonly doclingOcrClient: DoclingOcrClient,
    private readonly reportLabAiFallbackService: ReportLabAiFallbackService,
    private readonly notificationPipeline: NotificationPipelineService,
    private readonly imageToPdfService: ImageToPdfService,
  ) {
    this.labExtractor = new LabValueExtractor();
  }

  private readonly labExtractor: LabValueExtractor;
  private readonly labDetailsExtractor = new LabDetailsExtractor();
  private readonly odlJsonParser = new OpenDataLoaderJsonParser();

  private throwIfAlreadyParsed(status: string): void {
    if (status === 'parsed') {
      throw new BadRequestException({
        code: REPORT_ALREADY_PARSED,
        message: 'Report is already parsed; nothing to retry or keep.',
      });
    }
  }

  private async getActiveReportOrThrow(
    userId: string,
    reportId: string,
  ): Promise<ReportEntity> {
    if (!isUUID(reportId)) throw new ReportNotFoundException();
    const entity = await this.reportRepo.findOne({
      where: { id: reportId, userId, deletedAt: IsNull() },
    });
    if (!entity) throw new ReportNotFoundException();
    return entity;
  }

  async uploadReport(
    userId: string,
    file: {
      buffer: Buffer;
      originalname: string;
      mimetype: string;
      size: number;
    },
    options?: { duplicateAction?: 'upload_anyway' },
    correlationId?: string,
  ): Promise<UploadReportResult> {
    const activeProfileId =
      await this.profilesService.getActiveProfileId(userId);
    if (!activeProfileId) {
      throw new ReportUploadException(
        REPORT_NO_ACTIVE_PROFILE,
        'No active profile. Create or select a profile first.',
      );
    }

    const reportUsage = await this.usageLimitsService.getReportUsage(userId);
    if (reportUsage.current >= reportUsage.limit) {
      throw new ReportLimitExceededException(reportUsage);
    }

    if (!file?.buffer) {
      throw new ReportUploadException(REPORT_FILE_REQUIRED, 'No file uploaded');
    }
    if (file.buffer.length === 0) {
      throw new ReportUploadException(REPORT_FILE_EMPTY, 'File is empty');
    }
    if (file.buffer.length > MAX_REPORT_SIZE_BYTES) {
      throw new ReportUploadException(
        REPORT_FILE_TOO_LARGE,
        `File exceeds maximum size of ${MAX_REPORT_SIZE_BYTES / 1024 / 1024} MB`,
      );
    }
    if (
      !ALLOWED_UPLOAD_CONTENT_TYPES.includes(
        file.mimetype as 'application/pdf' | 'image/jpeg' | 'image/png',
      )
    ) {
      throw new ReportUploadException(
        REPORT_FILE_TYPE_UNSUPPORTED,
        'Only PDF, JPG, and PNG files are supported',
      );
    }

    const normalizedFile = await this.normalizeReportInput(file);
    this.logger.log(
      JSON.stringify({
        action: 'REPORT_UPLOAD_NORMALIZED_SOURCE',
        trigger: 'upload',
        source: normalizedFile.source,
        inputMimetype: file.mimetype,
        normalizedMimetype: normalizedFile.mimetype,
        originalName: file.originalname ?? null,
      }),
    );
    const contentHash = this.computeContentHash(normalizedFile.buffer);
    const forceUploadAnyway = options?.duplicateAction === 'upload_anyway';

    // Duplicate check: best-effort per profile; concurrent uploads of same file can both pass (no locking).
    const existing = await this.reportRepo.findOne({
      where: {
        userId,
        profileId: activeProfileId,
        contentHash,
        deletedAt: IsNull(),
      },
    });

    if (!forceUploadAnyway) {
      if (existing) {
        throw new ReportDuplicateDetectedException({
          id: existing.id,
          originalFileName: existing.originalFileName,
          createdAt: existing.createdAt.toISOString(),
        });
      }
    }

    const reportId = randomUUID();
    const storageKey = `reports/${userId}/${activeProfileId}/${reportId}.pdf`;
    const originalFileName =
      normalizedFile.originalname?.trim() || 'report.pdf';

    await this.fileStorage.upload(
      storageKey,
      normalizedFile.buffer,
      normalizedFile.mimetype,
    );

    let { status, transcript, opendataloaderJson } =
      await this.parseReportBuffer(
        normalizedFile.buffer,
        'upload',
        reportId,
        normalizedFile.source,
      );

    let parsedFromJson = opendataloaderJson
      ? await this.extractLabValuesFromOdlJsonWithFallback({
          opendataloaderJson,
          reportId,
          trigger: 'upload',
          transcript,
        })
      : null;
    const transcriptLabValuesRaw = transcript
      ? this.toStructuredLabInputs(this.labExtractor.extract(transcript))
      : [];
    const transcriptLabValues = this.filterNoisyLabValues(transcriptLabValuesRaw);
    const jsonLabValues = this.filterNoisyLabValues(
      parsedFromJson?.extractedLabValues ?? [],
    );
    let labValues =
      normalizedFile.source === 'image' && jsonLabValues.length > 0
        ? jsonLabValues
        : this.selectBestLabValues(jsonLabValues, transcriptLabValues);
    labValues = this.deduplicateStructuredLabValues(labValues);

    const finalStatus = this.resolveParsedReportStatus(
      status,
      transcript,
      labValues,
    );
    let structuredReport =
      finalStatus === 'parsed'
        ? (parsedFromJson?.structuredReport ??
          this.buildStructuredReport(transcript, labValues))
        : null;
    if (finalStatus === 'parsed' && structuredReport) {
      structuredReport = this.withBestPatientDetails(structuredReport, transcript);
      structuredReport.sections = this.buildStructuredReport(
        null,
        labValues,
      ).sections;
    }
    if (finalStatus === 'parsed' && structuredReport) {
      this.logLabDetailsExtraction({
        trigger: 'upload',
        reportId,
        source:
          parsedFromJson && parsedFromJson.extractedLabValues.length > 0
            ? 'odl_json'
            : 'transcript',
        labDetails: structuredReport.labDetails,
      });
      if (normalizedFile.source === 'image') {
        this.logger.log(
          JSON.stringify({
            action: 'REPORT_IMAGE_OCR_MAPPED_RESULT_DEBUG',
            reportId,
            extractedLabValuesCount: labValues.length,
            extractedLabValues: labValues,
            structuredReport,
          }),
        );
      }
    }
    if (finalStatus === 'content_not_recognized') {
      try {
        await this.fileStorage.delete(storageKey);
      } catch (deleteErr) {
        this.logger.warn(
          redactSecrets(
            `Cleanup: failed to delete invalid report file ${storageKey}: ${deleteErr instanceof Error ? deleteErr.message : String(deleteErr)}`,
          ),
        );
      }
      throw new ReportUploadException(
        REPORT_CONTENT_NOT_RECOGNIZED,
        'Uploaded file is not a valid lab report and was not saved.',
      );
    }
    this.logger.log(
      JSON.stringify({
        action: 'REPORT_VALID_LAB_FILE_ACCEPTED',
        trigger: 'upload',
        reportId,
        userId,
        profileId: activeProfileId,
        fileName: originalFileName,
        status: finalStatus,
        extractedLabValues: labValues.length,
      }),
    );
    const persistedLabValues = finalStatus === 'parsed' ? labValues : [];

    const summary =
      finalStatus === 'parsed'
        ? await this.reportSummaryService.generateSummary(normalizedFile.buffer)
        : null;

    const entity = this.reportRepo.create({
      id: reportId,
      userId,
      profileId: activeProfileId,
      originalFileName,
      contentType: normalizedFile.mimetype,
      sizeBytes: normalizedFile.buffer.length,
      originalFileStorageKey: storageKey,
      status: finalStatus,
      summary,
      parsedTranscript: finalStatus === 'parsed' ? transcript : null,
      structuredReport:
        finalStatus === 'parsed'
          ? (structuredReport as Record<string, unknown> | null)
          : null,
      contentHash,
    });

    try {
      await this.reportRepo.save(entity);
    } catch (err) {
      try {
        await this.fileStorage.delete(storageKey);
      } catch (deleteErr) {
        this.logger.warn(
          redactSecrets(
            `Cleanup: failed to delete orphaned file ${storageKey}: ${deleteErr instanceof Error ? deleteErr.message : String(deleteErr)}`,
          ),
        );
      }
      throw err;
    }

    if (persistedLabValues.length > 0) {
      const labEntities = persistedLabValues.map((lv, i) =>
        this.reportLabValueRepo.create({
          reportId: entity.id,
          parameterName: lv.parameterName,
          value: lv.value,
          unit: lv.unit ?? null,
          sampleDate: lv.sampleDate ?? null,
          sortOrder: i,
        }),
      );
      await this.reportLabValueRepo.save(labEntities);
    }

    await this.recordAttempt(entity.id, 'initial_upload', entity.status);

    this.dispatchReportNotification({
      status: entity.status,
      userId,
      profileId: activeProfileId,
      correlationId,
    });

    if (forceUploadAnyway && existing) {
      this.logger.log(
        `Duplicate resolution: upload_anyway existingReportId=${existing.id} newReportId=${reportId}`,
      );
    }

    return {
      reportId,
      profileId: activeProfileId,
      fileName: entity.originalFileName,
      contentType: entity.contentType,
      sizeBytes: entity.sizeBytes,
      status: entity.status,
    };
  }

  private computeContentHash(buffer: Buffer): string {
    return createHash('sha256').update(buffer).digest('hex');
  }

  private async normalizeReportInput(file: {
    buffer: Buffer;
    originalname: string;
    mimetype: string;
    size: number;
  }): Promise<{
    buffer: Buffer;
    originalname: string;
    mimetype: 'application/pdf';
    size: number;
    source: ReportInputSource;
  }> {
    if (ALLOWED_CONTENT_TYPES.includes(file.mimetype as 'application/pdf')) {
      return {
        buffer: file.buffer,
        originalname: file.originalname,
        mimetype: 'application/pdf',
        size: file.size,
        source: 'pdf',
      };
    }
    if (
      ALLOWED_IMAGE_CONTENT_TYPES.includes(
        file.mimetype as 'image/jpeg' | 'image/png',
      )
    ) {
      const pdfBuffer = await this.imageToPdfService.convertSingleImageToPdf({
        buffer: file.buffer,
        mimetype: file.mimetype as 'image/jpeg' | 'image/png',
      });
      return {
        buffer: pdfBuffer,
        originalname: this.toPdfFileName(file.originalname),
        mimetype: 'application/pdf',
        size: pdfBuffer.length,
        source: 'image',
      };
    }
    throw new ReportUploadException(
      REPORT_FILE_TYPE_UNSUPPORTED,
      'Only PDF, JPG, and PNG files are supported',
    );
  }

  private toPdfFileName(originalName: string): string {
    const trimmed = originalName?.trim() || 'report';
    return trimmed.replace(/\.[^.]+$/, '') + '.pdf';
  }

  async getReportFile(
    userId: string,
    reportId: string,
  ): Promise<{
    buffer: Buffer;
    contentType: string;
    originalFileName: string;
  }> {
    const entity = await this.getActiveReportOrThrow(userId, reportId);
    try {
      const buffer = await this.fileStorage.get(entity.originalFileStorageKey);
      return {
        buffer,
        contentType: entity.contentType,
        originalFileName: entity.originalFileName,
      };
    } catch (err) {
      this.logger.warn(
        redactSecrets(
          `Report file unavailable in storage: ${err instanceof Error ? err.message : String(err)}`,
        ),
      );
      throw new ReportFileUnavailableException();
    }
  }

  async getReport(userId: string, reportId: string): Promise<ReportDto> {
    const entity = await this.getActiveReportOrThrow(userId, reportId);
    const labValues = await this.reportLabValueRepo.find({
      where: { reportId },
      order: { sortOrder: 'ASC', parameterName: 'ASC' },
    });
    const profileInfoById = await this.getProfileInfoMap(userId);
    return this.withProfileInfo(
      this.toDto(entity, labValues, true, true),
      profileInfoById,
    );
  }

  /** List reports for a profile. Validates user owns the profile (throws if not). */
  async listReportsByProfile(
    userId: string,
    profileId: string,
  ): Promise<ReportDto[]> {
    await this.profilesService.getProfile(userId, profileId);
    const profileInfoById = await this.getProfileInfoMap(userId);
    const entities = await this.reportRepo.find({
      where: { profileId, userId, deletedAt: IsNull() },
      order: { createdAt: 'DESC' },
    });
    return entities.map((e) =>
      this.withProfileInfo(this.toDto(e), profileInfoById),
    );
  }

  /**
   * List reports: if profileId provided, use it (validates ownership); otherwise use active profile.
   */
  async listReports(
    userId: string,
    profileId?: string,
    scope: 'active' | 'all' = 'active',
  ): Promise<ReportDto[]> {
    if (scope === 'all') {
      const profileInfoById = await this.getProfileInfoMap(userId);
      const entities = await this.reportRepo.find({
        where: { userId, deletedAt: IsNull() },
        order: { createdAt: 'DESC' },
      });
      return entities.map((e) =>
        this.withProfileInfo(this.toDto(e), profileInfoById),
      );
    }

    const resolved =
      profileId ??
      (await this.profilesService.getActiveProfileId(userId)) ??
      null;
    if (!resolved) {
      throw new ReportUploadException(
        REPORT_NO_ACTIVE_PROFILE,
        'No active profile. Provide profileId or set an active profile.',
      );
    }
    return this.listReportsByProfile(userId, resolved);
  }

  /**
   * Aggregate lab trend data for a profile.
   * Only numeric values (parseFloat, exclude NaN) are included.
   * Date = sampleDate when present, else report createdAt (YYYY-MM-DD).
   * Note: values like ">10" parse as NaN and are excluded.
   */
  async getLabTrends(
    userId: string,
    profileId: string,
    parameterName?: string,
  ): Promise<LabTrendsResult> {
    // Validates user owns profile (throws ProfileNotFoundException if not)
    await this.profilesService.getProfile(userId, profileId);

    // First get report IDs for this profile (profile ownership already validated above)
    const reports = await this.reportRepo.find({
      where: { profileId, userId, deletedAt: IsNull() },
      select: ['id', 'createdAt'],
    });

    if (reports.length === 0) {
      return { parameters: [] };
    }

    const reportIds = reports.map((r) => r.id);
    const reportCreatedAtMap = new Map<string, Date>(
      reports.map((r) => [r.id, r.createdAt]),
    );

    // Build query for lab values belonging to these reports
    const qb = this.reportLabValueRepo
      .createQueryBuilder('lv')
      .where('lv.report_id IN (:...reportIds)', { reportIds });

    if (parameterName) {
      qb.andWhere('lv.parameter_name = :parameterName', { parameterName });
    }

    qb.orderBy('lv.sample_date', 'ASC', 'NULLS LAST');

    const labValues = await qb.getMany();

    // Attach report createdAt for date fallback (not loaded via relation)
    const labValuesWithCreatedAt = labValues.map((lv) => ({
      ...lv,
      reportCreatedAt: reportCreatedAtMap.get(lv.reportId) ?? new Date(),
    }));

    // Group by parameterName
    const grouped = new Map<
      string,
      { unit: string | null; dataPoints: TrendDataPoint[] }
    >();

    for (const lv of labValuesWithCreatedAt) {
      const numericValue = parseFloat(lv.value);
      if (isNaN(numericValue)) continue;

      // Date: sampleDate when present, else report createdAt (YYYY-MM-DD)
      const date = lv.sampleDate
        ? lv.sampleDate
        : lv.reportCreatedAt.toISOString().slice(0, 10);

      if (!grouped.has(lv.parameterName)) {
        grouped.set(lv.parameterName, {
          unit: lv.unit ?? null,
          dataPoints: [],
        });
      }
      const entry = grouped.get(lv.parameterName)!;
      // Use first non-null unit found
      if (entry.unit === null && lv.unit) {
        entry.unit = lv.unit;
      }
      entry.dataPoints.push({ date, value: numericValue });
    }

    const parameters: TrendParameter[] = [];
    for (const [name, data] of grouped.entries()) {
      if (data.dataPoints.length === 0) continue;
      // Sort data points chronologically
      data.dataPoints.sort((a, b) => a.date.localeCompare(b.date));
      const param: TrendParameter = {
        parameterName: name,
        dataPoints: data.dataPoints,
      };
      if (data.unit) param.unit = data.unit;
      parameters.push(param);
    }

    return { parameters };
  }

  async retryParse(
    userId: string,
    reportId: string,
    options?: { force?: boolean },
    correlationId?: string,
  ): Promise<ReportDto> {
    const entity = await this.getActiveReportOrThrow(userId, reportId);
    const force = options?.force === true;
    if (!force) {
      this.throwIfAlreadyParsed(entity.status);
    }

    const buffer = await this.fileStorage.get(entity.originalFileStorageKey);

    const { status, transcript, opendataloaderJson } =
      await this.parseReportBuffer(buffer, 'retry', entity.id);

    const retryFromJson = opendataloaderJson
      ? await this.extractLabValuesFromOdlJsonWithFallback({
          opendataloaderJson,
          reportId: entity.id,
          trigger: 'retry',
          transcript,
        })
      : null;
    const retryTranscriptValuesRaw = transcript
      ? this.toStructuredLabInputs(this.labExtractor.extract(transcript))
      : [];
    const retryTranscriptValues = this.filterNoisyLabValues(
      retryTranscriptValuesRaw,
    );
    const retryJsonValues = this.filterNoisyLabValues(
      retryFromJson?.extractedLabValues ?? [],
    );
    const retryLabValues =
      status === 'parsed'
        ? this.selectBestLabValues(retryJsonValues, retryTranscriptValues)
        : [];
    const dedupedRetryLabValues =
      status === 'parsed'
        ? this.deduplicateStructuredLabValues(retryLabValues)
        : [];
    const finalStatus = this.resolveParsedReportStatus(
      status,
      transcript,
      dedupedRetryLabValues,
    );
    if (finalStatus === 'parsed') {
      this.logger.log(
        JSON.stringify({
          action: 'REPORT_VALID_LAB_FILE_ACCEPTED',
          trigger: 'retry',
          reportId: entity.id,
          userId,
          profileId: entity.profileId,
          fileName: entity.originalFileName,
          status: finalStatus,
          extractedLabValues: retryLabValues.length,
        }),
      );
    }
    const persistedRetryLabValues =
      finalStatus === 'parsed' ? dedupedRetryLabValues : [];

    entity.status = finalStatus;
    entity.summary =
      finalStatus === 'parsed'
        ? await this.reportSummaryService.generateSummary(buffer)
        : null;
    // Only overwrite transcript on success; preserve existing on failure (AC3)
    if (finalStatus === 'parsed') {
      let retryStructuredReport =
        retryFromJson?.structuredReport ??
        this.buildStructuredReport(transcript, dedupedRetryLabValues);
      retryStructuredReport = this.withBestPatientDetails(
        retryStructuredReport,
        transcript,
      );
      retryStructuredReport.sections = this.buildStructuredReport(
        null,
        dedupedRetryLabValues,
      ).sections;
      this.logLabDetailsExtraction({
        trigger: 'retry',
        reportId: entity.id,
        source: retryFromJson ? 'odl_json' : 'transcript',
        labDetails: retryStructuredReport.labDetails,
      });
      entity.parsedTranscript = transcript;
      entity.structuredReport = JSON.parse(
        JSON.stringify(retryStructuredReport),
      ) as unknown as Record<string, unknown>;
    }
    await this.reportRepo.save(entity);

    // Replace previous extracted values on successful parse to avoid duplicated rows
    // when users intentionally reprocess the same report.
    await this.reportLabValueRepo.delete({ reportId: entity.id });

    if (persistedRetryLabValues.length > 0) {
      const labEntities = persistedRetryLabValues.map((lv, i) =>
        this.reportLabValueRepo.create({
          reportId: entity.id,
          parameterName: lv.parameterName,
          value: lv.value,
          unit: lv.unit ?? null,
          sampleDate: lv.sampleDate ?? null,
          sortOrder: i,
        }),
      );
      await this.reportLabValueRepo.save(labEntities);
    }

    await this.recordAttempt(entity.id, 'retry', entity.status);

    this.dispatchReportNotification({
      status: entity.status,
      userId,
      profileId: entity.profileId,
      correlationId,
    });

    const refreshedLabValues = await this.reportLabValueRepo.find({
      where: { reportId: entity.id },
      order: { sortOrder: 'ASC', parameterName: 'ASC' },
    });
    return this.toDto(entity, refreshedLabValues, true, true);
  }

  private resolveParsedReportStatus(
    initialStatus: ReportStatus,
    transcript: string | null,
    labValues: StructuredReportLabInput[],
  ): ReportStatus {
    if (initialStatus !== 'parsed') {
      // Additive fallback for image/scanned uploads:
      // if deterministic extraction produced enough lab rows, treat as parsed
      // even when OCR transcript quality is low.
      if (labValues.length >= 2) return 'parsed';
      return initialStatus;
    }
    if (this.isLikelyLabReport(transcript, labValues)) return 'parsed';
    return 'content_not_recognized';
  }

  private isLikelyLabReport(
    transcript: string | null,
    labValues: StructuredReportLabInput[],
  ): boolean {
    if (labValues.length >= 2) return true;
    if (!transcript) return false;

    const text = transcript.toLowerCase();
    const signals = [
      /\b(hemoglobin|haemoglobin|hba1c)\b/,
      /\b(wbc|rbc|platelet|esr|pcv|mcv|mch|mchc)\b/,
      /\b(glucose|creatinine|urea|uric acid|bilirubin|albumin|globulin)\b/,
      /\b(cholesterol|triglycerides|hdl|ldl|vldl)\b/,
      /\b(tsh|t3|t4|ft3|ft4)\b/,
      /\b(reference range|normal range|test name|result|unit)\b/,
      /\b(cbc|lft|kft|lipid profile|thyroid profile|urine routine)\b/,
    ];
    const hitCount = signals.reduce(
      (count, re) => count + (re.test(text) ? 1 : 0),
      0,
    );

    return hitCount >= 2 && labValues.length >= 1;
  }

  private evaluateParsedTranscript(text: string | null | undefined): {
    ok: boolean;
    text: string | null;
  } {
    const cleaned = this.sanitizeParsedTranscript(text);
    if (!cleaned) return { ok: false, text: null };
    if (cleaned.length < ReportsService.MIN_PARSE_TEXT_LENGTH) {
      return { ok: false, text: cleaned };
    }
    const alphaCount = (cleaned.match(/[A-Za-z]/g) ?? []).length;
    if (alphaCount < 30) {
      return { ok: false, text: cleaned };
    }
    return { ok: true, text: cleaned };
  }

  private async parseReportBuffer(
    buffer: Buffer,
    trigger: 'upload' | 'retry',
    reportId: string,
    source: ReportInputSource = 'pdf',
  ): Promise<ParsedBufferResult> {
    if (source === 'image') {
      const doclingAttempt = await this.doclingOcrClient.parsePdf(buffer, {
        forceOcr: true,
      });
      const bestEval = this.evaluateParsedTranscript(doclingAttempt?.text);
      const status = bestEval.ok ? 'parsed' : 'failed_transient';
      this.logParseQuality(trigger, reportId, bestEval.text, status);
      return {
        status,
        transcript: bestEval.text,
        ...(doclingAttempt?.parsedJson
          ? { opendataloaderJson: doclingAttempt.parsedJson }
          : {}),
      };
    }

    const firstAttempt = await this.openDataLoaderClient.parsePdf(buffer);
    const firstEval = this.evaluateParsedTranscript(firstAttempt?.text);
    if (firstEval.ok) {
      const status = 'parsed';
      this.logParseQuality(trigger, reportId, firstEval.text, status);
      return {
        status,
        transcript: firstEval.text,
        ...(firstAttempt?.parsedJson
          ? { opendataloaderJson: firstAttempt.parsedJson }
          : {}),
      };
    }

    // Fallback for scanned/image-only PDFs:
    // when ODL text is too weak, run Docling OCR to recover transcript + JSON.
    const doclingAttempt = await this.doclingOcrClient.parsePdf(buffer, {
      forceOcr: true,
    });
    const doclingEval = this.evaluateParsedTranscript(doclingAttempt?.text);
    if (doclingAttempt) {
      this.logger.log(
        JSON.stringify({
          action: 'REPORT_DOCLING_PDF_FALLBACK_ATTEMPT',
          trigger,
          reportId,
          odlTranscriptChars: firstEval.text?.length ?? 0,
          doclingTranscriptChars: doclingEval.text?.length ?? 0,
          doclingHasJson: Boolean(doclingAttempt.parsedJson),
          selected: doclingEval.ok ? 'docling' : 'odl',
        }),
      );
    }
    if (doclingEval.ok || doclingAttempt?.parsedJson) {
      const status = doclingEval.ok ? 'parsed' : 'failed_transient';
      this.logParseQuality(trigger, reportId, doclingEval.text, status);
      return {
        status,
        transcript: doclingEval.text,
        ...(doclingAttempt?.parsedJson
          ? { opendataloaderJson: doclingAttempt.parsedJson }
          : {}),
      };
    }

    const status = 'failed_transient';
    this.logParseQuality(trigger, reportId, firstEval.text, status);
    return {
      status,
      transcript: firstEval.text,
      ...(firstAttempt?.parsedJson
        ? { opendataloaderJson: firstAttempt.parsedJson }
        : {}),
    };
  }

  private async extractLabValuesFromOdlJsonWithFallback(input: {
    opendataloaderJson: unknown;
    reportId: string;
    trigger: 'upload' | 'retry';
    transcript: string | null;
  }): Promise<SelectedOdlLabOutput> {
    const deterministic = this.odlJsonParser.parseWithDiagnostics(
      input.opendataloaderJson,
    );
    let extractedLabValues = this.toStructuredLabInputs(
      deterministic.extractedLabValues,
    );
    let structuredReport = deterministic.structuredReport;
    if (extractedLabValues.length >= 10) {
      this.logger.log(
        JSON.stringify({
          action: 'REPORT_LAB_AI_FALLBACK_DECISION',
          reportId: input.reportId,
          trigger: input.trigger,
          deterministicConfidence: deterministic.diagnostics.confidence,
          deterministicRows: extractedLabValues.length,
          aiRows: 0,
          aiFallbackUsed: false,
          selectedSource: 'deterministic_json',
          reason: 'sufficient_deterministic_rows',
        }),
      );
      return { extractedLabValues, structuredReport };
    }
    const transcriptCandidates = this.extractAiFallbackCandidatesFromTranscript(
      input.transcript,
    );
    const candidateRows = Array.from(
      new Set([
        ...deterministic.diagnostics.aiCandidateRows,
        ...transcriptCandidates,
      ]),
    ).slice(0, 400);

    const aiFallback = await this.reportLabAiFallbackService.tryExtract({
      reportId: input.reportId,
      trigger: input.trigger,
      confidence: deterministic.diagnostics.confidence,
      lowConfidenceReasons: deterministic.diagnostics.lowConfidenceReasons,
      candidateRows,
    });

    if (!aiFallback) {
      this.logger.log(
        JSON.stringify({
          action: 'REPORT_LAB_AI_FALLBACK_DECISION',
          reportId: input.reportId,
          trigger: input.trigger,
          deterministicConfidence: deterministic.diagnostics.confidence,
          deterministicRows: extractedLabValues.length,
          aiRows: 0,
          aiFallbackUsed: false,
          selectedSource: 'deterministic_json',
        }),
      );
      return { extractedLabValues, structuredReport };
    }

    const aiValues = this.toStructuredLabInputs(aiFallback.extractedLabValues);
    const shouldUseAi = this.shouldUseAiFallbackResult(
      extractedLabValues,
      aiValues,
      deterministic,
    );

    this.logger.log(
      JSON.stringify({
        action: 'REPORT_LAB_AI_FALLBACK_DECISION',
        reportId: input.reportId,
        trigger: input.trigger,
        deterministicConfidence: deterministic.diagnostics.confidence,
        deterministicRows: extractedLabValues.length,
        aiRows: aiValues.length,
        aiFallbackUsed: shouldUseAi,
        selectedSource: shouldUseAi ? 'ai_fallback' : 'deterministic_json',
      }),
    );

    if (!shouldUseAi) {
      return { extractedLabValues, structuredReport };
    }

    extractedLabValues = aiValues;
    structuredReport = {
      patientDetails: deterministic.structuredReport.patientDetails,
      ...(deterministic.structuredReport.labDetails
        ? { labDetails: deterministic.structuredReport.labDetails }
        : {}),
      sections: this.buildStructuredReport(null, aiValues).sections,
    };
    return { extractedLabValues, structuredReport };
  }

  private toStructuredLabInputs(
    values: Array<{
      parameterName: string;
      value: string;
      unit?: string | null;
      sampleDate?: string | null;
      referenceRange?: string | null;
      isAbnormal?: boolean | null;
    }>,
  ): StructuredReportLabInput[] {
    const out: StructuredReportLabInput[] = [];
    for (const value of values) {
      const parameterName = value.parameterName?.trim();
      const parsedValue = value.value?.trim();
      if (!parameterName || !parsedValue) continue;
      if (this.isLikelyNoiseLabRow(parameterName, parsedValue, value.unit)) {
        continue;
      }
      const referenceRange = value.referenceRange?.trim() || null;
      const inferredAbnormal = this.evaluateAbnormalFromReference(
        parsedValue,
        referenceRange,
      );
      out.push({
        parameterName,
        value: parsedValue,
        unit: value.unit?.trim() || null,
        sampleDate: value.sampleDate?.trim() || null,
        referenceRange,
        isAbnormal:
          typeof value.isAbnormal === 'boolean'
            ? value.isAbnormal
            : inferredAbnormal,
      });
    }
    return out;
  }

  private evaluateAbnormalFromReference(
    rawValue: string,
    referenceRange: string | null,
  ): boolean | null {
    if (!referenceRange) return null;

    const valueNum = this.tryParseNumeric(rawValue);
    const ref = referenceRange.trim();
    const refLower = ref.toLowerCase();

    const qual =
      /^(negative|positive|nil|normal|absent|present|clear|cloudy|turbid|trace|pale yellow|yellow|amber|straw)$/i;
    if (qual.test(refLower)) {
      const v = rawValue.trim().toLowerCase();
      if (!qual.test(v)) return null;
      return v !== refLower;
    }

    if (valueNum === null) return null;

    const between = ref.match(
      /^\s*(-?\d+(?:\.\d+)?)\s*[-–]\s*(-?\d+(?:\.\d+)?)\s*$/,
    );
    if (between) {
      const low = Number(between[1]);
      const high = Number(between[2]);
      if (!Number.isFinite(low) || !Number.isFinite(high)) return null;
      return valueNum < Math.min(low, high) || valueNum > Math.max(low, high);
    }

    const lt = ref.match(/^\s*<\s*(-?\d+(?:\.\d+)?)\s*$/);
    if (lt) return valueNum >= Number(lt[1]);
    const lte = ref.match(/^\s*<=\s*(-?\d+(?:\.\d+)?)\s*$/);
    if (lte) return valueNum > Number(lte[1]);
    const gt = ref.match(/^\s*>\s*(-?\d+(?:\.\d+)?)\s*$/);
    if (gt) return valueNum <= Number(gt[1]);
    const gte = ref.match(/^\s*>=\s*(-?\d+(?:\.\d+)?)\s*$/);
    if (gte) return valueNum < Number(gte[1]);

    return null;
  }

  private tryParseNumeric(raw: string): number | null {
    const cleaned = raw
      .replace(/^[<>]=?\s*/, '')
      .replace(/,/g, '')
      .trim();
    if (!/^-?\d+(?:\.\d+)?$/.test(cleaned)) return null;
    const n = Number(cleaned);
    return Number.isFinite(n) ? n : null;
  }

  private labRowKey(
    parameterName: string,
    value: string,
    unit: string | null,
  ): string | null {
    const p = parameterName?.trim();
    const v = value?.trim();
    if (!p || !v) return null;
    return `${p.toLowerCase()}::${v.toLowerCase()}::${(unit ?? '').trim().toLowerCase()}`;
  }

  private normalizeComparableValue(value: string): string {
    const trimmed = value.trim();
    const numeric = trimmed.replace(/,/g, '');
    if (/^[<>]?\s*[-+]?\d+(?:\.\d+)?$/.test(numeric)) {
      const num = Number(numeric.replace(/^[<>]\s*/, ''));
      if (Number.isFinite(num)) return String(num);
    }
    return trimmed.toLowerCase();
  }

  private isLikelyNoiseLabRow(
    parameterName: string,
    value: string,
    unit: string | null | undefined,
  ): boolean {
    const p = parameterName.toLowerCase().trim();
    const u = (unit ?? '').toLowerCase().trim();
    const v = value.toLowerCase().trim();
    if (
      p.includes('#/texts/') ||
      p.includes('#/groups/') ||
      p.includes('#/body') ||
      p.includes('topleft') ||
      p.includes('bottomleft') ||
      p.includes('doclingdocument') ||
      p.startsWith('body ') ||
      p.startsWith('report.pdf')
    ) {
      return true;
    }
    if (
      u === 'topleft' ||
      u === 'bottomleft' ||
      u.startsWith('#/') ||
      u === '.' ||
      u === '.0'
    ) {
      return true;
    }
    if (/^\d+\.$/.test(v)) return true;
    return false;
  }

  private filterNoisyLabValues(
    values: StructuredReportLabInput[],
  ): StructuredReportLabInput[] {
    return values.filter(
      (row) =>
        !this.isLikelyNoiseLabRow(row.parameterName, row.value, row.unit),
    );
  }

  private deduplicateStructuredLabValues(
    rows: StructuredReportLabInput[],
  ): StructuredReportLabInput[] {
    const bestByKey = new Map<string, StructuredReportLabInput>();
    for (const row of rows) {
      const name = row.parameterName?.trim().toLowerCase();
      const unit = (row.unit ?? '').trim().toLowerCase();
      const value = this.normalizeComparableValue(row.value ?? '');
      if (!name || !value) continue;
      const key = `${name}::${value}::${unit}`;
      const current = bestByKey.get(key);
      if (!current) {
        bestByKey.set(key, row);
        continue;
      }
      const currentScore =
        (current.referenceRange ? 1 : 0) +
        (current.sampleDate ? 1 : 0) +
        (typeof current.isAbnormal === 'boolean' ? 1 : 0);
      const nextScore =
        (row.referenceRange ? 1 : 0) +
        (row.sampleDate ? 1 : 0) +
        (typeof row.isAbnormal === 'boolean' ? 1 : 0);
      if (nextScore > currentScore) {
        bestByKey.set(key, row);
      }
    }
    return Array.from(bestByKey.values());
  }

  private selectBestLabValues(
    parsedValues: StructuredReportLabInput[],
    transcriptValues: StructuredReportLabInput[],
  ): StructuredReportLabInput[] {
    if (parsedValues.length === 0) return transcriptValues;
    if (transcriptValues.length === 0) return parsedValues;

    const parsedScore = this.scoreLabExtractionQuality(parsedValues);
    const transcriptScore = this.scoreLabExtractionQuality(transcriptValues);
    const preferred =
      transcriptValues.length >= parsedValues.length + 3 ||
      transcriptScore > parsedScore * 1.05
        ? transcriptValues
        : parsedValues;

    // Merge both sets to avoid dropping valid rows when one source is partial.
    const merged: StructuredReportLabInput[] = [];
    const seen = new Set<string>();
    for (const row of [...preferred, ...parsedValues, ...transcriptValues]) {
      const key = this.labRowKey(row.parameterName, row.value, row.unit);
      if (!key || seen.has(key)) continue;
      seen.add(key);
      merged.push(row);
    }
    return merged;
  }

  private withBestPatientDetails(
    structuredReport: StructuredReportDto,
    transcript: string | null,
  ): StructuredReportDto {
    const fromTranscript = this.extractPatientDetails(transcript);
    const baseRaw = structuredReport.patientDetails ?? {};
    const base: StructuredPatientDetailsDto = {
      ...(baseRaw.name && !baseRaw.name.startsWith('#/')
        ? { name: baseRaw.name }
        : {}),
      ...(baseRaw.age && !baseRaw.age.startsWith('#/')
        ? { age: baseRaw.age }
        : {}),
      ...(baseRaw.gender && !baseRaw.gender.startsWith('#/')
        ? { gender: baseRaw.gender }
        : {}),
      ...(baseRaw.bookingId && !baseRaw.bookingId.startsWith('#/')
        ? { bookingId: baseRaw.bookingId }
        : {}),
      ...(baseRaw.sampleCollectionDate &&
      !baseRaw.sampleCollectionDate.startsWith('#/')
        ? { sampleCollectionDate: baseRaw.sampleCollectionDate }
        : {}),
    };
    return {
      ...structuredReport,
      patientDetails: {
        ...base,
        ...(fromTranscript.name ? { name: fromTranscript.name } : {}),
        ...(fromTranscript.age ? { age: fromTranscript.age } : {}),
        ...(fromTranscript.gender ? { gender: fromTranscript.gender } : {}),
        ...(fromTranscript.bookingId
          ? { bookingId: fromTranscript.bookingId }
          : {}),
        ...(fromTranscript.sampleCollectionDate
          ? { sampleCollectionDate: fromTranscript.sampleCollectionDate }
          : {}),
      },
    };
  }

  private shouldUseAiFallbackResult(
    deterministic: StructuredReportLabInput[],
    aiFallback: StructuredReportLabInput[],
    parserResult: OpenDataLoaderParsedWithDiagnosticsOutput,
  ): boolean {
    if (aiFallback.length === 0) return false;
    if (deterministic.length === 0) return true;

    const baseScore = this.scoreLabExtractionQuality(deterministic);
    const aiScore = this.scoreLabExtractionQuality(aiFallback);

    if (aiScore > baseScore * 1.03) return true;
    if (
      parserResult.diagnostics.confidence < 0.55 &&
      aiScore >= baseScore * 0.95 &&
      aiFallback.length >= Math.max(8, Math.floor(deterministic.length * 0.8))
    ) {
      return true;
    }
    return false;
  }

  private scoreLabExtractionQuality(
    values: StructuredReportLabInput[],
  ): number {
    if (values.length === 0) return 0;
    const distinctNames = new Set<string>();
    let score = 0;

    for (const value of values) {
      const name = value.parameterName.trim();
      const normalizedName = name.toLowerCase();
      const parsedValue = value.value.trim();
      distinctNames.add(normalizedName);

      if (this.isLikelyLabName(name)) score += 1.2;
      else score -= 0.8;

      if (/^[<>]?\s*[-+]?\d[\d,]*(?:\.\d+)?$/.test(parsedValue)) {
        score += 1;
      } else if (
        /^(negative|positive|nil|normal|absent|present|clear|cloudy|turbid|trace|pale yellow|yellow|amber|straw)$/i.test(
          parsedValue,
        )
      ) {
        score += 0.7;
      } else {
        score -= 0.6;
      }

      if (value.unit && value.unit.length <= 24) score += 0.2;
    }

    score += distinctNames.size * 0.3;
    return score;
  }

  private isLikelyLabName(name: string): boolean {
    if (!name || name.length > 100) return false;
    const n = name.toLowerCase();
    if (
      /\b(patient|booking|order id|sample|report|summary|suggestion|page \d|sin no|barcode|method|reference|department)\b/.test(
        n,
      )
    ) {
      return false;
    }
    return /[a-z]/i.test(name);
  }

  private sanitizeParsedTranscript(text: string | null | undefined): string {
    if (!text) return '';
    let cleaned = text;
    // Remove markdown image tags (common in parser output for scanned PDFs)
    cleaned = cleaned.replace(/!\[[^\]]*]\([^)\n]*\)/g, ' ');
    // Remove inline data URIs if any survived markdown stripping
    cleaned = cleaned.replace(
      /data:image\/[a-zA-Z+]+;base64,[A-Za-z0-9+/=\s]+/g,
      ' ',
    );
    // Remove long base64-like blobs and long opaque tokens
    cleaned = cleaned.replace(/[A-Za-z0-9+/=]{200,}/g, ' ');
    // Normalize whitespace
    cleaned = cleaned
      .replace(/\r\n/g, '\n')
      .replace(/[ \t]+/g, ' ')
      .trim();
    return cleaned;
  }

  private extractAiFallbackCandidatesFromTranscript(
    transcript: string | null,
  ): string[] {
    if (!transcript) return [];
    const lines = transcript
      .split('\n')
      .map((line) => line.replace(/\s+/g, ' ').trim())
      .filter((line) => line.length >= 3 && line.length <= 140);
    const out: string[] = [];
    const seen = new Set<string>();
    for (const line of lines) {
      const l = line.toLowerCase();
      if (
        /\b(patient|name|age\/gender|mobile|phone|address|email|booking id|order id|barcode|referred by|sample collected on|sample received on|report generated on|customer since|sin no|page \d+ of \d+)\b/.test(
          l,
        )
      ) {
        continue;
      }
      const looksLikeValueLine =
        /^[A-Za-z][A-Za-z0-9\s(),/%._-]{1,80}\s+[<>]?\s*[-+]?\d[\d,]*(?:\.\d+)?(?:\s+[A-Za-z/%._-]{1,24})?/i.test(
          line,
        ) ||
        /^[A-Za-z][A-Za-z0-9\s(),/%._-]{1,80}\s+(Negative|Positive|Nil|Normal|Absent|Present|Clear|Cloudy|Turbid|Trace)\b/i.test(
          line,
        ) ||
        /\b(reference range|test name|result|unit|hemoglobin|haemoglobin|wbc|rbc|platelet|creatinine|bilirubin|cholesterol|triglycerides|hdl|ldl|tsh|t3|t4)\b/i.test(
          line,
        );
      if (!looksLikeValueLine) continue;
      const key = line.toLowerCase();
      if (seen.has(key)) continue;
      seen.add(key);
      out.push(line);
      if (out.length >= 400) break;
    }
    return out;
  }

  private logParseQuality(
    trigger: 'upload' | 'retry',
    reportId: string,
    transcript: string | null,
    status: ReportStatus,
  ): void {
    const text = transcript ?? '';
    const preview = text.slice(0, 180).replace(/\s+/g, ' ');
    const alphaCount = (text.match(/[A-Za-z]/g) ?? []).length;
    const ocrText = text.slice(0, OCR_TEXT_LOG_CHAR_LIMIT);
    this.logger.log(
      JSON.stringify({
        action: 'REPORT_PARSE_RESULT',
        trigger,
        reportId,
        status,
        transcriptChars: text.length,
        transcriptAlphaChars: alphaCount,
        preview,
        ocrText,
        ocrTextTruncated: text.length > OCR_TEXT_LOG_CHAR_LIMIT,
      }),
    );
  }

  private dispatchReportNotification(input: {
    status: ReportStatus;
    userId: string;
    profileId: string;
    correlationId?: string;
  }): void {
    // Only dispatch for terminal parse outcomes — 'parsed' (success) or failure statuses.
    // In-flight statuses ('uploading', 'queued', 'parsing') have not completed parsing yet;
    // firing REPORT_PARSE_FAILED for them would be premature and incorrect.
    const isParsed = input.status === 'parsed';
    const isFailed =
      input.status === 'failed_transient' || input.status === 'failed_terminal';
    if (!isParsed && !isFailed) return;

    const correlationId = input.correlationId ?? randomUUID();
    const eventType = isParsed
      ? NotifiableEventType.REPORT_UPLOAD_COMPLETE
      : NotifiableEventType.REPORT_PARSE_FAILED;

    void this.notificationPipeline
      .dispatch({
        eventType,
        userId: input.userId,
        profileId: input.profileId,
        correlationId,
      })
      .catch((err) => {
        this.logger.warn(
          JSON.stringify({
            action: 'NOTIFICATION_DISPATCH_FAILED',
            eventType,
            correlationId,
            error: err instanceof Error ? err.message : String(err),
          }),
        );
      });
  }

  private async recordAttempt(
    reportId: string,
    trigger: AttemptTrigger,
    outcome: string,
  ): Promise<void> {
    const attempt = this.attemptRepo.create({
      reportId,
      trigger,
      outcome,
      attemptedAt: new Date(),
    });
    await this.attemptRepo.save(attempt);
  }

  async getProcessingAttempts(
    userId: string,
    reportId: string,
  ): Promise<ProcessingAttemptDto[]> {
    const report = await this.getActiveReportOrThrow(userId, reportId);
    const attempts = await this.attemptRepo.find({
      where: { reportId },
      order: { attemptedAt: 'DESC' },
    });
    return attempts.map((a) => ({
      id: a.id,
      trigger: a.trigger,
      outcome: a.outcome,
      attemptedAt: a.attemptedAt.toISOString(),
    }));
  }

  async reassignReport(
    userId: string,
    reportId: string,
    targetProfileId: string,
  ): Promise<ReportDto> {
    if (!isUUID(targetProfileId)) {
      throw new BadRequestException({
        code: 'TARGET_PROFILE_ID_INVALID',
        message: 'targetProfileId must be a valid UUID.',
      });
    }
    const entity = await this.getActiveReportOrThrow(userId, reportId);
    // Validates user owns targetProfileId (throws ProfileNotFoundException → 404 if not)
    await this.profilesService.getProfile(userId, targetProfileId);
    if (entity.profileId === targetProfileId) {
      throw new BadRequestException({
        code: 'REPORT_ALREADY_IN_PROFILE',
        message: 'Report is already in the specified profile.',
      });
    }
    entity.profileId = targetProfileId;
    await this.reportRepo.save(entity);
    const profileInfoById = await this.getProfileInfoMap(userId);
    return this.withProfileInfo(this.toDto(entity), profileInfoById);
  }

  async keepFile(userId: string, reportId: string): Promise<ReportDto> {
    const entity = await this.getActiveReportOrThrow(userId, reportId);
    this.throwIfAlreadyParsed(entity.status);
    // Sets to unparsed so user sees "View PDF"; applies to unparsed and content_not_recognized
    entity.status = 'unparsed';
    entity.summary = null;
    entity.parsedTranscript = null;
    entity.structuredReport = null;
    await this.reportRepo.save(entity);
    const profileInfoById = await this.getProfileInfoMap(userId);
    return this.withProfileInfo(this.toDto(entity), profileInfoById);
  }

  async moveToRecycleBin(userId: string, reportId: string): Promise<ReportDto> {
    const entity = await this.getActiveReportOrThrow(userId, reportId);
    const now = new Date();
    const purgeAfterAt = new Date(now);
    purgeAfterAt.setDate(
      purgeAfterAt.getDate() + ReportsService.RECYCLE_BIN_RETENTION_DAYS,
    );
    entity.deletedAt = now;
    entity.purgeAfterAt = purgeAfterAt;
    await this.reportRepo.save(entity);
    const profileInfoById = await this.getProfileInfoMap(userId);
    return this.withProfileInfo(this.toDto(entity), profileInfoById);
  }

  async listRecycleBin(
    userId: string,
    profileId?: string,
  ): Promise<ReportDto[]> {
    if (profileId) {
      await this.profilesService.getProfile(userId, profileId);
    }
    const profileInfoById = await this.getProfileInfoMap(userId);
    const entities = await this.reportRepo.find({
      where: {
        userId,
        ...(profileId ? { profileId } : {}),
        deletedAt: LessThanOrEqual(new Date()),
      },
      order: { deletedAt: 'DESC', createdAt: 'DESC' },
    });
    return entities.map((e) =>
      this.withProfileInfo(this.toDto(e), profileInfoById),
    );
  }

  async restoreFromRecycleBin(
    userId: string,
    reportId: string,
  ): Promise<ReportDto> {
    if (!isUUID(reportId)) throw new ReportNotFoundException();
    const entity = await this.reportRepo.findOne({
      where: { id: reportId, userId, deletedAt: LessThanOrEqual(new Date()) },
    });
    if (!entity) throw new ReportNotFoundException();
    entity.deletedAt = null;
    entity.purgeAfterAt = null;
    await this.reportRepo.save(entity);
    const profileInfoById = await this.getProfileInfoMap(userId);
    return this.withProfileInfo(this.toDto(entity), profileInfoById);
  }

  async purgeExpiredRecycleBinReports(): Promise<number> {
    const now = new Date();
    const expired = await this.reportRepo.find({
      where: {
        deletedAt: LessThanOrEqual(now),
        purgeAfterAt: LessThanOrEqual(now),
      },
      select: ['id', 'originalFileStorageKey'],
      order: { purgeAfterAt: 'ASC' },
      take: 500,
    });

    let deletedCount = 0;
    for (const report of expired) {
      try {
        await this.fileStorage.delete(report.originalFileStorageKey);
      } catch (err) {
        this.logger.warn(
          redactSecrets(
            `Recycle bin purge: failed to delete file key=${report.originalFileStorageKey}: ${err instanceof Error ? err.message : String(err)}`,
          ),
        );
      }
      await this.reportRepo.delete({ id: report.id });
      deletedCount += 1;
    }
    return deletedCount;
  }

  private toDto(
    e: ReportEntity,
    labValues: ReportLabValueEntity[] = [],
    includeTranscript = false,
    includeStructuredReport = false,
  ): ReportDto {
    const structuredReport = includeStructuredReport
      ? this.getStoredStructuredReport(e)
      : undefined;
    const rangeByKey = new Map<
      string,
      { referenceRange?: string; isAbnormal?: boolean }
    >();
    const rangeByName = new Map<
      string,
      { referenceRange?: string; isAbnormal?: boolean }
    >();
    if (structuredReport) {
      for (const section of structuredReport.sections) {
        for (const test of section.tests) {
          const key =
            this.labRowKey(test.parameterName, test.value, test.unit ?? null) ??
            null;
          if (!key) continue;
          const meta = {
            ...(test.referenceRange
              ? { referenceRange: test.referenceRange }
              : {}),
            ...(typeof test.isAbnormal === 'boolean'
              ? { isAbnormal: test.isAbnormal }
              : {}),
          };
          rangeByKey.set(key, meta);
          const byNameKey = test.parameterName.trim().toLowerCase();
          if (byNameKey && !rangeByName.has(byNameKey)) {
            rangeByName.set(byNameKey, meta);
          }
        }
      }
    }

    return {
      id: e.id,
      profileId: e.profileId,
      originalFileName: e.originalFileName,
      contentType: e.contentType,
      sizeBytes: e.sizeBytes,
      status: e.status,
      createdAt: e.createdAt.toISOString(),
      ...(e.deletedAt ? { deletedAt: e.deletedAt.toISOString() } : {}),
      ...(e.purgeAfterAt ? { purgeAfterAt: e.purgeAfterAt.toISOString() } : {}),
      ...(e.summary != null && { summary: e.summary }),
      ...(includeTranscript &&
        e.parsedTranscript != null && { parsedTranscript: e.parsedTranscript }),
      extractedLabValues: labValues.map((lv) => {
        const key =
          this.labRowKey(lv.parameterName, lv.value, lv.unit ?? null) ?? '';
        const meta =
          rangeByKey.get(key) ??
          rangeByName.get(lv.parameterName.trim().toLowerCase());
        return {
          parameterName: lv.parameterName,
          value: lv.value,
          ...(lv.unit != null && lv.unit !== '' && { unit: lv.unit }),
          ...(lv.sampleDate != null && { sampleDate: lv.sampleDate }),
          ...(meta?.referenceRange
            ? { referenceRange: meta.referenceRange }
            : {}),
          ...(typeof meta?.isAbnormal === 'boolean'
            ? { isAbnormal: meta.isAbnormal }
            : {}),
        };
      }),
      ...(structuredReport &&
        (structuredReport.sections.length > 0 ||
          this.hasLabDetails(structuredReport.labDetails) ||
          this.hasPatientDetails(structuredReport.patientDetails)) && {
          structuredReport,
        }),
    };
  }

  private async getProfileInfoMap(
    userId: string,
  ): Promise<Map<string, { name: string; isActive: boolean }>> {
    const profiles = await this.profilesService.getProfiles(userId);
    return new Map(
      profiles.map((profile) => [
        profile.id,
        { name: profile.name, isActive: profile.isActive },
      ]),
    );
  }

  private withProfileInfo(
    dto: ReportDto,
    profileInfoById: Map<string, { name: string; isActive: boolean }>,
  ): ReportDto {
    const profileInfo = profileInfoById.get(dto.profileId);
    if (!profileInfo) return dto;
    return {
      ...dto,
      profileName: profileInfo.name,
      profileIsActive: profileInfo.isActive,
    };
  }

  private getStoredStructuredReport(
    report: ReportEntity,
  ): StructuredReportDto | undefined {
    const raw = report.structuredReport;
    if (!raw || typeof raw !== 'object') return undefined;
    const candidate = raw as Partial<StructuredReportDto>;
    if (!candidate.patientDetails || !Array.isArray(candidate.sections)) {
      return undefined;
    }
    return candidate as StructuredReportDto;
  }

  private buildStructuredReport(
    transcript: string | null,
    labValues: StructuredReportLabInput[],
  ): StructuredReportDto {
    const patientDetails = this.extractPatientDetails(transcript);
    const labDetails =
      this.labDetailsExtractor.extractFromTranscript(transcript);
    const sectionsMap = new Map<string, StructuredSectionItemDto[]>();

    for (const lv of labValues) {
      const heading = this.resolveSectionHeading(lv.parameterName);
      if (!sectionsMap.has(heading)) {
        sectionsMap.set(heading, []);
      }
      sectionsMap.get(heading)!.push({
        parameterName: lv.parameterName,
        value: lv.value,
        ...(lv.unit ? { unit: lv.unit } : {}),
        ...(lv.sampleDate ? { sampleDate: lv.sampleDate } : {}),
        ...(lv.referenceRange ? { referenceRange: lv.referenceRange } : {}),
        ...(typeof lv.isAbnormal === 'boolean'
          ? { isAbnormal: lv.isAbnormal }
          : {}),
      });
    }

    const sectionOrder = [
      'Thyroid Function',
      'Liver Function',
      'Kidney Function',
      'Lipid Profile',
      'Diabetes',
      'Complete Blood Count',
      'Iron Studies',
      'Vitamin Profile',
      'Inflammation / Autoimmune',
      'Urine Analysis',
      'Hormones',
      'Other Tests',
    ];

    const sections: StructuredSectionDto[] = Array.from(sectionsMap.entries())
      .sort((a, b) => {
        const ai = sectionOrder.indexOf(a[0]);
        const bi = sectionOrder.indexOf(b[0]);
        if (ai === -1 && bi === -1) return a[0].localeCompare(b[0]);
        if (ai === -1) return 1;
        if (bi === -1) return -1;
        return ai - bi;
      })
      .map(([heading, tests]) => ({ heading, tests }));

    return {
      patientDetails,
      ...(this.hasLabDetails(labDetails) ? { labDetails } : {}),
      sections,
    };
  }

  private extractPatientDetails(
    transcript: string | null,
  ): StructuredPatientDetailsDto {
    if (!transcript) return {};
    const lines = transcript
      .replace(/\r\n/g, '\n')
      .split('\n')
      .map((line) => line.replace(/\s+/g, ' ').trim())
      .filter(Boolean);
    const compact = lines.join(' ');
    const read = (re: RegExp): string | undefined => {
      const m = compact.match(re);
      return m?.[1]?.trim();
    };
    const readNextLineValue = (labelRe: RegExp): string | undefined => {
      for (let i = 0; i < lines.length - 1; i++) {
        if (!labelRe.test(lines[i])) continue;
        for (let j = i + 1; j < Math.min(i + 5, lines.length); j++) {
          const candidate = lines[j];
          if (
            /^(patient name|age\/gender|care location|patient location|lab accession id|specimen|collected date|authorized date|investigation|results|uom|reference range)$/i.test(
              candidate,
            )
          ) {
            continue;
          }
          return candidate;
        }
      }
      return undefined;
    };
    const name =
      read(
        /Patient Name\s*:\s*([^|]+?)(?:\s{2,}|Age\/Gender|Barcode|Order Id|$)/i,
      ) ??
      readNextLineValue(/^patient name$/i) ??
      read(/\bDear\s+([A-Za-z][A-Za-z ]{1,60})[,!]/i);
    const ageGender =
      read(/Age\/Gender\s*:\s*([^|]+?)(?:\s{2,}|Order Id|$)/i) ??
      readNextLineValue(/^age\/gender$/i) ??
      read(/\b(\d+\s*Y(?:\s*\d+\s*M)?(?:\s*\d+\s*D)?\s+(?:Male|Female|Other))\b/i);
    const age = ageGender?.match(
      /(\d+\s*Y(?:\s*\d+\s*M)?(?:\s*\d+\s*D)?|\d+\s*Yrs?)/i,
    )?.[1];
    const gender = ageGender?.match(/\b(Male|Female|Other)\b/i)?.[1];
    const bookingId =
      read(/Booking ID\s*:\s*([A-Za-z0-9-]+)/i) ??
      readNextLineValue(/^booking id$/i) ??
      readNextLineValue(/^lab accession id$/i);
    const sampleCollectionDate =
      read(/Sample Collection Date\s*:\s*([0-9]{1,2}\/[A-Za-z]{3}\/[0-9]{4})/i) ??
      read(/Collected Date&Time\s*[:\-]?\s*([0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4})/i);
    return {
      ...(name ? { name } : {}),
      ...(age ? { age } : {}),
      ...(gender ? { gender } : {}),
      ...(bookingId ? { bookingId } : {}),
      ...(sampleCollectionDate ? { sampleCollectionDate } : {}),
    };
  }

  private hasLabDetails(details: StructuredLabDetailsDto | undefined): boolean {
    if (!details) return false;
    return Boolean(details.name && details.name.trim().length > 0);
  }

  private hasPatientDetails(
    details: StructuredPatientDetailsDto | undefined,
  ): boolean {
    if (!details) return false;
    return Boolean(
      details.name ||
        details.age ||
        details.gender ||
        details.bookingId ||
        details.sampleCollectionDate,
    );
  }

  private logLabDetailsExtraction(input: {
    trigger: 'upload' | 'retry';
    reportId: string;
    source: 'odl_json' | 'transcript';
    labDetails: StructuredLabDetailsDto | undefined;
  }): void {
    const name = input.labDetails?.name?.trim() ?? '';
    const shouldExpose = name.length > 0;
    this.logger.log(
      JSON.stringify({
        action: 'REPORT_LAB_DETAILS_EXTRACTED',
        trigger: input.trigger,
        reportId: input.reportId,
        source: input.source,
        shouldExpose,
        labDetails: input.labDetails ?? {},
      }),
    );
  }

  private resolveSectionHeading(parameterName: string): string {
    const p = parameterName.toLowerCase();
    if (/tsh|thyroid|t3|t4|tri-iodothyronine|thyroxine/.test(p)) {
      return 'Thyroid Function';
    }
    if (
      /alt|ast|bilirubin|ggt|alkaline phosphatase|albumin|globulin|sgot|sgpt|liver/.test(
        p,
      )
    ) {
      return 'Liver Function';
    }
    if (
      /creatinine|gfr|urea|bun|uric acid|sodium|chloride|calcium|potassium|kidney/.test(
        p,
      )
    ) {
      return 'Kidney Function';
    }
    if (/cholesterol|hdl|ldl|vldl|triglycerides|non-hdl|lipid/.test(p)) {
      return 'Lipid Profile';
    }
    if (/hba1c|glucose|fasting blood sugar|estimated glucose/.test(p)) {
      return 'Diabetes';
    }
    if (
      /haemoglobin|hemoglobin|rbc|wbc|leucocyte|lymphocyte|neutrophil|monocyte|eosinophil|basophil|platelet|mcv|mch|mchc|rdw|cbc|pcv/.test(
        p,
      )
    ) {
      return 'Complete Blood Count';
    }
    if (/iron|uibc|tibc|transferrin/.test(p)) {
      return 'Iron Studies';
    }
    if (/vitamin b12|vitamin d/.test(p)) {
      return 'Vitamin Profile';
    }
    if (/crp|c-reactive|rheumatoid/.test(p)) {
      return 'Inflammation / Autoimmune';
    }
    if (
      /urine|pus cells|epithelial|ketones|nitrite|leucocyte esterase/.test(p)
    ) {
      return 'Urine Analysis';
    }
    if (/cortisol/.test(p)) {
      return 'Hormones';
    }
    return 'Other Tests';
  }
}
