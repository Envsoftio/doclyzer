import { config } from 'dotenv';
import { join } from 'path';
import { DataSource } from 'typeorm';

// Load .env when running TypeORM CLI (migrations); Nest loads it via ConfigModule
config({ path: join(__dirname, '../../../../.env') });
import { AccountPreferenceEntity } from './entities/account-preference.entity';
import { ClosureRequestEntity } from './entities/closure-request.entity';
import { ConsentRecordEntity } from './entities/consent-record.entity';
import { DataExportRequestEntity } from './entities/data-export-request.entity';
import { PasswordResetTokenEntity } from './entities/password-reset-token.entity';
import { ProfileEntity } from './entities/profile.entity';
import { ReportEntity } from './entities/report.entity';
import { RestrictionEntity } from './entities/restriction.entity';
import { SessionEntity } from './entities/session.entity';
import { UserEntity } from './entities/user.entity';
import { migrations } from './migrations';

/**
 * Standalone DataSource for TypeORM CLI (migration:generate, migration:run, migration:revert).
 * NestJS DI is unavailable in CLI context — reads process.env directly.
 */
export const AppDataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  entities: [
    UserEntity,
    SessionEntity,
    ProfileEntity,
    AccountPreferenceEntity,
    RestrictionEntity,
    DataExportRequestEntity,
    ClosureRequestEntity,
    PasswordResetTokenEntity,
    ConsentRecordEntity,
    ReportEntity,
  ],
  migrations,
  synchronize: false,
  logging: process.env.NODE_ENV === 'development',
});
