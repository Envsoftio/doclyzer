import assert from 'node:assert/strict';
import {
  acceptedSourceHash,
  assertProcessingTransition,
  legacyReportStatus,
  PROCESSING_STATES,
} from '../src/modules/reports/processing/report-processing.contract';

assert.equal(
  acceptedSourceHash(Buffer.from('abc')),
  'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
);
assert.notEqual(
  acceptedSourceHash(Buffer.from('abc')),
  acceptedSourceHash(Buffer.from('abc\n')),
);
assertProcessingTransition('queued', 'processing');
assertProcessingTransition('processing', 'retry_scheduled');
assertProcessingTransition('retry_scheduled', 'processing');
assertProcessingTransition('processing', 'ready');
for (const state of PROCESSING_STATES) {
  assert.throws(() => assertProcessingTransition(state, state));
  assert.throws(() => assertProcessingTransition('cancelled', state));
}
assert.throws(() => assertProcessingTransition('queued', 'ready'));
assert.throws(() => assertProcessingTransition('ready', 'processing'));
assert.throws(() => assertProcessingTransition('failed', 'queued'));
assert.equal(legacyReportStatus.ready, 'parsed');
assert.equal(legacyReportStatus.retry_scheduled, 'failed_transient');
console.log('Report processing contract tests passed');
