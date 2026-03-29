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
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
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
import { BetterAuthService } from './better-auth.service';
import { ProfilesService } from '../profiles/profiles.service';

interface RateLimitState {
  count: number;
  resetAt: number;
}

interface BetterAuthErrorBody {
  code?: string;
  message?: string;
}

interface BetterAuthError extends Error {
  body?: BetterAuthErrorBody;
  statusCode?: number;
}

interface AuthResponseWithHeaders<T> {
  data: T;
  headers: Headers | null;
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
    private readonly betterAuthService: BetterAuthService,
    private readonly profilesService: ProfilesService,
  ) {
    this.accessTtlSec = this.betterAuthService.getSessionExpiresInSeconds();
  }

  async register(payload: RegisterRequest): Promise<RegisterResponse> {
    this.validateEmail(payload.email);
    this.validatePassword(payload.password);

    const email = payload.email.trim().toLowerCase();
    const displayName = this.deriveDisplayName(email);
    const auth = await this.betterAuthService.getAuth();

    try {
      const response = await auth.api.signUpEmail({
        body: {
          email,
          password: payload.password,
          name: displayName,
        },
      });

      const userId = response?.user?.id;
      if (!userId) {
        throw new HttpException(
          {
            code: 'AUTH_REGISTRATION_FAILED',
            message: 'Unable to register at this time',
          },
          HttpStatus.INTERNAL_SERVER_ERROR,
        );
      }

      await this.createDefaultProfile(userId, displayName);
      this.logger.log(`Auth registration success userId=${userId}`);
      return {
        userId,
        requiresVerification: true,
        nextStep: 'verify_then_login',
      };
    } catch (error: unknown) {
      this.throwMappedAuthError(error, {
        status: HttpStatus.INTERNAL_SERVER_ERROR,
        code: 'AUTH_REGISTRATION_FAILED',
        message: 'Unable to register at this time',
      });
    }
  }

  private async createDefaultProfile(
    userId: string,
    displayName: string,
  ): Promise<void> {
    try {
      await this.profilesService.createProfile(userId, {
        name: displayName,
      });
    } catch (error: unknown) {
      this.logger.error(
        `Failed to create default profile for userId=${userId}`,
        error instanceof Error ? error.stack : String(error),
      );
      throw new HttpException(
        {
          code: 'PROFILE_CREATION_FAILED',
          message: 'Unable to create a default profile for your account.',
        },
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  async login(
    payload: LoginRequest,
    headers: Headers,
  ): Promise<AuthResponseWithHeaders<LoginResponse>> {
    this.validateEmail(payload.email);
    this.validatePassword(payload.password);

    const email = payload.email.trim().toLowerCase();
    const auth = await this.betterAuthService.getAuth();

    try {
      const result = await auth.api.signInEmail({
        body: {
          email,
          password: payload.password,
        },
        headers,
        returnHeaders: true,
      });

      const token = result?.response?.token;
      const userId = result?.response?.user?.id ?? 'unknown';
      if (!token) {
        throw new UnauthorizedException({
          code: 'AUTH_INVALID_CREDENTIALS',
          message: 'Invalid credentials',
        });
      }

      this.logger.log(`Auth login success userId=${userId}`);
      return {
        data: {
          accessToken: token,
          refreshToken: token,
          expiresIn: this.accessTtlSec,
        },
        headers: result?.headers ?? null,
      };
    } catch (error: unknown) {
      this.throwMappedAuthError(error, {
        status: HttpStatus.UNAUTHORIZED,
        code: 'AUTH_INVALID_CREDENTIALS',
        message: 'Invalid credentials',
      });
    }
  }

  async logout(headers: Headers): Promise<Headers | null> {
    const auth = await this.betterAuthService.getAuth();
    try {
      const result = await auth.api.signOut({ headers, returnHeaders: true });
      this.logger.log('Auth logout success');
      return result?.headers ?? null;
    } catch (error: unknown) {
      this.throwMappedAuthError(error, {
        status: HttpStatus.UNAUTHORIZED,
        code: 'AUTH_UNAUTHORIZED',
        message: 'Authentication required',
      });
    }
  }

  async refresh(
    refreshToken: string,
    headers: Headers,
  ): Promise<AuthResponseWithHeaders<LoginResponse>> {
    const auth = await this.betterAuthService.getAuth();

    try {
      const result = await auth.api.getSession({
        method: 'POST',
        headers,
        returnHeaders: true,
      });

      const session = result?.response?.session;
      const user = result?.response?.user;
      if (!session || !user) {
        throw new UnauthorizedException({
          code: 'AUTH_SESSION_REVOKED',
          message: 'Session has been revoked',
        });
      }

      const token = session.token || refreshToken;
      this.logger.log(`Auth token refresh userId=${user.id}`);
      return {
        data: {
          accessToken: token,
          refreshToken: token,
          expiresIn: this.accessTtlSec,
        },
        headers: result?.headers ?? null,
      };
    } catch (error: unknown) {
      this.throwMappedAuthError(error, {
        status: HttpStatus.UNAUTHORIZED,
        code: 'AUTH_SESSION_REVOKED',
        message: 'Session has been revoked',
      });
    }
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

  private toAuthUser(user: UserEntity): AuthUser {
    return {
      id: user.id,
      email: user.email,
      passwordHash: user.passwordHash ?? null,
      displayName: user.displayName ?? null,
      createdAt: user.createdAt,
    };
  }

  private deriveDisplayName(email: string): string {
    const localPart = email.split('@')[0]?.trim();
    return localPart && localPart.length > 0 ? localPart : 'User';
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

  private getBetterAuthErrorCode(error: unknown): string | null {
    if (!error || typeof error !== 'object') return null;
    const err = error as BetterAuthError;
    if (!err.body || typeof err.body !== 'object') return null;
    return err.body.code ?? null;
  }

  private throwMappedAuthError(
    error: unknown,
    fallback: { status: HttpStatus; code: string; message: string },
  ): never {
    if (error instanceof HttpException) throw error;

    const code = this.getBetterAuthErrorCode(error);
    if (code) {
      switch (code) {
        case 'INVALID_EMAIL':
          throw new BadRequestException({
            code: 'AUTH_EMAIL_INVALID',
            message: 'Email must be a valid email address',
          });
        case 'INVALID_PASSWORD':
        case 'PASSWORD_TOO_SHORT':
        case 'PASSWORD_TOO_LONG':
          throw new BadRequestException({
            code: 'AUTH_PASSWORD_INVALID',
            message:
              'Password must be at least 8 characters long and contain uppercase, lowercase, a digit, and a special character',
          });
        case 'INVALID_EMAIL_OR_PASSWORD':
          throw new UnauthorizedException({
            code: 'AUTH_INVALID_CREDENTIALS',
            message: 'Invalid credentials',
          });
        case 'USER_ALREADY_EXISTS':
        case 'USER_ALREADY_EXISTS_USE_ANOTHER_EMAIL':
          throw new ConflictException({
            code: 'AUTH_EMAIL_EXISTS',
            message: 'An account with this email already exists',
          });
        case 'SESSION_EXPIRED':
        case 'INVALID_TOKEN':
          throw new UnauthorizedException({
            code: 'AUTH_SESSION_REVOKED',
            message: 'Session has been revoked',
          });
        case 'EMAIL_NOT_VERIFIED':
          throw new UnauthorizedException({
            code: 'AUTH_UNAUTHORIZED',
            message: 'Authentication required',
          });
        default:
          break;
      }
    }

    throw new HttpException(
      { code: fallback.code, message: fallback.message },
      fallback.status,
    );
  }
}
