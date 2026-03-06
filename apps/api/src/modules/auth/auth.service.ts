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
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  createHash,
  createHmac,
  randomBytes,
  scrypt as scryptCallback,
  timingSafeEqual,
} from 'node:crypto';
import { promisify } from 'node:util';
import { UserEntity } from '../../database/entities/user.entity';
import { SessionEntity } from '../../database/entities/session.entity';
import type {
  AuthUser,
  DeviceSessionSummary,
  LoginRequest,
  LoginResponse,
  RegisterRequest,
  RegisterResponse,
} from './auth.types';
import { SessionNotFoundException } from './exceptions/session-not-found.exception';

const scrypt = promisify(scryptCallback);

interface RateLimitState {
  count: number;
  resetAt: number;
}

interface JwtPayload {
  sub: string;
  sid: string;
  iat: number;
  exp: number;
}

function b64url(buf: Buffer): string {
  return buf.toString('base64').replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');
}

function b64urlDecode(s: string): string {
  const pad = s.length % 4 === 0 ? '' : '='.repeat(4 - (s.length % 4));
  return Buffer.from(s + pad, 'base64').toString('utf8');
}

function signJwt(payload: object, secret: string): string {
  const hdr = b64url(Buffer.from('{"alg":"HS256","typ":"JWT"}'));
  const bdy = b64url(Buffer.from(JSON.stringify(payload)));
  const sig = b64url(createHmac('sha256', secret).update(`${hdr}.${bdy}`).digest());
  return `${hdr}.${bdy}.${sig}`;
}

function verifyJwt(token: string, secret: string): JwtPayload | null {
  const parts = token.split('.');
  if (parts.length !== 3) return null;
  const [hdr, bdy, sig] = parts;
  const expected = b64url(createHmac('sha256', secret).update(`${hdr}.${bdy}`).digest());
  const sigBuf = Buffer.from(sig, 'utf8');
  const expectedBuf = Buffer.from(expected, 'utf8');
  if (sigBuf.length !== expectedBuf.length) return null;
  if (!timingSafeEqual(sigBuf, expectedBuf)) return null;
  try {
    return JSON.parse(b64urlDecode(bdy)) as JwtPayload;
  } catch {
    return null;
  }
}

function decodeJwtUnsafe(token: string): JwtPayload | null {
  const parts = token.split('.');
  if (parts.length !== 3) return null;
  try {
    return JSON.parse(b64urlDecode(parts[1])) as JwtPayload;
  } catch {
    return null;
  }
}

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  private readonly rateLimit = new Map<string, RateLimitState>();
  private readonly jwtSecret: string;

  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(SessionEntity)
    private readonly sessionRepo: Repository<SessionEntity>,
    private readonly configService: ConfigService,
  ) {
    this.jwtSecret = this.configService.getOrThrow<string>('JWT_ACCESS_SECRET');
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
    const user = this.userRepo.create({ email, passwordHash, displayName: null });
    const saved = await this.userRepo.save(user);

    this.logger.log(`Auth registration success userId=${saved.id}`);
    return { userId: saved.id, requiresVerification: true, nextStep: 'verify_then_login' };
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

    const isValid = await this.verifyPassword(payload.password, user.passwordHash);
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
    return {
      accessToken,
      refreshToken,
      tokenType: 'Bearer',
      accessTokenExpiresInSec: 15 * 60,
      refreshTokenExpiresInSec: 7 * 24 * 60 * 60,
    };
  }

  async logout(accessToken: string): Promise<void> {
    const payload = decodeJwtUnsafe(accessToken);
    if (!payload?.sid) return;
    await this.sessionRepo.delete({ id: payload.sid, userId: payload.sub });
    this.logger.log(`Auth logout sessionId=${payload.sid}`);
  }

  async refresh(refreshToken: string): Promise<LoginResponse> {
    const hash = createHash('sha256').update(refreshToken).digest('hex');
    const session = await this.sessionRepo.findOne({ where: { refreshTokenHash: hash } });

    if (!session) {
      throw new UnauthorizedException({
        code: 'AUTH_SESSION_NOT_FOUND',
        message: 'Session not found',
      });
    }

    if (session.expiresAt <= new Date()) {
      await this.sessionRepo.delete(session.id);
      throw new UnauthorizedException({
        code: 'AUTH_SESSION_EXPIRED',
        message: 'Refresh token has expired',
      });
    }

    await this.sessionRepo.delete(session.id);

    const { accessToken, refreshToken: newRefreshToken } = await this.createSession(
      session.userId,
      session.ipAddress,
      session.userAgent,
    );

    this.logger.log(`Auth token refresh userId=${session.userId}`);
    return {
      accessToken,
      refreshToken: newRefreshToken,
      tokenType: 'Bearer',
      accessTokenExpiresInSec: 15 * 60,
      refreshTokenExpiresInSec: 7 * 24 * 60 * 60,
    };
  }

  async validateAccessToken(token: string): Promise<AuthUser> {
    const payload = verifyJwt(token, this.jwtSecret);
    if (!payload) {
      throw new UnauthorizedException({
        code: 'AUTH_UNAUTHORIZED',
        message: 'Authentication required',
      });
    }

    if (payload.exp * 1000 <= Date.now()) {
      throw new UnauthorizedException({
        code: 'AUTH_UNAUTHORIZED',
        message: 'Authentication required',
      });
    }

    const session = await this.sessionRepo.findOne({
      where: { id: payload.sid, userId: payload.sub },
    });
    if (!session) {
      throw new UnauthorizedException({
        code: 'AUTH_UNAUTHORIZED',
        message: 'Authentication required',
      });
    }

    const user = await this.userRepo.findOne({ where: { id: payload.sub } });
    if (!user) {
      throw new UnauthorizedException({
        code: 'AUTH_UNAUTHORIZED',
        message: 'Authentication required',
      });
    }

    return this.toAuthUser(user);
  }

  getSessionIdForAccessToken(token: string): string | null {
    const payload = decodeJwtUnsafe(token);
    if (!payload) return null;
    if (payload.exp * 1000 <= Date.now()) return null;
    return payload.sid ?? null;
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
      .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
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

  async updatePasswordHash(userId: string, newPasswordHash: string): Promise<void> {
    const result = await this.userRepo.update(userId, { passwordHash: newPasswordHash });
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
    const salt = randomBytes(16).toString('hex');
    const derived = (await scrypt(password, salt, 64)) as Buffer;
    return `${salt}:${derived.toString('hex')}`;
  }

  async verifyPassword(password: string, hash: string): Promise<boolean> {
    const [salt, storedHex] = hash.split(':');
    if (!salt || !storedHex) return false;
    const candidate = (await scrypt(password, salt, 64)) as Buffer;
    const stored = Buffer.from(storedHex, 'hex');
    if (candidate.length !== stored.length) return false;
    return timingSafeEqual(candidate, stored);
  }

  private async createSession(
    userId: string,
    ipAddress: string | null,
    userAgent: string | null,
  ): Promise<{ accessToken: string; refreshToken: string }> {
    const rawRefresh = randomBytes(48).toString('hex');
    const refreshTokenHash = createHash('sha256').update(rawRefresh).digest('hex');
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

    const session = this.sessionRepo.create({
      userId,
      refreshTokenHash,
      ipAddress,
      userAgent,
      expiresAt,
    });
    const saved = await this.sessionRepo.save(session);

    const now = Math.floor(Date.now() / 1000);
    const accessToken = signJwt(
      { sub: userId, sid: saved.id, iat: now, exp: now + 15 * 60 },
      this.jwtSecret,
    );

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
