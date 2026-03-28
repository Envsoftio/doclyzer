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
import type { CreditPackEntity } from './credit-pack.entity';

@Entity('orders')
export class OrderEntity {
  @PrimaryGeneratedColumn('uuid') id!: string;

  @Column({ type: 'uuid', name: 'user_id' }) userId!: string;
  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' }) user!: UserEntity;

  @Column({ type: 'uuid', name: 'credit_pack_id' }) creditPackId!: string;
  @ManyToOne('CreditPackEntity') // no cascade — orders reference packs, don't own them
  @JoinColumn({ name: 'credit_pack_id' }) creditPack!: CreditPackEntity;

  @Column({ type: 'numeric', precision: 10, scale: 2 })
  amount!: string; // numeric columns return as string in TypeORM

  @Column({ type: 'varchar', length: 10 }) currency!: string;

  @Column({ type: 'varchar', length: 32, default: 'pending' })
  status!: string; // pending | paid | reconciled | failed

  @Column({ type: 'varchar', length: 255, name: 'razorpay_order_id', unique: true })
  razorpayOrderId!: string;

  @Column({ type: 'varchar', length: 255, name: 'razorpay_payment_id', nullable: true })
  razorpayPaymentId!: string | null;

  @Column({ type: 'varchar', length: 512, name: 'razorpay_signature', nullable: true })
  razorpaySignature!: string | null;

  @Column({ type: 'boolean', default: false })
  credited!: boolean;

  @Column({ type: 'jsonb', nullable: true })
  metadata!: Record<string, unknown> | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
