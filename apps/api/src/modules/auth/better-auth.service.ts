import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { Request } from 'express';
import { NotificationService } from '../../common/notification/notification.service';
import type { BetterAuthOptions } from 'better-auth';
import type { Pool } from 'pg';

const DEFAULT_SESSION_EXPIRES_IN_SECONDS = 60 * 60 * 24 * 30; // 30 days
const DEFAULT_SESSION_UPDATE_AGE_SECONDS = 60 * 60 * 24; // 1 day

export type BetterAuthInstance = ReturnType<
  typeof import('better-auth').betterAuth
>;

@Injectable()
export class BetterAuthService {
  private readonly logger = new Logger(BetterAuthService.name);
  private authPromise: Promise<BetterAuthInstance> | null = null;
  private readonly sessionExpiresInSeconds: number;
  private readonly sessionUpdateAgeSeconds: number;
  private readonly basePath: string;

  constructor(
    private readonly configService: ConfigService,
    private readonly notificationService: NotificationService,
  ) {
    this.sessionExpiresInSeconds = this.parseNumber(
      this.configService.get<string>('BETTER_AUTH_SESSION_EXPIRES_IN_SECONDS'),
      DEFAULT_SESSION_EXPIRES_IN_SECONDS,
    );
    this.sessionUpdateAgeSeconds = this.parseNumber(
      this.configService.get<string>('BETTER_AUTH_SESSION_UPDATE_AGE_SECONDS'),
      DEFAULT_SESSION_UPDATE_AGE_SECONDS,
    );
    this.basePath =
      this.configService.get<string>('BETTER_AUTH_BASE_PATH') ?? '/v1/auth';
  }

  getSessionExpiresInSeconds(): number {
    return this.sessionExpiresInSeconds;
  }

  async getAuth(): Promise<BetterAuthInstance> {
    if (!this.authPromise) {
      this.authPromise = this.createAuthInstance();
    }
    return this.authPromise;
  }

  buildHeadersFromRequest(req: Request): Headers {
    const headers = new Headers();
    for (const [key, value] of Object.entries(req.headers)) {
      if (value === undefined) continue;
      if (Array.isArray(value)) {
        headers.set(key, value.join(','));
      } else {
        headers.set(key, value);
      }
    }
    return headers;
  }

  buildHeadersWithBearer(token: string): Headers {
    const headers = new Headers();
    headers.set('authorization', `Bearer ${token}`);
    return headers;
  }

  extractSetCookie(headers: Headers): string[] {
    const headerBag = headers as Headers & { getSetCookie?: () => string[] };
    if (typeof headerBag.getSetCookie === 'function') {
      return headerBag.getSetCookie();
    }
    const value = headers.get('set-cookie');
    return value ? [value] : [];
  }

  private async createAuthInstance(): Promise<BetterAuthInstance> {
    const [{ betterAuth }, { Pool: PgPool }, { bearer }] =
      await Promise.all([
        import('better-auth'),
        import('pg'),
        import('better-auth/plugins'),
      ]);

    const databaseUrl = this.configService.getOrThrow<string>('DATABASE_URL');
    const baseURL = this.configService.getOrThrow<string>('BETTER_AUTH_URL');
    const secret = this.configService.getOrThrow<string>('BETTER_AUTH_SECRET');

    const pool: Pool = new PgPool({
      connectionString: databaseUrl,
    });

    const options: BetterAuthOptions = {
      appName: 'doclyzer',
      baseURL,
      basePath: this.basePath,
      secret,
      logger: { disabled: true },
      database: pool,
      user: {
        modelName: 'users',
        fields: {
          email: 'email',
          name: 'display_name',
          emailVerified: 'email_verified',
          image: 'avatar_url',
          createdAt: 'created_at',
          updatedAt: 'updated_at',
        },
      },
      session: {
        modelName: 'sessions',
        fields: {
          userId: 'user_id',
          token: 'token',
          expiresAt: 'expires_at',
          ipAddress: 'ip_address',
          userAgent: 'user_agent',
          createdAt: 'created_at',
          updatedAt: 'updated_at',
        },
        expiresIn: this.sessionExpiresInSeconds,
        updateAge: this.sessionUpdateAgeSeconds,
        deferSessionRefresh: true,
      },
      account: {
        modelName: 'accounts',
        fields: {
          userId: 'user_id',
          accountId: 'account_id',
          providerId: 'provider_id',
          accessToken: 'access_token',
          refreshToken: 'refresh_token',
          idToken: 'id_token',
          accessTokenExpiresAt: 'access_token_expires_at',
          refreshTokenExpiresAt: 'refresh_token_expires_at',
          scope: 'scope',
          password: 'password_hash',
          createdAt: 'created_at',
          updatedAt: 'updated_at',
        },
      },
      verification: {
        modelName: 'verifications',
        fields: {
          identifier: 'identifier',
          value: 'value',
          expiresAt: 'expires_at',
          createdAt: 'created_at',
          updatedAt: 'updated_at',
        },
      },
      emailAndPassword: {
        enabled: true,
        autoSignIn: false,
        minPasswordLength: 8,
        maxPasswordLength: 128,
        revokeSessionsOnPasswordReset: true,
        password: {
          hash: async (password) => {
            const { hash } = await import('bcryptjs');
            return hash(password, 12);
          },
          verify: async ({ hash: hashValue, password }) => {
            const { compare } = await import('bcryptjs');
            return compare(password, hashValue);
          },
        },
        sendResetPassword: async ({ user, token }) => {
          void this.notificationService.sendPasswordResetToken(
            user.email,
            token,
          );
        },
      },
      advanced: {
        disableCSRFCheck: true,
        disableOriginCheck: true,
        database: {
          generateId: 'uuid',
        },
      },
      plugins: [bearer()],
    };

    this.logger.log('Better Auth instance configured');
    return betterAuth(options);
  }

  private parseNumber(value: string | undefined, fallback: number): number {
    if (!value) return fallback;
    const parsed = Number.parseInt(value, 10);
    return Number.isNaN(parsed) ? fallback : parsed;
  }
}
