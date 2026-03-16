import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import type { ProfileEntity } from './profile.entity';
import type { UserEntity } from './user.entity';

export type ReportStatus =
  | 'uploading'
  | 'queued'
  | 'parsing'
  | 'parsed'
  | 'unparsed'
  | 'content_not_recognized'
  | 'failed_transient'
  | 'failed_terminal';

@Entity('reports')
export class ReportEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: UserEntity;

  @Column({ type: 'uuid', name: 'profile_id' })
  profileId!: string;

  @ManyToOne('ProfileEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'profile_id' })
  profile!: ProfileEntity;

  @Column({ type: 'varchar', name: 'original_file_name', length: 512 })
  originalFileName!: string;

  @Column({ type: 'varchar', name: 'content_type', length: 128 })
  contentType!: string;

  @Column({ type: 'integer', name: 'size_bytes' })
  sizeBytes!: number;

  @Column({ type: 'varchar', name: 'original_file_storage_key', length: 1024 })
  originalFileStorageKey!: string;

  @Column({ type: 'varchar', name: 'content_hash', length: 64, nullable: true })
  contentHash!: string | null;

  @Column({
    type: 'varchar',
    length: 32,
    default: 'queued',
  })
  status!: ReportStatus;

  @Column({ type: 'text', nullable: true })
  summary!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
