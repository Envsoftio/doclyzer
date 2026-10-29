import {
  IsIn,
  IsISO8601,
  IsOptional,
  IsString,
  IsUrl,
  IsUUID,
  MaxLength,
  MinLength,
} from 'class-validator';
export class PushCampaignDto {
  @IsString() @MinLength(3) @MaxLength(120) name!: string;
  @IsString() @MinLength(3) @MaxLength(120) title!: string;
  @IsString() @MinLength(3) @MaxLength(280) body!: string;
  @IsOptional() @IsString() @MaxLength(255) deepLink?: string;
  @IsOptional()
  @IsUrl({ protocols: ['https'], require_protocol: true })
  @MaxLength(2048)
  imageUrl?: string;
  @IsIn(['all', 'single']) audience!: 'all' | 'single';
  @IsOptional() @IsUUID() userId?: string;
  @IsOptional()
  @IsIn(['all', 'android', 'ios', 'web', 'mobile_web'])
  platform?: string;
  @IsString() @MinLength(8) @MaxLength(128) idempotencyKey!: string;
}
export class SchedulePushCampaignDto {
  @IsOptional() @IsISO8601({ strict: true }) scheduledAt?: string;
}
export class PushRecipientEventDto {
  @IsUUID() recipientId!: string;
  @IsIn(['received', 'opened', 'deep_link_opened']) eventType!: string;
}
