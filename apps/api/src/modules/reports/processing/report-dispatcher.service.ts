import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { DataSource } from 'typeorm';
import { randomUUID } from 'node:crypto';
import { PushProviderService } from '../../notifications/push-provider.service';
import { NotificationPipelineService } from '../../../common/notification-pipeline/notification-pipeline.service';
import { NotifiableEventType } from '../../../common/notification-pipeline/notification-event.types';
import { ReferralsService } from '../../referrals/referrals.service';
import { ReportsService } from '../reports.service';
import { processingSettings } from './processing-settings';
@Injectable()
export class ReportDispatcherService {
  private readonly log = new Logger(ReportDispatcherService.name);
  constructor(
    private readonly db: DataSource,
    private readonly config: ConfigService,
    private readonly push: PushProviderService,
    private readonly email: NotificationPipelineService,
    private readonly referrals: ReferralsService,
    private readonly reports: ReportsService,
  ) {}
  async run(signal: AbortSignal) {
    const s = processingSettings(this.config);
    if (s.pushEnabled && this.push.providerName !== 'fcm')
      throw new Error('Completion push requires configured FCM credentials');
    let nextRetention = 0;
    while (!signal.aborted) {
      try {
        await this.materialize();
        await this.deliver();
        if (Date.now() > nextRetention) {
          nextRetention = Date.now() + 60000;
          await this.retain();
        }
      } catch {
        this.log.error('REPORT_DISPATCH_ITERATION_FAILED');
      }
      await new Promise((resolve) => setTimeout(resolve, 1000));
    }
  }
  async materialize() {
    const s = processingSettings(this.config);
    await this.db.transaction(async (m) => {
      const events = await m.query(
        `SELECT e.* FROM report_processing_events e WHERE e.dispatched_at IS NULL ORDER BY e.created_at LIMIT 50 FOR UPDATE OF e SKIP LOCKED`,
      );
      for (const e of events) {
        if (['ready', 'needs_attention', 'failed'].includes(e.status)) {
          const [r] = await m.query(
            'SELECT id FROM reports WHERE id=$1 AND user_id=$2 AND processing_generation=$3 AND deleted_at IS NULL',
            [e.report_id, e.user_id, e.generation],
          );
          if (r) {
            const id = randomUUID();
            await m.query(
              `INSERT INTO report_inbox(id,user_id,report_id,generation,status) VALUES($1,$2,$3,$4,$5) ON CONFLICT(report_id,generation) DO NOTHING`,
              [id, e.user_id, e.report_id, e.generation, e.status],
            );
            const [inbox] = await m.query(
              'SELECT id FROM report_inbox WHERE report_id=$1 AND generation=$2',
              [e.report_id, e.generation],
            );
            const channels: { channel: string; target: string }[] = [
              { channel: 'email', target: 'account' },
            ];
            if (e.status === 'ready') {
              channels.push({ channel: 'referral', target: 'account' });
              // Raw-document summaries are disabled at the privacy boundary.
              await m.query(
                "UPDATE reports SET summary_status='not_requested' WHERE id=$1",
                [e.report_id],
              );
            }
            if (e.status === 'failed')
              channels.push({ channel: 'ops', target: 'ops' });
            if (s.pushEnabled) {
              const tokens = await m.query(
                `SELECT id FROM user_device_tokens WHERE user_id=$1 AND active AND COALESCE((preferences->>'product')::boolean,true)`,
                [e.user_id],
              );
              for (const token of tokens)
                channels.push({ channel: 'push', target: token.id });
            }
            for (const channel of channels)
              await m.query(
                `INSERT INTO report_delivery_intents(id,inbox_id,channel,target,expires_at) VALUES($1,$2,$3,$4,clock_timestamp()+$5*interval '1 millisecond') ON CONFLICT(inbox_id,channel,target) DO NOTHING`,
                [
                  randomUUID(),
                  inbox.id,
                  channel.channel,
                  channel.target,
                  s.notificationExpiryMs,
                ],
              );
          }
        }
        await m.query(
          'UPDATE report_processing_events SET dispatched_at=clock_timestamp() WHERE user_id=$1 AND cursor=$2',
          [e.user_id, e.cursor],
        );
      }
    });
  }
  async deliver() {
    const token = randomUUID();
    const delivery = await this.db.transaction(async (m) => {
      const [d] = await m.query(`SELECT * FROM report_delivery_intents WHERE
        (state='pending' AND available_at<=clock_timestamp()) OR (state='sending' AND lease_until<=clock_timestamp())
        ORDER BY available_at LIMIT 1 FOR UPDATE SKIP LOCKED`);
      if (!d) return null;
      if (new Date(d.expires_at).getTime() <= Date.now() || d.attempts >= 8) {
        await m.query(
          `UPDATE report_delivery_intents SET state='failed',error_code='DELIVERY_EXHAUSTED',lease_token=NULL,lease_until=NULL,completed_at=clock_timestamp() WHERE id=$1`,
          [d.id],
        );
        this.log.error('REPORT_DELIVERY_EXHAUSTED');
        return null;
      }
      await m.query(
        `UPDATE report_delivery_intents SET state='sending',attempts=attempts+1,lease_token=$2,lease_until=clock_timestamp()+interval '5 minutes' WHERE id=$1`,
        [d.id, token],
      );
      return d;
    });
    if (!delivery) return;
    let retryAfterMs = 0;
    let outcome = 'accepted',
      error: string | null = null,
      messageId: string | null = null;
    try {
      const [r] = await this.db.query(
        `SELECT i.*,r.profile_id,r.processing_generation,r.deleted_at FROM report_inbox i JOIN reports r ON r.id=i.report_id WHERE i.id=$1 AND r.user_id=i.user_id`,
        [delivery.inbox_id],
      );
      if (!r || r.deleted_at || r.generation !== r.processing_generation)
        outcome = 'skipped';
      else if (delivery.channel === 'push') {
        const [device] = await this.db.query(
          `SELECT * FROM user_device_tokens WHERE id=$1 AND user_id=$2 AND active AND COALESCE((preferences->>'product')::boolean,true)`,
          [delivery.target, r.user_id],
        );
        if (!device || !processingSettings(this.config).pushEnabled)
          outcome = 'skipped';
        else {
          if (this.push.providerName !== 'fcm')
            throw new Error('PUSH_NOT_CONFIGURED');
          const result = await this.push.send({
            token: device.provider_token,
            title: 'Report update',
            body:
              r.status === 'ready'
                ? 'Your report results are ready.'
                : 'Your report needs attention. Open the app for details.',
            collapseId: r.id,
            expiresAt: new Date(delivery.expires_at),
            data: {
              notificationType: 'report.completed',
              reportId: r.report_id,
              profileId: r.profile_id,
              notificationId: r.id,
              generation: String(r.generation),
            },
          });
          messageId = result.providerMessageId;
          await this.db.query(
            `INSERT INTO push_delivery_events(id,user_id,device_token_id,notification_type,recipient_scope,outcome,provider,provider_message_id,error_code,occurred_at,metadata)
            VALUES($1,$2,$3,'report.completed','single',$4,'fcm',$5,$6,clock_timestamp(),$7::jsonb)`,
            [
              randomUUID(),
              r.user_id,
              device.id,
              result.outcome,
              messageId,
              result.errorCode,
              JSON.stringify({
                notificationId: r.id,
                deliveryId: delivery.id,
                providerAccepted: result.outcome === 'sent',
              }),
            ],
          );
          if (result.outcome === 'failed') {
            retryAfterMs = result.retryAfterMs ?? 0;
            if (result.errorCode === 'UNREGISTERED') {
              await this.db.query(
                'UPDATE user_device_tokens SET active=false,disabled_at=clock_timestamp() WHERE id=$1 AND user_id=$2 AND token_hash=$3',
                [device.id, r.user_id, device.token_hash],
              );
              outcome = 'skipped';
              error = 'UNREGISTERED';
            } else throw new Error(result.errorCode ?? 'PUSH_FAILED');
          }
        }
      } else if (delivery.channel === 'email') {
        await this.email.dispatch({
          eventType:
            r.status === 'ready'
              ? NotifiableEventType.REPORT_UPLOAD_COMPLETE
              : r.status === 'needs_attention'
                ? NotifiableEventType.REPORT_REVIEW_REQUIRED
                : NotifiableEventType.REPORT_PARSE_FAILED,
          userId: r.user_id,
          profileId: r.profile_id,
          correlationId: r.id,
          idempotencyKey: `report:${r.id}:email`,
          metadata: { reportId: r.report_id },
        });
      } else if (delivery.channel === 'referral') {
        await this.referrals.triggerMilestoneAForSuccessfulAnalysis({
          inviteeUserId: r.user_id,
          reportId: r.report_id,
          correlationId: r.id,
          trigger: 'upload',
        });
      } else if (delivery.channel === 'summary') {
        await this.reports.enrichWorkerSummary(r.report_id, r.generation);
      } else if (delivery.channel === 'ops') {
        await this.email.dispatchOpsAlert({
          alertType: 'REPORT_PROCESSING_FAILED',
          severity: 'warning',
          idempotencyKey: `report:${r.id}:ops`,
          correlationId: r.id,
          metadata: { reportId: r.report_id },
        });
      }
    } catch {
      outcome = 'pending';
      error = 'DELIVERY_RETRY';
      if (delivery.channel === 'summary')
        await this.db.query(
          `UPDATE reports SET summary_status='failed' WHERE id=(SELECT report_id FROM report_inbox WHERE id=$1) AND processing_generation=(SELECT generation FROM report_inbox WHERE id=$1)`,
          [delivery.inbox_id],
        );
    }
    await this.db.query(
      `UPDATE report_delivery_intents SET state=$3::varchar,error_code=$4,provider_message_id=$5,lease_token=NULL,lease_until=NULL,
      completed_at=CASE WHEN $3::varchar='pending' THEN NULL ELSE clock_timestamp() END,
      available_at=clock_timestamp()+$6*interval '1 millisecond' WHERE id=$1 AND lease_token=$2`,
      [
        delivery.id,
        token,
        outcome,
        error,
        messageId,
        Math.max(
          retryAfterMs,
          Math.floor(
            Math.min(3600000, 5000 * 2 ** delivery.attempts) *
              (0.5 + Math.random() / 2),
          ),
        ),
      ],
    );
  }
  async retain() {
    const retention = processingSettings(this.config).eventRetentionMs;
    const accounts = await this.db.query(
      `SELECT user_id FROM report_event_cursors ORDER BY user_id`,
    );
    for (const account of accounts)
      await this.db.transaction(async (m) => {
        await m.query(
          'SELECT user_id FROM report_event_cursors WHERE user_id=$1 FOR UPDATE',
          [account.user_id],
        );
        // Only remove a contiguous delivered prefix, never skip an undispatched event.
        const [row] = await m.query(
          `SELECT COALESCE(min(cursor)-1,(SELECT last_cursor FROM report_event_cursors WHERE user_id=$1)) AS cutoff
        FROM report_processing_events WHERE user_id=$1 AND (created_at>clock_timestamp()-$2*interval '1 millisecond' OR dispatched_at IS NULL)`,
          [account.user_id, retention],
        );
        await m.query(
          'DELETE FROM report_processing_events WHERE user_id=$1 AND cursor<=$2',
          [account.user_id, row.cutoff],
        );
        await m.query(
          'UPDATE report_event_cursors SET retained_after=GREATEST(retained_after,$2) WHERE user_id=$1',
          [account.user_id, row.cutoff],
        );
      });
    await this.db.query(
      `UPDATE report_processing_jobs SET staged_result=NULL WHERE state IN ('succeeded','failed','cancelled') AND completed_at<clock_timestamp()-interval '1 day'`,
    );
    await this.db.query(
      `DELETE FROM report_ocr_page_checkpoints c USING report_processing_jobs j
       WHERE c.job_id=j.id AND j.state IN ('succeeded','failed','cancelled')
       AND j.completed_at<clock_timestamp()-interval '1 day'`,
    );
    await this.db.query(
      'DELETE FROM report_sse_connections WHERE expires_at<clock_timestamp()',
    );
  }
}
