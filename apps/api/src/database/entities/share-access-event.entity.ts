import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import type { ShareLinkEntity } from './share-link.entity';

@Entity('share_access_events')
export class ShareAccessEventEntity {
  @PrimaryGeneratedColumn('uuid') id!: string;
  @Column({ type: 'uuid', name: 'share_link_id' }) shareLinkId!: string;
  @ManyToOne('ShareLinkEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'share_link_id' })
  shareLink!: ShareLinkEntity;
  @Column({ type: 'varchar', length: 32, default: 'accessed' })
  outcome!: string;
  @CreateDateColumn({ name: 'accessed_at', type: 'timestamptz' })
  accessedAt!: Date;
}
