import {
  IsDateString,
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';

export const GIFT_VOUCHER_CODE_REQUIRED = 'GIFT_VOUCHER_CODE_REQUIRED';
export const GIFT_VOUCHER_INVALID = 'GIFT_VOUCHER_INVALID';
export const GIFT_VOUCHER_ALREADY_REDEEMED = 'GIFT_VOUCHER_ALREADY_REDEEMED';
export const GIFT_VOUCHER_VOIDED = 'GIFT_VOUCHER_VOIDED';
export const GIFT_VOUCHER_EXPIRED = 'GIFT_VOUCHER_EXPIRED';
export const GIFT_VOUCHER_NOT_ACTIVE = 'GIFT_VOUCHER_NOT_ACTIVE';
export const GIFT_VOUCHER_NOT_FOUND = 'GIFT_VOUCHER_NOT_FOUND';
export const GIFT_VOUCHER_CREDIT_AMOUNT_INVALID =
  'GIFT_VOUCHER_CREDIT_AMOUNT_INVALID';

export class RedeemGiftVoucherDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  code!: string;
}

export class AdminGenerateGiftVoucherDto {
  @Type(() => Number)
  @IsNumber()
  @Min(0.01)
  creditAmount!: number;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  @IsOptional()
  count?: number;

  @IsDateString()
  @IsOptional()
  expiresAt?: string;
}

export class AdminVoidGiftVoucherDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(240)
  reason!: string;
}

export interface GiftVoucherAdminDto {
  id: string;
  codeMask: string;
  creditAmount: number;
  status: 'active' | 'redeemed' | 'voided' | 'expired';
  expiresAt: string | null;
  redeemedByUserId: string | null;
  redeemedAt: string | null;
  voidedByUserId: string | null;
  voidedAt: string | null;
  voidReason: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface GeneratedGiftVoucherDto extends GiftVoucherAdminDto {
  code: string;
}

export interface AdminGenerateGiftVoucherResponseDto {
  state: 'success';
  vouchers: GeneratedGiftVoucherDto[];
}

export interface RedeemGiftVoucherResponseDto {
  state: 'success';
  voucherId: string;
  codeMask: string;
  creditsAdded: number;
  entitlementSummary: object;
}
