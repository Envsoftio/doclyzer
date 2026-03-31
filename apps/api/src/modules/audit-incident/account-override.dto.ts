import {
  ArrayMinSize,
  IsArray,
  IsDateString,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
} from 'class-validator';

export class CreateAccountOverrideDto {
  @IsArray()
  @ArrayMinSize(1)
  @IsString({ each: true })
  overriddenActions!: string[];

  @IsDateString()
  expiresAt!: string;

  @IsOptional()
  @IsString()
  @MaxLength(512)
  reason?: string;
}

export class RevokeAccountOverrideDto {
  @IsUUID()
  overrideId!: string;

  @IsOptional()
  @IsString()
  @MaxLength(512)
  revokedReason?: string;
}
