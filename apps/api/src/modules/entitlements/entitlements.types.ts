export const ENTITLEMENT_NOT_FOUND = 'ENTITLEMENT_NOT_FOUND';

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
