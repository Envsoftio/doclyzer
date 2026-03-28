import { NotFoundException } from '@nestjs/common';
import { PLAN_CONFIG_NOT_FOUND } from '../entitlements.types';

export class PlanConfigNotFoundException extends NotFoundException {
  constructor(planId: string) {
    super({
      code: PLAN_CONFIG_NOT_FOUND,
      message: `Plan configuration not found for id: ${planId}`,
    });
  }
}
