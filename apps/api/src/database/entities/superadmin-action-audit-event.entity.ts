import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import type { UserEntity } from './user.entity';

@Entity('superadmin_action_audit_events')
export class SuperadminActionAuditEventEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'actor_user_id', nullable: true })
  actorUserId!: string | null;

  @ManyToOne('UserEntity', { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'actor_user_id' })
  actorUser!: UserEntity | null;

  @Column({ type: 'varchar', length: 64 })
  action!: string;

  @Column({ type: 'varchar', length: 128 })
  target!: string;

  @Column({ type: 'boolean', name: 'sensitive_target', default: false })
  sensitiveTarget!: boolean;

  @Column({ type: 'varchar', length: 32 })
  outcome!: 'success' | 'failure' | 'denied' | 'reverted';

  @Column({ type: 'varchar', length: 128, name: 'correlation_id' })
  correlationId!: string;

  @Column({ type: 'jsonb', nullable: true })
  metadata!: Record<string, string | number | boolean> | null;

  @Column({ type: 'varchar', length: 64, name: 'tamper_hash' })
  tamperHash!: string;

  @Column({
    type: 'varchar',
    length: 64,
    name: 'tamper_prev_hash',
    nullable: true,
  })
  tamperPrevHash!: string | null;

  @Column({ type: 'integer', name: 'tamper_sequence' })
  tamperSequence!: number;

  @Column({ type: 'timestamptz', name: 'performed_at' })
  performedAt!: Date;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt!: Date;
}
