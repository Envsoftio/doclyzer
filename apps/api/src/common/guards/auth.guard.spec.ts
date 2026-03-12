import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import type { JwtService } from '@nestjs/jwt';
import type { Repository } from 'typeorm';
import type { SessionEntity } from '../../database/entities/session.entity';
import { AuthGuard } from './auth.guard';

function makeContext(
  authHeader?: string,
  handlerName?: string,
): {
  ctx: ExecutionContext;
  req: Record<string, unknown>;
} {
  const req: Record<string, unknown> = {
    header: (name: string) =>
      name.toLowerCase() === 'authorization' ? authHeader : undefined,
  };
  const ctx = {
    switchToHttp: () => ({ getRequest: () => req }),
    getHandler: () => {
      if (handlerName === 'logout') return function logout() {};
      return function handler() {};
    },
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
  function makeSessionRepo(
    overrides: Partial<Record<keyof Repository<SessionEntity>, jest.Mock>> = {},
  ): Repository<SessionEntity> {
    return {
      findOne: jest.fn().mockResolvedValue(null),
      ...overrides,
    } as unknown as Repository<SessionEntity>;
  }

  it('passes and attaches user and currentSessionId for a valid Bearer token', async () => {
    const jwtService = makeJwtService({
      verify: jest
        .fn()
        .mockReturnValue({ sub: 'user-1', sessionId: 'session-1' }),
    });
    const sessionRepo = makeSessionRepo({
      findOne: jest.fn().mockResolvedValue({
        userId: 'user-1',
        expiresAt: new Date(Date.now() + 60_000),
      }),
    });
    const guard = new AuthGuard(jwtService, sessionRepo);
    const { ctx, req } = makeContext('Bearer valid-token');

    const result = await guard.canActivate(ctx);
    expect(result).toBe(true);
    expect(req['user']).toEqual({ id: 'user-1' });
    expect(req['currentSessionId']).toBe('session-1');
  });

  it('throws AUTH_UNAUTHORIZED when Authorization header is missing', async () => {
    const guard = new AuthGuard(makeJwtService(), makeSessionRepo());
    const { ctx } = makeContext(undefined);
    await expect(guard.canActivate(ctx)).rejects.toThrow(UnauthorizedException);
  });

  it('throws AUTH_UNAUTHORIZED when scheme is not Bearer', async () => {
    const guard = new AuthGuard(makeJwtService(), makeSessionRepo());
    const { ctx } = makeContext('Basic some-token');
    await expect(guard.canActivate(ctx)).rejects.toThrow(UnauthorizedException);
  });

  it('throws AUTH_UNAUTHORIZED when token is missing after Bearer', async () => {
    const jwtService = makeJwtService({ verify: jest.fn() });
    const guard = new AuthGuard(jwtService, makeSessionRepo());
    const { ctx } = makeContext('Bearer ');
    await expect(guard.canActivate(ctx)).rejects.toThrow(UnauthorizedException);
    // eslint-disable-next-line @typescript-eslint/unbound-method
    expect(jwtService.verify).not.toHaveBeenCalled();
  });

  it('throws AUTH_UNAUTHORIZED when JwtService.verify throws (expired/invalid token)', async () => {
    const jwtService = makeJwtService({
      verify: jest.fn().mockImplementation(() => {
        throw new Error('jwt expired');
      }),
    });
    const guard = new AuthGuard(jwtService, makeSessionRepo());
    const { ctx } = makeContext('Bearer expired-token');
    await expect(guard.canActivate(ctx)).rejects.toThrow(UnauthorizedException);
  });

  it('throws AUTH_UNAUTHORIZED when session does not exist', async () => {
    const jwtService = makeJwtService({
      verify: jest
        .fn()
        .mockReturnValue({ sub: 'user-1', sessionId: 'session-1' }),
    });
    const sessionRepo = makeSessionRepo({
      findOne: jest.fn().mockResolvedValue(null),
    });
    const guard = new AuthGuard(jwtService, sessionRepo);
    const { ctx } = makeContext('Bearer valid-token');

    await expect(guard.canActivate(ctx)).rejects.toMatchObject({
      response: { code: 'AUTH_UNAUTHORIZED' },
    });
  });

  it('throws AUTH_SESSION_REVOKED for logout when session does not exist', async () => {
    const jwtService = makeJwtService({
      verify: jest
        .fn()
        .mockReturnValue({ sub: 'user-1', sessionId: 'session-1' }),
    });
    const sessionRepo = makeSessionRepo({
      findOne: jest.fn().mockResolvedValue(null),
    });
    const guard = new AuthGuard(jwtService, sessionRepo);
    const { ctx } = makeContext('Bearer valid-token', 'logout');

    await expect(guard.canActivate(ctx)).rejects.toMatchObject({
      response: { code: 'AUTH_SESSION_REVOKED' },
    });
  });
});
