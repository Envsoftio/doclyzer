import { BadRequestException } from '@nestjs/common';
import { PLAN_CONFIG_INVALID_LIMITS } from '../entitlements.types';

export class PlanConfigValidationException extends BadRequestException {
  constructor(message: string) {
    super({
      code: PLAN_CONFIG_INVALID_LIMITS,
      message,
    });
  }
}
