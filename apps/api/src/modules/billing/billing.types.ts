import {
  IsIn,
  IsNotEmpty,
  IsOptional,
  IsInt,
  Max,
  Min,
  IsString,
  IsUUID,
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
