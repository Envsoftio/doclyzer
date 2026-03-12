/* eslint-disable @typescript-eslint/no-unsafe-argument, @typescript-eslint/no-unsafe-member-access */
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import request from 'supertest';
import { createHash } from 'node:crypto';
import { DataSource, type Repository } from 'typeorm';
import { AppModule } from '../src/app.module';
import { ApiExceptionFilter } from '../src/common/api-exception.filter';
import { correlationIdMiddleware } from '../src/common/correlation-id.middleware';
import { InMemoryNotificationService } from '../src/common/notification/in-memory-notification.service';
import { NotificationService } from '../src/common/notification/notification.service';
import { PasswordResetTokenEntity } from '../src/database/entities/password-reset-token.entity';
import { RestrictionEntity } from '../src/database/entities/restriction.entity';
import { clearDatabase } from './db-cleaner';

describe('AuthController (e2e)', () => {
  let app: INestApplication;
  let notificationService: InMemoryNotificationService;
  let resetTokenRepo: Repository<PasswordResetTokenEntity>;
  let restrictionRepo: Repository<RestrictionEntity>;

  beforeAll(async () => {
    process.env.E2E_MAX_PROFILES = '2';
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.use(correlationIdMiddleware);
    app.useGlobalFilters(new ApiExceptionFilter());
    app.useGlobalPipes(
      new ValidationPipe({ whitelist: true, transform: true }),
    );
    app.setGlobalPrefix('v1');
    await app.init();
    notificationService =
      app.get<InMemoryNotificationService>(NotificationService);
    resetTokenRepo = app.get<Repository<PasswordResetTokenEntity>>(
      getRepositoryToken(PasswordResetTokenEntity),
    );
    restrictionRepo = app.get<Repository<RestrictionEntity>>(
      getRepositoryToken(RestrictionEntity),
    );
  });

  afterAll(async () => {
    await app.close();
  });

  describe('Auth flows (per-test clean)', () => {
    beforeEach(async () => {
      const dataSource = app.get<DataSource>(DataSource);
      await clearDatabase(dataSource);
    });

    it('registers successfully', async () => {
      const res = await request(app.getHttpServer())
        .post('/v1/auth/register')
        .set('x-correlation-id', 'test-correlation-id')
        .send({
          email: 'user@example.com',
          password: 'StrongPass123!',
        })
        .expect(201);

      expect(res.body.success).toBe(true);
      expect(res.body.correlationId).toBe('test-correlation-id');
      expect(res.body.data.requiresVerification).toBe(true);
    });

    it('logs in and logs out with revocation', async () => {
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .send({
          email: 'logout@example.com',
          password: 'StrongPass123!',
        })
        .expect(201);

      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .send({ email: 'logout@example.com', password: 'StrongPass123!' })
        .expect(200);

      const accessToken = loginRes.body.data.accessToken as string;
      expect(accessToken).toBeTruthy();

      await request(app.getHttpServer())
        .post('/v1/auth/logout')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      const secondLogoutRes = await request(app.getHttpServer())
        .post('/v1/auth/logout')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(401);

      expect(secondLogoutRes.body.success).toBe(false);
      expect(secondLogoutRes.body.error.code).toBe('AUTH_SESSION_REVOKED');
    });

      it('rejects login with invalid credentials', async () => {
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .send({
          email: 'invalid@example.com',
          password: 'StrongPass123!',
        })
        .expect(201);

      const res = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .send({ email: 'invalid@example.com', password: 'WrongPass999!' })
        .expect(401);

      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('AUTH_INVALID_CREDENTIALS');
    });

    it('rotates session on refresh and invalidates old refresh token', async () => {
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .send({
          email: 'refresh@example.com',
          password: 'StrongPass123!',
        })
        .expect(201);

      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .send({ email: 'refresh@example.com', password: 'StrongPass123!' })
        .expect(200);

      const originalRefreshToken = loginRes.body.data.refreshToken as string;
      const originalAccessToken = loginRes.body.data.accessToken as string;

      const refreshRes = await request(app.getHttpServer())
        .post('/v1/auth/refresh')
        .send({ refreshToken: originalRefreshToken })
        .expect(200);

      expect(refreshRes.body.success).toBe(true);
      expect(refreshRes.body.data.accessToken).not.toBe(originalAccessToken);
      expect(refreshRes.body.data.refreshToken).not.toBe(originalRefreshToken);
      expect(refreshRes.body.data.accessToken).toBeTruthy();

      const reusedRefreshRes = await request(app.getHttpServer())
        .post('/v1/auth/refresh')
        .send({ refreshToken: originalRefreshToken })
        .expect(401);

      expect(reusedRefreshRes.body.error.code).toBe('AUTH_SESSION_REVOKED');
    });
  });

  describe('password recovery', () => {
    beforeEach(async () => {
      const dataSource = app.get<DataSource>(DataSource);
      await clearDatabase(dataSource);
    });
    it('forgot-password returns generic message regardless of account existence', async () => {
      const knownRes = await request(app.getHttpServer())
        .post('/v1/auth/forgot-password')
        .send({ email: 'recovery-known@example.com' })
        .expect(200);

      const unknownRes = await request(app.getHttpServer())
        .post('/v1/auth/forgot-password')
        .send({ email: 'recovery-unknown-xyz@example.com' })
        .expect(200);

      expect(knownRes.body.success).toBe(true);
      expect(unknownRes.body.success).toBe(true);
      expect(knownRes.body.data.message).toBe(unknownRes.body.data.message);
    });

    it('completes full reset flow: request → reset → login with new password', async () => {
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .send({
          email: 'pwreset@example.com',
          password: 'OldPass123!',
        })
        .expect(201);

      await request(app.getHttpServer())
        .post('/v1/auth/forgot-password')
        .send({ email: 'pwreset@example.com' })
        .expect(200);

      const token = notificationService.getLastTokenForEmail(
        'pwreset@example.com',
      );
      expect(token).toBeTruthy();

      const resetRes = await request(app.getHttpServer())
        .post('/v1/auth/reset-password')
        .send({ token, newPassword: 'NewPass456!' })
        .expect(200);

      expect(resetRes.body.success).toBe(true);
      expect(resetRes.body.data.message).toContain('successful');

      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .send({ email: 'pwreset@example.com', password: 'NewPass456!' })
        .expect(200);

      expect(loginRes.body.data.accessToken).toBeTruthy();
    });

    it('rejects old password after reset', async () => {
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .send({
          email: 'oldpass@example.com',
          password: 'OldPass123!',
        })
        .expect(201);

      await request(app.getHttpServer())
        .post('/v1/auth/forgot-password')
        .send({ email: 'oldpass@example.com' })
        .expect(200);

      const token = notificationService.getLastTokenForEmail(
        'oldpass@example.com',
      )!;
      await request(app.getHttpServer())
        .post('/v1/auth/reset-password')
        .send({ token, newPassword: 'NewPass456!' })
        .expect(200);

      const oldLoginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .send({ email: 'oldpass@example.com', password: 'OldPass123!' })
        .expect(401);

      expect(oldLoginRes.body.error.code).toBe('AUTH_INVALID_CREDENTIALS');
    });

    it('revokes active sessions on reset', async () => {
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .send({
          email: 'sessionrevoke@example.com',
          password: 'OldPass123!',
        })
        .expect(201);

      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .send({ email: 'sessionrevoke@example.com', password: 'OldPass123!' })
        .expect(200);

      const { accessToken } = loginRes.body.data as { accessToken: string };

      await request(app.getHttpServer())
        .post('/v1/auth/forgot-password')
        .send({ email: 'sessionrevoke@example.com' })
        .expect(200);

      const token = notificationService.getLastTokenForEmail(
        'sessionrevoke@example.com',
      )!;
      await request(app.getHttpServer())
        .post('/v1/auth/reset-password')
        .send({ token, newPassword: 'NewPass456!' })
        .expect(200);

      const logoutRes = await request(app.getHttpServer())
        .post('/v1/auth/logout')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(401);

      expect(logoutRes.body.error.code).toBe('AUTH_SESSION_REVOKED');
    });

    it('rejects invalid reset token', async () => {
      const res = await request(app.getHttpServer())
        .post('/v1/auth/reset-password')
        .send({ token: 'fake-token-xyz', newPassword: 'NewPass456!' })
        .expect(401);

      expect(res.body.error.code).toBe('AUTH_RESET_TOKEN_INVALID');
    });

    it('enforces single-use: rejects token used twice', async () => {
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .send({
          email: 'singleuse@example.com',
          password: 'OldPass123!',
        })
        .expect(201);

      await request(app.getHttpServer())
        .post('/v1/auth/forgot-password')
        .send({ email: 'singleuse@example.com' })
        .expect(200);

      const token = notificationService.getLastTokenForEmail(
        'singleuse@example.com',
      )!;
      await request(app.getHttpServer())
        .post('/v1/auth/reset-password')
        .send({ token, newPassword: 'NewPass456!' })
        .expect(200);

      const reusedRes = await request(app.getHttpServer())
        .post('/v1/auth/reset-password')
        .send({ token, newPassword: 'AnotherPass789!' })
        .expect(401);

      expect(reusedRes.body.error.code).toBe('AUTH_RESET_TOKEN_USED');
    });

    it('enforces password policy on reset', async () => {
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .send({
          email: 'weakpw@example.com',
          password: 'OldPass123!',
        })
        .expect(201);

      await request(app.getHttpServer())
        .post('/v1/auth/forgot-password')
        .send({ email: 'weakpw@example.com' })
        .expect(200);

      const token =
        notificationService.getLastTokenForEmail('weakpw@example.com')!;
      const res = await request(app.getHttpServer())
        .post('/v1/auth/reset-password')
        .send({ token, newPassword: 'short' })
        .expect(400);

      expect(res.body.error.code).toBe('AUTH_PASSWORD_INVALID');
    });

    it('rate limits forgot-password requests', async () => {
      let rateLimitedRes: request.Response | undefined;
      for (let i = 0; i < 20; i++) {
        const res = await request(app.getHttpServer())
          .post('/v1/auth/forgot-password')
          .send({ email: 'rl-forgot@example.com' });
        if (res.status === 429) {
          rateLimitedRes = res;
          break;
        }
      }
      expect(rateLimitedRes).toBeDefined();
      expect(rateLimitedRes!.body.error.code).toBe('AUTH_RATE_LIMITED');
    });

    it('rejects an expired reset token', async () => {
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .send({
          email: 'expiredtoken@example.com',
          password: 'OldPass123!',
        })
        .expect(201);

      await request(app.getHttpServer())
        .post('/v1/auth/forgot-password')
        .send({ email: 'expiredtoken@example.com' })
        .expect(200);

      const token = notificationService.getLastTokenForEmail(
        'expiredtoken@example.com',
      )!;
      expect(token).toBeTruthy();

      // Backdate the token record directly via the injected service to simulate expiry.
      const tokenHash = createHash('sha256').update(token).digest('hex');
      await resetTokenRepo.update(
        { tokenHash },
        { expiresAt: new Date(Date.now() - 1000) },
      );

      const res = await request(app.getHttpServer())
        .post('/v1/auth/reset-password')
        .send({ token, newPassword: 'NewPass456!' })
        .expect(400);

      expect(res.body.error.code).toBe('AUTH_RESET_TOKEN_EXPIRED');
    });
  });

  describe('GET /auth/sessions and DELETE /auth/sessions/:sessionId', () => {
    beforeEach(async () => {
      const dataSource = app.get<DataSource>(DataSource);
      await clearDatabase(dataSource);
    });
    it('GET /auth/sessions with valid token returns 200 and list with isCurrent', async () => {
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .send({
          email: 'sessions-e2e@example.com',
          password: 'StrongPass123!',
        })
        .expect(201);

      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .send({
          email: 'sessions-e2e@example.com',
          password: 'StrongPass123!',
        })
        .expect(200);

      const accessToken = loginRes.body.data.accessToken as string;
      const res = await request(app.getHttpServer())
        .get('/v1/auth/sessions')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
      expect(res.body.data.length).toBeGreaterThanOrEqual(1);
      const current = (res.body.data as Array<{ isCurrent: boolean }>).find(
        (s) => s.isCurrent,
      );
      expect(current).toBeDefined();
      expect(res.body.correlationId).toBeTruthy();
    });

    it('GET /auth/sessions without token returns 401', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/auth/sessions')
        .expect(401);
      expect(res.body.success).toBe(false);
      expect(res.body.error?.code).toBe('AUTH_UNAUTHORIZED');
    });

    it('DELETE /auth/sessions/:sessionId for valid owned session returns 200 and data null', async () => {
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .send({
          email: 'revoke-e2e@example.com',
          password: 'StrongPass123!',
        })
        .expect(201);

      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .send({
          email: 'revoke-e2e@example.com',
          password: 'StrongPass123!',
        })
        .expect(200);

      const accessToken = loginRes.body.data.accessToken as string;
      const listRes = await request(app.getHttpServer())
        .get('/v1/auth/sessions')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      const sessionId = (listRes.body.data as Array<{ sessionId: string }>)[0]
        .sessionId;
      const delRes = await request(app.getHttpServer())
        .delete(`/v1/auth/sessions/${sessionId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(delRes.body.success).toBe(true);
      expect(delRes.body.data).toBeNull();
    });

    it('DELETE /auth/sessions/:sessionId for non-existent sessionId returns 404 SESSION_NOT_FOUND', async () => {
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .send({
          email: 'revoke404@example.com',
          password: 'StrongPass123!',
        })
        .expect(201);

      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .send({
          email: 'revoke404@example.com',
          password: 'StrongPass123!',
        })
        .expect(200);

      const accessToken = loginRes.body.data.accessToken as string;
      const res = await request(app.getHttpServer())
        .delete('/v1/auth/sessions/00000000-0000-0000-0000-000000000000')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(404);

      expect(res.body.success).toBe(false);
      expect(res.body.error?.code).toBe('SESSION_NOT_FOUND');
    });

    it('DELETE /auth/sessions without token returns 401', async () => {
      const res = await request(app.getHttpServer())
        .delete('/v1/auth/sessions/some-session-id')
        .expect(401);
      expect(res.body.success).toBe(false);
      expect(res.body.error?.code).toBe('AUTH_UNAUTHORIZED');
    });

    it('after DELETE current session, subsequent request with same token returns 401', async () => {
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .send({
          email: 'revoke-current@example.com',
          password: 'StrongPass123!',
        })
        .expect(201);

      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .send({
          email: 'revoke-current@example.com',
          password: 'StrongPass123!',
        })
        .expect(200);

      const accessToken = loginRes.body.data.accessToken as string;
      const listRes = await request(app.getHttpServer())
        .get('/v1/auth/sessions')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      const sessionId = (listRes.body.data as Array<{ sessionId: string }>)[0]
        .sessionId;
      await request(app.getHttpServer())
        .delete(`/v1/auth/sessions/${sessionId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      const afterRes = await request(app.getHttpServer())
        .get('/v1/auth/sessions')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(401);
      expect(afterRes.body.error?.code).toBe('AUTH_UNAUTHORIZED');
    });
  });
  });

  describe('Account Profile', () => {
    const accountEmail = 'account-profile@example.com';
    const accountPassword = 'StrongPass123!';
    let accountToken: string;

    beforeAll(async () => {
      await clearDatabase(app.get<DataSource>(DataSource));
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .set('x-forwarded-for', '10.0.1.1')
        .send({
          email: accountEmail,
          password: accountPassword,
        })
        .expect(201);

      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .set('x-forwarded-for', '10.0.1.1')
        .send({ email: accountEmail, password: accountPassword })
        .expect(200);

      accountToken = loginRes.body.data.accessToken as string;
    });

    it('GET /account/profile returns correct shape for authenticated user', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/account/profile')
        .set('Authorization', `Bearer ${accountToken}`)
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.email).toBe(accountEmail);
      expect(res.body.data.displayName).toBeNull();
      expect(res.body.data.id).toBeTruthy();
      expect(res.body.data.createdAt).toBeTruthy();
      expect(typeof res.body.correlationId).toBe('string');
    });

    it('PATCH /account/profile updates displayName and persists', async () => {
      const patchRes = await request(app.getHttpServer())
        .patch('/v1/account/profile')
        .set('Authorization', `Bearer ${accountToken}`)
        .send({ displayName: 'Alice Tester' })
        .expect(200);

      expect(patchRes.body.success).toBe(true);
      expect(patchRes.body.data.displayName).toBe('Alice Tester');

      const getRes = await request(app.getHttpServer())
        .get('/v1/account/profile')
        .set('Authorization', `Bearer ${accountToken}`)
        .expect(200);

      expect(getRes.body.data.displayName).toBe('Alice Tester');
    });

    it('PATCH /account/profile ignores restricted field (email)', async () => {
      await request(app.getHttpServer())
        .patch('/v1/account/profile')
        .set('Authorization', `Bearer ${accountToken}`)
        .send({ email: 'hacked@example.com', displayName: 'Bob' })
        .expect(200);

      const getRes = await request(app.getHttpServer())
        .get('/v1/account/profile')
        .set('Authorization', `Bearer ${accountToken}`)
        .expect(200);

      expect(getRes.body.data.email).toBe(accountEmail);
      expect(getRes.body.data.displayName).toBe('Bob');
    });

    it('GET /account/profile without token returns 401 AUTH_UNAUTHORIZED', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/account/profile')
        .expect(401);

      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('AUTH_UNAUTHORIZED');
    });

    it('PATCH /account/profile without token returns 401 AUTH_UNAUTHORIZED', async () => {
      const res = await request(app.getHttpServer())
        .patch('/v1/account/profile')
        .send({ displayName: 'Ghost' })
        .expect(401);

      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('AUTH_UNAUTHORIZED');
    });

    it('GET /account/profile with invalid token returns 401 AUTH_UNAUTHORIZED', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/account/profile')
        .set('Authorization', 'Bearer totally-invalid-token')
        .expect(401);

      expect(res.body.error.code).toBe('AUTH_UNAUTHORIZED');
    });
  });

  describe('Profiles', () => {
    const profilesEmail = 'profiles@example.com';
    const profilesPassword = 'StrongPass123!';
    let profilesToken: string;
    let firstProfileId: string;
    let secondProfileId: string;

    beforeAll(async () => {
      await clearDatabase(app.get<DataSource>(DataSource));
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .set('x-forwarded-for', '10.0.1.3')
        .send({
          email: profilesEmail,
          password: profilesPassword,
        })
        .expect(201);

      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .set('x-forwarded-for', '10.0.1.3')
        .send({ email: profilesEmail, password: profilesPassword })
        .expect(200);

      profilesToken = loginRes.body.data.accessToken as string;
    });

    it('GET /profiles without token → 401 AUTH_UNAUTHORIZED', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/profiles')
        .expect(401);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('AUTH_UNAUTHORIZED');
    });

    it('GET /profiles with valid token → 200, empty array', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/profiles')
        .set('Authorization', `Bearer ${profilesToken}`)
        .expect(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toEqual([]);
      expect(typeof res.body.correlationId).toBe('string');
    });

    it('POST /profiles creates first profile and auto-activates it', async () => {
      const res = await request(app.getHttpServer())
        .post('/v1/profiles')
        .set('Authorization', `Bearer ${profilesToken}`)
        .send({ name: 'Vishnu' })
        .expect(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.name).toBe('Vishnu');
      expect(res.body.data.isActive).toBe(true);
      expect(res.body.data.id).toBeTruthy();
      expect(typeof res.body.correlationId).toBe('string');
      firstProfileId = res.body.data.id as string;
    });

    it('GET /profiles after first create → one profile, isActive: true', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/profiles')
        .set('Authorization', `Bearer ${profilesToken}`)
        .expect(200);
      expect(res.body.data).toHaveLength(1);
      expect(res.body.data[0].isActive).toBe(true);
    });

    it('POST /profiles creates second profile, isActive: false', async () => {
      const res = await request(app.getHttpServer())
        .post('/v1/profiles')
        .set('Authorization', `Bearer ${profilesToken}`)
        .send({ name: 'Amma', relation: 'parent' })
        .expect(201);
      expect(res.body.data.name).toBe('Amma');
      expect(res.body.data.isActive).toBe(false);
      secondProfileId = res.body.data.id as string;
    });

    it('PATCH /profiles/:id/activate switches active profile', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/v1/profiles/${secondProfileId}/activate`)
        .set('Authorization', `Bearer ${profilesToken}`)
        .expect(200);
      expect(res.body.success).toBe(true);
      const profiles = res.body.data as Array<{
        id: string;
        isActive: boolean;
      }>;
      const second = profiles.find((p) => p.id === secondProfileId)!;
      const first = profiles.find((p) => p.id === firstProfileId)!;
      expect(second.isActive).toBe(true);
      expect(first.isActive).toBe(false);
    });

    it('PATCH /profiles/:id updates profile name', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/v1/profiles/${secondProfileId}`)
        .set('Authorization', `Bearer ${profilesToken}`)
        .send({ name: 'Amma Edited' })
        .expect(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.name).toBe('Amma Edited');
    });

    it('GET /profiles after update → name change reflected', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/profiles')
        .set('Authorization', `Bearer ${profilesToken}`)
        .expect(200);
      const amma = (res.body.data as Array<{ id: string; name: string }>).find(
        (p) => p.id === secondProfileId,
      )!;
      expect(amma.name).toBe('Amma Edited');
    });

    it('PATCH /profiles/nonexistent-id → 404 PROFILE_NOT_FOUND', async () => {
      const res = await request(app.getHttpServer())
        .patch('/v1/profiles/nonexistent-id')
        .set('Authorization', `Bearer ${profilesToken}`)
        .send({ name: 'X' })
        .expect(404);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('PROFILE_NOT_FOUND');
    });

    it('PATCH /profiles/nonexistent-id/activate → 404 PROFILE_NOT_FOUND', async () => {
      const res = await request(app.getHttpServer())
        .patch('/v1/profiles/nonexistent-id/activate')
        .set('Authorization', `Bearer ${profilesToken}`)
        .expect(404);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('PROFILE_NOT_FOUND');
    });

    it('DELETE /profiles without token → 401 AUTH_UNAUTHORIZED', async () => {
      const res = await request(app.getHttpServer())
        .delete(`/v1/profiles/${firstProfileId}`)
        .expect(401);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('AUTH_UNAUTHORIZED');
    });

    it('DELETE /profiles/nonexistent-id → 404 PROFILE_NOT_FOUND', async () => {
      const res = await request(app.getHttpServer())
        .delete('/v1/profiles/nonexistent-id')
        .set('Authorization', `Bearer ${profilesToken}`)
        .expect(404);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('PROFILE_NOT_FOUND');
    });

    it('DELETE /profiles/:id removes profile and returns updated list', async () => {
      const res = await request(app.getHttpServer())
        .delete(`/v1/profiles/${secondProfileId}`)
        .set('Authorization', `Bearer ${profilesToken}`)
        .expect(200);
      expect(res.body.success).toBe(true);
      const ids = (res.body.data as Array<{ id: string }>).map((p) => p.id);
      expect(ids).not.toContain(secondProfileId);
      expect(ids).toContain(firstProfileId);
    });

    it('GET /profiles after delete → deleted profile absent', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/profiles')
        .set('Authorization', `Bearer ${profilesToken}`)
        .expect(200);
      const ids = (res.body.data as Array<{ id: string }>).map((p) => p.id);
      expect(ids).not.toContain(secondProfileId);
    });

    it('DELETE last profile → empty list returned', async () => {
      const res = await request(app.getHttpServer())
        .delete(`/v1/profiles/${firstProfileId}`)
        .set('Authorization', `Bearer ${profilesToken}`)
        .expect(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveLength(0);
    });
  });

  describe('Profiles limit (free tier)', () => {
    let limitApp: INestApplication;
    const limitEmail = 'profiles-limit@example.com';
    const limitPassword = 'StrongPass123!';
    let limitToken: string;

    // Fresh app instance without E2E_MAX_PROFILES; DB is shared so we clear before seeding.
    beforeAll(async () => {
      delete process.env.E2E_MAX_PROFILES;

      const moduleFixture = await Test.createTestingModule({
        imports: [AppModule],
      }).compile();

      limitApp = moduleFixture.createNestApplication();
      limitApp.use(correlationIdMiddleware);
      limitApp.useGlobalFilters(new ApiExceptionFilter());
      limitApp.useGlobalPipes(
        new ValidationPipe({ whitelist: true, transform: true }),
      );
      limitApp.setGlobalPrefix('v1');
      await limitApp.init();
    });

    beforeAll(async () => {
      await clearDatabase(limitApp.get<DataSource>(DataSource));
      await request(limitApp.getHttpServer())
        .post('/v1/auth/register')
        .send({
          email: limitEmail,
          password: limitPassword,
        })
        .expect(201);

      const loginRes = await request(limitApp.getHttpServer())
        .post('/v1/auth/login')
        .send({ email: limitEmail, password: limitPassword })
        .expect(200);

      limitToken = loginRes.body.data.accessToken as string;
    });

    afterAll(async () => {
      await limitApp.close();
    });

    it('POST /profiles when free tier and already 1 profile → 403 PROFILE_LIMIT_EXCEEDED', async () => {
      await request(limitApp.getHttpServer())
        .post('/v1/profiles')
        .set('Authorization', `Bearer ${limitToken}`)
        .send({ name: 'Me' })
        .expect(201);

      const res = await request(limitApp.getHttpServer())
        .post('/v1/profiles')
        .set('Authorization', `Bearer ${limitToken}`)
        .send({ name: 'Second' })
        .expect(403);

      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('PROFILE_LIMIT_EXCEEDED');
      expect(res.body.error.message).toContain('Free plan');
    });
  });

  describe('Communication Preferences', () => {
    const commPrefEmail = 'comm-prefs@example.com';
    const commPrefPassword = 'StrongPass123!';
    let commPrefToken: string;

    beforeAll(async () => {
      await clearDatabase(app.get<DataSource>(DataSource));
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .set('x-forwarded-for', '10.0.1.4')
        .send({
          email: commPrefEmail,
          password: commPrefPassword,
        })
        .expect(201);

      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .set('x-forwarded-for', '10.0.1.4')
        .send({ email: commPrefEmail, password: commPrefPassword })
        .expect(200);

      commPrefToken = loginRes.body.data.accessToken as string;
    });

    it('GET /account/communication-preferences with valid token → 200, returns all 3 categories with mandatory flags', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/account/communication-preferences')
        .set('Authorization', `Bearer ${commPrefToken}`)
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(typeof res.body.correlationId).toBe('string');
      const prefs = res.body.data.preferences as Array<{
        category: string;
        enabled: boolean;
        mandatory: boolean;
      }>;
      expect(prefs).toHaveLength(3);
      const security = prefs.find((p) => p.category === 'security')!;
      expect(security.enabled).toBe(true);
      expect(security.mandatory).toBe(true);
      const compliance = prefs.find((p) => p.category === 'compliance')!;
      expect(compliance.enabled).toBe(true);
      expect(compliance.mandatory).toBe(true);
      const product = prefs.find((p) => p.category === 'product')!;
      expect(product.enabled).toBe(true);
      expect(product.mandatory).toBe(false);
    });

    it('PUT /account/communication-preferences with { productEmails: false } → 200, product disabled', async () => {
      const res = await request(app.getHttpServer())
        .put('/v1/account/communication-preferences')
        .set('Authorization', `Bearer ${commPrefToken}`)
        .send({ productEmails: false })
        .expect(200);

      expect(res.body.success).toBe(true);
      const prefs = res.body.data.preferences as Array<{
        category: string;
        enabled: boolean;
      }>;
      const product = prefs.find((p) => p.category === 'product')!;
      expect(product.enabled).toBe(false);
      const security = prefs.find((p) => p.category === 'security')!;
      expect(security.enabled).toBe(true);
    });

    it('PATCH preference persists — GET after PATCH returns updated value', async () => {
      await request(app.getHttpServer())
        .put('/v1/account/communication-preferences')
        .set('Authorization', `Bearer ${commPrefToken}`)
        .send({ productEmails: true })
        .expect(200);

      const res = await request(app.getHttpServer())
        .get('/v1/account/communication-preferences')
        .set('Authorization', `Bearer ${commPrefToken}`)
        .expect(200);

      const prefs = res.body.data.preferences as Array<{
        category: string;
        enabled: boolean;
      }>;
      const product = prefs.find((p) => p.category === 'product')!;
      expect(product.enabled).toBe(true);
    });

    it('GET /account/communication-preferences without token → 401 AUTH_UNAUTHORIZED', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/account/communication-preferences')
        .expect(401);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('AUTH_UNAUTHORIZED');
    });

    it('PUT /account/communication-preferences without token → 401 AUTH_UNAUTHORIZED', async () => {
      const res = await request(app.getHttpServer())
        .put('/v1/account/communication-preferences')
        .send({ productEmails: false })
        .expect(401);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('AUTH_UNAUTHORIZED');
    });
  });

  describe('Data Export and Account Closure', () => {
    const dataRightsEmail = 'data-rights@example.com';
    const dataRightsPassword = 'StrongPass123!';
    let dataRightsToken: string;

    beforeAll(async () => {
      await clearDatabase(app.get<DataSource>(DataSource));
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .set('x-forwarded-for', '10.0.2.1')
        .send({
          email: dataRightsEmail,
          password: dataRightsPassword,
        })
        .expect(201);

      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .set('x-forwarded-for', '10.0.2.1')
        .send({ email: dataRightsEmail, password: dataRightsPassword })
        .expect(200);

      dataRightsToken = loginRes.body.data.accessToken as string;
    });

    it('POST /account/data-export-requests → 201 with pending request', async () => {
      const res = await request(app.getHttpServer())
        .post('/v1/account/data-export-requests')
        .set('Authorization', `Bearer ${dataRightsToken}`)
        .expect(201);

      expect(res.body.success).toBe(true);
      expect(res.body.data.requestId).toBeDefined();
      expect(res.body.data.status).toBe('pending');
      expect(res.body.data.createdAt).toBeDefined();
    });

    it('POST /account/data-export-requests → GET by requestId → 200 with completed status', async () => {
      const createRes = await request(app.getHttpServer())
        .post('/v1/account/data-export-requests')
        .set('Authorization', `Bearer ${dataRightsToken}`)
        .expect(201);

      const { requestId } = createRes.body.data as { requestId: string };

      const getRes = await request(app.getHttpServer())
        .get(`/v1/account/data-export-requests/${requestId}`)
        .set('Authorization', `Bearer ${dataRightsToken}`)
        .expect(200);

      expect(getRes.body.success).toBe(true);
      expect(getRes.body.data.status).toBe('completed');
      expect(getRes.body.data.downloadUrl).toBeDefined();
    });

    it('GET /account/data-export-requests/:requestId with wrong requestId → 404 EXPORT_REQUEST_NOT_FOUND', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/account/data-export-requests/nonexistent-id')
        .set('Authorization', `Bearer ${dataRightsToken}`)
        .expect(404);

      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('EXPORT_REQUEST_NOT_FOUND');
    });

    it('POST /account/data-export-requests without token → 401 AUTH_UNAUTHORIZED', async () => {
      const res = await request(app.getHttpServer())
        .post('/v1/account/data-export-requests')
        .expect(401);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('AUTH_UNAUTHORIZED');
    });

    it('GET /account/data-export-requests/:requestId without token → 401 AUTH_UNAUTHORIZED', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/account/data-export-requests/some-id')
        .expect(401);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('AUTH_UNAUTHORIZED');
    });

    it('GET /account/closure-request → 200 with null status when no closure requested', async () => {
      const closureEmail = 'pre-closure@example.com';
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .set('x-forwarded-for', '10.0.2.2')
        .send({
          email: closureEmail,
          password: dataRightsPassword,
        })
        .expect(201);
      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .set('x-forwarded-for', '10.0.2.2')
        .send({ email: closureEmail, password: dataRightsPassword })
        .expect(200);
      const token = loginRes.body.data.accessToken as string;

      const res = await request(app.getHttpServer())
        .get('/v1/account/closure-request')
        .set('Authorization', `Bearer ${token}`)
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.status).toBeNull();
    });

    it('POST /account/closure-requests → 201, sessions invalidated', async () => {
      const closureEmail = 'closure-test@example.com';
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .set('x-forwarded-for', '10.0.2.3')
        .send({
          email: closureEmail,
          password: dataRightsPassword,
        })
        .expect(201);
      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .set('x-forwarded-for', '10.0.2.3')
        .send({ email: closureEmail, password: dataRightsPassword })
        .expect(200);
      const token = loginRes.body.data.accessToken as string;

      const res = await request(app.getHttpServer())
        .post('/v1/account/closure-requests')
        .set('Authorization', `Bearer ${token}`)
        .send({ confirmClosure: true })
        .expect(201);

      expect(res.body.success).toBe(true);
      expect(res.body.data.requestId).toBeDefined();
      expect(res.body.data.status).toBe('completed');
      expect(res.body.data.message).toContain('closure');

      const afterClose = await request(app.getHttpServer())
        .get('/v1/account/profile')
        .set('Authorization', `Bearer ${token}`)
        .expect(401);
      expect(afterClose.body.success).toBe(false);
    });

    it('GET /account/closure-request → 200 with completed status after closure processed', async () => {
      const closureEmail = 'closure-get@example.com';
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .set('x-forwarded-for', '10.0.2.4')
        .send({
          email: closureEmail,
          password: dataRightsPassword,
        })
        .expect(201);
      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .set('x-forwarded-for', '10.0.2.4')
        .send({ email: closureEmail, password: dataRightsPassword })
        .expect(200);
      const token = loginRes.body.data.accessToken as string;

      await request(app.getHttpServer())
        .post('/v1/account/closure-requests')
        .set('Authorization', `Bearer ${token}`)
        .send({ confirmClosure: true })
        .expect(201);

      const loginRes2 = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .set('x-forwarded-for', '10.0.2.4')
        .send({ email: closureEmail, password: dataRightsPassword })
        .expect(200);
      const newToken = loginRes2.body.data.accessToken as string;

      const res = await request(app.getHttpServer())
        .get('/v1/account/closure-request')
        .set('Authorization', `Bearer ${newToken}`)
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.status).toBe('completed');
    });

    it('POST /account/closure-requests with confirmClosure: false → 400 CLOSURE_CONFIRMATION_REQUIRED', async () => {
      const closureEmail = 'closure-reject@example.com';
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .set('x-forwarded-for', '10.0.2.5')
        .send({
          email: closureEmail,
          password: dataRightsPassword,
        })
        .expect(201);
      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .set('x-forwarded-for', '10.0.2.5')
        .send({ email: closureEmail, password: dataRightsPassword })
        .expect(200);
      const token = loginRes.body.data.accessToken as string;

      const res = await request(app.getHttpServer())
        .post('/v1/account/closure-requests')
        .set('Authorization', `Bearer ${token}`)
        .send({ confirmClosure: false })
        .expect(400);

      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('CLOSURE_CONFIRMATION_REQUIRED');
    });

    it('POST /account/closure-requests without token → 401 AUTH_UNAUTHORIZED', async () => {
      const res = await request(app.getHttpServer())
        .post('/v1/account/closure-requests')
        .send({ confirmClosure: true })
        .expect(401);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('AUTH_UNAUTHORIZED');
    });

    it('GET /account/closure-request without token → 401 AUTH_UNAUTHORIZED', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/account/closure-request')
        .expect(401);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('AUTH_UNAUTHORIZED');
    });
  });

  describe('Restriction Status', () => {
    const restrictionEmail = 'restriction-test@example.com';
    const restrictionPassword = 'StrongPass123!';
    let restrictionToken: string;

    beforeAll(async () => {
      await clearDatabase(app.get<DataSource>(DataSource));
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .set('x-forwarded-for', '10.0.3.1')
        .send({
          email: restrictionEmail,
          password: restrictionPassword,
        })
        .expect(201);
      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .set('x-forwarded-for', '10.0.3.1')
        .send({ email: restrictionEmail, password: restrictionPassword })
        .expect(200);
      restrictionToken = loginRes.body.data.accessToken as string;
    });

    it('GET /account/restriction with valid token → 200 and isRestricted false', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/account/restriction')
        .set('Authorization', `Bearer ${restrictionToken}`)
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.isRestricted).toBe(false);
      expect(typeof res.body.correlationId).toBe('string');
    });

    it('GET /account/restriction without token → 401 AUTH_UNAUTHORIZED', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/account/restriction')
        .expect(401);

      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('AUTH_UNAUTHORIZED');
    });

    it('GET /account/restriction → 200 with isRestricted true, rationale, nextSteps when user is restricted', async () => {
      const profileRes = await request(app.getHttpServer())
        .get('/v1/account/profile')
        .set('Authorization', `Bearer ${restrictionToken}`)
        .expect(200);
      const userId = profileRes.body.data.id as string;

      await restrictionRepo.save(
        restrictionRepo.create({
          userId,
          isRestricted: true,
          rationale: 'Suspicious activity detected on your account.',
          nextSteps: 'Contact support at support@doclyzer.com to resolve.',
        }),
      );

      const res = await request(app.getHttpServer())
        .get('/v1/account/restriction')
        .set('Authorization', `Bearer ${restrictionToken}`)
        .expect(200);

      expect(res.body.success).toBe(true);
      expect(res.body.data.isRestricted).toBe(true);
      expect(typeof res.body.data.rationale).toBe('string');
      expect(res.body.data.rationale.length).toBeGreaterThan(0);
      expect(typeof res.body.data.nextSteps).toBe('string');
      expect(res.body.data.nextSteps.length).toBeGreaterThan(0);

      // clean up so other tests in this block still see isRestricted: false
      await restrictionRepo.delete({ userId });
    });
  });

  describe('rate limiting', () => {
    beforeEach(async () => {
      await clearDatabase(app.get<DataSource>(DataSource));
    });
    it('enforces rate limiting and returns correct error shape', async () => {
      let rateLimitedRes: request.Response | undefined;

      for (let i = 0; i < 20; i++) {
        const res = await request(app.getHttpServer())
          .post('/v1/auth/login')
          .send({ email: 'ratelimit@example.com', password: 'any' });

        if (res.status === 429) {
          rateLimitedRes = res;
          break;
        }
      }

      expect(rateLimitedRes).toBeDefined();
      expect(rateLimitedRes!.body.success).toBe(false);
      expect(rateLimitedRes!.body.error.code).toBe('AUTH_RATE_LIMITED');
      expect(typeof rateLimitedRes!.body.correlationId).toBe('string');
    });
  });
});
