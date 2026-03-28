import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('credit_packs')
export class CreditPackEntity {
  @PrimaryGeneratedColumn('uuid') id!: string;

  @Column({ type: 'varchar', length: 255 }) name!: string;

  @Column({ type: 'integer' }) credits!: number;

  @Column({ type: 'numeric', precision: 10, scale: 2, name: 'price_inr' })
  priceInr!: string; // numeric columns return as string in TypeORM

  @Column({ type: 'numeric', precision: 10, scale: 2, name: 'price_usd' })
  priceUsd!: string;

  @Column({ type: 'boolean', name: 'is_active', default: true })
  isActive!: boolean;

  @Column({ type: 'integer', name: 'sort_order', default: 0 })
  sortOrder!: number;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
