import { Transform } from 'class-transformer';
import { IsBoolean, IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateDataExportRequestDto {}

export class CreateClosureRequestDto {
  @IsBoolean()
  confirmClosure!: boolean;
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

  @IsOptional()
  @IsString()
  @MaxLength(1024)
  avatarUrl?: string | null;
}

export class UpdateCommunicationPreferencesDto {
  @IsOptional()
  @IsBoolean()
  productEmails?: boolean;
}
