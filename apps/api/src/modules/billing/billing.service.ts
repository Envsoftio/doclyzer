import {
  BadRequestException,
  HttpException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { createHash, randomUUID } from 'node:crypto';
import { DataSource, EntityManager, Repository } from 'typeorm';
import {
  BillingProviderEventEntity,
  type BillingProviderEventOutcome,
} from '../../database/entities/billing-provider-event.entity';
import { CreditPackEntity } from '../../database/entities/credit-pack.entity';
import { OrderEntity } from '../../database/entities/order.entity';
import { PromoCodeEntity } from '../../database/entities/promo-code.entity';
import { PromoCodeAuditEventEntity } from '../../database/entities/promo-code-audit-event.entity';
import {
  PromoLifecycleEventEntity,
  type PromoLifecycleEventOutcome,
  type PromoLifecycleEventType,
} from '../../database/entities/promo-lifecycle-event.entity';
import { PromoRedemptionEntity } from '../../database/entities/promo-redemption.entity';
import { SubscriptionEntity } from '../../database/entities/subscription.entity';
import { SuperadminAuthAuditEventEntity } from '../../database/entities/superadmin-auth-audit-event.entity';
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
  BILLING_RECONCILIATION_AMOUNT_MISMATCH,
  BILLING_RECONCILIATION_CURRENCY_MISMATCH,
  BILLING_MANUAL_ADJUSTMENT_NEGATIVE_BALANCE,
  BILLING_RECONCILIATION_PAYLOAD_INCOMPLETE,
  BILLING_SUBSCRIPTION_INVALID_SIGNATURE,
  BILLING_SUBSCRIPTION_NOT_FOUND,
  BILLING_WEBHOOK_INVALID_AUTHORIZATION,
  BILLING_WEBHOOK_INVALID_SIGNATURE,
} from './billing.types';
import type {
  CreditPackResponseDto,
  CreateOrderResponseDto,
  ConfirmClientPurchaseDto,
  CreateSubscriptionResponseDto,
  AdminBillingOrderRowDto,
  AdminBillingOrdersResponseDto,
  AdminManualCreditAdjustmentResponseDto,
  OrderStatusDto,
  PlanResponseDto,
  PromoProductType,
  PromoValidationResponseDto,
  PromoCodeAdminDto,
  PromoAnalyticsExportResponseDto,
  PromoInvalidReasonDto,
  PromoAnalyticsResponseDto,
  PromoAnalyticsRowDto,
  PromoAnalyticsSummaryDto,
  PromoLifecycleResponseDto,
  VerifyPaymentResponseDto,
  VerifySubscriptionResponseDto,
} from './billing.types';
import type {
  AdminCreatePromoCodeDto,
  AdminBillingOrdersQueryDto,
  AdminManualCreditAdjustmentDto,
  AdminPromoAnalyticsExportDto,
  AdminPromoAnalyticsQueryDto,
  AdminUpdatePromoCodeDto,
} from './billing.types';
import { toOrderStatusDto } from './billing.types';

export interface RazorpayWebhookContext {
  providerEventId: string | null;
  idempotencyKey: string;
  eventType: string;
  rawBodyHash: string;
  correlationId: string;
}

export interface CapturedPaymentWebhookInput extends RazorpayWebhookContext {
  razorpayOrderId: string;
  razorpayPaymentId: string;
  amount: number | null;
  currency: string | null;
}

export interface FailedPaymentWebhookInput extends RazorpayWebhookContext {
  razorpayOrderId: string;
  razorpayPaymentId: string | null;
  reason?: string;
}

export interface RevenueCatWebhookContext {
  providerEventId: string | null;
  idempotencyKey: string;
  eventType: string;
  rawBodyHash: string;
  correlationId: string;
}

export interface RevenueCatPurchaseWebhookInput extends RevenueCatWebhookContext {
  orderId: string | null;
  transactionId: string | null;
  appUserId: string | null;
  productId: string | null;
  amount: number | null;
  currency: string | null;
}

export interface RevenueCatFailedWebhookInput extends RevenueCatWebhookContext {
  orderId: string | null;
  transactionId: string | null;
  appUserId: string | null;
  productId: string | null;
  reason?: string;
}

interface PaymentExpectationMismatch {
  code:
    | typeof BILLING_RECONCILIATION_AMOUNT_MISMATCH
    | typeof BILLING_RECONCILIATION_CURRENCY_MISMATCH
    | typeof BILLING_RECONCILIATION_PAYLOAD_INCOMPLETE;
  reviewReason: string;
  expectedAmount: number;
  actualAmount: number | null;
  expectedCurrency: string;
  actualCurrency: string | null;
}

interface PromoValidationResult {
  promoCodeId: string;
  originalAmount: number;
  discountAmount: number;
  finalAmount: number;
  currency: string;
  promoLabel: string;
  promoDescription: string;
  promoCode: string;
}

interface PromoValidationFailureContext {
  promoCodeId: string | null;
  originalAmount: number;
  finalAmount: number;
  currency: string;
  promoLabel: string | null;
  promoDescription: string | null;
  normalizedCode: string;
}

interface PromoCheckoutTransactionResult {
  response: CreateOrderResponseDto;
  receiptNotification:
    | {
        userId: string;
        correlationId: string;
        idempotencyKey: string;
        metadata: Record<string, string | number | boolean | null>;
      }
    | null;
}

interface PromoLifecycleCounts {
  validation: number;
  reservation: number;
  redeemed: number;
  failed: number;
  voided: number;
}

type PromoFinancialAnalyticsSummary = Pick<
  PromoAnalyticsSummaryDto,
  | 'totalReconciledCheckouts'
  | 'totalFailedCheckouts'
  | 'totalAttributedDiscount'
  | 'totalFinalizedRevenue'
>;

@Injectable()
export class BillingService {
  private readonly logger = new Logger(BillingService.name);
  private readonly EXPORT_ROW_CAP = 1000;
  private readonly PROMO_RESERVATION_TIMEOUT_MINUTES =
    this.resolvePromoReservationTimeoutMinutes();

  constructor(
    @InjectRepository(BillingProviderEventEntity)
    private readonly providerEventRepo: Repository<BillingProviderEventEntity>,
    @InjectRepository(CreditPackEntity)
    private readonly creditPackRepo: Repository<CreditPackEntity>,
    @InjectRepository(OrderEntity)
    private readonly orderRepo: Repository<OrderEntity>,
    @InjectRepository(PromoRedemptionEntity)
    private readonly promoRedemptionRepo: Repository<PromoRedemptionEntity>,
    @InjectRepository(PromoLifecycleEventEntity)
    private readonly promoLifecycleEventRepo: Repository<PromoLifecycleEventEntity>,
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

  async getOrderStatus(
    userId: string,
    orderId: string,
  ): Promise<OrderStatusDto> {
    const order = await this.orderRepo.findOne({
      where: { id: orderId, userId },
    });
    if (!order) {
      throw new NotFoundException({
        code: BILLING_ORDER_NOT_FOUND,
        message: 'Order not found',
      });
    }

    return toOrderStatusDto(order);
  }

  async listAdminBillingOrders(input: {
    actorUserId: string;
    query: AdminBillingOrdersQueryDto;
    correlationId: string;
  }): Promise<AdminBillingOrdersResponseDto> {
    const page = Math.max(1, input.query.page ?? 1);
    const pageSize = Math.max(1, Math.min(input.query.pageSize ?? 25, 100));
    const reviewState = input.query.reviewState ?? 'all';
    const qb = this.orderRepo
      .createQueryBuilder('order')
      .leftJoinAndSelect('order.user', 'user')
      .leftJoinAndSelect('order.creditPack', 'creditPack')
      .orderBy('order.updatedAt', 'DESC');

    if (input.query.search?.trim()) {
      const search = `%${input.query.search.trim().toLowerCase()}%`;
      qb.andWhere(
        `(
          LOWER(user.email) LIKE :search
          OR LOWER(COALESCE(user.displayName, '')) LIKE :search
          OR LOWER(order.id::text) LIKE :search
          OR LOWER(order.razorpayOrderId) LIKE :search
          OR LOWER(COALESCE(order.razorpayPaymentId, '')) LIKE :search
        )`,
        { search },
      );
    }

    if (input.query.status) {
      qb.andWhere('order.status = :status', { status: input.query.status });
    }

    if (reviewState === 'needs_review') {
      qb.andWhere('order.status = :pendingReview', {
        pendingReview: 'pending_review',
      });
    } else if (reviewState === 'clear') {
      qb.andWhere('order.status != :pendingReview', {
        pendingReview: 'pending_review',
      });
    }

    if (input.query.dateFrom) {
      qb.andWhere('order.createdAt >= :dateFrom', {
        dateFrom: new Date(input.query.dateFrom),
      });
    }

    if (input.query.dateTo) {
      const end = new Date(input.query.dateTo);
      end.setUTCHours(23, 59, 59, 999);
      qb.andWhere('order.createdAt <= :dateTo', {
        dateTo: end,
      });
    }

    qb.skip((page - 1) * pageSize).take(pageSize);

    const [orders, totalItems] = await qb.getManyAndCount();
    const items = orders.map((order) => this.toAdminBillingOrderRow(order));
    const totalPages = Math.max(1, Math.ceil(totalItems / pageSize));

    try {
      await this.recordSuperadminAudit({
        actorUserId: input.actorUserId,
        action: 'BILLING_ORDERS_VIEW',
        target: 'billing_orders',
        outcome: 'success',
        correlationId: input.correlationId,
        metadata: {
          page,
          pageSize,
          rowCount: items.length,
          hasSearch: input.query.search?.trim().length ? true : false,
          hasStatusFilter: input.query.status ? true : false,
          needsReviewOnly: reviewState === 'needs_review',
        },
      });
    } catch (err) {
      this.logger.error('Failed to persist billing order view audit event', err);
    }

    return {
      state: 'success',
      filters: {
        search: input.query.search?.trim() || null,
        status: input.query.status ?? 'all',
        reviewState,
        dateFrom: input.query.dateFrom ?? null,
        dateTo: input.query.dateTo ?? null,
      },
      pagination: {
        page,
        pageSize,
        totalItems,
        totalPages,
      },
      items,
    };
  }

  async applyManualCreditAdjustment(input: {
    actorUserId: string;
    dto: AdminManualCreditAdjustmentDto;
    correlationId: string;
  }): Promise<AdminManualCreditAdjustmentResponseDto> {
    const delta = Math.round(input.dto.adjustment * 100) / 100;
    if (!Number.isFinite(delta) || delta === 0) {
      throw new BadRequestException({
        code: 'BILLING_MANUAL_ADJUSTMENT_INVALID',
        message: 'Adjustment must be a non-zero number.',
      });
    }

    const performedAt = new Date();
    let newCreditBalance = 0;

    try {
      await this.dataSource.transaction(async (manager) => {
        try {
          newCreditBalance =
            await this.entitlementsService.adjustCreditsInTransaction(
              manager,
              input.dto.userId,
              delta,
              'admin_adjustment',
            );
        } catch (err) {
          if (err instanceof HttpException) {
            throw err;
          }
          throw new BadRequestException({
            code: BILLING_MANUAL_ADJUSTMENT_NEGATIVE_BALANCE,
            message: 'Credit adjustment would result in a negative balance.',
          });
        }

        await this.recordSuperadminAudit({
          actorUserId: input.actorUserId,
          action: 'BILLING_MANUAL_CREDIT_ADJUSTMENT',
          target: `user:${input.dto.userId}`,
          outcome: 'success',
          correlationId: input.correlationId,
          metadata: {
            delta,
            newCreditBalance,
            reason: input.dto.reason.trim(),
          },
        });
      });
    } catch (err) {
      if (err instanceof HttpException) {
        throw err;
      }
      throw err;
    }

    await this.dispatchBillingOpsAlert({
      alertType: 'billing.manual_credit_adjustment',
      severity: 'warning',
      idempotencyKey: `billing-ops:manual-credit-adjustment:${input.correlationId}`,
      correlationId: input.correlationId,
      metadata: {
        actorUserId: input.actorUserId,
        userId: input.dto.userId,
        delta,
        newCreditBalance,
      },
    });

    return {
      state: 'success',
      adjustment: {
        userId: input.dto.userId,
        delta,
        newCreditBalance,
        reason: input.dto.reason.trim(),
        performedAt: performedAt.toISOString(),
      },
    };
  }

  async createOrder(
    userId: string,
    creditPackId: string,
    promoCode?: string,
    correlationId: string = randomUUID(),
    idempotencyKey?: string,
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
        status: 'payment_pending',
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
        paymentRequired: true,
        checkoutProvider: 'razorpay',
        orderStatus: 'payment_pending',
      };
    }

