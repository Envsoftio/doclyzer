import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('promo_codes')
export class PromoCodeEntity {
  @PrimaryGeneratedColumn('uuid') id!: string;

  @Column({ type: 'varchar', length: 64, unique: true }) code!: string;

  @Column({ type: 'varchar', length: 16, name: 'discount_type' })
  discountType!: 'percentage' | 'fixed';

  @Column({ type: 'numeric', precision: 10, scale: 2, name: 'discount_value' })
  discountValue!: string; // numeric columns return as string in TypeORM

  @Column({ type: 'varchar', length: 16, name: 'applies_to' })
  appliesTo!: 'credit_pack' | 'subscription' | 'both';

  @Column({ type: 'timestamptz', name: 'valid_from', nullable: true })
  validFrom!: Date | null;

  @Column({ type: 'timestamptz', name: 'valid_until', nullable: true })
  validUntil!: Date | null;

  @Column({ type: 'integer', name: 'usage_cap_total', nullable: true })
  usageCapTotal!: number | null;

  @Column({ type: 'integer', name: 'usage_cap_per_user', nullable: true })
  usageCapPerUser!: number | null;

  @Column({ type: 'boolean', name: 'is_active', default: true })
  isActive!: boolean;

  @Column({ type: 'jsonb', nullable: true })
  metadata!: Record<string, unknown> | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
