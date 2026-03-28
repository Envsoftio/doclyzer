import { join } from 'path';
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { razorpayConfig } from './config/razorpay.config';
import { reportsConfig } from './config/reports.config';
import { storageConfig } from './config/storage.config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DataType, newDb } from 'pg-mem';
import { DataSource, type DataSourceOptions } from 'typeorm';
import { AccountPreferenceEntity } from './database/entities/account-preference.entity';
import { ClosureRequestEntity } from './database/entities/closure-request.entity';
import { ConsentRecordEntity } from './database/entities/consent-record.entity';
import { DataExportRequestEntity } from './database/entities/data-export-request.entity';
import { PasswordResetTokenEntity } from './database/entities/password-reset-token.entity';
import { ProfileEntity } from './database/entities/profile.entity';
import { ReportEntity } from './database/entities/report.entity';
import { RestrictionEntity } from './database/entities/restriction.entity';
import { ShareLinkEntity } from './database/entities/share-link.entity';
import { UserSharePolicyEntity } from './database/entities/user-share-policy.entity';
import { CreditPackEntity } from './database/entities/credit-pack.entity';
import { OrderEntity } from './database/entities/order.entity';
import { PlanEntity } from './database/entities/plan.entity';
import { SubscriptionEntity } from './database/entities/subscription.entity';
import { UserEntitlementEntity } from './database/entities/user-entitlement.entity';
import { SessionEntity } from './database/entities/session.entity';
import { UserEntity } from './database/entities/user.entity';
import { migrations } from './database/migrations';
import { AccountModule } from './modules/account/account.module';
import { AuthModule } from './modules/auth/auth.module';
import { BillingModule } from './modules/billing/billing.module';
import { ConsentModule } from './modules/consent/consent.module';
import { EntitlementsModule } from './modules/entitlements/entitlements.module';
import { ProfilesModule } from './modules/profiles/profiles.module';
import { ReportsModule } from './modules/reports/reports.module';
import { SharingModule } from './modules/sharing/sharing.module';
import { randomUUID } from 'node:crypto';

const typeOrmEntities = [
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
  ShareLinkEntity,
  UserSharePolicyEntity,
  PlanEntity,
  UserEntitlementEntity,
  CreditPackEntity,
  OrderEntity,
  SubscriptionEntity,
];

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: [join(__dirname, '../../../.env'), '.env'],
      load: [storageConfig, reportsConfig, razorpayConfig],
    }),
    TypeOrmModule.forRootAsync({
      useFactory: (config: ConfigService) => {
        const isTest =
          config.get<string>('NODE_ENV') === 'test' ||
          config.get<string>('JEST_WORKER_ID') !== undefined;
        const dbUrl = config.get<string>('DATABASE_URL');
        const e2eRealDb = Boolean(dbUrl?.includes('doclyzer_test'));
        const usePgMem = isTest && !e2eRealDb;
        return {
          type: 'postgres',
          ...(usePgMem
            ? {}
            : { url: dbUrl ?? config.getOrThrow<string>('DATABASE_URL') }),
          entities: typeOrmEntities,
          autoLoadEntities: true,
          synchronize: usePgMem,
          retryAttempts: usePgMem ? 0 : undefined,
          migrationsRun:
            !usePgMem &&
            config.get<string>('NODE_ENV', 'development') === 'development',
          migrations,
          logging: config.get<string>('NODE_ENV') === 'development',
          extra: { usePgMem },
        };
      },
      inject: [ConfigService],
      dataSourceFactory: async (options) => {
        if (!options) throw new Error('TypeORM options were not provided');
        const isTest =
          options.type === 'postgres' &&
          Boolean(
            (options as { extra?: { usePgMem?: boolean } }).extra?.usePgMem,
          );
        if (!isTest) {
          return new DataSource(options).initialize();
        }

        const db = newDb({ autoCreateForeignKeyIndices: true });
        db.public.registerFunction({
          name: 'uuid_generate_v4',
          args: [],
          returns: DataType.uuid,
          implementation: randomUUID,
          impure: true,
        });
        db.public.registerFunction({
          name: 'now',
          args: [],
          returns: DataType.timestamptz,
          implementation: () => new Date(),
          impure: true,
        });
        db.public.registerFunction({
          name: 'version',
          args: [],
          returns: DataType.text,
          implementation: () => 'PostgreSQL 16.0 (pg-mem)',
        });
        db.public.registerFunction({
          name: 'current_database',
          args: [],
          returns: DataType.text,
          implementation: () => 'doclyzer_test',
        });
        db.public.registerFunction({
          name: 'current_schema',
          args: [],
          returns: DataType.text,
          implementation: () => 'public',
        });

        const dataSource = (await db.adapters.createTypeormDataSource({
          ...(options as unknown as DataSourceOptions),
          // Never run migrations in pg-mem: our migrations include CREATE EXTENSION.
          synchronize: true,
          migrationsRun: false,
          logging: ['error'],
        })) as DataSource;
        return dataSource.initialize();
      },
    }),
    AuthModule,
    BillingModule,
    ConsentModule,
    AccountModule,
    EntitlementsModule,
    ProfilesModule,
    ReportsModule,
    SharingModule,
  ],
})
export class AppModule {}
