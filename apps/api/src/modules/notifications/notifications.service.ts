import { PushCampaignService } from './push-campaign.service';
import { validatePushDestination } from './push-contract';
import { randomUUID } from 'node:crypto';
import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { createHash } from 'node:crypto';
import {
  Between,
  EntityManager,
  Repository,
  SelectQueryBuilder,
} from 'typeorm';
import { AccountPreferenceEntity } from '../../database/entities/account-preference.entity';
import { PushDeliveryEventEntity } from '../../database/entities/push-delivery-event.entity';
import { PushOpenEventEntity } from '../../database/entities/push-open-event.entity';
import { NotificationReadEntity } from '../../database/entities/notification-read.entity';
import { EmailQueueItemEntity } from '../../database/entities/email-queue-item.entity';
import { ShareLinkEntity } from '../../database/entities/share-link.entity';
import { PushSendAuditEntity } from '../../database/entities/push-send-audit.entity';
import {
  PushTokenPreferences,
  UserDeviceTokenEntity,
} from '../../database/entities/user-device-token.entity';
import type {
  AdminPushBroadcastDto,
  PushAuditQueryDto,
  PushNotificationCategory,
  PushOpenDto,
  RegisterDeviceTokenDto,
  UpdateDeviceTokenPreferencesDto,
} from './notifications.dto';
import { PushProviderService } from './push-provider.service';

const DEFAULT_PUSH_PREFERENCES: Required<PushTokenPreferences> = {
  marketing: false,
  billing: true,
  referrals: true,
  product: true,
  adminAnnouncements: true,
};

