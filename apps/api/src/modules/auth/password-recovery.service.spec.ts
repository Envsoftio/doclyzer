import type { Repository } from 'typeorm';
import { PasswordResetTokenEntity } from '../../database/entities/password-reset-token.entity';
import { InMemoryNotificationService } from '../../common/notification/in-memory-notification.service';
import { AuthService } from './auth.service';
import { PasswordRecoveryService } from './password-recovery.service';

function makeTokenRepo(): jest.Mocked<Repository<PasswordResetTokenEntity>> {
  return {
    findOne: jest.fn(),
    find: jest.fn(),
    save: jest.fn(),
    create: jest.fn((data) => data as PasswordResetTokenEntity),
    delete: jest.fn(),
    update: jest.fn(),
  } as unknown as jest.Mocked<Repository<PasswordResetTokenEntity>>;
}

describe('PasswordRecoveryService', () => {
  let authService: jest.Mocked<
    Pick<AuthService, 'findUserByEmail' | 'hashPassword' | 'updatePasswordHash' | 'revokeAllSessionsForUser' | 'validatePasswordStrength'>
  >;
  let notificationService: InMemoryNotificationService;
  let tokenRepo: jest.Mocked<Repository<PasswordResetTokenEntity>>;
  let recoveryService: PasswordRecoveryService;

  beforeEach(() => {
    authService = {
      findUserByEmail: jest.fn(),
      hashPassword: jest.fn().mockResolvedValue('newhash'),
      updatePasswordHash: jest.fn().mockResolvedValue(undefined),
      revokeAllSessionsForUser: jest.fn().mockResolvedValue(undefined),
      validatePasswordStrength: jest.fn(),
    };
    notificationService = new InMemoryNotificationService();
    tokenRepo = makeTokenRepo();
    recoveryService = new PasswordRecoveryService(
      tokenRepo,
      authService as unknown as AuthService,
      notificationService,
    );
  });

  describe('requestReset', () => {
    it('returns generic message for known email', async () => {
      authService.findUserByEmail.mockResolvedValue({
        id: 'user-1',
        email: 'test@example.com',
        passwordHash: 'hash',
        displayName: null,
        createdAt: new Date(),
      });
      tokenRepo.delete.mockResolvedValue({ affected: 0, raw: {} });
      tokenRepo.save.mockResolvedValue({} as PasswordResetTokenEntity);

      const result = await recoveryService.requestReset('test@example.com');
      expect(result.message).toContain('If an account exists');
    });

    it('returns same generic message for unknown email (enumeration-safe)', async () => {
      authService.findUserByEmail.mockResolvedValue(null);
      tokenRepo.delete.mockResolvedValue({ affected: 0, raw: {} });

      const result = await recoveryService.requestReset('unknown@example.com');
      expect(result.message).toContain('If an account exists');
    });
  });

  describe('confirmReset', () => {
    it('throws AUTH_RESET_TOKEN_INVALID for unknown token', async () => {
      const { UnauthorizedException } = await import('@nestjs/common');
      tokenRepo.findOne.mockResolvedValue(null);
      await expect(
        recoveryService.confirmReset('bad-token', 'NewPass123!'),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('throws AUTH_RESET_TOKEN_EXPIRED for expired token', async () => {
      const { BadRequestException } = await import('@nestjs/common');
      tokenRepo.findOne.mockResolvedValue({
        id: 'tok-1',
        userId: 'user-1',
        tokenHash: 'somehash',
        expiresAt: new Date(Date.now() - 1000),
        usedAt: null,
        createdAt: new Date(),
      } as PasswordResetTokenEntity);
      await expect(
        recoveryService.confirmReset('expired-raw-token', 'NewPass123!'),
      ).rejects.toThrow(BadRequestException);
    });
  });
});
