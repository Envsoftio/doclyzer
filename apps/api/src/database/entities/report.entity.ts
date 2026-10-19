import type {
  ProcessingState,
  ProcessingStage,
} from '../../modules/reports/processing/report-processing.contract';
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

  @Column({
    type: 'varchar',
    name: 'processing_state',
    length: 32,
    nullable: true,
  })
  processingState!: ProcessingState | null;

  @Column({ type: 'integer', name: 'processing_generation', default: 0 })
  processingGeneration!: number;

  @Column({ type: 'bigint', name: 'processing_version', default: 0 })
  processingVersion!: string;

  @Column({
    type: 'varchar',
    name: 'processing_stage',
    length: 32,
    nullable: true,
  })
  processingStage!: ProcessingStage | null;

  @Column({
    type: 'varchar',
    name: 'processing_error_code',
    length: 64,
    nullable: true,
  })
  processingErrorCode!: string | null;

  @Column({
    type: 'timestamptz',
    name: 'processing_accepted_at',
    nullable: true,
  })
  processingAcceptedAt!: Date | null;

  @Column({
    type: 'timestamptz',
    name: 'processing_started_at',
    nullable: true,
  })
  processingStartedAt!: Date | null;

  @Column({
    type: 'timestamptz',
    name: 'processing_completed_at',
    nullable: true,
  })
  processingCompletedAt!: Date | null;

  @Column({ type: 'timestamptz', name: 'processing_retry_at', nullable: true })
  processingRetryAt!: Date | null;

  @Column({ type: 'varchar', name: 'source_hash', length: 64, nullable: true })
  sourceHash!: string | null;

  @Column({ type: 'smallint', name: 'source_hash_version', nullable: true })
  sourceHashVersion!: number | null;

  @Column({ type: 'varchar', name: 'summary_status', length: 24, default: 'not_requested' })
  summaryStatus!: string;

  @Column({ type: 'timestamptz', name: 'processing_acknowledged_at', nullable: true })
  processingAcknowledgedAt!: Date | null;

  @Column({ type: 'text', nullable: true })
  summary!: string | null;

  @Column({ type: 'text', nullable: true, name: 'parsed_transcript' })
  parsedTranscript!: string | null;

  @Column({ type: 'jsonb', nullable: true, name: 'structured_report' })
  structuredReport!: Record<string, unknown> | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;

  @Column({ type: 'timestamptz', name: 'deleted_at', nullable: true })
  deletedAt!: Date | null;

  @Column({ type: 'timestamptz', name: 'purge_after_at', nullable: true })
  purgeAfterAt!: Date | null;
}
