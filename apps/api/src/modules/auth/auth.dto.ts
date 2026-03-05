import {
  IsBoolean,
  IsEmail,
  IsNotEmpty,
  IsString,
  MinLength,
} from 'class-validator';

export class RegisterDto {
  @IsEmail({}, { message: 'Email must be a valid email address' })
  email!: string;

  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters long' })
  password!: string;

  @IsBoolean({ message: 'policyAccepted must be a boolean' })
  policyAccepted!: boolean;
}

export class LoginDto {
  @IsEmail({}, { message: 'Email must be a valid email address' })
  email!: string;

  @IsString()
  @MinLength(1)
  password!: string;
}

export class RefreshDto {
  @IsString()
  @IsNotEmpty()
  refreshToken!: string;
}

export class ForgotPasswordDto {
  @IsEmail({}, { message: 'Email must be a valid email address' })
  email!: string;
}

export class ResetPasswordDto {
  @IsString()
  @IsNotEmpty({ message: 'Reset token is required' })
  token!: string;

  @IsString()
  @IsNotEmpty({ message: 'New password is required' })
  newPassword!: string;
}
