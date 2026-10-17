import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('report_result_insight_usage')
export class ReportResultInsightUsageEntity {
  @PrimaryGeneratedColumn('uuid') id!: string;
  @Column({ type: 'uuid', name: 'user_id' }) userId!: string;
  @Column({ type: 'uuid', name: 'report_id' }) reportId!: string;
  @Column({ type: 'varchar', length: 64, name: 'cache_key' }) cacheKey!: string;
  @Column({ type: 'varchar', length: 128 }) model!: string;
  @Column({ type: 'integer', name: 'input_tokens', default: 0 }) inputTokens!: number;
  @Column({ type: 'integer', name: 'output_tokens', default: 0 }) outputTokens!: number;
  @Column({ type: 'integer', name: 'total_tokens', default: 0 }) totalTokens!: number;
  @Column({ type: 'numeric', precision: 12, scale: 8, name: 'estimated_cost_usd', default: 0 }) estimatedCostUsd!: string;
  @Column({ type: 'boolean', name: 'cache_hit', default: false }) cacheHit!: boolean;
  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' }) createdAt!: Date;
}
