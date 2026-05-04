import {
  BadRequestException,
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
import { randomUUID } from 'node:crypto';
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
  isActive: boolean;
  expiresAt: string | null; // ISO string or null
  createdAt: string; // ISO string
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
  ) {
    this.shareBaseUrl = this.configService.get<string>(
      'SHARE_BASE_URL',
      'http://localhost:3001',
    );
  }

  // scope='all' is the only defined value today; extend this switch for future scope types (e.g. date-range, specific-reports)
  private buildScopedReportWhere(
    link: ShareLinkEntity,
  ): FindOptionsWhere<ReportEntity> {
    // Double isolation: profileId (profile boundary) + userId (owner boundary)
    // scope='all' is the only defined value today; extend for future scope types
    const base: FindOptionsWhere<ReportEntity> = {
      profileId: link.profileId,
      userId: link.userId,
      status: 'parsed' as const,
      deletedAt: IsNull(),
    };
    switch (link.scope) {
      case 'all':
      default:
        return base;
    }
  }

  private toDto(entity: ShareLinkEntity): ShareLinkDto {
    return {
      id: entity.id,
      token: entity.token,
      shareUrl: `${this.shareBaseUrl}/share/${entity.token}`,
      profileId: entity.profileId,
      scope: entity.scope,
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

  async getPublicShareData(token: string): Promise<PublicShareDto> {
    const link = await this.shareLinkRepo.findOne({ where: { token } });
    if (!link) throw new ShareLinkNotFoundException(); // no recording — no link to associate

    // Record event BEFORE validity check — captures both 'accessed' and 'expired_or_revoked'
    const outcome = this.isLinkValid(link) ? 'accessed' : 'expired_or_revoked';
    await this.accessEventRepo.save(
      this.accessEventRepo.create({ shareLinkId: link.id, outcome }),
    );

    if (!this.isLinkValid(link)) throw new ShareLinkExpiredException();

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
        where: { reportId: In(reportIds) },
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
      reports: reports.map((r) => ({
        id: r.id,
        originalFileName: r.originalFileName,
        status: r.status,
        summary: r.summary,
        createdAt: r.createdAt.toISOString(),
        labValues: (labByReport.get(r.id) ?? []).map((lv) => ({
          parameterName: lv.parameterName,
          value: lv.value,
          unit: lv.unit,
        })),
      })),
    };
  }

  async createShareLink(
    userId: string,
    profileId: string,
    scope = 'all',
    expiresAt?: Date,
  ): Promise<ShareLinkDto> {
    if (expiresAt && expiresAt <= new Date()) {
      throw new BadRequestException({
        code: EXPIRY_MUST_BE_FUTURE,
        message: 'expiresAt must be a future date',
      });
    }
    // Throws ProfileNotFoundException (404) if user doesn't own profile
    await this.profilesService.getProfile(userId, profileId);
    const planInfo = await this.usageLimitsService.getPlanLimits(userId);
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
        expiresAt: expiresAt ?? null,
      });
      const saved = await manager.save(entity);
      return this.toDto(saved);
    });
  }

  async listShareLinks(
    userId: string,
    profileId: string,
  ): Promise<ShareLinkDto[]> {
    // Ownership check: ProfilesService throws ProfileNotFoundException if not owned
    await this.profilesService.getProfile(userId, profileId);
    const now = new Date();
    const links = await this.shareLinkRepo.find({
      where: {
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
