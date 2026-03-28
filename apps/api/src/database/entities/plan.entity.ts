import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

export interface PlanLimits {
  maxProfiles: number;
  maxReports: number;
  maxShareLinks: number;
  aiChatEnabled: boolean;
}

@Entity('plans')
export class PlanEntity {
  @PrimaryGeneratedColumn('uuid') id!: string;

  @Column({ type: 'varchar', length: 255 }) name!: string;

  @Column({ type: 'varchar', length: 32 }) tier!: string;

  @Column({ type: 'jsonb' }) limits!: PlanLimits;

  @Column({ type: 'jsonb', name: 'price_info', nullable: true })
  priceInfo!: Record<string, unknown> | null;

  @Column({ type: 'varchar', name: 'razorpay_plan_id', nullable: true })
  razorpayPlanId!: string | null;

  @Column({ type: 'boolean', name: 'is_active', default: true })
  isActive!: boolean;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
