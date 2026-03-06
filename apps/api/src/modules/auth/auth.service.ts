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
import {
  randomBytes,
  randomUUID,
  scrypt as scryptCallback,
  timingSafeEqual,
} from 'node:crypto';
import { promisify } from 'node:util';
import type {
  AuthSession,
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

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  private readonly usersByEmail = new Map<string, AuthUser>();
  private readonly sessionsByAccessToken = new Map<string, AuthSession>();
  private readonly sessionsByRefreshToken = new Map<string, AuthSession>();
  private readonly rateLimit = new Map<string, RateLimitState>();

  async register(payload: RegisterRequest): Promise<RegisterResponse> {
    this.validateEmail(payload.email);
    this.validatePassword(payload.password);

    if (payload.policyAccepted !== true) {
      throw new BadRequestException({
        code: 'AUTH_POLICY_ACK_REQUIRED',
        message: 'Policy acknowledgement is required before registration',
      });
    }

    const normalizedEmail = payload.email.trim().toLowerCase();
    if (this.usersByEmail.has(normalizedEmail)) {
      throw new ConflictException({
        code: 'AUTH_EMAIL_EXISTS',
        message: 'An account with this email already exists',
      });
    }

    const user: AuthUser = {
      id: randomUUID(),
      email: normalizedEmail,
      passwordHash: await this.hashPassword(payload.password),
      displayName: null,
      createdAt: new Date(),
    };
    this.usersByEmail.set(normalizedEmail, user);

    this.logger.log(`Auth registration success userId=${user.id}`);

    return {
      userId: user.id,
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

    const user = this.usersByEmail.get(payload.email.trim().toLowerCase());
    if (!user) {
      throw new UnauthorizedException({
        code: 'AUTH_INVALID_CREDENTIALS',
        message: 'Invalid credentials',
      });
    }

    const isValidPassword = await this.verifyPassword(
      payload.password,
      user.passwordHash,
    );
    if (!isValidPassword) {
      throw new UnauthorizedException({
        code: 'AUTH_INVALID_CREDENTIALS',
        message: 'Invalid credentials',
      });
    }

    const session = this.createSession(
      user.id,
      ip ?? 'unknown',
      userAgent ?? 'Unknown',
    );
    this.logger.log(
      `Auth login success userId=${user.id} sessionId=${session.sessionId}`,
    );

    return {
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      tokenType: 'Bearer',
      accessTokenExpiresInSec: 15 * 60,
      refreshTokenExpiresInSec: 7 * 24 * 60 * 60,
    };
  }

  logout(accessToken: string): void {
    const session = this.sessionsByAccessToken.get(accessToken);
    if (!session) {
      throw new UnauthorizedException({
        code: 'AUTH_SESSION_NOT_FOUND',
        message: 'Session not found',
      });
    }

    if (session.revokedAt) {
      throw new UnauthorizedException({
        code: 'AUTH_SESSION_REVOKED',
        message: 'Session already revoked',
      });
    }

    // Revoke regardless of expiry — expired tokens must still be explicitly
    // revocable so the associated refresh token is also invalidated.
    session.revokedAt = new Date();
    this.sessionsByAccessToken.set(accessToken, session);
    this.logger.log(
      `Auth logout success userId=${session.userId} sessionId=${session.sessionId}`,
    );
  }

  refresh(refreshToken: string): LoginResponse {
    const session = this.sessionsByRefreshToken.get(refreshToken);
    if (!session) {
      throw new UnauthorizedException({
        code: 'AUTH_SESSION_NOT_FOUND',
        message: 'Session not found',
      });
    }

    if (session.revokedAt) {
      throw new UnauthorizedException({
        code: 'AUTH_SESSION_REVOKED',
        message: 'Session already revoked',
      });
    }

    if (session.refreshExpiresAt <= new Date()) {
      throw new UnauthorizedException({
        code: 'AUTH_SESSION_EXPIRED',
        message: 'Refresh token has expired',
      });
    }

    session.revokedAt = new Date();
    const newSession = this.createSession(session.userId);
    this.logger.log(
      `Auth token refresh userId=${session.userId} newSessionId=${newSession.sessionId}`,
    );

    return {
      accessToken: newSession.accessToken,
      refreshToken: newSession.refreshToken,
      tokenType: 'Bearer',
      accessTokenExpiresInSec: 15 * 60,
      refreshTokenExpiresInSec: 7 * 24 * 60 * 60,
    };
  }

  enforceRateLimit(
    routeKey: string,
    identifier: string,
    maxCount = 10,
    windowMs = 60_000,
  ): void {
    const now = Date.now();
    const key = `${routeKey}:${identifier}`;

    // Purge expired windows to prevent unbounded Map growth
    for (const [k, v] of this.rateLimit) {
      if (v.resetAt <= now) {
        this.rateLimit.delete(k);
      }
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

  findUserByEmail(email: string): AuthUser | undefined {
    return this.usersByEmail.get(email.trim().toLowerCase());
  }

  findUserById(userId: string): AuthUser | undefined {
    for (const user of this.usersByEmail.values()) {
      if (user.id === userId) return user;
    }
    return undefined;
  }

  updateUser(
    userId: string,
    patch: Partial<Pick<AuthUser, 'displayName'>>,
  ): void {
    const user = this.findUserById(userId);
    if (!user)
      throw new NotFoundException({
        code: 'ACCOUNT_NOT_FOUND',
        message: 'User not found',
      });
    if (patch.displayName !== undefined) user.displayName = patch.displayName;
  }

  validateAccessToken(token: string): AuthUser {
    const session = this.sessionsByAccessToken.get(token);
    if (!session) {
      throw new UnauthorizedException({
        code: 'AUTH_UNAUTHORIZED',
        message: 'Authentication required',
      });
    }
    if (session.revokedAt) {
      throw new UnauthorizedException({
        code: 'AUTH_UNAUTHORIZED',
        message: 'Authentication required',
      });
    }
    if (session.accessExpiresAt <= new Date()) {
      throw new UnauthorizedException({
        code: 'AUTH_UNAUTHORIZED',
        message: 'Authentication required',
      });
    }
    const user = this.findUserById(session.userId);
    if (!user) {
      throw new UnauthorizedException({
        code: 'AUTH_UNAUTHORIZED',
        message: 'Authentication required',
      });
    }
    return user;
  }

  getSessionIdForAccessToken(accessToken: string): string | null {
    const session = this.sessionsByAccessToken.get(accessToken);
    if (!session || session.revokedAt || session.accessExpiresAt <= new Date()) {
      return null;
    }
    return session.sessionId;
  }

  getSessions(
    userId: string,
    currentSessionId: string | null,
  ): DeviceSessionSummary[] {
    const now = new Date();
    const summaries: DeviceSessionSummary[] = [];

    for (const session of this.sessionsByAccessToken.values()) {
      if (
        session.userId !== userId ||
        session.revokedAt ||
        session.accessExpiresAt <= now
      ) {
        continue;
      }
      summaries.push({
        sessionId: session.sessionId,
        ip: session.ip ?? 'unknown',
        userAgent: session.userAgent ?? 'Unknown',
        createdAt: session.createdAt.toISOString(),
        isCurrent: session.sessionId === currentSessionId,
      });
    }

    summaries.sort(
      (a, b) =>
        new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime(),
    );
    return summaries;
  }

  revokeSession(
    userId: string,
    sessionId: string,
    correlationId: string,
  ): void {
    let found: AuthSession | undefined;
    for (const session of this.sessionsByAccessToken.values()) {
      if (session.userId === userId && session.sessionId === sessionId) {
        found = session;
        break;
      }
    }
    if (!found) {
      throw new SessionNotFoundException();
    }
    found.revokedAt = new Date();
    this.sessionsByAccessToken.set(found.accessToken, found);
    this.logger.log(
      JSON.stringify({
        action: 'SESSION_REVOKED',
        actorUserId: userId,
        targetSessionId: sessionId,
        correlationId,
      }),
    );
  }

  updatePasswordHash(userId: string, newPasswordHash: string): void {
    for (const user of this.usersByEmail.values()) {
      if (user.id === userId) {
        user.passwordHash = newPasswordHash;
        return;
      }
    }
    throw new NotFoundException({
      code: 'ACCOUNT_NOT_FOUND',
      message: 'User not found',
    });
  }

  revokeAllSessionsForUser(userId: string): void {
    const now = new Date();
    for (const session of this.sessionsByAccessToken.values()) {
      if (session.userId === userId && !session.revokedAt) {
        session.revokedAt = now;
      }
    }
    this.logger.log(`All sessions revoked for userId=${userId}`);
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
    if (!salt || !storedHex) {
      return false;
    }

    const candidate = (await scrypt(password, salt, 64)) as Buffer;
    const stored = Buffer.from(storedHex, 'hex');

    if (candidate.length !== stored.length) {
      return false;
    }

    return timingSafeEqual(candidate, stored);
  }

  private createSession(
    userId: string,
    ip = 'unknown',
    userAgent = 'Unknown',
  ): AuthSession {
    const now = new Date();
    const session: AuthSession = {
      sessionId: randomUUID(),
      userId,
      accessToken: randomBytes(32).toString('hex'),
      refreshToken: randomBytes(48).toString('hex'),
      accessExpiresAt: new Date(now.getTime() + 15 * 60 * 1000),
      refreshExpiresAt: new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000),
      createdAt: now,
      ip,
      userAgent,
    };
    this.sessionsByAccessToken.set(session.accessToken, session);
    this.sessionsByRefreshToken.set(session.refreshToken, session);
    return session;
  }

  private validateEmail(email: string): void {
    if (typeof email !== 'string') {
      throw new BadRequestException({
        code: 'AUTH_EMAIL_INVALID',
        message: 'Email must be a valid email address',
      });
    }

    const normalized = email.trim().toLowerCase();
    const isValid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalized);
    if (!isValid) {
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

    const hasUpper = /[A-Z]/.test(password);
    const hasLower = /[a-z]/.test(password);
    const hasDigit = /\d/.test(password);
    const hasSpecial = /[^A-Za-z0-9]/.test(password);

    if (!hasUpper || !hasLower || !hasDigit || !hasSpecial) {
      throw new BadRequestException({
        code: 'AUTH_PASSWORD_INVALID',
        message:
          'Password must be at least 8 characters long and contain uppercase, lowercase, a digit, and a special character',
      });
    }
  }
}
