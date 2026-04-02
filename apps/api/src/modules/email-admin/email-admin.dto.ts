import {
  IsIn,
  IsInt,
  IsISO8601,
  IsObject,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { Type } from 'class-transformer';
import type { EmailDeliveryOutcome } from '../../database/entities/email-delivery-event.entity';

export class EmailDeliveryAnalyticsQueryDto {
  @IsISO8601()
  startDate!: string;

  @IsISO8601()
  endDate!: string;

  @IsOptional()
  @IsString()
  emailType?: string;

  @IsOptional()
  @IsString()
  recipientScope?: string;
}

export class EmailSendingHistoryQueryDto {
  @IsOptional()
  @IsISO8601()
  startDate?: string;

  @IsOptional()
  @IsISO8601()
  endDate?: string;

  @IsOptional()
  @IsString()
  emailType?: string;

  @IsOptional()
  @IsString()
  recipientScope?: string;

  @IsOptional()
  @IsIn(['sent', 'failed', 'bounced'] satisfies EmailDeliveryOutcome[])
  outcome?: EmailDeliveryOutcome;

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
  pageSize?: number;
}

export class EmailAdminSendRequestDto {
  @IsIn(['announcement', 'incident', 'support'])
  emailType!: 'announcement' | 'incident' | 'support';

  @IsString()
  @MinLength(3)
  @MaxLength(160)
  subject!: string;

  @IsString()
  @MinLength(10)
  @MaxLength(5000)
  body!: string;

  @IsIn(['all', 'segment', 'single'])
  recipientScope!: 'all' | 'segment' | 'single';

  @IsOptional()
  @IsUUID()
  recipientUserId?: string;

  @IsOptional()
  @IsString()
  @MaxLength(128)
  recipientSegment?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(1_000_000)
  estimatedRecipientCount?: number;

  @IsOptional()
  @IsString()
  @MaxLength(128)
  templateKey?: string;

  @IsOptional()
  @IsObject()
  templateData?: Record<string, string | number | boolean | null>;

  @IsOptional()
  @IsString()
  @MaxLength(128)
  idempotencyKey?: string;

  @IsOptional()
  @IsString()
  @MaxLength(128)
  approvalToken?: string;
}
