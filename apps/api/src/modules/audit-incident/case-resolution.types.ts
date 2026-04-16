import {
  BadRequestException,
  ConflictException,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';

export type CaseResolutionOutcome = 'closed' | 'reopened' | 'escalated';

export const CASE_RESOLUTION_OUTCOMES: CaseResolutionOutcome[] = [
  'closed',
  'reopened',
  'escalated',
];

// Error codes — screaming snake case per project convention
export const CASE_RESOLUTION_NOT_FOUND = 'CASE_RESOLUTION_NOT_FOUND' as const;
export const CASE_RESOLUTION_REQUIRED_FIELDS_MISSING =
  'CASE_RESOLUTION_REQUIRED_FIELDS_MISSING' as const;
export const CASE_RESOLUTION_IMMUTABLE = 'CASE_RESOLUTION_IMMUTABLE' as const;
export const CASE_RESOLUTION_TARGET_NOT_FOUND =
  'CASE_RESOLUTION_TARGET_NOT_FOUND' as const;
export const CASE_RESOLUTION_INVALID_PRIOR_DOCUMENT =
  'CASE_RESOLUTION_INVALID_PRIOR_DOCUMENT' as const;

export interface CaseResolutionDocument {
  id: string;
  targetUserId: string;
  authorUserId: string | null;
  summary: string;
  rootCause: string;
  userImpact: string;
  actionsTaken: string;
  outcome: CaseResolutionOutcome;
  auditCorrelationId: string | null;
  priorDocumentId: string | null;
  version: number;
  createdAt: string;
}

export interface CaseResolutionSubmitResult {
  state: 'success';
  document: CaseResolutionDocument;
}

export interface CaseResolutionListResult {
  documents: CaseResolutionDocument[];
  total: number;
  page: number;
  limit: number;
}

export class CaseResolutionNotFoundException extends NotFoundException {
  constructor(id: string) {
    super({
      code: CASE_RESOLUTION_NOT_FOUND,
      message: `Case resolution document ${id} was not found`,
    });
  }
}

export class CaseResolutionTargetNotFoundException extends NotFoundException {
  constructor(targetUserId: string) {
    super({
      code: CASE_RESOLUTION_TARGET_NOT_FOUND,
      message: `Target account ${targetUserId} was not found`,
    });
  }
}

export class CaseResolutionRequiredFieldsMissingException extends BadRequestException {
  constructor(fields: string[]) {
    super({
      code: CASE_RESOLUTION_REQUIRED_FIELDS_MISSING,
      message: `Required closure fields are missing: ${fields.join(', ')}`,
    });
  }
}

export class CaseResolutionImmutableException extends ConflictException {
  constructor(id: string) {
    super({
      code: CASE_RESOLUTION_IMMUTABLE,
      message: `Resolution document ${id} is immutable and cannot be modified`,
    });
  }
}

export class CaseResolutionInvalidPriorDocumentException extends UnprocessableEntityException {
  constructor(priorDocumentId: string) {
    super({
      code: CASE_RESOLUTION_INVALID_PRIOR_DOCUMENT,
      message: `Prior document ${priorDocumentId} does not belong to this case`,
    });
  }
}
