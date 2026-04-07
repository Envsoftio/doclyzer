import { Type } from 'class-transformer';
import {
  IsBoolean,
  ArrayNotEmpty,
  IsArray,
  IsDateString,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';
import type { AnalyticsFieldClassification } from './analytics-governance.types';

export class AnalyticsGovernanceFieldDto {
  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsIn(['non_phi', 'pii', 'phi'])
  classification!: AnalyticsFieldClassification;
}

export class AnalyticsGovernanceValidationDto {
  @IsString()
  @IsNotEmpty()
  eventName!: string;

  @IsArray()
  @ArrayNotEmpty()
  @ValidateNested({ each: true })
  @Type(() => AnalyticsGovernanceFieldDto)
  fields!: AnalyticsGovernanceFieldDto[];

  @IsOptional()
  @IsString()
  changeSummary?: string;
}

export class GovernanceRecordsQueryDto {
  @IsDateString()
  windowStart!: string;

  @IsDateString()
  windowEnd!: string;

  @IsOptional()
  @IsIn(['access', 'share', 'consent', 'policy', 'all'])
  recordType?: 'access' | 'share' | 'consent' | 'policy' | 'all';

  @IsOptional()
  @IsUUID()
  userId?: string;

  @IsOptional()
  @IsUUID()
  profileId?: string;

  @IsOptional()
  @IsUUID()
  shareLinkId?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;

  @IsOptional()
  @IsString()
  cursor?: string;
}

export class GovernanceRecordsExportDto extends GovernanceRecordsQueryDto {
  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  includeAuditMetadata?: boolean;
}
