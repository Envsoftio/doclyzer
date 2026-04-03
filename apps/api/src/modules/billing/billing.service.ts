import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'node:crypto';
import { DataSource, EntityManager, Repository } from 'typeorm';
import { CreditPackEntity } from '../../database/entities/credit-pack.entity';
import { OrderEntity } from '../../database/entities/order.entity';
import { PromoCodeEntity } from '../../database/entities/promo-code.entity';
import { PromoCodeAuditEventEntity } from '../../database/entities/promo-code-audit-event.entity';
import { PromoRedemptionEntity } from '../../database/entities/promo-redemption.entity';
import { SubscriptionEntity } from '../../database/entities/subscription.entity';
import { SuperadminAuthAuditEventEntity } from '../../database/entities/superadmin-auth-audit-event.entity';
import { UserEntitlementEntity } from '../../database/entities/user-entitlement.entity';
import { NotificationPipelineService } from '../../common/notification-pipeline/notification-pipeline.service';
import { NotifiableEventType } from '../../common/notification-pipeline/notification-event.types';
import { EntitlementsService } from '../entitlements/entitlements.service';
import { RazorpayService } from './razorpay.service';
import {
  BILLING_ALREADY_SUBSCRIBED,
  BILLING_ANALYTICS_DATE_RANGE_INVALID,
  BILLING_INVALID_SIGNATURE,
  BILLING_ORDER_NOT_FOUND,
  BILLING_PACK_INACTIVE,
  BILLING_PACK_NOT_FOUND,
  BILLING_PLAN_INACTIVE,
  BILLING_PLAN_NOT_FOUND,
  BILLING_PROMO_CAP_REACHED,
  BILLING_PROMO_CODE_DUPLICATE,
  BILLING_PROMO_DATE_RANGE_INVALID,
  BILLING_PROMO_EXPIRED,
  BILLING_PROMO_INACTIVE,
  BILLING_PROMO_NOT_APPLICABLE,
  BILLING_PROMO_NOT_FOUND,
  BILLING_PROMO_USER_CAP_REACHED,
  BILLING_SUBSCRIPTION_INVALID_SIGNATURE,
  BILLING_SUBSCRIPTION_NOT_FOUND,
} from './billing.types';
import type {
  CreditPackResponseDto,
  CreateOrderResponseDto,
  CreateSubscriptionResponseDto,
  OrderStatusDto,
  PlanResponseDto,
  PromoProductType,
  PromoValidationResponseDto,
  PromoCodeAdminDto,
  PromoAnalyticsExportResponseDto,
  PromoAnalyticsResponseDto,
  PromoAnalyticsRowDto,
  PromoAnalyticsSummaryDto,
  PromoLifecycleResponseDto,
  VerifyPaymentResponseDto,
  VerifySubscriptionResponseDto,
} from './billing.types';
import type {
  AdminCreatePromoCodeDto,
  AdminPromoAnalyticsExportDto,
  AdminPromoAnalyticsQueryDto,
  AdminUpdatePromoCodeDto,
} from './billing.types';
import { toOrderStatusDto } from './billing.types';

@Injectable()
export class BillingService {
  private readonly logger = new Logger(BillingService.name);
  private readonly EXPORT_ROW_CAP = 1000;

  constructor(
    @InjectRepository(CreditPackEntity)
    private readonly creditPackRepo: Repository<CreditPackEntity>,
    @InjectRepository(OrderEntity)
    private readonly orderRepo: Repository<OrderEntity>,
    @InjectRepository(PromoRedemptionEntity)
    private readonly promoRedemptionRepo: Repository<PromoRedemptionEntity>,
    @InjectRepository(PromoCodeEntity)
    private readonly promoCodeRepo: Repository<PromoCodeEntity>,
    @InjectRepository(SubscriptionEntity)
    private readonly subscriptionRepo: Repository<SubscriptionEntity>,
    @InjectRepository(SuperadminAuthAuditEventEntity)
    private readonly superadminAuditRepo: Repository<SuperadminAuthAuditEventEntity>,
    private readonly dataSource: DataSource,
    private readonly razorpayService: RazorpayService,
    private readonly entitlementsService: EntitlementsService,
    private readonly notificationPipeline: NotificationPipelineService,
  ) {}

  async listCreditPacks(): Promise<CreditPackResponseDto[]> {
    const packs = await this.creditPackRepo.find({
      where: { isActive: true },
      order: { sortOrder: 'ASC' },
    });

    return packs.map((p) => ({
      id: p.id,
      name: p.name,
      credits: p.credits,
      priceInr: parseFloat(p.priceInr),
      priceUsd: parseFloat(p.priceUsd),
    }));
  }

  async listRecentOrders(userId: string, limit = 5): Promise<OrderStatusDto[]> {
    const safeLimit = Math.max(1, Math.min(limit, 5));
    const orders = await this.orderRepo.find({
      where: { userId },
      order: { updatedAt: 'DESC' },
      take: safeLimit,
    });

    return orders.map((order) => toOrderStatusDto(order));
  }

  async createOrder(
    userId: string,
    creditPackId: string,
    promoCode?: string,
  ): Promise<CreateOrderResponseDto> {
    const pack = await this.creditPackRepo.findOne({
      where: { id: creditPackId },
    });
    if (!pack) {
      throw new NotFoundException({
        code: BILLING_PACK_NOT_FOUND,
        message: 'Credit pack not found',
      });
    }
    if (!pack.isActive) {
      throw new BadRequestException({
        code: BILLING_PACK_INACTIVE,
        message: 'Credit pack is no longer available',
      });
    }

    const baseAmount = parseFloat(pack.priceInr);
    const currency = 'INR';

    if (!promoCode?.trim()) {
      const amountInPaise = Math.round(baseAmount * 100);
      const razorpayOrder = await this.razorpayService.createOrder(
        amountInPaise,
        currency,
        `order_${userId}_${creditPackId}`,
      );

      const order = this.orderRepo.create({
        userId,
        creditPackId: pack.id,
        amount: pack.priceInr,
        currency,
        status: 'pending',
        razorpayOrderId: razorpayOrder.id,
        razorpayPaymentId: null,
        razorpaySignature: null,
        credited: false,
        promoCodeId: null,
        discountAmount: null,
        finalAmount: baseAmount.toFixed(2),
        metadata: null,
      });
      const saved = await this.orderRepo.save(order);

      return {
        orderId: saved.id,
        razorpayOrderId: razorpayOrder.id,
        amount: amountInPaise,
        currency,
        razorpayKeyId: this.razorpayService.keyId,
      };
    }

    // Keep promo validation + reservation atomic to prevent cap over-redemption.
    return this.dataSource.transaction(async (manager) => {
      const promo = await this.validatePromoForCreditPack(
        userId,
        promoCode,
        creditPackId,
        manager,
      );
      const amountInPaise = Math.round(promo.finalAmount * 100);
      const razorpayOrder = await this.razorpayService.createOrder(
        amountInPaise,
        currency,
        `order_${userId}_${creditPackId}`,
      );

      const order = manager.create(OrderEntity, {
        userId,
        creditPackId: pack.id,
        amount: pack.priceInr,
        currency,
        status: 'pending',
        razorpayOrderId: razorpayOrder.id,
        razorpayPaymentId: null,
        razorpaySignature: null,
        credited: false,
        promoCodeId: promo.promoCodeId,
        discountAmount: promo.discountAmount.toFixed(2),
        finalAmount: promo.finalAmount.toFixed(2),
        metadata: null,
      });
      const saved = await manager.save(OrderEntity, order);
      await this.reservePromoRedemption(saved, manager);

      return {
        orderId: saved.id,
        razorpayOrderId: razorpayOrder.id,
        amount: amountInPaise,
        currency,
        razorpayKeyId: this.razorpayService.keyId,
      };
    });
  }

