import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import type { ReportEntity } from './report.entity';

@Entity('report_lab_values')
export class ReportLabValueEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'report_id' })
  reportId!: string;

  @ManyToOne('ReportEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'report_id' })
  report!: ReportEntity;

  @Column({ type: 'varchar', name: 'parameter_name', length: 256 })
  parameterName!: string;

  @Column({ type: 'varchar', name: 'original_parameter_name', length: 256 })
  originalParameterName!: string;

  @Column({ type: 'varchar', name: 'canonical_test_id', length: 64, nullable: true })
  canonicalTestId!: string | null;

  @Column({ type: 'varchar', name: 'value', length: 512 })
  value!: string;

  @Column({ type: 'varchar', name: 'raw_result', length: 512 })
  rawResult!: string;

  @Column({ type: 'numeric', name: 'parsed_numeric_value', nullable: true })
  parsedNumericValue!: string | null;

  @Column({ type: 'numeric', name: 'normalized_numeric_value', nullable: true })
  normalizedNumericValue!: string | null;

  @Column({ type: 'varchar', name: 'comparison_qualifier', length: 16, nullable: true })
  comparisonQualifier!: string | null;

  @Column({ type: 'varchar', name: 'result_kind', length: 16 })
  resultKind!: string;

  @Column({ type: 'varchar', name: 'unit', length: 64, nullable: true })
  unit!: string | null;

  @Column({ type: 'varchar', name: 'original_unit', length: 64, nullable: true })
  originalUnit!: string | null;

  @Column({ type: 'varchar', name: 'normalized_unit', length: 64, nullable: true })
  normalizedUnit!: string | null;

  @Column({ type: 'date', name: 'sample_date', nullable: true })
  sampleDate!: string | null;

  @Column({ type: 'date', name: 'original_sample_date', nullable: true })
  originalSampleDate!: string | null;

  @Column({ type: 'varchar', name: 'collection_date_source', length: 24 })
  collectionDateSource!: string;

  @Column({ type: 'varchar', name: 'extraction_source', length: 32 })
  extractionSource!: string;

  @Column({ type: 'varchar', name: 'review_state', length: 24 })
  reviewState!: string;

  @Column({ type: 'varchar', name: 'reference_range', length: 256, nullable: true })
  referenceRange!: string | null;

  @Column({ type: 'integer', name: 'review_version', default: 0 })
  reviewVersion!: number;

  @Column({ type: 'jsonb', name: 'source_snapshot', nullable: true })
  sourceSnapshot!: Record<string, unknown> | null;

  @Column({ type: 'jsonb', name: 'identity_evidence', nullable: true })
  identityEvidence!: Record<string, string> | null;

  @Column({ type: 'integer', name: 'sort_order', default: 0 })
  sortOrder!: number;
}
