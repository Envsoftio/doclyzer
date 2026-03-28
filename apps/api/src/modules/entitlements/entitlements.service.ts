import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PlanEntity } from '../../database/entities/plan.entity';
import { UserEntitlementEntity } from '../../database/entities/user-entitlement.entity';
import type { EntitlementSummaryDto } from './entitlements.types';

@Injectable()
export class EntitlementsService {
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
  async getEntitlementSummary(
    userId: string,
  ): Promise<EntitlementSummaryDto> {
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
   * Returns a single plan by ID, or null if not found.
   */
  async getPlanById(planId: string): Promise<PlanEntity | null> {
    return this.planRepo.findOne({ where: { id: planId } });
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
}
