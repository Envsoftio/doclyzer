import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import type { PushSendAuditEntity } from './push-send-audit.entity';
import type { UserDeviceTokenEntity } from './user-device-token.entity';
import type { UserEntity } from './user.entity';

export type PushDeliveryOutcome = 'pending' | 'sent' | 'failed' | 'skipped';

@Entity('push_delivery_events')
@Index('IDX_push_delivery_audit_outcome', ['pushSendAuditId', 'outcome'])
@Index('IDX_push_delivery_user_occurred', ['userId', 'occurredAt'])
@Index('IDX_push_delivery_occurred_at', ['occurredAt'])
export class PushDeliveryEventEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'push_send_audit_id', nullable: true })
  pushSendAuditId!: string | null;

  @ManyToOne('PushSendAuditEntity', { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'push_send_audit_id' })
  pushSendAudit!: PushSendAuditEntity | null;

  @Column({ type: 'uuid', name: 'user_id', nullable: true })
  userId!: string | null;

  @ManyToOne('UserEntity', { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'user_id' })
  user!: UserEntity | null;

  @Column({ type: 'uuid', name: 'device_token_id', nullable: true })
  deviceTokenId!: string | null;

  @ManyToOne('UserDeviceTokenEntity', {
    onDelete: 'SET NULL',
    nullable: true,
  })
  @JoinColumn({ name: 'device_token_id' })
  deviceToken!: UserDeviceTokenEntity | null;

  @Column({ type: 'varchar', length: 64, name: 'notification_type' })
  notificationType!: string;

  @Column({ type: 'varchar', length: 32, name: 'recipient_scope' })
  recipientScope!: string;

  @Column({ type: 'varchar', length: 32 })
  outcome!: PushDeliveryOutcome;

  @Column({ type: 'varchar', length: 64, nullable: true })
  provider!: string | null;

  @Column({
    type: 'varchar',
    length: 255,
    name: 'provider_message_id',
    nullable: true,
  })
  providerMessageId!: string | null;

  @Column({
    type: 'varchar',
    length: 96,
    name: 'error_code',
    nullable: true,
  })
  errorCode!: string | null;

  @Column({ type: 'timestamptz', name: 'occurred_at' })
  occurredAt!: Date;

  @Column({ type: 'jsonb', nullable: true })
  metadata!: Record<string, string | number | boolean | null> | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
