/* eslint-disable @typescript-eslint/no-unsafe-argument, @typescript-eslint/no-unsafe-member-access */
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { ApiExceptionFilter } from '../src/common/api-exception.filter';
import { correlationIdMiddleware } from '../src/common/correlation-id.middleware';

describe('AuthController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.use(correlationIdMiddleware);
    app.useGlobalFilters(new ApiExceptionFilter());
    app.setGlobalPrefix('v1');
    await app.init();
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
});
