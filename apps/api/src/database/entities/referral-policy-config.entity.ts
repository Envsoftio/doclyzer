import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('referral_policy_configs')
export class ReferralPolicyConfigEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 64, name: 'config_key', unique: true })
  configKey!: string;

  @Column({
    type: 'numeric',
    precision: 10,
    scale: 2,
    name: 'invitee_bonus_credits',
  })
  inviteeBonusCredits!: string;

  @Column({
    type: 'numeric',
    precision: 10,
    scale: 2,
    name: 'milestone_a_credits',
  })
  milestoneACredits!: string;

  @Column({ type: 'jsonb', name: 'milestone_b_tiers' })
  milestoneBTiers!: Array<{
    label: string;
    thresholdAmount: number;
    rewardCredits: number;
  }>;

  @Column({
    type: 'numeric',
    precision: 10,
    scale: 2,
    name: 'monthly_reward_cap',
  })
  monthlyRewardCap!: string;

  @Column({
    type: 'boolean',
    name: 'zero_amount_order_eligible',
    default: false,
  })
  zeroAmountOrderEligible!: boolean;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
