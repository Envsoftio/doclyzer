import {
  BadRequestException,
  ForbiddenException,
  HttpException,
  HttpStatus,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { createHash, timingSafeEqual } from 'node:crypto';
import { MoreThanOrEqual, Repository, SelectQueryBuilder } from 'typeorm';
import { AccountPreferenceEntity } from '../../database/entities/account-preference.entity';
import { PushDeliveryEventEntity } from '../../database/entities/push-delivery-event.entity';
import { PushOpenEventEntity } from '../../database/entities/push-open-event.entity';
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
  billing: true,
  referrals: true,
  product: true,
  adminAnnouncements: true,
};

const ADMIN_PUSH_RATE_LIMIT = {
  maxLiveSends: 10,
  windowMinutes: 60,
} as const;

type PushRecipientScope = 'all' | 'segment' | 'single';

interface ResolvedAudience {
  tokens: UserDeviceTokenEntity[];
  skippedCount: number;
}

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    @InjectRepository(UserDeviceTokenEntity)
    private readonly deviceTokenRepo: Repository<UserDeviceTokenEntity>,
    @InjectRepository(PushSendAuditEntity)
    private readonly pushAuditRepo: Repository<PushSendAuditEntity>,
    @InjectRepository(PushDeliveryEventEntity)
    private readonly deliveryRepo: Repository<PushDeliveryEventEntity>,
    @InjectRepository(PushOpenEventEntity)
    private readonly openRepo: Repository<PushOpenEventEntity>,
    @InjectRepository(AccountPreferenceEntity)
    private readonly accountPreferenceRepo: Repository<AccountPreferenceEntity>,
    private readonly pushProvider: PushProviderService,
    private readonly config: ConfigService,
  ) {}

  async listDeviceTokens(userId: string): Promise<object> {
    const tokens = await this.deviceTokenRepo.find({
      where: { userId },
      order: { lastSeenAt: 'DESC' },
    });
    return { tokens: tokens.map((token) => this.mapDeviceToken(token)) };
  }

  async registerDeviceToken(
    userId: string,
    dto: RegisterDeviceTokenDto,
  ): Promise<object> {
    const providerToken = dto.token.trim();
    const tokenHash = this.hashProviderToken(providerToken);
    const now = new Date();
    const preferences = this.normalizePreferences(dto.preferences);
    const metadata = this.sanitizeMetadata(dto.metadata);

    const existing = await this.deviceTokenRepo.findOne({
      where: { tokenHash },
    });

    const entity =
      existing ??
      this.deviceTokenRepo.create({
        tokenHash,
        createdAt: now,
      });

    entity.userId = userId;
    entity.providerToken = providerToken;
    entity.platform = dto.platform;
    entity.provider = dto.provider ?? 'fcm';
    entity.installationId = dto.installationId?.trim() || null;
    entity.appVersion = dto.appVersion?.trim() || null;
    entity.deviceLabel = dto.deviceLabel?.trim() || null;
    entity.preferences = preferences;
    entity.active = true;
    entity.disabledAt = null;
    entity.lastSeenAt = now;
    entity.metadata = metadata;

    const saved = await this.deviceTokenRepo.save(entity);
    return this.mapDeviceToken(saved);
  }

  async updateDeviceTokenPreferences(
    userId: string,
    deviceTokenId: string,
    dto: UpdateDeviceTokenPreferencesDto,
  ): Promise<object> {
    const token = await this.findOwnedToken(userId, deviceTokenId);
    token.preferences = this.normalizePreferences({
      ...(token.preferences ?? DEFAULT_PUSH_PREFERENCES),
      ...dto.preferences,
    });
    token.lastSeenAt = new Date();
    const saved = await this.deviceTokenRepo.save(token);
    return this.mapDeviceToken(saved);
  }

  async deactivateDeviceToken(
    userId: string,
    deviceTokenId: string,
  ): Promise<object> {
    const token = await this.findOwnedToken(userId, deviceTokenId);
    token.active = false;
    token.disabledAt = new Date();
    token.lastSeenAt = token.disabledAt;
    const saved = await this.deviceTokenRepo.save(token);
    return this.mapDeviceToken(saved);
  }

  async trackPushOpen(userId: string, dto: PushOpenDto): Promise<object> {
    if (dto.deviceTokenId) {
      await this.findOwnedToken(userId, dto.deviceTokenId);
    }

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
      pushOpens: await this.openRepo.count(),
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
    const existing = await this.findExistingAudit(dto.idempotencyKey);
    if (existing) return this.mapPushAudit(existing);

    const requiresApproval = dto.recipientScope !== 'single';
    if (requiresApproval) {
      this.validateApprovalToken(dto.approvalToken);
    }
    await this.enforceAdminPushRateLimit(input.actorUserId);

    const audience = await this.resolveAudience(dto);
    const audit = await this.pushAuditRepo.save(
      this.pushAuditRepo.create({
        senderUserId: input.actorUserId,
        notificationType: dto.notificationType,
        status: 'pending',
        audienceFilter: this.buildAudienceFilter(dto),
        title: dto.title.trim(),
        body: dto.body.trim(),
        dryRun: false,
        targetCount: audience.tokens.length,
        sentCount: 0,
        failedCount: 0,
        skippedCount: audience.skippedCount,
        provider: this.pushProvider.providerName,
        idempotencyKey: dto.idempotencyKey ?? null,
        metadata: {
          correlationId: input.correlationId,
          category: this.getNotificationCategory(dto),
          deepLink: dto.deepLink ?? null,
          requiresApproval,
          approvalToken: dto.approvalToken ? 'provided' : 'none',
        },
      }),
    );

    let sentCount = 0;
    let failedCount = 0;
    const category = this.getNotificationCategory(dto);
    const data = this.buildPushData(dto, audit.id, input.correlationId);

    for (const token of audience.tokens) {
      const result = await this.pushProvider.send({
        token: token.providerToken,
        title: dto.title.trim(),
        body: dto.body.trim(),
        data,
        deepLink: dto.deepLink ?? null,
      });

      if (result.outcome === 'sent') sentCount += 1;
      else failedCount += 1;

      await this.deliveryRepo.save(
        this.deliveryRepo.create({
          pushSendAuditId: audit.id,
          userId: token.userId,
          deviceTokenId: token.id,
          notificationType: dto.notificationType,
          recipientScope: dto.recipientScope,
          outcome: result.outcome,
          provider: result.provider,
          providerMessageId: result.providerMessageId,
          errorCode: result.errorCode,
          occurredAt: new Date(),
          metadata: {
            category,
            platform: token.platform,
            correlationId: input.correlationId,
            errorMessage: result.errorMessage,
          },
        }),
      );

      if (this.shouldDeactivateAfterProviderFailure(result.errorCode)) {
        token.active = false;
        token.disabledAt = new Date();
        token.metadata = {
          ...(token.metadata ?? {}),
          disabledReason: result.errorCode,
        };
        await this.deviceTokenRepo.save(token);
      }
    }

    audit.sentCount = sentCount;
    audit.failedCount = failedCount;
    audit.status =
      audience.tokens.length > 0 && sentCount === 0 && failedCount > 0
        ? 'failed'
        : 'completed';
    const saved = await this.pushAuditRepo.save(audit);

    this.logger.log(
      JSON.stringify({
        action: 'PUSH_ADMIN_SEND',
        pushSendAuditId: saved.id,
        targetCount: saved.targetCount,
        sentCount,
        failedCount,
        correlationId: input.correlationId,
      }),
    );

    return this.mapPushAudit(saved);
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

  private validateApprovalToken(token?: string): void {
    if (!token) {
      throw new ForbiddenException({
        code: 'PUSH_ADMIN_APPROVAL_REQUIRED',
        message: 'Approval token is required for this push audience',
      });
    }

    const secret =
      this.config.get<string>('push.adminApprovalSecret') ??
      this.config.get<string>('PUSH_ADMIN_APPROVAL_SECRET') ??
      '';
    if (!secret) {
      this.logger.error('PUSH_ADMIN_APPROVAL_SECRET is not configured');
      throw new ForbiddenException({
        code: 'PUSH_ADMIN_INVALID_APPROVAL_TOKEN',
        message: 'Invalid approval token',
      });
    }

    const tokenBuffer = Buffer.from(token);
    const secretBuffer = Buffer.from(secret);
    const valid =
      tokenBuffer.length === secretBuffer.length &&
      timingSafeEqual(tokenBuffer, secretBuffer);
    if (!valid) {
      throw new ForbiddenException({
        code: 'PUSH_ADMIN_INVALID_APPROVAL_TOKEN',
        message: 'Invalid approval token',
      });
    }
  }

  private async enforceAdminPushRateLimit(actorUserId: string): Promise<void> {
    const windowStart = new Date();
    windowStart.setMinutes(
      windowStart.getMinutes() - ADMIN_PUSH_RATE_LIMIT.windowMinutes,
    );
    const count = await this.pushAuditRepo.count({
      where: {
        senderUserId: actorUserId,
        dryRun: false,
        createdAt: MoreThanOrEqual(windowStart),
      },
    });
    if (count >= ADMIN_PUSH_RATE_LIMIT.maxLiveSends) {
      throw new HttpException(
        {
          code: 'PUSH_ADMIN_RATE_LIMIT_EXCEEDED',
          message: 'Admin push rate limit exceeded',
        },
        HttpStatus.TOO_MANY_REQUESTS,
      );
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
    dto: AdminPushBroadcastDto,
  ): PushNotificationCategory {
    if (dto.category) return dto.category;
    if (dto.notificationType === 'billing') return 'billing';
    if (dto.notificationType === 'referral') return 'referrals';
    if (dto.notificationType === 'incident') return 'compliance';
    return 'admin_announcements';
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

  private buildPushData(
    dto: AdminPushBroadcastDto,
    pushSendAuditId: string,
    correlationId: string,
  ): Record<string, string> {
    const data: Record<string, string> = {
      notificationType: dto.notificationType,
      category: this.getNotificationCategory(dto),
      pushSendAuditId,
      correlationId,
    };
    if (dto.deepLink) data.deepLink = dto.deepLink;
    if (dto.data) {
      for (const [key, value] of Object.entries(dto.data)) {
        if (value === null || value === undefined) continue;
        data[key] = String(value);
      }
    }
    return data;
  }

  private shouldDeactivateAfterProviderFailure(errorCode: string | null): boolean {
    if (!errorCode) return false;
    return errorCode === 'UNREGISTERED';
  }

  private normalizePreferences(
    raw?: Record<string, boolean>,
  ): Required<PushTokenPreferences> {
    const preferences = { ...DEFAULT_PUSH_PREFERENCES };
    if (!raw) return preferences;
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
