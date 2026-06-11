import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Logger,
  Param,
  Post,
  Put,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { Request } from 'express';
import { AuthGuard } from '../../common/guards/auth.guard';
import { getCorrelationId } from '../../common/correlation-id.middleware';
import { successResponse } from '../../common/response-envelope';
import type { RequestUser } from '../auth/auth.types';
import { SuperadminGuard } from '../auth/superadmin.guard';
import { BillingService } from './billing.service';
import { RazorpayService } from './razorpay.service';
import {
  AdminPromoAnalyticsExportDto,
  AdminPromoAnalyticsQueryDto,
  AdminCreatePromoCodeDto,
  AdminUpdatePromoCodeDto,
  ConfirmClientPurchaseDto,
  CreateOrderDto,
  CreateSubscriptionDto,
  ListOrdersQueryDto,
  PromoValidationDto,
  VerifyPaymentDto,
  VerifySubscriptionDto,
  BILLING_WEBHOOK_INVALID_AUTHORIZATION,
  BILLING_WEBHOOK_INVALID_SIGNATURE,
} from './billing.types';
import { RevenueCatService } from './revenuecat.service';

interface RazorpayPaymentWebhookEntity extends Record<string, unknown> {
  order_id?: string;
  id?: string;
  amount?: number;
  currency?: string;
  error_description?: string;
  error_reason?: string;
  error_source?: string;
  error_step?: string;
  error_code?: string;
}

interface RazorpayWebhookPayload {
  event?: string;
  payload?: {
    payment?: {
      entity?: RazorpayPaymentWebhookEntity;
    };
    order?: {
      entity?: { id?: string };
    };
    subscription?: {
      entity?: { id?: string };
    };
  };
}

interface RevenueCatSubscriberAttribute {
  value?: string | null;
}

interface RevenueCatWebhookEvent extends Record<string, unknown> {
  id?: string;
  type?: string;
  transaction_id?: string;
  app_user_id?: string;
  product_id?: string;
  currency?: string | null;
  price?: number | null;
  price_in_purchased_currency?: number | null;
  cancel_reason?: string | null;
  expiration_reason?: string | null;
  subscriber_attributes?: Record<
    string,
    RevenueCatSubscriberAttribute | string | null
  >;
}

interface RevenueCatWebhookPayload {
  event?: RevenueCatWebhookEvent;
}

@Controller('billing')
export class BillingController {
  private readonly logger = new Logger(BillingController.name);

  constructor(
    private readonly billingService: BillingService,
    private readonly razorpayService: RazorpayService,
    private readonly revenueCatService: RevenueCatService,
  ) {}

  @Get('credit-packs')
  @UseGuards(AuthGuard)
  async getCreditPacks(@Req() req: Request): Promise<object> {
    const data = await this.billingService.listCreditPacks();
    return successResponse(data, getCorrelationId(req));
  }

  @Get('orders')
  @UseGuards(AuthGuard)
  async getRecentOrders(
    @Req() req: Request,
    @Query() query: ListOrdersQueryDto,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.billingService.listRecentOrders(
      userId,
      query.limit ?? 5,
    );
    return successResponse(data, getCorrelationId(req));
  }

  @Get('orders/:orderId/status')
  @UseGuards(AuthGuard)
  async getOrderStatus(
    @Req() req: Request,
    @Param('orderId') orderId: string,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.billingService.getOrderStatus(userId, orderId);
    return successResponse(data, getCorrelationId(req));
  }

  @Post('orders')
  @UseGuards(AuthGuard)
  async createOrder(
    @Req() req: Request,
    @Body() dto: CreateOrderDto,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.billingService.createOrder(
      userId,
      dto.creditPackId,
      dto.promoCode,
      getCorrelationId(req),
      dto.idempotencyKey,
    );
    return successResponse(data, getCorrelationId(req));
  }

  @Post('promo/validate')
  @UseGuards(AuthGuard)
  async validatePromo(
    @Req() req: Request,
    @Body() dto: PromoValidationDto,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.billingService.validatePromoCode(
      userId,
      dto.promoCode,
      dto.productType,
      dto.productId,
    );
    return successResponse(data, getCorrelationId(req));
  }

