import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

/**
 * Stub service for plan/entitlement limits.
 * Returns free-tier limits until Epic 4 wires real plan data from billing.
 * E2E tests set E2E_MAX_PROFILES=2 to test multi-profile flows.
 */
@Injectable()
export class EntitlementsService {
  constructor(private readonly configService: ConfigService) {}

  /**
   * Returns max profiles allowed for the user's plan.
   * Free tier: 1. Paid tier: multiple (configurable in Epic 5.2).
   */
  getMaxProfiles(_userId: string): number {
    const e2eOverride = this.configService.get<string>('E2E_MAX_PROFILES');
    if (!e2eOverride) return 1;
    const n = parseInt(e2eOverride, 10);
    return Number.isNaN(n) ? 1 : n;
  }
}
