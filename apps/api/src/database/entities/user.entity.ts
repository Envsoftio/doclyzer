import {
  Column,
  CreateDateColumn,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import type { AccountPreferenceEntity } from './account-preference.entity';
import type { ClosureRequestEntity } from './closure-request.entity';
import type { ConsentRecordEntity } from './consent-record.entity';
import type { DataExportRequestEntity } from './data-export-request.entity';
import type { PasswordResetTokenEntity } from './password-reset-token.entity';
import type { ProfileEntity } from './profile.entity';
import type { RestrictionEntity } from './restriction.entity';
import type { SessionEntity } from './session.entity';

@Entity('users')
export class UserEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ type: 'varchar', length: 255, unique: true })
  email!: string;

  @Column({ type: 'varchar', length: 255, name: 'password_hash' })
  passwordHash!: string;

  @Column({ type: 'varchar', length: 255, name: 'display_name', nullable: true })
  displayName!: string | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;

  // Relations: no cascade; service layer manages persistence
  @OneToMany('SessionEntity', 'user')
  sessions?: SessionEntity[];

  @OneToMany('ProfileEntity', 'user')
  profiles?: ProfileEntity[];

  @OneToMany('AccountPreferenceEntity', 'user')
  accountPreference?: AccountPreferenceEntity[];

  @OneToMany('RestrictionEntity', 'user')
  restriction?: RestrictionEntity[];

  @OneToMany('DataExportRequestEntity', 'user')
  dataExportRequests?: DataExportRequestEntity[];

  @OneToMany('ClosureRequestEntity', 'user')
  closureRequests?: ClosureRequestEntity[];

  @OneToMany('PasswordResetTokenEntity', 'user')
  passwordResetTokens?: PasswordResetTokenEntity[];

  @OneToMany('ConsentRecordEntity', 'user')
  consentRecords?: ConsentRecordEntity[];
}
