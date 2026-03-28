import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CreditPackEntity } from '../../database/entities/credit-pack.entity';
import { OrderEntity } from '../../database/entities/order.entity';
import { PromoCodeEntity } from '../../database/entities/promo-code.entity';
import { PromoRedemptionEntity } from '../../database/entities/promo-redemption.entity';
import { SubscriptionEntity } from '../../database/entities/subscription.entity';
import { AuthModule } from '../auth/auth.module';
import { EntitlementsModule } from '../entitlements/entitlements.module';
import { BillingController } from './billing.controller';
import { BillingService } from './billing.service';
import { RazorpayService } from './razorpay.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      CreditPackEntity,
      OrderEntity,
      PromoCodeEntity,
      PromoRedemptionEntity,
      SubscriptionEntity,
    ]),
    AuthModule,
    EntitlementsModule,
  ],
  controllers: [BillingController],
  providers: [BillingService, RazorpayService],
})
export class BillingModule {}
