import {
  BadRequestException,
  ConflictException,
  HttpException,
  HttpStatus,
  Injectable,
  Logger,
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
  LoginRequest,
  LoginResponse,
  RegisterRequest,
  RegisterResponse,
} from './auth.types';

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
  private readonly rateLimit = new Map<string, RateLimitState>();

  async register(payload: RegisterRequest): Promise<RegisterResponse> {
    this.validateEmail(payload.email);
    this.validatePassword(payload.password);

    if (!payload.policyAccepted) {
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

  async login(payload: LoginRequest): Promise<LoginResponse> {
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

    const session = this.createSession(user.id);
    this.sessionsByAccessToken.set(session.accessToken, session);
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

  async logout(accessToken: string): Promise<void> {
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

    session.revokedAt = new Date();
    this.sessionsByAccessToken.set(accessToken, session);
    this.logger.log(
      `Auth logout success userId=${session.userId} sessionId=${session.sessionId}`,
    );
    await Promise.resolve();
  }

  enforceRateLimit(
    routeKey: string,
    identifier: string,
    maxCount = 10,
    windowMs = 60_000,
  ): void {
    const now = Date.now();
    const key = `${routeKey}:${identifier}`;
    const existing = this.rateLimit.get(key);

    if (!existing || existing.resetAt <= now) {
      this.rateLimit.set(key, {
        count: 1,
        resetAt: now + windowMs,
      });
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

  private createSession(userId: string): AuthSession {
    const now = new Date();
    return {
      sessionId: randomUUID(),
      userId,
      accessToken: randomBytes(32).toString('hex'),
      refreshToken: randomBytes(48).toString('hex'),
      accessExpiresAt: new Date(now.getTime() + 15 * 60 * 1000),
      refreshExpiresAt: new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000),
      createdAt: now,
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
        message: 'Password must be at least 8 characters long',
      });
    }
  }
}
