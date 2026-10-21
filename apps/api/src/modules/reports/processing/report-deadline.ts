import type { AdmissionPolicy } from './report-admission.service';

export function reportDeadlineMs(
  policy: AdmissionPolicy,
  pageCount: number | null | undefined,
): number {
  if (!pageCount || !Number.isSafeInteger(pageCount) || pageCount < 1)
    return policy.processingDeadlineMs;
  return Math.min(
    2147483647,
    Math.max(
      policy.processingDeadlineMs,
      policy.processingDeadlineOverheadMs +
        pageCount * policy.processingDeadlinePerPageMs,
    ),
  );
}
