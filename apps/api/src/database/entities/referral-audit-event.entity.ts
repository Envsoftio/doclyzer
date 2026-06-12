import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import type { ReferralLogEntity } from './referral-log.entity';
import type { ReferralRewardEventEntity } from './referral-reward-event.entity';
import type { UserEntity } from './user.entity';

@Entity('referral_audit_events')
export class ReferralAuditEventEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'referral_log_id', nullable: true })
  referralLogId!: string | null;

  @ManyToOne('ReferralLogEntity', { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'referral_log_id' })
  referralLog!: ReferralLogEntity | null;

  @Column({ type: 'uuid', name: 'reward_event_id', nullable: true })
  rewardEventId!: string | null;

  @ManyToOne('ReferralRewardEventEntity', { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'reward_event_id' })
  rewardEvent!: ReferralRewardEventEntity | null;

  @Column({ type: 'uuid', name: 'actor_user_id', nullable: true })
  actorUserId!: string | null;

  @ManyToOne('UserEntity', { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'actor_user_id' })
  actorUser!: UserEntity | null;

  @Column({ type: 'varchar', length: 64, name: 'event_type' })
  eventType!: string;

  @Column({ type: 'varchar', length: 32, name: 'outcome' })
  outcome!: 'success' | 'failure' | 'blocked' | 'capped' | 'pending';

  @Column({
    type: 'varchar',
    length: 64,
    name: 'reason_code',
    nullable: true,
  })
  reasonCode!: string | null;

  @Column({ type: 'jsonb', nullable: true })
  metadata!: Record<string, unknown> | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
