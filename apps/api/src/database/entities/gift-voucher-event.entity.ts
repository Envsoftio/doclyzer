import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import type { GiftVoucherEntity } from './gift-voucher.entity';
import type { UserEntity } from './user.entity';

@Entity('gift_voucher_events')
export class GiftVoucherEventEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'gift_voucher_id' })
  giftVoucherId!: string;
  @ManyToOne('GiftVoucherEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'gift_voucher_id' })
  giftVoucher!: GiftVoucherEntity;

  @Column({ type: 'uuid', name: 'actor_user_id', nullable: true })
  actorUserId!: string | null;
  @ManyToOne('UserEntity', { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'actor_user_id' })
  actorUser!: UserEntity | null;

  @Column({ type: 'varchar', length: 64, name: 'event_type' })
  eventType!: string;

  @Column({ type: 'varchar', length: 32 })
  outcome!: 'success' | 'blocked' | 'failure';

  @Column({ type: 'jsonb', nullable: true })
  metadata!: Record<string, unknown> | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
