import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('report_lab_value_corrections')
export class ReportLabValueCorrectionEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'report_id' })
  reportId!: string;

  @Column({ type: 'uuid', name: 'lab_value_id' })
  labValueId!: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @Column({ type: 'integer' })
  version!: number;

  @Column({ type: 'jsonb', name: 'previous_value' })
  previousValue!: Record<string, unknown>;

  @Column({ type: 'jsonb', name: 'corrected_value' })
  correctedValue!: Record<string, unknown>;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt!: Date;
}
