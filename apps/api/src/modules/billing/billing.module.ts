import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CreditPackEntity } from '../../database/entities/credit-pack.entity';
import { OrderEntity } from '../../database/entities/order.entity';
import { SubscriptionEntity } from '../../database/entities/subscription.entity';
import { EntitlementsModule } from '../entitlements/entitlements.module';
import { BillingController } from './billing.controller';
import { BillingService } from './billing.service';
import { RazorpayService } from './razorpay.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([CreditPackEntity, OrderEntity, SubscriptionEntity]),
    EntitlementsModule,
  ],
  controllers: [BillingController],
  providers: [BillingService, RazorpayService],
})
export class BillingModule {}
