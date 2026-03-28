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
import type { PlanEntity } from './plan.entity';

@Entity('subscriptions')
export class SubscriptionEntity {
  @PrimaryGeneratedColumn('uuid') id!: string;

  @Column({ type: 'uuid', name: 'user_id' }) userId!: string;
  @ManyToOne('UserEntity', { onDelete: 'CASCADE' }) // user owns subscriptions
  @JoinColumn({ name: 'user_id' }) user!: UserEntity;

  @Column({ type: 'uuid', name: 'plan_id' }) planId!: string;
  @ManyToOne('PlanEntity') // no cascade — subscriptions reference plans
  @JoinColumn({ name: 'plan_id' }) plan!: PlanEntity;

  @Column({ type: 'varchar', length: 32, default: 'created' }) status!: string;

  @Column({ type: 'varchar', name: 'razorpay_subscription_id', unique: true })
  razorpaySubscriptionId!: string;

  @Column({ type: 'varchar', name: 'razorpay_payment_id', nullable: true })
  razorpayPaymentId!: string | null;

  @Column({ type: 'varchar', name: 'razorpay_signature', nullable: true })
  razorpaySignature!: string | null;

  @Column({ type: 'timestamptz', name: 'current_period_start', nullable: true })
  currentPeriodStart!: Date | null;

  @Column({ type: 'timestamptz', name: 'current_period_end', nullable: true })
  currentPeriodEnd!: Date | null;

  @Column({ type: 'jsonb', nullable: true })
  metadata!: Record<string, unknown> | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
