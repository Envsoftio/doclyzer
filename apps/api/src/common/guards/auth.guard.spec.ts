import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import type { JwtService } from '@nestjs/jwt';
import { AuthGuard } from './auth.guard';

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

function makeJwtService(overrides: Partial<JwtService> = {}): JwtService {
  return {
    verify: jest.fn(),
    sign: jest.fn(),
    decode: jest.fn(),
    ...overrides,
  } as unknown as JwtService;
}

describe('AuthGuard', () => {
  it('passes and attaches user and currentSessionId for a valid Bearer token', () => {
    const jwtService = makeJwtService({
      verify: jest
        .fn()
        .mockReturnValue({ sub: 'user-1', sessionId: 'session-1' }),
    });
    const guard = new AuthGuard(jwtService);
    const { ctx, req } = makeContext('Bearer valid-token');

    const result = guard.canActivate(ctx);
    expect(result).toBe(true);
    expect(req['user']).toEqual({ id: 'user-1' });
    expect(req['currentSessionId']).toBe('session-1');
  });

  it('throws AUTH_UNAUTHORIZED when Authorization header is missing', () => {
    const guard = new AuthGuard(makeJwtService());
    const { ctx } = makeContext(undefined);
    expect(() => guard.canActivate(ctx)).toThrow(UnauthorizedException);
  });

  it('throws AUTH_UNAUTHORIZED when scheme is not Bearer', () => {
    const guard = new AuthGuard(makeJwtService());
    const { ctx } = makeContext('Basic some-token');
    expect(() => guard.canActivate(ctx)).toThrow(UnauthorizedException);
  });

  it('throws AUTH_UNAUTHORIZED when token is missing after Bearer', () => {
    const jwtService = makeJwtService({ verify: jest.fn() });
    const guard = new AuthGuard(jwtService);
    const { ctx } = makeContext('Bearer ');
    expect(() => guard.canActivate(ctx)).toThrow(UnauthorizedException);
    // eslint-disable-next-line @typescript-eslint/unbound-method
    expect(jwtService.verify).not.toHaveBeenCalled();
  });

  it('throws AUTH_UNAUTHORIZED when JwtService.verify throws (expired/invalid token)', () => {
    const jwtService = makeJwtService({
      verify: jest.fn().mockImplementation(() => {
        throw new Error('jwt expired');
      }),
    });
    const guard = new AuthGuard(jwtService);
    const { ctx } = makeContext('Bearer expired-token');
    expect(() => guard.canActivate(ctx)).toThrow(UnauthorizedException);
  });
});
