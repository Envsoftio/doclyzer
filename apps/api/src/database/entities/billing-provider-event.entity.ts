import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import type { OrderEntity } from './order.entity';

export type BillingProviderEventOutcome =
  | 'received'
  | 'duplicate'
  | 'reconciled'
  | 'failed'
  | 'pending_review'
  | 'invalid_signature'
  | 'ignored';

@Entity('billing_provider_events')
export class BillingProviderEventEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 32 })
  provider!: string;

  @Column({
    type: 'varchar',
    length: 255,
    name: 'provider_event_id',
    nullable: true,
  })
  providerEventId!: string | null;

  @Index('UQ_billing_provider_events_idempotency', { unique: true })
  @Column({ type: 'varchar', length: 128, name: 'idempotency_key' })
  idempotencyKey!: string;

  @Column({ type: 'varchar', length: 64, name: 'event_type' })
  eventType!: string;

  @Column({ type: 'uuid', name: 'order_id', nullable: true })
  orderId!: string | null;
  @ManyToOne('OrderEntity', { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'order_id' })
  order!: OrderEntity | null;

  @Column({
    type: 'varchar',
    length: 255,
    name: 'razorpay_order_id',
    nullable: true,
  })
  razorpayOrderId!: string | null;

  @Column({
    type: 'varchar',
    length: 255,
    name: 'razorpay_payment_id',
    nullable: true,
  })
  razorpayPaymentId!: string | null;

  @Column({ type: 'varchar', length: 32, default: 'received' })
  outcome!: BillingProviderEventOutcome;

  @Column({ type: 'varchar', length: 64, name: 'error_code', nullable: true })
  errorCode!: string | null;

  @Column({ type: 'jsonb', nullable: true })
  metadata!: Record<string, string | number | boolean | null> | null;

  @CreateDateColumn({ name: 'received_at', type: 'timestamptz' })
  receivedAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
