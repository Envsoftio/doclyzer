import { BadRequestException, UnauthorizedException } from '@nestjs/common';
import { InMemoryNotificationService } from '../../common/notification/in-memory-notification.service';
import { AuthService } from './auth.service';
import { PasswordRecoveryService } from './password-recovery.service';

async function setupUser(
  service: AuthService,
  email = 'test@example.com',
  password = 'StrongPass123!',
): Promise<void> {
  await service.register({ email, password });
}

describe('PasswordRecoveryService', () => {
  let authService: AuthService;
  let notificationService: InMemoryNotificationService;
  let recoveryService: PasswordRecoveryService;

  beforeEach(() => {
    authService = new AuthService();
    notificationService = new InMemoryNotificationService();
    recoveryService = new PasswordRecoveryService(
      authService,
      notificationService,
    );
  });

  describe('requestReset', () => {
    it('returns generic message for known email (enumeration-safe)', async () => {
      await setupUser(authService);
      const result = await recoveryService.requestReset('test@example.com');
      expect(result.message).toContain('If an account exists');
    });

    it('returns identical message for unknown email (no enumeration)', async () => {
      const known = await recoveryService.requestReset('known@example.com');
      await setupUser(authService, 'known2@example.com');
      const registered =
        await recoveryService.requestReset('known2@example.com');
      expect(known.message).toBe(registered.message);
    });

    it('issues a token via notification service for known account', async () => {
      await setupUser(authService);
      await recoveryService.requestReset('test@example.com');
      const token =
        notificationService.getLastTokenForEmail('test@example.com');
      expect(token).toBeTruthy();
      expect(typeof token).toBe('string');
    });

    it('delivers no token for unknown email', async () => {
      await recoveryService.requestReset('nobody@example.com');
      const token =
        notificationService.getLastTokenForEmail('nobody@example.com');
      expect(token).toBeUndefined();
    });

    it('invalidates previous pending token on re-request', async () => {
      await setupUser(authService);
      await recoveryService.requestReset('test@example.com');
      const firstToken =
        notificationService.getLastTokenForEmail('test@example.com')!;
      await recoveryService.requestReset('test@example.com');
      const secondToken =
        notificationService.getLastTokenForEmail('test@example.com');
      expect(firstToken).not.toBe(secondToken);
      await expect(
        recoveryService.confirmReset(firstToken, 'NewPass456!'),
      ).rejects.toThrow();
    });
  });

  describe('confirmReset', () => {
    it('resets password and allows login with new password', async () => {
      await setupUser(authService);
      await recoveryService.requestReset('test@example.com');
      const token =
        notificationService.getLastTokenForEmail('test@example.com')!;

      await recoveryService.confirmReset(token, 'NewPass456!');

      await expect(
        authService.login({
          email: 'test@example.com',
          password: 'StrongPass123!',
        }),
      ).rejects.toThrow();

      const loginResult = await authService.login({
        email: 'test@example.com',
        password: 'NewPass456!',
      });
      expect(loginResult.accessToken).toBeTruthy();
    });

    it('revokes all active sessions on successful reset', async () => {
      await setupUser(authService);
      const { accessToken } = await authService.login({
        email: 'test@example.com',
        password: 'StrongPass123!',
      });

      await recoveryService.requestReset('test@example.com');
      const token =
        notificationService.getLastTokenForEmail('test@example.com')!;
      await recoveryService.confirmReset(token, 'NewPass456!');

      expect(() => authService.logout(accessToken)).toThrow();
    });

    it('enforces single-use: rejects token used twice', async () => {
      await setupUser(authService);
      await recoveryService.requestReset('test@example.com');
      const token =
        notificationService.getLastTokenForEmail('test@example.com')!;

      await recoveryService.confirmReset(token, 'NewPass456!');
      await expect(
        recoveryService.confirmReset(token, 'AnotherPass789!'),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('rejects invalid token', async () => {
      await expect(
        recoveryService.confirmReset('completely-fake-token', 'NewPass456!'),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('enforces password policy on reset', async () => {
      await setupUser(authService);
      await recoveryService.requestReset('test@example.com');
      const token =
        notificationService.getLastTokenForEmail('test@example.com')!;

      await expect(
        recoveryService.confirmReset(token, 'short'),
      ).rejects.toThrow(BadRequestException);
    });
  });
});
