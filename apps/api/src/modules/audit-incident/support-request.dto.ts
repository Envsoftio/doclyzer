import {
  IsIn,
  IsObject,
  IsOptional,
  IsString,
  MaxLength,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import {
  SUPPORT_ACTION_TYPES,
  SUPPORT_REQUEST_STATUSES,
} from './support-request.types';
import type {
  SupportActionType,
  SupportRequestStatus,
} from './support-request.types';

export class SupportRequestContextDto {
  @IsIn(SUPPORT_ACTION_TYPES)
  actionType!: SupportActionType;

  @IsOptional()
  @IsString()
  @MaxLength(128)
  correlationId?: string;

  @IsOptional()
  @IsString()
  @MaxLength(128)
  clientActionId?: string;

  @IsOptional()
  @IsString()
  @MaxLength(64)
  errorCode?: string;

  @IsOptional()
  @IsObject()
  entityIds?: Record<string, string>;

  @IsOptional()
  @IsObject()
  metadata?: Record<string, string | number | boolean | null>;
}

export class CreateSupportRequestDto {
  @ValidateNested()
  @Type(() => SupportRequestContextDto)
  context!: SupportRequestContextDto;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  userMessage?: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  errorMessage?: string;
}

export class SupportRequestAdminQueryDto {
  @IsOptional()
  @IsIn(SUPPORT_REQUEST_STATUSES)
  status?: SupportRequestStatus;

  @IsOptional()
  @IsIn(SUPPORT_ACTION_TYPES)
  actionType?: SupportActionType;

  @IsOptional()
  @IsString()
  userId?: string;

  @IsOptional()
  @IsString()
  correlationId?: string;

  @IsOptional()
  @IsString()
  clientActionId?: string;

  @IsOptional()
  @Type(() => Number)
  limit?: number;

  @IsOptional()
  @Type(() => Number)
  page?: number;
}
