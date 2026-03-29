import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsIn,
  IsInt,
  IsISO8601,
  IsObject,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';
import { AUDIT_ACTION_OUTCOMES } from './audit-incident.types';
import type { AuditActionOutcome, AuditMetadata } from './audit-incident.types';

export class AuditActionCreateDto {
  @IsString()
  action!: string;

  @IsString()
  target!: string;

  @IsIn(AUDIT_ACTION_OUTCOMES)
  outcome!: AuditActionOutcome;

  @IsOptional()
  @IsBoolean()
  sensitive?: boolean;

  @IsOptional()
  @IsObject()
  metadata?: AuditMetadata;

  @IsOptional()
  @IsString()
  reasonCode?: string;

  @IsOptional()
  @IsString()
  description?: string;
}

export class AuditActionQueryDto {
  @IsOptional()
  @IsString()
  actorUserId?: string;

  @IsOptional()
  @IsIn(AUDIT_ACTION_OUTCOMES)
  outcome?: AuditActionOutcome;

  @IsOptional()
  @IsString()
  action?: string;

  @IsOptional()
  @IsString()
  target?: string;

  @IsOptional()
  @IsISO8601()
  minTimestamp?: string;

  @IsOptional()
  @IsISO8601()
  maxTimestamp?: string;

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
