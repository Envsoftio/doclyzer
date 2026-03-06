import { join } from 'path';
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AccountPreferenceEntity } from './database/entities/account-preference.entity';
import { ClosureRequestEntity } from './database/entities/closure-request.entity';
import { ConsentRecordEntity } from './database/entities/consent-record.entity';
import { DataExportRequestEntity } from './database/entities/data-export-request.entity';
import { PasswordResetTokenEntity } from './database/entities/password-reset-token.entity';
import { ProfileEntity } from './database/entities/profile.entity';
import { RestrictionEntity } from './database/entities/restriction.entity';
import { SessionEntity } from './database/entities/session.entity';
import { UserEntity } from './database/entities/user.entity';
import { migrations } from './database/migrations';
import { AccountModule } from './modules/account/account.module';
import { AuthModule } from './modules/auth/auth.module';
import { EntitlementsModule } from './modules/entitlements/entitlements.module';
import { ProfilesModule } from './modules/profiles/profiles.module';

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
];

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: [join(__dirname, '../../../.env'), '.env'],
    }),
    TypeOrmModule.forRootAsync({
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        url: config.getOrThrow<string>('DATABASE_URL'),
        entities: typeOrmEntities,
        autoLoadEntities: true,
        synchronize: false,
        migrationsRun: ['development', 'test'].includes(
          config.get<string>('NODE_ENV', 'development'),
        ),
        migrations,
        logging: config.get<string>('NODE_ENV') === 'development',
      }),
      inject: [ConfigService],
    }),
    AuthModule,
    AccountModule,
    EntitlementsModule,
    ProfilesModule,
  ],
})
export class AppModule {}