  async verifyPayment(
    userId: string,
    razorpayOrderId: string,
    razorpayPaymentId: string,
    razorpaySignature: string,
  ): Promise<VerifyPaymentResponseDto> {
    // Verify signature
    const isValid = this.razorpayService.verifyPaymentSignature(
      razorpayOrderId,
      razorpayPaymentId,
      razorpaySignature,
    );
    if (!isValid) {
      throw new BadRequestException({
        code: BILLING_INVALID_SIGNATURE,
        message: 'Invalid payment signature',
      });
    }

    const order = await this.orderRepo.findOne({
      where: { razorpayOrderId, userId },
      relations: ['creditPack'],
    });
    if (!order) {
      throw new NotFoundException({
        code: BILLING_ORDER_NOT_FOUND,
        message: 'Order not found',
      });
    }

    // Idempotent: if already reconciled, keep response stable.
    if (this.isReconciled(order.status, order.credited)) {
      await this.recordPromoRedemption(order);
      const summary =
        await this.entitlementsService.getEntitlementSummary(userId);
      return {
        creditsAdded: order.creditPack.credits,
        orderStatus: 'reconciled',
        entitlementSummary: summary,
      };
    }

    // Capture verification proves payment auth, but reconciliation happens on webhook.
    order.status = 'paid';
    order.razorpayPaymentId = razorpayPaymentId;
    order.razorpaySignature = razorpaySignature;
    order.credited = false;
    order.metadata = this.withoutFailureReason(order.metadata);
    await this.orderRepo.save(order);

    const summary =
      await this.entitlementsService.getEntitlementSummary(userId);
    return {
      creditsAdded: 0,
      orderStatus: 'paid',
      entitlementSummary: summary,
    };
  }

  async handleWebhookPaymentCaptured(
    razorpayOrderId: string,
    razorpayPaymentId: string,
    correlationId: string,
  ): Promise<void> {
    const order = await this.orderRepo.findOne({
      where: { razorpayOrderId },
      relations: ['creditPack'],
    });
    if (!order) {
      this.logger.warn(
        `Webhook: order not found for razorpay_order_id=${razorpayOrderId}`,
      );
      return;
    }

    // Idempotent: if already reconciled or credited, skip
    if (order.status === 'reconciled') return;

    const now = new Date();
    await this.dataSource.transaction(async (manager) => {
      if (!order.credited) {
        // Credit balance atomically
        await manager
          .createQueryBuilder()
          .update(UserEntitlementEntity)
          .set({
            creditBalance: () => `credit_balance + ${order.creditPack.credits}`,
            lastChangeReason: 'credit_pack_purchase',
            lastChangeAt: now,
          })
          .where('user_id = :userId', { userId: order.userId })
          .execute();
      }

      await manager.update(OrderEntity, order.id, {
        status: 'reconciled',
        razorpayPaymentId,
        credited: true,
      });

      await this.recordPromoRedemption(order, manager);
    });

    this.logger.log(
      `Webhook: order ${order.id} reconciled (razorpay_order_id=${razorpayOrderId})`,
    );

    void this.notificationPipeline
      .dispatch({
        eventType: NotifiableEventType.BILLING_PAYMENT_SUCCESS,
        userId: order.userId,
        correlationId,
      })
      .catch((err) => {
        this.logger.warn(
          JSON.stringify({
            action: 'NOTIFICATION_DISPATCH_FAILED',
            eventType: NotifiableEventType.BILLING_PAYMENT_SUCCESS,
            correlationId,
            error: err instanceof Error ? err.message : String(err),
          }),
        );
      });
  }

  async handleWebhookPaymentFailed(
    razorpayOrderId: string,
    reason?: string,
    correlationId?: string,
  ): Promise<void> {
    const order = await this.orderRepo.findOne({
      where: { razorpayOrderId },
    });
    if (!order) {
      this.logger.warn(
        `Webhook: order not found for razorpay_order_id=${razorpayOrderId}`,
      );
      return;
    }

    // Don't downgrade reconciled/paid orders
    if (order.status === 'reconciled' || order.status === 'paid') return;

    order.status = 'failed';
    order.metadata = this.withFailureReason(order.metadata, reason);
    await this.orderRepo.save(order);
    await this.voidPromoReservation(order.id);
    this.logger.log(
      `Webhook: order ${order.id} marked failed (razorpay_order_id=${razorpayOrderId})`,
    );

    if (correlationId) {
      void this.notificationPipeline
        .dispatch({
          eventType: NotifiableEventType.BILLING_PAYMENT_FAILED,
          userId: order.userId,
          correlationId,
        })
        .catch((err) => {
          this.logger.warn(
            JSON.stringify({
              action: 'NOTIFICATION_DISPATCH_FAILED',
              eventType: NotifiableEventType.BILLING_PAYMENT_FAILED,
              correlationId,
              error: err instanceof Error ? err.message : String(err),
            }),
          );
        });
    }
  }

  async listPlans(userId: string): Promise<PlanResponseDto[]> {
    const plans = await this.entitlementsService.getActivePlans();
    const summary =
      await this.entitlementsService.getEntitlementSummary(userId);

    return plans
      .filter((p) => p.tier !== 'free')
      .map((p) => ({
        id: p.id,
        name: p.name,
        tier: p.tier,
        limits: p.limits,
        priceInfo: p.priceInfo,
        isCurrentPlan: summary.planName === p.name,
      }));
  }

