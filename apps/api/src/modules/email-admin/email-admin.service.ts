import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { EmailDeliveryEventEntity } from '../../database/entities/email-delivery-event.entity';
import { EmailQueueItemEntity } from '../../database/entities/email-queue-item.entity';
import { SuperadminAuthAuditEventEntity } from '../../database/entities/superadmin-auth-audit-event.entity';
import {
  EmailAdminApprovalRequiredException,
  EmailAdminInvalidDateRangeException,
  EmailAdminInvalidSendRequestException,
  EmailAdminRateLimitExceededException,
  EMAIL_ADMIN_APPROVAL_REQUIRED,
  EMAIL_ADMIN_RATE_LIMIT_EXCEEDED,
  type EmailAdminSendResponse,
  type EmailDeliveryAnalyticsByType,
  type EmailDeliveryAnalyticsResponse,
  type EmailQueueStatusSnapshot,
  type EmailSendingHistoryResponse,
} from './email-admin.types';
import type {
  EmailAdminSendRequestDto,
  EmailDeliveryAnalyticsQueryDto,
  EmailSendingHistoryQueryDto,
} from './email-admin.dto';

interface DateRange {
  start: Date;
  end: Date;
}

const EMAIL_ADMIN_SEND_POLICY = {
  approvalRequiredScopes: new Set(['all']),
  rateLimitWindowMinutes: 60,
  rateLimitMax: 20,
} as const;

@Injectable()
export class EmailAdminService {
  private readonly logger = new Logger(EmailAdminService.name);

  constructor(
    @InjectRepository(EmailQueueItemEntity)
    private readonly queueRepo: Repository<EmailQueueItemEntity>,
    @InjectRepository(EmailDeliveryEventEntity)
    private readonly deliveryRepo: Repository<EmailDeliveryEventEntity>,
    @InjectRepository(SuperadminAuthAuditEventEntity)
    private readonly auditRepo: Repository<SuperadminAuthAuditEventEntity>,
  ) {}

  async getQueueStatus(input: {
    actorUserId: string;
    correlationId: string;
  }): Promise<EmailQueueStatusSnapshot> {
    const rows = await this.queueRepo
      .createQueryBuilder('queue')
      .select('queue.status', 'status')
      .addSelect('COUNT(*)', 'count')
      .groupBy('queue.status')
      .getRawMany<{ status: string; count: string }>();

    const counts = {
      pending: 0,
      processing: 0,
      completed: 0,
    };

    for (const row of rows) {
      const count = Number.parseInt(row.count, 10) || 0;
      if (row.status === 'pending') counts.pending = count;
      if (row.status === 'processing') counts.processing = count;
      if (row.status === 'completed') counts.completed = count;
    }

    const snapshot: EmailQueueStatusSnapshot = {
      snapshotAt: new Date().toISOString(),
      counts,
      total: counts.pending + counts.processing + counts.completed,
    };

    await this.recordAudit({
      actorUserId: input.actorUserId,
      correlationId: input.correlationId,
      action: 'EMAIL_QUEUE_STATUS_VIEW',
      target: 'email_queue',
      outcome: 'success',
      errorCode: null,
      metadata: {
        pending: snapshot.counts.pending,
        processing: snapshot.counts.processing,
        completed: snapshot.counts.completed,
      },
    });

    return snapshot;
  }

