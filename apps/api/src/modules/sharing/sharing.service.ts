import {
  BadRequestException,
  ForbiddenException,
  HttpException,
  HttpStatus,
  Inject,
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import {
  FindOptionsWhere,
  In,
  IsNull,
  MoreThan,
  Or,
  Repository,
} from 'typeorm';
import { randomInt, randomUUID } from 'node:crypto';
import { compare, hash } from 'bcryptjs';
import { ShareLinkEntity } from '../../database/entities/share-link.entity';
import { UserSharePolicyEntity } from '../../database/entities/user-share-policy.entity';
import { ReportEntity } from '../../database/entities/report.entity';
import { ReportLabValueEntity } from '../../database/entities/report-lab-value.entity';
import { ShareAccessEventEntity } from '../../database/entities/share-access-event.entity';
import { ProfilesService } from '../profiles/profiles.service';
import { ShareLinkNotFoundException } from './exceptions/share-link-not-found.exception';
import { ShareLinkExpiredException } from './exceptions/share-link-expired.exception';
import { ShareLinkLimitExceededException } from './exceptions/share-link-limit-exceeded.exception';
import {
  EXPIRY_MUST_BE_FUTURE,
  INVALID_EXPIRES_IN_DAYS,
} from './sharing.types';
import { UsageLimitsService } from '../entitlements/usage-limits.service';
import type { FileStorageService } from '../../common/storage/file-storage.interface';
import { FILE_STORAGE } from '../../common/storage/storage.module';
import { comparePrintedRange } from '../reports/report-result-insight.service';
import {
  normalizePrintedRangeText,
  preferredPrintedRange,
} from '../reports/report-reference-range';

export interface SharePolicyDto {
  defaultExpiresInDays: number | null;
}

export interface AccessEventDto {
  id: string;
  accessedAt: string; // ISO string
  outcome: string; // 'accessed' | 'expired_or_revoked'
}

export interface PublicLabValueDto {
  parameterName: string;
  value: string;
  unit: string | null;
  sampleDate: string | null;
  referenceRange: string | null;
  rangeStatus: 'below' | 'within' | 'above' | 'unknown';
}

export interface PublicReportDto {
  id: string;
  originalFileName: string;
  status: string;
  summary: string | null;
  createdAt: string; // ISO string
  labValues: PublicLabValueDto[];
}

export interface PublicShareDto {
  profileName: string;
  scope: string;
  reports: PublicReportDto[];
}

export interface ShareLinkDto {
  id: string;
  token: string;
  shareUrl: string;
  profileId: string;
  scope: string;
  reportIds: string[] | null;
  labValueIds: string[] | null;
  requiresAccessCode: boolean;
  accessCode?: string;
  isActive: boolean;
  expiresAt: string | null; // ISO string or null
  createdAt: string; // ISO string
}

type StructuredRange = {
  referenceRange: string | null;
  isAbnormal: boolean | null;
  unit: string | null;
};

const misplacedInterval = /^\s*-?\d+(?:\.\d+)?\s*[-–—]\s*-?\d+(?:\.\d+)?\s*$/;

function resultKey(name: string, value: string, unit: string | null): string {
  return `${name.trim().toLowerCase()}::${value.trim().toLowerCase()}::${(unit ?? '').trim().toLowerCase()}`;
}

function structuredRangeLookup(raw: Record<string, unknown> | null | undefined) {
  const byResult = new Map<string, StructuredRange | null>();
  const byName = new Map<string, StructuredRange | null>();
  if (!raw || !Array.isArray(raw.sections)) return { byResult, byName };

  for (const section of raw.sections) {
    if (!section || !Array.isArray(section.tests)) continue;
    for (const test of section.tests) {
      if (typeof test?.parameterName !== 'string' ||
          typeof test?.value !== 'string') continue;
      const name = test.parameterName.trim().toLowerCase();
      const value = test.value.trim();
      if (!name || !value) continue;
      const range: StructuredRange = {
        referenceRange: typeof test.referenceRange === 'string'
          ? test.referenceRange.trim() || null
          : null,
        isAbnormal: typeof test.isAbnormal === 'boolean'
          ? test.isAbnormal
          : null,
        unit: typeof test.unit === 'string'
          ? test.unit.trim().toLowerCase() || null
          : null,
      };
      const key = resultKey(name, value, range.unit);
      if (!byResult.has(key)) byResult.set(key, range);
      else {
        const previous = byResult.get(key);
        if (previous?.referenceRange !== range.referenceRange ||
            previous?.isAbnormal !== range.isAbnormal) byResult.set(key, null);
      }
      // A name-only fallback is safe only when exactly one structured row has
      // this name and its unit matches the saved observation.
      if (!byName.has(name)) byName.set(name, range);
      else byName.set(name, null);
    }
  }
  return { byResult, byName };
}

function sharedRowRange(
  row: ReportLabValueEntity,
  lookup: ReturnType<typeof structuredRangeLookup>,
): { referenceRange: string | null; isAbnormal: boolean | null; unit: string | null } {
  const savedRange = row.referenceRange?.trim() || null;
  if (row.reviewVersion > 0) {
    return { referenceRange: savedRange, isAbnormal: null, unit: row.unit };
  }
  const key = resultKey(row.parameterName, row.value, row.unit);
  const exact = lookup.byResult.get(key);
  const name = row.parameterName.trim().toLowerCase();
  const candidate = lookup.byResult.has(key) ? null : lookup.byName.get(name);
  const fallback = candidate?.unit === (row.unit?.trim().toLowerCase() || null)
    ? candidate
    : null;
  let referenceRange = savedRange ?? exact?.referenceRange ??
    fallback?.referenceRange ?? null;
  let unit = row.unit;
  // Mobile also recovers a printed interval accidentally extracted as the
  // unit. Keep the missing real unit explicit, so comparison stays unknown.
  if (!referenceRange && unit &&
      (misplacedInterval.test(unit) || preferredPrintedRange(unit) != null)) {
    referenceRange = unit.trim();
    unit = null;
  }
  const exactFlagApplies = exact &&
    (!savedRange || normalizePrintedRangeText(savedRange) ===
      normalizePrintedRangeText(exact.referenceRange ?? ''));
  return {
    referenceRange,
    isAbnormal: exactFlagApplies ? exact.isAbnormal : null,
    unit,
  };
}

function structuredPublicRows(
  raw: Record<string, unknown> | null | undefined,
): PublicLabValueDto[] {
  if (!raw || !Array.isArray(raw.sections)) return [];
  const rows: PublicLabValueDto[] = [];
  for (const section of raw.sections) {
    if (!section || !Array.isArray(section.tests)) continue;
    for (const test of section.tests) {
      if (typeof test?.parameterName !== 'string' ||
          typeof test?.value !== 'string') continue;
      const parameterName = test.parameterName.trim();
      const value = test.value.trim();
      if (!parameterName || !value) continue;
      const unit = typeof test.unit === 'string' ? test.unit.trim() || null : null;
      const rawRange = typeof test.referenceRange === 'string'
        ? test.referenceRange.trim() || null
        : null;
      const referenceRange = rawRange
        ? normalizePrintedRangeText(rawRange)
        : null;
      rows.push({
        parameterName,
        value,
        unit,
        sampleDate: typeof test.sampleDate === 'string'
          ? test.sampleDate.trim() || null
          : null,
        referenceRange,
        rangeStatus: comparePrintedRange({
          parameterName,
          value,
          unit: unit ?? undefined,
          referenceRange: rawRange ?? undefined,
          isAbnormal: typeof test.isAbnormal === 'boolean'
            ? test.isAbnormal
            : undefined,
        }),
      });
    }
  }
  return rows;
}

@Injectable()
export class SharingService {
  private readonly shareBaseUrl: string;

  constructor(
    @InjectRepository(ShareLinkEntity)
    private readonly shareLinkRepo: Repository<ShareLinkEntity>,
    @InjectRepository(UserSharePolicyEntity)
    private readonly policyRepo: Repository<UserSharePolicyEntity>,
    @InjectRepository(ReportEntity)
    private readonly reportRepo: Repository<ReportEntity>,
    @InjectRepository(ReportLabValueEntity)
    private readonly reportLabValueRepo: Repository<ReportLabValueEntity>,
    @InjectRepository(ShareAccessEventEntity)
    private readonly accessEventRepo: Repository<ShareAccessEventEntity>,
    private readonly profilesService: ProfilesService,
    private readonly configService: ConfigService,
    private readonly usageLimitsService: UsageLimitsService,
    @Inject(FILE_STORAGE) private readonly fileStorage: FileStorageService,
  ) {
    this.shareBaseUrl = this.configService.get<string>(
      'SHARE_BASE_URL',
      'http://localhost:3005',
    );
  }

  private buildScopedReportWhere(
    link: ShareLinkEntity,
  ): FindOptionsWhere<ReportEntity> {
    // Double isolation: profileId (profile boundary) + userId (owner boundary)
    const base: FindOptionsWhere<ReportEntity> = {
      profileId: link.profileId,
      userId: link.userId,
      status: 'parsed' as const,
      deletedAt: IsNull(),
    };
    switch (link.scope) {
      case 'all':
        return base;
      case 'selected_reports':
      case 'selected_results':
        return { ...base, id: In(link.reportIds ?? []) };
      default:
        // Unknown scopes must never widen access to all reports.
        return { ...base, id: In([]) };
    }
  }

  private toDto(entity: ShareLinkEntity): ShareLinkDto {
    return {
      id: entity.id,
      token: entity.token,
      shareUrl: `${this.shareBaseUrl}/share/${entity.token}`,
      profileId: entity.profileId,
      scope: entity.scope,
      reportIds: entity.reportIds ?? null,
      labValueIds: entity.labValueIds ?? null,
      requiresAccessCode: Boolean(entity.accessCodeHash),
      isActive: entity.isActive,
      expiresAt: entity.expiresAt ? entity.expiresAt.toISOString() : null,
      createdAt: entity.createdAt.toISOString(),
    };
  }

  /** Returns true when link can be used by a recipient. Called by story 3.5 public endpoint. */
  isLinkValid(entity: ShareLinkEntity): boolean {
    if (!entity.isActive) return false;
    if (entity.expiresAt && entity.expiresAt <= new Date()) return false;
    return true;
  }

  async getPublicShareData(token: string, accessCode?: string): Promise<PublicShareDto> {
    const link = await this.shareLinkRepo.findOne({ where: { token } });
    if (!link) throw new ShareLinkNotFoundException(); // no recording — no link to associate

    if (!this.isLinkValid(link)) {
      await this.accessEventRepo.save(
        this.accessEventRepo.create({ shareLinkId: link.id, outcome: 'expired_or_revoked' }),
      );
      throw new ShareLinkExpiredException();
    }
    if (link.accessCodeHash) {
      if (typeof accessCode !== 'string' || accessCode.trim().length === 0) {
        throw new ForbiddenException({
          code: 'SHARE_ACCESS_CODE_REQUIRED',
          message: 'An access code is required',
        });
      }
      const failures = await this.accessEventRepo.count({
        where: {
          shareLinkId: link.id,
          outcome: 'access_code_rejected',
          accessedAt: MoreThan(new Date(Date.now() - 60 * 60 * 1000)),
        },
      });
      if (failures >= 5) {
        throw new HttpException(
          { code: 'SHARE_ACCESS_CODE_RATE_LIMITED', message: 'Try again later' },
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }
      if (!(await compare(accessCode.replace(/\s/g, ''), link.accessCodeHash))) {
        await this.accessEventRepo.save(
          this.accessEventRepo.create({ shareLinkId: link.id, outcome: 'access_code_rejected' }),
        );
        throw new ForbiddenException({
          code: 'SHARE_ACCESS_CODE_INVALID',
          message: 'The access code is incorrect',
        });
      }
    }
    await this.accessEventRepo.save(
      this.accessEventRepo.create({ shareLinkId: link.id, outcome: 'accessed' }),
    );

    const profile = await this.profilesService.getProfile(
      link.userId,
      link.profileId,
    );
    const reports = await this.reportRepo.find({
      where: this.buildScopedReportWhere(link), // Double isolation: profileId scopes to the shared profile; userId prevents cross-user data access if profileId were ever reused or guessed
      order: { createdAt: 'DESC' },
      select: [
        'id',
        'originalFileName',
        'status',
        'summary',
        'createdAt',
        'profileId',
        'structuredReport',
      ],
    });

    // Defense-in-depth: assert isolation holds (should never trigger in normal operation — canary for data access bugs)
    for (const r of reports) {
      if (r.profileId !== link.profileId) {
        throw new InternalServerErrorException(
          'Isolation violation: unexpected report in shared output',
        );
      }
    }

    const reportIds = reports.map((r) => r.id);
    let labValues: ReportLabValueEntity[] = [];
    if (reportIds.length > 0) {
      labValues = await this.reportLabValueRepo.find({
        where: {
          reportId: In(reportIds),
          ...(link.scope === 'selected_results'
            ? { id: In(link.labValueIds ?? []) }
            : {}),
        },
        order: { sortOrder: 'ASC', parameterName: 'ASC' },
      });
    }
    const labByReport = new Map<string, ReportLabValueEntity[]>();
    for (const lv of labValues) {
      if (!labByReport.has(lv.reportId)) labByReport.set(lv.reportId, []);
      labByReport.get(lv.reportId)!.push(lv);
    }

    return {
      profileName: profile.name,
      scope: link.scope,
      reports: reports
        .filter((r) => link.scope !== 'selected_results' || labByReport.has(r.id))
        .map((r) => {
          const lookup = structuredRangeLookup(r.structuredReport);
          const savedRows = labByReport.get(r.id) ?? [];
          return {
            id: r.id,
            originalFileName: r.originalFileName,
            status: r.status,
            summary: link.scope === 'selected_results' ? null : r.summary,
            createdAt: r.createdAt.toISOString(),
            labValues: savedRows.length === 0 && link.scope !== 'selected_results'
              ? structuredPublicRows(r.structuredReport)
              : savedRows.map((lv) => {
                  const resolved = sharedRowRange(lv, lookup);
                  return {
                    parameterName: lv.parameterName,
                    value: lv.value,
                    unit: resolved.unit,
                    sampleDate: lv.sampleDate ?? null,
                    referenceRange: resolved.referenceRange
                      ? normalizePrintedRangeText(resolved.referenceRange)
                      : null,
                    rangeStatus: comparePrintedRange({
                      parameterName: lv.parameterName,
                      value: lv.value,
                      unit: resolved.unit ?? undefined,
                      referenceRange: resolved.referenceRange ?? undefined,
                      isAbnormal: resolved.isAbnormal ?? undefined,
                    }),
                  };
                }),
          };
        }),
    };
  }

  async getSharedOriginal(
    token: string,
    reportId: string,
    accessCode?: string,
  ): Promise<{ data: Buffer; contentType: string; fileName: string }> {
    // Recheck expiry, revocation, code and ownership for every download.
    const share = await this.getPublicShareData(token, accessCode);
    if (share.scope === 'selected_results' ||
        !share.reports.some((report) => report.id === reportId)) {
      throw new ShareLinkNotFoundException();
    }
    const link = await this.shareLinkRepo.findOne({ where: { token } });
    if (!link || !this.isLinkValid(link)) throw new ShareLinkExpiredException();
    const report = await this.reportRepo.findOne({
      where: {
        id: reportId,
        userId: link.userId,
        profileId: link.profileId,
        deletedAt: IsNull(),
      },
    });
    if (!report) throw new ShareLinkNotFoundException();
    return {
      data: await this.fileStorage.get(report.originalFileStorageKey),
      contentType: report.contentType,
      fileName: report.originalFileName,
    };
  }

  async createShareLink(
    userId: string,
    profileId: string,
    scope = 'all',
    expiresAt?: Date,
    reportIds?: string[],
    requireAccessCode = false,
    labValueIds?: string[],
  ): Promise<ShareLinkDto> {
    if (expiresAt && expiresAt <= new Date()) {
      throw new BadRequestException({
        code: EXPIRY_MUST_BE_FUTURE,
        message: 'expiresAt must be a future date',
      });
    }
    // Throws ProfileNotFoundException (404) if user doesn't own profile
    await this.profilesService.getProfile(userId, profileId);
    let selectedReportIds: string[] | null = null;
    if (scope === 'selected_reports' || scope === 'selected_results') {
      if (!Array.isArray(reportIds) || reportIds.length === 0) {
        throw new BadRequestException({
          code: 'SHARE_REPORTS_REQUIRED',
          message: 'Select at least one report to share',
        });
      }
      selectedReportIds = [...new Set(reportIds)];
      if (
        selectedReportIds.some(
          (id) =>
            typeof id !== 'string' ||
            !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(
              id,
            ),
        )
      ) {
        throw new BadRequestException({
          code: 'SHARE_REPORTS_INVALID',
          message: 'Invalid report selection',
        });
      }
      const ownedReports = await this.reportRepo.find({
        where: {
          id: In(selectedReportIds),
          userId,
          profileId,
          status: 'parsed',
          deletedAt: IsNull(),
        },
        select: ['id'],
      });
      if (ownedReports.length !== selectedReportIds.length) {
        throw new BadRequestException({
          code: 'SHARE_REPORTS_INVALID',
          message: 'One or more selected reports are unavailable',
        });
      }
    } else if (scope !== 'all') {
      throw new BadRequestException({
        code: 'SHARE_SCOPE_INVALID',
        message: 'Unsupported share scope',
      });
    }
    let selectedLabValueIds: string[] | null = null;
    if (scope === 'selected_results') {
      if (!Array.isArray(labValueIds) || labValueIds.length === 0) {
        throw new BadRequestException({
          code: 'SHARE_RESULTS_REQUIRED',
          message: 'Select at least one test result to share',
        });
      }
      selectedLabValueIds = [...new Set(labValueIds)];
      if (
        selectedLabValueIds.some(
          (id) =>
            typeof id !== 'string' ||
            !/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(id),
        )
      ) {
        throw new BadRequestException({
          code: 'SHARE_RESULTS_INVALID',
          message: 'Invalid test result selection',
        });
      }
      const ownedValues = await this.reportLabValueRepo.find({
        where: {
          id: In(selectedLabValueIds),
          reportId: In(selectedReportIds!),
        },
        select: ['id'],
      });
      if (ownedValues.length !== selectedLabValueIds.length) {
        throw new BadRequestException({
          code: 'SHARE_RESULTS_INVALID',
          message: 'One or more selected test results are unavailable',
        });
      }
    }
    const planInfo = await this.usageLimitsService.getPlanLimits(userId);
    const accessCode = requireAccessCode
      ? randomInt(0, 1000000).toString().padStart(6, '0')
      : undefined;
    const accessCodeHash = accessCode ? await hash(accessCode, 10) : null;
    return this.shareLinkRepo.manager.transaction(async (manager) => {
      await this.usageLimitsService.lockEntitlementForUpdate(userId, manager);
      const usage = await this.usageLimitsService.getShareLinkUsage(
        userId,
        manager,
        planInfo,
      );
      if (usage.current >= usage.limit) {
        throw new ShareLinkLimitExceededException(usage);
      }
      const token = randomUUID();
      const entity = manager.create(ShareLinkEntity, {
        userId,
        profileId,
        token,
        scope,
        reportIds: selectedReportIds,
        labValueIds: selectedLabValueIds,
        accessCodeHash,
        expiresAt: expiresAt ?? null,
      });
      const saved = await manager.save(entity);
      return { ...this.toDto(saved), ...(accessCode ? { accessCode } : {}) };
    });
  }

  async listShareLinks(
    userId: string,
    profileId: string,
    includePast = false,
  ): Promise<ShareLinkDto[]> {
    // Ownership check: ProfilesService throws ProfileNotFoundException if not owned
    await this.profilesService.getProfile(userId, profileId);
    const now = new Date();
    const links = await this.shareLinkRepo.find({
      where: includePast
        ? { userId, profileId }
        : {
            userId,
            profileId,
            isActive: true,
            expiresAt: Or(IsNull(), MoreThan(now)),
          },
      order: { createdAt: 'DESC' },
    });
    return links.map((l) => this.toDto(l));
  }

  async revokeShareLink(userId: string, linkId: string): Promise<void> {
    const link = await this.shareLinkRepo.findOne({
      where: { id: linkId, userId },
    });
    if (!link) throw new ShareLinkNotFoundException();
    link.isActive = false;
    await this.shareLinkRepo.save(link);
  }

  async updateExpiry(
    userId: string,
    linkId: string,
    expiresAt: Date | null,
  ): Promise<ShareLinkDto> {
    if (expiresAt && expiresAt <= new Date()) {
      throw new BadRequestException({
        code: EXPIRY_MUST_BE_FUTURE,
        message: 'expiresAt must be a future date',
      });
    }
    const link = await this.shareLinkRepo.findOne({
      where: { id: linkId, userId },
    });
    if (!link) throw new ShareLinkNotFoundException();
    link.expiresAt = expiresAt;
    const saved = await this.shareLinkRepo.save(link);
    return this.toDto(saved);
  }

  async getPolicy(userId: string): Promise<SharePolicyDto> {
    const row = await this.policyRepo.findOne({ where: { userId } });
    return { defaultExpiresInDays: row?.defaultExpiresInDays ?? null };
  }

  async upsertPolicy(
    userId: string,
    defaultExpiresInDays: number | null,
  ): Promise<SharePolicyDto> {
    if (
      defaultExpiresInDays !== null &&
      (defaultExpiresInDays <= 0 || !Number.isInteger(defaultExpiresInDays))
    ) {
      throw new BadRequestException({
        code: INVALID_EXPIRES_IN_DAYS,
        message: 'defaultExpiresInDays must be a positive integer or null',
      });
    }
    let row = await this.policyRepo.findOne({ where: { userId } });
    if (row) {
      row.defaultExpiresInDays = defaultExpiresInDays;
    } else {
      row = this.policyRepo.create({ userId, defaultExpiresInDays });
    }
    await this.policyRepo.save(row);
    return { defaultExpiresInDays };
  }

  async listAccessEvents(
    userId: string,
    linkId: string,
  ): Promise<AccessEventDto[]> {
    // Ownership check — reuse same ownership pattern as revokeShareLink
    const link = await this.shareLinkRepo.findOne({
      where: { id: linkId, userId },
    });
    if (!link) throw new ShareLinkNotFoundException();
    const events = await this.accessEventRepo.find({
      where: { shareLinkId: linkId },
      order: { accessedAt: 'DESC' },
    });
    return events.map((e) => ({
      id: e.id,
      accessedAt: e.accessedAt.toISOString(),
      outcome: e.outcome,
    }));
  }
}
