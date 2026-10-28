import { Transform } from 'class-transformer';
import {
  IsBoolean,
  IsDateString,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  ValidateBy,
  ValidateIf,
} from 'class-validator';

export class CreateDataExportRequestDto {
  @IsOptional()
  @IsUUID()
  profileId?: string;

  @IsOptional()
  @IsDateString()
  from?: string;

  @IsOptional()
  @IsDateString()
  to?: string;

  @IsOptional()
  @IsBoolean()
  includeOriginals?: boolean;

  @IsOptional()
  @IsBoolean()
  includeResults?: boolean;
}

export class CreateClosureRequestDto {
  @IsBoolean()
  confirmClosure!: boolean;

  @IsString()
  password!: string;
}

/** Only null is allowed to clear avatar; use POST /account/avatar to upload */
function avatarUrlMustBeNull(value: unknown): boolean {
  return value === null;
}

export class UpdateAccountProfileDto {
  @IsOptional()
  @Transform(({ value }: { value: unknown }) => {
    if (typeof value === 'string') {
      const trimmed = value.trim();
      return trimmed === '' ? null : trimmed;
    }
    return value;
  })
  @IsString()
  @MaxLength(100)
  displayName?: string | null;

  @ValidateIf((o: { avatarUrl?: string | null }) => o.avatarUrl !== undefined)
  @ValidateBy({
    name: 'avatarUrlMustBeNull',
    validator: {
      validate: avatarUrlMustBeNull,
      defaultMessage: () =>
        'avatarUrl can only be null to clear avatar; use POST /account/avatar to upload',
    },
  })
  avatarUrl?: string | null;
}

export class UpdateCommunicationPreferencesDto {
  @IsOptional()
  @IsBoolean()
  marketingPush?: boolean;

  @IsOptional()
  @IsBoolean()
  productEmails?: boolean;

  @IsOptional()
  @IsBoolean()
  reportReady?: boolean;

  @IsOptional()
  @IsBoolean()
  uploadUpdates?: boolean;

  @IsOptional()
  @IsBoolean()
  shareReminders?: boolean;
}