  async createSubscription(
    userId: string,
    planId: string,
    promoCode?: string,
  ): Promise<CreateSubscriptionResponseDto> {
    if (promoCode?.trim()) {
      throw new BadRequestException({
        code: BILLING_PROMO_NOT_APPLICABLE,
        message: 'Promo codes are not supported for subscriptions yet',
      });
    }
    const plan = await this.entitlementsService.getPlanById(planId);
    if (!plan) {
      throw new NotFoundException({
        code: BILLING_PLAN_NOT_FOUND,
        message: 'Plan not found',
      });
    }
    if (!plan.isActive) {
      throw new BadRequestException({
        code: BILLING_PLAN_INACTIVE,
        message: 'Plan is no longer available',
      });
    }
    if (plan.tier === 'free') {
      throw new BadRequestException({
        code: BILLING_PLAN_INACTIVE,
        message: 'Cannot subscribe to the free plan',
      });
    }

    // Check for existing active subscription
    const existingActive = await this.subscriptionRepo.findOne({
      where: { userId, status: 'active' },
    });
    if (existingActive) {
      throw new BadRequestException({
        code: BILLING_ALREADY_SUBSCRIBED,
        message:
          'You already have an active subscription. Cancel it first before subscribing to a new plan.',
      });
    }

    if (!plan.razorpayPlanId) {
      throw new BadRequestException({
        code: BILLING_PLAN_INACTIVE,
        message: 'Plan is not configured for subscriptions',
      });
    }

    // Create Razorpay subscription
    const razorpaySub = await this.razorpayService.createSubscription(
      plan.razorpayPlanId,
      12,
    );

    // Persist subscription record
    const subscription = this.subscriptionRepo.create({
      userId,
      planId: plan.id,
      status: 'created',
      razorpaySubscriptionId: razorpaySub.id,
      razorpayPaymentId: null,
      razorpaySignature: null,
      currentPeriodStart: null,
      currentPeriodEnd: null,
      metadata: null,
    });
    const saved = await this.subscriptionRepo.save(subscription);

    return {
      subscriptionId: saved.id,
      razorpaySubscriptionId: razorpaySub.id,
      razorpayKeyId: this.razorpayService.keyId,
      planName: plan.name,
    };
  }

  async verifySubscription(
    userId: string,
    razorpaySubscriptionId: string,
    razorpayPaymentId: string,
    razorpaySignature: string,
    correlationId: string,
  ): Promise<VerifySubscriptionResponseDto> {
    const isValid = this.razorpayService.verifySubscriptionSignature(
      razorpaySubscriptionId,
      razorpayPaymentId,
      razorpaySignature,
    );
    if (!isValid) {
      throw new BadRequestException({
        code: BILLING_SUBSCRIPTION_INVALID_SIGNATURE,
        message: 'Invalid subscription signature',
      });
    }

    const subscription = await this.subscriptionRepo.findOne({
      where: { razorpaySubscriptionId, userId },
      relations: ['plan'],
    });
    if (!subscription) {
      throw new NotFoundException({
        code: BILLING_SUBSCRIPTION_NOT_FOUND,
        message: 'Subscription not found',
      });
    }

    // Idempotent: if already active, just return current summary
    if (subscription.status === 'active') {
      const summary =
        await this.entitlementsService.getEntitlementSummary(userId);
      return {
        planName: subscription.plan.name,
        entitlementSummary: summary,
      };
    }

    // Activate subscription and upgrade plan atomically
    const now = new Date();
    const periodEnd = new Date(now);
    periodEnd.setMonth(periodEnd.getMonth() + 1);

    await this.dataSource.transaction(async (manager) => {
      await manager.update(SubscriptionEntity, subscription.id, {
        status: 'active',
        razorpayPaymentId,
        razorpaySignature,
        currentPeriodStart: now,
        currentPeriodEnd: periodEnd,
      });
    });

    // Upgrade user's plan (outside transaction — EntitlementsService handles its own)
    await this.entitlementsService.upgradePlan(
      userId,
      subscription.planId,
      periodEnd,
    );

    void this.notificationPipeline
      .dispatch({
        eventType: NotifiableEventType.SUBSCRIPTION_ACTIVATED,
        userId,
        correlationId,
      })
      .catch((err) => {
        this.logger.warn(
          JSON.stringify({
            action: 'NOTIFICATION_DISPATCH_FAILED',
            eventType: NotifiableEventType.SUBSCRIPTION_ACTIVATED,
            correlationId,
            error: err instanceof Error ? err.message : String(err),
          }),
        );
      });

    const summary =
      await this.entitlementsService.getEntitlementSummary(userId);
    return {
      planName: subscription.plan.name,
      entitlementSummary: summary,
    };
  }

  async handleWebhookSubscriptionActivated(
    razorpaySubscriptionId: string,
    razorpayPaymentId: string,
    correlationId?: string,
  ): Promise<void> {
    const resolvedCorrelationId = correlationId ?? randomUUID();
    const subscription = await this.subscriptionRepo.findOne({
      where: { razorpaySubscriptionId },
    });
    if (!subscription) {
      this.logger.warn(
        `Webhook: subscription not found for razorpay_subscription_id=${razorpaySubscriptionId}`,
      );
      return;
    }

    // Idempotent: if already active, skip
    if (subscription.status === 'active') return;

    const now = new Date();
    const periodEnd = new Date(now);
    periodEnd.setMonth(periodEnd.getMonth() + 1);

    await this.subscriptionRepo.update(subscription.id, {
      status: 'active',
      razorpayPaymentId,
      currentPeriodStart: now,
      currentPeriodEnd: periodEnd,
    });

    await this.entitlementsService.upgradePlan(
      subscription.userId,
      subscription.planId,
      periodEnd,
    );

    this.logger.log(
      `Webhook: subscription ${subscription.id} activated (razorpay_subscription_id=${razorpaySubscriptionId})`,
    );

    void this.notificationPipeline
      .dispatch({
        eventType: NotifiableEventType.SUBSCRIPTION_ACTIVATED,
        userId: subscription.userId,
        correlationId: resolvedCorrelationId,
      })
      .catch((err) => {
        this.logger.warn(
          JSON.stringify({
            action: 'NOTIFICATION_DISPATCH_FAILED',
            eventType: NotifiableEventType.SUBSCRIPTION_ACTIVATED,
            correlationId: resolvedCorrelationId,
            error: err instanceof Error ? err.message : String(err),
          }),
        );
      });
  }

  async handleWebhookSubscriptionHalted(
    razorpaySubscriptionId: string,
  ): Promise<void> {
    const subscription = await this.subscriptionRepo.findOne({
      where: { razorpaySubscriptionId },
    });
    if (!subscription) {
      this.logger.warn(
        `Webhook: subscription not found for razorpay_subscription_id=${razorpaySubscriptionId}`,
      );
      return;
    }

    if (subscription.status === 'halted') return;

    await this.subscriptionRepo.update(subscription.id, {
      status: 'halted',
    });

    // Downgrade to free tier
    const freePlans = await this.entitlementsService.getActivePlans();
    const freePlan = freePlans.find((p) => p.tier === 'free');
    if (freePlan) {
      await this.entitlementsService.downgradeToPlan(
        subscription.userId,
        freePlan.id,
      );
    }

    this.logger.log(
      `Webhook: subscription ${subscription.id} halted (razorpay_subscription_id=${razorpaySubscriptionId})`,
    );
  }

