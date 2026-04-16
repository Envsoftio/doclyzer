import {
  IsIn,
  IsInt,
  IsISO8601,
  IsNotEmpty,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CoreProductAnalyticsQueryDto {
  @IsNotEmpty()
  @IsISO8601()
  startDate!: string;

  @IsNotEmpty()
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

export class SystemDashboardQueryDto {
  @IsNotEmpty()
  @IsISO8601()
  startDate!: string;

  @IsNotEmpty()
  @IsISO8601()
  endDate!: string;

  @IsOptional()
  @IsString()
  geography?: string;

  @IsOptional()
  @IsIn(['all', 'free', 'paid'])
  productSlice?: 'all' | 'free' | 'paid';
}

export class SystemDashboardExportDto extends SystemDashboardQueryDto {
  @IsIn(['json', 'csv'])
  format!: 'json' | 'csv';
}
