import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'node:crypto';
import { Repository } from 'typeorm';
import { NotificationService } from './notification.service';
import { NotificationPipelineService } from '../notification-pipeline/notification-pipeline.service';
import { NotifiableEventType } from '../notification-pipeline/notification-event.types';
import { UserEntity } from '../../database/entities/user.entity';

@Injectable()
export class PipelineNotificationService extends NotificationService {
  constructor(
    private readonly pipeline: NotificationPipelineService,
    @InjectRepository(UserEntity)
    private readonly userRepo: Repository<UserEntity>,
  ) {
    super();
  }

  async sendPasswordResetToken(email: string, _rawToken: string): Promise<void> {
    const normalizedEmail = email.trim().toLowerCase();
    const user = await this.userRepo.findOne({
      where: { email: normalizedEmail },
    });
    if (!user) return;

    await this.pipeline.dispatch({
      eventType: NotifiableEventType.ACCOUNT_PASSWORD_RESET,
      userId: user.id,
      correlationId: randomUUID(),
    });
  }
}