  async handleWebhookSubscriptionCancelled(
    razorpaySubscriptionId: string,
    correlationId?: string,
  ): Promise<void> {
    const resolvedCorrelationId = correlationId ?? randomUUID();
    const subscription = await this.subscriptionRepo.findOne({
      where: { razorpaySubscriptionId },
    });
    if (!subscription) {
      this.logger.warn(
        `Webhook: subscription not found for razorpay_subscription_id=${razorpaySubscriptionId}`,
      );
      return;
    }

    if (subscription.status === 'cancelled') return;

    await this.subscriptionRepo.update(subscription.id, {
      status: 'cancelled',
    });

    // Downgrade to free tier
    const freePlans = await this.entitlementsService.getActivePlans();
    const freePlan = freePlans.find((p) => p.tier === 'free');
    if (freePlan) {
      await this.entitlementsService.downgradeToPlan(
        subscription.userId,
        freePlan.id,
      );
    }

    this.logger.log(
      `Webhook: subscription ${subscription.id} cancelled (razorpay_subscription_id=${razorpaySubscriptionId})`,
    );

    void this.notificationPipeline
      .dispatch({
        eventType: NotifiableEventType.SUBSCRIPTION_CANCELLED,
        userId: subscription.userId,
        correlationId: resolvedCorrelationId,
      })
      .catch((err) => {
        this.logger.warn(
          JSON.stringify({
            action: 'NOTIFICATION_DISPATCH_FAILED',
            eventType: NotifiableEventType.SUBSCRIPTION_CANCELLED,
            correlationId: resolvedCorrelationId,
            error: err instanceof Error ? err.message : String(err),
          }),
        );
      });
  }

  async validatePromoCode(
    userId: string,
    promoCode: string,
    productType: PromoProductType,
    productId: string,
  ): Promise<PromoValidationResponseDto> {
    const promo = await this.validatePromo(
      userId,
      promoCode,
      productType,
      productId,
    );

    return {
      discountAmount: promo.discountAmount,
      finalAmount: promo.finalAmount,
      currency: promo.currency,
      promoCodeId: promo.promoCodeId,
    };
  }

  async listPromoCodes(): Promise<PromoCodeAdminDto[]> {
    const promos = await this.promoCodeRepo.find({
      order: { updatedAt: 'DESC' },
    });

    const countsByPromoId = await this.loadRedemptionCountsByPromoId();
    return promos.map((promo) =>
      this.toPromoCodeAdminDto(promo, countsByPromoId[promo.id]),
    );
  }

  async createPromoCode(input: {
    actorUserId: string;
    dto: AdminCreatePromoCodeDto;
    correlationId: string;
  }): Promise<PromoLifecycleResponseDto> {
    this.assertValidDateRange(input.dto.validFrom, input.dto.validUntil);

    const normalizedCode = this.normalizePromoCode(input.dto.code);
    await this.assertPromoCodeUnique(normalizedCode);

    const promo = await this.dataSource.transaction(async (manager) => {
      const repo = manager.getRepository(PromoCodeEntity);
      const created = repo.create({
        code: normalizedCode,
        discountType: input.dto.discountType,
        discountValue: this.roundCurrency(input.dto.discountValue).toFixed(2),
        appliesTo: input.dto.appliesTo,
        validFrom: input.dto.validFrom ? new Date(input.dto.validFrom) : null,
        validUntil: input.dto.validUntil
          ? new Date(input.dto.validUntil)
          : null,
        usageCapTotal: input.dto.usageCapTotal ?? null,
        usageCapPerUser: input.dto.usageCapPerUser ?? null,
        isActive: input.dto.isActive ?? true,
        metadata: null,
      });

      const saved = await repo.save(created);
      await this.recordPromoCodeAudit({
        manager,
        actorUserId: input.actorUserId,
        promoCodeId: saved.id,
        action: 'PROMO_CREATE',
        target: `promo:${saved.id}`,
        outcome: 'success',
        correlationId: input.correlationId,
        metadata: {
          code: saved.code,
          appliesTo: saved.appliesTo,
          isActive: saved.isActive,
        },
      });
      return saved;
    });

    return {
      state: 'success',
      promo: this.toPromoCodeAdminDto(promo),
    };
  }

  async updatePromoCode(input: {
    actorUserId: string;
    promoCodeId: string;
    dto: AdminUpdatePromoCodeDto;
    correlationId: string;
  }): Promise<PromoLifecycleResponseDto> {
    this.assertValidDateRange(input.dto.validFrom, input.dto.validUntil);

    return this.dataSource.transaction(async (manager) => {
      const promo = await this.getPromoForLifecycleChange(
        input.promoCodeId,
        manager,
      );

      const nextCode = promo.code;
      if (nextCode) {
        await this.assertPromoCodeUnique(nextCode, promo.id, manager);
      }

      const nextDiscountType = input.dto.discountType ?? promo.discountType;
      const nextDiscountValue =
        input.dto.discountValue !== undefined
          ? this.roundCurrency(input.dto.discountValue).toFixed(2)
          : promo.discountValue;
      const nextAppliesTo = input.dto.appliesTo ?? promo.appliesTo;
      const nextValidFrom =
        input.dto.validFrom !== undefined
          ? input.dto.validFrom
            ? new Date(input.dto.validFrom)
            : null
          : promo.validFrom;
      const nextValidUntil =
        input.dto.validUntil !== undefined
          ? input.dto.validUntil
            ? new Date(input.dto.validUntil)
            : null
          : promo.validUntil;
      const nextUsageCapTotal =
        input.dto.usageCapTotal !== undefined
          ? input.dto.usageCapTotal
          : promo.usageCapTotal;
      const nextUsageCapPerUser =
        input.dto.usageCapPerUser !== undefined
          ? input.dto.usageCapPerUser
          : promo.usageCapPerUser;
      const nextIsActive =
        input.dto.isActive !== undefined ? input.dto.isActive : promo.isActive;

      const changed =
        nextDiscountType !== promo.discountType ||
        nextDiscountValue !== promo.discountValue ||
        nextAppliesTo !== promo.appliesTo ||
        (nextValidFrom?.getTime() ?? null) !==
          (promo.validFrom?.getTime() ?? null) ||
        (nextValidUntil?.getTime() ?? null) !==
          (promo.validUntil?.getTime() ?? null) ||
        nextUsageCapTotal !== promo.usageCapTotal ||
        nextUsageCapPerUser !== promo.usageCapPerUser ||
        nextIsActive !== promo.isActive;

      if (!changed) {
        await this.recordPromoCodeAudit({
          manager,
          actorUserId: input.actorUserId,
          promoCodeId: promo.id,
          action: 'PROMO_UPDATE',
          target: `promo:${promo.id}`,
          outcome: 'reverted',
          correlationId: input.correlationId,
          metadata: {
            noOp: true,
            deterministic: true,
          },
        });
        return {
          state: 'reverted',
          promo: this.toPromoCodeAdminDto(promo),
        };
      }

      promo.discountType = nextDiscountType;
      promo.discountValue = nextDiscountValue;
      promo.appliesTo = nextAppliesTo;
      promo.validFrom = nextValidFrom;
      promo.validUntil = nextValidUntil;
      promo.usageCapTotal = nextUsageCapTotal;
      promo.usageCapPerUser = nextUsageCapPerUser;
      promo.isActive = nextIsActive;
      const saved = await manager.getRepository(PromoCodeEntity).save(promo);

      if (!saved.isActive) {
        await this.voidReservedRedemptions(saved.id, manager);
      }

      await this.recordPromoCodeAudit({
        manager,
        actorUserId: input.actorUserId,
        promoCodeId: saved.id,
        action: 'PROMO_UPDATE',
        target: `promo:${saved.id}`,
        outcome: 'success',
        correlationId: input.correlationId,
        metadata: {
          appliesTo: saved.appliesTo,
          isActive: saved.isActive,
        },
      });

      return {
        state: 'success',
        promo: this.toPromoCodeAdminDto(saved),
      };
    });
  }