  @Get('admin/promos')
  @UseGuards(AuthGuard, SuperadminGuard)
  async listPromoCodes(@Req() req: Request): Promise<object> {
    const data = await this.billingService.listPromoCodes();
    return successResponse(
      {
        state: 'success',
        promos: data,
      },
      getCorrelationId(req),
    );
  }

  @Post('admin/promos')
  @UseGuards(AuthGuard, SuperadminGuard)
  async createPromoCode(
    @Req() req: Request,
    @Body() dto: AdminCreatePromoCodeDto,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.billingService.createPromoCode({
      actorUserId,
      dto,
      correlationId: getCorrelationId(req),
    });
    return successResponse(data, getCorrelationId(req));
  }

  @Post('admin/promos/:promoCodeId/deactivate')
  @UseGuards(AuthGuard, SuperadminGuard)
  async deactivatePromoCode(
    @Req() req: Request,
    @Param('promoCodeId') promoCodeId: string,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.billingService.deactivatePromoCode({
      actorUserId,
      promoCodeId,
      correlationId: getCorrelationId(req),
    });
    return successResponse(data, getCorrelationId(req));
  }

  @Post('admin/promos/:promoCodeId/reactivate')
  @UseGuards(AuthGuard, SuperadminGuard)
  async reactivatePromoCode(
    @Req() req: Request,
    @Param('promoCodeId') promoCodeId: string,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.billingService.reactivatePromoCode({
      actorUserId,
      promoCodeId,
      correlationId: getCorrelationId(req),
    });
    return successResponse(data, getCorrelationId(req));
  }

  @Put('admin/promos/:promoCodeId')
  @UseGuards(AuthGuard, SuperadminGuard)
  async updatePromoCode(
    @Req() req: Request,
    @Param('promoCodeId') promoCodeId: string,
    @Body() dto: AdminUpdatePromoCodeDto,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.billingService.updatePromoCode({
      actorUserId,
      promoCodeId,
      dto,
      correlationId: getCorrelationId(req),
    });
    return successResponse(data, getCorrelationId(req));
  }

  @Get('admin/promo-analytics')
  @UseGuards(AuthGuard, SuperadminGuard)
  async getPromoAnalytics(
    @Req() req: Request,
    @Query() query: AdminPromoAnalyticsQueryDto,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.billingService.getPromoAnalytics({
      actorUserId,
      query,
      correlationId: getCorrelationId(req),
    });
    return successResponse(data, getCorrelationId(req));
  }

  @Post('admin/promo-analytics/export')
  @UseGuards(AuthGuard, SuperadminGuard)
  async exportPromoAnalytics(
    @Req() req: Request,
    @Body() dto: AdminPromoAnalyticsExportDto,
  ): Promise<object> {
    const { id: actorUserId } = req.user as RequestUser;
    const data = await this.billingService.exportPromoAnalytics({
      actorUserId,
      dto,
      correlationId: getCorrelationId(req),
    });
    return successResponse(data, getCorrelationId(req));
  }

  @Post('orders/verify')
  @UseGuards(AuthGuard)
  async verifyPayment(
    @Req() req: Request,
    @Body() dto: VerifyPaymentDto,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.billingService.verifyPayment(
      userId,
      dto.razorpayOrderId,
      dto.razorpayPaymentId,
      dto.razorpaySignature,
    );
    return successResponse(data, getCorrelationId(req));
  }

  @Post('orders/:orderId/client-confirmation')
  @UseGuards(AuthGuard)
  async confirmClientPurchase(
    @Req() req: Request,
    @Param('orderId') orderId: string,
    @Body() dto: ConfirmClientPurchaseDto,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.billingService.confirmClientPurchase(
      userId,
      orderId,
      dto,
    );
    return successResponse(data, getCorrelationId(req));
  }

