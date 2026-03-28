import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { CreditPackEntity } from '../../database/entities/credit-pack.entity';
import { OrderEntity } from '../../database/entities/order.entity';
import { SubscriptionEntity } from '../../database/entities/subscription.entity';
import { UserEntitlementEntity } from '../../database/entities/user-entitlement.entity';
import { EntitlementsService } from '../entitlements/entitlements.service';
import { RazorpayService } from './razorpay.service';
import {
  BILLING_ALREADY_SUBSCRIBED,
  BILLING_INVALID_SIGNATURE,
  BILLING_ORDER_ALREADY_PROCESSED,
  BILLING_ORDER_NOT_FOUND,
  BILLING_PACK_INACTIVE,
  BILLING_PACK_NOT_FOUND,
  BILLING_PLAN_INACTIVE,
  BILLING_PLAN_NOT_FOUND,
  BILLING_SUBSCRIPTION_INVALID_SIGNATURE,
  BILLING_SUBSCRIPTION_NOT_FOUND,
  BILLING_WEBHOOK_INVALID_SIGNATURE,
} from './billing.types';
import type {
  CreditPackResponseDto,
  CreateOrderResponseDto,
  CreateSubscriptionResponseDto,
  PlanResponseDto,
  VerifyPaymentResponseDto,
  VerifySubscriptionResponseDto,
} from './billing.types';

@Injectable()
export class BillingService {
  private readonly logger = new Logger(BillingService.name);

  constructor(
    @InjectRepository(CreditPackEntity)
    private readonly creditPackRepo: Repository<CreditPackEntity>,
    @InjectRepository(OrderEntity)
    private readonly orderRepo: Repository<OrderEntity>,
    @InjectRepository(SubscriptionEntity)
    private readonly subscriptionRepo: Repository<SubscriptionEntity>,
    private readonly dataSource: DataSource,
    private readonly razorpayService: RazorpayService,
    private readonly entitlementsService: EntitlementsService,
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

  async createOrder(
    userId: string,
    creditPackId: string,
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

    // Create Razorpay order (amount in paise for INR)
    const amountInPaise = Math.round(parseFloat(pack.priceInr) * 100);
    const currency = 'INR';

    const razorpayOrder = await this.razorpayService.createOrder(
      amountInPaise,
      currency,
      `order_${userId}_${creditPackId}`,
    );

    // Persist order
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

    // Idempotent: if already credited, just return current summary
    if (order.credited) {
      const summary =
        await this.entitlementsService.getEntitlementSummary(userId);
      return {
        creditsAdded: order.creditPack.credits,
        entitlementSummary: summary,
      };
    }

    // Credit user atomically in a transaction
    await this.dataSource.transaction(async (manager) => {
      // Atomic increment of credit balance
      await manager
        .createQueryBuilder()
        .update(UserEntitlementEntity)
        .set({
          creditBalance: () =>
            `credit_balance + ${order.creditPack.credits}`,
        })
        .where('user_id = :userId', { userId })
        .execute();

      // Mark order as paid + credited
      await manager.update(OrderEntity, order.id, {
        status: 'paid',
        razorpayPaymentId,
        razorpaySignature,
        credited: true,
      });
    });

    const summary =
      await this.entitlementsService.getEntitlementSummary(userId);
    return {
      creditsAdded: order.creditPack.credits,
      entitlementSummary: summary,
    };
  }

  async handleWebhookPaymentCaptured(
    razorpayOrderId: string,
    razorpayPaymentId: string,
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

    await this.dataSource.transaction(async (manager) => {
      if (!order.credited) {
        // Credit balance atomically
        await manager
          .createQueryBuilder()
          .update(UserEntitlementEntity)
          .set({
            creditBalance: () =>
              `credit_balance + ${order.creditPack.credits}`,
          })
          .where('user_id = :userId', { userId: order.userId })
          .execute();
      }

      await manager.update(OrderEntity, order.id, {
        status: 'reconciled',
        razorpayPaymentId,
        credited: true,
      });
    });

    this.logger.log(
      `Webhook: order ${order.id} reconciled (razorpay_order_id=${razorpayOrderId})`,
    );
  }

  async handleWebhookPaymentFailed(razorpayOrderId: string): Promise<void> {
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

    await this.orderRepo.update(order.id, { status: 'failed' });
    this.logger.log(
      `Webhook: order ${order.id} marked failed (razorpay_order_id=${razorpayOrderId})`,
    );
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
  ): Promise<CreateSubscriptionResponseDto> {
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
  }
}
