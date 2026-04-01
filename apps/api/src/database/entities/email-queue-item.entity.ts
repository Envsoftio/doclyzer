import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

export type EmailQueueStatus = 'pending' | 'processing' | 'completed';

@Entity('email_queue_items')
export class EmailQueueItemEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 64, name: 'email_type' })
  emailType!: string;

  @Column({ type: 'varchar', length: 64, name: 'recipient_scope' })
  recipientScope!: string;

  @Column({ type: 'varchar', length: 32, name: 'status' })
  status!: EmailQueueStatus;

  @Column({ type: 'timestamptz', name: 'scheduled_at' })
  scheduledAt!: Date;

  @Column({ type: 'timestamptz', name: 'processed_at', nullable: true })
  processedAt!: Date | null;

  @Column({ type: 'jsonb', name: 'metadata', nullable: true })
  metadata!: Record<string, string | number | boolean | null> | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
