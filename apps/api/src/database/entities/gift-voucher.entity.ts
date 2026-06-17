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

@Entity('gift_vouchers')
export class GiftVoucherEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 64, name: 'code_hash', unique: true })
  codeHash!: string;

  @Column({ type: 'varchar', length: 24, name: 'code_mask' })
  codeMask!: string;

  @Column({
    type: 'numeric',
    precision: 10,
    scale: 2,
    name: 'credit_amount',
  })
  creditAmount!: string;

  @Column({ type: 'varchar', length: 32, default: 'active' })
  status!: 'active' | 'redeemed' | 'voided' | 'expired';

  @Column({ type: 'timestamptz', name: 'expires_at', nullable: true })
  expiresAt!: Date | null;

  @Column({ type: 'uuid', name: 'created_by_user_id', nullable: true })
  createdByUserId!: string | null;
  @ManyToOne('UserEntity', { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'created_by_user_id' })
  createdByUser!: UserEntity | null;

  @Column({ type: 'uuid', name: 'redeemed_by_user_id', nullable: true })
  redeemedByUserId!: string | null;
  @ManyToOne('UserEntity', { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'redeemed_by_user_id' })
  redeemedByUser!: UserEntity | null;

  @Column({ type: 'timestamptz', name: 'redeemed_at', nullable: true })
  redeemedAt!: Date | null;

  @Column({ type: 'uuid', name: 'voided_by_user_id', nullable: true })
  voidedByUserId!: string | null;
  @ManyToOne('UserEntity', { onDelete: 'SET NULL' })
  @JoinColumn({ name: 'voided_by_user_id' })
  voidedByUser!: UserEntity | null;

  @Column({ type: 'timestamptz', name: 'voided_at', nullable: true })
  voidedAt!: Date | null;

  @Column({ type: 'varchar', length: 240, name: 'void_reason', nullable: true })
  voidReason!: string | null;

  @Column({ type: 'jsonb', nullable: true })
  metadata!: Record<string, unknown> | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
