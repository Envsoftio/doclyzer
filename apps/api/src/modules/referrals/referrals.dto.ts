import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class ApplyReferralCodeDto {
  @IsString()
  @IsNotEmpty({ message: 'Referral code is required' })
  @MaxLength(32, { message: 'Referral code must be 32 characters or fewer' })
  referralCode!: string;
}
