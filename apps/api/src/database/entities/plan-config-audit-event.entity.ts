import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import type { PlanEntity } from './plan.entity';
import type { UserEntity } from './user.entity';

@Entity('plan_config_audit_events')
export class PlanConfigAuditEventEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'actor_user_id' })
  actorUserId!: string;

  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'actor_user_id' })
  actorUser!: UserEntity;

  @Column({ type: 'uuid', name: 'plan_id' })
  planId!: string;

  @ManyToOne('PlanEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'plan_id' })
  plan!: PlanEntity;

  @Column({ type: 'varchar', length: 64, name: 'action' })
  action!: string;

  @Column({ type: 'varchar', length: 128, name: 'target' })
  target!: string;

  @Column({ type: 'varchar', length: 32, name: 'outcome' })
  outcome!: 'success' | 'failure' | 'denied' | 'reverted';

  @Column({ type: 'varchar', length: 128, name: 'correlation_id' })
  correlationId!: string;

  @Column({ type: 'integer', name: 'previous_config_version' })
  previousConfigVersion!: number;

  @Column({ type: 'integer', name: 'new_config_version' })
  newConfigVersion!: number;

  @Column({ type: 'varchar', length: 64, name: 'error_code', nullable: true })
  errorCode!: string | null;

  @Column({ type: 'jsonb', name: 'metadata', nullable: true })
  metadata!: Record<string, string | number | boolean | null> | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
