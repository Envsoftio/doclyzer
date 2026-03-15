import {
  BadRequestException,
  Inject,
  Injectable,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { createHash, randomUUID } from 'node:crypto';
import { Repository } from 'typeorm';
import { isUUID } from 'class-validator';
import type { FileStorageService } from '../../common/storage/file-storage.interface';
import { FILE_STORAGE } from '../../common/storage/storage.module';
import type { ReportStatus } from '../../database/entities/report.entity';
import { ReportEntity } from '../../database/entities/report.entity';
import { ReportLabValueEntity } from '../../database/entities/report-lab-value.entity';
import { ProfilesService } from '../profiles/profiles.service';
import { ReportDuplicateDetectedException } from './exceptions/report-duplicate-detected.exception';
import { ReportFileUnavailableException } from './exceptions/report-file-unavailable.exception';
import { ReportNotFoundException } from './exceptions/report-not-found.exception';
import { ReportUploadException } from './exceptions/report-upload.exception';
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
}

export interface ReportDto {
  id: string;
  profileId: string;
  originalFileName: string;
  contentType: string;
  sizeBytes: number;
  status: string;
  createdAt: string;
  extractedLabValues: ExtractedLabValueDto[];
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

@Injectable()
export class ReportsService {
  private readonly logger = new Logger(ReportsService.name);

  constructor(
    @InjectRepository(ReportEntity)
    private readonly reportRepo: Repository<ReportEntity>,
    @InjectRepository(ReportLabValueEntity)
    private readonly reportLabValueRepo: Repository<ReportLabValueEntity>,
    private readonly profilesService: ProfilesService,
    @Inject(FILE_STORAGE) private readonly fileStorage: FileStorageService,
    private readonly configService: ConfigService,
  ) {}

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
  ): Promise<UploadReportResult> {
    const activeProfileId =
      await this.profilesService.getActiveProfileId(userId);
    if (!activeProfileId) {
      throw new ReportUploadException(
        REPORT_NO_ACTIVE_PROFILE,
        'No active profile. Create or select a profile first.',
      );
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

    const status = this.runParseStub(file.buffer);
    const entity = this.reportRepo.create({
      id: reportId,
      userId,
      profileId: activeProfileId,
      originalFileName,
      contentType: file.mimetype,
      sizeBytes: file.buffer.length,
      originalFileStorageKey: storageKey,
      status,
      contentHash,
    });

    try {
      await this.reportRepo.save(entity);
    } catch (err) {
      try {
        await this.fileStorage.delete(storageKey);
      } catch (deleteErr) {
        this.logger.warn(
          `Cleanup: failed to delete orphaned file ${storageKey}: ${deleteErr instanceof Error ? deleteErr.message : String(deleteErr)}`,
        );
      }
      throw err;
    }

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
        `Report file unavailable in storage: ${err instanceof Error ? err.message : String(err)}`,
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
    return this.toDto(entity, labValues);
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

  async retryParse(userId: string, reportId: string): Promise<ReportDto> {
    if (!isUUID(reportId)) throw new ReportNotFoundException();
    const entity = await this.reportRepo.findOne({
      where: { id: reportId, userId },
    });
    if (!entity) throw new ReportNotFoundException();
    this.throwIfAlreadyParsed(entity.status);

    const buffer = await this.fileStorage.get(entity.originalFileStorageKey);
    const status = this.runParseStub(buffer, true);
    entity.status = status;
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
    await this.reportRepo.save(entity);
    return this.toDto(entity);
  }

  private runParseStub(_buffer: Buffer, isRetry = false): ReportStatus {
    const fail =
      this.configService.get<boolean>('reports.parseStubFail') ?? false;
    const retrySucceeds =
      this.configService.get<boolean>('reports.parseStubRetrySucceeds') ??
      false;
    const contentNotRecognized =
      this.configService.get<boolean>(
        'reports.parseStubContentNotRecognized',
      ) ?? false;
    if (isRetry && retrySucceeds) return 'parsed';
    if (fail) return contentNotRecognized ? 'content_not_recognized' : 'unparsed';
    return 'parsed';
  }

  private toDto(
    e: ReportEntity,
    labValues: ReportLabValueEntity[] = [],
  ): ReportDto {
    return {
      id: e.id,
      profileId: e.profileId,
      originalFileName: e.originalFileName,
      contentType: e.contentType,
      sizeBytes: e.sizeBytes,
      status: e.status,
      createdAt: e.createdAt.toISOString(),
      extractedLabValues: labValues.map((lv) => ({
        parameterName: lv.parameterName,
        value: lv.value,
        ...(lv.unit != null && lv.unit !== '' && { unit: lv.unit }),
        ...(lv.sampleDate != null && { sampleDate: lv.sampleDate }),
      })),
    };
  }
}
