export const ENTITLEMENT_NOT_FOUND = 'ENTITLEMENT_NOT_FOUND';
export const PLAN_CONFIG_NOT_FOUND = 'PLAN_CONFIG_NOT_FOUND';
export const PLAN_CONFIG_INVALID_LIMITS = 'PLAN_CONFIG_INVALID_LIMITS';
export const PLAN_CONFIG_VERSION_CONFLICT = 'PLAN_CONFIG_VERSION_CONFLICT';

export type PlanTier = 'free' | 'paid';

export type EntitlementStatus = 'active' | 'expired' | 'cancelled';

export interface EntitlementSummaryDto {
  planName: string;
  tier: PlanTier;
  creditBalance: number;
  status: EntitlementStatus;
  limits: {
    maxProfiles: number;
    maxReports: number;
    maxShareLinks: number;
    aiChatEnabled: boolean;
  };
  activatedAt: string;
  expiresAt: string | null;
}

export interface PlanConfigSummaryDto {
  planId: string;
  planName: string;
  tier: PlanTier;
  isActive: boolean;
  configVersion: number;
  limits: {
    maxProfilesPerPlan: number;
    reportCap: number;
    shareLinkLimit: number;
    aiChatEnabled: boolean;
  };
  updatedAt: string;
}

export interface PlanConfigRecalculationDto {
  mode: 'deterministic_non_destructive';
  backwardCompatible: boolean;
  previousConfigVersion: number;
  newConfigVersion: number;
  impact: {
    activeEntitlementsUnaffected: boolean;
    enforcementOnNewOperationsOnly: boolean;
  };
}
