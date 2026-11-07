export function useReportLabels() {
  const { t } = useI18n()
  const keys: Record<string, string> = {
    uploading: 'uploading', queued: 'waitingToProcess', parsing: 'readingReport',
    parsed: 'readyToReview', ready: 'readyToReview', processing: 'readingReport',
    content_not_recognized: 'someResultsNeedReview', needs_attention: 'someResultsNeedReview',
    unparsed: 'couldNotReadReport', failed_transient: 'processingStopped',
    failed_terminal: 'couldNotProcessReport', failed: 'couldNotProcessReport',
    cancelled: 'processingStopped', reviewed: 'filterReviewed', unreviewed: 'unreviewed',
  }
  return { statusLabel: (status?: string) => t(keys[status ?? ''] ?? 'statusUnavailable') }
}
