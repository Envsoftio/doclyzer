import type { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { AuthService } from './auth.service';
import { UserEntity } from '../../database/entities/user.entity';
import { SessionEntity } from '../../database/entities/session.entity';

function makeRepo(): jest.Mocked<Repository<object>> {
  return {
    findOne: jest.fn(),
    find: jest.fn(),
    save: jest.fn(),
    create: jest.fn((data: unknown) => data),
    delete: jest.fn(),
    update: jest.fn(),
    count: jest.fn(),
  } as unknown as jest.Mocked<Repository<object>>;
}

function makeConfigService(secret = 'test-secret'): ConfigService {
  return { getOrThrow: jest.fn().mockReturnValue(secret) } as unknown as ConfigService;
}

describe('AuthService - password utilities', () => {
  let service: AuthService;

  beforeEach(() => {
    service = new AuthService(
      makeRepo() as unknown as Repository<UserEntity>,
      makeRepo() as unknown as Repository<SessionEntity>,
      makeConfigService(),
    );
  });

  it('hashes passwords and verifies them correctly', async () => {
    const hash = await service.hashPassword('StrongPass123!');
    expect(hash).not.toBe('StrongPass123!');
    await expect(service.verifyPassword('StrongPass123!', hash)).resolves.toBe(true);
    await expect(service.verifyPassword('wrong', hash)).resolves.toBe(false);
  });

  it('validatePasswordStrength throws for weak passwords', () => {
    expect(() => service.validatePasswordStrength('weak')).toThrow();
    expect(() => service.validatePasswordStrength('StrongPass123!')).not.toThrow();
  });
});

describe('AuthService - enforceRateLimit', () => {
  let service: AuthService;

  beforeEach(() => {
    service = new AuthService(
      makeRepo() as unknown as Repository<UserEntity>,
      makeRepo() as unknown as Repository<SessionEntity>,
      makeConfigService(),
    );
  });

  it('allows requests under the limit', () => {
    expect(() => service.enforceRateLimit('register', '1.2.3.4', 3)).not.toThrow();
    expect(() => service.enforceRateLimit('register', '1.2.3.4', 3)).not.toThrow();
    expect(() => service.enforceRateLimit('register', '1.2.3.4', 3)).not.toThrow();
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
      makeConfigService(),
    );
  });

  it('creates a user and returns userId', async () => {
    userRepo.findOne.mockResolvedValue(null);
    const saved = { id: 'uuid-1', email: 'a@b.com', passwordHash: 'h', displayName: null, createdAt: new Date(), updatedAt: new Date() } as UserEntity;
    userRepo.save.mockResolvedValue(saved);

    const result = await service.register({ email: 'a@b.com', password: 'Strong1!' });
    expect(result.userId).toBe('uuid-1');
    expect(result.requiresVerification).toBe(true);
  });

  it('throws ConflictException if email already exists', async () => {
    userRepo.findOne.mockResolvedValue({ id: 'existing' } as UserEntity);
    const { ConflictException } = await import('@nestjs/common');
    await expect(service.register({ email: 'a@b.com', password: 'Strong1!' })).rejects.toThrow(ConflictException);
  });

  it('throws BadRequestException for invalid email', async () => {
    const { BadRequestException } = await import('@nestjs/common');
    await expect(service.register({ email: 'not-an-email', password: 'Strong1!' })).rejects.toThrow(BadRequestException);
  });

  it('throws BadRequestException for weak password', async () => {
    const { BadRequestException } = await import('@nestjs/common');
    await expect(service.register({ email: 'a@b.com', password: 'weak' })).rejects.toThrow(BadRequestException);
  });
});
