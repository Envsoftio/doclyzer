import { Transform, Type } from 'class-transformer';
import {
  IsBoolean,
  IsIn,
  IsInt,
  IsObject,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import type { PushPlatform } from '../../database/entities/user-device-token.entity';

export const PUSH_PLATFORMS = [
  'ios',
  'android',
  'web',
  'mobile_web',
] as const satisfies readonly PushPlatform[];

export const PUSH_NOTIFICATION_CATEGORIES = [
  'billing',
  'referrals',
  'product',
  'admin_announcements',
  'security',
  'compliance',
] as const;

export type PushNotificationCategory =
  (typeof PUSH_NOTIFICATION_CATEGORIES)[number];

export class RegisterDeviceTokenDto {
  @IsString()
  @MinLength(16)
  @MaxLength(4096)
  token!: string;

  @IsIn(PUSH_PLATFORMS)
  platform!: PushPlatform;

  @IsOptional()
  @IsIn(['fcm'])
  provider?: 'fcm';

  @IsOptional()
  @IsString()
  @MaxLength(128)
  installationId?: string;

  @IsOptional()
  @IsString()
  @MaxLength(64)
  appVersion?: string;

  @IsOptional()
  @IsString()
  @MaxLength(128)
  deviceLabel?: string;

  @IsOptional()
  @IsObject()
  preferences?: Record<string, boolean>;

  @IsOptional()
  @IsObject()
  metadata?: Record<string, string | number | boolean | null>;
}

export class UpdateDeviceTokenPreferencesDto {
  @IsObject()
  preferences!: Record<string, boolean>;
}

export class PushOpenDto {
  @IsOptional()
  @IsUUID()
  deviceTokenId?: string;

  @IsOptional()
  @IsUUID()
  pushSendAuditId?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  providerMessageId?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  deepLink?: string;

  @IsOptional()
  @IsObject()
  metadata?: Record<string, string | number | boolean | null>;
}

export class AdminPushBroadcastDto {
  @IsIn(['announcement', 'incident', 'support', 'billing', 'referral', 'system'])
  notificationType!:
    | 'announcement'
    | 'incident'
    | 'support'
    | 'billing'
    | 'referral'
    | 'system';

  @IsOptional()
  @IsIn(PUSH_NOTIFICATION_CATEGORIES)
  category?: PushNotificationCategory;

  @IsString()
  @MinLength(3)
  @MaxLength(120)
  title!: string;

  @IsString()
  @MinLength(3)
  @MaxLength(280)
  body!: string;

  @IsIn(['all', 'segment', 'single'])
  recipientScope!: 'all' | 'segment' | 'single';

  @IsOptional()
  @IsUUID()
  recipientUserId?: string;

  @IsOptional()
  @IsString()
  @MaxLength(64)
  recipientSegment?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  deepLink?: string;

  @IsOptional()
  @IsObject()
  data?: Record<string, string | number | boolean | null>;

  @IsOptional()
  @IsString()
  @MaxLength(128)
  idempotencyKey?: string;

  @IsOptional()
  @IsString()
  @MaxLength(128)
  approvalToken?: string;
}

export class PushAuditQueryDto {
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
  @Transform(({ value }) => {
    if (value === 'true') return true;
    if (value === 'false') return false;
    return value as unknown;
  })
  @IsBoolean()
  dryRun?: boolean;
}
