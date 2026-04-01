import { BadRequestException } from '@nestjs/common';

export const EMERGENCY_ACTION_NOTE_REQUIRED =
  'EMERGENCY_ACTION_NOTE_REQUIRED' as const;
export const EMERGENCY_TARGET_NOT_FOUND =
  'EMERGENCY_TARGET_NOT_FOUND' as const;

// Action name prefixes used when recording emergency actions in the audit log
export const EMERGENCY_ACTION_PREFIX = 'EMERGENCY_';

export type EmergencyActionType =
  | 'ACCOUNT_SUSPEND'
  | 'ACCOUNT_UNSUSPEND'
  | 'SHARE_LINK_SUSPEND'
  | 'SHARE_LINK_UNSUSPEND';

export type EmergencyContainmentState = 'success' | 'reverted' | 'failure';

export interface EmergencyContainmentResult {
  state: EmergencyContainmentState;
  targetType: 'account' | 'share_link';
  targetId: string;
  action: string;
  changed: boolean;
  actedAt: string;
}

export interface EmergencyActionTimelineResult {
  items: EmergencyAuditRecord[];
  total: number;
  page: number;
  limit: number;
}

export interface EmergencyAuditRecord {
  id: string;
  actorUserId: string | null;
  action: string;
  target: string;
  outcome: string;
  correlationId: string;
  auditNote: string | null;
  performedAt: string;
  tamperEvidence: {
    hash: string;
    previousHash: string | null;
    sequence: number;
  };
}

export class EmergencyActionNoteRequiredException extends BadRequestException {
  constructor() {
    super({
      code: EMERGENCY_ACTION_NOTE_REQUIRED,
      message:
        'auditNote is required for emergency containment actions and must be at least 10 characters',
    });
  }
}
