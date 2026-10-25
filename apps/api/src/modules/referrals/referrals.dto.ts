import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsISO8601,
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class ApplyReferralCodeDto {
  @IsString()
  @IsNotEmpty({ message: 'Referral code is required' })
  @MaxLength(32, { message: 'Referral code must be 32 characters or fewer' })
  referralCode!: string;
}

export class ReferralPolicyTierDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(64)
  label!: string;

  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  @Max(99999999)
  thresholdAmount!: number;

  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  @Max(99999999)
  rewardCredits!: number;
}

export class UpdateReferralPolicyDto {
  @IsOptional()
  @IsISO8601()
  expectedUpdatedAt?: string | null;

  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  @Max(99999999)
  inviteeBonusCredits!: number;

  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  @Max(99999999)
  milestoneACredits!: number;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(10)
  @ValidateNested({ each: true })
  @Type(() => ReferralPolicyTierDto)
  milestoneBTiers!: ReferralPolicyTierDto[];

  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0)
  @Max(99999999)
  monthlyRewardCap!: number;

  @IsBoolean()
  zeroAmountOrderEligible!: boolean;
}
