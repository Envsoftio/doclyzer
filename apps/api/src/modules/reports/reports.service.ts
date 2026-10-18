import {
  BadRequestException,
  ConflictException,
  Inject,
  Injectable,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { createHash, randomUUID } from 'node:crypto';
import { IsNull, LessThanOrEqual, MoreThan, Repository } from 'typeorm';
import { isUUID } from 'class-validator';
import { redactSecrets } from '../../common/redact-secrets';
import type { FileStorageService } from '../../common/storage/file-storage.interface';
import { FILE_STORAGE } from '../../common/storage/storage.module';
import type { ReportStatus } from '../../database/entities/report.entity';
import { ReportEntity } from '../../database/entities/report.entity';
import type { AttemptTrigger } from '../../database/entities/report-processing-attempt.entity';
import { ReportProcessingAttemptEntity } from '../../database/entities/report-processing-attempt.entity';
import { ReportLabValueEntity } from '../../database/entities/report-lab-value.entity';
import { ReportLabValueCorrectionEntity } from '../../database/entities/report-lab-value-correction.entity';
import { ReportResultInsightEntity } from '../../database/entities/report-result-insight.entity';
import { ProfilesService } from '../profiles/profiles.service';
import { ReportSummaryService } from './report-summary/report-summary.service';
import { OpenDataLoaderClient } from './opendataloader.client';
import { SuryaOcrClient } from './surya-ocr.client';
import { DoclingOcrClient } from './docling-ocr.client';
import { ImageToPdfService } from './image-to-pdf.service';
import { buildLabTrends, type TrendParameter } from './lab-trend-builder';
import {
  loadObservationRules,
  normalizeObservation,
} from './observation-normalizer';
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
import { ReferralsService } from '../referrals/referrals.service';
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
  id?: string;
  parameterName: string;
  originalParameterName?: string;
  canonicalTestId?: string | null;
  value: string;
  rawResult?: string;
  parsedNumericValue?: string | null;
  normalizedNumericValue?: string | null;
  comparisonQualifier?: string | null;
  resultKind?: string;
  unit?: string;
  originalUnit?: string | null;
  normalizedUnit?: string | null;
  sampleDate?: string;
  originalSampleDate?: string | null;
  collectionDateSource?: string;
  extractionSource?: string;
  reviewState?: string;
  referenceRange?: string;
  isAbnormal?: boolean;
  reviewVersion?: number;
  sourceSnapshot?: Record<string, unknown>;
}

export interface CorrectLabValueInput {
  expectedVersion: number;
  parameterName: string;
  value: string;
  unit: string | null;
  sampleDate: string | null;
  referenceRange: string | null;
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
  extractionReview?: {
    required: boolean;
    candidateRows: number;
    parsedRows: number;
    reasons: string[];
  };
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
  hasMappedLabTables?: boolean;
  extractedLabValues: StructuredReportLabInput[];
  structuredReport: StructuredReportDto;
  extractionReview: NonNullable<StructuredReportDto['extractionReview']>;
}

const OCR_TEXT_LOG_CHAR_LIMIT = 6000;

type ReportInputSource = 'pdf' | 'image';

interface ParsedBufferResult {
  status: ReportStatus;
  transcript: string | null;
  opendataloaderJson?: unknown;
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
    private readonly suryaOcrClient: SuryaOcrClient,
    private readonly reportLabAiFallbackService: ReportLabAiFallbackService,
    private readonly notificationPipeline: NotificationPipelineService,
    private readonly imageToPdfService: ImageToPdfService,
    private readonly referralsService: ReferralsService,
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

    const { status, transcript, opendataloaderJson } =
      await this.parseReportBuffer(
        normalizedFile.buffer,
        'upload',
        reportId,
        normalizedFile.source,
      );

