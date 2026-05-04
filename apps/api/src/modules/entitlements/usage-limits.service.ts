import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, Repository } from 'typeorm';
import { ReportEntity } from '../../database/entities/report.entity';
import { ShareLinkEntity } from '../../database/entities/share-link.entity';
import { UserEntitlementEntity } from '../../database/entities/user-entitlement.entity';
import type { PlanLimits } from '../../database/entities/plan.entity';
import type { PlanTier } from './entitlements.types';
import { EntitlementsService } from './entitlements.service';

export interface UsageLimitSnapshot {
  limit: number;
  current: number;
  planName: string;
  tier: PlanTier;
  upgradeHint: string;
}

export interface PlanLimitInfo {
  planName: string;
  tier: PlanTier;
  limits: PlanLimits;
}

@Injectable()
export class UsageLimitsService {
  constructor(
    private readonly entitlementsService: EntitlementsService,
    @InjectRepository(ReportEntity)
    private readonly reportRepo: Repository<ReportEntity>,
    @InjectRepository(ShareLinkEntity)
    private readonly shareLinkRepo: Repository<ShareLinkEntity>,
  ) {}

  async getPlanLimits(userId: string): Promise<PlanLimitInfo> {
    const planInfo = await this.entitlementsService.getPlanLimits(userId);
    return planInfo;
  }

  async getReportUsage(userId: string): Promise<UsageLimitSnapshot> {
    const planInfo = await this.getPlanLimits(userId);
    // Count both active and recycle-bin reports.
    // This prevents quota bypass by delete/re-upload loops.
    // Recycle-bin reports stop counting only after permanent purge.
    const current = await this.reportRepo.count({ where: { userId } });
    return {
      limit: planInfo.limits.maxReports,
      current,
      planName: planInfo.planName,
      tier: planInfo.tier,
      upgradeHint: this.buildUpgradeHint(planInfo.tier),
    };
  }

  async getShareLinkUsage(
    userId: string,
    manager?: EntityManager,
    planInfo?: PlanLimitInfo,
  ): Promise<UsageLimitSnapshot> {
    const resolvedPlanInfo = planInfo ?? (await this.getPlanLimits(userId));
    const repo = manager
      ? manager.getRepository(ShareLinkEntity)
      : this.shareLinkRepo;
    const now = new Date();
    const current = await repo
      .createQueryBuilder('share_link')
      .where('share_link.userId = :userId', { userId })
      .andWhere('share_link.isActive = true')
      .andWhere(
        '(share_link.expiresAt IS NULL OR share_link.expiresAt > :now)',
        {
          now,
        },
      )
      .getCount();
    return {
      limit: resolvedPlanInfo.limits.maxShareLinks,
      current,
      planName: resolvedPlanInfo.planName,
      tier: resolvedPlanInfo.tier,
      upgradeHint: this.buildUpgradeHint(resolvedPlanInfo.tier),
    };
  }

  async lockEntitlementForUpdate(
    userId: string,
    manager: EntityManager,
  ): Promise<void> {
    await manager
      .getRepository(UserEntitlementEntity)
      .createQueryBuilder('entitlement')
      .setLock('pessimistic_write')
      .where('entitlement.userId = :userId', { userId })
      .getOne();
  }

  private buildUpgradeHint(tier: PlanTier): string {
    if (tier === 'free') {
      return 'Upgrade to Pro or buy credits in Billing.';
    }
    return 'Manage your plan or buy credits in Billing.';
  }
}
