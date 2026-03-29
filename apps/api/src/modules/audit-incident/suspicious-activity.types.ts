import { BadRequestException, NotFoundException } from '@nestjs/common';

export type SuspiciousActivitySeverity = 'low' | 'medium' | 'high' | 'critical';

export type SuspiciousActivityStatus = 'open' | 'in_review' | 'resolved';

export type SuspiciousActivityContainmentAction =
  | 'suspend_account'
  | 'suspend_share_link'
  | 'restrict_account'
  | 'require_mfa'
  | 'manual_review'
  | 'none';

export const SUSPICIOUS_ACTIVITY_SEVERITIES: SuspiciousActivitySeverity[] = [
  'low',
  'medium',
  'high',
  'critical',
];

export const SUSPICIOUS_ACTIVITY_STATUSES: SuspiciousActivityStatus[] = [
  'open',
  'in_review',
  'resolved',
];

export const SUSPICIOUS_ACTIVITY_CONTAINMENT_ACTIONS: SuspiciousActivityContainmentAction[] =
  [
    'suspend_account',
    'suspend_share_link',
    'restrict_account',
    'require_mfa',
    'manual_review',
    'none',
  ];

export const SUSPICIOUS_ACTIVITY_ITEM_NOT_FOUND =
  'SUSPICIOUS_ACTIVITY_ITEM_NOT_FOUND';
export const SUSPICIOUS_ACTIVITY_INVALID_TRANSITION =
  'SUSPICIOUS_ACTIVITY_INVALID_STATUS_TRANSITION';

export interface SuspiciousActivityContainmentSuggestion {
  [key: string]: string | number | boolean;
  action: SuspiciousActivityContainmentAction;
  reason: string;
  confidenceScore: number;
  autoApplied: false;
}

export interface SuspiciousActivityQueueItem {
  id: string;
  targetType: string;
  targetId: string;
  signalType: string;
  ruleCode: string;
  severity: SuspiciousActivitySeverity;
  status: SuspiciousActivityStatus;
  confidenceScore: number;
  detectionSummary: string | null;
  detectionCount: number;
  firstDetectedAt: string;
  lastDetectedAt: string;
  suggestedContainment: SuspiciousActivityContainmentSuggestion | null;
  metadata: Record<string, string | number | boolean | null> | null;
  reviewedAt: string | null;
  resolvedAt: string | null;
  resolutionNotes: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface SuspiciousActivityIngestResult {
  state: 'success';
  action: 'created' | 'deduped';
  item: SuspiciousActivityQueueItem;
}

export interface SuspiciousActivityStatusUpdateResult {
  state: 'success';
  item: SuspiciousActivityQueueItem;
}

export interface SuspiciousActivityQueueResult {
  state: 'success';
  items: SuspiciousActivityQueueItem[];
  page: number;
  limit: number;
  total: number;
}

export class SuspiciousActivityQueueNotFoundException extends NotFoundException {
  constructor() {
    super({
      code: SUSPICIOUS_ACTIVITY_ITEM_NOT_FOUND,
      message: 'Suspicious activity queue item not found',
    });
  }
}

export class SuspiciousActivityInvalidTransitionException extends BadRequestException {
  constructor(message: string) {
    super({
      code: SUSPICIOUS_ACTIVITY_INVALID_TRANSITION,
      message,
    });
  }
}