  async deactivatePromoCode(input: {
    actorUserId: string;
    promoCodeId: string;
    correlationId: string;
  }): Promise<PromoLifecycleResponseDto> {
    return this.changePromoActivation({
      ...input,
      action: 'PROMO_DEACTIVATE',
      nextActiveState: false,
    });
  }

  async reactivatePromoCode(input: {
    actorUserId: string;
    promoCodeId: string;
    correlationId: string;
  }): Promise<PromoLifecycleResponseDto> {
    return this.changePromoActivation({
      ...input,
      action: 'PROMO_REACTIVATE',
      nextActiveState: true,
    });
  }

  async getPromoAnalytics(input: {
    actorUserId: string;
    query: AdminPromoAnalyticsQueryDto;
    correlationId: string;
  }): Promise<PromoAnalyticsResponseDto> {
    const normalized = this.normalizeAnalyticsFilters({
      promoCodeId: input.query.promoCodeId,
      dateFrom: input.query.dateFrom,
      dateTo: input.query.dateTo,
      productType: input.query.productType,
      page: input.query.page,
      pageSize: input.query.pageSize,
    });

    const [rows, totalItems, summary] = await Promise.all([
      this.queryPromoAnalyticsRows(normalized),
      this.queryPromoAnalyticsCount(normalized),
      this.queryPromoAnalyticsGlobalSummary(normalized),
    ]);

    const totalPages = Math.max(
      1,
      Math.ceil(totalItems / normalized.pagination.pageSize),
    );

    const response: PromoAnalyticsResponseDto = {
      state: 'success',
      filters: {
        promoCodeId: normalized.promoCodeId,
        dateFrom: normalized.window.from.toISOString(),
        dateTo: normalized.window.to.toISOString(),
        productType: normalized.productType,
        policy: 'finalized_only',
      },
      pagination: {
        page: normalized.pagination.page,
        pageSize: normalized.pagination.pageSize,
        totalItems,
        totalPages,
      },
      summary,
      rows,
    };

    try {
      await this.recordSuperadminAudit({
        actorUserId: input.actorUserId,
        action: 'PROMO_ANALYTICS_VIEW',
        target: 'promo_analytics',
        outcome: 'success',
        correlationId: input.correlationId,
        metadata: {
          promoCodeId: normalized.promoCodeId ?? 'all',
          dateFrom: normalized.window.from.toISOString(),
          dateTo: normalized.window.to.toISOString(),
          productType: normalized.productType,
          page: normalized.pagination.page,
          pageSize: normalized.pagination.pageSize,
          rowCount: rows.length,
        },
      });
    } catch (err) {
      this.logger.error('Failed to persist analytics view audit event', err);
    }

    return response;
  }

  async exportPromoAnalytics(input: {
    actorUserId: string;
    dto: AdminPromoAnalyticsExportDto;
    correlationId: string;
  }): Promise<PromoAnalyticsExportResponseDto> {
    const normalized = this.normalizeAnalyticsFilters({
      promoCodeId: input.dto.promoCodeId,
      dateFrom: input.dto.dateFrom,
      dateTo: input.dto.dateTo,
      productType: input.dto.productType,
      page: 1,
      pageSize: this.EXPORT_ROW_CAP,
    });
    const format = input.dto.format ?? 'csv';
    const rows = await this.queryPromoAnalyticsRows(normalized);

    const generatedAt = new Date();
    const fromDate = normalized.window.from.toISOString().slice(0, 10);
    const toDate = normalized.window.to.toISOString().slice(0, 10);
    const filename = `promo-analytics-${fromDate}-to-${toDate}.${format}`;
    const payload = format === 'json' ? rows : this.toPromoAnalyticsCsv(rows);

    try {
      await this.recordSuperadminAudit({
        actorUserId: input.actorUserId,
        action: 'PROMO_ANALYTICS_EXPORT',
        target: 'promo_analytics',
        outcome: 'success',
        correlationId: input.correlationId,
        metadata: {
          promoCodeId: normalized.promoCodeId ?? 'all',
          dateFrom: normalized.window.from.toISOString(),
          dateTo: normalized.window.to.toISOString(),
          productType: normalized.productType,
          format,
          rowCount: rows.length,
        },
      });
    } catch (err) {
      this.logger.error('Failed to persist analytics export audit event', err);
    }

    return {
      state: 'success',
      export: {
        format,
        generatedAt: generatedAt.toISOString(),
        filename,
        rowCount: rows.length,
        payload,
      },
    };
  }

  private async validatePromoForCreditPack(
    userId: string,
    promoCode: string,
    creditPackId: string,
    manager?: EntityManager,
  ): Promise<{
    promoCodeId: string;
    discountAmount: number;
    finalAmount: number;
    currency: string;
  }> {
    return this.validatePromo(
      userId,
      promoCode,
      'credit_pack',
      creditPackId,
      manager,
    );
  }

  private async changePromoActivation(input: {
    actorUserId: string;
    promoCodeId: string;
    correlationId: string;
    action: 'PROMO_DEACTIVATE' | 'PROMO_REACTIVATE';
    nextActiveState: boolean;
  }): Promise<PromoLifecycleResponseDto> {
    return this.dataSource.transaction(async (manager) => {
      const promo = await this.getPromoForLifecycleChange(
        input.promoCodeId,
        manager,
      );
      if (promo.isActive === input.nextActiveState) {
        await this.recordPromoCodeAudit({
          manager,
          actorUserId: input.actorUserId,
          promoCodeId: promo.id,
          action: input.action,
          target: `promo:${promo.id}`,
          outcome: 'reverted',
          correlationId: input.correlationId,
          metadata: {
            noOp: true,
            deterministic: true,
          },
        });

        return {
          state: 'reverted',
          promo: this.toPromoCodeAdminDto(promo),
        };
      }

      promo.isActive = input.nextActiveState;
      const saved = await manager.getRepository(PromoCodeEntity).save(promo);

      const voidedReservations = input.nextActiveState
        ? 0
        : await this.voidReservedRedemptions(saved.id, manager);

      await this.recordPromoCodeAudit({
        manager,
        actorUserId: input.actorUserId,
        promoCodeId: saved.id,
        action: input.action,
        target: `promo:${saved.id}`,
        outcome: 'success',
        correlationId: input.correlationId,
        metadata: {
          isActive: saved.isActive,
          voidedReservations,
        },
      });

      return {
        state: 'success',
        promo: this.toPromoCodeAdminDto(saved),
      };
    });
  }

