import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import type { UserEntity } from './user.entity';

@Entity('superadmin_auth_audit_events')
export class SuperadminAuthAuditEventEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'actor_user_id' })
  actorUserId!: string;

  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'actor_user_id' })
  actorUser!: UserEntity;

  @Column({ type: 'varchar', length: 64, name: 'action' })
  action!: string;

  @Column({ type: 'varchar', length: 64, name: 'target' })
  target!: string;

  @Column({ type: 'varchar', length: 32, name: 'outcome' })
  outcome!: 'success' | 'failure' | 'denied' | 'reverted';

  @Column({ type: 'varchar', length: 128, name: 'correlation_id' })
  correlationId!: string;

  @Column({
    type: 'varchar',
    length: 255,
    name: 'challenge_id',
    nullable: true,
  })
  challengeId!: string | null;

  @Column({ type: 'varchar', length: 64, name: 'error_code', nullable: true })
  errorCode!: string | null;

  @Column({ type: 'jsonb', name: 'metadata', nullable: true })
  metadata!: Record<string, string | number | boolean> | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
