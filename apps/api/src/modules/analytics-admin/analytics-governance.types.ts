import { BadRequestException, ForbiddenException } from '@nestjs/common';

export type AnalyticsFieldClassification = 'non_phi' | 'pii' | 'phi';

export type AnalyticsGovernanceReviewStatus =
  | 'pending'
  | 'approved'
  | 'rejected';

export const ANALYTICS_GOVERNANCE_PHI_VIOLATION =
  'ANALYTICS_GOVERNANCE_PHI_VIOLATION';
export const ANALYTICS_GOVERNANCE_REVIEW_REQUIRED =
  'ANALYTICS_GOVERNANCE_REVIEW_REQUIRED';
export const ANALYTICS_GOVERNANCE_INVALID_QUERY_WINDOW =
  'ANALYTICS_GOVERNANCE_INVALID_QUERY_WINDOW';
export const ANALYTICS_GOVERNANCE_QUERY_WINDOW_TOO_BROAD =
  'ANALYTICS_GOVERNANCE_QUERY_WINDOW_TOO_BROAD';
export const ANALYTICS_GOVERNANCE_INVALID_CURSOR =
  'ANALYTICS_GOVERNANCE_INVALID_CURSOR';
export const ANALYTICS_GOVERNANCE_UNAUTHORIZED_SCOPE =
  'ANALYTICS_GOVERNANCE_UNAUTHORIZED_SCOPE';

export type AnalyticsGovernanceValidationState = 'approved' | 'review_required';

export interface AnalyticsGovernanceViolation {
  field: string;
  classification: AnalyticsFieldClassification;
  code: typeof ANALYTICS_GOVERNANCE_PHI_VIOLATION;
  hint: string;
}

export interface AnalyticsGovernanceReviewRequest {
  field: string;
  classification: AnalyticsFieldClassification;
  reason: string;
}

export interface AnalyticsGovernanceValidationResult {
  state: AnalyticsGovernanceValidationState;
  message: string;
  reviewRequests?: AnalyticsGovernanceReviewRequest[];
}

export type GovernanceRecordType = 'access' | 'share' | 'consent' | 'policy';

export interface GovernanceRecordCorrelationMetadata {
  eventCorrelationId: string | null;
  queryCorrelationId: string;
}

export interface GovernanceRecord {
  id: string;
  type: GovernanceRecordType;
  action: string;
  outcome: 'pending' | 'success' | 'failure' | 'reverted' | 'denied';
  occurredAt: string;
  actorUserId: string | null;
  subjectUserId: string | null;
  profileId: string | null;
  shareLinkId: string | null;
  correlation: GovernanceRecordCorrelationMetadata;
  metadata: Record<string, string | number | boolean | null>;
}

export interface GovernanceRecordsPageInfo {
  limit: number;
  hasNextPage: boolean;
  nextCursor: string | null;
  windowStart: string;
  windowEnd: string;
}

export interface GovernanceRecordsQueryResult {
  state: 'success';
  records: GovernanceRecord[];
  pageInfo: GovernanceRecordsPageInfo;
}

export interface GovernanceRecordsExportResult {
  state: 'success';
  generatedAt: string;
  records: GovernanceRecord[];
  metadata: {
    queryCorrelationId: string;
    excludedSensitiveFields: string[];
    filterSummary: {
      recordType: GovernanceRecordType | 'all';
      userId: string | null;
      profileId: string | null;
      shareLinkId: string | null;
      windowStart: string;
      windowEnd: string;
    };
  };
}

export class AnalyticsGovernancePhiViolationException extends BadRequestException {
  constructor(details: {
    violations: AnalyticsGovernanceViolation[];
    remediationHints: string[];
  }) {
    super({
      code: ANALYTICS_GOVERNANCE_PHI_VIOLATION,
      message:
        'PHI-safe analytics governance blocked the instrumentation change.',
      details: {
        violations: details.violations,
        remediationHints: details.remediationHints,
      },
    });
  }
}

export class AnalyticsGovernanceInvalidQueryWindowException extends BadRequestException {
  constructor(message: string) {
    super({
      code: ANALYTICS_GOVERNANCE_INVALID_QUERY_WINDOW,
      message,
    });
  }
}

export class AnalyticsGovernanceQueryWindowTooBroadException extends BadRequestException {
  constructor(message: string) {
    super({
      code: ANALYTICS_GOVERNANCE_QUERY_WINDOW_TOO_BROAD,
      message,
    });
  }
}

export class AnalyticsGovernanceInvalidCursorException extends BadRequestException {
  constructor() {
    super({
      code: ANALYTICS_GOVERNANCE_INVALID_CURSOR,
      message: 'cursor is invalid or expired for this query window',
    });
  }
}

export class AnalyticsGovernanceUnauthorizedScopeException extends ForbiddenException {
  constructor(message: string) {
    super({
      code: ANALYTICS_GOVERNANCE_UNAUTHORIZED_SCOPE,
      message,
    });
  }
}
