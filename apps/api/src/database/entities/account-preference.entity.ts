import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import type { UserEntity } from './user.entity';

@Entity('account_preferences')
export class AccountPreferenceEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'user_id', unique: true })
  userId!: string;

  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: UserEntity;

  @Column({ type: 'boolean', name: 'product_emails_enabled', default: true })
  productEmailsEnabled!: boolean;

  @Column({ type: 'boolean', name: 'report_ready_enabled', default: true })
  reportReadyEnabled!: boolean;

  @Column({ type: 'boolean', name: 'upload_updates_enabled', default: true })
  uploadUpdatesEnabled!: boolean;

  @Column({ type: 'boolean', name: 'share_reminders_enabled', default: true })
  shareRemindersEnabled!: boolean;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
