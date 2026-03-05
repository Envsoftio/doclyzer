export type PolicyType = 'terms' | 'privacy';

export interface PolicyDefinition {
  type: PolicyType;
  version: string;
  title: string;
  url: string;
}

export interface PolicyAcceptanceRecord {
  userId: string;
  policyType: PolicyType;
  version: string;
  acceptedAt: Date;
}

export interface PolicyStatusItem {
  type: PolicyType;
  version: string;
  title: string;
  url: string;
  accepted: boolean;
  acceptedAt: Date | null;
}

export interface ConsentStatus {
  policies: PolicyStatusItem[];
  hasPending: boolean;
}
