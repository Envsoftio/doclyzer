import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
  HttpException,
} from '@nestjs/common';
import { DataSource, EntityManager } from 'typeorm';
import { randomUUID } from 'node:crypto';
import {
  PushProviderService,
  isInvalidPushToken,
  isRetryablePushFailure,
} from './push-provider.service';
import {
  PushCampaignDto,
  SchedulePushCampaignDto,
  PushRecipientEventDto,
} from './push-campaign.dto';
import { eligibleMarketingSql, validatePushDestination } from './push-contract';

@Injectable()
export class PushCampaignService {
  private readonly log = new Logger(PushCampaignService.name);
  constructor(
    private readonly db: DataSource,
    private readonly push: PushProviderService,
  ) {}

  async create(actor: string, dto: PushCampaignDto) {
    const deepLink = validatePushDestination(dto.deepLink);
    if (!dto.name.trim() || !dto.title.trim() || !dto.body.trim())
      throw new BadRequestException('Campaign copy is required');
    if (dto.audience === 'single' && !dto.userId)
      throw new BadRequestException('Choose a recipient');
    return this.db.transaction(async (m) => {
      await m.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [
        `campaign:${dto.idempotencyKey}`,
      ]);
      const [existing] = await m.query(
        'SELECT id FROM push_send_audit WHERE idempotency_key=$1 AND sender_user_id=$2',
        [dto.idempotencyKey, actor],
      );
      if (existing) return existing;
      const id = randomUUID();
      await m.query(
        `INSERT INTO push_send_audit(id,sender_user_id,notification_type,status,audience_filter,title,body,dry_run,provider,idempotency_key,metadata)
        VALUES($1,$2,'marketing_offer','draft',$3,$4,$5,false,$6,$7,$8)`,
        [
          id,
          actor,
          JSON.stringify({
            audience: dto.audience,
            userId: dto.userId ?? null,
            platform: dto.platform ?? 'all',
          }),
          dto.title.trim(),
          dto.body.trim(),
          this.push.providerName,
          dto.idempotencyKey,
          JSON.stringify({ category: 'marketing', deepLink }),
        ],
      );
      await m.query(
        'INSERT INTO push_campaigns(id,name,deep_link,image_url) VALUES($1,$2,$3,$4)',
        [id, dto.name.trim(), deepLink, dto.imageUrl ?? null],
      );
      await this.event(m, id, null, actor, 'campaign.created');
      return { id };
    });
  }
  async update(actor: string, id: string, dto: PushCampaignDto) {
    const deepLink = validatePushDestination(dto.deepLink);
    if (!dto.name.trim() || !dto.title.trim() || !dto.body.trim())
      throw new BadRequestException('Campaign copy is required');
    if (dto.audience === 'single' && !dto.userId)
      throw new BadRequestException('Choose a recipient');
    return this.db.transaction(async (m) => {
      const c = await this.campaign(id, m, true);
      if (c.status !== 'draft')
        throw new BadRequestException('Only drafts can be edited');
      await m.query(
        'UPDATE push_campaigns SET name=$2,deep_link=$3,image_url=$4 WHERE id=$1',
        [id, dto.name.trim(), deepLink, dto.imageUrl ?? null],
      );
      await m.query(
        'UPDATE push_send_audit SET title=$2,body=$3,audience_filter=$4,metadata=$5,updated_at=now() WHERE id=$1',
        [
          id,
          dto.title.trim(),
          dto.body.trim(),
          JSON.stringify({
            audience: dto.audience,
            userId: dto.userId ?? null,
            platform: dto.platform ?? 'all',
          }),
          JSON.stringify({ category: 'marketing', deepLink }),
        ],
      );
      await this.event(m, id, null, actor, 'campaign.updated');
      return { id };
    });
  }
  async list() {
    return this.db
      .query(`SELECT c.*,a.title,a.body,a.status,a.audience_filter,a.target_count,a.sent_count,a.failed_count,a.skipped_count
      FROM push_campaigns c JOIN push_send_audit a ON a.id=c.id ORDER BY c.created_at DESC LIMIT 100`);
  }
  private async campaign(
    id: string,
    m: EntityManager = this.db.manager,
    lock = false,
  ) {
    const [c] = await m.query(
      `SELECT c.*,a.title,a.body,a.status,a.audience_filter,a.sender_user_id
      FROM push_campaigns c JOIN push_send_audit a ON a.id=c.id WHERE c.id=$1 ${lock ? 'FOR UPDATE OF c,a' : ''}`,
      [id],
    );
    if (!c) throw new NotFoundException('Campaign not found');
    return c;
  }
  async preview(id: string) {
    const c = await this.campaign(id);
    const [count] = await this.db.query(
      `SELECT count(*)::int AS devices,count(DISTINCT d.user_id)::int AS users
      FROM user_device_tokens d LEFT JOIN account_preferences p ON p.user_id=d.user_id
      WHERE ${eligibleMarketingSql} AND ($1::uuid IS NULL OR d.user_id=$1) AND ($2='all' OR d.platform=$2)`,
      [
        c.audience_filter.audience === 'single'
          ? c.audience_filter.userId
          : null,
        c.audience_filter.platform,
      ],
    );
    return {
      ...count,
      title: c.title,
      body: c.body,
      deepLink: c.deep_link,
      imageUrl: c.image_url,
    };
  }
  async schedule(actor: string, id: string, dto: SchedulePushCampaignDto) {
    const when = dto.scheduledAt ? new Date(dto.scheduledAt) : new Date();
    if (
      !Number.isFinite(when.getTime()) ||
      (dto.scheduledAt && when.getTime() < Date.now())
    )
      throw new BadRequestException('Schedule must be in the future');
    return this.db.transaction(async (m) => {
      // Per-admin serialization makes the existing 10/hour send limit atomic.
      await m.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [
        `push-admin:${actor}`,
      ]);
      const c = await this.campaign(id, m, true);
      if (c.status !== 'draft')
        throw new BadRequestException('Only draft campaigns can be sent');
      await this.rateLimit(m, actor);
      await m.query('UPDATE push_campaigns SET scheduled_at=$2 WHERE id=$1', [
        id,
        when,
      ]);
      await m.query(
        "UPDATE push_send_audit SET status='queued',updated_at=now() WHERE id=$1",
        [id],
      );
      await this.event(m, id, null, actor, 'campaign.scheduled', {
        scheduledAt: when.toISOString(),
      });
      return { id, status: 'queued', scheduledAt: when.toISOString() };
    });
  }
  async test(actor: string, id: string) {
    // A test is a distinct campaign, addressed only to the authenticated admin's devices.
    const c = await this.campaign(id);
    const created = await this.create(actor, {
      name: `Test: ${c.name}`.slice(0, 120),
      title: `[Test] ${c.title}`.slice(0, 120),
      body: c.body,
      deepLink: c.deep_link,
      imageUrl: c.image_url ?? undefined,
      audience: 'single',
      userId: actor,
      platform: 'all',
      idempotencyKey: `test:${id}:${randomUUID()}`,
    });
    await this.db.transaction(async (m) => {
      await m.query('SELECT pg_advisory_xact_lock(hashtextextended($1,0))', [
        `push-admin:${actor}`,
      ]);
      await this.rateLimit(m, actor);
      await m.query(
        'UPDATE push_campaigns SET is_test=true,scheduled_at=now() WHERE id=$1',
        [created.id],
      );
      await m.query("UPDATE push_send_audit SET status='queued' WHERE id=$1", [
        created.id,
      ]);
      await this.event(m, id, null, actor, 'campaign.test_sent', {
        testCampaignId: created.id,
      });
    });
    return created;
  }
  async cancel(actor: string, id: string) {
    return this.db.transaction(async (m) => {
      const c = await this.campaign(id, m, true);
      if (!['draft', 'queued'].includes(c.status) || c.started_at)
        throw new BadRequestException('Campaign has already started');
      await m.query(
        "UPDATE push_send_audit SET status='cancelled',updated_at=now() WHERE id=$1",
        [id],
      );
      await m.query(
        'UPDATE push_campaigns SET completed_at=now() WHERE id=$1',
        [id],
      );
      await this.event(m, id, null, actor, 'campaign.cancelled');
      return { id, status: 'cancelled' };
    });
  }
  async remove(actor: string, id: string) {
    return this.db.transaction(async (m) => {
      const c = await this.campaign(id, m, true);
      if (['queued', 'sending'].includes(c.status))
        throw new BadRequestException('Cancel the campaign before deleting it');
      if (c.started_at && !c.completed_at)
        throw new BadRequestException('An active campaign cannot be deleted');
      const deletedAt = new Date().toISOString();
      await m.query(
        `UPDATE push_send_audit SET metadata=COALESCE(metadata,'{}'::jsonb)||$2::jsonb,updated_at=now() WHERE id=$1`,
        [
          id,
          JSON.stringify({
            campaignDeletedAt: deletedAt,
            campaignDeletedBy: actor,
          }),
        ],
      );
      await m.query('DELETE FROM push_campaigns WHERE id=$1', [id]);
      return { id, deleted: true, deletedAt };
    });
  }
  async recordEvent(user: string, dto: PushRecipientEventDto) {
    return this.db.transaction(async (m) => {
      const [r] = await m.query(
        `SELECT r.* FROM push_recipients r JOIN user_device_tokens d ON d.id=r.device_id
        WHERE r.id=$1 AND r.user_id=$2 AND d.user_id=$2 AND d.active AND r.attempts>0 FOR UPDATE OF r`,
        [dto.recipientId, user],
      );
      if (!r) throw new NotFoundException('Notification not found');
      const column = {
        received: 'received_at',
        opened: 'opened_at',
        deep_link_opened: 'actioned_at',
      }[dto.eventType];
      if (!column) throw new BadRequestException('Unsupported event');
      await m.query(
        `UPDATE push_recipients SET ${column}=COALESCE(${column},now()) WHERE id=$1`,
        [r.id],
      );
      await this.event(m, r.campaign_id, r.id, user, dto.eventType);
      return { recorded: true };
    });
  }
  async analytics(id: string) {
    await this.campaign(id);
    const [totals] = await this.db.query(
      `SELECT count(*)::int AS devices,count(DISTINCT user_id)::int AS users,
      count(*) FILTER(WHERE status='accepted')::int AS accepted,
      count(*) FILTER(WHERE status='failed')::int AS failed,
      count(*) FILTER(WHERE status='skipped')::int AS skipped,
      count(*) FILTER(WHERE received_at IS NOT NULL)::int AS received,
      count(*) FILTER(WHERE opened_at IS NOT NULL AND status='accepted')::int AS opens,
      count(*) FILTER(WHERE actioned_at IS NOT NULL AND status='accepted')::int AS actions,
      count(DISTINCT user_id) FILTER(WHERE opened_at IS NOT NULL AND status='accepted')::int AS unique_users_opened
      FROM push_recipients WHERE campaign_id=$1`,
      [id],
    );
    const platforms = await this.db.query(
      `SELECT platform,status,count(*)::int AS count FROM push_recipients WHERE campaign_id=$1 GROUP BY platform,status`,
      [id],
    );
    const failures = await this.db.query(
      `SELECT failure_code,count(*)::int AS count FROM push_recipients WHERE campaign_id=$1 AND failure_code IS NOT NULL GROUP BY failure_code`,
      [id],
    );
    const events = await this.db.query(
      `SELECT event_type,actor_id,metadata,created_at FROM push_events WHERE campaign_id=$1 AND recipient_id IS NULL ORDER BY created_at DESC LIMIT 100`,
      [id],
    );
    return {
      ...totals,
      openRate: totals.accepted ? totals.opens / totals.accepted : 0,
      actionRate: totals.accepted ? totals.actions / totals.accepted : 0,
      platforms,
      failures,
      events,
      definitions:
        'Open/action rate = unique device recipients opened/navigated divided by provider-accepted device recipients. Navigation is not a business conversion.',
    };
  }
  async tick() {
    await this.materialize();
    // At most ten requests per iteration/process; each recipient is leased independently.
    for (let i = 0; i < 10; i++) if (!(await this.deliverOne())) break;
    await this.db
      .query(`UPDATE push_send_audit a SET status=CASE WHEN s.failed>0 AND s.accepted=0 THEN 'failed'
      WHEN s.failed>0 THEN 'partially_failed' ELSE 'completed' END,
      sent_count=s.accepted,failed_count=s.failed,skipped_count=s.skipped,updated_at=now()
      FROM (SELECT c.id,count(r.id) FILTER(WHERE r.status='accepted')::int accepted,
        count(r.id) FILTER(WHERE r.status='failed')::int failed,count(r.id) FILTER(WHERE r.status='skipped')::int skipped
        FROM push_campaigns c LEFT JOIN push_recipients r ON r.campaign_id=c.id
        WHERE c.materialized AND c.completed_at IS NULL
        GROUP BY c.id HAVING count(r.id) FILTER(WHERE r.status IN ('queued','sending'))=0) s WHERE a.id=s.id`);
    await this.db.query(
      `UPDATE push_campaigns c SET completed_at=now() FROM push_send_audit a WHERE a.id=c.id AND c.completed_at IS NULL AND a.status IN ('completed','partially_failed','failed')`,
    );
  }
  private async materialize() {
    await this.db.transaction(async (m) => {
      const [c] =
        await m.query(`SELECT c.*,a.audience_filter FROM push_campaigns c JOIN push_send_audit a ON a.id=c.id
        WHERE NOT c.materialized AND a.status IN ('queued','sending') AND c.scheduled_at<=now()
        ORDER BY c.scheduled_at LIMIT 1 FOR UPDATE OF c,a SKIP LOCKED`);
      if (!c) return;
      const devices = await m.query(
        `SELECT d.id,d.user_id,d.platform FROM user_device_tokens d
        LEFT JOIN account_preferences p ON p.user_id=d.user_id
        WHERE ${eligibleMarketingSql}
        AND ($1::uuid IS NULL OR d.user_id=$1) AND ($2='all' OR d.platform=$2)
        AND ($3::uuid IS NULL OR d.id>$3) ORDER BY d.id LIMIT 500`,
        [
          c.audience_filter.audience === 'single'
            ? c.audience_filter.userId
            : null,
          c.audience_filter.platform,
          c.cursor,
        ],
      );
      for (const d of devices) {
        const [r] = await m.query(
          `INSERT INTO push_recipients(campaign_id,user_id,device_id,platform) VALUES($1,$2,$3,$4)
          ON CONFLICT(campaign_id,device_id) DO NOTHING RETURNING id`,
          [c.id, d.user_id, d.id, d.platform],
        );
        if (r) await this.event(m, c.id, r.id, null, 'queued');
      }
      await m.query(
        'UPDATE push_campaigns SET started_at=COALESCE(started_at,now()),cursor=$2,materialized=$3 WHERE id=$1',
        [c.id, devices.at(-1)?.id ?? c.cursor, devices.length < 500],
      );
      await m.query(
        "UPDATE push_send_audit SET status='sending',target_count=(SELECT count(*) FROM push_recipients WHERE campaign_id=$1),updated_at=now() WHERE id=$1",
        [c.id],
      );
      if (!c.started_at)
        await this.event(m, c.id, null, null, 'campaign.started');
    });
  }
  private async deliverOne(): Promise<boolean> {
    const lease = randomUUID();
    const r = await this.db.transaction(async (m) => {
      const [r] =
        await m.query(`SELECT * FROM push_recipients WHERE (status='queued' AND available_at<=now()) OR
        (status='sending' AND lease_until<now()) ORDER BY available_at LIMIT 1 FOR UPDATE SKIP LOCKED`);
      if (!r) return null;
      if (
        r.attempts >= 8 ||
        new Date(r.created_at).getTime() < Date.now() - 86400000
      ) {
        await m.query(
          "UPDATE push_recipients SET status='failed',failure_code='RETRIES_EXHAUSTED' WHERE id=$1",
          [r.id],
        );
        return null;
      }
      await m.query(
        "UPDATE push_recipients SET status='sending',attempts=attempts+1,lease_token=$2,lease_until=now()+interval '5 minutes' WHERE id=$1",
        [r.id, lease],
      );
      await this.event(m, r.campaign_id, r.id, null, 'send_attempted', {
        attempt: r.attempts + 1,
      });
      return r;
    });
    if (!r) return false;
    const c = await this.campaign(r.campaign_id);
    const [d] = await this.db.query(
      `SELECT d.* FROM user_device_tokens d LEFT JOIN account_preferences p ON p.user_id=d.user_id
      WHERE d.id=$1 AND d.user_id=$2 AND ${eligibleMarketingSql}`,
      [r.device_id, r.user_id],
    );
    const result = d
      ? await this.push.send({
          token: d.provider_token,
          title: c.title,
          body: c.body,
          imageUrl: c.image_url,
          category: 'marketing',
          collapseId: r.id,
          expiresAt: new Date(Date.now() + 86400000),
          data: {
            version: '1',
            notificationId: c.id,
            pushSendAuditId: c.id,
            campaignId: c.id,
            recipientId: r.id,
            notificationType: 'marketing_offer',
            category: 'marketing',
            deepLink: c.deep_link,
          },
        })
      : null;
    const status = !result
      ? 'skipped'
      : result.outcome === 'sent'
        ? 'accepted'
        : isRetryablePushFailure(result.errorCode) && r.attempts < 7
          ? 'queued'
          : 'failed';
    await this.db.transaction(async (m) => {
      const rows = await m.query(
        `UPDATE push_recipients SET status=$3::varchar,failure_code=$4,provider_message_id=$5,
        accepted_at=CASE WHEN $3::varchar='accepted' THEN now() ELSE accepted_at END,lease_token=NULL,lease_until=NULL,
        available_at=now()+$6*interval '1 millisecond' WHERE id=$1 AND lease_token=$2 RETURNING id`,
        [
          r.id,
          lease,
          status,
          result?.errorCode ?? null,
          result?.providerMessageId ?? null,
          Math.max(
            result?.retryAfterMs ?? 0,
            Math.min(3600000, 60000 * 2 ** r.attempts) *
              (1 + Math.random() / 4),
          ),
        ],
      );
      if (!rows.length) return;
      await this.event(
        m,
        c.id,
        r.id,
        null,
        status === 'accepted'
          ? 'provider_accepted'
          : status === 'skipped'
            ? 'skipped'
            : 'provider_rejected',
        { code: result?.errorCode ?? null, attempt: r.attempts + 1 },
      );
      if (result)
        await m.query(
          `INSERT INTO push_delivery_events(id,push_send_audit_id,user_id,device_token_id,notification_type,recipient_scope,outcome,provider,provider_message_id,error_code,occurred_at)
        VALUES($1,$2,$3,$4,'marketing_offer','single',$5,$6,$7,$8,now())`,
          [
            randomUUID(),
            c.id,
            r.user_id,
            r.device_id,
            result.outcome,
            result.provider,
            result.providerMessageId,
            result.errorCode,
          ],
        );
      if (d && isInvalidPushToken(result?.errorCode ?? null))
        await m.query(
          'UPDATE user_device_tokens SET active=false,disabled_at=now() WHERE id=$1 AND user_id=$2 AND token_hash=$3',
          [d.id, r.user_id, d.token_hash],
        );
    });
    this.log.log(
      JSON.stringify({
        action: 'PUSH_SEND',
        campaignId: c.id,
        recipientId: r.id,
        deviceId: r.device_id,
        result: status,
        errorCode: result?.errorCode,
        attempt: r.attempts + 1,
      }),
    );
    return true;
  }
  async retain() {
    await this.db
      .query(`UPDATE user_device_tokens SET active=false,disabled_at=now(),metadata=NULL,device_label=NULL
      WHERE last_seen_at<now()-interval '90 days' AND active`);
    await this.db
      .query(`UPDATE user_device_tokens SET provider_token='',metadata=NULL,device_label=NULL
      WHERE NOT active AND disabled_at<now()-interval '30 days'`);
    await this.db.query(
      `DELETE FROM push_delivery_events WHERE occurred_at<now()-interval '180 days'`,
    );
    await this.db.query(
      `DELETE FROM push_open_events WHERE opened_at<now()-interval '180 days'`,
    );
    // Campaign summaries and audit actions remain; remove raw provider attempt metadata only.
    await this.db.query(
      `DELETE FROM push_events WHERE recipient_id IS NOT NULL AND event_type IN ('send_attempted','provider_rejected') AND created_at<now()-interval '90 days'`,
    );
  }
  private async rateLimit(m: EntityManager, actor: string) {
    const [r] = await m.query(
      "SELECT count(*)::int n FROM push_events WHERE actor_id=$1 AND event_type IN ('campaign.scheduled','campaign.test_sent') AND created_at>now()-interval '1 hour'",
      [actor],
    );
    if (r.n >= 10)
      throw new HttpException('Admin push limit: 10 sends per hour', 429);
  }
  private async event(
    m: EntityManager,
    campaign: string,
    recipient: string | null,
    actor: string | null,
    type: string,
    metadata: object = {},
  ) {
    await m.query(
      'INSERT INTO push_events(campaign_id,recipient_id,actor_id,event_type,metadata) VALUES($1,$2,$3,$4,$5) ON CONFLICT DO NOTHING',
      [campaign, recipient, actor, type, JSON.stringify(metadata)],
    );
  }
}
