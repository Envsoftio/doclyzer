import { IsBoolean, IsOptional, IsString, MaxLength } from 'class-validator';

export class SetShareLinkSuspensionDto {
  @IsBoolean()
  suspended!: boolean;

  @IsOptional()
  @IsString()
  @MaxLength(128)
  reasonCode?: string;

  @IsOptional()
  @IsString()
  @MaxLength(256)
  note?: string;
}

export class SetAccountSuspensionDto {
  @IsBoolean()
  suspended!: boolean;

  @IsOptional()
  @IsString()
  @MaxLength(256)
  rationale?: string;

  @IsOptional()
  @IsString()
  @MaxLength(256)
  nextSteps?: string;

  @IsOptional()
  @IsString()
  @MaxLength(128)
  reasonCode?: string;
}
