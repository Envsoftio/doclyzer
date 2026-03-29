import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import type { AnalyticsFieldClassification } from '../../modules/analytics-admin/analytics-governance.types';

@Entity('analytics_taxonomy_fields')
@Index('IDX_analytics_taxonomy_event_field', ['eventName', 'fieldName'], {
  unique: true,
})
@Index('IDX_analytics_taxonomy_event', ['eventName'])
export class AnalyticsTaxonomyFieldEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ name: 'event_name', type: 'varchar', length: 128 })
  eventName!: string;

  @Column({ name: 'field_name', type: 'varchar', length: 128 })
  fieldName!: string;

  @Column({ name: 'classification', type: 'varchar', length: 32 })
  classification!: AnalyticsFieldClassification;

  @Column({ name: 'allow_list', type: 'boolean', default: false })
  allowList!: boolean;

  @Column({ name: 'notes', type: 'text', nullable: true })
  notes!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
