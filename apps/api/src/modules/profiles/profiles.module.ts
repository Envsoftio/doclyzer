import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProfileEntity } from '../../database/entities/profile.entity';
import { AuthModule } from '../auth/auth.module';
import { EntitlementsModule } from '../entitlements/entitlements.module';
import { ProfilesController } from './profiles.controller';
import { ProfilesService } from './profiles.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([ProfileEntity]),
    AuthModule,
    EntitlementsModule,
  ],
  controllers: [ProfilesController],
  providers: [ProfilesService],
  exports: [ProfilesService],
})
export class ProfilesModule {}
