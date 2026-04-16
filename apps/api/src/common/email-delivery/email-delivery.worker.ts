import {
  Inject,
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { EmailDeliveryEventEntity } from '../../database/entities/email-delivery-event.entity';
import { EmailQueueItemEntity } from '../../database/entities/email-queue-item.entity';
import { UserEntity } from '../../database/entities/user.entity';
import { VerificationEntity } from '../../database/entities/verification.entity';
import { redactSecrets } from '../redact-secrets';
import type { EmailSendResult } from './email-provider.interface';
import { EMAIL_PROVIDER, type EmailProvider } from './email-provider.interface';
import { EmailTemplateService } from './email-template.service';
import { EMAIL_TEMPLATE_REGISTRY } from './template-registry';

interface QueueMetadata {
  userId?: string | null;
  profileId?: string | null;
  correlationId?: string | null;
  eventType?: string | null;
  recipientUserId?: string | null;
  recipientSegment?: string | null;
  templateKey?: string | null;
  estimatedRecipientCount?: number | null;
  actorUserId?: string | null;
}

@Injectable()
export class EmailDeliveryWorkerService
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(EmailDeliveryWorkerService.name);
  private interval: NodeJS.Timeout | null = null;

  constructor(
    private readonly configService: ConfigService,
    private readonly dataSource: DataSource,
    @InjectRepository(EmailQueueItemEntity)
    private readonly queueRepo: Repository<EmailQueueItemEntity>,
    @InjectRepository(EmailDeliveryEventEntity)
    private readonly deliveryRepo: Repository<EmailDeliveryEventEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
    @InjectRepository(VerificationEntity)
    private readonly verificationRepo: Repository<VerificationEntity>,
    private readonly templateService: EmailTemplateService,
    @Inject(EMAIL_PROVIDER) private readonly provider: EmailProvider,
  ) {}

  onModuleInit(): void {
    const enabled = this.configService.get<boolean>('email.worker.enabled');
    if (!enabled) return;

    const pollIntervalMs = Math.max(
      1000,
      this.configService.get<number>('email.worker.pollIntervalMs') ?? 15000,
    );

    this.interval = setInterval(() => {
      void this.processPendingBatch();
    }, pollIntervalMs);
  }

  onModuleDestroy(): void {
    if (this.interval) clearInterval(this.interval);
  }

  async processPendingBatch(): Promise<void> {
    const batchSize = Math.max(
      1,
      this.configService.get<number>('email.worker.batchSize') ?? 25,
    );
    const now = new Date();

    const items = await this.dataSource.transaction(async (manager) => {
      const repo = manager.getRepository(EmailQueueItemEntity);
      const pending = await repo
        .createQueryBuilder('queue')
        .setLock('pessimistic_write')
        .setOnLocked('skip_locked')
        .where('queue.status = :status', { status: 'pending' })
        .andWhere('queue.scheduledAt <= :now', { now: now.toISOString() })
        .orderBy('queue.scheduledAt', 'ASC')
        .take(batchSize)
        .getMany();

      if (pending.length === 0) return [];

      for (const item of pending) {
        item.status = 'processing';
        await repo.save(item);
      }

      return pending;
    });

    if (items.length === 0) return;

    for (const item of items) {
      await this.processQueueItem(item);
    }
  }

  private async processQueueItem(item: EmailQueueItemEntity): Promise<void> {
    const metadata = (item.metadata ?? {}) as QueueMetadata;
    const queueItemId = item.id;

    try {
      const { subject, templateKey, templateData } = await this.resolveTemplate(
        item,
        metadata,
      );

      const recipients = await this.resolveRecipients(item, metadata);

      const html = await this.templateService.renderHtml(
        templateKey,
        templateData,
      );
      const text = await this.templateService.renderText(
        templateKey,
        templateData,
      );

      const sendResult = await this.provider.send({
        to: recipients,
        subject,
        html,
        text,
        fromName: this.configService.getOrThrow<string>('email.fromName'),
        fromAddress: this.configService.getOrThrow<string>('email.fromAddress'),
        metadata: {
          queueItemId,
          emailType: item.emailType,
          recipientScope: item.recipientScope,
        },
      });

      await this.applyOutcome(item, sendResult, templateKey);

      this.logger.log(
        JSON.stringify({
          action: 'EMAIL_QUEUE_PROCESSED',
          queueItemId,
          emailType: item.emailType,
          outcome: sendResult.outcome,
        }),
      );
    } catch (error) {
      await this.applyOutcome(
        item,
        {
          outcome: 'failed',
          provider: 'worker',
          providerMessageId: null,
          errorCode: 'EMAIL_WORKER_ERROR',
        },
        null,
      );

      const msg = error instanceof Error ? error.message : String(error);
      this.logger.error(
        redactSecrets(
          JSON.stringify({
            action: 'EMAIL_QUEUE_FAILED',
            queueItemId,
            emailType: item.emailType,
            error: msg,
          }),
        ),
      );
    }
  }

  private async resolveRecipients(
    item: EmailQueueItemEntity,
    metadata: QueueMetadata,
  ): Promise<string[]> {
    if (item.recipientScope === 'single') {
      const userId = metadata.recipientUserId ?? metadata.userId;
      if (!userId) {
        throw new Error('EMAIL_RECIPIENT_MISSING');
      }
      const user = await this.userRepo.findOne({ where: { id: userId } });
      if (!user) throw new Error('EMAIL_RECIPIENT_NOT_FOUND');
      return [user.email];
    }

    // Broadcast/segment sends are handled by provider-level fan-out.
    return [];
  }

  private async resolveTemplate(
    item: EmailQueueItemEntity,
    metadata: QueueMetadata,
  ): Promise<{
    subject: string;
    templateKey: string;
    templateData: Record<string, string | number | boolean | null>;
  }> {
    if (metadata.templateKey) {
      return {
        subject:
          EMAIL_TEMPLATE_REGISTRY[item.emailType]?.subject ??
          EMAIL_TEMPLATE_REGISTRY[metadata.templateKey]?.subject ??
          'Doclyzer update',
        templateKey: metadata.templateKey,
        templateData: {},
      };
    }

    const registry = EMAIL_TEMPLATE_REGISTRY[item.emailType];
    if (!registry) {
      throw new Error(`EMAIL_TEMPLATE_NOT_FOUND:${item.emailType}`);
    }

    if (item.emailType === 'account.password_reset') {
      const payload = await this.buildPasswordResetData(metadata);
      return {
        subject: registry.subject,
        templateKey: registry.templateKey,
        templateData: payload,
      };
    }

    return {
      subject: registry.subject,
      templateKey: registry.templateKey,
      templateData: {},
    };
  }

  private async buildPasswordResetData(
    metadata: QueueMetadata,
  ): Promise<Record<string, string | number | boolean | null>> {
    const userId = metadata.userId ?? metadata.recipientUserId;
    if (!userId) throw new Error('PASSWORD_RESET_USER_MISSING');
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) throw new Error('PASSWORD_RESET_USER_NOT_FOUND');

    const verification = await this.verificationRepo.findOne({
      where: { identifier: user.email },
      order: { createdAt: 'DESC' },
    });

    if (!verification) throw new Error('PASSWORD_RESET_TOKEN_NOT_FOUND');

    const now = new Date();
    const expiresAt = verification.expiresAt;
    if (expiresAt <= now) {
      throw new Error('PASSWORD_RESET_TOKEN_EXPIRED');
    }

    const baseUrl = this.configService.getOrThrow<string>('email.auth.baseUrl');
    const basePath = this.configService.getOrThrow<string>(
      'email.auth.basePath',
    );

    const resetLink = `${baseUrl}${basePath}/reset-password?token=${encodeURIComponent(
      verification.value,
    )}`;

    const expiryMinutes = Math.max(
      1,
      Math.round((expiresAt.getTime() - now.getTime()) / 60000),
    );

    return {
      resetLink,
      expiryMinutes,
    };
  }

  private async applyOutcome(
    item: EmailQueueItemEntity,
    result: EmailSendResult,
    templateKey: string | null,
  ): Promise<void> {
    const now = new Date();

    item.status = 'completed';
    item.processedAt = now;
    await this.queueRepo.save(item);

    const event = await this.findDeliveryEvent(item.id);
    if (event) {
      event.outcome = result.outcome;
      event.provider = result.provider;
      event.providerMessageId = result.providerMessageId;
      event.occurredAt = now;
      event.metadata = {
        ...(event.metadata ?? {}),
        queueItemId: item.id,
        source: event.metadata?.source ?? 'email-worker',
        recipientScope: item.recipientScope,
        templateKey,
        errorCode: result.errorCode ?? null,
      };
      await this.deliveryRepo.save(event);
      return;
    }

    await this.deliveryRepo.save(
      this.deliveryRepo.create({
        emailType: item.emailType,
        recipientScope: item.recipientScope,
        outcome: result.outcome,
        provider: result.provider,
        providerMessageId: result.providerMessageId,
        occurredAt: now,
        metadata: {
          queueItemId: item.id,
          source: 'email-worker',
          recipientScope: item.recipientScope,
          templateKey,
          errorCode: result.errorCode ?? null,
        },
      }),
    );
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
}
