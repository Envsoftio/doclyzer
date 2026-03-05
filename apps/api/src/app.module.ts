import { Module } from '@nestjs/common';
import { AccountModule } from './modules/account/account.module';
import { AuthModule } from './modules/auth/auth.module';
import { ConsentModule } from './modules/consent/consent.module';

@Module({
  imports: [AuthModule, AccountModule, ConsentModule],
})
export class AppModule {}
