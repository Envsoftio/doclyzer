import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { AuthGuard } from './auth.guard';
import { AuthService } from '../../modules/auth/auth.service';
import type { AuthUser } from '../../modules/auth/auth.types';

function makeContext(authHeader?: string): {
  ctx: ExecutionContext;
  req: Record<string, unknown>;
} {
  const req: Record<string, unknown> = {
    header: (name: string) =>
      name.toLowerCase() === 'authorization' ? authHeader : undefined,
  };
  const ctx = {
    switchToHttp: () => ({ getRequest: () => req }),
  } as unknown as ExecutionContext;
  return { ctx, req };
}

describe('AuthGuard', () => {
  let guard: AuthGuard;
  let authService: jest.Mocked<
    Pick<AuthService, 'validateAccessToken' | 'getSessionIdForAccessToken'>
  >;

  beforeEach(() => {
    authService = {
      validateAccessToken: jest.fn(),
      getSessionIdForAccessToken: jest.fn().mockReturnValue('session-1'),
    };
    guard = new AuthGuard(authService as unknown as AuthService);
  });

  it('passes and attaches user and currentSessionId for a valid Bearer token', async () => {
    const fullUser: AuthUser = {
      id: 'user-1',
      email: 'test@example.com',
      passwordHash: 'hash',
      displayName: null,
      createdAt: new Date(),
    };
    authService.validateAccessToken.mockResolvedValue(fullUser);
    authService.getSessionIdForAccessToken.mockReturnValue('session-1');
    const { ctx, req } = makeContext('Bearer valid-token');
    const result = await guard.canActivate(ctx);
    expect(result).toBe(true);
    expect(req['user']).toEqual({ id: 'user-1' });
    expect(req['currentSessionId']).toBe('session-1');
  });

  it('throws AUTH_UNAUTHORIZED when Authorization header is missing', async () => {
    const { ctx } = makeContext(undefined);
    await expect(guard.canActivate(ctx)).rejects.toThrow(UnauthorizedException);
  });

  it('throws AUTH_UNAUTHORIZED when scheme is not Bearer', async () => {
    const { ctx } = makeContext('Basic some-token');
    await expect(guard.canActivate(ctx)).rejects.toThrow(UnauthorizedException);
  });

  it('throws AUTH_UNAUTHORIZED when token is missing after Bearer', async () => {
    const { ctx } = makeContext('Bearer ');
    await expect(guard.canActivate(ctx)).rejects.toThrow(UnauthorizedException);
    expect(authService.validateAccessToken).not.toHaveBeenCalled();
  });

  it('propagates UnauthorizedException from AuthService (revoked/expired)', async () => {
    authService.validateAccessToken.mockRejectedValue(
      new UnauthorizedException({ code: 'AUTH_UNAUTHORIZED', message: 'Authentication required' }),
    );
    const { ctx } = makeContext('Bearer revoked-token');
    await expect(guard.canActivate(ctx)).rejects.toThrow(UnauthorizedException);
  });
});
