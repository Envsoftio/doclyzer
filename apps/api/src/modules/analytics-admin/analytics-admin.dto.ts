import { IsInt, IsISO8601, IsOptional, IsString, Max, Min } from 'class-validator';
import { Type } from 'class-transformer';

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

export class UserDirectoryQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(200)
  limit?: number;

  @IsOptional()
  @IsString()
  sortBy?: 'createdAt' | 'email' | 'reportCount';

  @IsOptional()
  @IsString()
  sortDir?: 'ASC' | 'DESC';

  @IsOptional()
  @IsString()
  search?: string;
}
