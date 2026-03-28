import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, Repository } from 'typeorm';
import { PlanEntity } from '../../database/entities/plan.entity';
import { PlanConfigAuditEventEntity } from '../../database/entities/plan-config-audit-event.entity';
import { UserEntitlementEntity } from '../../database/entities/user-entitlement.entity';
import type { PlanLimits } from '../../database/entities/plan.entity';
import type {
  EntitlementSummaryDto,
  PlanConfigRecalculationDto,
  PlanConfigSummaryDto,
  PlanTier,
} from './entitlements.types';
import { PLAN_CONFIG_VERSION_CONFLICT } from './entitlements.types';
import type { UpdatePlanConfigDto } from './entitlements.dto';
import { PlanConfigNotFoundException } from './exceptions/plan-config-not-found.exception';
import { PlanConfigValidationException } from './exceptions/plan-config-validation.exception';
import { PlanConfigVersionConflictException } from './exceptions/plan-config-version-conflict.exception';

@Injectable()
export class EntitlementsService {
  private readonly logger = new Logger(EntitlementsService.name);

  constructor(
    private readonly configService: ConfigService,
    @InjectRepository(PlanEntity)
    private readonly planRepo: Repository<PlanEntity>,
    @InjectRepository(UserEntitlementEntity)
    private readonly entitlementRepo: Repository<UserEntitlementEntity>,
  ) {}

  /**
   * Returns the full entitlement summary for a user.
   * Auto-provisions a free-tier entitlement if none exists (lazy provisioning).
   */
  async getEntitlementSummary(userId: string): Promise<EntitlementSummaryDto> {
    const entitlement = await this.findOrProvision(userId);

    return {
      planName: entitlement.plan.name,
      tier: entitlement.plan.tier as EntitlementSummaryDto['tier'],
      creditBalance: parseFloat(entitlement.creditBalance),
      status: entitlement.status as EntitlementSummaryDto['status'],
      limits: entitlement.plan.limits,
      activatedAt: entitlement.activatedAt.toISOString(),
      expiresAt: entitlement.expiresAt
        ? entitlement.expiresAt.toISOString()
        : null,
    };
  }

  /**
   * Returns the credit balance for a user.
   */
  async getCreditBalance(userId: string): Promise<number> {
    const entitlement = await this.findOrProvision(userId);
    return parseFloat(entitlement.creditBalance);
  }

  /**
   * Returns max profiles allowed for the user's plan.
   * Preserves E2E_MAX_PROFILES env override for tests.
   */
  async getMaxProfiles(userId: string): Promise<number> {
    const e2eOverride = this.configService.get<string>('E2E_MAX_PROFILES');
    if (e2eOverride) {
      const n = parseInt(e2eOverride, 10);
      if (!Number.isNaN(n)) return n;
    }

    const entitlement = await this.findOrProvision(userId);
    return entitlement.plan.limits.maxProfiles;
  }

  /**
   * Atomically increments the user's credit balance.
   * Uses raw query to avoid read-then-write race conditions.
   */
  async addCredits(userId: string, amount: number): Promise<void> {
    // Ensure entitlement exists (lazy provisioning)
    await this.findOrProvision(userId);

    await this.entitlementRepo
      .createQueryBuilder()
      .update(UserEntitlementEntity)
      .set({ creditBalance: () => `credit_balance + ${amount}` })
      .where('user_id = :userId', { userId })
      .execute();
  }

  /**
   * Returns all active plans (for billing plan listing).
   */
  async getActivePlans(): Promise<PlanEntity[]> {
    return this.planRepo.find({
      where: { isActive: true },
      order: { createdAt: 'ASC' },
    });
  }

  /**
   * Returns plan limits for the user's entitlement.
   */
  async getPlanLimits(
    userId: string,
  ): Promise<{ planName: string; tier: PlanTier; limits: PlanLimits }> {
    const entitlement = await this.findOrProvision(userId);
    return {
      planName: entitlement.plan.name,
      tier: entitlement.plan.tier as PlanTier,
      limits: entitlement.plan.limits,
    };
  }

  /**
   * Returns a single plan by ID, or null if not found.
   */
  async getPlanById(planId: string): Promise<PlanEntity | null> {
    return this.planRepo.findOne({ where: { id: planId } });
  }

  /**
   * Lists plan configurations for superadmin management.
   */
  async listPlanConfigurations(): Promise<PlanConfigSummaryDto[]> {
    const plans = await this.planRepo.find({
      order: { createdAt: 'ASC' },
    });
    return plans.map((plan) => this.toPlanConfigSummary(plan));
  }

