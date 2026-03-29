import { IsISO8601, IsOptional } from 'class-validator';

export class CoreProductAnalyticsQueryDto {
  @IsISO8601()
  startDate!: string;

  @IsISO8601()
  endDate!: string;

  @IsOptional()
  @IsISO8601()
  baselineStartDate?: string;

  @IsOptional()
  @IsISO8601()
  baselineEndDate?: string;
}
