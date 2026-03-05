/* eslint-disable @typescript-eslint/no-unsafe-argument, @typescript-eslint/no-unsafe-member-access */
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { createHash } from 'node:crypto';
import { AppModule } from '../src/app.module';
import { ApiExceptionFilter } from '../src/common/api-exception.filter';
import { correlationIdMiddleware } from '../src/common/correlation-id.middleware';
import { InMemoryNotificationService } from '../src/common/notification/in-memory-notification.service';
import { NotificationService } from '../src/common/notification/notification.service';
import { PasswordRecoveryService } from '../src/modules/auth/password-recovery.service';

describe('AuthController (e2e)', () => {
  let app: INestApplication;
  let notificationService: InMemoryNotificationService;
  let recoveryService: PasswordRecoveryService;

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
    recoveryService = app.get(PasswordRecoveryService);
  });

  afterAll(async () => {
    await app.close();
  });

  it('registers with policy acknowledgement', async () => {
    const res = await request(app.getHttpServer())
      .post('/v1/auth/register')
      .set('x-correlation-id', 'test-correlation-id')
      .send({
        email: 'user@example.com',
        password: 'StrongPass123!',
        policyAccepted: true,
      })
      .expect(201);

    expect(res.body.success).toBe(true);
    expect(res.body.correlationId).toBe('test-correlation-id');
    expect(res.body.data.requiresVerification).toBe(true);
  });

  it('rejects registration without policy acknowledgement', async () => {
    const res = await request(app.getHttpServer())
      .post('/v1/auth/register')
      .send({
        email: 'user2@example.com',
        password: 'StrongPass123!',
        policyAccepted: false,
      })
      .expect(400);

    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('AUTH_POLICY_ACK_REQUIRED');
    expect(typeof res.body.correlationId).toBe('string');
  });

  it('logs in and logs out with revocation', async () => {
    await request(app.getHttpServer())
      .post('/v1/auth/register')
      .send({
        email: 'logout@example.com',
        password: 'StrongPass123!',
        policyAccepted: true,
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
        policyAccepted: true,
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
        policyAccepted: true,
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

  describe('password recovery', () => {
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
          policyAccepted: true,
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
          policyAccepted: true,
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
          policyAccepted: true,
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
          policyAccepted: true,
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
          policyAccepted: true,
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
          policyAccepted: true,
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
      type TokenMap = Map<string, { expiresAt: Date }>;
      const tokenMap = (
        recoveryService as unknown as { resetTokensByHash: TokenMap }
      ).resetTokensByHash;
      const record = tokenMap.get(tokenHash);
      expect(record).toBeDefined();
      record!.expiresAt = new Date(Date.now() - 1000);

      const res = await request(app.getHttpServer())
        .post('/v1/auth/reset-password')
        .send({ token, newPassword: 'NewPass456!' })
        .expect(400);

      expect(res.body.error.code).toBe('AUTH_RESET_TOKEN_EXPIRED');
    });
  });

  describe('Account Profile', () => {
    const accountEmail = 'account-profile@example.com';
    const accountPassword = 'StrongPass123!';
    let accountToken: string;

    beforeAll(async () => {
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .send({
          email: accountEmail,
          password: accountPassword,
          policyAccepted: true,
        })
        .expect(201);

      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
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

  describe('Consent', () => {
    const consentEmail = 'consent-policy@example.com';
    const consentPassword = 'StrongPass123!';
    let consentToken: string;

    beforeAll(async () => {
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .send({
          email: consentEmail,
          password: consentPassword,
          policyAccepted: true,
        })
        .expect(201);

      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .send({ email: consentEmail, password: consentPassword })
        .expect(200);

      consentToken = loginRes.body.data.accessToken as string;
    });

    it('GET /consent/status without token → 401 AUTH_UNAUTHORIZED', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/consent/status')
        .expect(401);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('AUTH_UNAUTHORIZED');
    });

    it('GET /consent/status with invalid token → 401 AUTH_UNAUTHORIZED', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/consent/status')
        .set('Authorization', 'Bearer invalid-token-xyz')
        .expect(401);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('AUTH_UNAUTHORIZED');
    });

    it('GET /consent/status with valid token → 200, both policies pending', async () => {
      const res = await request(app.getHttpServer())
        .get('/v1/consent/status')
        .set('Authorization', `Bearer ${consentToken}`)
        .expect(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.hasPending).toBe(true);
      expect(res.body.data.policies).toHaveLength(2);
      for (const policy of res.body.data.policies as Array<{
        accepted: boolean;
      }>) {
        expect(policy.accepted).toBe(false);
      }
      expect(typeof res.body.correlationId).toBe('string');
    });

    it('POST /consent/accept without token → 401 AUTH_UNAUTHORIZED', async () => {
      const res = await request(app.getHttpServer())
        .post('/v1/consent/accept')
        .send({ policyTypes: ['terms', 'privacy'] })
        .expect(401);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('AUTH_UNAUTHORIZED');
    });

    it('POST /consent/accept all → 200, GET status shows hasPending false', async () => {
      const acceptRes = await request(app.getHttpServer())
        .post('/v1/consent/accept')
        .set('Authorization', `Bearer ${consentToken}`)
        .send({ policyTypes: ['terms', 'privacy'] })
        .expect(200);
      expect(acceptRes.body.success).toBe(true);
      expect(acceptRes.body.data.hasPending).toBe(false);
      expect(typeof acceptRes.body.correlationId).toBe('string');

      const statusRes = await request(app.getHttpServer())
        .get('/v1/consent/status')
        .set('Authorization', `Bearer ${consentToken}`)
        .expect(200);
      expect(statusRes.body.data.hasPending).toBe(false);
      for (const policy of statusRes.body.data.policies as Array<{
        accepted: boolean;
      }>) {
        expect(policy.accepted).toBe(true);
      }
    });
  });

  describe('Profiles', () => {
    const profilesEmail = 'profiles@example.com';
    const profilesPassword = 'StrongPass123!';
    let profilesToken: string;
    let firstProfileId: string;
    let secondProfileId: string;

    beforeAll(async () => {
      await request(app.getHttpServer())
        .post('/v1/auth/register')
        .send({
          email: profilesEmail,
          password: profilesPassword,
          policyAccepted: true,
        })
        .expect(201);

      const loginRes = await request(app.getHttpServer())
        .post('/v1/auth/login')
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

    it('POST /profiles/:id/activate switches active profile', async () => {
      const res = await request(app.getHttpServer())
        .post(`/v1/profiles/${secondProfileId}/activate`)
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

    it('POST /profiles/nonexistent-id/activate → 404 PROFILE_NOT_FOUND', async () => {
      const res = await request(app.getHttpServer())
        .post('/v1/profiles/nonexistent-id/activate')
        .set('Authorization', `Bearer ${profilesToken}`)
        .expect(404);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('PROFILE_NOT_FOUND');
    });
  });

  describe('Profiles limit (free tier)', () => {
    let limitApp: INestApplication;
    const limitEmail = 'profiles-limit@example.com';
    const limitPassword = 'StrongPass123!';
    let limitToken: string;

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

      await request(limitApp.getHttpServer())
        .post('/v1/auth/register')
        .send({
          email: limitEmail,
          password: limitPassword,
          policyAccepted: true,
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