  /**
   * Updates plan limits with optimistic locking, deterministic no-op semantics,
   * and versioned audit traces for governance.
   */
  async updatePlanConfiguration(input: {
    actorUserId: string;
    planId: string;
    dto: UpdatePlanConfigDto;
    correlationId: string;
  }): Promise<{
    plan: PlanConfigSummaryDto;
    recalculation: PlanConfigRecalculationDto;
    state: 'pending' | 'success' | 'failure' | 'reverted';
  }> {
    return this.planRepo.manager.transaction(async (manager) => {
      const repo = manager.getRepository(PlanEntity);

      const plan = await repo
        .createQueryBuilder('plan')
        .setLock('pessimistic_write')
        .where('plan.id = :planId', { planId: input.planId })
        .getOne();

      if (!plan) {
        throw new PlanConfigNotFoundException(input.planId);
      }

      this.validatePlanLimits(input.dto);

      const previousVersion = plan.configVersion;
      if (
        input.dto.expectedConfigVersion !== undefined &&
        input.dto.expectedConfigVersion !== previousVersion
      ) {
        await this.recordPlanConfigAudit({
          manager,
          actorUserId: input.actorUserId,
          planId: plan.id,
          action: 'PLAN_CONFIG_UPDATE',
          target: `plan:${plan.id}`,
          outcome: 'reverted',
          correlationId: input.correlationId,
          previousConfigVersion: previousVersion,
          newConfigVersion: previousVersion,
          errorCode: PLAN_CONFIG_VERSION_CONFLICT,
          metadata: {
            expectedConfigVersion: input.dto.expectedConfigVersion,
            actualConfigVersion: previousVersion,
          },
        });

        throw new PlanConfigVersionConflictException(
          input.dto.expectedConfigVersion,
          previousVersion,
        );
      }

      const nextLimits = this.toPlanLimits(input.dto);
      const limitsChanged = !this.sameLimits(plan.limits, nextLimits);

      if (!limitsChanged) {
        const recalculation = this.buildRecalculationDescriptor(
          previousVersion,
          previousVersion,
        );
        await this.recordPlanConfigAudit({
          manager,
          actorUserId: input.actorUserId,
          planId: plan.id,
          action: 'PLAN_CONFIG_UPDATE',
          target: `plan:${plan.id}`,
          outcome: 'success',
          correlationId: input.correlationId,
          previousConfigVersion: previousVersion,
          newConfigVersion: previousVersion,
          metadata: {
            noOp: true,
            deterministic: true,
          },
        });

        return {
          plan: this.toPlanConfigSummary(plan),
          recalculation,
          state: 'success',
        };
      }

      plan.limits = nextLimits;
      const saved = await repo.save(plan);

      const recalculation = this.buildRecalculationDescriptor(
        previousVersion,
        saved.configVersion,
      );

      await this.recordPlanConfigAudit({
        manager,
        actorUserId: input.actorUserId,
        planId: saved.id,
        action: 'PLAN_CONFIG_UPDATE',
        target: `plan:${saved.id}`,
        outcome: 'success',
        correlationId: input.correlationId,
        previousConfigVersion: previousVersion,
        newConfigVersion: saved.configVersion,
        metadata: {
          maxProfilesPerPlan: nextLimits.maxProfiles,
          reportCap: nextLimits.maxReports,
          shareLinkLimit: nextLimits.maxShareLinks,
          aiChatEnabled: nextLimits.aiChatEnabled,
        },
      });

      return {
        plan: this.toPlanConfigSummary(saved),
        recalculation,
        state: 'success',
      };
    });
  }

  /**
   * Upgrades user's plan. Does NOT reset credit balance.
   */
  async upgradePlan(
    userId: string,
    planId: string,
    expiresAt?: Date,
  ): Promise<void> {
    await this.findOrProvision(userId);
    await this.entitlementRepo
      .createQueryBuilder()
      .update(UserEntitlementEntity)
      .set({ planId, expiresAt: expiresAt ?? null, status: 'active' })
      .where('user_id = :userId', { userId })
      .execute();
  }

  /**
   * Downgrades user to specified plan (free tier fallback on cancellation/halt).
   */
  async downgradeToPlan(userId: string, planId: string): Promise<void> {
    await this.findOrProvision(userId);
    await this.entitlementRepo
      .createQueryBuilder()
      .update(UserEntitlementEntity)
      .set({ planId, expiresAt: null, status: 'active' })
      .where('user_id = :userId', { userId })
      .execute();
  }