  private async validatePromo(
    userId: string,
    promoCode: string,
    productType: PromoProductType,
    productId: string,
    manager?: EntityManager,
  ): Promise<{
    promoCodeId: string;
    discountAmount: number;
    finalAmount: number;
    currency: string;
  }> {
    if (productType === 'subscription') {
      throw new BadRequestException({
        code: BILLING_PROMO_NOT_APPLICABLE,
        message: 'Promo codes are not supported for subscriptions yet',
      });
    }

    const runValidation = async (tx: EntityManager) => {
      const normalizedCode = this.normalizePromoCode(promoCode);
      const promoRepo = tx.getRepository(PromoCodeEntity);
      const redemptionRepo = tx.getRepository(PromoRedemptionEntity);
      const packRepo = tx.getRepository(CreditPackEntity);

      const promo = await promoRepo
        .createQueryBuilder('promo')
        .setLock('pessimistic_write')
        .where('UPPER(promo.code) = :code', { code: normalizedCode })
        .getOne();
      if (!promo) {
        throw new BadRequestException({
          code: BILLING_PROMO_NOT_FOUND,
          message: 'Promo code not found',
        });
      }
      if (!promo.isActive) {
        throw new BadRequestException({
          code: BILLING_PROMO_INACTIVE,
          message: 'Promo code is inactive',
        });
      }

      const now = new Date();
      if (
        (promo.validFrom && now < promo.validFrom) ||
        (promo.validUntil && now > promo.validUntil)
      ) {
        throw new BadRequestException({
          code: BILLING_PROMO_EXPIRED,
          message: 'Promo code is expired',
        });
      }

      if (promo.appliesTo !== 'both' && promo.appliesTo !== 'credit_pack') {
        throw new BadRequestException({
          code: BILLING_PROMO_NOT_APPLICABLE,
          message: 'Promo code is not applicable to this product',
        });
      }

      if (promo.usageCapTotal !== null) {
        const totalCount = await redemptionRepo
          .createQueryBuilder('redemption')
          .where('redemption.promo_code_id = :promoCodeId', {
            promoCodeId: promo.id,
          })
          .andWhere("redemption.status IN ('reserved', 'redeemed')")
          .getCount();
        if (totalCount >= promo.usageCapTotal) {
          throw new BadRequestException({
            code: BILLING_PROMO_CAP_REACHED,
            message: 'Promo code usage limit reached',
          });
        }
      }

      if (promo.usageCapPerUser !== null) {
        const userCount = await redemptionRepo
          .createQueryBuilder('redemption')
          .where('redemption.promo_code_id = :promoCodeId', {
            promoCodeId: promo.id,
          })
          .andWhere('redemption.user_id = :userId', { userId })
          .andWhere("redemption.status IN ('reserved', 'redeemed')")
          .getCount();
        if (userCount >= promo.usageCapPerUser) {
          throw new BadRequestException({
            code: BILLING_PROMO_USER_CAP_REACHED,
            message: 'Promo code usage limit reached for this user',
          });
        }
      }

      const pack = await packRepo.findOne({
        where: { id: productId },
      });
      if (!pack) {
        throw new NotFoundException({
          code: BILLING_PACK_NOT_FOUND,
          message: 'Credit pack not found',
        });
      }
      if (!pack.isActive) {
        throw new BadRequestException({
          code: BILLING_PACK_INACTIVE,
          message: 'Credit pack is no longer available',
        });
      }

      const baseAmount = parseFloat(pack.priceInr);
      const { discountAmount, finalAmount } = this.computeDiscount(
        baseAmount,
        promo,
      );

      return {
        promoCodeId: promo.id,
        discountAmount,
        finalAmount,
        currency: 'INR',
      };
    };

    if (manager) {
      return runValidation(manager);
    }

    return this.dataSource.transaction(runValidation);
  }

  private computeDiscount(
    baseAmount: number,
    promo: PromoCodeEntity,
  ): { discountAmount: number; finalAmount: number } {
    const discountValue = parseFloat(promo.discountValue);
    const discount =
      promo.discountType === 'percentage'
        ? (baseAmount * discountValue) / 100
        : discountValue;

    const discountAmount = this.roundCurrency(
      Math.min(Math.max(discount, 0), baseAmount),
    );
    const finalAmount = this.roundCurrency(
      Math.max(baseAmount - discountAmount, 0),
    );

    return { discountAmount, finalAmount };
  }

  private roundCurrency(amount: number): number {
    return Math.round(amount * 100) / 100;
  }

  private normalizePromoCode(code: string): string {
    return code.trim().toUpperCase();
  }

  private async assertPromoCodeUnique(
    normalizedCode: string,
    excludingPromoCodeId?: string,
    manager?: EntityManager,
  ): Promise<void> {
    const repo = manager
      ? manager.getRepository(PromoCodeEntity)
      : this.promoCodeRepo;
    const qb = repo
      .createQueryBuilder('promo')
      .where('UPPER(promo.code) = :code', { code: normalizedCode });
    if (excludingPromoCodeId) {
      qb.andWhere('promo.id != :promoCodeId', {
        promoCodeId: excludingPromoCodeId,
      });
    }
    const duplicate = await qb.getOne();
    if (duplicate) {
      throw new BadRequestException({
        code: BILLING_PROMO_CODE_DUPLICATE,
        message: 'Promo code already exists',
      });
    }
  }

  private assertValidDateRange(validFrom?: string, validUntil?: string): void {
    if (!validFrom || !validUntil) {
      return;
    }
    if (new Date(validUntil).getTime() < new Date(validFrom).getTime()) {
      throw new BadRequestException({
        code: BILLING_PROMO_DATE_RANGE_INVALID,
        message: 'validUntil must be greater than or equal to validFrom',
      });
    }
  }

  private isReconciled(status: string, credited: boolean): boolean {
    return status === 'reconciled' || credited;
  }

  private withFailureReason(
    metadata: Record<string, unknown> | null,
    reason?: string,
  ): Record<string, unknown> | null {
    if (!reason || reason.trim().length === 0) {
      return metadata;
    }

    return {
      ...(metadata ?? {}),
      reason: reason.trim(),
    };
  }

  private withoutFailureReason(
    metadata: Record<string, unknown> | null,
  ): Record<string, unknown> | null {
    if (
      !metadata ||
      !Object.prototype.hasOwnProperty.call(metadata, 'reason')
    ) {
      return metadata;
    }

    const copy = { ...metadata };
    delete copy.reason;
    return Object.keys(copy).length === 0 ? null : copy;
  }

  private async reservePromoRedemption(
    order: OrderEntity,
    manager?: EntityManager,
  ): Promise<void> {
    if (!order.promoCodeId) return;
    if (!order.discountAmount) return;

    const repo = manager
      ? manager.getRepository(PromoRedemptionEntity)
      : this.promoRedemptionRepo;

    await repo
      .createQueryBuilder()
      .insert()
      .into(PromoRedemptionEntity)
      .values({
        promoCodeId: order.promoCodeId,
        userId: order.userId,
        productType: 'credit_pack',
        productRefId: order.creditPackId,
        orderId: order.id,
        subscriptionId: null,
        discountAmount: order.discountAmount,
        currency: order.currency,
        status: 'reserved',
      })
      .orIgnore()
      .execute();
  }

