import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import type { UserEntity } from './user.entity';
import type { UserReferralProfileEntity } from './user-referral-profile.entity';

@Entity('referral_logs')
export class ReferralLogEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'referrer_user_id' })
  referrerUserId!: string;

  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'referrer_user_id' })
  referrerUser!: UserEntity;

  @Column({ type: 'uuid', name: 'invitee_user_id', unique: true })
  inviteeUserId!: string;

  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'invitee_user_id' })
  inviteeUser!: UserEntity;

  @Column({ type: 'uuid', name: 'referrer_profile_id' })
  referrerProfileId!: string;

  @ManyToOne('UserReferralProfileEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'referrer_profile_id' })
  referrerProfile!: UserReferralProfileEntity;

  @Column({ type: 'varchar', length: 32, name: 'applied_referral_code' })
  appliedReferralCode!: string;

  @Column({
    type: 'varchar',
    length: 32,
    name: 'review_status',
    default: 'pending',
  })
  reviewStatus!: 'pending' | 'released' | 'blocked' | 'under_review';

  @Column({
    type: 'varchar',
    length: 32,
    name: 'invitee_bonus_status',
    default: 'pending',
  })
  inviteeBonusStatus!:
    | 'pending'
    | 'released'
    | 'blocked'
    | 'capped'
    | 'under_review';

  @Column({
    type: 'varchar',
    length: 32,
    name: 'milestone_a_status',
    default: 'pending',
  })
  milestoneAStatus!:
    | 'pending'
    | 'released'
    | 'blocked'
    | 'capped'
    | 'under_review';

  @Column({
    type: 'varchar',
    length: 32,
    name: 'milestone_b_status',
    default: 'pending',
  })
  milestoneBStatus!:
    | 'pending'
    | 'released'
    | 'blocked'
    | 'capped'
    | 'under_review';

  @Column({
    type: 'timestamptz',
    name: 'invitee_bonus_released_at',
    nullable: true,
  })
  inviteeBonusReleasedAt!: Date | null;

  @Column({
    type: 'timestamptz',
    name: 'milestone_a_released_at',
    nullable: true,
  })
  milestoneAReleasedAt!: Date | null;

  @Column({
    type: 'timestamptz',
    name: 'milestone_b_released_at',
    nullable: true,
  })
  milestoneBReleasedAt!: Date | null;

  @Column({
    type: 'varchar',
    length: 64,
    name: 'blocked_reason_code',
    nullable: true,
  })
  blockedReasonCode!: string | null;

  @Column({ type: 'jsonb', nullable: true })
  metadata!: Record<string, unknown> | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
