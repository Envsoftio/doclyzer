import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PlanEntity } from '../../database/entities/plan.entity';
import { UserEntitlementEntity } from '../../database/entities/user-entitlement.entity';
import { EntitlementsController } from './entitlements.controller';
import { EntitlementsService } from './entitlements.service';

@Module({
  imports: [TypeOrmModule.forFeature([PlanEntity, UserEntitlementEntity])],
  controllers: [EntitlementsController],
  providers: [EntitlementsService],
  exports: [EntitlementsService],
})
export class EntitlementsModule {}
