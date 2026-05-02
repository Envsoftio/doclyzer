import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

import type {
  IncidentSeverity,
  IncidentStatus,
  IncidentSurface,
} from '../../../../../packages/contracts/state/incident-status';
import {
  INCIDENT_SEVERITIES,
  INCIDENT_STATUSES,
} from '../../../../../packages/contracts/state/incident-status';

@Entity('service_incidents')
export class ServiceIncidentEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({
    type: 'enum',
    enum: INCIDENT_SEVERITIES,
    enumName: 'incident_severity',
  })
  severity!: IncidentSeverity;

  @Column({
    type: 'enum',
    enum: INCIDENT_STATUSES,
    enumName: 'incident_status',
  })
  status!: IncidentStatus;

  @Column({ type: 'text' })
  headline!: string;

  @Column({ type: 'text' })
  message!: string;

  @Column({ type: 'text', name: 'whats_affected' })
  whatsAffected!: string;

  @Column({ type: 'text', array: true, name: 'affected_surfaces' })
  affectedSurfaces!: IncidentSurface[];

  @Column({ type: 'timestamptz', name: 'started_at' })
  startedAt!: Date;

  @Column({ type: 'timestamptz', nullable: true, name: 'resolved_at' })
  resolvedAt!: Date | null;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt!: Date;

  @UpdateDateColumn({ type: 'timestamptz', name: 'updated_at' })
  updatedAt!: Date;
}