  async getDeliveryAnalytics(input: {
    actorUserId: string;
    correlationId: string;
    query: EmailDeliveryAnalyticsQueryDto;
  }): Promise<EmailDeliveryAnalyticsResponse> {
    const window = this.buildRequiredRange(
      input.query.startDate,
      input.query.endDate,
    );

    const qb = this.deliveryRepo
      .createQueryBuilder('delivery')
      .select('delivery.emailType', 'emailType')
      .addSelect('delivery.outcome', 'outcome')
      .addSelect('COUNT(*)', 'count')
      .where('delivery.occurredAt >= :start', {
        start: window.start.toISOString(),
      })
      .andWhere('delivery.occurredAt <= :end', {
        end: window.end.toISOString(),
      });

    if (input.query.emailType) {
      qb.andWhere('delivery.emailType = :emailType', {
        emailType: input.query.emailType,
      });
    }

    if (input.query.recipientScope) {
      qb.andWhere('delivery.recipientScope = :recipientScope', {
        recipientScope: input.query.recipientScope,
      });
    }

    qb.groupBy('delivery.emailType').addGroupBy('delivery.outcome');

    const rows = await qb.getRawMany<{
      emailType: string;
      outcome: 'sent' | 'failed' | 'bounced';
      count: string;
    }>();

    const byTypeMap = new Map<string, EmailDeliveryAnalyticsByType>();

    for (const row of rows) {
      const key = row.emailType ?? 'unknown';
      if (!byTypeMap.has(key)) {
        byTypeMap.set(key, { emailType: key, sent: 0, failed: 0, bounced: 0 });
      }
      const entry = byTypeMap.get(key);
      if (!entry) continue;
      const count = Number.parseInt(row.count, 10) || 0;
      if (row.outcome === 'sent') entry.sent += count;
      if (row.outcome === 'failed') entry.failed += count;
      if (row.outcome === 'bounced') entry.bounced += count;
    }

    const byType = Array.from(byTypeMap.values()).sort((a, b) =>
      a.emailType.localeCompare(b.emailType),
    );

    const totals = byType.reduce(
      (acc, item) => {
        acc.sent += item.sent;
        acc.failed += item.failed;
        acc.bounced += item.bounced;
        return acc;
      },
      { sent: 0, failed: 0, bounced: 0 },
    );

    const response: EmailDeliveryAnalyticsResponse = {
      window: {
        start: window.start.toISOString(),
        end: window.end.toISOString(),
      },
      filters: {
        emailType: input.query.emailType ?? null,
        recipientScope: input.query.recipientScope ?? null,
      },
      totals,
      byType,
    };

    await this.recordAudit({
      actorUserId: input.actorUserId,
      correlationId: input.correlationId,
      action: 'EMAIL_DELIVERY_ANALYTICS_QUERY',
      target: 'email_delivery_events',
      outcome: 'success',
      errorCode: null,
      metadata: {
        windowStart: response.window.start,
        windowEnd: response.window.end,
        emailType: response.filters.emailType,
        recipientScope: response.filters.recipientScope,
        sent: response.totals.sent,
        failed: response.totals.failed,
        bounced: response.totals.bounced,
      },
    });

    return response;
  }

  async getSendingHistory(input: {
    actorUserId: string;
    correlationId: string;
    query: EmailSendingHistoryQueryDto;
  }): Promise<EmailSendingHistoryResponse> {
    const window = this.buildOptionalRange(
      input.query.startDate,
      input.query.endDate,
    );
    const page = input.query.page ?? 1;
    const pageSize = input.query.pageSize ?? 25;
    const offset = (page - 1) * pageSize;

    const qb = this.deliveryRepo
      .createQueryBuilder('delivery')
      .where('delivery.occurredAt >= :start', {
        start: window.start.toISOString(),
      })
      .andWhere('delivery.occurredAt <= :end', {
        end: window.end.toISOString(),
      })
      .orderBy('delivery.occurredAt', 'DESC')
      .skip(offset)
      .take(pageSize);

    if (input.query.emailType) {
      qb.andWhere('delivery.emailType = :emailType', {
        emailType: input.query.emailType,
      });
    }

    if (input.query.recipientScope) {
      qb.andWhere('delivery.recipientScope = :recipientScope', {
        recipientScope: input.query.recipientScope,
      });
    }

    if (input.query.outcome) {
      qb.andWhere('delivery.outcome = :outcome', {
        outcome: input.query.outcome,
      });
    }

    const [records, total] = await qb.getManyAndCount();

    const response: EmailSendingHistoryResponse = {
      window: {
        start: window.start.toISOString(),
        end: window.end.toISOString(),
      },
      pagination: {
        page,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize) || 1,
      },
      items: records.map((record) => ({
        id: record.id,
        occurredAt: record.occurredAt.toISOString(),
        emailType: record.emailType,
        recipientScope: record.recipientScope,
        outcome: record.outcome,
      })),
    };

    await this.recordAudit({
      actorUserId: input.actorUserId,
      correlationId: input.correlationId,
      action: 'EMAIL_SENDING_HISTORY_QUERY',
      target: 'email_delivery_events',
      outcome: 'success',
      errorCode: null,
      metadata: {
        windowStart: response.window.start,
        windowEnd: response.window.end,
        page,
        pageSize,
        emailType: input.query.emailType ?? null,
        recipientScope: input.query.recipientScope ?? null,
        outcome: input.query.outcome ?? null,
      },
    });

