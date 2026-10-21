import assert from 'node:assert/strict';
import { ConfigService } from '@nestjs/config';
import { processingSettings } from '../src/modules/reports/processing/processing-settings';
import { reportDeadlineMs } from '../src/modules/reports/processing/report-deadline';
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
const defaultSettings = processingSettings(new ConfigService({}));
assert.equal(defaultSettings.runtime, true);
assert.equal(defaultSettings.admission, true);
assert.equal(reportDeadlineMs(defaultSettings.policy, 1), 1800000);
assert.equal(reportDeadlineMs(defaultSettings.policy, 100), 13600000);
const drainedSettings = processingSettings(
  new ConfigService({
    REPORT_ASYNC_RUNTIME_ENABLED: 'true',
    REPORT_ASYNC_ACCEPTANCE_ENABLED: 'false',
  }),
);
assert.equal(drainedSettings.runtime, true);
assert.equal(drainedSettings.admission, false);
console.log('Report processing contract tests passed');
