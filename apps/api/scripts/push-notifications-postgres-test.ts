import 'reflect-metadata';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { DataSource, Entity, PrimaryColumn } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { CreatePushNotificationTables1730816800000 } from '../src/database/migrations/1730816800000-CreatePushNotificationTables';
import { CompletePushNotifications1730819400000 } from '../src/database/migrations/1730819400000-CompletePushNotifications';
import { UserDeviceTokenEntity } from '../src/database/entities/user-device-token.entity';
import { NotificationsService } from '../src/modules/notifications/notifications.service';
import { PushCampaignService } from '../src/modules/notifications/push-campaign.service';
import {
  PushProviderResult,
  PushProviderService,
  isRetryablePushFailure,
  isInvalidPushToken,
} from '../src/modules/notifications/push-provider.service';
import { validatePushDestination } from '../src/modules/notifications/push-contract';
import { SuperadminGuard } from '../src/modules/auth/superadmin.guard';
import { NotificationsAdminController } from '../src/modules/notifications/notifications.controller';
import { GUARDS_METADATA } from '@nestjs/common/constants';

@Entity('users')
class UserEntity {
  @PrimaryColumn('uuid') id!: string;
}

async function main() {
  const url = process.env.PUSH_TEST_DATABASE_URL;
  if (!url)
    throw new Error(
      'Set PUSH_TEST_DATABASE_URL to a disposable PostgreSQL database',
    );
  const schema = `push_test_${randomUUID().replaceAll('-', '')}`;
  const adminDb = await new DataSource({ type: 'postgres', url }).initialize();
  await adminDb.query('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"');
  await adminDb.query(`CREATE SCHEMA ${schema}`);
  const db = await new DataSource({
    type: 'postgres',
    url,
    schema,
    extra: { options: `-c search_path=${schema},public` },
    entities: [UserDeviceTokenEntity, UserEntity],
  }).initialize();
  try {
    await db.query('CREATE TABLE users(id uuid PRIMARY KEY)');
    await db.query(
      'CREATE TABLE account_preferences(user_id uuid PRIMARY KEY, product_emails_enabled boolean DEFAULT true)',
    );
    const q = db.createQueryRunner();
    await new CreatePushNotificationTables1730816800000().up(q);
    await new CompletePushNotifications1730819400000().up(q);
    const user = randomUUID(),
      other = randomUUID();
    await db.query('INSERT INTO users VALUES($1),($2)', [user, other]);
    await db.query(
      'INSERT INTO account_preferences(user_id,marketing_push_enabled) VALUES($1,true),($2,false)',
      [user, other],
    );
    const config = new ConfigService({
      push: { provider: 'mock', adminApprovalSecret: 'test-approval' },
    });
    let calls = 0,
      failure: string | null = null;
    const provider = {
      providerName: 'mock',
      send: async (): Promise<PushProviderResult> => {
        calls++;
        return {
          outcome: failure ? 'failed' : 'sent',
          provider: 'mock',
          providerMessageId: failure ? null : randomUUID(),
          errorCode: failure,
          errorMessage: null,
        };
      },
    } as unknown as PushProviderService;
    const campaigns = new PushCampaignService(db, provider, config);
    const registry = new NotificationsService(
      db.getRepository(UserDeviceTokenEntity),
      {} as never,
      {} as never,
      {} as never,
      {} as never,
      {} as never,
      {} as never,
      {} as never,
      provider,
      config,
      campaigns,
    );
    const register = (
      owner: string,
      installation: string,
      token: string,
      prefs?: Record<string, boolean>,
    ) =>
      registry.registerDeviceToken(owner, {
        token: token.padEnd(24, 'x'),
        installationId: installation,
        platform: 'android',
        notificationPermission: 'authorized',
        preferences: prefs,
      }) as Promise<{ id: string }>;
    const first = await register(user, 'install-one', 'token-one', {
      marketing: true,
    });
    const concurrent = await Promise.all(
      Array.from({ length: 5 }, () =>
        register(user, 'install-one', 'token-two'),
      ),
    );
    assert(concurrent.every((r) => r.id === first.id));
    assert.equal(await db.getRepository(UserDeviceTokenEntity).count(), 1);
    assert.equal(
      (
        await db
          .getRepository(UserDeviceTokenEntity)
          .findOneByOrFail({ id: first.id })
      ).preferences?.marketing,
      true,
      'refresh preserves opt-in',
    );
    const second = await register(user, 'install-two', 'token-three', {
      marketing: true,
    });
    await register(other, 'denied-device', 'token-four', { marketing: true });
    const draft = () => ({
      name: 'Campaign',
      title: 'Test message',
      body: 'Safe generic content',
      audience: 'all' as const,
      platform: 'all',
      deepLink: '/notifications',
      idempotencyKey: randomUUID(),
    });
    const dto = draft();
    const [a, b] = await Promise.all([
      campaigns.create(user, dto),
      campaigns.create(user, dto),
    ]);
    assert.equal(a.id, b.id, 'idempotent concurrent creation');
    assert.equal(
      (await campaigns.preview(a.id)).devices,
      2,
      'account consent required',
    );
    await assert.rejects(() => campaigns.schedule(user, a.id, {}), /approval/);
    await campaigns.schedule(user, a.id, {
      scheduledAt: new Date(Date.now() + 3600000).toISOString(),
      approvalToken: 'test-approval',
    });
    await campaigns.tick();
    assert.equal(calls, 0, 'future schedule does not send');
    await campaigns.cancel(user, a.id);
    await assert.rejects(
      () => campaigns.schedule(user, a.id, { approvalToken: 'test-approval' }),
      /draft/,
    );
    const live = await campaigns.create(user, draft());
    await campaigns.schedule(user, live.id, { approvalToken: 'test-approval' });
    await Promise.all([campaigns.tick(), campaigns.tick()]);
    assert.equal(calls, 2, 'concurrent workers do not double claim');
    const [r] = await db.query(
      'SELECT * FROM push_recipients WHERE campaign_id=$1 ORDER BY id',
      [live.id],
    );
    await assert.rejects(
      () =>
        campaigns.recordEvent(other, {
          recipientId: r.id,
          eventType: 'opened',
        }),
      /not found/,
    );
    await campaigns.recordEvent(user, {
      recipientId: r.id,
      eventType: 'opened',
    });
    await campaigns.recordEvent(user, {
      recipientId: r.id,
      eventType: 'opened',
    });
    assert.equal(
      (await campaigns.analytics(live.id)).opens,
      1,
      'opens are deduplicated',
    );
    assert.equal(
      (
        await db.query(
          "SELECT count(*)::int n FROM push_events WHERE recipient_id=$1 AND event_type='opened'",
          [r.id],
        )
      )[0].n,
      1,
    );
    await register(other, 'install-one', 'token-two');
    const moved = await db
      .getRepository(UserDeviceTokenEntity)
      .findOneByOrFail({ id: first.id });
    assert.equal(moved.userId, other);
    assert.equal(
      moved.preferences?.marketing,
      false,
      'switch resets device consent',
    );
    await assert.rejects(
      () => registry.deactivateDeviceToken(user, first.id),
      /not found/i,
    );
    assert.equal((await campaigns.preview(live.id)).devices, 1);
    // Re-check consent after materialization, before delivery.
    const suppressed = await campaigns.create(user, draft());
    await campaigns.schedule(user, suppressed.id, {
      approvalToken: 'test-approval',
    });
    await (campaigns as any).materialize();
    await registry.updateDeviceTokenPreferences(user, second.id, {
      preferences: { marketing: false },
    });
    const before = calls;
    await campaigns.tick();
    assert.equal(calls, before);
    assert.equal((await campaigns.analytics(suppressed.id)).skipped, 1);
    await registry.updateDeviceTokenPreferences(user, second.id, {
      preferences: { marketing: true },
    });
    failure = 'messaging/server-unavailable';
    const retry = await campaigns.create(user, draft());
    await campaigns.schedule(user, retry.id, {
      approvalToken: 'test-approval',
    });
    await campaigns.tick();
    assert.equal(
      (
        await db.query(
          'SELECT status FROM push_recipients WHERE campaign_id=$1',
          [retry.id],
        )
      )[0].status,
      'queued',
    );
    failure = null;
    await db.query(
      'UPDATE push_recipients SET available_at=now() WHERE campaign_id=$1',
      [retry.id],
    );
    await campaigns.tick();
    assert.equal((await campaigns.analytics(retry.id)).accepted, 1);
    failure = 'messaging/registration-token-not-registered';
    const dead = await campaigns.create(user, draft());
    await campaigns.schedule(user, dead.id, { approvalToken: 'test-approval' });
    await campaigns.tick();
    assert.equal(
      (
        await db
          .getRepository(UserDeviceTokenEntity)
          .findOneByOrFail({ id: second.id })
      ).active,
      false,
    );
    assert.equal((await campaigns.analytics(dead.id)).failed, 1);
    assert.equal(isRetryablePushFailure('messaging/invalid-argument'), false);
    assert.equal(isInvalidPushToken('messaging/invalid-argument'), false);
    for (const value of [
      'https://evil.test',
      '//evil.test',
      '/reports/../../account',
      'javascript:alert(1)',
      '/account?token=secret',
    ])
      assert.throws(() => validatePushDestination(value));
    assert.equal(validatePushDestination('/reports'), '/reports');
    assert(
      Reflect.getMetadata(
        GUARDS_METADATA,
        NotificationsAdminController,
      ).includes(SuperadminGuard),
    );
    const guard = new SuperadminGuard({
      findOne: async () => ({ role: 'user' }),
    } as never);
    await assert.rejects(
      () =>
        guard.canActivate({
          switchToHttp: () => ({ getRequest: () => ({ user: { id: user } }) }),
        } as never),
      /Superadmin/,
    );
    const prodMock = new PushProviderService(
      new ConfigService({ NODE_ENV: 'production', push: { provider: 'mock' } }),
    );
    assert.equal(
      (await prodMock.send({ token: 'secret', title: 'Test', body: 'Test' }))
        .outcome,
      'failed',
    );
    // A stale logout must not restore ownership or deactivate a newly assigned account.
    const racing = await register(user, 'race-install', 'race-token');
    await Promise.allSettled([
      registry.deactivateDeviceToken(user, racing.id),
      register(other, 'race-install', 'race-token'),
      registry.updateDeviceTokenPreferences(user, racing.id, {
        preferences: { marketing: true },
      }),
    ]);
    const afterRace = await db
      .getRepository(UserDeviceTokenEntity)
      .findOneByOrFail({ id: racing.id });
    assert.equal(afterRace.userId, other);
    assert.equal(afterRace.active, true);
    assert.equal(afterRace.preferences?.marketing, false);
    // Platform permission and explicit logout are independent of account intent.
    const denied = await register(user, 'denied-permission', 'token-denied', {
      marketing: true,
    });
    await db.query(
      "UPDATE user_device_tokens SET notification_permission='denied' WHERE id=$1",
      [denied.id],
    );
    assert.equal((await campaigns.preview(live.id)).devices, 0);
    await registry.deactivateDeviceToken(user, denied.id);
    assert.equal(
      (
        await db
          .getRepository(UserDeviceTokenEntity)
          .findOneByOrFail({ id: denied.id })
      ).active,
      false,
    );
    // Test sends have a distinct history/recipient set and never affect source metrics.
    failure = null;
    const testDevice = await register(user, 'internal-test', 'token-internal', {
      marketing: true,
    });
    const testSend = await campaigns.test(user, live.id);
    await campaigns.tick();
    assert.notEqual(testSend.id, live.id);
    assert.equal((await campaigns.analytics(testSend.id)).accepted, 1);
    assert.equal((await campaigns.analytics(live.id)).accepted, 2);
    await registry.deactivateDeviceToken(user, testDevice.id);
    // A larger audience is materialized in bounded pages without duplicate rows.
    await db.query(
      `INSERT INTO user_device_tokens(id,user_id,token_hash,provider_token,platform,last_seen_at,notification_permission,preferences)
      SELECT gen_random_uuid(),$1,md5('bulk-'||n),'bulk-'||n,'android',now(),'authorized','{"marketing":true}'::jsonb
      FROM generate_series(1,501) n`,
      [user],
    );
    const large = await campaigns.create(user, draft());
    await campaigns.update(user, large.id, {
      ...draft(),
      name: 'Edited draft',
    });
    await campaigns.schedule(user, large.id, {
      approvalToken: 'test-approval',
    });
    await assert.rejects(
      () => campaigns.update(user, large.id, draft()),
      /draft/,
    );
    await (campaigns as any).materialize();
    assert.equal(
      (
        await db.query(
          'SELECT count(*)::int n FROM push_recipients WHERE campaign_id=$1',
          [large.id],
        )
      )[0].n,
      500,
    );
    await (campaigns as any).materialize();
    assert.equal(
      (
        await db.query(
          'SELECT count(*)::int n FROM push_recipients WHERE campaign_id=$1',
          [large.id],
        )
      )[0].n,
      501,
    );
    assert.equal(
      (
        await db.query('SELECT materialized FROM push_campaigns WHERE id=$1', [
          large.id,
        ])
      )[0].materialized,
      true,
    );
    await new CompletePushNotifications1730819400000().down(q);
    await q.release();
    console.log(
      'Push PostgreSQL tests passed: registry, concurrency, consent, scheduling, cancellation, retries, invalid tokens, analytics ownership, RBAC, payloads, migration rollback.',
    );
  } finally {
    await db.destroy();
    await adminDb.query(`DROP SCHEMA ${schema} CASCADE`);
    await adminDb.destroy();
  }
}
void main().catch((e) => {
  console.error(e);
  process.exitCode = 1;
});
