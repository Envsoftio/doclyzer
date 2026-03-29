import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import type { UserEntity } from './user.entity';

@Entity('restrictions')
export class RestrictionEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'uuid', name: 'user_id', unique: true })
  userId!: string;

  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: UserEntity;

  @Column({ type: 'boolean', name: 'is_restricted' })
  isRestricted!: boolean;

  @Column({
    type: 'boolean',
    name: 'restricted_review_mode',
    default: false,
  })
  restrictedReviewMode!: boolean;

  @Column({ type: 'timestamptz', name: 'restricted_until', nullable: true })
  restrictedUntil!: Date | null;

  @Column({ type: 'text', nullable: true })
  rationale!: string | null;

  @Column({ type: 'text', name: 'next_steps', nullable: true })
  nextSteps!: string | null;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
