import assert from 'node:assert/strict';
import { ConfigService } from '@nestjs/config';
import { OpenDataLoaderJsonParser } from '../src/modules/reports/opendataloader-json-parser';
import { ReportsService } from '../src/modules/reports/reports.service';
import {
  isUnclearResultValue,
  ReportValueSuggestionService,
  verifiedValueSuggestion,
} from '../src/modules/reports/report-value-suggestion.service';

async function main() {
  assert.equal(isUnclearResultValue('O.5'), true);
  assert.equal(isUnclearResultValue('1,2'), true);
  assert.equal(isUnclearResultValue('1,200'), true);
  assert.equal(isUnclearResultValue('12.5'), false);
  assert.equal(verifiedValueSuggestion('O.5', '0.5'), '0.5');
  assert.equal(verifiedValueSuggestion('1,2', '1.2'), null);
  assert.equal(verifiedValueSuggestion('O.5', '0.8'), null);

  const parsed = new OpenDataLoaderJsonParser().parse({
    type: 'document',
    kids: [
      {
        type: 'table',
        rows: [
          ['Test Name', 'Result', 'Unit', 'Ref Range'],
          ['Glucose', 'O.5', 'mg/dL', '0.4-1.0'],
          ['Creatinine', '1,2', 'mg/dL', '0.6-1.3'],
        ].map((row) => ({ cells: row.map((content) => ({ content })) })),
      },
    ],
  });
  assert.deepEqual(
    parsed.extractedLabValues.map((row) => row.value),
    ['O.5', '1,2'],
  );

  const service = new ReportValueSuggestionService(
    new ConfigService({
      reports: {
        labAiFallbackOpenaiApiKey: 'test-key',
        labAiFallbackOpenaiModel: 'test-model',
      },
    }),
  );
  const originalFetch = global.fetch;
  let calls = 0;
  try {
    global.fetch = async (_url, options) => {
      calls += 1;
      const body = JSON.parse(options?.body as string) as {
        input: string;
        store: boolean;
      };
      assert.equal(body.store, false);
      const input = JSON.parse(body.input) as {
        targetIndex: number;
        reportResults: Array<{ value: string; referenceRange: string }>;
      };
      assert.equal(input.targetIndex, 0);
      assert.deepEqual(
        input.reportResults.map((row) => row.value),
        ['O.5', '1,2'],
      );
      assert.deepEqual(
        input.reportResults.map((row) => row.referenceRange),
        ['0.4-1.0', '0.6-1.3'],
      );
      return new Response(
        JSON.stringify({
          output_text: JSON.stringify({ suggestedValue: '0.5' }),
        }),
      );
    };
    const context = parsed.extractedLabValues.map((row) => ({
      parameterName: row.parameterName,
      value: row.value,
      unit: row.unit ?? null,
      referenceRange: row.referenceRange ?? null,
    }));
    assert.equal(await service.suggest(context[0], context), '0.5');
    assert.equal(calls, 1);
    assert.equal(
      await new ReportValueSuggestionService(new ConfigService({})).suggest(
        context[0],
        context,
      ),
      null,
    );
    assert.equal(calls, 1, 'missing provider key must not send report data');
    global.fetch = async () =>
      new Response(
        JSON.stringify({
          output_text: JSON.stringify({ suggestedValue: '0.8' }),
        }),
      );
    assert.equal(await service.suggest(context[0], context), null);

    const processing = Object.create(ReportsService.prototype) as Record<
      string,
      unknown
    >;
    processing.valueSuggestionService = {
      suggest: async (target: { value: string }, all: unknown[]) => {
        assert.equal(all.length, 2);
        return target.value === 'O.5' ? '0.5' : null;
      },
    };
    const rows = context.map((row) => ({
      ...row,
      sampleDate: null,
      isAbnormal: null,
    }));
    await (
      processing as unknown as {
        resolveUnclearValues: (
          values: Array<{ value: string }>,
        ) => Promise<void>;
      }
    ).resolveUnclearValues(rows);
    assert.equal(rows[0].value, '0.5');
    assert.equal(
      (rows[0] as (typeof rows)[0] & { originalValue?: string }).originalValue,
      'O.5',
    );
    assert.equal(rows[1].value, '1,2');
  } finally {
    global.fetch = originalFetch;
  }
  console.log('Result value suggestion checks passed.');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
