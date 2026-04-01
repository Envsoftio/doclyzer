import {
  IsIn,
  IsInt,
  IsISO8601,
  IsOptional,
  IsString,
  Max,
  Min,
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
