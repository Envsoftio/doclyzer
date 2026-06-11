import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import type { OrderEntity } from './order.entity';
import type { PromoCodeEntity } from './promo-code.entity';
import type { UserEntity } from './user.entity';

export type PromoLifecycleEventType =
  | 'validation'
  | 'reservation'
  | 'redeemed'
  | 'failed'
  | 'voided';

export type PromoLifecycleEventOutcome =
  | 'success'
  | 'failure'
  | 'reverted';

@Entity('promo_lifecycle_events')
export class PromoLifecycleEventEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Index('IDX_promo_lifecycle_events_promo_created_at')
  @Column({ type: 'uuid', name: 'promo_code_id', nullable: true })
  promoCodeId!: string | null;
  @ManyToOne('PromoCodeEntity', { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'promo_code_id' })
  promoCode!: PromoCodeEntity | null;

  @Index('IDX_promo_lifecycle_events_user_id')
  @Column({ type: 'uuid', name: 'user_id', nullable: true })
  userId!: string | null;
  @ManyToOne('UserEntity', { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'user_id' })
  user!: UserEntity | null;

  @Column({ type: 'varchar', length: 64, name: 'promo_code', nullable: true })
  promoCodeValue!: string | null;

  @Column({ type: 'varchar', length: 32, name: 'product_type', nullable: true })
  productType!: 'credit_pack' | 'subscription' | null;

  @Column({ type: 'uuid', name: 'product_ref_id', nullable: true })
  productRefId!: string | null;

  @Index('IDX_promo_lifecycle_events_order_id')
  @Column({ type: 'uuid', name: 'order_id', nullable: true })
  orderId!: string | null;
  @ManyToOne('OrderEntity', { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'order_id' })
  order!: OrderEntity | null;

  @Index('IDX_promo_lifecycle_events_type_created_at')
  @Column({ type: 'varchar', length: 32, name: 'event_type' })
  eventType!: PromoLifecycleEventType;

  @Column({ type: 'varchar', length: 32 })
  outcome!: PromoLifecycleEventOutcome;

  @Column({
    type: 'varchar',
    length: 64,
    name: 'invalid_reason_code',
    nullable: true,
  })
  invalidReasonCode!: string | null;

  @Column({
    type: 'numeric',
    precision: 10,
    scale: 2,
    name: 'discount_amount',
    nullable: true,
  })
  discountAmount!: string | null;

  @Column({
    type: 'numeric',
    precision: 10,
    scale: 2,
    name: 'final_amount',
    nullable: true,
  })
  finalAmount!: string | null;

  @Column({ type: 'varchar', length: 10, nullable: true })
  currency!: string | null;

  @Column({
    type: 'varchar',
    length: 128,
    name: 'idempotency_key',
    nullable: true,
  })
  idempotencyKey!: string | null;

  @Column({ type: 'jsonb', nullable: true })
  metadata!: Record<string, string | number | boolean | null> | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
