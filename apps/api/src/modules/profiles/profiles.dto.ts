import { IsNotEmpty, IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateProfileDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  name!: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  dateOfBirth?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  relation?: string;
}

export class UpdateProfileDto {
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  name?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  dateOfBirth?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  relation?: string;
}
