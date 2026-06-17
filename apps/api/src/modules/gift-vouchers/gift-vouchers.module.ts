import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { GiftVoucherEntity } from '../../database/entities/gift-voucher.entity';
import { GiftVoucherEventEntity } from '../../database/entities/gift-voucher-event.entity';
import { AuthModule } from '../auth/auth.module';
import { EntitlementsModule } from '../entitlements/entitlements.module';
import { GiftVouchersController } from './gift-vouchers.controller';
import { GiftVouchersService } from './gift-vouchers.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([GiftVoucherEntity, GiftVoucherEventEntity]),
    AuthModule,
    EntitlementsModule,
  ],
  controllers: [GiftVouchersController],
  providers: [GiftVouchersService],
})
export class GiftVouchersModule {}
