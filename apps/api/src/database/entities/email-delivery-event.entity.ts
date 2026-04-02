import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
} from 'typeorm';

export type EmailDeliveryOutcome = 'pending' | 'sent' | 'failed' | 'bounced';

@Entity('email_delivery_events')
export class EmailDeliveryEventEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 64, name: 'email_type' })
  emailType!: string;

  @Column({ type: 'varchar', length: 64, name: 'recipient_scope' })
  recipientScope!: string;

  @Column({ type: 'varchar', length: 32, name: 'outcome' })
  outcome!: EmailDeliveryOutcome;

  @Column({ type: 'varchar', length: 64, name: 'provider', nullable: true })
  provider!: string | null;

  @Column({
    type: 'varchar',
    length: 128,
    name: 'provider_message_id',
    nullable: true,
  })
  providerMessageId!: string | null;

  @Column({ type: 'timestamptz', name: 'occurred_at' })
  occurredAt!: Date;

  @Column({ type: 'jsonb', name: 'metadata', nullable: true })
  metadata!: Record<string, string | number | boolean | null> | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;
}
