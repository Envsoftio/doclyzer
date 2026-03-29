import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('suspicious_activity_queue_items')
export class SuspiciousActivityQueueItemEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 64, name: 'target_type' })
  targetType!: string;

  @Column({ type: 'varchar', length: 128, name: 'target_id' })
  targetId!: string;

  @Column({ type: 'varchar', length: 64, name: 'signal_type' })
  signalType!: string;

  @Column({ type: 'varchar', length: 64, name: 'rule_code' })
  ruleCode!: string;

  @Column({ type: 'varchar', length: 16 })
  severity!: 'low' | 'medium' | 'high' | 'critical';

  @Column({ type: 'varchar', length: 16 })
  status!: 'open' | 'in_review' | 'resolved';

  @Column({ type: 'integer', name: 'confidence_score' })
  confidenceScore!: number;

  @Column({
    type: 'varchar',
    length: 256,
    name: 'detection_summary',
    nullable: true,
  })
  detectionSummary!: string | null;

  @Column({ type: 'integer', name: 'detection_count', default: 1 })
  detectionCount!: number;

  @Column({ type: 'timestamptz', name: 'first_detected_at' })
  firstDetectedAt!: Date;

  @Column({ type: 'timestamptz', name: 'last_detected_at' })
  lastDetectedAt!: Date;

  @Column({ type: 'jsonb', name: 'suggested_containment', nullable: true })
  suggestedContainment!: Record<string, string | number | boolean> | null;

  @Column({ type: 'varchar', length: 128, name: 'dedupe_key' })
  dedupeKey!: string;

  @Column({
    type: 'varchar',
    length: 128,
    name: 'idempotency_key',
    nullable: true,
  })
  idempotencyKey!: string | null;

  @Column({ type: 'jsonb', nullable: true })
  metadata!: Record<string, string | number | boolean | null> | null;

  @Column({ type: 'timestamptz', name: 'reviewed_at', nullable: true })
  reviewedAt!: Date | null;

  @Column({ type: 'timestamptz', name: 'resolved_at', nullable: true })
  resolvedAt!: Date | null;

  @Column({
    type: 'varchar',
    length: 256,
    name: 'resolution_notes',
    nullable: true,
  })
  resolutionNotes!: string | null;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt!: Date;
}
