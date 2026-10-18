export type ReportCollectionDate = {
  collectionDate?: string;
  collectionDateStatus: 'known' | 'unknown' | 'multiple';
};

/** A report date is usable only when saved observations agree on one date. */
export function summarizeReportCollectionDate(
  observationDates: Array<string | null | undefined>,
  headerDate?: string,
): ReportCollectionDate {
  const dates = [
    ...new Set(
      observationDates
        .map((date) => date?.trim())
        .filter((date): date is string => Boolean(date)),
    ),
  ];
  if (dates.length > 1) return { collectionDateStatus: 'multiple' };
  const date = dates[0] ?? headerDate?.trim();
  return date
    ? { collectionDate: date, collectionDateStatus: 'known' }
    : { collectionDateStatus: 'unknown' };
}
