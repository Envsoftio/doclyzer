import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConsentRecordEntity } from '../../database/entities/consent-record.entity';
import { AuthModule } from '../auth/auth.module';
import { AuthGuard } from '../../common/guards/auth.guard';
import { ConsentController } from './consent.controller';
import { ConsentService } from './consent.service';

@Module({
  imports: [TypeOrmModule.forFeature([ConsentRecordEntity]), AuthModule],
  controllers: [ConsentController],
  providers: [ConsentService, AuthGuard],
})
export class ConsentModule {}
