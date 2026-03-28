import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import type { PromoCodeEntity } from './promo-code.entity';
import type { UserEntity } from './user.entity';
import type { OrderEntity } from './order.entity';
import type { SubscriptionEntity } from './subscription.entity';

@Entity('promo_redemptions')
export class PromoRedemptionEntity {
  @PrimaryGeneratedColumn('uuid') id!: string;

  @Column({ type: 'uuid', name: 'promo_code_id' }) promoCodeId!: string;
  @ManyToOne('PromoCodeEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'promo_code_id' })
  promoCode!: PromoCodeEntity;

  @Column({ type: 'uuid', name: 'user_id' }) userId!: string;
  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: UserEntity;

  @Column({ type: 'varchar', length: 32, name: 'product_type' })
  productType!: 'credit_pack' | 'subscription';

  @Column({ type: 'uuid', name: 'product_ref_id', nullable: true })
  productRefId!: string | null;

  @Column({ type: 'uuid', name: 'order_id', nullable: true })
  orderId!: string | null;
  @ManyToOne('OrderEntity', { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'order_id' })
  order!: OrderEntity | null;

  @Column({ type: 'uuid', name: 'subscription_id', nullable: true })
  subscriptionId!: string | null;
  @ManyToOne('SubscriptionEntity', { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'subscription_id' })
  subscription!: SubscriptionEntity | null;

  @Column({ type: 'numeric', precision: 10, scale: 2, name: 'discount_amount' })
  discountAmount!: string; // numeric columns return as string in TypeORM

  @Column({ type: 'varchar', length: 10 }) currency!: string;

  @Column({ type: 'varchar', length: 16, default: 'redeemed' })
  status!: 'reserved' | 'redeemed' | 'void';

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