    return response;
  }

  async sendAdminEmail(input: {
    actorUserId: string;
    correlationId: string;
    dto: EmailAdminSendRequestDto;
  }): Promise<EmailAdminSendResponse> {
    const { dto } = input;
    const acceptedAt = new Date();
    const requiresApproval = EMAIL_ADMIN_SEND_POLICY.approvalRequiredScopes.has(
      dto.recipientScope,
    );

    this.assertRecipientScope(dto);

    if (requiresApproval && !dto.approvalToken) {
      await this.recordAudit({
        actorUserId: input.actorUserId,
        correlationId: input.correlationId,
        action: 'EMAIL_ADMIN_SEND_REQUEST',
        target: 'email_queue',
        outcome: 'denied',
        errorCode: EMAIL_ADMIN_APPROVAL_REQUIRED,
        metadata: {
          emailType: dto.emailType,
          recipientScope: dto.recipientScope,
          requiresApproval: true,
          estimatedRecipientCount: dto.estimatedRecipientCount ?? null,
        },
      });
      throw new EmailAdminApprovalRequiredException(
        'Approval required for this recipient scope',
      );
    }

    await this.enforceRateLimit({
      actorUserId: input.actorUserId,
      correlationId: input.correlationId,
      emailType: dto.emailType,
      recipientScope: dto.recipientScope,
      estimatedRecipientCount: dto.estimatedRecipientCount ?? null,
    });

    if (dto.idempotencyKey) {
      const existing = await this.queueRepo.findOne({
        where: { idempotencyKey: dto.idempotencyKey },
      });
      if (existing) {
        const deliveryEvent = await this.findDeliveryEvent(existing.id);
        return {
          state: 'pending',
          emailType: existing.emailType,
          recipientScope: existing.recipientScope,
          queueItemId: existing.id,
          deliveryEventId: deliveryEvent?.id ?? null,
          requiresApproval,
          estimatedRecipientCount: dto.estimatedRecipientCount ?? null,
          acceptedAt: acceptedAt.toISOString(),
        };
      }
    }

    const queueItem = await this.queueRepo.save(
      this.queueRepo.create({
        emailType: dto.emailType,
        recipientScope: dto.recipientScope,
        status: 'pending',
        scheduledAt: acceptedAt,
        processedAt: null,
        idempotencyKey: dto.idempotencyKey ?? null,
        metadata: {
          subject: dto.subject,
          body: dto.body,
          recipientUserId: dto.recipientUserId ?? null,
          recipientSegment: dto.recipientSegment ?? null,
          templateKey: dto.templateKey ?? null,
          templateData: dto.templateData ?? null,
          estimatedRecipientCount: dto.estimatedRecipientCount ?? null,
          actorUserId: input.actorUserId,
        },
      }),
    );

    const deliveryEvent = await this.deliveryRepo.save(
      this.deliveryRepo.create({
        emailType: dto.emailType,
        recipientScope: dto.recipientScope,
        outcome: 'sent',
        provider: 'admin-panel',
        providerMessageId: null,
        occurredAt: acceptedAt,
        metadata: {
          queueItemId: queueItem.id,
          source: 'admin-email-send',
        },
      }),
    );

    await this.recordAudit({
      actorUserId: input.actorUserId,
      correlationId: input.correlationId,
      action: 'EMAIL_ADMIN_SEND_REQUEST',
      target: 'email_queue',
      outcome: 'success',
      errorCode: null,
      metadata: {
        emailType: dto.emailType,
        recipientScope: dto.recipientScope,
        queueItemId: queueItem.id,
        deliveryEventId: deliveryEvent.id,
        requiresApproval,
        estimatedRecipientCount: dto.estimatedRecipientCount ?? null,
        idempotencyKey: dto.idempotencyKey ? 'provided' : 'none',
      },
    });

    return {
      state: 'pending',
      emailType: dto.emailType,
      recipientScope: dto.recipientScope,
      queueItemId: queueItem.id,
      deliveryEventId: deliveryEvent.id,
      requiresApproval,
      estimatedRecipientCount: dto.estimatedRecipientCount ?? null,
      acceptedAt: acceptedAt.toISOString(),
    };
  }

  private buildRequiredRange(startValue: string, endValue: string): DateRange {
    if (!startValue || !endValue) {
      throw new EmailAdminInvalidDateRangeException(
        'startDate and endDate are required',
      );
    }
    const start = new Date(startValue);
    const end = new Date(endValue);
    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) {
      throw new EmailAdminInvalidDateRangeException('Invalid ISO date values');
    }
    if (start >= end) {
      throw new EmailAdminInvalidDateRangeException(
        'startDate must be before endDate',
      );
    }
    return { start, end };
  }

  private buildOptionalRange(
    startValue?: string,
    endValue?: string,
  ): DateRange {
    const now = new Date();
    const defaultStart = new Date(now);
    defaultStart.setDate(defaultStart.getDate() - 30);

    const start = startValue ? new Date(startValue) : defaultStart;
    const end = endValue ? new Date(endValue) : now;

    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) {
      throw new EmailAdminInvalidDateRangeException('Invalid ISO date values');
    }
    if (start > end) {
      throw new EmailAdminInvalidDateRangeException(
        'startDate must be before endDate',
      );
    }
    return { start, end };
  }

  private assertRecipientScope(dto: EmailAdminSendRequestDto): void {
    if (dto.recipientScope === 'single' && !dto.recipientUserId) {
      throw new EmailAdminInvalidSendRequestException(
        'recipientUserId is required for single recipient scope',
      );
    }
    if (dto.recipientScope === 'segment' && !dto.recipientSegment) {
      throw new EmailAdminInvalidSendRequestException(
        'recipientSegment is required for segment recipient scope',
      );
    }
  }

  private async enforceRateLimit(input: {
    actorUserId: string;
    correlationId: string;
    emailType: string;
    recipientScope: string;
    estimatedRecipientCount: number | null;
  }): Promise<void> {
    const windowStart = new Date();
    windowStart.setMinutes(
      windowStart.getMinutes() - EMAIL_ADMIN_SEND_POLICY.rateLimitWindowMinutes,
    );

    const count = await this.auditRepo
      .createQueryBuilder('audit')
      .where('audit.actor_user_id = :actorUserId', {
        actorUserId: input.actorUserId,
      })
      .andWhere('audit.action = :action', {
        action: 'EMAIL_ADMIN_SEND_REQUEST',
      })
      .andWhere('audit.outcome = :outcome', { outcome: 'success' })
      .andWhere('audit.created_at >= :windowStart', {
        windowStart: windowStart.toISOString(),
      })
      .getCount();

    if (count >= EMAIL_ADMIN_SEND_POLICY.rateLimitMax) {
      await this.recordAudit({
        actorUserId: input.actorUserId,
        correlationId: input.correlationId,
        action: 'EMAIL_ADMIN_SEND_REQUEST',
        target: 'email_queue',
        outcome: 'denied',
        errorCode: EMAIL_ADMIN_RATE_LIMIT_EXCEEDED,
        metadata: {
          emailType: input.emailType,
          recipientScope: input.recipientScope,
          requiresApproval: EMAIL_ADMIN_SEND_POLICY.approvalRequiredScopes.has(
            input.recipientScope,
          ),
          estimatedRecipientCount: input.estimatedRecipientCount,
        },
      });
      throw new EmailAdminRateLimitExceededException(
        'Admin email rate limit exceeded',
      );
    }
  }

  private async findDeliveryEvent(
    queueItemId: string,
  ): Promise<EmailDeliveryEventEntity | null> {
    return this.deliveryRepo
      .createQueryBuilder('delivery')
      .where("delivery.metadata ->> 'queueItemId' = :queueItemId", {
        queueItemId,
      })
      .orderBy('delivery.occurredAt', 'DESC')
      .getOne();
  }

  private async recordAudit(input: {
    actorUserId: string;
    correlationId: string;
    action: string;
    target: string;
    outcome: 'success' | 'failure' | 'denied' | 'reverted';
    errorCode: string | null;
    metadata: Record<string, string | number | boolean | null>;
  }): Promise<void> {
    const metadata = Object.fromEntries(
      Object.entries(input.metadata).filter(([, value]) => value !== null),
    ) as Record<string, string | number | boolean>;

    const audit = this.auditRepo.create({
      actorUserId: input.actorUserId,
      action: input.action,
      target: input.target,
      outcome: input.outcome,
      correlationId: input.correlationId,
      challengeId: null,
      errorCode: input.errorCode,
      metadata: Object.keys(metadata).length === 0 ? null : metadata,
    });

    try {
      await this.auditRepo.save(audit);
      this.logger.log(
        JSON.stringify({
          action: audit.action,
          target: audit.target,
          outcome: audit.outcome,
          correlationId: audit.correlationId,
          actorUserId: audit.actorUserId,
        }),
      );
    } catch (err) {
      this.logger.error('Failed to persist email admin audit event', err);
    }
  }
}