  private async recordPromoRedemption(
    order: OrderEntity,
    manager?: EntityManager,
  ): Promise<void> {
    if (!order.promoCodeId) return;
    if (!order.discountAmount) return;

    const repo = manager
      ? manager.getRepository(PromoRedemptionEntity)
      : this.promoRedemptionRepo;

    const existingReserved = await repo
      .createQueryBuilder()
      .update(PromoRedemptionEntity)
      .set({
        status: 'redeemed',
        discountAmount: order.discountAmount,
        currency: order.currency,
      })
      .where('promo_code_id = :promoCodeId', { promoCodeId: order.promoCodeId })
      .andWhere('order_id = :orderId', { orderId: order.id })
      .andWhere("status = 'reserved'")
      .execute();
    if ((existingReserved.affected ?? 0) > 0) return;

    await repo
      .createQueryBuilder()
      .insert()
      .into(PromoRedemptionEntity)
      .values({
        promoCodeId: order.promoCodeId,
        userId: order.userId,
        productType: 'credit_pack',
        productRefId: order.creditPackId,
        orderId: order.id,
        subscriptionId: null,
        discountAmount: order.discountAmount,
        currency: order.currency,
        status: 'redeemed',
      })
      .orIgnore()
      .execute();
  }

  private async voidPromoReservation(orderId: string): Promise<void> {
    await this.promoRedemptionRepo
      .createQueryBuilder()
      .update(PromoRedemptionEntity)
      .set({ status: 'void' })
      .where('order_id = :orderId', { orderId })
      .andWhere("status = 'reserved'")
      .execute();
  }

  private async voidReservedRedemptions(
    promoCodeId: string,
    manager: EntityManager,
  ): Promise<number> {
    const result = await manager
      .getRepository(PromoRedemptionEntity)
      .createQueryBuilder()
      .update(PromoRedemptionEntity)
      .set({ status: 'void' })
      .where('promo_code_id = :promoCodeId', { promoCodeId })
      .andWhere("status = 'reserved'")
      .execute();
    return result.affected ?? 0;
  }

  private async getPromoForLifecycleChange(
    promoCodeId: string,
    manager: EntityManager,
  ): Promise<PromoCodeEntity> {
    const promo = await manager
      .getRepository(PromoCodeEntity)
      .createQueryBuilder('promo')
      .setLock('pessimistic_write')
      .where('promo.id = :promoCodeId', { promoCodeId })
      .getOne();

    if (!promo) {
      throw new NotFoundException({
        code: BILLING_PROMO_NOT_FOUND,
        message: 'Promo code not found',
      });
    }
    return promo;
  }

  private async loadRedemptionCountsByPromoId(): Promise<
    Record<
      string,
      {
        reserved: number;
        redeemed: number;
        void: number;
      }
    >
  > {
    const rows = await this.promoRedemptionRepo
      .createQueryBuilder('redemption')
      .select('redemption.promoCodeId', 'promoCodeId')
      .addSelect('redemption.status', 'status')
      .addSelect('COUNT(redemption.id)', 'count')
      .groupBy('redemption.promoCodeId')
      .addGroupBy('redemption.status')
      .getRawMany<{ promoCodeId: string; status: string; count: string }>();

    const result: Record<
      string,
      {
        reserved: number;
        redeemed: number;
        void: number;
      }
    > = {};

    for (const row of rows) {
      const bucket = (result[row.promoCodeId] ??= {
        reserved: 0,
        redeemed: 0,
        void: 0,
      });
      const count = parseInt(row.count, 10);
      if (row.status === 'reserved') {
        bucket.reserved = count;
      } else if (row.status === 'redeemed') {
        bucket.redeemed = count;
      } else if (row.status === 'void') {
        bucket.void = count;
      }
    }

    return result;
  }

  private normalizeAnalyticsFilters(input: {
    promoCodeId?: string;
    dateFrom?: string;
    dateTo?: string;
    productType?: PromoProductType | 'all';
    page?: number;
    pageSize?: number;
  }): {
    promoCodeId: string | null;
    productType: PromoProductType | 'all';
    window: { from: Date; to: Date };
    pagination: { page: number; pageSize: number };
  } {
    const now = new Date();
    const defaultFrom = new Date(now);
    defaultFrom.setDate(defaultFrom.getDate() - 30);

    const from = input.dateFrom ? new Date(input.dateFrom) : defaultFrom;
    const to = input.dateTo ? new Date(input.dateTo) : now;

    if (
      Number.isNaN(from.getTime()) ||
      Number.isNaN(to.getTime()) ||
      from > to
    ) {
      throw new BadRequestException({
        code: BILLING_ANALYTICS_DATE_RANGE_INVALID,
        message: 'dateFrom must be less than or equal to dateTo',
      });
    }

    return {
      promoCodeId: input.promoCodeId ?? null,
      productType: input.productType ?? 'all',
      window: { from, to },
      pagination: {
        page: input.page ?? 1,
        pageSize: input.pageSize ?? 20,
      },
    };
  }

  private buildAnalyticsBaseQueryBuilder(input: {
    promoCodeId: string | null;
    productType: PromoProductType | 'all';
    window: { from: Date; to: Date };
  }) {
    const qb = this.promoCodeRepo
      .createQueryBuilder('promo')
      .leftJoin(
        PromoRedemptionEntity,
        'redemption',
        [
          'redemption.promo_code_id = promo.id',
          'redemption.updated_at >= :dateFrom',
          'redemption.updated_at <= :dateTo',
          input.productType === 'all'
            ? '1=1'
            : 'redemption.product_type = :productType',
        ].join(' AND '),
        {
          dateFrom: input.window.from.toISOString(),
          dateTo: input.window.to.toISOString(),
          ...(input.productType === 'all'
            ? {}
            : { productType: input.productType }),
        },
      )
      .leftJoin(
        OrderEntity,
        'checkout_order',
        'checkout_order.id = redemption.order_id',
      );

    if (input.promoCodeId) {
      qb.where('promo.id = :promoCodeId', { promoCodeId: input.promoCodeId });
    }

    return qb;
  }

  private async queryPromoAnalyticsCount(input: {
    promoCodeId: string | null;
    productType: PromoProductType | 'all';
    window: { from: Date; to: Date };
  }): Promise<number> {
    const row = await this.buildAnalyticsBaseQueryBuilder(input)
      .select('COUNT(DISTINCT promo.id)', 'cnt')
      .getRawOne<{ cnt: string }>();
    return parseInt(row?.cnt ?? '0', 10) || 0;
  }