    const zeroCheckoutKey = this.buildZeroCheckoutKey({
      userId,
      creditPackId,
      promoCode,
      idempotencyKey,
    });

    // Keep promo validation + reservation atomic to prevent cap over-redemption.
    const checkout =
      await this.dataSource.transaction<PromoCheckoutTransactionResult>(
        async (manager) => {
          const existingZeroOrder = await this.findExistingZeroCheckoutOrder(
            zeroCheckoutKey,
            manager,
          );
          if (existingZeroOrder) {
            return {
              response: {
                orderId: existingZeroOrder.id,
                razorpayOrderId: null,
                amount: 0,
                currency: existingZeroOrder.currency,
                razorpayKeyId: null,
                paymentRequired: false,
                checkoutProvider: 'internal',
                orderStatus: toOrderStatusDto(existingZeroOrder).status,
              },
              receiptNotification: null,
            };
          }

          const promo = await this.validatePromoForCreditPack(
            userId,
            promoCode,
            creditPackId,
            manager,
          );
          if (promo.finalAmount <= 0) {
            return this.createZeroAmountPromoOrder({
              manager,
              userId,
              pack,
              promo,
              zeroCheckoutKey,
              correlationId,
            });
          }

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
            status: 'payment_pending',
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
            response: {
              orderId: saved.id,
              razorpayOrderId: razorpayOrder.id,
              amount: amountInPaise,
              currency,
              razorpayKeyId: this.razorpayService.keyId,
              paymentRequired: true,
              checkoutProvider: 'razorpay',
              orderStatus: 'payment_pending',
            },
            receiptNotification: null,
          };
        },
      );

    if (checkout.receiptNotification) {
      await this.dispatchBillingPaymentSuccess(checkout.receiptNotification);
    }
    if (!checkout.response.paymentRequired) {
      checkout.response.entitlementSummary =
        await this.entitlementsService.getEntitlementSummary(userId);
    }

    return checkout.response;
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

    if (order.status === 'failed' || order.status === 'pending_review') {
      const summary =
        await this.entitlementsService.getEntitlementSummary(userId);
      return {
        creditsAdded: 0,
        orderStatus: toOrderStatusDto(order).status,
        entitlementSummary: summary,
      };
    }

    // Client confirmation proves SDK callback success, but webhook reconciliation grants credits.
    order.status = 'client_purchase_confirmed';
    order.razorpayPaymentId = razorpayPaymentId;
    order.razorpaySignature = razorpaySignature;
    order.credited = false;
    order.metadata = this.withoutReviewOrFailureReason(order.metadata);
    await this.orderRepo.save(order);

    const summary =
      await this.entitlementsService.getEntitlementSummary(userId);
    return {
      creditsAdded: 0,
      orderStatus: 'client_purchase_confirmed',
      entitlementSummary: summary,
    };
  }

  async confirmClientPurchase(
    userId: string,
    orderId: string,
    dto: ConfirmClientPurchaseDto,
  ): Promise<OrderStatusDto> {
    const order = await this.orderRepo.findOne({
      where: { id: orderId, userId },
    });
    if (!order) {
      throw new NotFoundException({
        code: BILLING_ORDER_NOT_FOUND,
        message: 'Order not found',
      });
    }

    if (
      order.status === 'created' ||
      order.status === 'payment_pending' ||
      order.status === 'signature_verified' ||
      order.status === 'client_purchase_confirmed'
    ) {
      order.status = 'client_purchase_confirmed';
      order.credited = false;
      order.metadata = this.withClientPurchaseMetadata(
        this.withoutReviewOrFailureReason(order.metadata),
        dto,
      );
      await this.orderRepo.save(order);
    }

    return toOrderStatusDto(order);
  }

  buildRazorpayWebhookContext(input: {
    providerEventId?: string | null;
    rawBody: string;
    eventType: string;
    correlationId: string;
  }): RazorpayWebhookContext {
    const rawBodyHash = createHash('sha256')
      .update(input.rawBody)
      .digest('hex');
    const idempotencySource = input.providerEventId?.trim()
      ? `event:${input.providerEventId.trim()}`
      : `body:${rawBodyHash}`;
    const idempotencyHash = createHash('sha256')
      .update(idempotencySource)
      .digest('hex');

    return {
      providerEventId: input.providerEventId?.trim() || null,
      idempotencyKey: `razorpay:${idempotencyHash}`,
      eventType: input.eventType,
      rawBodyHash,
      correlationId: input.correlationId,
    };
  }

  buildRevenueCatWebhookContext(input: {
    providerEventId?: string | null;
    rawBody: string;
    eventType: string;
    correlationId: string;
  }): RevenueCatWebhookContext {
    const rawBodyHash = createHash('sha256')
      .update(input.rawBody)
      .digest('hex');
    const idempotencySource = input.providerEventId?.trim()
      ? `event:${input.providerEventId.trim()}`
      : `body:${rawBodyHash}`;
    const idempotencyHash = createHash('sha256')
      .update(idempotencySource)
      .digest('hex');

    return {
      providerEventId: input.providerEventId?.trim() || null,
      idempotencyKey: `revenuecat:${idempotencyHash}`,
      eventType: input.eventType,
      rawBodyHash,
      correlationId: input.correlationId,
    };
  }

  async recordInvalidWebhookSignature(input: {
    context: RazorpayWebhookContext;
  }): Promise<void> {
    await this.recordBillingProviderEvent({
      ...input.context,
      razorpayOrderId: null,
      razorpayPaymentId: null,
      outcome: 'invalid_signature',
      errorCode: BILLING_WEBHOOK_INVALID_SIGNATURE,
      metadata: {
        rawBodyHash: input.context.rawBodyHash,
      },
    });

    await this.dispatchBillingOpsAlert({
      alertType: 'billing.webhook_invalid_signature',
      severity: 'critical',
      idempotencyKey: `billing-ops:${input.context.idempotencyKey}:invalid-signature`,
      correlationId: input.context.correlationId,
      metadata: {
        errorCode: BILLING_WEBHOOK_INVALID_SIGNATURE,
        providerEventId: input.context.providerEventId,
        eventType: input.context.eventType,
        rawBodyHash: input.context.rawBodyHash,
      },
    });
  }

  async recordInvalidRevenueCatWebhookAuthorization(input: {
    context: RevenueCatWebhookContext;
  }): Promise<void> {
    await this.recordBillingProviderEvent({
      provider: 'revenuecat',
      ...input.context,
      razorpayOrderId: null,
      razorpayPaymentId: null,
      outcome: 'invalid_signature',
      errorCode: BILLING_WEBHOOK_INVALID_AUTHORIZATION,
      metadata: {
        rawBodyHash: input.context.rawBodyHash,
      },
    });

    await this.dispatchBillingOpsAlert({
      alertType: 'billing.revenuecat_webhook_invalid_authorization',
      severity: 'critical',
      idempotencyKey: `billing-ops:${input.context.idempotencyKey}:invalid-authorization`,
      correlationId: input.context.correlationId,
      metadata: {
        errorCode: BILLING_WEBHOOK_INVALID_AUTHORIZATION,
        providerEventId: input.context.providerEventId,
        eventType: input.context.eventType,
        rawBodyHash: input.context.rawBodyHash,
      },
    });
  }

  async handleWebhookPaymentCaptured(
    input: CapturedPaymentWebhookInput,
  ): Promise<void> {
    const providerEvent = await this.recordBillingProviderEvent({
      ...input,
      outcome: 'received',
      metadata: {
        rawBodyHash: input.rawBodyHash,
        amount: input.amount,
        currency: input.currency,
      },
    });
    if (
      providerEvent.duplicate &&
      this.isTerminalProviderOutcome(providerEvent.outcome)
    ) {
      return;
    }

    const effects: {
      reconciledUserId: string | null;
      pendingReviewAlert: {
        orderId: string;
        mismatch: PaymentExpectationMismatch;
      } | null;
    } = {
      reconciledUserId: null,
      pendingReviewAlert: null,
    };

    await this.dataSource.transaction(async (manager) => {
      const order = await this.lockOrderByRazorpayOrderId(
        input.razorpayOrderId,
        manager,
      );
      if (!order) {
        await this.updateProviderEventOutcome(
          providerEvent.id,
          'ignored',
          manager,
          {
            errorCode: BILLING_ORDER_NOT_FOUND,
            razorpayOrderId: input.razorpayOrderId,
          },
        );
        this.logger.warn(
          `Webhook: order not found for razorpay_order_id=${input.razorpayOrderId}`,
        );
        return;
      }

      if (this.isReconciled(order.status, order.credited)) {
        await this.updateProviderEventOutcome(
          providerEvent.id,
          'duplicate',
          manager,
          {
            orderId: order.id,
            metadata: { reason: 'order_already_reconciled' },
          },
        );
        return;
      }

      if (order.status === 'failed' || order.status === 'pending_review') {
        await this.updateProviderEventOutcome(
          providerEvent.id,
          'ignored',
          manager,
          {
            orderId: order.id,
            metadata: { reason: `order_${order.status}` },
          },
        );
        return;
      }

      const mismatch = this.getPaymentExpectationMismatch(order, input);
      if (mismatch) {
        await this.markOrderPendingReview(
          order,
          mismatch,
          {
            provider: 'razorpay',
            providerEventId: input.providerEventId,
            idempotencyKey: input.idempotencyKey,
            paymentId: input.razorpayPaymentId,
          },
          manager,
        );
        await this.updateProviderEventOutcome(
          providerEvent.id,
          'pending_review',
          manager,
          {
            orderId: order.id,
            errorCode: mismatch.code,
            metadata: {
              reviewReason: mismatch.reviewReason,
              expectedAmount: mismatch.expectedAmount,
              actualAmount: mismatch.actualAmount,
              expectedCurrency: mismatch.expectedCurrency,
              actualCurrency: mismatch.actualCurrency,
            },
          },
        );
        effects.pendingReviewAlert = { orderId: order.id, mismatch };
        return;
      }

      order.status = 'webhook_pending';
      order.razorpayPaymentId = input.razorpayPaymentId;
      order.metadata = this.withoutReviewOrFailureReason(order.metadata);
      await manager.save(OrderEntity, order);

      await this.entitlementsService.addCreditsInTransaction(
        manager,
        order.userId,
        order.creditPack.credits,
        'credit_pack_purchase',
      );

      order.status = 'reconciled';
      order.credited = true;
      await manager.save(OrderEntity, order);
      await this.recordPromoRedemption(order, manager);
      await this.updateProviderEventOutcome(
        providerEvent.id,
        'reconciled',
        manager,
        {
          orderId: order.id,
          metadata: {
            creditsGranted: order.creditPack.credits,
            expectedAmount: this.expectedOrderAmountInSmallestUnit(order),
            actualAmount: input.amount,
            currency: order.currency,
          },
        },
      );

      effects.reconciledUserId = order.userId;
    });

    if (effects.pendingReviewAlert) {
      const alert = effects.pendingReviewAlert;
      await this.dispatchBillingOpsAlert({
        alertType: 'billing.reconciliation_mismatch',
        severity: 'critical',
        idempotencyKey: `billing-ops:${input.idempotencyKey}:mismatch`,
        correlationId: input.correlationId,
        metadata: {
          orderId: alert.orderId,
          errorCode: alert.mismatch.code,
          reviewReason: alert.mismatch.reviewReason,
          expectedAmount: alert.mismatch.expectedAmount,
          actualAmount: alert.mismatch.actualAmount,
          expectedCurrency: alert.mismatch.expectedCurrency,
          actualCurrency: alert.mismatch.actualCurrency,
        },
      });
      return;
    }

    if (!effects.reconciledUserId) return;

    this.logger.log(
      `Webhook: order reconciled (razorpay_order_id=${input.razorpayOrderId})`,
    );

    void this.notificationPipeline
      .dispatch({
        eventType: NotifiableEventType.BILLING_PAYMENT_SUCCESS,
        userId: effects.reconciledUserId,
        correlationId: input.correlationId,
      })
      .catch((err) => {
        this.logger.warn(
          JSON.stringify({
            action: 'NOTIFICATION_DISPATCH_FAILED',
            eventType: NotifiableEventType.BILLING_PAYMENT_SUCCESS,
            correlationId: input.correlationId,
            error: err instanceof Error ? err.message : String(err),
          }),
        );
      });
  }

  async handleWebhookPaymentFailed(
    input: FailedPaymentWebhookInput,
  ): Promise<void> {
    const providerEvent = await this.recordBillingProviderEvent({
      ...input,
      outcome: 'received',
      metadata: {
        rawBodyHash: input.rawBodyHash,
        reason: input.reason ?? null,
      },
    });
    if (
      providerEvent.duplicate &&
      this.isTerminalProviderOutcome(providerEvent.outcome)
    ) {
      return;
    }

    let failedUserId: string | null = null;

    await this.dataSource.transaction(async (manager) => {
      const order = await this.lockOrderByRazorpayOrderId(
        input.razorpayOrderId,
        manager,
      );
      if (!order) {
        await this.updateProviderEventOutcome(
          providerEvent.id,
          'ignored',
          manager,
          {
            errorCode: BILLING_ORDER_NOT_FOUND,
            razorpayOrderId: input.razorpayOrderId,
          },
        );
        this.logger.warn(
          `Webhook: order not found for razorpay_order_id=${input.razorpayOrderId}`,
        );
        return;
      }

      if (this.isReconciled(order.status, order.credited)) {
        await this.updateProviderEventOutcome(
          providerEvent.id,
          'ignored',
          manager,
          {
            orderId: order.id,
            metadata: { reason: 'order_already_reconciled' },
          },
        );
        return;
      }

      if (order.status === 'pending_review') {
        await this.updateProviderEventOutcome(
          providerEvent.id,
          'ignored',
          manager,
          {
            orderId: order.id,
            metadata: { reason: 'order_pending_review' },
          },
        );
        return;
      }

      order.status = 'failed';
      order.razorpayPaymentId =
        input.razorpayPaymentId ?? order.razorpayPaymentId;
      order.metadata = this.withFailureReason(order.metadata, input.reason);
      await manager.save(OrderEntity, order);
      await this.voidPromoReservation(order.id, manager);
      await this.updateProviderEventOutcome(
        providerEvent.id,
        'failed',
        manager,
        {
          orderId: order.id,
          metadata: {
            reason: input.reason ?? null,
            promoReservationVoided: true,
          },
        },
      );
      failedUserId = order.userId;
    });

    if (!failedUserId) return;

    this.logger.log(
      `Webhook: order marked failed (razorpay_order_id=${input.razorpayOrderId})`,
    );

    void this.notificationPipeline
      .dispatch({
        eventType: NotifiableEventType.BILLING_PAYMENT_FAILED,
        userId: failedUserId,
        correlationId: input.correlationId,
      })
      .catch((err) => {
        this.logger.warn(
          JSON.stringify({
            action: 'NOTIFICATION_DISPATCH_FAILED',
            eventType: NotifiableEventType.BILLING_PAYMENT_FAILED,
            correlationId: input.correlationId,
            error: err instanceof Error ? err.message : String(err),
          }),
        );
      });
  }

  async handleRevenueCatPurchaseReconciled(
    input: RevenueCatPurchaseWebhookInput,
  ): Promise<void> {
    const providerEvent = await this.recordBillingProviderEvent({
      provider: 'revenuecat',
      ...input,
      razorpayOrderId: null,
      razorpayPaymentId: input.transactionId,
      outcome: 'received',
      metadata: {
        rawBodyHash: input.rawBodyHash,
        orderId: input.orderId,
        transactionId: input.transactionId,
        appUserId: input.appUserId,
        productId: input.productId,
        amount: input.amount,
        currency: input.currency,
      },
    });
    if (
      providerEvent.duplicate &&
      this.isTerminalProviderOutcome(providerEvent.outcome)
    ) {
      return;
    }

    const effects: {
      reconciledUserId: string | null;
      pendingReviewAlert: {
        orderId: string;
        mismatch: PaymentExpectationMismatch;
      } | null;
    } = {
      reconciledUserId: null,
      pendingReviewAlert: null,
    };

    await this.dataSource.transaction(async (manager) => {
      const order = await this.lockOrderForRevenueCatEvent(input, manager);
      if (!order) {
        await this.updateProviderEventOutcome(
          providerEvent.id,
          'ignored',
          manager,
          {
            errorCode: BILLING_ORDER_NOT_FOUND,
            metadata: {
              reason: 'order_not_found',
              orderId: input.orderId,
              transactionId: input.transactionId,
              appUserId: input.appUserId,
              productId: input.productId,
            },
          },
        );
        this.logger.warn(
          `RevenueCat webhook: order not found for transaction_id=${input.transactionId ?? 'unknown'}`,
        );
        return;
      }

      if (this.isReconciled(order.status, order.credited)) {
        await this.updateProviderEventOutcome(
          providerEvent.id,
          'duplicate',
          manager,
          {
            orderId: order.id,
            metadata: { reason: 'order_already_reconciled' },
          },
        );
        return;
      }

      if (order.status === 'failed' || order.status === 'pending_review') {
        await this.updateProviderEventOutcome(
          providerEvent.id,
          'ignored',
          manager,
          {
            orderId: order.id,
            metadata: { reason: `order_${order.status}` },
          },
        );
        return;
      }

      const mismatch = this.getPaymentExpectationMismatch(order, input);
      if (mismatch) {
        await this.markOrderPendingReview(
          order,
          mismatch,
          {
            provider: 'revenuecat',
            providerEventId: input.providerEventId,
            idempotencyKey: input.idempotencyKey,
            paymentId: input.transactionId,
          },
          manager,
        );
        await this.updateProviderEventOutcome(
          providerEvent.id,
          'pending_review',
          manager,
          {
            orderId: order.id,
            errorCode: mismatch.code,
            metadata: {
              reviewReason: mismatch.reviewReason,
              expectedAmount: mismatch.expectedAmount,
              actualAmount: mismatch.actualAmount,
              expectedCurrency: mismatch.expectedCurrency,
              actualCurrency: mismatch.actualCurrency,
              transactionId: input.transactionId,
            },
          },
        );
        effects.pendingReviewAlert = { orderId: order.id, mismatch };
        return;
      }

      order.status = 'webhook_pending';
      order.razorpayPaymentId = input.transactionId ?? order.razorpayPaymentId;
      order.metadata = this.withRevenueCatWebhookMetadata(
        this.withoutReviewOrFailureReason(order.metadata),
        input,
      );
      await manager.save(OrderEntity, order);

      await this.entitlementsService.addCreditsInTransaction(
        manager,
        order.userId,
        order.creditPack.credits,
        'credit_pack_purchase',
      );

      order.status = 'reconciled';
      order.credited = true;
      await manager.save(OrderEntity, order);
      await this.recordPromoRedemption(order, manager);
      await this.updateProviderEventOutcome(
        providerEvent.id,
        'reconciled',
        manager,
        {
          orderId: order.id,
          metadata: {
            creditsGranted: order.creditPack.credits,
            expectedAmount: this.expectedOrderAmountInSmallestUnit(order),
            actualAmount: input.amount,
            currency: order.currency,
            transactionId: input.transactionId,
          },
        },
      );

      effects.reconciledUserId = order.userId;
    });

    if (effects.pendingReviewAlert) {
      const alert = effects.pendingReviewAlert;
      await this.dispatchBillingOpsAlert({
        alertType: 'billing.reconciliation_mismatch',
        severity: 'critical',
        idempotencyKey: `billing-ops:${input.idempotencyKey}:mismatch`,
        correlationId: input.correlationId,
        metadata: {
          provider: 'revenuecat',
          orderId: alert.orderId,
          errorCode: alert.mismatch.code,
          reviewReason: alert.mismatch.reviewReason,
          expectedAmount: alert.mismatch.expectedAmount,
          actualAmount: alert.mismatch.actualAmount,
          expectedCurrency: alert.mismatch.expectedCurrency,
          actualCurrency: alert.mismatch.actualCurrency,
        },
      });
      return;
    }

    if (!effects.reconciledUserId) return;

    this.logger.log(
      `RevenueCat webhook: order reconciled (transaction_id=${input.transactionId ?? 'unknown'})`,
    );

    void this.notificationPipeline
      .dispatch({
        eventType: NotifiableEventType.BILLING_PAYMENT_SUCCESS,
        userId: effects.reconciledUserId,
        correlationId: input.correlationId,
      })
      .catch((err) => {
        this.logger.warn(
          JSON.stringify({
            action: 'NOTIFICATION_DISPATCH_FAILED',
            eventType: NotifiableEventType.BILLING_PAYMENT_SUCCESS,
            correlationId: input.correlationId,
            error: err instanceof Error ? err.message : String(err),
          }),
        );
      });
  }

  async handleRevenueCatPurchaseFailed(
    input: RevenueCatFailedWebhookInput,
  ): Promise<void> {
    const providerEvent = await this.recordBillingProviderEvent({
      provider: 'revenuecat',
      ...input,
      razorpayOrderId: null,
      razorpayPaymentId: input.transactionId,
      outcome: 'received',
      metadata: {
        rawBodyHash: input.rawBodyHash,
        orderId: input.orderId,
        transactionId: input.transactionId,
        appUserId: input.appUserId,
        productId: input.productId,
        reason: input.reason ?? null,
      },
    });
    if (
      providerEvent.duplicate &&
      this.isTerminalProviderOutcome(providerEvent.outcome)
    ) {
      return;
    }

    let failedUserId: string | null = null;

    await this.dataSource.transaction(async (manager) => {
      const order = await this.lockOrderForRevenueCatEvent(input, manager);
      if (!order) {
        await this.updateProviderEventOutcome(
          providerEvent.id,
          'ignored',
          manager,
          {
            errorCode: BILLING_ORDER_NOT_FOUND,
            metadata: {
              reason: 'order_not_found',
              orderId: input.orderId,
              transactionId: input.transactionId,
              appUserId: input.appUserId,
              productId: input.productId,
            },
          },
        );
        this.logger.warn(
          `RevenueCat webhook: order not found for failed transaction_id=${input.transactionId ?? 'unknown'}`,
        );
        return;
      }

      if (this.isReconciled(order.status, order.credited)) {
        await this.updateProviderEventOutcome(
          providerEvent.id,
          'ignored',
          manager,
          {
            orderId: order.id,
            metadata: { reason: 'order_already_reconciled' },
          },
        );
        return;
      }

      if (order.status === 'pending_review') {
        await this.updateProviderEventOutcome(
          providerEvent.id,
          'ignored',
          manager,
          {
            orderId: order.id,
            metadata: { reason: 'order_pending_review' },
          },
        );
        return;
      }

      order.status = 'failed';
      order.razorpayPaymentId = input.transactionId ?? order.razorpayPaymentId;
      order.metadata = this.withRevenueCatWebhookMetadata(
        this.withFailureReason(order.metadata, input.reason),
        input,
      );
      await manager.save(OrderEntity, order);
      await this.voidPromoReservation(order.id, manager);
      await this.updateProviderEventOutcome(
        providerEvent.id,
        'failed',
        manager,
        {
          orderId: order.id,
          metadata: {
            reason: input.reason ?? null,
            transactionId: input.transactionId,
            promoReservationVoided: true,
          },
        },
      );
      failedUserId = order.userId;
    });

    if (!failedUserId) return;

    this.logger.log(
      `RevenueCat webhook: order marked failed (transaction_id=${input.transactionId ?? 'unknown'})`,
    );

    void this.notificationPipeline
      .dispatch({
        eventType: NotifiableEventType.BILLING_PAYMENT_FAILED,
        userId: failedUserId,
        correlationId: input.correlationId,
      })
      .catch((err) => {
        this.logger.warn(
          JSON.stringify({
            action: 'NOTIFICATION_DISPATCH_FAILED',
            eventType: NotifiableEventType.BILLING_PAYMENT_FAILED,
            correlationId: input.correlationId,
            error: err instanceof Error ? err.message : String(err),
          }),
        );
      });
  }

  async recordIgnoredRevenueCatWebhook(
    input: RevenueCatWebhookContext & {
      transactionId: string | null;
      appUserId: string | null;
      productId: string | null;
    },
  ): Promise<void> {
    await this.recordBillingProviderEvent({
      provider: 'revenuecat',
      ...input,
      razorpayOrderId: null,
      razorpayPaymentId: input.transactionId,
      outcome: 'ignored',
      metadata: {
        rawBodyHash: input.rawBodyHash,
        transactionId: input.transactionId,
        appUserId: input.appUserId,
        productId: input.productId,
        reason: 'event_type_not_relevant_to_credit_pack_reconciliation',
      },
    });
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
    const normalizedCode = this.normalizePromoCode(promoCode);

    try {
      const promo = await this.validatePromo(
        userId,
        promoCode,
        productType,
        productId,
      );

      await this.recordPromoLifecycleEvent({
        promoCodeId: promo.promoCodeId,
        promoCode: promo.promoCode,
        userId,
        productType,
        productRefId: productId,
        orderId: null,
        eventType: 'validation',
        outcome: 'success',
        discountAmount: promo.discountAmount,
        finalAmount: promo.finalAmount,
        currency: promo.currency,
        metadata: {
          originalAmount: promo.originalAmount,
          nonConsuming: true,
        },
      });

      return {
        valid: true,
        originalAmount: promo.originalAmount,
        discountAmount: promo.discountAmount,
        finalAmount: promo.finalAmount,
        currency: promo.currency,
        promoCodeId: promo.promoCodeId,
        promoLabel: promo.promoLabel,
        promoDescription: promo.promoDescription,
        invalidReason: null,
      };
    } catch (err) {
      const invalidReason = this.toPromoInvalidReason(err);
      if (!invalidReason) {
        throw err;
      }

      const context = await this.loadPromoValidationFailureContext({
        normalizedCode,
        productType,
        productId,
      });

      await this.recordPromoLifecycleEvent({
        promoCodeId: context.promoCodeId,
        promoCode: context.normalizedCode,
        userId,
        productType,
        productRefId: this.isUuid(productId) ? productId : null,
        orderId: null,
        eventType: 'validation',
        outcome: 'failure',
        invalidReasonCode: invalidReason.code,
        discountAmount: 0,
        finalAmount: context.finalAmount,
        currency: context.currency,
        metadata: {
          originalAmount: context.originalAmount,
          nonConsuming: true,
        },
      });

      throw new HttpException(
        {
          code: invalidReason.code,
          message: invalidReason.message,
          data: {
            valid: false,
            originalAmount: context.originalAmount,
            discountAmount: 0,
            finalAmount: context.finalAmount,
            currency: context.currency,
            promoCodeId: context.promoCodeId,
            promoLabel: context.promoLabel,
            promoDescription: context.promoDescription,
            invalidReason,
          },
        },
        err instanceof HttpException ? err.getStatus() : 400,
      );
    }
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
        maxDiscountAmount:
          input.dto.discountType === 'percentage' &&
          input.dto.maxDiscountAmount !== undefined
            ? this.roundCurrency(input.dto.maxDiscountAmount).toFixed(2)
            : null,
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
          maxDiscountAmount: saved.maxDiscountAmount
            ? parseFloat(saved.maxDiscountAmount)
            : null,
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
      const nextMaxDiscountAmount =
        nextDiscountType === 'percentage'
          ? input.dto.maxDiscountAmount !== undefined
            ? input.dto.maxDiscountAmount === null
              ? null
              : this.roundCurrency(input.dto.maxDiscountAmount).toFixed(2)
            : promo.maxDiscountAmount
          : null;
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
        nextMaxDiscountAmount !== promo.maxDiscountAmount ||
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
      promo.maxDiscountAmount = nextMaxDiscountAmount;
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
          maxDiscountAmount: saved.maxDiscountAmount
            ? parseFloat(saved.maxDiscountAmount)
            : null,
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

    const [lifecycleCounts, totalItems, financialSummary] = await Promise.all([
      this.queryPromoLifecycleCounts(normalized),
      this.queryPromoAnalyticsCount(normalized),
      this.queryPromoAnalyticsGlobalSummary(normalized),
    ]);
    const rows = await this.queryPromoAnalyticsRows(
      normalized,
      lifecycleCounts,
    );
    const summary: PromoAnalyticsSummaryDto = {
      ...this.summarizePromoLifecycleCounts(lifecycleCounts),
      ...financialSummary,
    };

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
    const lifecycleCounts = await this.queryPromoLifecycleCounts(normalized);
    const rows = await this.queryPromoAnalyticsRows(
      normalized,
      lifecycleCounts,
    );

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
  ): Promise<PromoValidationResult> {
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
  ): Promise<PromoValidationResult> {
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

      await this.expireAbandonedPromoReservations(promo.id, tx);

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
        originalAmount: baseAmount,
        discountAmount,
        finalAmount,
        currency: 'INR',
        promoLabel: this.promoLabel(promo),
        promoDescription: this.promoDescription(promo),
        promoCode: promo.code,
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
    const rawDiscount =
      promo.discountType === 'percentage'
        ? (baseAmount * discountValue) / 100
        : discountValue;
    const cappedDiscount =
      promo.discountType === 'percentage' && promo.maxDiscountAmount !== null
        ? Math.min(rawDiscount, parseFloat(promo.maxDiscountAmount))
        : rawDiscount;

    const discountAmount = this.roundCurrency(
      Math.min(Math.max(cappedDiscount, 0), baseAmount),
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

  private promoLabel(promo: PromoCodeEntity): string {
    const label = promo.metadata?.['label'];
    return typeof label === 'string' && label.trim().length > 0
      ? label.trim()
      : promo.code;
  }

  private promoDescription(promo: PromoCodeEntity): string {
    const description = promo.metadata?.['description'];
    if (typeof description === 'string' && description.trim().length > 0) {
      return description.trim();
    }

    const value = this.roundCurrency(parseFloat(promo.discountValue));
    if (promo.discountType === 'percentage') {
      const cap = promo.maxDiscountAmount
        ? ` up to INR ${parseFloat(promo.maxDiscountAmount).toFixed(2)}`
        : '';
      return `${value.toFixed(2)}% off${cap}`;
    }

    return `INR ${value.toFixed(2)} off`;
  }

  private toPromoInvalidReason(err: unknown): PromoInvalidReasonDto | null {
    if (!(err instanceof HttpException)) {
      return null;
    }

    const response = err.getResponse();
    if (
      typeof response === 'object' &&
      response !== null &&
      'code' in response &&
      'message' in response
    ) {
      const typed = response as Record<string, unknown>;
      if (
        typeof typed.code === 'string' &&
        typeof typed.message === 'string'
      ) {
        return {
          code: typed.code,
          message: typed.message,
        };
      }
    }

    return null;
  }

  private async loadPromoValidationFailureContext(input: {
    normalizedCode: string;
    productType: PromoProductType;
    productId: string;
  }): Promise<PromoValidationFailureContext> {
    const [promo, productAmount] = await Promise.all([
      this.promoCodeRepo
        .createQueryBuilder('promo')
        .where('UPPER(promo.code) = :code', { code: input.normalizedCode })
        .getOne(),
      this.loadPromoProductAmount(input.productType, input.productId),
    ]);

    return {
      promoCodeId: promo?.id ?? null,
      originalAmount: productAmount.amount,
      finalAmount: productAmount.amount,
      currency: productAmount.currency,
      promoLabel: promo ? this.promoLabel(promo) : null,
      promoDescription: promo ? this.promoDescription(promo) : null,
      normalizedCode: input.normalizedCode,
    };
  }

  private async loadPromoProductAmount(
    productType: PromoProductType,
    productId: string,
  ): Promise<{ amount: number; currency: string }> {
    if (productType !== 'credit_pack' || !this.isUuid(productId)) {
      return { amount: 0, currency: 'INR' };
    }

    const pack = await this.creditPackRepo.findOne({ where: { id: productId } });
    return {
      amount: pack ? parseFloat(pack.priceInr) : 0,
      currency: 'INR',
    };
  }

  private resolvePromoReservationTimeoutMinutes(): number {
    const raw = process.env.BILLING_PROMO_RESERVATION_TIMEOUT_MINUTES;
    const parsed = raw ? parseInt(raw, 10) : NaN;
    if (Number.isFinite(parsed) && parsed > 0) {
      return parsed;
    }
    return 30;
  }

  private async expireAbandonedPromoReservations(
    promoCodeId: string,
    manager: EntityManager,
  ): Promise<number> {
    const cutoff = new Date(
      Date.now() - this.PROMO_RESERVATION_TIMEOUT_MINUTES * 60 * 1000,
    );
    const rows = await manager
      .getRepository(PromoRedemptionEntity)
      .createQueryBuilder('redemption')
      .innerJoin(OrderEntity, 'checkout_order', 'checkout_order.id = redemption.order_id')
      .select('DISTINCT checkout_order.id', 'orderId')
      .where('redemption.promo_code_id = :promoCodeId', { promoCodeId })
      .andWhere("redemption.status = 'reserved'")
      .andWhere("checkout_order.status IN ('created', 'payment_pending')")
      .andWhere('checkout_order.updated_at <= :cutoff', {
        cutoff: cutoff.toISOString(),
      })
      .getRawMany<{ orderId: string }>();

    if (rows.length === 0) {
      return 0;
    }

    let expiredCount = 0;
    for (const row of rows) {
      const order = await manager
        .getRepository(OrderEntity)
        .createQueryBuilder('order')
        .setLock('pessimistic_write')
        .where('order.id = :orderId', { orderId: row.orderId })
        .getOne();
      if (!order) continue;
      if (order.status !== 'created' && order.status !== 'payment_pending') {
        continue;
      }
      if (order.updatedAt > cutoff) continue;

      order.status = 'failed';
      order.credited = false;
      order.metadata = {
        ...(order.metadata ?? {}),
        promoReservationExpiredAt: new Date().toISOString(),
        promoReservationTimeoutMinutes: this.PROMO_RESERVATION_TIMEOUT_MINUTES,
      };
      order.metadata = this.withFailureReason(
        order.metadata,
        'Checkout expired before payment was completed.',
      );
      await manager.save(OrderEntity, order);
      await this.voidPromoReservation(order.id, manager);
      expiredCount += 1;
    }

    return expiredCount;
  }

  private normalizeOptionalIdempotencyKey(value?: string): string | null {
    const trimmed = value?.trim();
    return trimmed && trimmed.length > 0 ? trimmed : null;
  }

  private buildZeroCheckoutKey(input: {
    userId: string;
    creditPackId: string;
    promoCode: string;
    idempotencyKey?: string;
  }): string {
    const clientKey = this.normalizeOptionalIdempotencyKey(input.idempotencyKey);
    const normalizedCode = this.normalizePromoCode(input.promoCode);
    const source = [
      'zero-checkout',
      input.userId,
      input.creditPackId,
      normalizedCode,
      clientKey ?? 'default',
    ].join(':');
    const digest = createHash('sha256').update(source).digest('hex');
    return `zero:${digest}`;
  }

  private async findExistingZeroCheckoutOrder(
    zeroCheckoutKey: string,
    manager: EntityManager,
  ): Promise<OrderEntity | null> {
    return manager
      .getRepository(OrderEntity)
      .createQueryBuilder('order')
      .setLock('pessimistic_write')
      .where("order.metadata ->> 'zeroCheckoutKey' = :zeroCheckoutKey", {
        zeroCheckoutKey,
      })
      .andWhere('order.status = :status', { status: 'reconciled' })
      .andWhere('order.credited = true')
      .orderBy('order.updated_at', 'DESC')
      .getOne();
  }

  private async createZeroAmountPromoOrder(input: {
    manager: EntityManager;
    userId: string;
    pack: CreditPackEntity;
    promo: PromoValidationResult;
    zeroCheckoutKey: string;
    correlationId: string;
  }): Promise<PromoCheckoutTransactionResult> {
    const now = new Date().toISOString();
    const order = input.manager.create(OrderEntity, {
      userId: input.userId,
      creditPackId: input.pack.id,
      amount: input.pack.priceInr,
      currency: input.promo.currency,
      status: 'created',
      razorpayOrderId: `internal_zero_${randomUUID()}`,
      razorpayPaymentId: null,
      razorpaySignature: null,
      credited: false,
      promoCodeId: input.promo.promoCodeId,
      discountAmount: input.promo.discountAmount.toFixed(2),
      finalAmount: input.promo.finalAmount.toFixed(2),
      metadata: {
        checkoutProvider: 'internal',
        zeroCheckoutKey: input.zeroCheckoutKey,
        zeroAmountCheckout: true,
        promoCode: input.promo.promoCode,
        createdReason: 'promo_zero_amount_checkout',
        createdAt: now,
      },
    });
    const saved = await input.manager.save(OrderEntity, order);

    await this.reservePromoRedemption(saved, input.manager);
    await this.entitlementsService.addCreditsInTransaction(
      input.manager,
      saved.userId,
      input.pack.credits,
      'credit_pack_purchase',
    );

    saved.status = 'reconciled';
    saved.credited = true;
    saved.metadata = {
      ...(saved.metadata ?? {}),
      reconciledAt: now,
      creditsGranted: input.pack.credits,
    };
    await input.manager.save(OrderEntity, saved);

    await this.recordPromoRedemption(saved, input.manager);
    await this.recordInternalZeroCheckoutProviderEvent({
      manager: input.manager,
      order: saved,
      promo: input.promo,
      zeroCheckoutKey: input.zeroCheckoutKey,
      creditsGranted: input.pack.credits,
    });

    return {
      response: {
        orderId: saved.id,
        razorpayOrderId: null,
        amount: 0,
        currency: saved.currency,
        razorpayKeyId: null,
        paymentRequired: false,
        checkoutProvider: 'internal',
        orderStatus: 'reconciled',
      },
      receiptNotification: {
        userId: input.userId,
        correlationId: input.correlationId,
        idempotencyKey: `billing-receipt:${input.zeroCheckoutKey}`,
        metadata: {
          orderId: saved.id,
          checkoutProvider: 'internal',
          promoCodeId: input.promo.promoCodeId,
          promoCode: input.promo.promoCode,
          discountAmount: input.promo.discountAmount,
          finalAmount: input.promo.finalAmount,
          creditsGranted: input.pack.credits,
        },
      },
    };
  }

  private async recordInternalZeroCheckoutProviderEvent(input: {
    manager: EntityManager;
    order: OrderEntity;
    promo: PromoValidationResult;
    zeroCheckoutKey: string;
    creditsGranted: number;
  }): Promise<void> {
    await input.manager.getRepository(BillingProviderEventEntity).save(
      input.manager.getRepository(BillingProviderEventEntity).create({
        provider: 'internal',
        providerEventId: input.order.id,
        idempotencyKey: `internal:${input.zeroCheckoutKey}`,
        eventType: 'promo.zero_amount_checkout',
        orderId: input.order.id,
        razorpayOrderId: input.order.razorpayOrderId,
        razorpayPaymentId: null,
        outcome: 'reconciled',
        errorCode: null,
        metadata: {
          promoCodeId: input.promo.promoCodeId,
          promoCode: input.promo.promoCode,
          discountAmount: input.promo.discountAmount,
          finalAmount: input.promo.finalAmount,
          creditsGranted: input.creditsGranted,
        },
      }),
    );
  }

  private async dispatchBillingPaymentSuccess(input: {
    userId: string;
    correlationId: string;
    idempotencyKey: string;
    metadata: Record<string, string | number | boolean | null>;
  }): Promise<void> {
    try {
      await this.notificationPipeline.dispatch({
        eventType: NotifiableEventType.BILLING_PAYMENT_SUCCESS,
        userId: input.userId,
        correlationId: input.correlationId,
        idempotencyKey: input.idempotencyKey,
        metadata: input.metadata,
      });
    } catch (err) {
      this.logger.warn(
        JSON.stringify({
          action: 'NOTIFICATION_DISPATCH_FAILED',
          eventType: NotifiableEventType.BILLING_PAYMENT_SUCCESS,
          correlationId: input.correlationId,
          error: err instanceof Error ? err.message : String(err),
        }),
      );
    }
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

  private async lockOrderByRazorpayOrderId(
    razorpayOrderId: string,
    manager: EntityManager,
  ): Promise<OrderEntity | null> {
    if (!razorpayOrderId.trim()) return null;

    return manager
      .getRepository(OrderEntity)
      .createQueryBuilder('order')
      .leftJoinAndSelect('order.creditPack', 'creditPack')
      .setLock('pessimistic_write')
      .where('order.razorpay_order_id = :razorpayOrderId', {
        razorpayOrderId,
      })
      .getOne();
  }

  private async lockOrderForRevenueCatEvent(
    input: {
      orderId: string | null;
      transactionId: string | null;
      appUserId: string | null;
      productId: string | null;
    },
    manager: EntityManager,
  ): Promise<OrderEntity | null> {
    const repo = manager.getRepository(OrderEntity);

    if (input.orderId?.trim() && this.isUuid(input.orderId.trim())) {
      return repo
        .createQueryBuilder('order')
        .leftJoinAndSelect('order.creditPack', 'creditPack')
        .setLock('pessimistic_write')
        .where('order.id = :orderId', { orderId: input.orderId.trim() })
        .getOne();
    }

    if (input.transactionId?.trim()) {
      const order = await repo
        .createQueryBuilder('order')
        .leftJoinAndSelect('order.creditPack', 'creditPack')
        .setLock('pessimistic_write')
        .where(
          "order.metadata ->> 'revenueCatTransactionId' = :transactionId",
          {
            transactionId: input.transactionId.trim(),
          },
        )
        .getOne();
      if (order) return order;
    }

    if (
      input.appUserId?.trim() &&
      input.productId?.trim() &&
      this.isUuid(input.appUserId.trim())
    ) {
      return repo
        .createQueryBuilder('order')
        .leftJoinAndSelect('order.creditPack', 'creditPack')
        .setLock('pessimistic_write')
        .where('order.user_id = :userId', { userId: input.appUserId.trim() })
        .andWhere("order.metadata ->> 'revenueCatProductId' = :productId", {
          productId: input.productId.trim(),
        })
        .andWhere(
          "order.status IN ('created', 'payment_pending', 'client_purchase_confirmed', 'webhook_pending')",
        )
        .orderBy('order.updated_at', 'DESC')
        .getOne();
    }

    return null;
  }

  private getPaymentExpectationMismatch(
    order: OrderEntity,
    input: { amount: number | null; currency: string | null },
  ): PaymentExpectationMismatch | null {
    const expectedAmount = this.expectedOrderAmountInSmallestUnit(order);
    const expectedCurrency = order.currency.toUpperCase();
    const actualCurrency = input.currency?.trim().toUpperCase() || null;

    if (input.amount === null || actualCurrency === null) {
      return {
        code: BILLING_RECONCILIATION_PAYLOAD_INCOMPLETE,
        reviewReason: 'Payment webhook payload is missing amount or currency',
        expectedAmount,
        actualAmount: input.amount,
        expectedCurrency,
        actualCurrency,
      };
    }

    if (input.amount !== expectedAmount) {
      return {
        code: BILLING_RECONCILIATION_AMOUNT_MISMATCH,
        reviewReason: 'Payment webhook amount does not match order amount',
        expectedAmount,
        actualAmount: input.amount,
        expectedCurrency,
        actualCurrency,
      };
    }

    if (actualCurrency !== expectedCurrency) {
      return {
        code: BILLING_RECONCILIATION_CURRENCY_MISMATCH,
        reviewReason: 'Payment webhook currency does not match order currency',
        expectedAmount,
        actualAmount: input.amount,
        expectedCurrency,
        actualCurrency,
      };
    }

    return null;
  }

  private expectedOrderAmountInSmallestUnit(order: OrderEntity): number {
    return Math.round(parseFloat(order.finalAmount ?? order.amount) * 100);
  }

  private isUuid(value: string): boolean {
    return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(
      value,
    );
  }

  private async markOrderPendingReview(
    order: OrderEntity,
    mismatch: PaymentExpectationMismatch,
    input: {
      provider: string;
      providerEventId: string | null;
      idempotencyKey: string;
      paymentId: string | null;
    },
    manager: EntityManager,
  ): Promise<void> {
    order.status = 'pending_review';
    order.razorpayPaymentId = input.paymentId ?? order.razorpayPaymentId;
    order.credited = false;
    order.metadata = {
      ...(order.metadata ?? {}),
      provider: input.provider,
      reviewReason: mismatch.reviewReason,
      reviewCode: mismatch.code,
      providerEventId: input.providerEventId,
      idempotencyKey: input.idempotencyKey,
      expectedAmount: mismatch.expectedAmount,
      actualAmount: mismatch.actualAmount,
      expectedCurrency: mismatch.expectedCurrency,
      actualCurrency: mismatch.actualCurrency,
    };
    await manager.save(OrderEntity, order);
  }

  private async recordBillingProviderEvent(input: {
    provider?: string;
    providerEventId: string | null;
    idempotencyKey: string;
    eventType: string;
    razorpayOrderId: string | null;
    razorpayPaymentId: string | null;
    outcome: BillingProviderEventOutcome;
    errorCode?: string;
    metadata?: Record<string, string | number | boolean | null>;
  }): Promise<{
    id: string;
    duplicate: boolean;
    outcome: BillingProviderEventOutcome;
  }> {
    const existing = await this.providerEventRepo.findOne({
      where: { idempotencyKey: input.idempotencyKey },
    });
    if (existing) {
      return {
        id: existing.id,
        duplicate: true,
        outcome: existing.outcome,
      };
    }

    let saved: BillingProviderEventEntity;
    try {
      saved = await this.providerEventRepo.save(
        this.providerEventRepo.create({
          provider: input.provider ?? 'razorpay',
          providerEventId: input.providerEventId,
          idempotencyKey: input.idempotencyKey,
          eventType: input.eventType,
          razorpayOrderId: input.razorpayOrderId,
          razorpayPaymentId: input.razorpayPaymentId,
          outcome: input.outcome,
          errorCode: input.errorCode ?? null,
          metadata: input.metadata ?? null,
        }),
      );
    } catch (err) {
      const duplicate = await this.providerEventRepo.findOne({
        where: { idempotencyKey: input.idempotencyKey },
      });
      if (duplicate) {
        return {
          id: duplicate.id,
          duplicate: true,
          outcome: duplicate.outcome,
        };
      }
      throw err;
    }

    return {
      id: saved.id,
      duplicate: false,
      outcome: saved.outcome,
    };
  }

  private isTerminalProviderOutcome(
    outcome: BillingProviderEventOutcome,
  ): boolean {
    return outcome !== 'received';
  }

  private async updateProviderEventOutcome(
    providerEventId: string,
    outcome: BillingProviderEventOutcome,
    manager: EntityManager,
    input?: {
      orderId?: string;
      razorpayOrderId?: string;
      errorCode?: string;
      metadata?: Record<string, string | number | boolean | null>;
    },
  ): Promise<void> {
    await manager
      .getRepository(BillingProviderEventEntity)
      .createQueryBuilder()
      .update(BillingProviderEventEntity)
      .set({
        outcome,
        orderId: input?.orderId,
        razorpayOrderId: input?.razorpayOrderId,
        errorCode: input?.errorCode ?? null,
        metadata: input?.metadata ?? null,
      })
      .where('id = :providerEventId', { providerEventId })
      .andWhere('outcome = :received', { received: 'received' })
      .execute();
  }

  private async dispatchBillingOpsAlert(input: {
    alertType: string;
    severity: 'warning' | 'critical';
    idempotencyKey: string;
    correlationId: string;
    metadata: Record<string, string | number | boolean | null>;
  }): Promise<void> {
    try {
      await this.notificationPipeline.dispatchOpsAlert(input);
    } catch (err) {
      this.logger.warn(
        JSON.stringify({
          action: 'OPS_ALERT_DISPATCH_FAILED',
          alertType: input.alertType,
          correlationId: input.correlationId,
          error: err instanceof Error ? err.message : String(err),
        }),
      );
    }
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

  private withoutReviewOrFailureReason(
    metadata: Record<string, unknown> | null,
  ): Record<string, unknown> | null {
    const withoutFailure = this.withoutFailureReason(metadata);
    if (!withoutFailure) return null;

    const copy = { ...withoutFailure };
    for (const key of [
      'reviewReason',
      'reviewCode',
      'providerEventId',
      'idempotencyKey',
      'expectedAmount',
      'actualAmount',
      'expectedCurrency',
      'actualCurrency',
    ]) {
      delete copy[key];
    }

    return Object.keys(copy).length === 0 ? null : copy;
  }

  private withClientPurchaseMetadata(
    metadata: Record<string, unknown> | null,
    dto: ConfirmClientPurchaseDto,
  ): Record<string, unknown> | null {
    const next: Record<string, unknown> = { ...(metadata ?? {}) };
    next.clientPurchaseConfirmedAt = new Date().toISOString();

    this.assignTrimmedMetadata(
      next,
      'revenueCatTransactionId',
      dto.revenueCatTransactionId,
    );
    this.assignTrimmedMetadata(
      next,
      'revenueCatProductId',
      dto.revenueCatProductId,
    );
    this.assignTrimmedMetadata(
      next,
      'revenueCatAppUserId',
      dto.revenueCatAppUserId,
    );

    return Object.keys(next).length === 0 ? null : next;
  }

  private withRevenueCatWebhookMetadata(
    metadata: Record<string, unknown> | null,
    input: RevenueCatPurchaseWebhookInput | RevenueCatFailedWebhookInput,
  ): Record<string, unknown> | null {
    const next: Record<string, unknown> = {
      ...(metadata ?? {}),
      provider: 'revenuecat',
      revenueCatEventId: input.providerEventId,
      revenueCatEventType: input.eventType,
      revenueCatWebhookReceivedAt: new Date().toISOString(),
    };

    this.assignTrimmedMetadata(
      next,
      'revenueCatTransactionId',
      input.transactionId,
    );
    this.assignTrimmedMetadata(next, 'revenueCatProductId', input.productId);
    this.assignTrimmedMetadata(next, 'revenueCatAppUserId', input.appUserId);

    if ('amount' in input) {
      next.revenueCatAmount = input.amount;
      next.revenueCatCurrency = input.currency;
    }

    return Object.keys(next).length === 0 ? null : next;
  }

  private assignTrimmedMetadata(
    target: Record<string, unknown>,
    key: string,
    value: string | null | undefined,
  ): void {
    if (typeof value === 'string' && value.trim().length > 0) {
      target[key] = value.trim();
    }
  }

  private async recordPromoLifecycleEvent(input: {
    manager?: EntityManager;
    promoCodeId: string | null;
    promoCode: string | null;
    userId: string | null;
    productType: PromoProductType | null;
    productRefId: string | null;
    orderId: string | null;
    eventType: PromoLifecycleEventType;
    outcome: PromoLifecycleEventOutcome;
    invalidReasonCode?: string | null;
    discountAmount?: number | string | null;
    finalAmount?: number | string | null;
    currency?: string | null;
    idempotencyKey?: string | null;
    metadata?: Record<string, string | number | boolean | null>;
  }): Promise<void> {
    const repo = input.manager
      ? input.manager.getRepository(PromoLifecycleEventEntity)
      : this.promoLifecycleEventRepo;

    await repo.save(
      repo.create({
        promoCodeId: input.promoCodeId,
        promoCodeValue: input.promoCode,
        userId: input.userId,
        productType: input.productType,
        productRefId: input.productRefId,
        orderId: input.orderId,
        eventType: input.eventType,
        outcome: input.outcome,
        invalidReasonCode: input.invalidReasonCode ?? null,
        discountAmount: this.toNullableCurrencyString(input.discountAmount),
        finalAmount: this.toNullableCurrencyString(input.finalAmount),
        currency: input.currency ?? null,
        idempotencyKey: input.idempotencyKey ?? null,
        metadata: input.metadata ?? null,
      }),
    );
  }

  private toNullableCurrencyString(
    value?: number | string | null,
  ): string | null {
    if (value === undefined || value === null) return null;
    const parsed = typeof value === 'number' ? value : parseFloat(value);
    if (Number.isNaN(parsed)) return null;
    return this.roundCurrency(parsed).toFixed(2);
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

    await this.recordPromoLifecycleEvent({
      manager,
      promoCodeId: order.promoCodeId,
      promoCode: null,
      userId: order.userId,
      productType: 'credit_pack',
      productRefId: order.creditPackId,
      orderId: order.id,
      eventType: 'reservation',
      outcome: 'success',
      discountAmount: order.discountAmount,
      finalAmount: order.finalAmount,
      currency: order.currency,
    });
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
    if ((existingReserved.affected ?? 0) > 0) {
      await this.recordPromoLifecycleEvent({
        manager,
        promoCodeId: order.promoCodeId,
        promoCode: null,
        userId: order.userId,
        productType: 'credit_pack',
        productRefId: order.creditPackId,
        orderId: order.id,
        eventType: 'redeemed',
        outcome: 'success',
        discountAmount: order.discountAmount,
        finalAmount: order.finalAmount,
        currency: order.currency,
      });
      return;
    }

    const existing = await repo.findOne({
      where: {
        promoCodeId: order.promoCodeId,
        orderId: order.id,
      },
    });
    if (existing?.status === 'redeemed') return;

    const inserted = await repo
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
    if ((inserted.identifiers?.length ?? 0) === 0) return;

    await this.recordPromoLifecycleEvent({
      manager,
      promoCodeId: order.promoCodeId,
      promoCode: null,
      userId: order.userId,
      productType: 'credit_pack',
      productRefId: order.creditPackId,
      orderId: order.id,
      eventType: 'redeemed',
      outcome: 'success',
      discountAmount: order.discountAmount,
      finalAmount: order.finalAmount,
      currency: order.currency,
    });
  }

  private async voidPromoReservation(
    orderId: string,
    manager?: EntityManager,
  ): Promise<void> {
    const repo = manager
      ? manager.getRepository(PromoRedemptionEntity)
      : this.promoRedemptionRepo;
    const result = await repo
      .createQueryBuilder()
      .update(PromoRedemptionEntity)
      .set({ status: 'void' })
      .where('order_id = :orderId', { orderId })
      .andWhere("status = 'reserved'")
      .execute();
    if ((result.affected ?? 0) === 0) return;

    const orderRepo = manager
      ? manager.getRepository(OrderEntity)
      : this.orderRepo;
    const order = await orderRepo.findOne({ where: { id: orderId } });
    if (!order?.promoCodeId) return;

    await this.recordPromoLifecycleEvent({
      manager,
      promoCodeId: order.promoCodeId,
      promoCode: null,
      userId: order.userId,
      productType: 'credit_pack',
      productRefId: order.creditPackId,
      orderId: order.id,
      eventType: 'failed',
      outcome: 'failure',
      discountAmount: order.discountAmount,
      finalAmount: order.finalAmount,
      currency: order.currency,
      metadata: {
        orderStatus: order.status,
      },
    });
    await this.recordPromoLifecycleEvent({
      manager,
      promoCodeId: order.promoCodeId,
      promoCode: null,
      userId: order.userId,
      productType: 'credit_pack',
      productRefId: order.creditPackId,
      orderId: order.id,
      eventType: 'voided',
      outcome: 'success',
      discountAmount: order.discountAmount,
      finalAmount: order.finalAmount,
      currency: order.currency,
      metadata: {
        orderStatus: order.status,
      },
    });
  }

  private async voidReservedRedemptions(
    promoCodeId: string,
    manager: EntityManager,
  ): Promise<number> {
    const repo = manager.getRepository(PromoRedemptionEntity);
    const reserved = await repo.find({
      where: {
        promoCodeId,
        status: 'reserved',
      },
    });
    const result = await repo
      .createQueryBuilder()
      .update(PromoRedemptionEntity)
      .set({ status: 'void' })
      .where('promo_code_id = :promoCodeId', { promoCodeId })
      .andWhere("status = 'reserved'")
      .execute();
    if ((result.affected ?? 0) === 0) return 0;

    for (const redemption of reserved) {
      await this.recordPromoLifecycleEvent({
        manager,
        promoCodeId: redemption.promoCodeId,
        promoCode: null,
        userId: redemption.userId,
        productType: redemption.productType,
        productRefId: redemption.productRefId,
        orderId: redemption.orderId,
        eventType: 'voided',
        outcome: 'success',
        discountAmount: redemption.discountAmount,
        finalAmount: null,
        currency: redemption.currency,
        metadata: {
          reason: 'promo_lifecycle_change',
        },
      });
    }

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
  }): Promise<PromoFinancialAnalyticsSummary> {
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

  private async queryPromoLifecycleCounts(input: {
    promoCodeId: string | null;
    productType: PromoProductType | 'all';
    window: { from: Date; to: Date };
  }): Promise<Record<string, PromoLifecycleCounts>> {
    const qb = this.promoLifecycleEventRepo
      .createQueryBuilder('event')
      .select('event.promoCodeId', 'promoCodeId')
      .addSelect('event.eventType', 'eventType')
      .addSelect('COUNT(event.id)', 'count')
      .where('event.createdAt >= :dateFrom', {
        dateFrom: input.window.from.toISOString(),
      })
      .andWhere('event.createdAt <= :dateTo', {
        dateTo: input.window.to.toISOString(),
      })
      .andWhere('event.promoCodeId IS NOT NULL');

    if (input.promoCodeId) {
      qb.andWhere('event.promoCodeId = :promoCodeId', {
        promoCodeId: input.promoCodeId,
      });
    }
    if (input.productType !== 'all') {
      qb.andWhere('event.productType = :productType', {
        productType: input.productType,
      });
    }

    const rows = await qb
      .groupBy('event.promoCodeId')
      .addGroupBy('event.eventType')
      .getRawMany<{
        promoCodeId: string;
        eventType: PromoLifecycleEventType;
        count: string;
      }>();

    const result: Record<string, PromoLifecycleCounts> = {};
    for (const row of rows) {
      const bucket = (result[row.promoCodeId] ??=
        this.emptyPromoLifecycleCounts());
      const count = parseInt(row.count, 10) || 0;
      switch (row.eventType) {
        case 'validation':
          bucket.validation = count;
          break;
        case 'reservation':
          bucket.reservation = count;
          break;
        case 'redeemed':
          bucket.redeemed = count;
          break;
        case 'failed':
          bucket.failed = count;
          break;
        case 'voided':
          bucket.voided = count;
          break;
      }
    }

    return result;
  }

  private summarizePromoLifecycleCounts(
    countsByPromoId: Record<string, PromoLifecycleCounts>,
  ): Pick<
    PromoAnalyticsSummaryDto,
    | 'totalValidationCount'
    | 'totalReservationCount'
    | 'totalRedeemedCount'
    | 'totalFailedCount'
    | 'totalVoidedCount'
  > {
    const summary = this.emptyPromoLifecycleCounts();
    for (const counts of Object.values(countsByPromoId)) {
      summary.validation += counts.validation;
      summary.reservation += counts.reservation;
      summary.redeemed += counts.redeemed;
      summary.failed += counts.failed;
      summary.voided += counts.voided;
    }

    return {
      totalValidationCount: summary.validation,
      totalReservationCount: summary.reservation,
      totalRedeemedCount: summary.redeemed,
      totalFailedCount: summary.failed,
      totalVoidedCount: summary.voided,
    };
  }

  private emptyPromoLifecycleCounts(): PromoLifecycleCounts {
    return {
      validation: 0,
      reservation: 0,
      redeemed: 0,
      failed: 0,
      voided: 0,
    };
  }

  private async queryPromoAnalyticsRows(
    input: {
      promoCodeId: string | null;
      productType: PromoProductType | 'all';
      window: { from: Date; to: Date };
      pagination: { page: number; pageSize: number };
    },
    lifecycleCounts: Record<string, PromoLifecycleCounts>,
  ): Promise<PromoAnalyticsRowDto[]> {
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

    return rows.map((row) => {
      const lifecycle = lifecycleCounts[row.promoCodeId] ?? {
        validation: 0,
        reservation: 0,
        redeemed: 0,
        failed: 0,
        voided: 0,
      };

      return {
        promoCodeId: row.promoCodeId,
        promoCode: row.promoCode,
        validationCount: lifecycle.validation,
        reservationCount: lifecycle.reservation,
        redeemedCount: lifecycle.redeemed,
        failedCount: lifecycle.failed,
        voidedCount: lifecycle.voided,
        reconciledCheckoutCount:
          parseInt(row.reconciledCheckoutCount, 10) || 0,
        failedCheckoutCount: parseInt(row.failedCheckoutCount, 10) || 0,
        attributedDiscountTotal: parseFloat(row.attributedDiscountTotal) || 0,
        finalizedRevenueTotal: parseFloat(row.finalizedRevenueTotal) || 0,
      };
    });
  }

  private toPromoAnalyticsCsv(rows: PromoAnalyticsRowDto[]): string {
    const header = [
      'promoCodeId',
      'promoCode',
      'validationCount',
      'reservationCount',
      'redeemedCount',
      'failedCount',
      'voidedCount',
      'reconciledCheckoutCount',
      'failedCheckoutCount',
      'attributedDiscountTotal',
      'finalizedRevenueTotal',
    ].join(',');

    const lines = rows.map((row) =>
      [
        row.promoCodeId,
        this.escapeCsvCell(row.promoCode),
        row.validationCount.toString(),
        row.reservationCount.toString(),
        row.redeemedCount.toString(),
        row.failedCount.toString(),
        row.voidedCount.toString(),
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
      maxDiscountAmount: promo.maxDiscountAmount
        ? parseFloat(promo.maxDiscountAmount)
        : null,
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

  private toAdminBillingOrderRow(order: OrderEntity): AdminBillingOrderRowDto {
    const status = toOrderStatusDto(order);
    const metadata = order.metadata ?? {};
    const provider =
      (typeof metadata['provider'] === 'string' && metadata['provider']) ||
      (status.finalAmount <= 0 ? 'internal' : 'razorpay');
    const paymentReference =
      (typeof metadata['revenueCatTransactionId'] === 'string' &&
        metadata['revenueCatTransactionId']) ||
      order.razorpayPaymentId ||
      null;

    return {
      id: order.id,
      userId: order.userId,
      userEmail: order.user.email,
      userDisplayName: order.user.displayName,
      creditPackId: order.creditPackId,
      creditPackName: order.creditPack.name,
      credits: order.creditPack.credits,
      amount: parseFloat(order.amount),
      finalAmount: status.finalAmount,
      currency: order.currency,
      status: status.status,
      statusLabel: status.statusLabel,
      credited: order.credited,
      provider:
        provider === 'revenuecat' || provider === 'internal'
          ? provider
          : 'razorpay',
      checkoutProvider:
        provider === 'revenuecat' || provider === 'internal'
          ? provider
          : 'razorpay',
      orderReference: order.razorpayOrderId,
      paymentReference,
      failureReason: status.failureReason,
      reviewReason: status.reviewReason,
      createdAt: order.createdAt.toISOString(),
      updatedAt: order.updatedAt.toISOString(),
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
