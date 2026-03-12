import {
  BadRequestException,
  ConflictException,
  HttpException,
  HttpStatus,
  Injectable,
  Logger,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { createHash, randomBytes, randomUUID } from 'node:crypto';
import * as bcrypt from 'bcryptjs';
import { UserEntity } from '../../database/entities/user.entity';
import { SessionEntity } from '../../database/entities/session.entity';
import {
  type AuthUser,
  type DeviceSessionSummary,
  type LoginRequest,
  type LoginResponse,
  type RegisterRequest,
  type RegisterResponse,
} from './auth.types';
import { SessionNotFoundException } from './exceptions/session-not-found.exception';

const BCRYPT_ROUNDS = 12;
const REFRESH_TTL_DAYS = 30;

interface RateLimitState {
  count: number;
  resetAt: number;
}

interface JwtPayload {
  sub: string;
  sessionId: string;
}

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  // Temporary in-memory limiter for auth endpoints; move to Redis-backed counters later.
  private readonly rateLimit = new Map<string, RateLimitState>();

  private readonly accessTtlSec: number;

  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(SessionEntity)
    private readonly sessionRepo: Repository<SessionEntity>,
    private readonly jwtService: JwtService,
    configService: ConfigService,
  ) {
    const raw = configService.get<string>('JWT_ACCESS_TTL_SECONDS') ?? '900';
    const n = parseInt(raw, 10);
    this.accessTtlSec = Number.isNaN(n) ? 900 : n;
  }

  async register(payload: RegisterRequest): Promise<RegisterResponse> {
    this.validateEmail(payload.email);
    this.validatePassword(payload.password);

    const email = payload.email.trim().toLowerCase();
    const existing = await this.userRepo.findOne({ where: { email } });
    if (existing) {
      throw new ConflictException({
        code: 'AUTH_EMAIL_EXISTS',
        message: 'An account with this email already exists',
      });
    }

    const passwordHash = await this.hashPassword(payload.password);
    const user = this.userRepo.create({
      email,
      passwordHash,
      displayName: null,
    });
    const saved = await this.userRepo.save(user);

    this.logger.log(`Auth registration success userId=${saved.id}`);
    return {
      userId: saved.id,
      requiresVerification: true,
      nextStep: 'verify_then_login',
    };
  }

  async login(
    payload: LoginRequest,
    ip?: string,
    userAgent?: string,
  ): Promise<LoginResponse> {
    this.validateEmail(payload.email);
    this.validatePassword(payload.password);

    const email = payload.email.trim().toLowerCase();
    const user = await this.userRepo.findOne({ where: { email } });
    if (!user) {
      throw new UnauthorizedException({
        code: 'AUTH_INVALID_CREDENTIALS',
        message: 'Invalid credentials',
      });
    }

    const isValid = await this.verifyPassword(
      payload.password,
      user.passwordHash,
    );
    if (!isValid) {
      throw new UnauthorizedException({
        code: 'AUTH_INVALID_CREDENTIALS',
        message: 'Invalid credentials',
      });
    }

    const { accessToken, refreshToken } = await this.createSession(
      user.id,
      ip ?? null,
      userAgent ?? null,
    );

    this.logger.log(`Auth login success userId=${user.id}`);
    return { accessToken, refreshToken, expiresIn: this.accessTtlSec };
  }

  async logout(accessToken: string): Promise<void> {
    const payload = this.jwtService.decode<JwtPayload>(accessToken);
    if (!payload?.sessionId) return;
    await this.sessionRepo.delete({
      id: payload.sessionId,
      userId: payload.sub,
    });
    this.logger.log(`Auth logout sessionId=${payload.sessionId}`);
  }

  async refresh(refreshToken: string): Promise<LoginResponse> {
    const hash = createHash('sha256').update(refreshToken).digest('hex');
    const now = new Date();
    const session = await this.sessionRepo.findOne({
      where: {
        refreshTokenHash: hash,
        expiresAt: MoreThan(now),
      },
    });

    if (!session) {
      throw new UnauthorizedException({
        code: 'AUTH_SESSION_REVOKED',
        message: 'Session has been revoked',
      });
    }

    await this.sessionRepo.delete(session.id);

    const { accessToken, refreshToken: newRefreshToken } =
      await this.createSession(
        session.userId,
        session.ipAddress,
        session.userAgent,
      );

    this.logger.log(`Auth token refresh userId=${session.userId}`);
    return {
      accessToken,
      refreshToken: newRefreshToken,
      expiresIn: this.accessTtlSec,
    };
  }

  async getSessions(
    userId: string,
    currentSessionId: string | null,
  ): Promise<DeviceSessionSummary[]> {
    const now = new Date();
    const sessions = await this.sessionRepo.find({ where: { userId } });

    return sessions
      .filter((s) => s.expiresAt > now)
      .map((s) => ({
        sessionId: s.id,
        ip: s.ipAddress ?? 'unknown',
        userAgent: s.userAgent ?? 'Unknown',
        createdAt: s.createdAt.toISOString(),
        isCurrent: s.id === currentSessionId,
      }))
      .sort(
        (a, b) =>
          new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime(),
      );
  }

  async revokeSession(
    userId: string,
    sessionId: string,
    correlationId: string,
  ): Promise<void> {
    const session = await this.sessionRepo.findOne({
      where: { id: sessionId, userId },
    });
    if (!session) throw new SessionNotFoundException();

    await this.sessionRepo.delete(session.id);
    this.logger.log(
      JSON.stringify({
        action: 'SESSION_REVOKED',
        actorUserId: userId,
        targetSessionId: sessionId,
        correlationId,
      }),
    );
  }

  async findUserByEmail(email: string): Promise<AuthUser | null> {
    const user = await this.userRepo.findOne({
      where: { email: email.trim().toLowerCase() },
    });
    return user ? this.toAuthUser(user) : null;
  }

  async findUserById(userId: string): Promise<AuthUser | null> {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    return user ? this.toAuthUser(user) : null;
  }

  async updateUser(
    userId: string,
    patch: Partial<Pick<AuthUser, 'displayName'>>,
  ): Promise<void> {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException({
        code: 'ACCOUNT_NOT_FOUND',
        message: 'User not found',
      });
    }
    if (patch.displayName !== undefined) user.displayName = patch.displayName;
    await this.userRepo.save(user);
  }

  async updatePasswordHash(
    userId: string,
    newPasswordHash: string,
  ): Promise<void> {
    const result = await this.userRepo.update(userId, {
      passwordHash: newPasswordHash,
    });
    if (!result.affected) {
      throw new NotFoundException({
        code: 'ACCOUNT_NOT_FOUND',
        message: 'User not found',
      });
    }
  }

  async revokeAllSessionsForUser(userId: string): Promise<void> {
    await this.sessionRepo.delete({ userId });
    this.logger.log(`All sessions revoked for userId=${userId}`);
  }

  enforceRateLimit(
    routeKey: string,
    identifier: string,
    maxCount = 10,
    windowMs = 60_000,
  ): void {
    const now = Date.now();
    const key = `${routeKey}:${identifier}`;

    for (const [k, v] of this.rateLimit) {
      if (v.resetAt <= now) this.rateLimit.delete(k);
    }

    const existing = this.rateLimit.get(key);
    if (!existing) {
      this.rateLimit.set(key, { count: 1, resetAt: now + windowMs });
      return;
    }

    if (existing.count >= maxCount) {
      throw new HttpException(
        {
          code: 'AUTH_RATE_LIMITED',
          message: 'Too many authentication attempts. Please try again later.',
        },
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    existing.count += 1;
    this.rateLimit.set(key, existing);
  }

  validatePasswordStrength(password: string): void {
    this.validatePassword(password);
  }

  async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, BCRYPT_ROUNDS);
  }

  async verifyPassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  private async createSession(
    userId: string,
    ipAddress: string | null,
    userAgent: string | null,
  ): Promise<{ accessToken: string; refreshToken: string }> {
    const sessionId = randomUUID();
    const rawRefresh = randomBytes(48).toString('hex');
    const refreshTokenHash = createHash('sha256')
      .update(rawRefresh)
      .digest('hex');
    const expiresAt = new Date(
      Date.now() + REFRESH_TTL_DAYS * 24 * 60 * 60 * 1000,
    );

    const session = this.sessionRepo.create({
      id: sessionId,
      userId,
      refreshTokenHash,
      ipAddress,
      userAgent,
      expiresAt,
    });
    await this.sessionRepo.insert(session);

    const accessToken = this.jwtService.sign({
      sub: userId,
      sessionId,
    });

    return { accessToken, refreshToken: rawRefresh };
  }

  private toAuthUser(user: UserEntity): AuthUser {
    return {
      id: user.id,
      email: user.email,
      passwordHash: user.passwordHash,
      displayName: user.displayName ?? null,
      createdAt: user.createdAt,
    };
  }

  private validateEmail(email: string): void {
    if (typeof email !== 'string') {
      throw new BadRequestException({
        code: 'AUTH_EMAIL_INVALID',
        message: 'Email must be a valid email address',
      });
    }
    const normalized = email.trim().toLowerCase();
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalized)) {
      throw new BadRequestException({
        code: 'AUTH_EMAIL_INVALID',
        message: 'Email must be a valid email address',
      });
    }
  }

  private validatePassword(password: string): void {
    if (typeof password !== 'string' || password.length < 8) {
      throw new BadRequestException({
        code: 'AUTH_PASSWORD_INVALID',
        message:
          'Password must be at least 8 characters long and contain uppercase, lowercase, a digit, and a special character',
      });
    }
    if (
      !/[A-Z]/.test(password) ||
      !/[a-z]/.test(password) ||
      !/\d/.test(password) ||
      !/[^A-Za-z0-9]/.test(password)
    ) {
      throw new BadRequestException({
        code: 'AUTH_PASSWORD_INVALID',
        message:
          'Password must be at least 8 characters long and contain uppercase, lowercase, a digit, and a special character',
      });
    }
  }
}
