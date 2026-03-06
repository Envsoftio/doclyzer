import type { Request } from 'express';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { PasswordRecoveryService } from './password-recovery.service';
import type { DeviceSessionSummary } from './auth.types';

function makeReq(
  overrides: Partial<
    Request & {
      user: { id: string };
      currentSessionId?: string | null;
      correlationId?: string;
    }
  > = {},
): Request {
  return {
    user: { id: 'user-1' },
    currentSessionId: null,
    correlationId: 'test-cid',
    header: () => undefined,
    headers: {},
    ...overrides,
  } as unknown as Request;
}

describe('AuthController', () => {
  let controller: AuthController;
  let authService: jest.Mocked<
    Pick<AuthService, 'getSessions' | 'revokeSession'>
  >;

  beforeEach(() => {
    authService = {
      getSessions: jest.fn(),
      revokeSession: jest.fn(),
    };
    controller = new AuthController(
      authService as unknown as AuthService,
      {} as unknown as PasswordRecoveryService,
    );
  });

  describe('getSessions', () => {
    it('delegates to getSessions and returns success envelope', async () => {
      const sessions: DeviceSessionSummary[] = [
        {
          sessionId: 's1',
          ip: '127.0.0.1',
          userAgent: 'test',
          createdAt: new Date().toISOString(),
          isCurrent: true,
        },
      ];
      authService.getSessions.mockResolvedValue(sessions);
      const req = makeReq({ user: { id: 'user-1' }, currentSessionId: 's1' });
      const result = (await controller.getSessions(req)) as {
        success: boolean;
        data: DeviceSessionSummary[];
        correlationId: string;
      };
      expect(result.success).toBe(true);
      expect(result.data).toEqual(sessions);
      expect(authService.getSessions).toHaveBeenCalledWith('user-1', 's1');
    });
  });

  describe('revokeSession', () => {
    it('delegates to revokeSession and returns success envelope', async () => {
      authService.revokeSession.mockResolvedValue(undefined);
      const result = (await controller.revokeSession(
        makeReq(),
        'session-123',
      )) as {
        success: boolean;
        data: null;
        correlationId: string;
      };
      expect(result.success).toBe(true);
      expect(result.data).toBeNull();
      expect(authService.revokeSession).toHaveBeenCalledWith(
        'user-1',
        'session-123',
        'test-cid',
      );
    });

    it('propagates SessionNotFoundException', async () => {
      authService.revokeSession.mockRejectedValue(
        new Error('SESSION_NOT_FOUND'),
      );
      await expect(
        controller.revokeSession(makeReq(), 'bad-id'),
      ).rejects.toThrow();
    });
  });
});
