import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { AuthGuard } from '../../common/guards/auth.guard';
import { ConsentController } from './consent.controller';
import { ConsentService } from './consent.service';

@Module({
  imports: [AuthModule],
  controllers: [ConsentController],
  providers: [ConsentService, AuthGuard],
})
export class ConsentModule {}
