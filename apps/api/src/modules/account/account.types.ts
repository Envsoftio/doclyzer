import { BadRequestException, NotFoundException } from '@nestjs/common';
export { ACCOUNT_SUSPENDED_RESTRICTED_ACTIONS } from '../../common/restriction/restriction.constants';

export interface AccountProfile {
  id: string;
  email: string;
  displayName: string | null;
  avatarUrl: string | null;
  createdAt: Date;
}

export interface DataExportRequest {
  requestId: string;
  userId: string;
  status: 'pending' | 'completed' | 'failed';
  createdAt: string;
  completedAt?: string;
  downloadUrl?: string;
  failureReason?: string;
}

export interface ClosureRequest {
  requestId: string;
  userId: string;
  status: 'pending' | 'completed';
  createdAt: string;
  message: string;
}

export const EXPORT_REQUEST_NOT_FOUND = 'EXPORT_REQUEST_NOT_FOUND';
export const CLOSURE_CONFIRMATION_REQUIRED = 'CLOSURE_CONFIRMATION_REQUIRED';

export class ExportRequestNotFoundException extends NotFoundException {
  constructor() {
    super({
      code: EXPORT_REQUEST_NOT_FOUND,
      message: 'Export request not found',
    });
  }
}

export class ClosureConfirmationRequiredException extends BadRequestException {
  constructor() {
    super({
      code: CLOSURE_CONFIRMATION_REQUIRED,
      message: 'confirmClosure must be true to proceed',
    });
  }
}

export interface RestrictionStatus {
  isRestricted: boolean;
  rationale?: string;
  nextSteps?: string;
  restrictedActions?: string[];
}

export const COMM_PREF_CATEGORY = {
  SECURITY: 'security',
  COMPLIANCE: 'compliance',
  PRODUCT: 'product',
} as const;

export type CommPrefCategory =
  (typeof COMM_PREF_CATEGORY)[keyof typeof COMM_PREF_CATEGORY];

export const MANDATORY_CATEGORIES: ReadonlySet<CommPrefCategory> = new Set([
  COMM_PREF_CATEGORY.SECURITY,
  COMM_PREF_CATEGORY.COMPLIANCE,
]);

export interface CommunicationPreferenceItem {
  category: CommPrefCategory;
  enabled: boolean;
  mandatory: boolean;
}

export interface CommunicationPreferences {
  preferences: CommunicationPreferenceItem[];
}
