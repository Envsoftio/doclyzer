import { SessionNotFoundException } from './exceptions/session-not-found.exception';
import { AuthService } from './auth.service';

describe('AuthService', () => {
  let service: AuthService;

  beforeEach(() => {
    service = new AuthService();
  });

  it('hashes passwords and verifies them', async () => {
    const hash = await service.hashPassword('StrongPass123!');

    expect(hash).not.toBe('StrongPass123!');
    await expect(service.verifyPassword('StrongPass123!', hash)).resolves.toBe(
      true,
    );
    await expect(service.verifyPassword('wrong', hash)).resolves.toBe(false);
  });

  it('issues and revokes login sessions', async () => {
    await service.register({
      email: 'unit@example.com',
      password: 'StrongPass123!',
      policyAccepted: true,
    });

    const login = await service.login({
      email: 'unit@example.com',
      password: 'StrongPass123!',
    });

    expect(login.accessToken).toBeTruthy();
    expect(login.refreshToken).toBeTruthy();

    service.logout(login.accessToken);
    expect(() => service.logout(login.accessToken)).toThrow();
  });

  it('requires policy acceptance to register', async () => {
    await expect(
      service.register({
        email: 'policy@example.com',
        password: 'StrongPass123!',
        policyAccepted: false,
      }),
    ).rejects.toThrow();
  });

  describe('token refresh', () => {
    it('rotates tokens and invalidates old refresh token', async () => {
      await service.register({
        email: 'refresh@example.com',
        password: 'StrongPass123!',
        policyAccepted: true,
      });

      const { accessToken, refreshToken } = await service.login({
        email: 'refresh@example.com',
        password: 'StrongPass123!',
      });

      const rotated = service.refresh(refreshToken);

      expect(rotated.accessToken).not.toBe(accessToken);
      expect(rotated.refreshToken).not.toBe(refreshToken);
      expect(rotated.accessToken).toBeTruthy();
      expect(rotated.refreshToken).toBeTruthy();

      expect(() => service.refresh(refreshToken)).toThrow();
    });

    it('rejects an unknown refresh token', () => {
      expect(() => service.refresh('totally-fake-token')).toThrow();
    });
  });

  describe('validateAccessToken', () => {
    const email = 'validate@example.com';
    const password = 'StrongPass123!';

    beforeEach(async () => {
      await service.register({ email, password, policyAccepted: true });
    });

    it('returns the AuthUser for a valid token', async () => {
      const { accessToken } = await service.login({ email, password });
      const user = service.validateAccessToken(accessToken);
      expect(user.email).toBe(email);
    });

    it('throws AUTH_UNAUTHORIZED for an unknown token', () => {
      expect(() => service.validateAccessToken('totally-unknown')).toThrow(
        expect.objectContaining({
          response: expect.objectContaining({ code: 'AUTH_UNAUTHORIZED' }),
        }),
      );
    });

    it('throws AUTH_UNAUTHORIZED for a revoked token', async () => {
      const { accessToken } = await service.login({ email, password });
      service.logout(accessToken);
      expect(() => service.validateAccessToken(accessToken)).toThrow(
        expect.objectContaining({
          response: expect.objectContaining({ code: 'AUTH_UNAUTHORIZED' }),
        }),
      );
    });

    it('throws AUTH_UNAUTHORIZED for an expired token', async () => {
      const { accessToken } = await service.login({ email, password });
      const realNow = Date.now();
      jest.useFakeTimers();
      jest.setSystemTime(realNow + 16 * 60 * 1000);
      try {
        expect(() => service.validateAccessToken(accessToken)).toThrow(
          expect.objectContaining({
            response: expect.objectContaining({ code: 'AUTH_UNAUTHORIZED' }),
          }),
        );
      } finally {
        jest.useRealTimers();
      }
    });
  });

  describe('rate limiting', () => {
    it('allows requests up to maxCount', () => {
      for (let i = 0; i < 10; i++) {
        expect(() =>
          service.enforceRateLimit('test', '1.2.3.4', 10),
        ).not.toThrow();
      }
    });

    it('blocks the (maxCount + 1)th request', () => {
      for (let i = 0; i < 10; i++) {
        service.enforceRateLimit('test', '1.2.3.4', 10);
      }
      expect(() => service.enforceRateLimit('test', '1.2.3.4', 10)).toThrow();
    });

    it('tracks different identifiers independently', () => {
      for (let i = 0; i < 10; i++) {
        service.enforceRateLimit('login', '1.1.1.1', 10);
      }
      expect(() =>
        service.enforceRateLimit('login', '2.2.2.2', 10),
      ).not.toThrow();
    });

    it('tracks different routes independently', () => {
      for (let i = 0; i < 10; i++) {
        service.enforceRateLimit('login', '1.2.3.4', 10);
      }
      expect(() =>
        service.enforceRateLimit('register', '1.2.3.4', 10),
      ).not.toThrow();
    });
  });

  describe('getSessions', () => {
    it('returns sessions with isCurrent true for matching sessionId', async () => {
      await service.register({
        email: 'sessions@example.com',
        password: 'StrongPass123!',
        policyAccepted: true,
      });
      const loginRes = await service.login(
        { email: 'sessions@example.com', password: 'StrongPass123!' },
        '192.168.1.1',
        'Mozilla/5.0',
      );
      const sessions = service.getSessions(
        service.validateAccessToken(loginRes.accessToken).id,
        service.getSessionIdForAccessToken(loginRes.accessToken),
      );
      expect(sessions).toHaveLength(1);
      expect(sessions[0].sessionId).toBeTruthy();
      expect(sessions[0].ip).toBe('192.168.1.1');
      expect(sessions[0].userAgent).toBe('Mozilla/5.0');
      expect(sessions[0].isCurrent).toBe(true);
      expect(sessions[0].createdAt).toBeTruthy();
    });

    it('returns empty array when user has no active sessions', async () => {
      await service.register({
        email: 'nosess@example.com',
        password: 'StrongPass123!',
        policyAccepted: true,
      });
      const user = service.findUserByEmail('nosess@example.com');
      expect(user).toBeDefined();
      const sessions = service.getSessions(user!.id, null);
      expect(sessions).toEqual([]);
    });

    it('marks isCurrent false when currentSessionId does not match', async () => {
      await service.register({
        email: 'current@example.com',
        password: 'StrongPass123!',
        policyAccepted: true,
      });
      const loginRes = await service.login({
        email: 'current@example.com',
        password: 'StrongPass123!',
      });
      const userId = service.validateAccessToken(loginRes.accessToken).id;
      const sessions = service.getSessions(userId, 'non-matching-session-id');
      expect(sessions).toHaveLength(1);
      expect(sessions[0].isCurrent).toBe(false);
    });
  });

  describe('revokeSession', () => {
    it('revokes session and emits audit log', async () => {
      await service.register({
        email: 'revoke@example.com',
        password: 'StrongPass123!',
        policyAccepted: true,
      });
      const loginRes = await service.login({
        email: 'revoke@example.com',
        password: 'StrongPass123!',
      });
      const userId = service.validateAccessToken(loginRes.accessToken).id;
      const sessionId = service.getSessionIdForAccessToken(loginRes.accessToken)!;
      const logSpy = jest.spyOn(service['logger'], 'log').mockImplementation();
      service.revokeSession(userId, sessionId, 'corr-123');
      expect(logSpy).toHaveBeenCalledWith(
        JSON.stringify({
          action: 'SESSION_REVOKED',
          actorUserId: userId,
          targetSessionId: sessionId,
          correlationId: 'corr-123',
        }),
      );
      logSpy.mockRestore();
      expect(() => service.validateAccessToken(loginRes.accessToken)).toThrow();
    });

    it('throws SessionNotFoundException for unknown sessionId', async () => {
      await service.register({
        email: 'revoke2@example.com',
        password: 'StrongPass123!',
        policyAccepted: true,
      });
      const loginRes = await service.login({
        email: 'revoke2@example.com',
        password: 'StrongPass123!',
      });
      const userId = service.validateAccessToken(loginRes.accessToken).id;
      expect(() =>
        service.revokeSession(userId, '00000000-0000-0000-0000-000000000000', 'c'),
      ).toThrow(SessionNotFoundException);
    });
  });

  describe('getSessionIdForAccessToken', () => {
    it('returns sessionId for valid token', async () => {
      await service.register({
        email: 'sid@example.com',
        password: 'StrongPass123!',
        policyAccepted: true,
      });
      const loginRes = await service.login({
        email: 'sid@example.com',
        password: 'StrongPass123!',
      });
      const sessionId = service.getSessionIdForAccessToken(loginRes.accessToken);
      expect(sessionId).toBeTruthy();
      expect(typeof sessionId).toBe('string');
    });

    it('returns null for invalid token', () => {
      expect(service.getSessionIdForAccessToken('invalid')).toBeNull();
    });

    it('returns null for revoked token', async () => {
      await service.register({
        email: 'sid2@example.com',
        password: 'StrongPass123!',
        policyAccepted: true,
      });
      const loginRes = await service.login({
        email: 'sid2@example.com',
        password: 'StrongPass123!',
      });
      service.logout(loginRes.accessToken);
      expect(service.getSessionIdForAccessToken(loginRes.accessToken)).toBeNull();
    });
  });
});