interface ResolvedAudience {
  tokens: UserDeviceTokenEntity[];
  skippedCount: number;
}

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(UserDeviceTokenEntity)
    private readonly deviceTokenRepo: Repository<UserDeviceTokenEntity>,
    @InjectRepository(PushSendAuditEntity)
    private readonly pushAuditRepo: Repository<PushSendAuditEntity>,
    @InjectRepository(PushDeliveryEventEntity)
    private readonly deliveryRepo: Repository<PushDeliveryEventEntity>,
    @InjectRepository(PushOpenEventEntity)
    private readonly openRepo: Repository<PushOpenEventEntity>,
    @InjectRepository(NotificationReadEntity)
    private readonly notificationReadRepo: Repository<NotificationReadEntity>,
    @InjectRepository(EmailQueueItemEntity)
    private readonly emailQueueRepo: Repository<EmailQueueItemEntity>,
    @InjectRepository(ShareLinkEntity)
    private readonly shareLinkRepo: Repository<ShareLinkEntity>,
    @InjectRepository(AccountPreferenceEntity)
    private readonly accountPreferenceRepo: Repository<AccountPreferenceEntity>,
    private readonly pushProvider: PushProviderService,
    private readonly config: ConfigService,
    private readonly campaigns: PushCampaignService,
  ) {}

  async listDeviceTokens(userId: string): Promise<object> {
    const tokens = await this.deviceTokenRepo.find({
      where: { userId },
      order: { lastSeenAt: 'DESC' },
    });
    return { tokens: tokens.map((token) => this.mapDeviceToken(token)) };
  }

  async getInbox(userId: string): Promise<object> {
    const now = new Date();
    const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000);
    const [deliveries, queueItems, expiringLinks, reads, accountPreference] =
      await Promise.all([
        this.deliveryRepo
          .createQueryBuilder('delivery')
          .innerJoinAndSelect('delivery.pushSendAudit', 'audit')
          .where('delivery.userId = :userId', { userId })
          .andWhere('delivery.outcome = :outcome', { outcome: 'sent' })
          .orderBy('delivery.occurredAt', 'DESC')
          .take(100)
          .getMany(),
        this.emailQueueRepo
          .createQueryBuilder('queue')
          .where("queue.metadata ->> 'userId' = :userId", { userId })
          .andWhere('queue.emailType IN (:...types)', {
            types: [
              'report.upload_complete',
              'report.review_required',
              'report.parse_failed',
            ],
          })
          .orderBy('queue.createdAt', 'DESC')
          .take(100)
          .getMany(),
        this.shareLinkRepo.find({
          where: { userId, isActive: true, expiresAt: Between(now, tomorrow) },
          order: { expiresAt: 'ASC' },
          take: 100,
        }),
        this.notificationReadRepo.find({ where: { userId } }),
        this.accountPreferenceRepo.findOne({ where: { userId } }),
      ]);
    const readKeys = new Set(
      reads.map((read) => `${read.sourceType}:${read.sourceId}`),
    );
    const items: Array<{
      id: string;
      sourceType: string;
      type: string;
      title: string;
      body: string;
      occurredAt: string;
      read: boolean;
      deepLink: string | null;
    }> = [];
    const seenAudits = new Set<string>();
    for (const delivery of deliveries) {
      const audit = delivery.pushSendAudit;
      if (!audit || seenAudits.has(audit.id)) continue;
      seenAudits.add(audit.id);
      items.push({
        id: audit.id,
        sourceType: 'push',
        type: delivery.notificationType,
        title: audit.title,
        body: audit.body,
        occurredAt: delivery.occurredAt.toISOString(),
        read: readKeys.has(`push:${audit.id}`),
        deepLink:
          typeof audit.metadata?.deepLink === 'string'
            ? audit.metadata.deepLink
            : null,
      });
    }
    const reportCopy: Record<string, { title: string; body: string }> = {
      'report.upload_complete': {
        title: 'Your report was saved',
        body: 'Open your reports to review the saved file.',
      },
      'report.review_required': {
        title: 'Your report is ready to review',
        body: 'Check extracted details against the original report.',
      },
      'report.parse_failed': {
        title: 'A report needs attention',
        body: 'Open the report to retry or keep the original.',
      },
    };
    for (const queued of queueItems) {
      const copy = reportCopy[queued.emailType];
      if (!copy) continue;
      items.push({
        id: queued.id,
        sourceType: 'report',
        type: queued.emailType,
        ...copy,
        occurredAt: queued.createdAt.toISOString(),
        read: readKeys.has(`report:${queued.id}`),
        deepLink:
          typeof queued.metadata?.reportId === 'string'
            ? `/reports/${queued.metadata.reportId}`
            : '/reports',
      });
    }
    for (const link of accountPreference?.shareRemindersEnabled === false
      ? []
      : expiringLinks) {
      items.push({
        id: link.id,
        sourceType: 'share',
        type: 'share.link_expiring',
        title: 'A sharing link expires soon',
        body: 'Review or renew access from Shared links.',
        occurredAt: now.toISOString(),
        read: readKeys.has(`share:${link.id}`),
        deepLink: `/shared-links/${link.profileId}`,
      });
    }
    items.sort((a, b) => b.occurredAt.localeCompare(a.occurredAt));
    return { items: items.slice(0, 100) };
  }

  async markInboxRead(
    userId: string,
    sourceType: string,
    sourceId: string,
  ): Promise<object> {
    if (!['push', 'report', 'share'].includes(sourceType)) {
      throw new NotFoundException('Notification not found');
    }
    let owned = false;
    if (sourceType === 'push') {
      owned =
        (await this.deliveryRepo.count({
          where: { userId, pushSendAuditId: sourceId, outcome: 'sent' },
        })) > 0;
    } else if (sourceType === 'report') {
      const queue = await this.emailQueueRepo.findOne({
        where: { id: sourceId },
      });
      owned =
        queue?.metadata?.userId === userId &&
        [
          'report.upload_complete',
          'report.review_required',
          'report.parse_failed',
        ].includes(queue.emailType);
    } else {
      owned =
        (await this.shareLinkRepo.count({ where: { id: sourceId, userId } })) >
        0;
    }
    if (!owned) throw new NotFoundException('Notification not found');
    const readAt = new Date();
    await this.notificationReadRepo.upsert(
      { userId, sourceType, sourceId, readAt },
      ['userId', 'sourceType', 'sourceId'],
    );
    return { readAt: readAt.toISOString() };
  }

  async registerDeviceToken(
    userId: string,
    dto: RegisterDeviceTokenDto,
  ): Promise<object> {
    const providerToken = dto.token.trim();
    const tokenHash = this.hashProviderToken(providerToken);
    const installationId = dto.installationId?.trim() || null;
    // Serialize both token and installation identities, including concurrent account switches.
    return this.deviceTokenRepo.manager.transaction(async (manager) => {
      for (const key of [tokenHash, installationId].filter(Boolean).sort())
        await manager.query(
          'SELECT pg_advisory_xact_lock(hashtextextended($1, 0))',
          [key],
        );
      const repo = manager.getRepository(UserDeviceTokenEntity);
      const identities = await repo
        .createQueryBuilder('device')
        .where(
          'device.tokenHash = :tokenHash OR device.installationId = :installationId',
          { tokenHash, installationId },
        )
        .orderBy('device.id', 'ASC')
        .setLock('pessimistic_write')
        .getMany();
      const byToken = identities.find(
        (device) => device.tokenHash === tokenHash,
      );
      const byInstallation = installationId
        ? identities.find((device) => device.installationId === installationId)
        : null;
      const entity = byInstallation ?? byToken ?? repo.create({ tokenHash });
      if (byToken && byToken.id !== entity.id) {
        // Preserve analytics identity, but release the rotated token for its installation.
        byToken.active = false;
        byToken.disabledAt = new Date();
        byToken.installationId = null;
        byToken.providerToken = '';
        byToken.tokenHash = this.hashProviderToken(`retired:${byToken.id}`);
        await repo.save(byToken);
      }
      const sameAccount = entity.userId === userId;
      const now = new Date();
      if (entity.tokenHash !== tokenHash || !entity.tokenUpdatedAt)
        entity.tokenUpdatedAt = now;
      entity.tokenHash = tokenHash;
      entity.userId = userId;
      entity.providerToken = providerToken;
      entity.platform = dto.platform;
      entity.provider = dto.provider ?? 'fcm';
      entity.installationId = installationId;
      entity.appVersion = dto.appVersion?.trim() || null;
      entity.deviceLabel = dto.deviceLabel?.trim() || null;
      entity.preferences = this.normalizePreferences({
        ...(sameAccount ? entity.preferences : {}),
        ...dto.preferences,
      });
      entity.notificationPermission =
        dto.notificationPermission ??
        (sameAccount ? entity.notificationPermission : 'unknown');
      entity.active = true;
      entity.disabledAt = null;
      entity.lastSeenAt = now;
      entity.metadata = this.sanitizeMetadata(dto.metadata);
      return this.mapDeviceToken(await repo.save(entity));
    });
  }

  async updateDeviceTokenPreferences(
    userId: string,
    deviceTokenId: string,
    dto: UpdateDeviceTokenPreferencesDto,
  ): Promise<object> {
    return this.mutateOwnedToken(
      userId,
      deviceTokenId,
      async (token, manager) => {
        token.preferences = this.normalizePreferences({
          ...(token.preferences ?? DEFAULT_PUSH_PREFERENCES),
          ...dto.preferences,
        });
        token.lastSeenAt = new Date();
        if (dto.preferences.marketing === false)
          await manager.query(
            `INSERT INTO push_events(actor_id,event_type,metadata) VALUES($1,'marketing_device_opt_out',$2)`,
            [userId, JSON.stringify({ deviceId: token.id })],
          );
      },
    );
  }

  async deactivateDeviceToken(
    userId: string,
    deviceTokenId: string,
  ): Promise<object> {
    return this.mutateOwnedToken(userId, deviceTokenId, async (token) => {
      token.active = false;
      token.disabledAt = new Date();
      token.lastSeenAt = token.disabledAt;
    });
  }

  private async mutateOwnedToken(
    userId: string,
    id: string,
    mutate: (
      token: UserDeviceTokenEntity,
      manager: EntityManager,
    ) => Promise<void>,
  ): Promise<object> {
    return this.deviceTokenRepo.manager.transaction(async (manager) => {
      const repo = manager.getRepository(UserDeviceTokenEntity);
      const token = await repo.findOne({
        where: { id, userId },
        lock: { mode: 'pessimistic_write' },
      });
      if (!token) throw new NotFoundException('Device token not found');
      await mutate(token, manager);
      return this.mapDeviceToken(await repo.save(token));
    });
  }

  async trackPushOpen(userId: string, dto: PushOpenDto): Promise<object> {
    if (dto.deviceTokenId) {
      await this.findOwnedToken(userId, dto.deviceTokenId);
    }

    if (
      !dto.pushSendAuditId ||
      !(await this.deliveryRepo.count({
        where: {
          userId,
          pushSendAuditId: dto.pushSendAuditId,
          outcome: 'sent',
          ...(dto.deviceTokenId ? { deviceTokenId: dto.deviceTokenId } : {}),
        },
      }))
    )
      throw new NotFoundException('Notification not found');
    const existing = await this.openRepo.findOne({
      where: { userId, pushSendAuditId: dto.pushSendAuditId },
    });
    if (existing)
      return { id: existing.id, openedAt: existing.openedAt.toISOString() };
    const openedAt = new Date();
    const saved = await this.openRepo.save(
      this.openRepo.create({
        userId,
        deviceTokenId: dto.deviceTokenId ?? null,
        pushSendAuditId: dto.pushSendAuditId ?? null,
        providerMessageId: dto.providerMessageId ?? null,
        deepLink: dto.deepLink ?? null,
        openedAt,
        metadata: this.sanitizeMetadata(dto.metadata),
      }),
    );

    return {
      id: saved.id,
      openedAt: saved.openedAt.toISOString(),
    };
  }

  async getMetrics(): Promise<object> {
    const platformRows = await this.deviceTokenRepo
      .createQueryBuilder('token')
      .select('token.platform', 'platform')
      .addSelect('COUNT(*)', 'count')
      .where('token.active = :active', { active: true })
      .groupBy('token.platform')
      .getRawMany<{ platform: string; count: string }>();

    const deliveryRows = await this.deliveryRepo
      .createQueryBuilder('delivery')
      .select('delivery.outcome', 'outcome')
      .addSelect('COUNT(*)', 'count')
      .groupBy('delivery.outcome')
      .getRawMany<{ outcome: string; count: string }>();

    const activePushTokensByPlatform: Record<string, number> = {};
    for (const row of platformRows) {
      activePushTokensByPlatform[row.platform] =
        Number.parseInt(row.count, 10) || 0;
    }

    const deliveryByOutcome: Record<string, number> = {};
    for (const row of deliveryRows) {
      deliveryByOutcome[row.outcome] = Number.parseInt(row.count, 10) || 0;
    }

    const activePushTokens = Object.values(activePushTokensByPlatform).reduce(
      (sum, count) => sum + count,
      0,
    );

    return {
      snapshotAt: new Date().toISOString(),
      activePushTokens,
      activePushTokensByPlatform,
      pushSends: await this.pushAuditRepo.count(),
      livePushSends: await this.pushAuditRepo.count({
        where: { dryRun: false },
      }),
      pushOpens: Number(
        (
          await this.deviceTokenRepo.manager.query(`
        SELECT count(*) AS count FROM (
          SELECT r.id FROM push_recipients r JOIN push_campaigns c ON c.id=r.campaign_id
            WHERE r.opened_at IS NOT NULL AND r.status='accepted' AND NOT c.is_test
          UNION ALL
          SELECT o.id FROM push_open_events o LEFT JOIN push_campaigns c ON c.id=o.push_send_audit_id
            WHERE c.id IS NULL
        ) opens`)
        )[0].count,
      ),
      deliveryByOutcome,
    };
  }

  async getPushAudit(query: PushAuditQueryDto): Promise<object> {
    const page = query.page ?? 1;
    const pageSize = query.pageSize ?? 25;
    const qb = this.pushAuditRepo.createQueryBuilder('audit');
    if (query.dryRun !== undefined) {
      qb.where('audit.dryRun = :dryRun', { dryRun: query.dryRun });
    }
    const [items, total] = await qb
      .orderBy('audit.createdAt', 'DESC')
      .skip((page - 1) * pageSize)
      .take(pageSize)
      .getManyAndCount();

    return {
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize) || 1,
      },
      items: items.map((item) => this.mapPushAudit(item)),
    };
  }

  async dryRunAdminPush(input: {
    actorUserId: string;
    correlationId: string;
    dto: AdminPushBroadcastDto;
  }): Promise<object> {
    this.assertRecipientScope(input.dto);
    validatePushDestination(input.dto.deepLink);
    const existing = await this.findExistingAudit(input.dto.idempotencyKey);
    if (existing) return this.mapPushAudit(existing);

    const audience = await this.resolveAudience(input.dto);
    const audit = await this.pushAuditRepo.save(
      this.pushAuditRepo.create({
        senderUserId: input.actorUserId,
        notificationType: input.dto.notificationType,
        status: 'completed',
        audienceFilter: this.buildAudienceFilter(input.dto),
        title: input.dto.title.trim(),
        body: input.dto.body.trim(),
        dryRun: true,
        targetCount: audience.tokens.length,
        sentCount: 0,
        failedCount: 0,
        skippedCount: audience.skippedCount,
        provider: this.pushProvider.providerName,
        idempotencyKey: input.dto.idempotencyKey ?? null,
        metadata: {
          correlationId: input.correlationId,
          category: this.getNotificationCategory(input.dto),
          deepLink: input.dto.deepLink ?? null,
        },
      }),
    );
    return this.mapPushAudit(audit);
  }

  async sendAdminPush(input: {
    actorUserId: string;
    correlationId: string;
    dto: AdminPushBroadcastDto;
  }): Promise<object> {
    const { dto } = input;
    this.assertRecipientScope(dto);
    const campaign = await this.campaigns.create(input.actorUserId, {
      name: dto.title,
      title: dto.title,
      body: dto.body,
      deepLink: dto.deepLink,
      audience: dto.recipientScope === 'single' ? 'single' : 'all',
      userId: dto.recipientUserId,
      platform: ['ios', 'android', 'web', 'mobile_web'].includes(
        dto.recipientSegment ?? '',
      )
        ? dto.recipientSegment
        : 'all',
      idempotencyKey: dto.idempotencyKey ?? randomUUID(),
    });
    return this.campaigns.schedule(input.actorUserId, campaign.id, {
      approvalToken: dto.approvalToken,
    });
  }

  hashProviderToken(token: string): string {
    return createHash('sha256').update(token).digest('hex');
  }

  private async findOwnedToken(
    userId: string,
    deviceTokenId: string,
  ): Promise<UserDeviceTokenEntity> {
    const token = await this.deviceTokenRepo.findOne({
      where: { id: deviceTokenId, userId },
    });
    if (!token) {
      throw new NotFoundException({
        code: 'PUSH_DEVICE_TOKEN_NOT_FOUND',
        message: 'Device token not found',
      });
    }
    return token;
  }

  private async findExistingAudit(
    idempotencyKey?: string,
  ): Promise<PushSendAuditEntity | null> {
    if (!idempotencyKey) return null;
    return this.pushAuditRepo.findOne({ where: { idempotencyKey } });
  }

  private assertRecipientScope(dto: AdminPushBroadcastDto): void {
    if (dto.recipientScope === 'single' && !dto.recipientUserId) {
      throw new BadRequestException({
        code: 'PUSH_RECIPIENT_USER_REQUIRED',
        message: 'recipientUserId is required for single push sends',
      });
    }
    if (dto.recipientScope === 'segment' && !dto.recipientSegment) {
      throw new BadRequestException({
        code: 'PUSH_RECIPIENT_SEGMENT_REQUIRED',
        message: 'recipientSegment is required for segment push sends',
      });
    }
  }

  private async resolveAudience(
    dto: AdminPushBroadcastDto,
  ): Promise<ResolvedAudience> {
    const qb = this.deviceTokenRepo
      .createQueryBuilder('token')
      .where('token.active = :active', { active: true });

    if (dto.recipientScope === 'single') {
      qb.andWhere('token.userId = :userId', {
        userId: dto.recipientUserId,
      });
    }

    if (dto.recipientScope === 'segment') {
      this.applySegmentFilter(qb, dto.recipientSegment);
    }

    const candidates = await qb.orderBy('token.lastSeenAt', 'DESC').getMany();
    const category = this.getNotificationCategory(dto);
    const accountPrefs = await this.getAccountPreferenceMap(candidates);
    const tokens = candidates.filter((token) =>
      this.allowsCategory(token, category, accountPrefs.get(token.userId)),
    );

    return {
      tokens,
      skippedCount: candidates.length - tokens.length,
    };
  }

  private applySegmentFilter(
    qb: SelectQueryBuilder<UserDeviceTokenEntity>,
    segmentValue?: string,
  ): void {
    const segment = segmentValue?.trim().toLowerCase();
    if (!segment || segment === 'all') return;
    if (segment === 'mobile') {
      qb.andWhere('token.platform IN (:...platforms)', {
        platforms: ['ios', 'android'],
      });
      return;
    }
    if (segment === 'web') {
      qb.andWhere('token.platform IN (:...platforms)', {
        platforms: ['web', 'mobile_web'],
      });
      return;
    }
    if (['ios', 'android', 'mobile_web'].includes(segment)) {
      qb.andWhere('token.platform = :platform', { platform: segment });
      return;
    }
    throw new BadRequestException({
      code: 'PUSH_UNSUPPORTED_SEGMENT',
      message: `Unsupported push audience segment: ${segmentValue}`,
    });
  }

  private async getAccountPreferenceMap(
    tokens: UserDeviceTokenEntity[],
  ): Promise<Map<string, AccountPreferenceEntity>> {
    const userIds = Array.from(new Set(tokens.map((token) => token.userId)));
    if (userIds.length === 0) return new Map();
    const rows = await this.accountPreferenceRepo
      .createQueryBuilder('pref')
      .where('pref.userId IN (:...userIds)', { userIds })
      .getMany();
    return new Map(rows.map((row) => [row.userId, row]));
  }

  private allowsCategory(
    token: UserDeviceTokenEntity,
    category: PushNotificationCategory,
    accountPreference?: AccountPreferenceEntity,
  ): boolean {
    if (!['authorized', 'provisional'].includes(token.notificationPermission))
      return false;
    if (
      category === 'marketing' ||
      category === 'product' ||
      category === 'admin_announcements' ||
      category === 'referrals'
    )
      return (
        accountPreference?.marketingPushEnabled === true &&
        token.preferences?.marketing === true
      );
    if (category === 'security' || category === 'compliance') return true;
    if (accountPreference?.productEmailsEnabled === false) return false;

    const prefs = {
      ...DEFAULT_PUSH_PREFERENCES,
      ...(token.preferences ?? {}),
    };
    if (category === 'billing') return prefs.billing;
    if (category === 'referrals') return prefs.referrals;
    if (category === 'admin_announcements') return prefs.adminAnnouncements;
    return prefs.product;
  }

  private getNotificationCategory(
    _dto: AdminPushBroadcastDto,
  ): PushNotificationCategory {
    return 'marketing';
  }

  private buildAudienceFilter(
    dto: AdminPushBroadcastDto,
  ): Record<string, string | number | boolean | null> {
    return {
      recipientScope: dto.recipientScope,
      recipientUserId: dto.recipientUserId ?? null,
      recipientSegment: dto.recipientSegment ?? null,
      category: this.getNotificationCategory(dto),
    };
  }

  private normalizePreferences(
    raw?: Record<string, boolean>,
  ): Required<PushTokenPreferences> {
    const preferences = { ...DEFAULT_PUSH_PREFERENCES };
    if (!raw) return preferences;
    if (typeof raw.marketing === 'boolean')
      preferences.marketing = raw.marketing;
    if (typeof raw.billing === 'boolean') preferences.billing = raw.billing;
    if (typeof raw.referrals === 'boolean') {
      preferences.referrals = raw.referrals;
    }
    if (typeof raw.product === 'boolean') preferences.product = raw.product;
    if (typeof raw.adminAnnouncements === 'boolean') {
      preferences.adminAnnouncements = raw.adminAnnouncements;
    }
    return preferences;
  }

  private sanitizeMetadata(
    metadata?: Record<string, string | number | boolean | null>,
  ): Record<string, string | number | boolean | null> | null {
    if (!metadata) return null;
    const sanitized: Record<string, string | number | boolean | null> = {};
    for (const [key, value] of Object.entries(metadata)) {
      if (
        value === null ||
        typeof value === 'string' ||
        typeof value === 'number' ||
        typeof value === 'boolean'
      ) {
        sanitized[key] = value;
      }
    }
    return Object.keys(sanitized).length > 0 ? sanitized : null;
  }

  private mapDeviceToken(token: UserDeviceTokenEntity): object {
    return {
      id: token.id,
      userId: token.userId,
      notificationPermission: token.notificationPermission,
      tokenUpdatedAt: token.tokenUpdatedAt?.toISOString(),
      platform: token.platform,
      provider: token.provider,
      installationId: token.installationId,
      appVersion: token.appVersion,
      deviceLabel: token.deviceLabel,
      preferences: {
        ...DEFAULT_PUSH_PREFERENCES,
        ...(token.preferences ?? {}),
      },
      active: token.active,
      lastSeenAt: token.lastSeenAt.toISOString(),
      disabledAt: token.disabledAt?.toISOString() ?? null,
      createdAt: token.createdAt.toISOString(),
      updatedAt: token.updatedAt.toISOString(),
    };
  }

  private mapPushAudit(audit: PushSendAuditEntity): object {
    return {
      id: audit.id,
      senderUserId: audit.senderUserId,
      notificationType: audit.notificationType,
      status: audit.status,
      audienceFilter: audit.audienceFilter,
      title: audit.title,
      body: audit.body,
      dryRun: audit.dryRun,
      targetCount: audit.targetCount,
      sentCount: audit.sentCount,
      failedCount: audit.failedCount,
      skippedCount: audit.skippedCount,
      provider: audit.provider,
      idempotencyKey: audit.idempotencyKey,
      metadata: audit.metadata,
      createdAt: audit.createdAt.toISOString(),
      updatedAt: audit.updatedAt.toISOString(),
    };
  }
}
