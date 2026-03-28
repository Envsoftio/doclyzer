import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import type { PromoCodeEntity } from './promo-code.entity';
import type { UserEntity } from './user.entity';

@Entity('promo_code_audit_events')
export class PromoCodeAuditEventEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'actor_user_id' })
  actorUserId!: string;

  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'actor_user_id' })
  actorUser!: UserEntity;

  @Column({ type: 'uuid', name: 'promo_code_id' })
  promoCodeId!: string;

  @ManyToOne('PromoCodeEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'promo_code_id' })
  promoCode!: PromoCodeEntity;

  @Column({ type: 'varchar', length: 64, name: 'action' })
  action!: string;

  @Column({ type: 'varchar', length: 128, name: 'target' })
  target!: string;

  @Column({ type: 'varchar', length: 32, name: 'outcome' })
  outcome!: 'success' | 'failure' | 'denied' | 'reverted';

  @Column({ type: 'varchar', length: 128, name: 'correlation_id' })
  correlationId!: string;

  @Column({ type: 'jsonb', name: 'metadata', nullable: true })
  metadata!: Record<string, string | number | boolean | null> | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
