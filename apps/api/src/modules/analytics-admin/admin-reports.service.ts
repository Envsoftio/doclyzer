import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { createHash } from 'node:crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FILE_STORAGE } from '../../common/storage/storage.module';
import type { FileStorageService } from '../../common/storage/file-storage.interface';
import { ProfileEntity } from '../../database/entities/profile.entity';
import { ReportEntity } from '../../database/entities/report.entity';
import { ReportLabValueEntity } from '../../database/entities/report-lab-value.entity';
import { UserEntity } from '../../database/entities/user.entity';
import { AuditIncidentService } from '../audit-incident/audit-incident.service';
import { comparePrintedRange } from '../reports/report-result-insight.service';
import type { AdminReportsQueryDto } from './admin-reports.dto';

@Injectable()
export class AdminReportsService {
  constructor(
    @InjectRepository(ReportEntity)
    private readonly reports: Repository<ReportEntity>,
    @InjectRepository(ReportLabValueEntity)
    private readonly values: Repository<ReportLabValueEntity>,
    @Inject(FILE_STORAGE)
    private readonly storage: FileStorageService,
    private readonly audit: AuditIncidentService,
  ) {}

  async list(query: AdminReportsQueryDto) {
    const page = query.page ?? 1;
    const pageSize = query.pageSize ?? 25;
    const qb = this.reports
      .createQueryBuilder('r')
      .innerJoin(UserEntity, 'u', 'u.id = r.user_id')
      .innerJoin(ProfileEntity, 'p', 'p.id = r.profile_id');
    if (query.userId) qb.andWhere('r.user_id = :userId', { userId: query.userId });
    if (query.status) qb.andWhere('r.status = :status', { status: query.status });
    if (query.search?.trim()) {
      const search = `%${query.search.trim().replace(/[\\%_]/g, '\\$&')}%`;
      qb.andWhere(
        `(r.original_file_name ILIKE :search ESCAPE '\\' OR u.email ILIKE :search ESCAPE '\\' OR CAST(r.id AS text) ILIKE :search ESCAPE '\\')`,
        { search },
      );
    }
    const total = await qb.getCount();
    const rows = await qb
      .select('r.id', 'id')
      .addSelect('r.user_id', 'userId')
      .addSelect('u.email', 'userEmail')
      .addSelect('r.profile_id', 'profileId')
      .addSelect('p.name', 'profileName')
      .addSelect('r.original_file_name', 'originalFileName')
      .addSelect('r.content_type', 'contentType')
      .addSelect('r.size_bytes', 'sizeBytes')
      .addSelect('r.status', 'status')
      .addSelect('r.created_at', 'createdAt')
      .addSelect('r.deleted_at', 'deletedAt')
      .orderBy('r.created_at', 'DESC')
      .addOrderBy('r.id', 'DESC')
      .offset((page - 1) * pageSize)
      .limit(pageSize)
      .getRawMany<{
        id: string;
        userId: string;
        userEmail: string;
        profileId: string;
        profileName: string;
        originalFileName: string;
        contentType: string;
        sizeBytes: number;
        status: string;
        createdAt: Date | string;
        deletedAt: Date | string | null;
      }>();
    return {
      items: rows.map((row) => ({
        ...row,
        sizeBytes: Number(row.sizeBytes),
        createdAt: new Date(row.createdAt).toISOString(),
        deletedAt: row.deletedAt ? new Date(row.deletedAt).toISOString() : null,
      })),
      total,
      page,
      pageSize,
      totalPages: Math.max(1, Math.ceil(total / pageSize)),
    };
  }

  async detail(reportId: string, actorUserId: string, correlationId: string) {
    const report = await this.findReport(reportId);
    await this.recordAccess(actorUserId, correlationId, 'ADMIN_REPORT_VIEW', reportId);
    const values = await this.values.find({
      where: { reportId },
      order: { sortOrder: 'ASC', parameterName: 'ASC' },
    });
    const [user, profile] = await Promise.all([
      this.reports.manager.getRepository(UserEntity).findOne({ where: { id: report.userId } }),
      this.reports.manager.getRepository(ProfileEntity).findOne({ where: { id: report.profileId } }),
    ]);
    const sections = Array.isArray(report.structuredReport?.sections)
      ? report.structuredReport.sections
      : [];
    const parsedRangeStatuses = sections.map((section) => {
      const tests = section && typeof section === 'object' && 'tests' in section && Array.isArray(section.tests)
        ? section.tests
        : [];
      return tests.map((test: unknown) => {
        const row = test && typeof test === 'object' ? test as Record<string, unknown> : {};
        return comparePrintedRange({
          parameterName: typeof row.parameterName === 'string' ? row.parameterName : '',
          value: typeof row.value === 'string' ? row.value : '',
          unit: typeof row.unit === 'string' ? row.unit : undefined,
          referenceRange: typeof row.referenceRange === 'string' ? row.referenceRange : undefined,
          isAbnormal: typeof row.isAbnormal === 'boolean' ? row.isAbnormal : undefined,
        });
      });
    });
    return {
      id: report.id,
      userId: report.userId,
      userEmail: user?.email ?? null,
      profileId: report.profileId,
      profileName: profile?.name ?? null,
      originalFileName: report.originalFileName,
      contentType: report.contentType,
      sizeBytes: report.sizeBytes,
      status: report.status,
      processingState: report.processingState,
      processingStage: report.processingStage,
      processingErrorCode: report.processingErrorCode,
      createdAt: report.createdAt.toISOString(),
      updatedAt: report.updatedAt.toISOString(),
      deletedAt: report.deletedAt?.toISOString() ?? null,
      summary: report.summary,
      parsedTranscript: report.parsedTranscript,
      structuredReport: report.structuredReport,
      parsedRangeStatuses,
      extractedLabValues: values.map((value) => ({
        id: value.id,
        parameterName: value.parameterName,
        originalParameterName: value.originalParameterName,
        value: value.value,
        rawResult: value.rawResult,
        unit: value.unit,
        sampleDate: value.sampleDate,
        referenceRange: value.referenceRange,
        rangeStatus: comparePrintedRange({
          parameterName: value.parameterName,
          value: value.value,
          unit: value.unit ?? undefined,
          referenceRange: value.referenceRange ?? undefined,
        }),
        resultKind: value.resultKind,
        comparisonQualifier: value.comparisonQualifier,
        reviewState: value.reviewState,
        extractionSource: value.extractionSource,
      })),
    };
  }

  async file(reportId: string, actorUserId: string, correlationId: string) {
    const report = await this.findReport(reportId);
    await this.recordAccess(actorUserId, correlationId, 'ADMIN_REPORT_FILE_VIEW', reportId);
    const buffer = await this.storage.get(report.originalFileStorageKey);
    return {
      buffer,
      contentType: report.contentType,
      originalFileName: report.originalFileName,
    };
  }

  private async findReport(reportId: string): Promise<ReportEntity> {
    const report = await this.reports.findOne({ where: { id: reportId } });
    if (!report) throw new NotFoundException({ code: 'REPORT_NOT_FOUND', message: 'Report not found' });
    return report;
  }

  private async recordAccess(actorUserId: string, correlationId: string, action: string, reportId: string) {
    const reportFingerprint = createHash('sha256').update(reportId).digest('hex');
    await this.audit.recordAuditAction({
      actorUserId,
      correlationId,
      dto: { action, target: `report-sha256:${reportFingerprint}`, outcome: 'success' },
    });
  }
}
