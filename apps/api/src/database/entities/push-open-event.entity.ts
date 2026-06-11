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

@Entity('push_open_events')
@Index('IDX_push_open_audit_opened', ['pushSendAuditId', 'openedAt'])
@Index('IDX_push_open_user_opened', ['userId', 'openedAt'])
export class PushOpenEventEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'push_send_audit_id', nullable: true })
  pushSendAuditId!: string | null;

  @ManyToOne('PushSendAuditEntity', { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'push_send_audit_id' })
  pushSendAudit!: PushSendAuditEntity | null;

  @Column({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: UserEntity;

  @Column({ type: 'uuid', name: 'device_token_id', nullable: true })
  deviceTokenId!: string | null;

  @ManyToOne('UserDeviceTokenEntity', {
    onDelete: 'SET NULL',
    nullable: true,
  })
  @JoinColumn({ name: 'device_token_id' })
  deviceToken!: UserDeviceTokenEntity | null;

  @Column({
    type: 'varchar',
    length: 255,
    name: 'provider_message_id',
    nullable: true,
  })
  providerMessageId!: string | null;

  @Column({ type: 'varchar', length: 255, name: 'deep_link', nullable: true })
  deepLink!: string | null;

  @Column({ type: 'timestamptz', name: 'opened_at' })
  openedAt!: Date;

  @Column({ type: 'jsonb', nullable: true })
  metadata!: Record<string, string | number | boolean | null> | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
