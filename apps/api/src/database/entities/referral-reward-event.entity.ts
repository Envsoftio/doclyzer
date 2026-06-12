import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import type { ReferralLogEntity } from './referral-log.entity';
import type { UserEntity } from './user.entity';

@Entity('referral_reward_events')
export class ReferralRewardEventEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'referral_log_id' })
  referralLogId!: string;

  @ManyToOne('ReferralLogEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'referral_log_id' })
  referralLog!: ReferralLogEntity;

  @Column({ type: 'uuid', name: 'beneficiary_user_id' })
  beneficiaryUserId!: string;

  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'beneficiary_user_id' })
  beneficiaryUser!: UserEntity;

  @Column({ type: 'varchar', length: 32, name: 'reward_type' })
  rewardType!: 'invitee_bonus' | 'milestone_a' | 'milestone_b';

  @Column({ type: 'varchar', length: 32, name: 'status', default: 'pending' })
  status!: 'pending' | 'released' | 'blocked' | 'capped' | 'under_review';

  @Column({
    type: 'numeric',
    precision: 10,
    scale: 2,
    name: 'credit_amount',
  })
  creditAmount!: string;

  @Column({
    type: 'varchar',
    length: 128,
    name: 'idempotency_key',
    nullable: true,
  })
  idempotencyKey!: string | null;

  @Column({
    type: 'varchar',
    length: 64,
    name: 'reason_code',
    nullable: true,
  })
  reasonCode!: string | null;

  @Column({ type: 'jsonb', nullable: true })
  metadata!: Record<string, unknown> | null;

  @Column({ type: 'timestamptz', name: 'resolved_at', nullable: true })
  resolvedAt!: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
