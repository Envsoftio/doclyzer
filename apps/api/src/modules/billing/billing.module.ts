import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CreditPackEntity } from '../../database/entities/credit-pack.entity';
import { OrderEntity } from '../../database/entities/order.entity';
import { PromoCodeEntity } from '../../database/entities/promo-code.entity';
import { PromoCodeAuditEventEntity } from '../../database/entities/promo-code-audit-event.entity';
import { PromoRedemptionEntity } from '../../database/entities/promo-redemption.entity';
import { SubscriptionEntity } from '../../database/entities/subscription.entity';
import { SuperadminAuthAuditEventEntity } from '../../database/entities/superadmin-auth-audit-event.entity';
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
      PromoCodeAuditEventEntity,
      PromoRedemptionEntity,
      SubscriptionEntity,
      SuperadminAuthAuditEventEntity,
    ]),
    AuthModule,
    EntitlementsModule,
  ],
  controllers: [BillingController],
  providers: [BillingService, RazorpayService],
})
export class BillingModule {}
