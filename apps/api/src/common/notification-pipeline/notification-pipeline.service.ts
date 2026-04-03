import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AccountPreferenceEntity } from '../../database/entities/account-preference.entity';
import { EmailDeliveryEventEntity } from '../../database/entities/email-delivery-event.entity';
import { EmailQueueItemEntity } from '../../database/entities/email-queue-item.entity';
import {
  EVENT_CATEGORY_MAP,
  MANDATORY_NOTIFICATION_CATEGORIES,
  NotifiableEventType,
} from './notification-event.types';
import type { NotificationCategory } from './notification-event.types';

@Injectable()
export class NotificationPipelineService {
  private readonly logger = new Logger(NotificationPipelineService.name);

  constructor(
    @InjectRepository(AccountPreferenceEntity)
    private readonly preferenceRepo: Repository<AccountPreferenceEntity>,
    @InjectRepository(EmailQueueItemEntity)
    private readonly queueRepo: Repository<EmailQueueItemEntity>,
    @InjectRepository(EmailDeliveryEventEntity)
    private readonly deliveryRepo: Repository<EmailDeliveryEventEntity>,
  ) {}

  async dispatch(event: {
    eventType: NotifiableEventType;
    userId: string;
    profileId?: string;
    metadata?: Record<string, string | number | boolean | null>;
    correlationId: string;
  }): Promise<void> {
    const routing = EVENT_CATEGORY_MAP[event.eventType];
    if (!routing) {
      this.logger.warn(
        JSON.stringify({
          action: 'NOTIFICATION_EVENT_UNMAPPED',
          eventType: event.eventType,
          correlationId: event.correlationId,
        }),
      );
      return;
    }

    const suppressed = await this.suppressedByPreference(
      event.userId,
      routing.category,
    );

    if (suppressed) {
      this.logger.log(
        JSON.stringify({
          action: 'NOTIFICATION_SUPPRESSED',
          eventType: event.eventType,
          category: routing.category,
          correlationId: event.correlationId,
        }),
      );
      return;
    }

    const now = new Date();
    const queueItem = await this.queueRepo.save(
      this.queueRepo.create({
        emailType: routing.emailType,
        recipientScope: 'single',
        status: 'pending',
        scheduledAt: now,
        processedAt: null,
        idempotencyKey: null,
        metadata: {
          userId: event.userId,
          profileId: event.profileId ?? null,
          correlationId: event.correlationId,
          eventType: event.eventType,
          ...(event.metadata ?? {}),
        },
      }),
    );

    await this.deliveryRepo.save(
      this.deliveryRepo.create({
        emailType: routing.emailType,
        recipientScope: 'single',
        outcome: 'pending',
        provider: 'notification-pipeline',
        providerMessageId: null,
        occurredAt: now,
        metadata: {
          queueItemId: queueItem.id,
          source: 'notification-pipeline',
          eventType: event.eventType,
        },
      }),
    );

    this.logger.log(
      JSON.stringify({
        action: 'NOTIFICATION_DISPATCHED',
        eventType: event.eventType,
        emailType: routing.emailType,
        outcome: 'queued',
        correlationId: event.correlationId,
      }),
    );
  }

  async suppressedByPreference(
    userId: string,
    category: NotificationCategory,
  ): Promise<boolean> {
    if (MANDATORY_NOTIFICATION_CATEGORIES.has(category)) return false;
    if (category !== 'product') return false;

    const preference = await this.preferenceRepo.findOne({
      where: { userId },
    });

    if (!preference) return false;
    return preference.productEmailsEnabled === false;
  }
}
