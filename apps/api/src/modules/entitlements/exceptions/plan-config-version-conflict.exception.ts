import { ConflictException } from '@nestjs/common';
import { PLAN_CONFIG_VERSION_CONFLICT } from '../entitlements.types';

export class PlanConfigVersionConflictException extends ConflictException {
  constructor(expected: number, actual: number) {
    super({
      code: PLAN_CONFIG_VERSION_CONFLICT,
      message: `Plan configuration update conflict. Expected version ${expected}, found ${actual}.`,
    });
  }
}
