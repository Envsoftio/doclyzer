import { spawn, type ChildProcess } from 'node:child_process';
import { once, EventEmitter } from 'node:events';
import { PDFDocument, StandardFonts } from 'pdf-lib';
import { ReportProcessingController } from '../src/modules/reports/processing/report-processing.controller';
import type { Response, Request } from 'express';
import 'reflect-metadata';
import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { createServer } from 'node:http';
import { DataSource } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { migrations } from '../src/database/migrations';
import { ReportAdmissionService } from '../src/modules/reports/processing/report-admission.service';
import { ReportJobStore } from '../src/modules/reports/processing/report-job.store';
import { ReportStreamService } from '../src/modules/reports/processing/report-stream.service';
import { ReportDispatcherService } from '../src/modules/reports/processing/report-dispatcher.service';
import { DoclingTaskClient } from '../src/modules/reports/processing/docling-task.client';
import { processingSettings } from '../src/modules/reports/processing/processing-settings';
import { RepairReportProviderSubmissionCount1730818200000 } from '../src/database/migrations/1730818200000-RepairReportProviderSubmissionCount';
import type { FileStorageService } from '../src/common/storage/file-storage.interface';
import type { PushProviderService } from '../src/modules/notifications/push-provider.service';
import type { NotificationPipelineService } from '../src/common/notification-pipeline/notification-pipeline.service';
import type { ReferralsService } from '../src/modules/referrals/referrals.service';
import type { ReportsService } from '../src/modules/reports/reports.service';
import {
  retryReportProcessing,
  cancelReportProcessing,
} from '../src/modules/reports/processing/report-lifecycle';

