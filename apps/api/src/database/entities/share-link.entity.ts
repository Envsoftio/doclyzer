import { Column, CreateDateColumn, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';
import type { ProfileEntity } from './profile.entity';
import type { UserEntity } from './user.entity';

@Entity('share_links')
export class ShareLinkEntity {
  @PrimaryGeneratedColumn('uuid') id!: string;
  @Column({ type: 'uuid', name: 'user_id' }) userId!: string;
  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' }) user!: UserEntity;
  @Column({ type: 'uuid', name: 'profile_id' }) profileId!: string;
  @ManyToOne('ProfileEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'profile_id' }) profile!: ProfileEntity;
  @Column({ type: 'varchar', length: 64, unique: true }) token!: string;
  @Column({ type: 'varchar', length: 32, default: 'all' }) scope!: string;
  @Column({ type: 'boolean', name: 'is_active', default: true }) isActive!: boolean;
  @Column({ type: 'timestamptz', name: 'expires_at', nullable: true }) expiresAt!: Date | null;
  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' }) createdAt!: Date;
  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' }) updatedAt!: Date;
}
