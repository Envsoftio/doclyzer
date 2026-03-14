import {
  BadRequestException,
  Inject,
  Injectable,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'node:crypto';
import { Repository } from 'typeorm';
import { isUUID } from 'class-validator';
import type { FileStorageService } from '../../common/storage/file-storage.interface';
import { FILE_STORAGE } from '../../common/storage/storage.module';
import type { ReportStatus } from '../../database/entities/report.entity';
import { ReportEntity } from '../../database/entities/report.entity';
import { ProfilesService } from '../profiles/profiles.service';
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

export interface ReportDto {
  id: string;
  profileId: string;
  originalFileName: string;
  contentType: string;
  sizeBytes: number;
  status: string;
  createdAt: string;
}

@Injectable()
export class ReportsService {
  private readonly logger = new Logger(ReportsService.name);

  constructor(
    @InjectRepository(ReportEntity)
    private readonly reportRepo: Repository<ReportEntity>,
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

    return {
      reportId,
      profileId: activeProfileId,
      fileName: entity.originalFileName,
      contentType: entity.contentType,
      sizeBytes: entity.sizeBytes,
      status: entity.status, // parsed when sync stub runs
    };
  }

  async getReportFile(
    userId: string,
    reportId: string,
  ): Promise<{ buffer: Buffer; contentType: string; originalFileName: string }> {
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
    return this.toDto(entity);
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
    if (isRetry && retrySucceeds) return 'parsed';
    return fail ? 'unparsed' : 'parsed';
  }

  private toDto(e: ReportEntity): ReportDto {
    return {
      id: e.id,
      profileId: e.profileId,
      originalFileName: e.originalFileName,
      contentType: e.contentType,
      sizeBytes: e.sizeBytes,
      status: e.status,
      createdAt: e.createdAt.toISOString(),
    };
  }
}
