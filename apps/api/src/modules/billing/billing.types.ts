import {
  IsBoolean,
  IsDateString,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsPositive,
  IsUUID,
  MaxLength,
  Min,
  IsString,
  Max,
} from 'class-validator';
import { Type } from 'class-transformer';
import type { OrderEntity } from '../../database/entities/order.entity';

export const BILLING_PACK_NOT_FOUND = 'BILLING_PACK_NOT_FOUND';
export const BILLING_PACK_INACTIVE = 'BILLING_PACK_INACTIVE';
export const BILLING_ORDER_NOT_FOUND = 'BILLING_ORDER_NOT_FOUND';
export const BILLING_INVALID_SIGNATURE = 'BILLING_INVALID_SIGNATURE';
export const BILLING_ORDER_ALREADY_PROCESSED =
  'BILLING_ORDER_ALREADY_PROCESSED';
export const BILLING_WEBHOOK_INVALID_SIGNATURE =
  'BILLING_WEBHOOK_INVALID_SIGNATURE';
export const BILLING_PLAN_NOT_FOUND = 'BILLING_PLAN_NOT_FOUND';
export const BILLING_PLAN_INACTIVE = 'BILLING_PLAN_INACTIVE';
export const BILLING_ALREADY_SUBSCRIBED = 'BILLING_ALREADY_SUBSCRIBED';
export const BILLING_SUBSCRIPTION_NOT_FOUND = 'BILLING_SUBSCRIPTION_NOT_FOUND';
export const BILLING_SUBSCRIPTION_INVALID_SIGNATURE =
  'BILLING_SUBSCRIPTION_INVALID_SIGNATURE';
export const BILLING_PROMO_NOT_FOUND = 'BILLING_PROMO_NOT_FOUND';
export const BILLING_PROMO_INACTIVE = 'BILLING_PROMO_INACTIVE';
export const BILLING_PROMO_EXPIRED = 'BILLING_PROMO_EXPIRED';
export const BILLING_PROMO_NOT_APPLICABLE = 'BILLING_PROMO_NOT_APPLICABLE';
export const BILLING_PROMO_CAP_REACHED = 'BILLING_PROMO_CAP_REACHED';
export const BILLING_PROMO_USER_CAP_REACHED = 'BILLING_PROMO_USER_CAP_REACHED';
export const BILLING_PROMO_CODE_DUPLICATE = 'BILLING_PROMO_CODE_DUPLICATE';
export const BILLING_PROMO_DATE_RANGE_INVALID =
  'BILLING_PROMO_DATE_RANGE_INVALID';
export const BILLING_ANALYTICS_DATE_RANGE_INVALID =
  'BILLING_ANALYTICS_DATE_RANGE_INVALID';

export type PromoProductType = 'credit_pack' | 'subscription';

export type OrderStatus = 'pending' | 'paid' | 'reconciled' | 'failed';

export class CreateOrderDto {
  @IsUUID()
  @IsNotEmpty()
  creditPackId!: string;

  @IsString()
  @IsOptional()
  promoCode?: string;
}

export class VerifyPaymentDto {
  @IsString()
  @IsNotEmpty()
  razorpayOrderId!: string;

  @IsString()
  @IsNotEmpty()
  razorpayPaymentId!: string;

  @IsString()
  @IsNotEmpty()
  razorpaySignature!: string;
}

export interface CreditPackResponseDto {
  id: string;
  name: string;
  credits: number;
  priceInr: number;
  priceUsd: number;
}

export interface CreateOrderResponseDto {
  orderId: string;
  razorpayOrderId: string;
  amount: number;
  currency: string;
  razorpayKeyId: string;
}

export interface VerifyPaymentResponseDto {
  creditsAdded: number;
  orderStatus: OrderStatus;
  entitlementSummary: object;
}

export class ListOrdersQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(5)
  limit?: number;
}

export class CreateSubscriptionDto {
  @IsUUID()
  @IsNotEmpty()
  planId!: string;

  @IsString()
  @IsOptional()
  promoCode?: string;
}

export class VerifySubscriptionDto {
  @IsString()
  @IsNotEmpty()
  razorpaySubscriptionId!: string;

  @IsString()
  @IsNotEmpty()
  razorpayPaymentId!: string;

  @IsString()
  @IsNotEmpty()
  razorpaySignature!: string;
}

export interface PlanResponseDto {
  id: string;
  name: string;
  tier: string;
  limits: object;
  priceInfo: Record<string, unknown> | null;
  isCurrentPlan: boolean;
}

export interface CreateSubscriptionResponseDto {
  subscriptionId: string;
  razorpaySubscriptionId: string;
  razorpayKeyId: string;
  planName: string;
}

export interface VerifySubscriptionResponseDto {
  planName: string;
  entitlementSummary: object;
}

export class PromoValidationDto {
  @IsString()
  @IsNotEmpty()
  promoCode!: string;

  @IsString()
  @IsIn(['credit_pack', 'subscription'])
  productType!: PromoProductType;

  @IsUUID()
  @IsNotEmpty()
  productId!: string;
}

export interface PromoValidationResponseDto {
  discountAmount: number;
  finalAmount: number;
  currency: string;
  promoCodeId: string;
}

export type PromoLifecycleState =
  | 'pending'
  | 'success'
  | 'failure'
  | 'reverted';

export class AdminCreatePromoCodeDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(64)
  code!: string;

  @IsIn(['percentage', 'fixed'])
  discountType!: 'percentage' | 'fixed';

  @Type(() => Number)
  @IsPositive()
  discountValue!: number;

  @IsIn(['credit_pack', 'subscription', 'both'])
  appliesTo!: 'credit_pack' | 'subscription' | 'both';

  @IsDateString()
  @IsOptional()
  validFrom?: string;

  @IsDateString()
  @IsOptional()
  validUntil?: string;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  @IsOptional()
  usageCapTotal?: number;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  @IsOptional()
  usageCapPerUser?: number;

  @Type(() => Boolean)
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}

export class AdminUpdatePromoCodeDto {
  @IsIn(['percentage', 'fixed'])
  @IsOptional()
  discountType?: 'percentage' | 'fixed';

  @Type(() => Number)
  @IsPositive()
  @IsOptional()
  discountValue?: number;

  @IsIn(['credit_pack', 'subscription', 'both'])
  @IsOptional()
  appliesTo?: 'credit_pack' | 'subscription' | 'both';

  @IsDateString()
  @IsOptional()
  validFrom?: string;

  @IsDateString()
  @IsOptional()
  validUntil?: string;

  @IsInt()
  @Min(1)
  @IsOptional()
  usageCapTotal?: number | null;

  @IsInt()
  @Min(1)
  @IsOptional()
  usageCapPerUser?: number | null;

  @Type(() => Boolean)
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}

export interface PromoCodeAdminDto {
  id: string;
  code: string;
  discountType: 'percentage' | 'fixed';
  discountValue: number;
  appliesTo: 'credit_pack' | 'subscription' | 'both';
  validFrom: string | null;
  validUntil: string | null;
  usageCapTotal: number | null;
  usageCapPerUser: number | null;
  isActive: boolean;
  redemptions: {
    reserved: number;
    redeemed: number;
    void: number;
  };
  updatedAt: string;
}

export interface PromoLifecycleResponseDto {
  state: PromoLifecycleState;
  promo: PromoCodeAdminDto;
}

export class AdminPromoAnalyticsQueryDto {
  @IsUUID()
  @IsOptional()
  promoCodeId?: string;

  @IsDateString()
  @IsOptional()
  dateFrom?: string;

  @IsDateString()
  @IsOptional()
  dateTo?: string;

  @IsIn(['credit_pack', 'subscription', 'all'])
  @IsOptional()
  productType?: PromoProductType | 'all';

  @Type(() => Number)
  @IsInt()
  @Min(1)
  @IsOptional()
  page?: number;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  @IsOptional()
  pageSize?: number;
}

export class AdminPromoAnalyticsExportDto {
  @IsUUID()
  @IsOptional()
  promoCodeId?: string;

  @IsDateString()
  @IsOptional()
  dateFrom?: string;

  @IsDateString()
  @IsOptional()
  dateTo?: string;

  @IsIn(['credit_pack', 'subscription', 'all'])
  @IsOptional()
  productType?: PromoProductType | 'all';

  @IsIn(['csv', 'json'])
  @IsOptional()
  format?: 'csv' | 'json';
}

export interface PromoAnalyticsRowDto {
  promoCodeId: string;
  promoCode: string;
  reconciledCheckoutCount: number;
  failedCheckoutCount: number;
  attributedDiscountTotal: number;
  finalizedRevenueTotal: number;
}

export interface PromoAnalyticsSummaryDto {
  totalReconciledCheckouts: number;
  totalFailedCheckouts: number;
  totalAttributedDiscount: number;
  totalFinalizedRevenue: number;
}

export interface PromoAnalyticsResponseDto {
  state: 'success';
  filters: {
    promoCodeId: string | null;
    dateFrom: string;
    dateTo: string;
    productType: PromoProductType | 'all';
    policy: 'finalized_only';
  };
  pagination: {
    page: number;
    pageSize: number;
    totalItems: number;
    totalPages: number;
  };
  summary: PromoAnalyticsSummaryDto;
  rows: PromoAnalyticsRowDto[];
}

export interface PromoAnalyticsExportResponseDto {
  state: 'success';
  export: {
    format: 'csv' | 'json';
    generatedAt: string;
    filename: string;
    rowCount: number;
    payload: string | PromoAnalyticsRowDto[];
  };
}

export interface OrderStatusDto {
  id: string;
  status: OrderStatus;
  statusLabel: string;
  finalAmount: number;
  currency: string;
  credited: boolean;
  razorpayOrderId: string;
  updatedAt: string;
  failureReason: string | null;
}

export function toOrderStatusDto(order: OrderEntity): OrderStatusDto {
  const status = normalizeOrderStatus(order.status);

  return {
    id: order.id,
    status,
    statusLabel: orderStatusLabel(status),
    finalAmount: parseFloat(order.finalAmount ?? order.amount),
    currency: order.currency,
    credited: order.credited,
    razorpayOrderId: order.razorpayOrderId,
    updatedAt: order.updatedAt.toISOString(),
    failureReason: orderFailureReason(order.metadata),
  };
}

function normalizeOrderStatus(status: string): OrderStatus {
  if (
    status === 'pending' ||
    status === 'paid' ||
    status === 'reconciled' ||
    status === 'failed'
  ) {
    return status;
  }
  return 'pending';
}

function orderStatusLabel(status: OrderStatus): string {
  switch (status) {
    case 'pending':
      return 'Pending payment';
    case 'paid':
      return 'Payment pending - awaiting Razorpay capture';
    case 'reconciled':
      return 'Reconciled';
    case 'failed':
      return 'Payment failed';
  }
}

function orderFailureReason(
  metadata: Record<string, unknown> | null,
): string | null {
  if (!metadata) {
    return null;
  }

  const reason = metadata['reason'];
  return typeof reason === 'string' && reason.trim().length > 0
    ? reason.trim()
    : null;
}
