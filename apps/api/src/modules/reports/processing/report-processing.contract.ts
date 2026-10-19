import { createHash } from 'node:crypto';
import type { ReportStatus } from '../../../database/entities/report.entity';

export const PROCESSING_STATES = [
  'queued',
  'processing',
  'retry_scheduled',
  'ready',
  'needs_attention',
  'failed',
  'cancelled',
] as const;
export type ProcessingState = (typeof PROCESSING_STATES)[number];
export type ProcessingStage =
  | 'queued'
  | 'extracting'
  | 'normalizing'
  | 'complete';

const transitions: Record<ProcessingState, readonly ProcessingState[]> = {
  queued: ['processing', 'failed', 'cancelled'],
  processing: [
    'retry_scheduled',
    'ready',
    'needs_attention',
    'failed',
    'cancelled',
  ],
  retry_scheduled: ['processing', 'failed', 'cancelled'],
  ready: ['cancelled'],
  needs_attention: ['cancelled'],
  failed: ['cancelled'],
  cancelled: [],
};

/** A manual retry starts a NEW generation; it is not a transition here. */
export function assertProcessingTransition(
  from: ProcessingState,
  to: ProcessingState,
): void {
  if (!transitions[from].includes(to)) {
    throw new Error(`Illegal report processing transition: ${from} -> ${to}`);
  }
}

export const legacyReportStatus: Record<ProcessingState, ReportStatus> = {
  queued: 'queued',
  processing: 'parsing',
  retry_scheduled: 'failed_transient',
  ready: 'parsed',
  needs_attention: 'content_not_recognized',
  failed: 'failed_terminal',
  cancelled: 'unparsed',
};

/** Hash the original upload, BEFORE image/PDF normalization. */
export function acceptedSourceHash(bytes: Buffer): string {
  return createHash('sha256').update(bytes).digest('hex');
}

export interface ReportStatusEventV1 {
  schemaVersion: 1;
  reportId: string;
  profileId: string;
  generation: number;
  // Decimal strings avoid JavaScript bigint precision loss.
  version: string;
  status: ProcessingState;
  stage: ProcessingStage;
}
