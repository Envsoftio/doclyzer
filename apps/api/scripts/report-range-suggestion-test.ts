import assert from 'node:assert/strict';
import { ConfigService } from '@nestjs/config';
import {
  ReportRangeSuggestionService,
  preferredPrintedRange,
  safeRawRange,
  validSuggestedRange,
} from '../src/modules/reports/report-range-suggestion.service';
import { ReportsService } from '../src/modules/reports/reports.service';

async function main() {
  const usageRows: unknown[] = [];
  const optimalCategories = [
    'Optimal: <100',
    'Above Optimal: 100-129',
    'Borderline: 130-159',
    'High: 160-189',
    'Very High: >190',
  ].join('\n');
  for (const raw of [
    optimalCategories,
    optimalCategories.replaceAll('\n', '\\'),
    optimalCategories.replaceAll('\n', '; '),
    optimalCategories.replaceAll('\n', '<br>').replace('<100', '&lt;100'),
    optimalCategories.replace('Above Optimal', 'Near or Above Optimal'),
  ]) {
    assert.equal(preferredPrintedRange(raw), '<100');
    assert.notEqual(safeRawRange(raw), null);
  }
  for (const raw of [
    'Above Optimal: 100-129 High: >160',
    'Optimal: <100 Normal: <130 High: >160',
    'Optimal: <100 Above Optimal: 129-100',
    'Optimal: <100 High: 160-189 Note: 190',
    'Optimal: <100 Above Optimal: 90-129 High: >129',
    'Normal: 0-100 High: 100-200',
    'Female Optimal: <100 Male Optimal: <130',
    'Suboptimal: <100 High: >160',
    'Optimal: <100 High: 160',
  ])
    assert.equal(preferredPrintedRange(raw), null, raw);
  assert.equal(validSuggestedRange('3.50&#x2d;5.20'), true);
  assert.equal(validSuggestedRange('5.20-3.50'), false);
  assert.equal(validSuggestedRange('3.50 to 5.20'), true);
  assert.equal(safeRawRange('12-l6'), '12-l6');
  assert.equal(
    safeRawRange('Normal: <161 High: 161-199 Very High: 200-499'),
    'Normal: <161 High: 161-199 Very High: 200-499',
  );
  assert.equal(
    safeRawRange('Adult Desirable: <200 Borderline: 200-239 High: >239'),
    'Adult Desirable: <200 Borderline: 200-239 High: >239',
  );
  assert.equal(
    preferredPrintedRange(
      'Adult Desirable: <200 Borderline: 200-239 High: >239',
    ),
    '<200',
  );
  assert.equal(
    preferredPrintedRange('Normal: <161 High: 161-199 Very High: 200-499'),
    '<161',
  );
  assert.equal(
    preferredPrintedRange('Normal: <161 Desirable: <150 High: >199'),
    null,
  );
  for (const raw of [
    null,
    '',
    'Patient Jane 12-16',
    'John 42',
    'Name: 12-16',
    'normal range 12-16',
    '5551234567',
    'O12-16',
    'Patient Jane Normal: <161 High: 161-199',
  ]) {
    assert.equal(safeRawRange(raw), null);
  }
  const service = new ReportRangeSuggestionService(
    new ConfigService({
      reports: {
        labAiFallbackOpenaiApiKey: 'test-key',
        labAiFallbackOpenaiModel: 'test-model',
        resultInsightOpenaiInputPricePerMillion: 1,
        resultInsightOpenaiOutputPricePerMillion: 2,
      },
    }),
    {
      insert: async (row: unknown) => {
        usageRows.push(row);
      },
    } as never,
  );
  const originalFetch = global.fetch;
  let calls = 0;
  try {
    global.fetch = async (_url, options) => {
      calls++;
      const body = JSON.parse(options?.body as string);
      assert.equal(body.store, false);
      assert.equal(body.model, 'test-model');
      assert.deepEqual(JSON.parse(body.input), { rawRange: '12-l6' });
      return new Response(
        JSON.stringify({
          output_text: JSON.stringify({ suggestedRange: '12-16' }),
          usage: { input_tokens: 100, output_tokens: 20 },
        }),
      );
    };
    assert.equal(
      (await service.suggest('Patient Jane 12-16', 'user', 'report'))
        .suggestedRange,
      null,
    );
    assert.equal(
      (await service.suggest('12-16', 'user', 'report')).suggestedRange,
      null,
      'clear ranges do not need an LLM',
    );
    assert.equal(calls, 0);
    const suggested = await service.suggest('12-l6', 'user', 'report');
    assert.equal(suggested.suggestedRange, '12-16');
    assert.equal(suggested.estimatedCostUsd, 0.00014);
    assert.equal(usageRows.length, 1);
    assert.equal(calls, 1);

    const deferred = await service.suggest('12-l6', 'user', 'report', true);
    assert.equal(
      usageRows.length,
      1,
      'direct upload waits until the report exists',
    );
    await service.recordUsage('12-l6', 'user', 'report', deferred);
    assert.equal(usageRows.length, 2);

    const callsBeforeCategories = calls;
    for (const range of [
      optimalCategories,
      'Normal: <161 High: 161-199 Very High: 200-499',
    ]) {
      const readable = await service.suggest(range, 'user', 'report');
      assert.equal(readable.providerCalled, false);
      assert.equal(readable.suggestedRange, null);
    }
    assert.equal(
      calls,
      callsBeforeCategories,
      'readable categories do not need an LLM',
    );

    const processing = Object.create(ReportsService.prototype) as Record<
      string,
      unknown
    >;
    processing.rangeSuggestionService = service;
    processing.logger = { warn: () => undefined };
    const values = [
      {
        parameterName: 'Test',
        value: '10',
        unit: 'mg/dL',
        sampleDate: null,
        referenceRange: '12-l6',
        isAbnormal: null,
      },
      {
        parameterName: 'Other',
        value: '10',
        unit: 'mg/dL',
        sampleDate: null,
        referenceRange: 'Patient Jane 12-16',
        isAbnormal: null,
      },
    ];
    values.push({
      parameterName: 'Categorical test',
      value: '110',
      unit: 'mg/dL',
      sampleDate: null,
      referenceRange: optimalCategories,
      isAbnormal: null,
    });
    values.push({
      parameterName: 'Albumin',
      value: '4.06',
      unit: 'g/dL',
      sampleDate: null,
      referenceRange: '3.50-5.20',
      isAbnormal: null,
    });
    const before = usageRows.length;
    global.fetch = async () =>
      new Response(
        JSON.stringify({
          output_text: JSON.stringify({ suggestedRange: '12-16' }),
          usage: { input_tokens: 100, output_tokens: 20 },
        }),
      );
    const deferredUsage = await (
      processing as unknown as {
        resolveUnclearRanges: (
          rows: typeof values,
          userId: string,
          reportId: string,
          deferUsage: boolean,
        ) => Promise<Array<{ raw: string }>>;
      }
    ).resolveUnclearRanges(values, 'user', 'report', true);
    assert.equal(values[0].referenceRange, '12-16');
    assert.equal(values[1].referenceRange, 'Patient Jane 12-16');
    assert.equal(values[2].referenceRange, optimalCategories);
    assert.equal(values[3].referenceRange, '3.50-5.20');
    assert.equal(deferredUsage.length, 1);
    assert.equal(usageRows.length, before);

    global.fetch = async () =>
      new Response(
        JSON.stringify({
          output_text: JSON.stringify({ suggestedRange: '12-18' }),
        }),
      );
    assert.equal(
      (await service.suggest('12-l6', 'user', 'report')).suggestedRange,
      null,
      'changed digits must be rejected',
    );
    global.fetch = async () =>
      new Response(
        JSON.stringify({
          output_text: JSON.stringify({ suggestedRange: '12-16 patient' }),
        }),
      );
    assert.equal(
      (await service.suggest('12-l6', 'user', 'report')).suggestedRange,
      null,
      'free text must be rejected',
    );
    global.fetch = async () => {
      throw new Error('private provider error');
    };
    await assert.rejects(
      () => service.suggest('12-l6', 'user', 'report'),
      (error: { response?: { code?: string } }) =>
        error.response?.code === 'RANGE_SUGGESTION_UNAVAILABLE',
    );
  } finally {
    global.fetch = originalFetch;
  }
  console.log('Range suggestion privacy and validation checks passed.');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
