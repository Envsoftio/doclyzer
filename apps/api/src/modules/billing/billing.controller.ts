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
  AdminCreatePromoCodeDto,
  AdminUpdatePromoCodeDto,
  CreateOrderDto,
  CreateSubscriptionDto,
  ListOrdersQueryDto,
  PromoValidationDto,
  VerifyPaymentDto,
  VerifySubscriptionDto,
  BILLING_WEBHOOK_INVALID_SIGNATURE,
} from './billing.types';

@Controller('billing')
export class BillingController {
  private readonly logger = new Logger(BillingController.name);

  constructor(
    private readonly billingService: BillingService,
    private readonly razorpayService: RazorpayService,
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
    );
    return successResponse(data, getCorrelationId(req));
  }

  @Post('webhook/razorpay')
  async handleRazorpayWebhook(@Req() req: Request): Promise<object> {
    const signature = req.headers['x-razorpay-signature'] as string;
    const rawBody =
      typeof (req as { rawBody?: Buffer }).rawBody !== 'undefined'
        ? (req as { rawBody?: Buffer }).rawBody!.toString()
        : JSON.stringify(req.body);

    if (
      !signature ||
      !this.razorpayService.verifyWebhookSignature(rawBody, signature)
    ) {
      throw new BadRequestException({
        code: BILLING_WEBHOOK_INVALID_SIGNATURE,
        message: 'Invalid webhook signature',
      });
    }

    const payload = req.body as {
      event: string;
      payload: {
        payment?: {
          entity?: { order_id?: string; id?: string };
        };
        order?: {
          entity?: { id?: string };
        };
        subscription?: {
          entity?: { id?: string };
        };
      };
    };

    const event = payload.event;
    this.logger.log(`Webhook event received: ${event}`);

    if (event === 'payment.captured') {
      const razorpayOrderId = payload.payload.payment?.entity?.order_id ?? '';
      const razorpayPaymentId = payload.payload.payment?.entity?.id ?? '';
      await this.billingService.handleWebhookPaymentCaptured(
        razorpayOrderId,
        razorpayPaymentId,
      );
    } else if (event === 'payment.failed') {
      const razorpayOrderId = payload.payload.payment?.entity?.order_id ?? '';
      const reason = this.extractPaymentFailureReason(
        payload.payload.payment?.entity ?? {},
      );
      await this.billingService.handleWebhookPaymentFailed(
        razorpayOrderId,
        reason,
      );
    } else if (event === 'subscription.activated') {
      const subId = payload.payload.subscription?.entity?.id ?? '';
      const paymentId = payload.payload.payment?.entity?.id ?? '';
      await this.billingService.handleWebhookSubscriptionActivated(
        subId,
        paymentId,
      );
    } else if (event === 'subscription.halted') {
      const subId = payload.payload.subscription?.entity?.id ?? '';
      await this.billingService.handleWebhookSubscriptionHalted(subId);
    } else if (event === 'subscription.cancelled') {
      const subId = payload.payload.subscription?.entity?.id ?? '';
      await this.billingService.handleWebhookSubscriptionCancelled(subId);
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
}