    const parsedFromJson = opendataloaderJson
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
    const transcriptLabValues = this.filterNoisyLabValues(
      transcriptLabValuesRaw,
    );
    const jsonLabValues = this.filterNoisyLabValues(
      parsedFromJson?.extractedLabValues ?? [],
    );
    let labValues =
      parsedFromJson?.hasMappedLabTables ||
      (normalizedFile.source === 'image' && jsonLabValues.length > 0)
        ? jsonLabValues
        : this.selectBestLabValues(jsonLabValues, transcriptLabValues);
    const extractionSource =
      parsedFromJson?.hasMappedLabTables ||
      (normalizedFile.source === 'image' && jsonLabValues.length > 0)
        ? 'odl_json'
        : jsonLabValues.length > 0 && transcriptLabValues.length > 0
          ? 'merged_extractors'
          : jsonLabValues.length > 0
            ? 'odl_json'
            : 'transcript';
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
      structuredReport = this.withBestPatientDetails(
        structuredReport,
        transcript,
      );
      structuredReport.sections = this.buildStructuredReport(
        null,
        labValues,
      ).sections;
      structuredReport.extractionReview = parsedFromJson?.extractionReview ?? {
        required: true,
        candidateRows: 0,
        parsedRows: labValues.length,
        reasons: ['Results came from text without verifiable table coverage.'],
      };
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
            structuredSectionsCount: structuredReport.sections.length,
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
        status: finalStatus,
        extractedLabValues: labValues.length,
      }),
    );
    const persistedLabValues = finalStatus === 'parsed' ? labValues : [];
    const observationRules = await loadObservationRules((sql) =>
      this.reportRepo.manager.query(sql),
    );

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
          originalParameterName: lv.parameterName,
          value: lv.value,
          rawResult: lv.value,
          unit: lv.unit ?? null,
          originalUnit: lv.unit ?? null,
          sampleDate: lv.sampleDate ?? null,
          originalSampleDate: lv.sampleDate ?? null,
          collectionDateSource: lv.sampleDate ? 'extracted' : 'unknown',
          extractionSource,
          referenceRange: lv.referenceRange ?? null,
          ...normalizeObservation(
            {
              parameterName: lv.parameterName,
              value: lv.value,
              unit: lv.unit ?? null,
            },
            observationRules,
          ),
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
    await this.triggerReferralMilestoneA(entity, correlationId, 'upload');

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

  async correctLabValue(
    userId: string,
    reportId: string,
    labValueId: string,
    input: CorrectLabValueInput,
  ): Promise<ReportDto> {
    if (!isUUID(reportId) || !isUUID(labValueId))
      throw new ReportNotFoundException();
    const name = this.requiredCorrectionText(
      input.parameterName,
      'parameterName',
      256,
    );
    const value = this.requiredCorrectionText(input.value, 'value', 512);
    const unit = this.optionalCorrectionText(input.unit, 'unit', 64);
    const sampleDate = this.optionalCorrectionText(
      input.sampleDate,
      'sampleDate',
      10,
    );
    const referenceRange = this.optionalCorrectionText(
      input.referenceRange,
      'referenceRange',
      256,
    );
    const observationRules = await loadObservationRules((sql) =>
      this.reportRepo.manager.query(sql),
    );
    if (
      !Number.isSafeInteger(input.expectedVersion) ||
      input.expectedVersion < 0
    ) {
      throw new BadRequestException({
        code: 'REVIEW_VERSION_INVALID',
        message: 'A valid review version is required.',
      });
    }
    if (sampleDate && !this.validCollectionDate(sampleDate)) {
      throw new BadRequestException({
        code: 'COLLECTION_DATE_INVALID',
        message: 'Use a valid collection date in YYYY-MM-DD format.',
      });
    }

    await this.reportRepo.manager.transaction(async (manager) => {
      const report = await manager.getRepository(ReportEntity).findOne({
        where: { id: reportId, userId, deletedAt: IsNull() },
        lock: { mode: 'pessimistic_write' },
      });
      if (!report || report.status !== 'parsed')
        throw new ReportNotFoundException();
      const labRepo = manager.getRepository(ReportLabValueEntity);
      const row = await labRepo.findOne({
        where: { id: labValueId, reportId },
        lock: { mode: 'pessimistic_write' },
      });
      if (!row) throw new ReportNotFoundException();
      if (row.reviewVersion !== input.expectedVersion) {
        throw new ConflictException({
          code: 'REPORT_RESULT_VERSION_CONFLICT',
          message:
            'This result changed. Reload the report before saving your correction.',
        });
      }
      const source = this.toDto(report, [row], false, true)
        .extractedLabValues[0];
      const previous = {
        parameterName: row.parameterName,
        value: row.value,
        unit: row.unit,
        sampleDate: row.sampleDate,
        referenceRange:
          row.reviewVersion > 0
            ? row.referenceRange
            : (source.referenceRange ?? null),
      };
      const next = {
        parameterName: name,
        value,
        unit,
        sampleDate,
        referenceRange,
      };
      if (JSON.stringify(previous) === JSON.stringify(next)) return;
      row.sourceSnapshot ??= {
        parameterName: source.parameterName,
        value: source.value,
        unit: source.unit ?? null,
        sampleDate: source.sampleDate ?? null,
        referenceRange: source.referenceRange ?? null,
      };
      row.parameterName = name;
      row.value = value;
      row.unit = unit;
      row.sampleDate = sampleDate;
      row.referenceRange = referenceRange;
      row.collectionDateSource = sampleDate ? 'corrected' : 'unknown';
      Object.assign(
        row,
        normalizeObservation(
          { parameterName: name, value, unit, corrected: true },
          observationRules,
        ),
      );
      row.reviewVersion += 1;
      await labRepo.save(row);
      await manager.getRepository(ReportLabValueCorrectionEntity).save({
        reportId,
        labValueId,
        userId,
        version: row.reviewVersion,
        previousValue: previous,
        correctedValue: next,
      });
      report.summary = null;
      await manager.getRepository(ReportEntity).save(report);
      await manager.delete(ReportResultInsightEntity, { reportId });
    });
    return this.getReport(userId, reportId);
  }

  private requiredCorrectionText(
    value: unknown,
    field: string,
    max: number,
  ): string {
    if (
      typeof value !== 'string' ||
      !value.trim() ||
      value.trim().length > max
    ) {
      throw new BadRequestException({
        code: 'REPORT_RESULT_FIELD_INVALID',
        message: `${field} must contain 1–${max} characters.`,
      });
    }
    return value.trim();
  }

  private optionalCorrectionText(
    value: unknown,
    field: string,
    max: number,
  ): string | null {
    if (value !== null && typeof value !== 'string') {
      throw new BadRequestException({
        code: 'REPORT_RESULT_FIELD_INVALID',
        message: `${field} must be text or null.`,
      });
    }
    if (typeof value === 'string' && value.trim().length > max) {
      throw new BadRequestException({
        code: 'REPORT_RESULT_FIELD_INVALID',
        message: `${field} is too long.`,
      });
    }
    return typeof value === 'string' ? value.trim() || null : null;
  }

  private validCollectionDate(value: string): boolean {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
    const parsed = new Date(`${value}T00:00:00Z`);
    return (
      !Number.isNaN(parsed.getTime()) &&
      parsed.toISOString().slice(0, 10) === value
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

  /** Build chartable series from confirmed collection dates and exact numeric values. */
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
      select: ['id', 'structuredReport'],
    });

    if (reports.length === 0) {
      return { parameters: [] };
    }

    const reportIds = reports.map((r) => r.id);
    // Build query for lab values belonging to these reports
    const qb = this.reportLabValueRepo
      .createQueryBuilder('lv')
      .where('lv.report_id IN (:...reportIds)', { reportIds });
    const labValues = await qb.getMany();
    const rangesByReport = new Map<string, Map<string, string | null>>();
    for (const report of reports) {
      const candidates = new Map<string, Array<string | null>>();
      for (const section of this.getStoredStructuredReport(report)?.sections ??
        []) {
        for (const test of section.tests) {
          const key = this.labRowKey(
            test.parameterName,
            test.value,
            test.unit ?? null,
          );
          if (!key) continue;
          const ranges = candidates.get(key) ?? [];
          ranges.push(test.referenceRange?.trim() || null);
          candidates.set(key, ranges);
        }
      }
      rangesByReport.set(
        report.id,
        new Map(
          [...candidates].map(([key, ranges]) => [
            key,
            ranges.length === 1 ? ranges[0] : null,
          ]),
        ),
      );
    }
    const observationRules = await loadObservationRules((sql) =>
      this.reportRepo.manager.query(sql),
    );
    return buildLabTrends(
      labValues.map((row) => {
        const key = this.labRowKey(
          row.parameterName,
          row.value,
          row.unit ?? null,
        );
        const sourceRange = key
          ? rangesByReport.get(row.reportId)?.get(key)
          : null;
        return {
          id: row.id,
          reportId: row.reportId,
          parameterName: row.parameterName,
          value: row.value,
          unit: row.unit,
          sampleDate: row.sampleDate,
          canonicalTestId: row.canonicalTestId,
          parsedNumericValue: row.parsedNumericValue,
          normalizedNumericValue: row.normalizedNumericValue,
          comparisonQualifier: row.comparisonQualifier,
          resultKind: row.resultKind,
          normalizedUnit: row.normalizedUnit,
          collectionDateSource: row.collectionDateSource,
          reviewState: row.reviewState,
          referenceRange:
            row.reviewVersion > 0
              ? row.referenceRange
              : (row.referenceRange ?? sourceRange ?? null),
        };
      }),
      parameterName,
      observationRules,
    );
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
        ? retryFromJson?.hasMappedLabTables
          ? retryJsonValues
          : this.selectBestLabValues(retryJsonValues, retryTranscriptValues)
        : [];
    const retryExtractionSource = retryFromJson?.hasMappedLabTables
      ? 'odl_json'
      : retryJsonValues.length > 0 && retryTranscriptValues.length > 0
        ? 'merged_extractors'
        : retryJsonValues.length > 0
          ? 'odl_json'
          : 'transcript';
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
          status: finalStatus,
          extractedLabValues: retryLabValues.length,
        }),
      );
    }
    const persistedRetryLabValues =
      finalStatus === 'parsed' ? dedupedRetryLabValues : [];
    const observationRules = await loadObservationRules((sql) =>
      this.reportRepo.manager.query(sql),
    );

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
      retryStructuredReport.extractionReview =
        retryFromJson?.extractionReview ?? {
          required: true,
          candidateRows: 0,
          parsedRows: dedupedRetryLabValues.length,
          reasons: [
            'Results came from text without verifiable table coverage.',
          ],
        };
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
    // Serialize replacement with corrections. A correction made during parsing
    // must win; reprocessing must never silently remove it.
    await this.reportRepo.manager.transaction(async (manager) => {
      const locked = await manager.getRepository(ReportEntity).findOne({
        where: { id: entity.id, userId, deletedAt: IsNull() },
        lock: { mode: 'pessimistic_write' },
      });
      if (!locked) throw new ReportNotFoundException();
      const corrected = await manager
        .getRepository(ReportLabValueEntity)
        .count({
          where: { reportId: entity.id, reviewVersion: MoreThan(0) },
        });
      if (corrected > 0) {
        throw new ConflictException({
          code: 'REPORT_HAS_CORRECTIONS',
          message:
            'This report has reviewed results. Reprocessing would replace them.',
        });
      }
      locked.status = entity.status;
      locked.summary = entity.summary;
      locked.parsedTranscript = entity.parsedTranscript;
      locked.structuredReport = entity.structuredReport;
      await manager.getRepository(ReportEntity).save(locked);
      await manager
        .getRepository(ReportLabValueEntity)
        .delete({ reportId: entity.id });
      if (persistedRetryLabValues.length > 0) {
        const labRepo = manager.getRepository(ReportLabValueEntity);
        await labRepo.save(
          persistedRetryLabValues.map((lv, i) =>
            labRepo.create({
              reportId: entity.id,
              parameterName: lv.parameterName,
              originalParameterName: lv.parameterName,
              value: lv.value,
              rawResult: lv.value,
              unit: lv.unit ?? null,
              originalUnit: lv.unit ?? null,
              sampleDate: lv.sampleDate ?? null,
              originalSampleDate: lv.sampleDate ?? null,
              collectionDateSource: lv.sampleDate ? 'extracted' : 'unknown',
              extractionSource: retryExtractionSource,
              referenceRange: lv.referenceRange ?? null,
              ...normalizeObservation(
                {
                  parameterName: lv.parameterName,
                  value: lv.value,
                  unit: lv.unit ?? null,
                },
                observationRules,
              ),
              sortOrder: i,
            }),
          ),
        );
      }
      entity.profileId = locked.profileId;
    });

    await this.recordAttempt(entity.id, 'retry', entity.status);

    this.dispatchReportNotification({
      status: entity.status,
      userId,
      profileId: entity.profileId,
      correlationId,
    });
    await this.triggerReferralMilestoneA(entity, correlationId, 'retry');

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

    if (labValues.length === 0) return false;
    // A single observation needs report structure as corroboration. Its name
    // cannot tell us whether the document is a lab report.
    const hasNameColumn =
      /\b(test(?: name)?|investigation|parameter|analyte|assay)\b/i.test(
        transcript,
      );
    const hasResultColumn =
      /\b(result|observed value|observation|patient result)\b/i.test(
        transcript,
      );
    return hasNameColumn && hasResultColumn;
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

  private async parseWithPreferredOcr(buffer: Buffer) {
    const surya = await this.suryaOcrClient.parsePdf(buffer);
    if (surya) {
      const parsed = this.odlJsonParser.parseWithDiagnostics(surya.parsedJson);
      if (
        parsed.diagnostics.hasMappedLabTables &&
        !parsed.diagnostics.hasAmbiguousHeaders &&
        parsed.extractedLabValues.length > 0 &&
        parsed.diagnostics.coverage >= 0.9
      )
        return surya;
    }
    const fallback = await this.doclingOcrClient.parsePdf(buffer, {
      doOcr: true,
      forceOcr: true,
    });
    // A backend failure should not erase Surya's readable transcript.
    return fallback?.text?.trim() || fallback?.parsedJson ? fallback : surya;
  }

  private async parseReportBuffer(
    buffer: Buffer,
    trigger: 'upload' | 'retry',
    reportId: string,
    source: ReportInputSource = 'pdf',
  ): Promise<ParsedBufferResult> {
    if (source === 'image') {
      const doclingAttempt = await this.parseWithPreferredOcr(buffer);
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
    const firstStructure = firstAttempt?.parsedJson
      ? this.odlJsonParser.parseWithDiagnostics(firstAttempt.parsedJson)
      : null;
    // Readable prose is not evidence of usable lab-table extraction.
    if (
      firstEval.ok &&
      firstStructure?.diagnostics.hasMappedLabTables &&
      !firstStructure.diagnostics.hasAmbiguousHeaders &&
      firstStructure.extractedLabValues.length > 0 &&
      firstStructure.diagnostics.coverage >= 0.9
    ) {
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

    // Native extraction preserves exact embedded text and avoids OCR on logos.
    // Only pay the OCR cost when native lab extraction is insufficient.
    let doclingAttempt = await this.doclingOcrClient.parsePdf(buffer, {
      doOcr: false,
      forceOcr: false,
    });
    let doclingEval = this.evaluateParsedTranscript(doclingAttempt?.text);
    const nativeStructure = doclingAttempt?.parsedJson
      ? this.odlJsonParser.parseWithDiagnostics(doclingAttempt.parsedJson)
      : null;
    if (
      !doclingEval.ok ||
      !nativeStructure?.diagnostics.hasMappedLabTables ||
      nativeStructure.diagnostics.hasAmbiguousHeaders ||
      nativeStructure.extractedLabValues.length === 0 ||
      nativeStructure.diagnostics.coverage < 0.9
    ) {
      const ocrAttempt = await this.parseWithPreferredOcr(buffer);
      const ocrEval = this.evaluateParsedTranscript(ocrAttempt?.text);
      // An unavailable OCR backend must not discard usable native output.
      const ocrRows = ocrAttempt?.parsedJson
        ? this.odlJsonParser.parseWithDiagnostics(ocrAttempt.parsedJson)
            .extractedLabValues.length
        : 0;
      if (
        (ocrEval.ok || ocrAttempt?.parsedJson) &&
        ocrRows >= (nativeStructure?.extractedLabValues.length ?? 0)
      ) {
        doclingAttempt = ocrAttempt;
        doclingEval = ocrEval;
      }
    }
    if (doclingAttempt) {
      this.logger.log(
        JSON.stringify({
          action: 'REPORT_PDF_FALLBACK_ATTEMPT',
          trigger,
          reportId,
          odlTranscriptChars: firstEval.text?.length ?? 0,
          doclingTranscriptChars: doclingEval.text?.length ?? 0,
          doclingHasJson: Boolean(doclingAttempt.parsedJson),
          selected: doclingEval.ok ? 'native_or_ocr' : 'odl',
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
    const diagnostics = deterministic.diagnostics;
    const reviewReasons: string[] = [];
    if (!diagnostics.hasMappedLabTables)
      reviewReasons.push(
        'Results could not be checked against mapped table columns.',
      );
    if (diagnostics.hasUnmappedTables)
      reviewReasons.push(
        'Some tables had no identifiable test and result columns.',
      );
    if (diagnostics.hasAmbiguousHeaders)
      reviewReasons.push('Some result columns could not be distinguished.');
    if (diagnostics.candidateRows > diagnostics.parsedRows)
      reviewReasons.push(
        `${diagnostics.candidateRows - diagnostics.parsedRows} candidate result row(s) were not extracted.`,
      );
    if (diagnostics.candidateRows === 0)
      reviewReasons.push('Table coverage could not be measured.');
    const extractionReview: NonNullable<
      StructuredReportDto['extractionReview']
    > = {
      required: reviewReasons.length > 0,
      candidateRows: diagnostics.candidateRows,
      parsedRows: diagnostics.parsedRows,
      reasons: reviewReasons,
    };
    if (
      deterministic.diagnostics.hasMappedLabTables &&
      !deterministic.diagnostics.hasAmbiguousHeaders &&
      deterministic.diagnostics.candidateRows > 0 &&
      deterministic.diagnostics.parsedRows ===
        deterministic.diagnostics.candidateRows
    ) {
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
          reason: 'header_mapped_table_cells',
        }),
      );
      return {
        extractedLabValues,
        structuredReport,
        hasMappedLabTables: deterministic.diagnostics.hasMappedLabTables,
        extractionReview,
      };
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
      return {
        extractedLabValues,
        structuredReport,
        hasMappedLabTables: deterministic.diagnostics.hasMappedLabTables,
        extractionReview,
      };
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
      return {
        extractedLabValues,
        structuredReport,
        hasMappedLabTables: deterministic.diagnostics.hasMappedLabTables,
        extractionReview,
      };
    }

    extractedLabValues = aiValues;
    extractionReview.required = true;
    extractionReview.reasons.push(
      'Some results required automated fallback extraction.',
    );
    structuredReport = {
      patientDetails: deterministic.structuredReport.patientDetails,
      ...(deterministic.structuredReport.labDetails
        ? { labDetails: deterministic.structuredReport.labDetails }
        : {}),
      sections: this.buildStructuredReport(null, aiValues).sections,
    };
    return {
      extractedLabValues,
      structuredReport,
      hasMappedLabTables: deterministic.diagnostics.hasMappedLabTables,
      extractionReview,
    };
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
    if (!referenceRange || /^[<>≤≥]/.test(rawValue.trim())) return null;

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
    const cleaned = raw.trim();
    const plain = /^-?(?:\d+(?:\.\d+)?|\.\d+)$/.test(cleaned);
    const grouped = /^-?\d{1,3}(?:,\d{3})+(?:\.\d+)?$/.test(cleaned);
    if (!plain && !grouped) return null;
    const n = Number(cleaned.replaceAll(',', ''));
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
    const match = numeric.match(/^([<>]=?|[≤≥])?\s*([-+]?\d+(?:\.\d+)?)$/);
    if (match) {
      const num = Number(match[2]);
      if (Number.isFinite(num)) return `${match[1] ?? ''}${num}`;
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
        /\b(reference range|test name|investigation|parameter|analyte|result|unit)\b/i.test(
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
    const alphaCount = (text.match(/[A-Za-z]/g) ?? []).length;
    this.logger.log(
      JSON.stringify({
        action: 'REPORT_PARSE_RESULT',
        trigger,
        reportId,
        status,
        transcriptChars: text.length,
        transcriptAlphaChars: alphaCount,
        transcriptTruncatedForTelemetry: text.length > OCR_TEXT_LOG_CHAR_LIMIT,
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

  private async triggerReferralMilestoneA(
    report: ReportEntity,
    correlationId: string | undefined,
    trigger: 'upload' | 'retry',
  ): Promise<void> {
    if (report.status !== 'parsed') {
      return;
    }

    const resolvedCorrelationId = correlationId ?? randomUUID();
    try {
      await this.referralsService.triggerMilestoneAForSuccessfulAnalysis({
        inviteeUserId: report.userId,
        reportId: report.id,
        correlationId: resolvedCorrelationId,
        trigger,
      });
    } catch (err) {
      this.logger.warn(
        JSON.stringify({
          action: 'REFERRAL_MILESTONE_A_TRIGGER_FAILED',
          reportId: report.id,
          correlationId: resolvedCorrelationId,
          error: err instanceof Error ? err.message : String(err),
        }),
      );
    }
  }

  async getProcessingAttempts(
    userId: string,
    reportId: string,
  ): Promise<ProcessingAttemptDto[]> {
    await this.getActiveReportOrThrow(userId, reportId);
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
        const referenceRange =
          lv.reviewVersion > 0
            ? lv.referenceRange
            : (lv.referenceRange ?? meta?.referenceRange);
        const isAbnormal =
          lv.reviewVersion > 0
            ? this.evaluateAbnormalFromReference(
                lv.value,
                referenceRange ?? null,
              )
            : meta?.isAbnormal;
        return {
          id: lv.id,
          parameterName: lv.parameterName,
          originalParameterName: lv.originalParameterName,
          canonicalTestId: lv.canonicalTestId,
          value: lv.value,
          rawResult: lv.rawResult,
          parsedNumericValue: lv.parsedNumericValue,
          normalizedNumericValue: lv.normalizedNumericValue,
          comparisonQualifier: lv.comparisonQualifier,
          resultKind: lv.resultKind,
          ...(lv.unit != null && lv.unit !== '' && { unit: lv.unit }),
          originalUnit: lv.originalUnit,
          normalizedUnit: lv.normalizedUnit,
          ...(lv.sampleDate != null && { sampleDate: lv.sampleDate }),
          originalSampleDate: lv.originalSampleDate,
          collectionDateSource: lv.collectionDateSource,
          extractionSource: lv.extractionSource,
          reviewState: lv.reviewState,
          ...(referenceRange ? { referenceRange } : {}),
          ...(typeof isAbnormal === 'boolean' ? { isAbnormal } : {}),
          reviewVersion: lv.reviewVersion ?? 0,
          ...(lv.sourceSnapshot ? { sourceSnapshot: lv.sourceSnapshot } : {}),
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
      const heading = 'Lab Results';
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

    const sections: StructuredSectionDto[] = Array.from(
      sectionsMap.entries(),
    ).map(([heading, tests]) => ({ heading, tests }));

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
      read(
        /\b(\d+\s*Y(?:\s*\d+\s*M)?(?:\s*\d+\s*D)?\s+(?:Male|Female|Other))\b/i,
      );
    const age = ageGender?.match(
      /(\d+\s*Y(?:\s*\d+\s*M)?(?:\s*\d+\s*D)?|\d+\s*Yrs?)/i,
    )?.[1];
    const gender = ageGender?.match(/\b(Male|Female|Other)\b/i)?.[1];
    const bookingId =
      read(/Booking ID\s*:\s*([A-Za-z0-9-]+)/i) ??
      readNextLineValue(/^booking id$/i) ??
      readNextLineValue(/^lab accession id$/i);
    const sampleCollectionDate =
      read(
        /Sample Collection Date\s*:\s*([0-9]{1,2}\/[A-Za-z]{3}\/[0-9]{4})/i,
      ) ??
      read(/Collected Date&Time\s*[:-]?\s*([0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4})/i);
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
        labDetailsFields: {
          name: Boolean(input.labDetails?.name),
          address: Boolean(input.labDetails?.address),
          phone: Boolean(input.labDetails?.phone),
          email: Boolean(input.labDetails?.email),
          location: Boolean(input.labDetails?.location),
        },
      }),
    );
  }
}
