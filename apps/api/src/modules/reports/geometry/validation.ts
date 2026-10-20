import type { LabCandidate, ReviewReason } from './lab-parser';

/** Shadow eligibility is a policy check, never clinical publication. */
export interface ValidationContext {
  patientResolved: boolean;
  reportDateResolved: boolean;
  specimenResolved: boolean;
  sourceVisible: boolean;
  sourceQualityAccepted: boolean;
  parsingProfileValidated: boolean;
  associationCount: number;
  tokenReuse: boolean;
  normalizationSupported: boolean;
  verificationRequired: boolean;
  verificationCompleted: boolean;
}
export function validateCandidate(
  candidate: LabCandidate,
  context: ValidationContext,
): LabCandidate {
  const reasons = new Set<ReviewReason>(
    candidate.reviewReasons.filter((r) => r !== 'quality_profile_unvalidated'),
  );
  if (!context.sourceVisible || !context.sourceQualityAccepted)
    reasons.add('unreadable_source');
  if (!candidate.evidence.test.length || !candidate.evidence.result.length)
    reasons.add('unreadable_source');
  if (context.associationCount !== 1 || context.tokenReuse)
    reasons.add('ambiguous_row_pairing');
  if (
    !context.patientResolved ||
    !context.reportDateResolved ||
    !context.specimenResolved
  )
    reasons.add('context_unresolved');
  if (
    context.verificationRequired &&
    (!context.verificationCompleted ||
      !candidate.readings.some((r) => r.engine === 'tesseract'))
  )
    reasons.add('verification_timeout');
  if (!context.normalizationSupported || !context.parsingProfileValidated)
    reasons.add('quality_profile_unvalidated');
  const eligible =
    reasons.size === 0 &&
    candidate.resultKind !== 'unparsed' &&
    candidate.resultKind !== 'missing';
  return {
    ...candidate,
    machineEligible: eligible,
    interpretationReady: false,
    status: 'needs_review',
    reviewReasons: [...reasons],
  };
}
