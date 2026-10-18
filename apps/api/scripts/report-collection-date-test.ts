import { strict as assert } from 'node:assert';
import { summarizeReportCollectionDate } from '../src/modules/reports/report-collection-date';

assert.deepEqual(summarizeReportCollectionDate([], undefined), {
  collectionDateStatus: 'unknown',
});
assert.deepEqual(summarizeReportCollectionDate([], '2026-10-10'), {
  collectionDateStatus: 'known',
  collectionDate: '2026-10-10',
});
assert.deepEqual(
  summarizeReportCollectionDate(
    ['2026-10-11', null, '2026-10-11'],
    '2026-10-10',
  ),
  { collectionDateStatus: 'known', collectionDate: '2026-10-11' },
);
assert.deepEqual(
  summarizeReportCollectionDate(['2026-10-10', '2026-10-11'], '2026-10-10'),
  { collectionDateStatus: 'multiple' },
);
