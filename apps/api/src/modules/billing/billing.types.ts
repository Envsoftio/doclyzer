import {
  IsBoolean,
  IsDateString,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsNumber,
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
export const BILLING_WEBHOOK_INVALID_AUTHORIZATION =
  'BILLING_WEBHOOK_INVALID_AUTHORIZATION';
export const BILLING_RECONCILIATION_AMOUNT_MISMATCH =
  'BILLING_RECONCILIATION_AMOUNT_MISMATCH';
export const BILLING_RECONCILIATION_CURRENCY_MISMATCH =
  'BILLING_RECONCILIATION_CURRENCY_MISMATCH';
export const BILLING_RECONCILIATION_PAYLOAD_INCOMPLETE =
  'BILLING_RECONCILIATION_PAYLOAD_INCOMPLETE';
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
export const BILLING_MANUAL_ADJUSTMENT_NEGATIVE_BALANCE =
  'BILLING_MANUAL_ADJUSTMENT_NEGATIVE_BALANCE';

export type PromoProductType = 'credit_pack' | 'subscription';

export type OrderStatus =
  | 'created'
  | 'payment_pending'
  | 'client_purchase_confirmed'
  | 'signature_verified'
  | 'webhook_pending'
  | 'reconciled'
  | 'failed'
  | 'pending_review';

export class CreateOrderDto {
  @IsUUID()
  @IsNotEmpty()
  creditPackId!: string;

  @IsString()
  @IsOptional()
  promoCode?: string;

  @IsString()
  @MaxLength(128)
  @IsOptional()
  idempotencyKey?: string;
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

export class ConfirmClientPurchaseDto {
  @IsString()
  @IsOptional()
  revenueCatTransactionId?: string;

  @IsString()
  @IsOptional()
  revenueCatProductId?: string;

  @IsString()
  @IsOptional()
  revenueCatAppUserId?: string;
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
  razorpayOrderId: string | null;
  amount: number;
  currency: string;
  razorpayKeyId: string | null;
  paymentRequired: boolean;
  checkoutProvider: 'razorpay' | 'internal';
  orderStatus: OrderStatus;
  entitlementSummary?: object;
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

export class AdminBillingOrdersQueryDto {
  @IsOptional()
  @IsString()
  @MaxLength(120)
  search?: string;

  @IsOptional()
  @IsIn([
    'created',
    'payment_pending',
    'client_purchase_confirmed',
    'signature_verified',
    'webhook_pending',
    'reconciled',
    'failed',
    'pending_review',
  ])
  status?: OrderStatus;

  @IsOptional()
  @IsIn(['all', 'needs_review', 'clear'])
  reviewState?: 'all' | 'needs_review' | 'clear';

  @IsOptional()
  @IsDateString()
  dateFrom?: string;

  @IsOptional()
  @IsDateString()
  dateTo?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  pageSize?: number;
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

export interface AdminBillingOrderRowDto {
  id: string;
  userId: string;
  userEmail: string;
  userDisplayName: string | null;
  creditPackId: string;
  creditPackName: string;
  credits: number;
  amount: number;
  finalAmount: number;
  currency: string;
  status: OrderStatus;
  statusLabel: string;
  credited: boolean;
  provider: 'revenuecat' | 'razorpay' | 'internal';
  checkoutProvider: 'revenuecat' | 'razorpay' | 'internal';
  orderReference: string;
  paymentReference: string | null;
  failureReason: string | null;
  reviewReason: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface AdminBillingOrdersResponseDto {
  state: 'success';
  filters: {
    search: string | null;
    status: OrderStatus | 'all';
    reviewState: 'all' | 'needs_review' | 'clear';
    dateFrom: string | null;
    dateTo: string | null;
  };
  pagination: {
    page: number;
    pageSize: number;
    totalItems: number;
    totalPages: number;
  };
  items: AdminBillingOrderRowDto[];
}

export class AdminManualCreditAdjustmentDto {
  @IsUUID()
  @IsNotEmpty()
  userId!: string;

  @Type(() => Number)
  @IsNumber()
  adjustment!: number;

  @IsString()
  @IsNotEmpty()
  @MaxLength(240)
  reason!: string;
}

export interface AdminManualCreditAdjustmentResponseDto {
  state: 'success';
  adjustment: {
    userId: string;
    delta: number;
    newCreditBalance: number;
    reason: string;
    performedAt: string;
  };
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
  valid: boolean;
  originalAmount: number;
  discountAmount: number;
  finalAmount: number;
  currency: string;
  promoCodeId: string | null;
  promoLabel: string | null;
  promoDescription: string | null;
  invalidReason: PromoInvalidReasonDto | null;
}

export interface PromoInvalidReasonDto {
  code: string;
  message: string;
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

  @Type(() => Number)
  @IsPositive()
  @IsOptional()
  maxDiscountAmount?: number;

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

  @Type(() => Number)
  @IsPositive()
  @IsOptional()
  maxDiscountAmount?: number | null;

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
  maxDiscountAmount: number | null;
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
  validationCount: number;
  reservationCount: number;
  redeemedCount: number;
  failedCount: number;
  voidedCount: number;
  reconciledCheckoutCount: number;
  failedCheckoutCount: number;
  attributedDiscountTotal: number;
  finalizedRevenueTotal: number;
}

export interface PromoAnalyticsSummaryDto {
  totalValidationCount: number;
  totalReservationCount: number;
  totalRedeemedCount: number;
  totalFailedCount: number;
  totalVoidedCount: number;
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
  reviewReason: string | null;
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
    reviewReason: orderReviewReason(order.metadata),
  };
}

function normalizeOrderStatus(status: string): OrderStatus {
  if (
    status === 'created' ||
    status === 'payment_pending' ||
    status === 'client_purchase_confirmed' ||
    status === 'webhook_pending' ||
    status === 'reconciled' ||
    status === 'failed' ||
    status === 'pending_review'
  ) {
    return status;
  }

  if (status === 'pending') {
    return 'payment_pending';
  }

  if (status === 'paid') {
    return 'client_purchase_confirmed';
  }

  if (status === 'signature_verified') {
    return 'client_purchase_confirmed';
  }

  return 'payment_pending';
}

function orderStatusLabel(status: OrderStatus): string {
  switch (status) {
    case 'created':
      return 'Order created';
    case 'payment_pending':
      return 'Pending payment';
    case 'client_purchase_confirmed':
      return 'Purchase confirmed - awaiting payment webhook';
    case 'signature_verified':
      return 'Purchase confirmed - awaiting payment webhook';
    case 'webhook_pending':
      return 'Payment webhook received - reconciling';
    case 'reconciled':
      return 'Reconciled';
    case 'failed':
      return 'Payment failed';
    case 'pending_review':
      return 'Pending review';
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

function orderReviewReason(
  metadata: Record<string, unknown> | null,
): string | null {
  if (!metadata) {
    return null;
  }

  const reason = metadata['reviewReason'];
  return typeof reason === 'string' && reason.trim().length > 0
    ? reason.trim()
    : null;
}
