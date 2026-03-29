import { InternalServerErrorException } from '@nestjs/common';

export type AuditActionOutcome = 'success' | 'failure' | 'denied' | 'reverted';

export type AuditMetadataValue = string | number | boolean;
export type AuditMetadata = Record<string, AuditMetadataValue>;

export const AUDIT_ACTION_OUTCOMES: AuditActionOutcome[] = [
  'success',
  'failure',
  'denied',
  'reverted',
];

export const DEFAULT_AUDIT_PAGE_LIMIT = 20;
export const MAX_AUDIT_PAGE_LIMIT = 100;

export interface AuditTamperEvidence {
  hash: string;
  previousHash: string | null;
  sequence: number;
}

export interface AuditActionRecord {
  id: string;
  actorUserId: string | null;
  action: string;
  target: string;
  sensitiveTarget: boolean;
  outcome: AuditActionOutcome;
  correlationId: string;
  metadata: AuditMetadata | null;
  performedAt: string;
  tamperEvidence: AuditTamperEvidence;
}

export interface AuditActionSearchResult {
  items: AuditActionRecord[];
  total: number;
  page: number;
  limit: number;
}

export enum AuditIncidentErrorCode {
  AUDIT_PERSISTENCE_FAILED = 'AUDIT_EVENT_PERSISTENCE_FAILED',
}

export class AuditIncidentPersistenceException extends InternalServerErrorException {
  constructor(message?: string) {
    super({
      code: AuditIncidentErrorCode.AUDIT_PERSISTENCE_FAILED,
      message: message ?? 'Unable to persist audit event',
    });
  }
}
