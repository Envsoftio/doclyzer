import { createHash } from 'node:crypto';
import {
  BadRequestException,
  ConflictException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { Repository } from 'typeorm';
import type { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { AuthService } from './auth.service';
import { UserEntity } from '../../database/entities/user.entity';
import { SessionEntity } from '../../database/entities/session.entity';

function makeRepo(): jest.Mocked<Repository<object>> {
  return {
    findOne: jest.fn(),
    find: jest.fn(),
    save: jest.fn(),
    insert: jest.fn(),
    create: jest.fn((data: unknown) => data),
    delete: jest.fn(),
    update: jest.fn(),
    count: jest.fn(),
  } as unknown as jest.Mocked<Repository<object>>;
}

function makeJwtService(): jest.Mocked<JwtService> {
  return {
    sign: jest.fn().mockReturnValue('mock-access-token'),
    decode: jest.fn().mockReturnValue(null),
    verify: jest.fn(),
  } as unknown as jest.Mocked<JwtService>;
}

function makeConfigService(expiresIn = 900): ConfigService {
  return {
    get: jest.fn().mockImplementation((key: string) => {
      if (key === 'JWT_ACCESS_TTL_SECONDS') return expiresIn;
      return undefined;
    }),
  } as unknown as ConfigService;
}

describe('AuthService - password utilities', () => {
  let service: AuthService;

  beforeEach(() => {
    service = new AuthService(
      makeRepo() as unknown as Repository<UserEntity>,
      makeRepo() as unknown as Repository<SessionEntity>,
      makeJwtService(),
      makeConfigService(),
    );
  });

  it('hashes passwords with bcrypt and verifies them correctly', async () => {
    const hash = await service.hashPassword('StrongPass123!');
    expect(hash).not.toBe('StrongPass123!');
    expect(hash).toMatch(/^\$2[ab]\$12\$/); // bcrypt with cost 12
    await expect(service.verifyPassword('StrongPass123!', hash)).resolves.toBe(
      true,
    );
    await expect(service.verifyPassword('wrong', hash)).resolves.toBe(false);
  }, 15000);

  it('validatePasswordStrength throws for weak passwords', () => {
    expect(() => service.validatePasswordStrength('weak')).toThrow();
    expect(() =>
      service.validatePasswordStrength('StrongPass123!'),
    ).not.toThrow();
  });
});

describe('AuthService - enforceRateLimit', () => {
  let service: AuthService;

  beforeEach(() => {
    service = new AuthService(
      makeRepo() as unknown as Repository<UserEntity>,
      makeRepo() as unknown as Repository<SessionEntity>,
      makeJwtService(),
      makeConfigService(),
    );
  });

  it('allows requests under the limit', () => {
    expect(() =>
      service.enforceRateLimit('register', '1.2.3.4', 3),
    ).not.toThrow();
    expect(() =>
      service.enforceRateLimit('register', '1.2.3.4', 3),
    ).not.toThrow();
    expect(() =>
      service.enforceRateLimit('register', '1.2.3.4', 3),
    ).not.toThrow();
  });

  it('throws after exceeding the limit', () => {
    service.enforceRateLimit('login', '1.2.3.4', 2);
    service.enforceRateLimit('login', '1.2.3.4', 2);
    expect(() => service.enforceRateLimit('login', '1.2.3.4', 2)).toThrow();
  });
});

describe('AuthService - register', () => {
  let service: AuthService;
  let userRepo: ReturnType<typeof makeRepo>;
  let sessionRepo: ReturnType<typeof makeRepo>;

  beforeEach(() => {
    userRepo = makeRepo();
    sessionRepo = makeRepo();
    service = new AuthService(
      userRepo as unknown as Repository<UserEntity>,
      sessionRepo as unknown as Repository<SessionEntity>,
      makeJwtService(),
      makeConfigService(),
    );
  });

  it('creates a user and returns userId', async () => {
    userRepo.findOne.mockResolvedValue(null);
    const saved = {
      id: 'uuid-1',
      email: 'a@b.com',
      passwordHash: 'h',
      displayName: null,
      createdAt: new Date(),
      updatedAt: new Date(),
    } as UserEntity;
    userRepo.save.mockResolvedValue(saved);

    const result = await service.register({
      email: 'a@b.com',
      password: 'Strong1!',
    });
    expect(result.userId).toBe('uuid-1');
    expect(result.requiresVerification).toBe(true);
  }, 15000);

  it('throws ConflictException if email already exists', async () => {
    userRepo.findOne.mockResolvedValue({ id: 'existing' } as UserEntity);
    await expect(
      service.register({ email: 'a@b.com', password: 'Strong1!' }),
    ).rejects.toThrow(ConflictException);
  });

  it('throws BadRequestException for invalid email', async () => {
    await expect(
      service.register({ email: 'not-an-email', password: 'Strong1!' }),
    ).rejects.toThrow(BadRequestException);
  });

  it('throws BadRequestException for weak password', async () => {
    await expect(
      service.register({ email: 'a@b.com', password: 'weak' }),
    ).rejects.toThrow(BadRequestException);
  });
});

describe('AuthService - login', () => {
  let service: AuthService;
  let userRepo: ReturnType<typeof makeRepo>;
  let sessionRepo: ReturnType<typeof makeRepo>;
  let jwtService: jest.Mocked<JwtService>;

  beforeEach(() => {
    userRepo = makeRepo();
    sessionRepo = makeRepo();
    jwtService = makeJwtService();
    service = new AuthService(
      userRepo as unknown as Repository<UserEntity>,
      sessionRepo as unknown as Repository<SessionEntity>,
      jwtService,
      makeConfigService(),
    );
  });

  it('returns accessToken, refreshToken, and expiresIn on success', async () => {
    const hash = await bcrypt.hash('StrongPass123!', 4);
    const user = {
      id: 'user-1',
      email: 'a@b.com',
      passwordHash: hash,
    } as UserEntity;
    userRepo.findOne.mockResolvedValue(user);
    sessionRepo.insert.mockResolvedValue({} as never);

    const result = await service.login({
      email: 'a@b.com',
      password: 'StrongPass123!',
    });
    expect(result.accessToken).toBe('mock-access-token');
    expect(result.refreshToken).toBeTruthy();
    expect(result.expiresIn).toBe(900);
  }, 15000);

  it('throws UnauthorizedException for wrong password', async () => {
    const hash = await bcrypt.hash('CorrectPass1!', 4);
    const user = {
      id: 'user-1',
      email: 'a@b.com',
      passwordHash: hash,
    } as UserEntity;
    userRepo.findOne.mockResolvedValue(user);

    await expect(
      service.login({ email: 'a@b.com', password: 'WrongPass1!' }),
    ).rejects.toThrow(UnauthorizedException);
  }, 15000);

  it('throws UnauthorizedException for unknown email', async () => {
    userRepo.findOne.mockResolvedValue(null);
    await expect(
      service.login({ email: 'unknown@b.com', password: 'StrongPass123!' }),
    ).rejects.toThrow(UnauthorizedException);
  });
});

describe('AuthService - refresh', () => {
  let service: AuthService;
  let sessionRepo: ReturnType<typeof makeRepo>;

  beforeEach(() => {
    sessionRepo = makeRepo();
    service = new AuthService(
      makeRepo() as unknown as Repository<UserEntity>,
      sessionRepo as unknown as Repository<SessionEntity>,
      makeJwtService(),
      makeConfigService(),
    );
  });

  it('rotates session and returns new tokens', async () => {
    const rawToken = 'some-raw-refresh-token';
    const hash = createHash('sha256').update(rawToken).digest('hex');
    const session = {
      id: 'session-1',
      userId: 'user-1',
      refreshTokenHash: hash,
      expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      ipAddress: '1.2.3.4',
      userAgent: 'test',
    } as SessionEntity;
    sessionRepo.findOne.mockResolvedValue(session);
    sessionRepo.insert.mockResolvedValue({} as never);

    const result = await service.refresh(rawToken);
    expect(result.accessToken).toBe('mock-access-token');
    expect(result.expiresIn).toBe(900);
    // eslint-disable-next-line @typescript-eslint/unbound-method
    expect(sessionRepo.delete).toHaveBeenCalledWith(session.id);
  });

  it('throws INVALID_REFRESH_TOKEN when session not found', async () => {
    sessionRepo.findOne.mockResolvedValue(null);
    await expect(service.refresh('bad-token')).rejects.toThrow(
      UnauthorizedException,
    );
  });

  it('throws INVALID_REFRESH_TOKEN for expired session', async () => {
    const rawToken = 'expired-token';
    sessionRepo.findOne.mockResolvedValue(null); // query-level expiry: expired rows not returned

    await expect(service.refresh(rawToken)).rejects.toThrow(
      UnauthorizedException,
    );
  });
});
