import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryColumn,
} from 'typeorm';
import type { ReportEntity } from './report.entity';

@Entity('report_result_insights')
export class ReportResultInsightEntity {
  @PrimaryColumn({ type: 'uuid', name: 'report_id' })
  reportId!: string;

  @ManyToOne('ReportEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'report_id' })
  report!: ReportEntity;

  @PrimaryColumn({ type: 'varchar', name: 'cache_key', length: 64 })
  cacheKey!: string;

  @Column({ type: 'jsonb', name: 'insight' })
  insight!: Record<string, unknown>;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt!: Date;
}
