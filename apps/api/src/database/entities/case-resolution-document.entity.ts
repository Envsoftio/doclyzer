import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import type { UserEntity } from './user.entity';

// Stores closure documentation for a restricted account case.
// Records are immutable after creation — resolved cases version-link prior closures.
@Entity('case_resolution_documents')
export class CaseResolutionDocumentEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  // The account (user) this resolution belongs to
  @Column({ type: 'uuid', name: 'target_user_id' })
  targetUserId!: string;

  @ManyToOne('UserEntity', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'target_user_id' })
  targetUser!: UserEntity;

  // Superadmin who submitted this resolution document
  @Column({ type: 'uuid', name: 'author_user_id', nullable: true })
  authorUserId!: string | null;

  @ManyToOne('UserEntity', { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'author_user_id' })
  authorUser!: UserEntity | null;

  // Required closure fields
  @Column({ type: 'text' })
  summary!: string;

  @Column({ type: 'text', name: 'root_cause' })
  rootCause!: string;

  @Column({ type: 'text', name: 'user_impact' })
  userImpact!: string;

  @Column({ type: 'text', name: 'actions_taken' })
  actionsTaken!: string;

  // Outcome of the resolution: closed | reopened | escalated
  @Column({ type: 'varchar', length: 32 })
  outcome!: string;

  // Optional audit correlation ID linking to the superadmin action audit event
  @Column({
    type: 'varchar',
    length: 128,
    name: 'audit_correlation_id',
    nullable: true,
  })
  auditCorrelationId!: string | null;

  // Version chain: if this is a re-closure after re-investigation, links to prior doc
  @Column({ type: 'uuid', name: 'prior_document_id', nullable: true })
  priorDocumentId!: string | null;

  // Version number within this case (1 for first closure, increments on each re-closure)
  @Column({ type: 'integer', name: 'version', default: 1 })
  version!: number;

  @CreateDateColumn({ type: 'timestamptz', name: 'created_at' })
  createdAt!: Date;
}
