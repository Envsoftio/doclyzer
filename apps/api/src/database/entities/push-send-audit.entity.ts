import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import type { UserEntity } from './user.entity';

export type PushSendStatus = 'pending' | 'completed' | 'failed';

@Entity('push_send_audit')
@Index('IDX_push_send_audit_sender_created', ['senderUserId', 'createdAt'])
@Index('IDX_push_send_audit_created_at', ['createdAt'])
@Index('UQ_push_send_audit_idempotency', ['idempotencyKey'], {
  unique: true,
})
export class PushSendAuditEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'sender_user_id', nullable: true })
  senderUserId!: string | null;

  @ManyToOne('UserEntity', { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'sender_user_id' })
  senderUser!: UserEntity | null;

  @Column({ type: 'varchar', length: 64, name: 'notification_type' })
  notificationType!: string;

  @Column({ type: 'varchar', length: 32 })
  status!: PushSendStatus;

  @Column({ type: 'jsonb', name: 'audience_filter' })
  audienceFilter!: Record<string, string | number | boolean | null>;

  @Column({ type: 'varchar', length: 120 })
  title!: string;

  @Column({ type: 'varchar', length: 280 })
  body!: string;

  @Column({ type: 'boolean', name: 'dry_run', default: false })
  dryRun!: boolean;

  @Column({ type: 'integer', name: 'target_count', default: 0 })
  targetCount!: number;

  @Column({ type: 'integer', name: 'sent_count', default: 0 })
  sentCount!: number;

  @Column({ type: 'integer', name: 'failed_count', default: 0 })
  failedCount!: number;

  @Column({ type: 'integer', name: 'skipped_count', default: 0 })
  skippedCount!: number;

  @Column({ type: 'varchar', length: 64, nullable: true })
  provider!: string | null;

  @Column({
    type: 'varchar',
    length: 128,
    name: 'idempotency_key',
    nullable: true,
  })
  idempotencyKey!: string | null;

  @Column({ type: 'jsonb', nullable: true })
  metadata!: Record<string, string | number | boolean | null> | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
