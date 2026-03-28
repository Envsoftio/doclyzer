import {
  IsIn,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
} from 'class-validator';

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
  entitlementSummary: object;
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
