import { BadRequestException, NotFoundException } from '@nestjs/common';

// Error codes
export const OVERRIDE_NOT_FOUND = 'ACCOUNT_OVERRIDE_NOT_FOUND' as const;
export const OVERRIDE_INVALID_EXPIRY =
  'ACCOUNT_OVERRIDE_INVALID_EXPIRY' as const;
export const OVERRIDE_INVALID_ACTIONS =
  'ACCOUNT_OVERRIDE_INVALID_ACTIONS' as const;

// Precedence rule: active override always takes precedence over a restriction
// for the specific actions listed in overriddenActions. If the restriction is
// 'suspended' but an active override covers 'upload_report', that action is
// temporarily permitted until the override expires. Emergency containment
// (Story 5.14) supersedes all overrides and must be handled separately.
export type OverrideOutcome = 'pending' | 'success' | 'reverted' | 'expired';

export interface AccountOverrideRecord {
  id: string;
  userId: string;
  overriddenActions: string[];
  expiresAt: string;
  isActive: boolean;
  reason: string | null;
  createdByUserId: string | null;
  revokedAt: string | null;
  revokedByUserId: string | null;
  revokedReason: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface AccountOverrideListResult {
  overrides: AccountOverrideRecord[];
}

export interface AccountOverrideActionResult {
  state: OverrideOutcome;
  overrideId: string;
  userId: string;
  changed: boolean;
  actedAt: string;
}

export class AccountOverrideNotFoundException extends NotFoundException {
  constructor(overrideId: string) {
    super({
      code: OVERRIDE_NOT_FOUND,
      message: `Override ${overrideId} was not found`,
    });
  }
}

export class AccountOverrideInvalidExpiryException extends BadRequestException {
  constructor(message: string) {
    super({ code: OVERRIDE_INVALID_EXPIRY, message });
  }
}

export class AccountOverrideInvalidActionsException extends BadRequestException {
  constructor(message: string) {
    super({ code: OVERRIDE_INVALID_ACTIONS, message });
  }
}
