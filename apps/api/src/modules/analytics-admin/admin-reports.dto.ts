import { Type } from 'class-transformer';
import {
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

export const ADMIN_REPORT_STATUSES = [
  'uploading',
  'queued',
  'parsing',
  'parsed',
  'unparsed',
  'content_not_recognized',
  'failed_transient',
  'failed_terminal',
] as const;

export class AdminReportsQueryDto {
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

  @IsOptional()
  @IsString()
  @MaxLength(100)
  search?: string;

  @IsOptional()
  @IsUUID()
  userId?: string;

  @IsOptional()
  @IsIn(ADMIN_REPORT_STATUSES)
  status?: (typeof ADMIN_REPORT_STATUSES)[number];
}
