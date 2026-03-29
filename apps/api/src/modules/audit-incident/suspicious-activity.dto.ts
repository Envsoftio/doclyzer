import { Type } from 'class-transformer';
import {
  IsIn,
  IsInt,
  IsISO8601,
  IsObject,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import {
  SUSPICIOUS_ACTIVITY_CONTAINMENT_ACTIONS,
  SUSPICIOUS_ACTIVITY_SEVERITIES,
  SUSPICIOUS_ACTIVITY_STATUSES,
} from './suspicious-activity.types';
import type {
  SuspiciousActivityContainmentAction,
  SuspiciousActivitySeverity,
  SuspiciousActivityStatus,
} from './suspicious-activity.types';

export class SuspiciousActivityContainmentSuggestionDto {
  @IsIn(SUSPICIOUS_ACTIVITY_CONTAINMENT_ACTIONS)
  action!: SuspiciousActivityContainmentAction;

  @IsOptional()
  @IsString()
  @MaxLength(256)
  reason?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  @Max(100)
  confidenceScore?: number;
}

export class SuspiciousActivityIngestDto {
  @IsString()
  targetType!: string;

  @IsString()
  targetId!: string;

  @IsString()
  signalType!: string;

  @IsString()
  ruleCode!: string;

  @IsIn(SUSPICIOUS_ACTIVITY_SEVERITIES)
  severity!: SuspiciousActivitySeverity;

  @Type(() => Number)
  @IsInt()
  @Min(0)
  @Max(100)
  confidenceScore!: number;

  @IsOptional()
  @IsString()
  @MaxLength(256)
  detectionSummary?: string;

  @IsOptional()
  @IsObject()
  metadata?: Record<string, string | number | boolean | null>;

  @IsOptional()
  @IsString()
  @MaxLength(128)
  idempotencyKey?: string;

  @IsOptional()
  @IsISO8601()
  detectedAt?: string;

  @IsOptional()
  @ValidateNested()
  @Type(() => SuspiciousActivityContainmentSuggestionDto)
  suggestedContainment?: SuspiciousActivityContainmentSuggestionDto;
}

export class SuspiciousActivityStatusUpdateDto {
  @IsIn(SUSPICIOUS_ACTIVITY_STATUSES)
  status!: SuspiciousActivityStatus;

  @IsOptional()
  @IsString()
  @MaxLength(256)
  notes?: string;
}

export class SuspiciousActivityQueueQueryDto {
  @IsOptional()
  @IsIn(SUSPICIOUS_ACTIVITY_STATUSES)
  status?: SuspiciousActivityStatus;

  @IsOptional()
  @IsIn(SUSPICIOUS_ACTIVITY_SEVERITIES)
  severity?: SuspiciousActivitySeverity;

  @IsOptional()
  @IsString()
  targetType?: string;

  @IsOptional()
  @IsString()
  targetId?: string;

  @IsOptional()
  @IsString()
  ruleCode?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  @Max(100)
  minConfidence?: number;

  @IsOptional()
  @IsISO8601()
  minDetectedAt?: string;

  @IsOptional()
  @IsISO8601()
  maxDetectedAt?: string;

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
  limit?: number;
}
