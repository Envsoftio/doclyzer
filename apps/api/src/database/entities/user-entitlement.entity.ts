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

@Entity('user_entitlements')
export class UserEntitlementEntity {
  @PrimaryGeneratedColumn('uuid') id!: string;

  @Column({ type: 'uuid', name: 'user_id' }) userId!: string;
  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: UserEntity;

  @Column({ type: 'uuid', name: 'plan_id' }) planId!: string;
  @ManyToOne('PlanEntity', { eager: true }) // eager: plan data always needed with entitlement
  @JoinColumn({ name: 'plan_id' })
  plan!: PlanEntity;

  @Column({
    type: 'numeric',
    precision: 10,
    scale: 2,
    name: 'credit_balance',
    default: 0,
  })
  creditBalance!: string; // numeric columns return as string in TypeORM

  @Column({ type: 'varchar', length: 32, default: 'active' }) status!: string;

  @Column({ type: 'timestamptz', name: 'activated_at', default: () => 'now()' })
  activatedAt!: Date;

  @Column({ type: 'timestamptz', name: 'expires_at', nullable: true })
  expiresAt!: Date | null;

  @Column({
    type: 'varchar',
    name: 'last_change_reason',
    length: 64,
    nullable: true,
  })
  lastChangeReason!: string | null;

  @Column({ type: 'timestamptz', name: 'last_change_at', nullable: true })
  lastChangeAt!: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
