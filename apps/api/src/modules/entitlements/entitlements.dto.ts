import { IsBoolean, IsInt, IsOptional, Min } from 'class-validator';

export class UpdatePlanConfigDto {
  @IsInt()
  @Min(1, {
    message: 'maxProfilesPerPlan must be at least 1',
  })
  maxProfilesPerPlan!: number;

  @IsInt()
  @Min(1, {
    message: 'reportCap must be at least 1',
  })
  reportCap!: number;

  @IsInt()
  @Min(0, {
    message: 'shareLinkLimit must be zero or greater',
  })
  shareLinkLimit!: number;

  @IsBoolean()
  aiChatEnabled!: boolean;

  @IsOptional()
  @IsInt()
  @Min(1, {
    message: 'expectedConfigVersion must be at least 1 when provided',
  })
  expectedConfigVersion?: number;
}
