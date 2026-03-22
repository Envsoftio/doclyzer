import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import type { ReportEntity } from './report.entity';

export type AttemptTrigger = 'initial_upload' | 'retry';

@Entity('report_processing_attempts')
export class ReportProcessingAttemptEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'report_id' })
  reportId!: string;

  @ManyToOne('ReportEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'report_id' })
  report!: ReportEntity;

  @Column({ type: 'varchar', length: 32 })
  trigger!: AttemptTrigger;

  @Column({ type: 'varchar', length: 32 })
  outcome!: string;

  @Column({ type: 'timestamptz', name: 'attempted_at' })
  attemptedAt!: Date;
}
