import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import type {
  AnalyticsFieldClassification,
  AnalyticsGovernanceReviewStatus,
} from '../../modules/analytics-admin/analytics-governance.types';

@Entity('analytics_governance_reviews')
@Index('IDX_analytics_governance_reviews_event_field', [
  'eventName',
  'fieldName',
])
@Index('IDX_analytics_governance_reviews_event', ['eventName'])
export class AnalyticsGovernanceReviewEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ name: 'event_name', type: 'varchar', length: 128 })
  eventName!: string;

  @Column({ name: 'field_name', type: 'varchar', length: 128 })
  fieldName!: string;

  @Column({ name: 'classification', type: 'varchar', length: 32 })
  classification!: AnalyticsFieldClassification;

  @Column({ name: 'status', type: 'varchar', length: 32, default: 'pending' })
  status!: AnalyticsGovernanceReviewStatus;

  @Column({ name: 'details', type: 'text', nullable: true })
  details!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
