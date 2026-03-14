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

  @Column({ type: 'varchar', name: 'value', length: 512 })
  value!: string;

  @Column({ type: 'varchar', name: 'unit', length: 64, nullable: true })
  unit!: string | null;

  @Column({ type: 'date', name: 'sample_date', nullable: true })
  sampleDate!: string | null;

  @Column({ type: 'integer', name: 'sort_order', default: 0 })
  sortOrder!: number;
}