async function main() {
  const url = process.env.REPORT_PROCESSING_TEST_DATABASE_URL;
  if (!url) throw new Error('Set REPORT_PROCESSING_TEST_DATABASE_URL');
  const admin = await new DataSource({ type: 'postgres', url }).initialize();
  const name = `doclyzer_test_processing_${randomUUID().replaceAll('-', '')}`;
  await admin.query(`CREATE DATABASE ${name}`);
  const testUrl = new URL(url);
  testUrl.pathname = `/${name}`;
  const db = await new DataSource({
    type: 'postgres',
    url: testUrl.toString(),
    migrations,
    extra: { max: 8 },
  }).initialize();
  let holdStatus = false;
  let child: ChildProcess | null = null;
  let submits = 0,
    partial = false,
    unavailable = false;
  const provider = createServer((req, res) => {
    if (req.url?.startsWith('/fixture-bucket/')) {
      const key = req.url.slice('/fixture-bucket/'.length).split('?')[0];
      const value = bytes.get(decodeURIComponent(key));
      if (!value) {
        res.writeHead(404);
        res.end();
      } else {
        res.setHeader('Content-Length', value.length);
        res.end(value);
      }
      return;
    }
    if (req.url?.includes('/file/async')) {
      submits++;
      req.resume();
      if (unavailable) {
        res.writeHead(503, { 'Retry-After': '7' });
        res.end('{}');
        return;
      }
      res.setHeader('Content-Type', 'application/json');
      res.end(
        JSON.stringify({ task_id: 'fixture-task', task_status: 'pending' }),
      );
    } else if (req.url?.includes('/poll/')) {
      res.end(
        JSON.stringify({ task_status: holdStatus ? 'pending' : 'success' }),
      );
    } else if (req.url?.includes('/result/')) {
      res.end(
        JSON.stringify({
          status: partial ? 'partial_success' : 'success',
          document: {
            md_content: 'Synthetic lab result: haemoglobin 13.5 g/dL',
            json_content: {
              schema_name: 'DoclingDocument',
              texts: [],
              tables: [],
            },
          },
        }),
      );
    } else {
      res.writeHead(404);
      res.end();
    }
  });
  await new Promise<void>((resolve) =>
    provider.listen(0, '127.0.0.1', resolve),
  );
  const address = provider.address() as { port: number };
  const config = new ConfigService({
    REPORT_ASYNC_RUNTIME_ENABLED: 'true',
    REPORT_PROCESS_ROLE: 'test',
    REPORT_COMPLETION_PUSH_ENABLED: 'true',
    DOCLING_OCR_BASE_URL: `http://127.0.0.1:${address.port}`,
    REPORT_PROVIDER_REQUEST_MS: 1000,
  });
  const settings = processingSettings(config);
  const bytes = new Map<string, Buffer>();
  const storage: FileStorageService = {
    durability: 'durable',
    async upload(k, b) {
      bytes.set(k, b);
      return k;
    },
    async get(k) {
      return bytes.get(k)!;
    },
    async delete(k) {
      bytes.delete(k);
    },
    async deletePrefix(prefix) {
      for (const key of bytes.keys()) if (key.startsWith(prefix)) bytes.delete(key);
    },
    async getSignedUrl() {
      return '';
    },
  }; // Test double only.
  try {
    await db.runMigrations();
    // Exercise both the repair and original runtime migration down/up against
    // the full historical schema.
    await db.undoLastMigration();
    await db.undoLastMigration();
    await db.runMigrations();
    // Reproduce an already-applied older runtime migration that lacks the
    // provider submission budget column, then verify the forward repair.
    await db.query(
      'ALTER TABLE report_processing_jobs DROP COLUMN provider_submission_count',
    );
    const repair = new RepairReportProviderSubmissionCount1730818200000();
    await db.transaction(async (manager) => repair.up(manager.queryRunner!));
    await db.query(
      'SELECT provider_submission_count FROM report_processing_jobs LIMIT 0',
    );
    const user = randomUUID(),
      other = randomUUID(),
      profile = randomUUID(),
      device = randomUUID();
    await db.query(
      "INSERT INTO users(id,email) VALUES($1,'runtime@example.test'),($2,'other@example.test')",
      [user, other],
    );
    await db.query(
      "INSERT INTO profiles(id,user_id,name) VALUES($1,$2,'Test')",
      [profile, user],
    );
    const [plan] = await db.query(
      "SELECT id FROM plans WHERE tier='free' LIMIT 1",
    );
    await db.query(
      'INSERT INTO user_entitlements(user_id,plan_id) VALUES($1,$2)',
      [user, plan.id],
    );
    await db.query(
      "INSERT INTO user_device_tokens(id,user_id,token_hash,provider_token,platform,provider,active,last_seen_at) VALUES($1,$2,$3,'fixture-token','android','fcm',true,now())",
      [device, user, 'a'.repeat(64)],
    );
    // Email preference must not suppress product push eligibility.
    await db.query(
      'INSERT INTO account_preferences(user_id,product_emails_enabled) VALUES($1,false)',
      [user],
    );
    const admission = new ReportAdmissionService(db, storage, settings.policy),
      jobs = new ReportJobStore(db, 60000),
      streams = new ReportStreamService(db, config);
    const accept = (key: string) =>
      admission.accept({
        userId: user,
        profileId: profile,
        idempotencyKey: key,
        file: {
          buffer: Buffer.from(key),
          originalname: 'fixture.pdf',
          mimetype: 'application/pdf',
        },
      });
    const accepted = await accept('runtime-one');
    const snapshot = await streams.snapshot(user);
    assert.equal(snapshot.reports.length, 1);
    assert.equal((await streams.snapshot(other)).reports.length, 0);
    const lease = (await jobs.claim())!;
    const client = new DoclingTaskClient(db, settings);
    const result = await client.convert(
      Buffer.from('synthetic fixture'),
      lease,
      new AbortController().signal,
    );
    assert.ok(result.text);
    assert.equal(submits, 1);
    const [checkpoint] = await db.query(
      'SELECT provider_task_id,staged_result,submission_uncertain_at FROM report_processing_jobs WHERE id=$1',
      [lease.jobId],
    );
    assert.equal(checkpoint.provider_task_id, 'fixture-task');
    assert.ok(checkpoint.staged_result);
    assert.equal(checkpoint.submission_uncertain_at, null);
    await client.convert(
      Buffer.from('synthetic fixture'),
      lease,
      new AbortController().signal,
    );
    assert.equal(submits, 1, 'staged result prevents resubmission');
    await client.saveCascadeCandidate(lease, 1, 'paddleocr-v5', {
      text: 'synthetic',
      parsedJson: { type: 'document', kids: [] },
    });
    const resumedOcr = await client.convert(
      Buffer.from('synthetic fixture'),
      lease,
      new AbortController().signal,
    );
    assert.deepEqual(
      Object.keys(resumedOcr.cascadeProgress?.['1'] ?? {}).sort(),
      ['paddleocr-v5'],
    );
    await jobs.complete(lease, 'ready', async () => {});
    const replay = await streams.replay(user, snapshot.cursor);
    assert.equal(replay.reset, false);
    assert.deepEqual(
      replay.events.map((e: { status: string }) => e.status),
      ['processing', 'ready'],
    );
    assert.equal((await streams.replay(other, '0')).events.length, 0);
    assert.equal((await streams.replay(user, 'not-a-cursor')).reset, true);
    let pushes = 0,
      emails = 0,
      referrals = 0;
    const dispatcher = new ReportDispatcherService(
      db,
      config,
      {
        providerName: 'fcm',
        send: async () => {
          pushes++;
          return {
            outcome: 'sent',
            providerMessageId: 'fixture-accepted',
            errorCode: null,
          };
        },
      } as unknown as PushProviderService,
      {
        dispatch: async () => {
          emails++;
        },
        dispatchOpsAlert: async () => {},
      } as unknown as NotificationPipelineService,
      {
        triggerMilestoneAForSuccessfulAnalysis: async () => {
          referrals++;
        },
      } as unknown as ReferralsService,
      {} as ReportsService,
    );
    await dispatcher.materialize();
    await dispatcher.materialize();
    assert.equal((await db.query('SELECT * FROM report_inbox')).length, 1);
    assert.equal(
      (await db.query('SELECT * FROM report_delivery_intents')).length,
      3,
    );
    for (let i = 0; i < 4; i++) await dispatcher.deliver();
    assert.equal(pushes, 1);
    assert.equal(emails, 1);
    assert.equal(referrals, 1);
    assert.equal(
      (
        await db.query(
          "SELECT * FROM report_delivery_intents WHERE state='accepted'",
        )
      ).length,
      3,
    );
    await dispatcher.materialize();
    await dispatcher.deliver();
    assert.equal(pushes, 1);
    // Account reassignment between intent creation and dispatch must suppress push.
    const second = await accept('runtime-two'),
      lease2 = (await jobs.claim())!;
    await jobs.complete(lease2, 'needs_attention', async () => {});
    await dispatcher.materialize();
    await db.query('UPDATE user_device_tokens SET user_id=$1 WHERE id=$2', [
      other,
      device,
    ]);
    for (let i = 0; i < 3; i++) await dispatcher.deliver();
    assert.equal(pushes, 1);
    // Manual retry creates a new generation and cancellation fences it.
    await retryReportProcessing(db, user, second.reportId, settings.policy);
    const retry = (await jobs.claim())!;
    assert.equal(retry.generation, 2);
    await cancelReportProcessing(db, user, second.reportId, true);
    await assert.rejects(jobs.complete(retry, 'ready', async () => {}));
    assert.equal(
      (await streams.snapshot(user)).reports.some(
        (r: { reportId: string }) => r.reportId === second.reportId,
      ),
      false,
    );
    // No format/host fallback on submission 503, and partial output cannot be ready.
    const third = await accept('runtime-three'),
      lease3 = (await jobs.claim())!;
    unavailable = true;
    const before = submits;
    await assert.rejects(
      client.convert(
        Buffer.from('fixture'),
        lease3,
        new AbortController().signal,
      ),
      (error: any) =>
        error.code === 'PROVIDER_UNAVAILABLE' && error.retryAfterMs === 7000,
    );
    assert.equal(submits, before + 1);
    unavailable = false;
    partial = true;
    await assert.rejects(
      client.convert(
        Buffer.from('fixture'),
        lease3,
        new AbortController().signal,
      ),
      /INVALID_CONTENT/,
    );
    await jobs.fail(lease3, 'INVALID_CONTENT', null);
    // Snapshot handoff and expired cursor reset after atomic retention.
    await dispatcher.materialize();
    await db.query(
      "UPDATE report_processing_events SET created_at=now()-interval '10 days'",
    );
    await dispatcher.retain();
    assert.equal((await streams.replay(user, '0')).reset, true);
    const fresh = await streams.snapshot(user);
    assert.equal((await streams.replay(user, fresh.cursor)).reset, false);
    const session = randomUUID();
    await db.query(
      "INSERT INTO sessions(id,user_id,token,expires_at) VALUES($1,$2,'fixture-session',now()+interval '1 hour')",
      [session, user],
    );
    const controller = new ReportProcessingController(
      db,
      config,
      storage,
      {} as never,
      {} as never,
      { enforceRateLimit: () => {} } as never,
      streams,
    );
    const request = {
      user: { id: user },
      currentSessionId: session,
      header: () => undefined,
      query: { cursor: fresh.cursor },
    } as unknown as Request;
    class FixtureResponse extends EventEmitter {
      frames: string[] = [];
      ended = false;
      status() {
        return this;
      }
      set() {
        return this;
      }
      flushHeaders() {}
      write(frame: string) {
        this.frames.push(frame);
        return true;
      }
      end() {
        this.ended = true;
      }
    }
    const response = new FixtureResponse();
    await controller.events(request, response as unknown as Response);
    const wait = async (check: () => Promise<boolean>, label: string) => {
      for (let n = 0; n < 400; n++) {
        if (await check()) return;
        await new Promise((resolve) => setTimeout(resolve, 50));
      }
      throw new Error(`Timed out: ${label}`);
    };
    await wait(async () => response.frames.length > 0, 'SSE heartbeat');
    await db.query('DELETE FROM sessions WHERE id=$1', [session]);
    await wait(async () => response.ended, 'session revocation closes SSE');
    // A real separate Nest worker is killed after durable provider submission.
    // Its replacement must recover the lease and reuse that task ID.
    partial = false;
    holdStatus = true;
    const pdf = await PDFDocument.create(),
      font = await pdf.embedFont(StandardFonts.Helvetica);
    pdf
      .addPage()
      .drawText('Synthetic laboratory report. Haemoglobin 13.5 g/dL', {
        x: 40,
        y: 700,
        font,
        size: 12,
      });
    const work = await admission.accept({
      userId: user,
      profileId: profile,
      idempotencyKey: 'process-crash',
      file: {
        buffer: Buffer.from(await pdf.save()),
        originalname: 'synthetic.pdf',
        mimetype: 'application/pdf',
      },
    });
    const startChild = () =>
      spawn(process.execPath, ['dist/apps/api/src/report-worker.js'], {
        stdio: ['ignore', 'pipe', 'pipe'],
        env: {
          ...process.env,
          DATABASE_URL: testUrl.toString(),
          NODE_ENV: 'test',
          REPORT_PROCESS_ROLE: 'worker',
          REPORT_ASYNC_RUNTIME_ENABLED: 'true',
          REPORT_ASYNC_ACCEPTANCE_ENABLED: 'false',
          REPORT_LEASE_MS: '3000',
          REPORT_WORKER_CONCURRENCY: '1',
          B2_DISABLED: 'false',
          B2_KEY_ID: 'fixture',
          B2_APPLICATION_KEY: 'fixture',
          B2_BUCKET_NAME: 'fixture-bucket',
          B2_ENDPOINT: `http://127.0.0.1:${address.port}`,
          B2_REGION: 'test',
          DOCLING_OCR_BASE_URL: `http://127.0.0.1:${address.port}`,
          DOCLING_API_KEY: '',
          REPORT_SUMMARY_ENABLED: 'false',
          REPORT_LAB_AI_FALLBACK_ENABLED: 'false',
          EMAIL_WORKER_ENABLED: 'false',
          REPORT_COMPLETION_PUSH_ENABLED: 'false',
        },
      });
    const submissionsBefore = submits;
    child = startChild();
    let childOutput = '';
    child.stdout?.on('data', (chunk) => {
      childOutput = (childOutput + String(chunk)).slice(-4000);
    });
    child.stderr?.on('data', (chunk) => {
      childOutput = (childOutput + String(chunk)).slice(-4000);
    });
    await wait(async () => {
      if (child?.exitCode !== null)
        throw new Error(`Worker startup failed: ${childOutput}`);
      const [j] = await db.query(
        'SELECT provider_task_id FROM report_processing_jobs WHERE report_id=$1',
        [work.reportId],
      );
      return Boolean(j.provider_task_id);
    }, 'worker provider checkpoint');
    const dead = once(child, 'exit');
    child.kill('SIGKILL');
    await dead;
    child = startChild();
    child.stdout?.resume();
    child.stderr?.resume();
    await wait(async () => {
      const [j] = await db.query(
        'SELECT attempt_count FROM report_processing_jobs WHERE report_id=$1',
        [work.reportId],
      );
      return j.attempt_count === 2;
    }, 'replacement lease');
    holdStatus = false;
    await wait(async () => {
      const [r] = await db.query(
        'SELECT processing_state FROM reports WHERE id=$1',
        [work.reportId],
      );
      return ['ready', 'needs_attention'].includes(r.processing_state);
    }, 'worker completion');
    assert.equal(
      submits,
      submissionsBefore + 1,
      'replacement reuses provider task',
    );
    const stopped = once(child, 'exit');
    child.kill('SIGTERM');
    await stopped;
    child = null;
    console.log(
      'PASS actual Nest worker process kill/restart, provider task reuse, extraction adapter and graceful shutdown; SSE session revocation',
    );
    assert.ok(accepted.reportId && third.reportId);
    console.log(
      'PASS full migration chain and runtime: checkpoint/reuse, no POST fallback, partial rejection, snapshot/replay authorization, delivery deduplication, token reassignment, retry/cancel and retention reset',
    );
  } finally {
    if (child && child.exitCode === null) {
      const exit = once(child, 'exit');
      child.kill('SIGKILL');
      await exit;
    }
    provider.closeAllConnections();
    await new Promise<void>((resolve) => provider.close(() => resolve()));
    await db.destroy();
    await admin.query(`DROP DATABASE ${name} WITH (FORCE)`);
    await admin.destroy();
  }
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
