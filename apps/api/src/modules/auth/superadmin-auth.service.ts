import {
  ForbiddenException,
  HttpException,
  HttpStatus,
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'node:crypto';
import { Repository } from 'typeorm';
import { SuperadminAuthAuditEventEntity } from '../../database/entities/superadmin-auth-audit-event.entity';
import { SuperadminMfaChallengeEntity } from '../../database/entities/superadmin-mfa-challenge.entity';
import { UserEntity } from '../../database/entities/user.entity';
import {
  AUTH_MFA_CHALLENGE_REQUIRED,
  AUTH_MFA_INVALID_CODE,
  AUTH_MFA_LOCKED,
  AUTH_MFA_RECHALLENGE_REQUIRED,
  AUTHZ_SUPERADMIN_REQUIRED,
  type SuperadminAdminActionTokenResponse,
  type SuperadminElevationChallengeResponse,
  type SuperadminElevationVerifyResponse,
} from './auth.types';

interface BuildRiskFingerprintInput {
  explicitRiskPosture?: string;
  userAgent?: string;
  ipAddress?: string;
}

@Injectable()
export class SuperadminAuthService {
  private readonly logger = new Logger(SuperadminAuthService.name);
  private readonly challengeTtlSeconds: number;
  private readonly trustTtlSeconds: number;
  private readonly maxAttempts: number;
  private readonly lockoutSeconds: number;
  private readonly testMfaCode: string;

  constructor(
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(SuperadminMfaChallengeEntity)
    private readonly challengeRepo: Repository<SuperadminMfaChallengeEntity>,
    @InjectRepository(SuperadminAuthAuditEventEntity)
    private readonly auditRepo: Repository<SuperadminAuthAuditEventEntity>,
    private readonly configService: ConfigService,
  ) {
    this.challengeTtlSeconds = this.parseIntWithFallback(
      this.configService.get<string>('SUPERADMIN_MFA_CHALLENGE_TTL_SECONDS'),
      300,
    );
    this.trustTtlSeconds = this.parseIntWithFallback(
      this.configService.get<string>('SUPERADMIN_MFA_TRUST_TTL_SECONDS'),
      600,
    );
    this.maxAttempts = this.parseIntWithFallback(
      this.configService.get<string>('SUPERADMIN_MFA_MAX_ATTEMPTS'),
      5,
    );
    this.lockoutSeconds = this.parseIntWithFallback(
      this.configService.get<string>('SUPERADMIN_MFA_LOCKOUT_SECONDS'),
      900,
    );
    this.testMfaCode =
      this.configService.get<string>('SUPERADMIN_MFA_TEST_CODE') ?? '654321';
  }

  async beginChallenge(input: {
    userId: string;
    sessionId: string;
    correlationId: string;
    riskFingerprint: string;
  }): Promise<SuperadminElevationChallengeResponse> {
    await this.assertSuperadmin(input.userId, input.correlationId);
    const now = new Date();

    const existing = await this.challengeRepo.findOne({
      where: {
        userId: input.userId,
        sessionId: input.sessionId,
      },
      order: { createdAt: 'DESC' },
    });

    if (
      existing &&
      existing.status === 'pending' &&
      existing.expiresAt > now &&
      existing.riskFingerprint === input.riskFingerprint
    ) {
      await this.recordAudit(input.userId, {
        action: 'MFA_CHALLENGE_REUSED',
        outcome: 'success',
        target: 'superadmin_elevation',
        correlationId: input.correlationId,
        challengeId: existing.id,
      });
      return this.toChallengeResponse(existing);
    }

    const challenge = this.challengeRepo.create({
      userId: input.userId,
      sessionId: input.sessionId,
      status: 'pending',
      riskFingerprint: input.riskFingerprint,
      attemptCount: 0,
      maxAttempts: this.maxAttempts,
      lockedUntil: null,
      lastFailureCode: null,
      adminActionToken: null,
      expiresAt: this.addSeconds(now, this.challengeTtlSeconds),
      verifiedAt: null,
      trustExpiresAt: null,
    });
    const saved = await this.challengeRepo.save(challenge);

    await this.recordAudit(input.userId, {
      action: 'MFA_CHALLENGE_CREATED',
      outcome: 'success',
      target: 'superadmin_elevation',
      correlationId: input.correlationId,
      challengeId: saved.id,
    });
    return this.toChallengeResponse(saved);
  }

  async verifyChallenge(input: {
    userId: string;
    challengeId: string;
    mfaCode: string;
    riskFingerprint: string;
    correlationId: string;
  }): Promise<SuperadminElevationVerifyResponse> {
    await this.assertSuperadmin(input.userId, input.correlationId);
    const challenge = await this.requireChallenge(
      input.userId,
      input.challengeId,
    );
    const now = new Date();

    if (challenge.lockedUntil && challenge.lockedUntil > now) {
      await this.recordAudit(input.userId, {
        action: 'MFA_VERIFY_ATTEMPT',
        outcome: 'failure',
        target: 'superadmin_elevation',
        correlationId: input.correlationId,
        challengeId: challenge.id,
        errorCode: AUTH_MFA_LOCKED,
      });
      throw new HttpException(
        {
          code: AUTH_MFA_LOCKED,
          message: 'MFA challenge is temporarily locked due to failed attempts',
        },
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    if (challenge.expiresAt <= now) {
      challenge.status = 'reverted';
      challenge.lastFailureCode = AUTH_MFA_RECHALLENGE_REQUIRED;
      await this.challengeRepo.save(challenge);
      await this.recordAudit(input.userId, {
        action: 'MFA_VERIFY_ATTEMPT',
        outcome: 'reverted',
        target: 'superadmin_elevation',
        correlationId: input.correlationId,
        challengeId: challenge.id,
        errorCode: AUTH_MFA_RECHALLENGE_REQUIRED,
      });
      throw new UnauthorizedException({
        code: AUTH_MFA_RECHALLENGE_REQUIRED,
        message: 'MFA challenge expired; re-challenge is required',
      });
    }

    if (challenge.riskFingerprint !== input.riskFingerprint) {
      challenge.status = 'reverted';
      challenge.lastFailureCode = AUTH_MFA_RECHALLENGE_REQUIRED;
      challenge.adminActionToken = null;
      challenge.trustExpiresAt = null;
      await this.challengeRepo.save(challenge);
      await this.recordAudit(input.userId, {
        action: 'MFA_VERIFY_ATTEMPT',
        outcome: 'reverted',
        target: 'superadmin_elevation',
        correlationId: input.correlationId,
        challengeId: challenge.id,
        errorCode: AUTH_MFA_RECHALLENGE_REQUIRED,
      });
      throw new UnauthorizedException({
        code: AUTH_MFA_RECHALLENGE_REQUIRED,
        message: 'Risk posture changed; re-challenge is required',
      });
    }

    if (input.mfaCode !== this.testMfaCode) {
      challenge.attemptCount += 1;
      challenge.status = 'failure';
      challenge.lastFailureCode = AUTH_MFA_INVALID_CODE;
      if (challenge.attemptCount >= challenge.maxAttempts) {
        challenge.lockedUntil = this.addSeconds(now, this.lockoutSeconds);
      }
      await this.challengeRepo.save(challenge);
      await this.recordAudit(input.userId, {
        action: 'MFA_VERIFY_ATTEMPT',
        outcome: 'failure',
        target: 'superadmin_elevation',
        correlationId: input.correlationId,
        challengeId: challenge.id,
        errorCode:
          challenge.attemptCount >= challenge.maxAttempts
            ? AUTH_MFA_LOCKED
            : AUTH_MFA_INVALID_CODE,
      });

      if (challenge.attemptCount >= challenge.maxAttempts) {
        throw new HttpException(
          {
            code: AUTH_MFA_LOCKED,
            message:
              'MFA challenge is temporarily locked due to failed attempts',
          },
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }

      throw new UnauthorizedException({
        code: AUTH_MFA_INVALID_CODE,
        message: 'Invalid MFA code',
      });
    }

    if (
      challenge.status === 'success' &&
      challenge.trustExpiresAt &&
      challenge.trustExpiresAt > now
    ) {
      await this.recordAudit(input.userId, {
        action: 'MFA_VERIFY_ATTEMPT',
        outcome: 'success',
        target: 'superadmin_elevation',
        correlationId: input.correlationId,
        challengeId: challenge.id,
      });
      return {
        challengeId: challenge.id,
        state: challenge.status,
        trustExpiresAt: challenge.trustExpiresAt.toISOString(),
      };
    }

    challenge.status = 'success';
    challenge.verifiedAt = now;
    challenge.trustExpiresAt = this.addSeconds(now, this.trustTtlSeconds);
    challenge.adminActionToken = challenge.adminActionToken ?? randomUUID();
    challenge.lockedUntil = null;
    challenge.lastFailureCode = null;
    await this.challengeRepo.save(challenge);

    await this.recordAudit(input.userId, {
      action: 'MFA_VERIFY_ATTEMPT',
      outcome: 'success',
      target: 'superadmin_elevation',
      correlationId: input.correlationId,
      challengeId: challenge.id,
    });
    return {
      challengeId: challenge.id,
      state: challenge.status,
      trustExpiresAt: challenge.trustExpiresAt?.toISOString() ?? null,
    };
  }

  async issueAdminActionToken(input: {
    userId: string;
    challengeId: string;
    sessionId: string;
    correlationId: string;
    riskFingerprint: string;
  }): Promise<SuperadminAdminActionTokenResponse> {
    await this.assertSuperadmin(input.userId, input.correlationId);
    const challenge = await this.requireChallenge(
      input.userId,
      input.challengeId,
    );
    const now = new Date();

    if (
      challenge.sessionId !== input.sessionId ||
      challenge.status !== 'success' ||
      !challenge.trustExpiresAt ||
      challenge.trustExpiresAt <= now ||
      challenge.riskFingerprint !== input.riskFingerprint
    ) {
      if (
        challenge.riskFingerprint !== input.riskFingerprint ||
        (challenge.trustExpiresAt && challenge.trustExpiresAt <= now)
      ) {
        challenge.status = 'reverted';
        challenge.lastFailureCode = AUTH_MFA_RECHALLENGE_REQUIRED;
        challenge.adminActionToken = null;
      }
      await this.challengeRepo.save(challenge);
      await this.recordAudit(input.userId, {
        action: 'ADMIN_ACTION_TOKEN_ISSUE',
        outcome: 'reverted',
        target: 'superadmin_sensitive_operation',
        correlationId: input.correlationId,
        challengeId: challenge.id,
        errorCode: AUTH_MFA_CHALLENGE_REQUIRED,
      });
      throw new UnauthorizedException({
        code: AUTH_MFA_CHALLENGE_REQUIRED,
        message:
          'MFA challenge must be completed before admin action token issuance',
      });
    }

    challenge.adminActionToken = challenge.adminActionToken ?? randomUUID();
    await this.challengeRepo.save(challenge);
    await this.recordAudit(input.userId, {
      action: 'ADMIN_ACTION_TOKEN_ISSUE',
      outcome: 'success',
      target: 'superadmin_sensitive_operation',
      correlationId: input.correlationId,
      challengeId: challenge.id,
    });
    return {
      challengeId: challenge.id,
      state: challenge.status,
      adminActionToken: challenge.adminActionToken,
      trustExpiresAt: challenge.trustExpiresAt.toISOString(),
    };
  }

  async validateAdminActionToken(input: {
    userId: string;
    sessionId: string;
    adminActionToken: string;
    correlationId: string;
    riskFingerprint: string;
  }): Promise<void> {
    const challenge = await this.challengeRepo.findOne({
      where: {
        userId: input.userId,
        sessionId: input.sessionId,
        adminActionToken: input.adminActionToken,
      },
    });
    if (!challenge) {
      await this.recordAudit(input.userId, {
        action: 'ADMIN_ACTION_TOKEN_VALIDATE',
        outcome: 'denied',
        target: 'superadmin_sensitive_operation',
        correlationId: input.correlationId,
        errorCode: AUTH_MFA_CHALLENGE_REQUIRED,
      });
      throw new UnauthorizedException({
        code: AUTH_MFA_CHALLENGE_REQUIRED,
        message: 'Admin action token is missing or invalid',
      });
    }

    const now = new Date();

    if (challenge.status !== 'success' || !challenge.trustExpiresAt) {
      challenge.status = 'reverted';
      challenge.adminActionToken = null;
      challenge.trustExpiresAt = null;
      challenge.lastFailureCode = AUTH_MFA_CHALLENGE_REQUIRED;
      await this.challengeRepo.save(challenge);
      await this.recordAudit(input.userId, {
        action: 'ADMIN_ACTION_TOKEN_VALIDATE',
        outcome: 'reverted',
        target: 'superadmin_sensitive_operation',
        correlationId: input.correlationId,
        challengeId: challenge.id,
        errorCode: AUTH_MFA_CHALLENGE_REQUIRED,
      });
      throw new UnauthorizedException({
        code: AUTH_MFA_CHALLENGE_REQUIRED,
        message: 'Admin action token is invalid',
      });
    }

    if (challenge.trustExpiresAt <= now) {
      challenge.status = 'reverted';
      challenge.adminActionToken = null;
      challenge.trustExpiresAt = null;
      challenge.lastFailureCode = AUTH_MFA_RECHALLENGE_REQUIRED;
      await this.challengeRepo.save(challenge);
      await this.recordAudit(input.userId, {
        action: 'ADMIN_ACTION_TOKEN_VALIDATE',
        outcome: 'reverted',
        target: 'superadmin_sensitive_operation',
        correlationId: input.correlationId,
        challengeId: challenge.id,
        errorCode: AUTH_MFA_RECHALLENGE_REQUIRED,
      });
      throw new UnauthorizedException({
        code: AUTH_MFA_RECHALLENGE_REQUIRED,
        message: 'Admin action token expired; re-challenge is required',
      });
    }

    if (challenge.riskFingerprint !== input.riskFingerprint) {
      challenge.status = 'reverted';
      challenge.adminActionToken = null;
      challenge.trustExpiresAt = null;
      challenge.lastFailureCode = AUTH_MFA_RECHALLENGE_REQUIRED;
      await this.challengeRepo.save(challenge);
      await this.recordAudit(input.userId, {
        action: 'ADMIN_ACTION_TOKEN_VALIDATE',
        outcome: 'reverted',
        target: 'superadmin_sensitive_operation',
        correlationId: input.correlationId,
        challengeId: challenge.id,
        errorCode: AUTH_MFA_RECHALLENGE_REQUIRED,
      });
      throw new UnauthorizedException({
        code: AUTH_MFA_RECHALLENGE_REQUIRED,
        message: 'Risk posture changed; re-challenge is required',
      });
    }

    await this.recordAudit(input.userId, {
      action: 'ADMIN_ACTION_TOKEN_VALIDATE',
      outcome: 'success',
      target: 'superadmin_sensitive_operation',
      correlationId: input.correlationId,
      challengeId: challenge.id,
    });
  }

  async assertSuperadmin(userId: string, correlationId: string): Promise<void> {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user || user.role !== 'superadmin') {
      await this.recordAudit(userId, {
        action: 'SUPERADMIN_ACCESS_CHECK',
        outcome: 'denied',
        target: 'superadmin_endpoint',
        correlationId,
        errorCode: AUTHZ_SUPERADMIN_REQUIRED,
      });
      throw new ForbiddenException({
        code: AUTHZ_SUPERADMIN_REQUIRED,
        message: 'Superadmin role is required for this operation',
      });
    }
  }

  buildRiskFingerprint(input: BuildRiskFingerprintInput): string {
    const explicit = input.explicitRiskPosture?.trim();
    if (explicit) return `risk:${explicit.toLowerCase()}`;
    const ua = input.userAgent?.trim() || 'unknown-user-agent';
    const ip = input.ipAddress?.trim() || 'unknown-ip';
    return `ua:${ua}|ip:${ip}`;
  }

  private async requireChallenge(
    userId: string,
    challengeId: string,
  ): Promise<SuperadminMfaChallengeEntity> {
    const challenge = await this.challengeRepo.findOne({
      where: { id: challengeId, userId },
    });
    if (!challenge) {
      throw new UnauthorizedException({
        code: AUTH_MFA_CHALLENGE_REQUIRED,
        message: 'MFA challenge not found for current user session',
      });
    }
    return challenge;
  }

  private toChallengeResponse(
    challenge: SuperadminMfaChallengeEntity,
  ): SuperadminElevationChallengeResponse {
    const now = new Date();
    const lockoutUntil =
      challenge.lockedUntil && challenge.lockedUntil > now
        ? challenge.lockedUntil.toISOString()
        : null;
    return {
      challengeId: challenge.id,
      state: challenge.status,
      expiresAt: challenge.expiresAt.toISOString(),
      attemptsRemaining: Math.max(
        challenge.maxAttempts - challenge.attemptCount,
        0,
      ),
      lockoutUntil,
    };
  }

  private addSeconds(base: Date, seconds: number): Date {
    return new Date(base.getTime() + seconds * 1000);
  }

  private parseIntWithFallback(
    value: string | undefined,
    fallback: number,
  ): number {
    if (!value) return fallback;
    const parsed = Number.parseInt(value, 10);
    return Number.isNaN(parsed) ? fallback : parsed;
  }

  private async recordAudit(
    actorUserId: string,
    payload: {
      action: string;
      target: string;
      outcome: 'success' | 'failure' | 'denied' | 'reverted';
      correlationId: string;
      challengeId?: string;
      errorCode?: string;
      metadata?: Record<string, string | number | boolean>;
    },
  ): Promise<void> {
    await this.auditRepo.save(
      this.auditRepo.create({
        actorUserId,
        action: payload.action,
        target: payload.target,
        outcome: payload.outcome,
        correlationId: payload.correlationId,
        challengeId: payload.challengeId ?? null,
        errorCode: payload.errorCode ?? null,
        metadata: payload.metadata ?? null,
      }),
    );
    this.logger.log(
      JSON.stringify({
        action: payload.action,
        target: payload.target,
        outcome: payload.outcome,
        correlationId: payload.correlationId,
        actorUserId,
        challengeId: payload.challengeId,
        errorCode: payload.errorCode,
      }),
    );
  }
}