  private async queryPromoAnalyticsGlobalSummary(input: {
    promoCodeId: string | null;
    productType: PromoProductType | 'all';
    window: { from: Date; to: Date };
  }): Promise<PromoAnalyticsSummaryDto> {
    const row = await this.buildAnalyticsBaseQueryBuilder(input)
      .select(
        "COALESCE(SUM(CASE WHEN redemption.status = 'redeemed' AND checkout_order.status = 'reconciled' THEN 1 ELSE 0 END), 0)",
        'totalReconciledCheckouts',
      )
      .addSelect(
        "COALESCE(SUM(CASE WHEN redemption.status = 'void' AND checkout_order.status = 'failed' THEN 1 ELSE 0 END), 0)",
        'totalFailedCheckouts',
      )
      .addSelect(
        "COALESCE(SUM(CASE WHEN redemption.status = 'redeemed' AND checkout_order.status = 'reconciled' THEN redemption.discount_amount ELSE 0 END), 0)",
        'totalAttributedDiscount',
      )
      .addSelect(
        "COALESCE(SUM(CASE WHEN redemption.status = 'redeemed' AND checkout_order.status = 'reconciled' THEN checkout_order.final_amount ELSE 0 END), 0)",
        'totalFinalizedRevenue',
      )
      .getRawOne<{
        totalReconciledCheckouts: string;
        totalFailedCheckouts: string;
        totalAttributedDiscount: string;
        totalFinalizedRevenue: string;
      }>();

    return {
      totalReconciledCheckouts:
        parseInt(row?.totalReconciledCheckouts ?? '0', 10) || 0,
      totalFailedCheckouts: parseInt(row?.totalFailedCheckouts ?? '0', 10) || 0,
      totalAttributedDiscount: this.roundCurrency(
        parseFloat(row?.totalAttributedDiscount ?? '0') || 0,
      ),
      totalFinalizedRevenue: this.roundCurrency(
        parseFloat(row?.totalFinalizedRevenue ?? '0') || 0,
      ),
    };
  }

  private async queryPromoAnalyticsRows(input: {
    promoCodeId: string | null;
    productType: PromoProductType | 'all';
    window: { from: Date; to: Date };
    pagination: { page: number; pageSize: number };
  }): Promise<PromoAnalyticsRowDto[]> {
    const offset = (input.pagination.page - 1) * input.pagination.pageSize;
    const rows = await this.buildAnalyticsBaseQueryBuilder(input)
      .select('promo.id', 'promoCodeId')
      .addSelect('promo.code', 'promoCode')
      .addSelect(
        "COALESCE(SUM(CASE WHEN redemption.status = 'redeemed' AND checkout_order.status = 'reconciled' THEN 1 ELSE 0 END), 0)",
        'reconciledCheckoutCount',
      )
      .addSelect(
        "COALESCE(SUM(CASE WHEN redemption.status = 'void' AND checkout_order.status = 'failed' THEN 1 ELSE 0 END), 0)",
        'failedCheckoutCount',
      )
      .addSelect(
        "COALESCE(SUM(CASE WHEN redemption.status = 'redeemed' AND checkout_order.status = 'reconciled' THEN redemption.discount_amount ELSE 0 END), 0)",
        'attributedDiscountTotal',
      )
      .addSelect(
        "COALESCE(SUM(CASE WHEN redemption.status = 'redeemed' AND checkout_order.status = 'reconciled' THEN checkout_order.final_amount ELSE 0 END), 0)",
        'finalizedRevenueTotal',
      )
      .groupBy('promo.id')
      .addGroupBy('promo.code')
      .orderBy('reconciledCheckoutCount', 'DESC')
      .addOrderBy('promo.code', 'ASC')
      .addOrderBy('promo.id', 'ASC')
      .limit(input.pagination.pageSize)
      .offset(offset)
      .getRawMany<{
        promoCodeId: string;
        promoCode: string;
        reconciledCheckoutCount: string;
        failedCheckoutCount: string;
        attributedDiscountTotal: string;
        finalizedRevenueTotal: string;
      }>();

    return rows.map((row) => ({
      promoCodeId: row.promoCodeId,
      promoCode: row.promoCode,
      reconciledCheckoutCount: parseInt(row.reconciledCheckoutCount, 10) || 0,
      failedCheckoutCount: parseInt(row.failedCheckoutCount, 10) || 0,
      attributedDiscountTotal: parseFloat(row.attributedDiscountTotal) || 0,
      finalizedRevenueTotal: parseFloat(row.finalizedRevenueTotal) || 0,
    }));
  }

  private toPromoAnalyticsCsv(rows: PromoAnalyticsRowDto[]): string {
    const header = [
      'promoCodeId',
      'promoCode',
      'reconciledCheckoutCount',
      'failedCheckoutCount',
      'attributedDiscountTotal',
      'finalizedRevenueTotal',
    ].join(',');

    const lines = rows.map((row) =>
      [
        row.promoCodeId,
        this.escapeCsvCell(row.promoCode),
        row.reconciledCheckoutCount.toString(),
        row.failedCheckoutCount.toString(),
        row.attributedDiscountTotal.toFixed(2),
        row.finalizedRevenueTotal.toFixed(2),
      ].join(','),
    );

    return [header, ...lines].join('\n');
  }

  private escapeCsvCell(value: string): string {
    if (!value.includes(',') && !value.includes('"') && !value.includes('\n')) {
      return value;
    }
    return `"${value.replaceAll('"', '""')}"`;
  }

  private toPromoCodeAdminDto(
    promo: PromoCodeEntity,
    redemptions?: { reserved: number; redeemed: number; void: number },
  ): PromoCodeAdminDto {
    return {
      id: promo.id,
      code: promo.code,
      discountType: promo.discountType,
      discountValue: parseFloat(promo.discountValue),
      appliesTo: promo.appliesTo,
      validFrom: promo.validFrom ? promo.validFrom.toISOString() : null,
      validUntil: promo.validUntil ? promo.validUntil.toISOString() : null,
      usageCapTotal: promo.usageCapTotal,
      usageCapPerUser: promo.usageCapPerUser,
      isActive: promo.isActive,
      redemptions: redemptions ?? {
        reserved: 0,
        redeemed: 0,
        void: 0,
      },
      updatedAt: promo.updatedAt.toISOString(),
    };
  }

  private async recordSuperadminAudit(input: {
    actorUserId: string;
    action: string;
    target: string;
    outcome: 'success' | 'failure' | 'denied' | 'reverted';
    correlationId: string;
    metadata?: Record<string, string | number | boolean>;
  }): Promise<void> {
    await this.superadminAuditRepo.save(
      this.superadminAuditRepo.create({
        actorUserId: input.actorUserId,
        action: input.action,
        target: input.target,
        outcome: input.outcome,
        correlationId: input.correlationId,
        challengeId: null,
        errorCode: null,
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
      }),
    );
  }

  private async recordPromoCodeAudit(input: {
    manager: EntityManager;
    actorUserId: string;
    promoCodeId: string;
    action: string;
    target: string;
    outcome: 'success' | 'failure' | 'denied' | 'reverted';
    correlationId: string;
    metadata?: Record<string, string | number | boolean | null>;
  }): Promise<void> {
    const repo = input.manager.getRepository(PromoCodeAuditEventEntity);
    await repo.save(
      repo.create({
        actorUserId: input.actorUserId,
        promoCodeId: input.promoCodeId,
        action: input.action,
        target: input.target,
        outcome: input.outcome,
        correlationId: input.correlationId,
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
        promoCodeId: input.promoCodeId,
      }),
    );
  }
}
