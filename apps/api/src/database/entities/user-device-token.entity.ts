import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import type { UserEntity } from './user.entity';

export type PushPlatform = 'ios' | 'android' | 'web' | 'mobile_web';
export type PushProviderName = 'fcm';

export interface PushTokenPreferences {
  billing?: boolean;
  referrals?: boolean;
  product?: boolean;
  adminAnnouncements?: boolean;
}

@Entity('user_device_tokens')
@Index('IDX_user_device_tokens_user_active', ['userId', 'active'])
@Index('UQ_user_device_tokens_token_hash', ['tokenHash'], { unique: true })
export class UserDeviceTokenEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: UserEntity;

  @Column({ type: 'varchar', length: 64, name: 'token_hash' })
  tokenHash!: string;

  @Column({ type: 'text', name: 'provider_token' })
  providerToken!: string;

  @Column({ type: 'varchar', length: 24 })
  platform!: PushPlatform;

  @Column({ type: 'varchar', length: 32, default: 'fcm' })
  provider!: PushProviderName;

  @Column({
    type: 'varchar',
    length: 128,
    name: 'installation_id',
    nullable: true,
  })
  installationId!: string | null;

  @Column({
    type: 'varchar',
    length: 64,
    name: 'app_version',
    nullable: true,
  })
  appVersion!: string | null;

  @Column({
    type: 'varchar',
    length: 128,
    name: 'device_label',
    nullable: true,
  })
  deviceLabel!: string | null;

  @Column({ type: 'jsonb', nullable: true })
  preferences!: PushTokenPreferences | null;

  @Column({ type: 'boolean', default: true })
  active!: boolean;

  @Column({ type: 'timestamptz', name: 'last_seen_at' })
  lastSeenAt!: Date;

  @Column({ type: 'timestamptz', name: 'disabled_at', nullable: true })
  disabledAt!: Date | null;

  @Column({ type: 'jsonb', nullable: true })
  metadata!: Record<string, string | number | boolean | null> | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
