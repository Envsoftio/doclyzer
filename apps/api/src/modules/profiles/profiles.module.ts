import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { EntitlementsModule } from '../entitlements/entitlements.module';
import { AuthGuard } from '../../common/guards/auth.guard';
import { ProfilesController } from './profiles.controller';
import { ProfilesService } from './profiles.service';

@Module({
  imports: [AuthModule, EntitlementsModule],
  controllers: [ProfilesController],
  providers: [ProfilesService, AuthGuard],
})
export class ProfilesModule {}
