import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import type { UserEntity } from './user.entity';

@Entity('superadmin_mfa_challenges')
export class SuperadminMfaChallengeEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: UserEntity;

  @Column({ type: 'varchar', length: 128, name: 'session_id' })
  sessionId!: string;

  @Column({ type: 'varchar', length: 32, name: 'status' })
  status!: 'pending' | 'success' | 'failure' | 'reverted';

  @Column({ type: 'varchar', length: 160, name: 'risk_fingerprint' })
  riskFingerprint!: string;

  @Column({ type: 'int', name: 'attempt_count', default: 0 })
  attemptCount!: number;

  @Column({ type: 'int', name: 'max_attempts', default: 5 })
  maxAttempts!: number;

  @Column({ type: 'timestamptz', name: 'locked_until', nullable: true })
  lockedUntil!: Date | null;

  @Column({
    type: 'varchar',
    length: 64,
    name: 'last_failure_code',
    nullable: true,
  })
  lastFailureCode!: string | null;

  @Column({
    type: 'varchar',
    length: 255,
    name: 'admin_action_token',
    nullable: true,
  })
  adminActionToken!: string | null;

  @Column({ type: 'timestamptz', name: 'expires_at' })
  expiresAt!: Date;

  @Column({ type: 'timestamptz', name: 'verified_at', nullable: true })
  verifiedAt!: Date | null;

  @Column({ type: 'timestamptz', name: 'trust_expires_at', nullable: true })
  trustExpiresAt!: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
