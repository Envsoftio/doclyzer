import {
  BadRequestException,
  Inject,
  Injectable,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { createHash, randomUUID } from 'node:crypto';
import { Repository } from 'typeorm';
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
import {
  OpenDataLoaderJsonParser,
  type OpenDataLoaderParsedWithDiagnosticsOutput,
} from './opendataloader-json-parser';
import { LabValueExtractor } from './lab-value-extractor';
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
  MAX_REPORT_SIZE_BYTES,
  REPORT_ALREADY_PARSED,
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
  originalFileName: string;
  contentType: string;
  sizeBytes: number;
  status: string;
  createdAt: string;
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
    private readonly reportLabAiFallbackService: ReportLabAiFallbackService,
    private readonly notificationPipeline: NotificationPipelineService,
  ) {
    this.labExtractor = new LabValueExtractor();
  }

  private readonly labExtractor: LabValueExtractor;
  private readonly odlJsonParser = new OpenDataLoaderJsonParser();

  private throwIfAlreadyParsed(status: string): void {
    if (status === 'parsed') {
      throw new BadRequestException({
        code: REPORT_ALREADY_PARSED,
        message: 'Report is already parsed; nothing to retry or keep.',
      });
    }
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
    if (!ALLOWED_CONTENT_TYPES.includes(file.mimetype as 'application/pdf')) {
      throw new ReportUploadException(
        REPORT_FILE_TYPE_UNSUPPORTED,
        'Only PDF files are supported',
      );
    }

    const contentHash = this.computeContentHash(file.buffer);
    const forceUploadAnyway = options?.duplicateAction === 'upload_anyway';

    // Duplicate check: best-effort per profile; concurrent uploads of same file can both pass (no locking).
    const existing = await this.reportRepo.findOne({
      where: { profileId: activeProfileId, contentHash },
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
    const originalFileName = file.originalname?.trim() || 'report.pdf';

    await this.fileStorage.upload(storageKey, file.buffer, file.mimetype);

    const { status, transcript, opendataloaderJson } =
      await this.parseReportBuffer(file.buffer, 'upload', reportId);

    const parsedFromJson = opendataloaderJson
      ? await this.extractLabValuesFromOdlJsonWithFallback({
          opendataloaderJson,
          reportId,
          trigger: 'upload',
        })
      : null;
    const labValues = parsedFromJson
      ? parsedFromJson.extractedLabValues
      : transcript
        ? this.toStructuredLabInputs(this.labExtractor.extract(transcript))
        : [];
    const structuredReport =
      status === 'parsed'
        ? (parsedFromJson?.structuredReport ??
          this.buildStructuredReport(transcript, labValues))
        : null;

    const summary =
      status === 'parsed'
        ? await this.reportSummaryService.generateSummary(file.buffer)
        : null;

    const entity = this.reportRepo.create({
      id: reportId,
      userId,
      profileId: activeProfileId,
      originalFileName,
      contentType: file.mimetype,
      sizeBytes: file.buffer.length,
      originalFileStorageKey: storageKey,
      status,
      summary,
      parsedTranscript: status === 'parsed' ? transcript : null,
      structuredReport: structuredReport as Record<string, unknown> | null,
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

    if (labValues.length > 0) {
      const labEntities = labValues.map((lv, i) =>
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

  async getReportFile(
    userId: string,
    reportId: string,
  ): Promise<{
    buffer: Buffer;
    contentType: string;
    originalFileName: string;
  }> {
    if (!isUUID(reportId)) throw new ReportNotFoundException();
    const entity = await this.reportRepo.findOne({
      where: { id: reportId, userId },
    });
    if (!entity) throw new ReportNotFoundException();
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
    if (!isUUID(reportId)) throw new ReportNotFoundException();
    const entity = await this.reportRepo.findOne({
      where: { id: reportId, userId },
    });
    if (!entity) throw new ReportNotFoundException();
    const labValues = await this.reportLabValueRepo.find({
      where: { reportId },
      order: { sortOrder: 'ASC', parameterName: 'ASC' },
    });
    return this.toDto(entity, labValues, true, true);
  }

  /** List reports for a profile. Validates user owns the profile (throws if not). */
  async listReportsByProfile(
    userId: string,
    profileId: string,
  ): Promise<ReportDto[]> {
    await this.profilesService.getProfile(userId, profileId);
    const entities = await this.reportRepo.find({
      where: { profileId },
      order: { createdAt: 'DESC' },
    });
    return entities.map((e) => this.toDto(e));
  }

  /**
   * List reports: if profileId provided, use it (validates ownership); otherwise use active profile.
   */
  async listReports(userId: string, profileId?: string): Promise<ReportDto[]> {
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
      where: { profileId },
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
    if (!isUUID(reportId)) throw new ReportNotFoundException();
    const entity = await this.reportRepo.findOne({
      where: { id: reportId, userId },
    });
    if (!entity) throw new ReportNotFoundException();
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
        })
      : null;
    const retryLabValues =
      status === 'parsed'
        ? (retryFromJson?.extractedLabValues ??
          (transcript
            ? this.toStructuredLabInputs(this.labExtractor.extract(transcript))
            : []))
        : [];

    entity.status = status;
    entity.summary =
      status === 'parsed'
        ? await this.reportSummaryService.generateSummary(buffer)
        : null;
    // Only overwrite transcript on success; preserve existing on failure (AC3)
    if (status === 'parsed') {
      entity.parsedTranscript = transcript;
      entity.structuredReport = JSON.parse(
        JSON.stringify(
          retryFromJson?.structuredReport ??
            this.buildStructuredReport(transcript, retryLabValues),
        ),
      ) as unknown as Record<string, unknown>;
    }
    await this.reportRepo.save(entity);

    // Replace previous extracted values on successful parse to avoid duplicated rows
    // when users intentionally reprocess the same report.
    await this.reportLabValueRepo.delete({ reportId: entity.id });

    if (retryLabValues.length > 0) {
      const labEntities = retryLabValues.map((lv, i) =>
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
  ): Promise<{
    status: ReportStatus;
    transcript: string | null;
    opendataloaderJson?: unknown;
  }> {
    const result = await this.openDataLoaderClient.parsePdf(buffer);
    const evaluated = this.evaluateParsedTranscript(result?.text);
    const status = evaluated.ok ? 'parsed' : 'failed_transient';
    this.logParseQuality(trigger, reportId, evaluated.text, status);
    return {
      status,
      transcript: evaluated.text,
      ...(result?.parsedJson ? { opendataloaderJson: result.parsedJson } : {}),
    };
  }

  private async extractLabValuesFromOdlJsonWithFallback(input: {
    opendataloaderJson: unknown;
    reportId: string;
    trigger: 'upload' | 'retry';
  }): Promise<SelectedOdlLabOutput> {
    const deterministic = this.odlJsonParser.parseWithDiagnostics(
      input.opendataloaderJson,
    );
    let extractedLabValues = this.toStructuredLabInputs(
      deterministic.extractedLabValues,
    );
    let structuredReport = deterministic.structuredReport;

    const aiFallback = await this.reportLabAiFallbackService.tryExtract({
      reportId: input.reportId,
      trigger: input.trigger,
      confidence: deterministic.diagnostics.confidence,
      lowConfidenceReasons: deterministic.diagnostics.lowConfidenceReasons,
      candidateRows: deterministic.diagnostics.aiCandidateRows,
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

    const qual = /^(negative|positive|nil|normal|absent|present|clear|cloudy|turbid|trace|pale yellow|yellow|amber|straw)$/i;
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
    const cleaned = raw.replace(/^[<>]=?\s*/, '').replace(/,/g, '').trim();
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

  private logParseQuality(
    trigger: 'upload' | 'retry',
    reportId: string,
    transcript: string | null,
    status: ReportStatus,
  ): void {
    const text = transcript ?? '';
    const preview = text.slice(0, 180).replace(/\s+/g, ' ');
    const alphaCount = (text.match(/[A-Za-z]/g) ?? []).length;
    this.logger.log(
      JSON.stringify({
        action: 'REPORT_PARSE_RESULT',
        trigger,
        reportId,
        status,
        transcriptChars: text.length,
        transcriptAlphaChars: alphaCount,
        preview,
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
    if (!isUUID(reportId)) throw new ReportNotFoundException();
    const report = await this.reportRepo.findOne({
      where: { id: reportId, userId },
    });
    if (!report) throw new ReportNotFoundException();
    const attempts = await this.attemptRepo.find({
      where: { reportId },
      order: { attemptedAt: 'ASC' },
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
    if (!isUUID(reportId)) throw new ReportNotFoundException();
    if (!isUUID(targetProfileId)) {
      throw new BadRequestException({
        code: 'TARGET_PROFILE_ID_INVALID',
        message: 'targetProfileId must be a valid UUID.',
      });
    }
    const entity = await this.reportRepo.findOne({
      where: { id: reportId, userId },
    });
    if (!entity) throw new ReportNotFoundException();
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
    return this.toDto(entity);
  }

  async keepFile(userId: string, reportId: string): Promise<ReportDto> {
    if (!isUUID(reportId)) throw new ReportNotFoundException();
    const entity = await this.reportRepo.findOne({
      where: { id: reportId, userId },
    });
    if (!entity) throw new ReportNotFoundException();
    this.throwIfAlreadyParsed(entity.status);
    // Sets to unparsed so user sees "View PDF"; applies to unparsed and content_not_recognized
    entity.status = 'unparsed';
    entity.summary = null;
    entity.parsedTranscript = null;
    entity.structuredReport = null;
    await this.reportRepo.save(entity);
    return this.toDto(entity);
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
            this.labRowKey(
              test.parameterName,
              test.value,
              test.unit ?? null,
            ) ?? null;
          if (!key) continue;
          const meta = {
            ...(test.referenceRange ? { referenceRange: test.referenceRange } : {}),
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
          ...(meta?.referenceRange ? { referenceRange: meta.referenceRange } : {}),
          ...(typeof meta?.isAbnormal === 'boolean'
            ? { isAbnormal: meta.isAbnormal }
            : {}),
        };
      }),
      ...(structuredReport &&
        structuredReport.sections.length > 0 && { structuredReport }),
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

    return { patientDetails, sections };
  }

  private extractPatientDetails(
    transcript: string | null,
  ): StructuredPatientDetailsDto {
    if (!transcript) return {};
    const compact = transcript.replace(/\s+/g, ' ').trim();
    const read = (re: RegExp): string | undefined => {
      const m = compact.match(re);
      return m?.[1]?.trim();
    };
    const name =
      read(
        /Patient Name\s*:\s*([^|]+?)(?:\s{2,}|Age\/Gender|Barcode|Order Id|$)/i,
      ) ?? read(/\bDear\s+([A-Za-z][A-Za-z ]{1,60})[,!]/i);
    const ageGender = read(/Age\/Gender\s*:\s*([^|]+?)(?:\s{2,}|Order Id|$)/i);
    const age = ageGender?.match(
      /(\d+\s*Y(?:\s*\d+\s*M)?(?:\s*\d+\s*D)?|\d+\s*Yrs?)/i,
    )?.[1];
    const gender = ageGender?.match(/\b(Male|Female|Other)\b/i)?.[1];
    return {
      ...(name ? { name } : {}),
      ...(age ? { age } : {}),
      ...(gender ? { gender } : {}),
      ...(read(/Booking ID\s*:\s*([A-Za-z0-9-]+)/i)
        ? { bookingId: read(/Booking ID\s*:\s*([A-Za-z0-9-]+)/i) }
        : {}),
      ...(read(
        /Sample Collection Date\s*:\s*([0-9]{1,2}\/[A-Za-z]{3}\/[0-9]{4})/i,
      )
        ? {
            sampleCollectionDate: read(
              /Sample Collection Date\s*:\s*([0-9]{1,2}\/[A-Za-z]{3}\/[0-9]{4})/i,
            ),
          }
        : {}),
    };
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
