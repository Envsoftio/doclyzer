import {
  BadRequestException,
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AuthService } from './auth.service';
import { BetterAuthService } from './better-auth.service';
import type {
  ForgotPasswordResponse,
  ResetPasswordResponse,
} from './auth.types';

interface BetterAuthErrorBody {
  code?: string;
}

interface BetterAuthError extends Error {
  body?: BetterAuthErrorBody;
}

@Injectable()
export class PasswordRecoveryService {
  private readonly logger = new Logger(PasswordRecoveryService.name);

  constructor(
    private readonly authService: AuthService,
    private readonly betterAuthService: BetterAuthService,
    private readonly configService: ConfigService,
  ) {}

  async requestReset(email: string): Promise<ForgotPasswordResponse> {
    const normalizedEmail = email.trim().toLowerCase();
    if (!this.isValidEmail(normalizedEmail)) {
      this.logger.log('Password reset requested (invalid email format)');
      return {
        message:
          'If an account exists for this email, a reset link has been sent.',
      };
    }

    const auth = await this.betterAuthService.getAuth();
    const redirectTo = this.configService.get<string>(
      'BETTER_AUTH_RESET_REDIRECT_URL',
    );

    await auth.api.requestPasswordReset({
      body: redirectTo
        ? { email: normalizedEmail, redirectTo }
        : { email: normalizedEmail },
    });

    this.logger.log('Password reset requested (enumeration-safe)');
    return {
      message:
        'If an account exists for this email, a reset link has been sent.',
    };
  }

  async confirmReset(
    token: string,
    newPassword: string,
  ): Promise<ResetPasswordResponse> {
    this.authService.validatePasswordStrength(newPassword);

    const auth = await this.betterAuthService.getAuth();
    try {
      await auth.api.resetPassword({
        body: {
          token,
          newPassword,
        },
      });
    } catch (error: unknown) {
      const code = this.getBetterAuthErrorCode(error);
      if (code === 'INVALID_TOKEN') {
        throw new UnauthorizedException({
          code: 'AUTH_RESET_TOKEN_INVALID',
          message: 'Reset token is invalid or has already been used',
        });
      }
      if (code === 'TOKEN_EXPIRED') {
        throw new BadRequestException({
          code: 'AUTH_RESET_TOKEN_EXPIRED',
          message: 'Reset token has expired. Please request a new one.',
        });
      }
      if (code === 'PASSWORD_TOO_SHORT' || code === 'PASSWORD_TOO_LONG') {
        throw new BadRequestException({
          code: 'AUTH_PASSWORD_INVALID',
          message:
            'Password must be at least 8 characters long and contain uppercase, lowercase, a digit, and a special character',
        });
      }
      throw error;
    }

    this.logger.log('Password reset confirmed');
    return {
      message:
        'Password reset successful. Please log in with your new password.',
    };
  }

  private isValidEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

  private getBetterAuthErrorCode(error: unknown): string | null {
    if (!error || typeof error !== 'object') return null;
    const err = error as BetterAuthError;
    if (!err.body || typeof err.body !== 'object') return null;
    return err.body.code ?? null;
  }
}