  @Get('plans')
  @UseGuards(AuthGuard)
  async getPlans(@Req() req: Request): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.billingService.listPlans(userId);
    return successResponse(data, getCorrelationId(req));
  }

  @Post('subscriptions')
  @UseGuards(AuthGuard)
  async createSubscription(
    @Req() req: Request,
    @Body() dto: CreateSubscriptionDto,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.billingService.createSubscription(
      userId,
      dto.planId,
      dto.promoCode,
    );
    return successResponse(data, getCorrelationId(req));
  }

  @Post('subscriptions/verify')
  @UseGuards(AuthGuard)
  async verifySubscription(
    @Req() req: Request,
    @Body() dto: VerifySubscriptionDto,
  ): Promise<object> {
    const { id: userId } = req.user as RequestUser;
    const data = await this.billingService.verifySubscription(
      userId,
      dto.razorpaySubscriptionId,
      dto.razorpayPaymentId,
      dto.razorpaySignature,
      getCorrelationId(req),
    );
    return successResponse(data, getCorrelationId(req));
  }

  @Post('webhook/razorpay')
  async handleRazorpayWebhook(@Req() req: Request): Promise<object> {
    const signature = this.firstHeader(req.headers['x-razorpay-signature']);
    const providerEventId = this.firstHeader(
      req.headers['x-razorpay-event-id'],
    );
    const rawBody =
      typeof (req as { rawBody?: Buffer }).rawBody !== 'undefined'
        ? (req as { rawBody?: Buffer }).rawBody!.toString()
        : JSON.stringify(req.body);
    const payload = req.body as RazorpayWebhookPayload;
    const event = payload.event ?? 'unknown';
    const webhookContext = this.billingService.buildRazorpayWebhookContext({
      providerEventId,
      rawBody,
      eventType: event,
      correlationId: getCorrelationId(req),
    });

    if (
      !signature ||
      !this.razorpayService.verifyWebhookSignature(rawBody, signature)
    ) {
      await this.billingService.recordInvalidWebhookSignature({
        context: webhookContext,
      });
      throw new BadRequestException({
        code: BILLING_WEBHOOK_INVALID_SIGNATURE,
        message: 'Invalid webhook signature',
      });
    }

    this.logger.log(`Webhook event received: ${event}`);

    if (event === 'payment.captured') {
      const payment = payload.payload?.payment?.entity;
      const razorpayOrderId = payment?.order_id ?? '';
      const razorpayPaymentId = payment?.id ?? '';
      await this.billingService.handleWebhookPaymentCaptured({
        ...webhookContext,
        razorpayOrderId,
        razorpayPaymentId,
        amount: typeof payment?.amount === 'number' ? payment.amount : null,
        currency:
          typeof payment?.currency === 'string' ? payment.currency : null,
      });
    } else if (event === 'payment.failed') {
      const payment = payload.payload?.payment?.entity;
      const razorpayOrderId = payment?.order_id ?? '';
      const reason = this.extractPaymentFailureReason(payment ?? {});
      await this.billingService.handleWebhookPaymentFailed({
        ...webhookContext,
        razorpayOrderId,
        razorpayPaymentId: payment?.id ?? null,
        reason,
      });
    } else if (event === 'subscription.activated') {
      const subId = payload.payload?.subscription?.entity?.id ?? '';
      const paymentId = payload.payload?.payment?.entity?.id ?? '';
      await this.billingService.handleWebhookSubscriptionActivated(
        subId,
        paymentId,
        getCorrelationId(req),
      );
    } else if (event === 'subscription.halted') {
      const subId = payload.payload?.subscription?.entity?.id ?? '';
      await this.billingService.handleWebhookSubscriptionHalted(subId);
    } else if (event === 'subscription.cancelled') {
      const subId = payload.payload?.subscription?.entity?.id ?? '';
      await this.billingService.handleWebhookSubscriptionCancelled(
        subId,
        getCorrelationId(req),
      );
    }

    return { status: 'ok' };
  }

  @Post('webhook/revenuecat')
  async handleRevenueCatWebhook(@Req() req: Request): Promise<object> {
    const authorization = this.firstHeader(req.headers.authorization);
    const rawBody =
      typeof (req as { rawBody?: Buffer }).rawBody !== 'undefined'
        ? (req as { rawBody?: Buffer }).rawBody!.toString()
        : JSON.stringify(req.body);
    const payload = req.body as RevenueCatWebhookPayload;
    const event = payload.event ?? {};
    const eventType = event.type ?? 'unknown';
    const webhookContext = this.billingService.buildRevenueCatWebhookContext({
      providerEventId: event.id ?? null,
      rawBody,
      eventType,
      correlationId: getCorrelationId(req),
    });

    if (!this.revenueCatService.verifyWebhookAuthorization(authorization)) {
      await this.billingService.recordInvalidRevenueCatWebhookAuthorization({
        context: webhookContext,
      });
      throw new BadRequestException({
        code: BILLING_WEBHOOK_INVALID_AUTHORIZATION,
        message: 'Invalid RevenueCat webhook authorization',
      });
    }

    this.logger.log(`RevenueCat webhook event received: ${eventType}`);

    if (this.isRevenueCatSuccessfulPurchase(eventType)) {
      await this.billingService.handleRevenueCatPurchaseReconciled({
        ...webhookContext,
        orderId: this.extractRevenueCatOrderId(event),
        transactionId: event.transaction_id ?? null,
        appUserId: event.app_user_id ?? null,
        productId: event.product_id ?? null,
        amount: this.revenueCatAmountInSmallestUnit(event),
        currency: event.currency ?? null,
      });
    } else if (this.isRevenueCatFailedPurchase(eventType)) {
      await this.billingService.handleRevenueCatPurchaseFailed({
        ...webhookContext,
        orderId: this.extractRevenueCatOrderId(event),
        transactionId: event.transaction_id ?? null,
        appUserId: event.app_user_id ?? null,
        productId: event.product_id ?? null,
        reason: this.extractRevenueCatFailureReason(event),
      });
    } else {
      await this.billingService.recordIgnoredRevenueCatWebhook({
        ...webhookContext,
        transactionId: event.transaction_id ?? null,
        appUserId: event.app_user_id ?? null,
        productId: event.product_id ?? null,
      });
    }

    return { status: 'ok' };
  }

  private extractPaymentFailureReason(
    payment: Record<string, unknown>,
  ): string | undefined {
    const candidates = [
      payment['error_description'],
      payment['error_reason'],
      payment['error_source'],
      payment['error_step'],
      payment['error_code'],
    ];

    for (const candidate of candidates) {
      if (typeof candidate === 'string' && candidate.trim().length > 0) {
        return candidate.trim();
      }
    }

    return undefined;
  }

  private firstHeader(value: string | string[] | undefined): string | null {
    if (Array.isArray(value)) {
      return value[0] ?? null;
    }

    return value ?? null;
  }

  private isRevenueCatSuccessfulPurchase(eventType: string): boolean {
    return eventType === 'NON_RENEWING_PURCHASE';
  }

  private isRevenueCatFailedPurchase(eventType: string): boolean {
    return (
      eventType === 'CANCELLATION' ||
      eventType === 'EXPIRATION' ||
      eventType === 'BILLING_ISSUE'
    );
  }

  private extractRevenueCatOrderId(
    event: RevenueCatWebhookEvent,
  ): string | null {
    const attrs = event.subscriber_attributes ?? {};
    const candidates = [
      attrs['doclyzer_order_id'],
      attrs['order_id'],
      attrs['$doclyzerOrderId'],
    ];

    for (const candidate of candidates) {
      const value =
        typeof candidate === 'string' ? candidate : candidate?.value;
      if (typeof value === 'string' && value.trim().length > 0) {
        return value.trim();
      }
    }

    return null;
  }

  private revenueCatAmountInSmallestUnit(
    event: RevenueCatWebhookEvent,
  ): number | null {
    const amount =
      typeof event.price_in_purchased_currency === 'number'
        ? event.price_in_purchased_currency
        : event.price;
    if (typeof amount !== 'number' || !Number.isFinite(amount)) {
      return null;
    }

    return Math.round(amount * 100);
  }

  private extractRevenueCatFailureReason(
    event: RevenueCatWebhookEvent,
  ): string | undefined {
    const candidates = [
      event.cancel_reason,
      event.expiration_reason,
      event.type,
    ];

    for (const candidate of candidates) {
      if (typeof candidate === 'string' && candidate.trim().length > 0) {
        return candidate.trim();
      }
    }

    return undefined;
  }
}
