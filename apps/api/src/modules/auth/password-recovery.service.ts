import {
  BadRequestException,
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { createHash, randomBytes } from 'node:crypto';
import { NotificationService } from '../../common/notification/notification.service';
import { AuthService } from './auth.service';
import type {
  ForgotPasswordResponse,
  ResetPasswordResponse,
} from './auth.types';

interface ResetTokenRecord {
  tokenHash: string;
  userId: string;
  email: string;
  expiresAt: Date;
  usedAt?: Date;
}

@Injectable()
export class PasswordRecoveryService {
  private readonly logger = new Logger(PasswordRecoveryService.name);
  private readonly resetTokensByHash = new Map<string, ResetTokenRecord>();

  constructor(
    private readonly authService: AuthService,
    private readonly notificationService: NotificationService,
  ) {}

  requestReset(email: string): Promise<ForgotPasswordResponse> {
    const normalizedEmail = email.trim().toLowerCase();
    const rawToken = randomBytes(32).toString('hex');
    const user = this.authService.findUserByEmail(normalizedEmail);

    this.purgeExpiredTokens();

    if (!user) {
      // Do equivalent work to avoid timing oracle on account existence.
      createHash('sha256').update(rawToken).digest('hex');
      this.logger.log(
        'Password reset requested (enumeration-safe: no matching account)',
      );
      return Promise.resolve({
        message:
          'If an account exists for this email, a reset link has been sent.',
      });
    }

    // Invalidate any previous pending token for this account.
    for (const [hash, record] of this.resetTokensByHash) {
      if (record.email === normalizedEmail && !record.usedAt) {
        this.resetTokensByHash.delete(hash);
      }
    }

    const tokenHash = createHash('sha256').update(rawToken).digest('hex');
    this.resetTokensByHash.set(tokenHash, {
      tokenHash,
      userId: user.id,
      email: normalizedEmail,
      expiresAt: new Date(Date.now() + 60 * 60 * 1000), // 1 hour
    });

    void this.notificationService.sendPasswordResetToken(
      normalizedEmail,
      rawToken,
    );

    this.logger.log(`Password reset token issued userId=${user.id}`);

    return Promise.resolve({
      message:
        'If an account exists for this email, a reset link has been sent.',
    });
  }

  async confirmReset(
    rawToken: string,
    newPassword: string,
  ): Promise<ResetPasswordResponse> {
    this.authService.validatePasswordStrength(newPassword);

    const tokenHash = createHash('sha256').update(rawToken).digest('hex');
    const record = this.resetTokensByHash.get(tokenHash);

    if (!record) {
      throw new UnauthorizedException({
        code: 'AUTH_RESET_TOKEN_INVALID',
        message: 'Reset token is invalid or has already been used',
      });
    }

    if (record.usedAt) {
      throw new UnauthorizedException({
        code: 'AUTH_RESET_TOKEN_USED',
        message: 'Reset token is invalid or has already been used',
      });
    }

    if (record.expiresAt <= new Date()) {
      throw new BadRequestException({
        code: 'AUTH_RESET_TOKEN_EXPIRED',
        message: 'Reset token has expired. Please request a new one.',
      });
    }

    // Mark single-use before any state mutation.
    record.usedAt = new Date();

    const newHash = await this.authService.hashPassword(newPassword);
    this.authService.updatePasswordHash(record.userId, newHash);
    this.authService.revokeAllSessionsForUser(record.userId);

    this.logger.log(
      `Password reset confirmed userId=${record.userId} — sessions revoked`,
    );

    return {
      message:
        'Password reset successful. Please log in with your new password.',
    };
  }

  private purgeExpiredTokens(): void {
    const now = new Date();
    for (const [hash, record] of this.resetTokensByHash) {
      if (record.expiresAt <= now) {
        this.resetTokensByHash.delete(hash);
      }
    }
  }
}
