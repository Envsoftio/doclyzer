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

export type SupportRequestStatus = 'open' | 'triaged' | 'resolved';

@Entity('support_requests')
export class SupportRequestEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: UserEntity;

  @Column({ type: 'varchar', length: 64, name: 'action_type' })
  actionType!: string;

  @Column({ type: 'varchar', length: 128, name: 'correlation_id' })
  correlationId!: string;

  @Column({ type: 'varchar', length: 128, name: 'client_action_id', nullable: true })
  clientActionId!: string | null;

  @Column({ type: 'varchar', length: 64, name: 'error_code', nullable: true })
  errorCode!: string | null;

  @Column({ type: 'text', name: 'error_message', nullable: true })
  errorMessage!: string | null;

  @Column({ type: 'jsonb', name: 'entity_ids', nullable: true })
  entityIds!: Record<string, string> | null;

  @Column({ type: 'jsonb', nullable: true })
  metadata!: Record<string, string | number | boolean> | null;

  @Column({ type: 'text', name: 'user_message', nullable: true })
  userMessage!: string | null;

  @Column({ type: 'varchar', length: 24, default: 'open' })
  status!: SupportRequestStatus;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt!: Date;
}
