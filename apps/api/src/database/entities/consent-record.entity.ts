import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import type { UserEntity } from './user.entity';

@Entity('consent_records')
export class ConsentRecordEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: UserEntity;

  @Column({ type: 'varchar', length: 32, name: 'policy_type', nullable: true })
  policyType!: string | null;

  @Column({ type: 'varchar', length: 64, name: 'policy_version' })
  policyVersion!: string;

  @Column({ type: 'timestamptz', name: 'accepted_at' })
  acceptedAt!: Date;
}
