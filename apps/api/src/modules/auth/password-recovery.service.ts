import {
  BadRequestException,
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { LessThan, Repository } from 'typeorm';
import { createHash, randomBytes } from 'node:crypto';
import { PasswordResetTokenEntity } from '../../database/entities/password-reset-token.entity';
import { NotificationService } from '../../common/notification/notification.service';
import { AuthService } from './auth.service';
import type {
  ForgotPasswordResponse,
  ResetPasswordResponse,
} from './auth.types';

@Injectable()
export class PasswordRecoveryService {
  private readonly logger = new Logger(PasswordRecoveryService.name);

  constructor(
    @InjectRepository(PasswordResetTokenEntity)
    private readonly tokenRepo: Repository<PasswordResetTokenEntity>,
    private readonly authService: AuthService,
    private readonly notificationService: NotificationService,
  ) {}

  async requestReset(email: string): Promise<ForgotPasswordResponse> {
    const normalizedEmail = email.trim().toLowerCase();
    const rawToken = randomBytes(32).toString('hex');
    const user = await this.authService.findUserByEmail(normalizedEmail);

    await this.purgeExpiredTokens();

    if (!user) {
      createHash('sha256').update(rawToken).digest('hex');
      this.logger.log(
        'Password reset requested (enumeration-safe: no matching account)',
      );
      return {
        message:
          'If an account exists for this email, a reset link has been sent.',
      };
    }

    // Invalidate any previous pending tokens for this user.
    await this.tokenRepo.delete({
      userId: user.id,
      usedAt: undefined as unknown as Date,
    });

    const tokenHash = createHash('sha256').update(rawToken).digest('hex');
    await this.tokenRepo.save(
      this.tokenRepo.create({
        userId: user.id,
        tokenHash,
        expiresAt: new Date(Date.now() + 60 * 60 * 1000),
        usedAt: null,
      }),
    );

    void this.notificationService.sendPasswordResetToken(
      normalizedEmail,
      rawToken,
    );

    this.logger.log(`Password reset token issued userId=${user.id}`);
    return {
      message:
        'If an account exists for this email, a reset link has been sent.',
    };
  }

  async confirmReset(
    rawToken: string,
    newPassword: string,
  ): Promise<ResetPasswordResponse> {
    this.authService.validatePasswordStrength(newPassword);

    const tokenHash = createHash('sha256').update(rawToken).digest('hex');
    const record = await this.tokenRepo.findOne({ where: { tokenHash } });

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

    await this.tokenRepo.update(record.id, { usedAt: new Date() });

    const newHash = await this.authService.hashPassword(newPassword);
    await this.authService.updatePasswordHash(record.userId, newHash);
    await this.authService.revokeAllSessionsForUser(record.userId);

    this.logger.log(
      `Password reset confirmed userId=${record.userId} — sessions revoked`,
    );
    return {
      message:
        'Password reset successful. Please log in with your new password.',
    };
  }

  private async purgeExpiredTokens(): Promise<void> {
    await this.tokenRepo.delete({ expiresAt: LessThan(new Date()) });
  }
}
