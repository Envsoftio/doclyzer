import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryColumn,
} from 'typeorm';
import type { UserEntity } from './user.entity';

@Entity('notification_reads')
@Index('IDX_notification_reads_user', ['userId'])
export class NotificationReadEntity {
  @PrimaryColumn({ type: 'uuid', name: 'user_id' })
  userId!: string;

  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: UserEntity;

  @PrimaryColumn({ type: 'varchar', length: 16, name: 'source_type' })
  sourceType!: string;

  @PrimaryColumn({ type: 'uuid', name: 'source_id' })
  sourceId!: string;

  @Column({ type: 'timestamptz', name: 'read_at' })
  readAt!: Date;
}
