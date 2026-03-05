import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { AuthGuard } from './auth.guard';
import { AuthService } from '../../modules/auth/auth.service';
import type { AuthUser } from '../../modules/auth/auth.types';

const mockUser: AuthUser = {
  id: 'user-1',
  email: 'test@example.com',
  passwordHash: 'hash',
  displayName: null,
  createdAt: new Date(),
};

function makeContext(authHeader?: string): {
  ctx: ExecutionContext;
  req: Record<string, unknown>;
} {
  const req: Record<string, unknown> = {
    header: (name: string) =>
      name.toLowerCase() === 'authorization' ? authHeader : undefined,
  };
  const ctx = {
    switchToHttp: () => ({
      getRequest: () => req,
    }),
  } as unknown as ExecutionContext;
  return { ctx, req };
}

describe('AuthGuard', () => {
  let guard: AuthGuard;
  let authService: jest.Mocked<Pick<AuthService, 'validateAccessToken'>>;

  beforeEach(() => {
    authService = { validateAccessToken: jest.fn() };
    guard = new AuthGuard(authService as unknown as AuthService);
  });

  it('passes and attaches user for a valid Bearer token', () => {
    authService.validateAccessToken.mockReturnValue(mockUser);
    const { ctx, req } = makeContext('Bearer valid-token');
    const result = guard.canActivate(ctx);
    expect(result).toBe(true);
    expect(req['user']).toEqual(mockUser);
  });

  it('throws AUTH_UNAUTHORIZED when Authorization header is missing', () => {
    const { ctx } = makeContext(undefined);
    expect(() => guard.canActivate(ctx)).toThrow(UnauthorizedException);
    try {
      guard.canActivate(ctx);
    } catch (e) {
      expect((e as UnauthorizedException).getResponse()).toMatchObject({
        code: 'AUTH_UNAUTHORIZED',
      });
    }
  });

  it('throws AUTH_UNAUTHORIZED when scheme is not Bearer', () => {
    const { ctx } = makeContext('Basic some-token');
    expect(() => guard.canActivate(ctx)).toThrow(UnauthorizedException);
  });

  it('throws AUTH_UNAUTHORIZED when token is missing after Bearer', () => {
    const { ctx } = makeContext('Bearer ');
    expect(() => guard.canActivate(ctx)).toThrow(UnauthorizedException);
    expect(authService.validateAccessToken).not.toHaveBeenCalled();
  });

  it('propagates UnauthorizedException from AuthService (revoked/expired)', () => {
    authService.validateAccessToken.mockImplementation(() => {
      throw new UnauthorizedException({
        code: 'AUTH_UNAUTHORIZED',
        message: 'Authentication required',
      });
    });
    const { ctx } = makeContext('Bearer revoked-token');
    expect(() => guard.canActivate(ctx)).toThrow(UnauthorizedException);
  });
});
