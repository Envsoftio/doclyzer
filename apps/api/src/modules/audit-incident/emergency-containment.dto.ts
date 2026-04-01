import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsInt,
  IsISO8601,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';

/**
 * Base for all emergency containment actions.
 * auditNote is MANDATORY: min 10 chars, max 1024 chars.
 */
export class EmergencyBaseDto {
  @IsString()
  @MinLength(10)
  @MaxLength(1024)
  auditNote!: string;

  @IsOptional()
  @IsString()
  @MaxLength(128)
  reasonCode?: string;
}

export class EmergencyAccountSuspendDto extends EmergencyBaseDto {
  @IsBoolean()
  suspended!: boolean;
}

export class EmergencyShareLinkSuspendDto extends EmergencyBaseDto {
  @IsBoolean()
  suspended!: boolean;
}

export class EmergencyActionTimelineQueryDto {
  @IsOptional()
  @IsString()
  targetUserId?: string;

  @IsOptional()
  @IsString()
  targetShareLinkId?: string;

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
