import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import type { UserEntity } from './user.entity';

export type DataExportStatus = 'pending' | 'completed' | 'failed';

@Entity('data_export_requests')
export class DataExportRequestEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: UserEntity;

  @Column({
    type: 'varchar',
    length: 32,
    enum: ['pending', 'completed', 'failed'],
  })
  status!: DataExportStatus;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @Column({ type: 'timestamptz', name: 'completed_at', nullable: true })
  completedAt!: Date | null;

  @Column({
    type: 'varchar',
    length: 2048,
    name: 'download_url',
    nullable: true,
  })
  downloadUrl!: string | null;

  @Column({ type: 'text', name: 'failure_reason', nullable: true })
  failureReason!: string | null;
}
