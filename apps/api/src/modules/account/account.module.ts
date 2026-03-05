import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { AuthGuard } from '../../common/guards/auth.guard';
import { AccountController } from './account.controller';
import { AccountService } from './account.service';

@Module({
  imports: [AuthModule],
  controllers: [AccountController],
  providers: [AccountService, AuthGuard],
})
export class AccountModule {}