  /**
   * Finds existing entitlement or auto-provisions free-tier for the user.
   */
  private async findOrProvision(
    userId: string,
  ): Promise<UserEntitlementEntity> {
    const existing = await this.entitlementRepo.findOne({
      where: { userId },
    });
    if (existing) return existing;

    // Auto-provision: find the free-tier plan and create an entitlement
    const freePlan = await this.planRepo.findOne({
      where: { tier: 'free', isActive: true },
    });
    if (!freePlan) {
      throw new Error(
        'Free-tier plan not found in database. Run migrations to seed it.',
      );
    }

    const entitlement = this.entitlementRepo.create({
      userId,
      planId: freePlan.id,
      creditBalance: '0',
      status: 'active',
    });
    const saved = await this.entitlementRepo.save(entitlement);

    // Reload with plan relation (eager load)
    const reloaded = await this.entitlementRepo.findOneOrFail({
      where: { id: saved.id },
    });
    return reloaded;
  }

  private validatePlanLimits(dto: UpdatePlanConfigDto): void {
    if (dto.maxProfilesPerPlan < 1) {
      throw new PlanConfigValidationException(
        'maxProfilesPerPlan must be at least 1',
      );
    }

    if (dto.reportCap < 1) {
      throw new PlanConfigValidationException('reportCap must be at least 1');
    }

    if (dto.shareLinkLimit < 0) {
      throw new PlanConfigValidationException(
        'shareLinkLimit must be zero or greater',
      );
    }
  }

  private toPlanLimits(dto: UpdatePlanConfigDto): PlanLimits {
    return {
      maxProfiles: dto.maxProfilesPerPlan,
      maxReports: dto.reportCap,
      maxShareLinks: dto.shareLinkLimit,
      aiChatEnabled: dto.aiChatEnabled,
    };
  }

  private sameLimits(left: PlanLimits, right: PlanLimits): boolean {
    return (
      left.maxProfiles === right.maxProfiles &&
      left.maxReports === right.maxReports &&
      left.maxShareLinks === right.maxShareLinks &&
      left.aiChatEnabled === right.aiChatEnabled
    );
  }

  private toPlanConfigSummary(plan: PlanEntity): PlanConfigSummaryDto {
    return {
      planId: plan.id,
      planName: plan.name,
      tier: plan.tier as PlanTier,
      isActive: plan.isActive,
      configVersion: plan.configVersion,
      limits: {
        maxProfilesPerPlan: plan.limits.maxProfiles,
        reportCap: plan.limits.maxReports,
        shareLinkLimit: plan.limits.maxShareLinks,
        aiChatEnabled: plan.limits.aiChatEnabled,
      },
      updatedAt: plan.updatedAt.toISOString(),
    };
  }

  private buildRecalculationDescriptor(
    previousConfigVersion: number,
    newConfigVersion: number,
  ): PlanConfigRecalculationDto {
    return {
      mode: 'deterministic_non_destructive',
      backwardCompatible: true,
      previousConfigVersion,
      newConfigVersion,
      impact: {
        activeEntitlementsUnaffected: true,
        enforcementOnNewOperationsOnly: true,
      },
    };
  }

  private async recordPlanConfigAudit(input: {
    manager: EntityManager;
    actorUserId: string;
    planId: string;
    action: string;
    target: string;
    outcome: 'success' | 'failure' | 'denied' | 'reverted';
    correlationId: string;
    previousConfigVersion: number;
    newConfigVersion: number;
    errorCode?: string;
    metadata?: Record<string, string | number | boolean | null>;
  }): Promise<void> {
    const auditRepo = input.manager.getRepository(PlanConfigAuditEventEntity);
    await auditRepo.save(
      auditRepo.create({
        actorUserId: input.actorUserId,
        planId: input.planId,
        action: input.action,
        target: input.target,
        outcome: input.outcome,
        correlationId: input.correlationId,
        previousConfigVersion: input.previousConfigVersion,
        newConfigVersion: input.newConfigVersion,
        errorCode: input.errorCode ?? null,
        metadata: input.metadata ?? null,
      }),
    );

    this.logger.log(
      JSON.stringify({
        action: input.action,
        target: input.target,
        outcome: input.outcome,
        correlationId: input.correlationId,
        actorUserId: input.actorUserId,
        planId: input.planId,
        previousConfigVersion: input.previousConfigVersion,
        newConfigVersion: input.newConfigVersion,
        errorCode: input.errorCode,
      }),
    );
  }
}
