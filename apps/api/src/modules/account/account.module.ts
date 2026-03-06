import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserEntity } from '../../database/entities/user.entity';
import { AccountPreferenceEntity } from '../../database/entities/account-preference.entity';
import { RestrictionEntity } from '../../database/entities/restriction.entity';
import { DataExportRequestEntity } from '../../database/entities/data-export-request.entity';
import { ClosureRequestEntity } from '../../database/entities/closure-request.entity';
import { AuthModule } from '../auth/auth.module';
import { AccountController } from './account.controller';
import { AccountService } from './account.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      UserEntity,
      AccountPreferenceEntity,
      RestrictionEntity,
      DataExportRequestEntity,
      ClosureRequestEntity,
    ]),
    AuthModule,
  ],
  controllers: [AccountController],
  providers: [AccountService],
})
export class AccountModule {}
