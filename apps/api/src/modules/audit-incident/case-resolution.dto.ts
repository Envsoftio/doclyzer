import { Type } from 'class-transformer';
import {
  IsIn,
  IsInt,
  IsISO8601,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { CASE_RESOLUTION_OUTCOMES } from './case-resolution.types';
import type { CaseResolutionOutcome } from './case-resolution.types';

export class SubmitResolutionDto {
  @IsString()
  @MinLength(10)
  @MaxLength(2000)
  summary!: string;

  @IsString()
  @MinLength(10)
  @MaxLength(2000)
  rootCause!: string;

  @IsString()
  @MinLength(5)
  @MaxLength(2000)
  userImpact!: string;

  @IsString()
  @MinLength(5)
  @MaxLength(2000)
  actionsTaken!: string;

  @IsIn(CASE_RESOLUTION_OUTCOMES)
  outcome!: CaseResolutionOutcome;

  // If re-closing a reopened investigation, link to prior closure doc (version chain)
  @IsOptional()
  @IsUUID()
  priorDocumentId?: string;
}

export class ResolutionQueryDto {
  @IsOptional()
  @IsISO8601()
  minDate?: string;

  @IsOptional()
  @IsISO8601()
  maxDate?: string;

  @IsOptional()
  @IsIn(CASE_RESOLUTION_OUTCOMES)
  outcome?: CaseResolutionOutcome;

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
