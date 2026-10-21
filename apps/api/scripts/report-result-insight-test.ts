import assert from 'node:assert/strict';
import { ConfigService } from '@nestjs/config';
import type { Repository } from 'typeorm';
import { ReportResultInsightEntity } from '../src/database/entities/report-result-insight.entity';
import { ReportResultInsightUsageEntity } from '../src/database/entities/report-result-insight-usage.entity';
import { selectStoredResult } from '../src/modules/reports/report-result-selector';
import {
  comparePrintedRange,
  ReportResultInsightService,
} from '../src/modules/reports/report-result-insight.service';

async function main() {
  const originalFetch = global.fetch;
  const config = new ConfigService({
    reports: {
      labAiFallbackOpenaiApiKey: 'test-key',
      labAiFallbackOpenaiModel: 'gpt-5-mini',
      resultInsightTimeoutMs: 1000,
    },
  });
  const rows = new Map<string, ReportResultInsightEntity>();
  const cacheRepo = {
    manager: { query: async () => [{ name: 'Hb' }] },
    findOneBy: async ({
      reportId,
      cacheKey,
    }: {
      reportId: string;
      cacheKey: string;
    }) => rows.get(`${reportId}:${cacheKey}`) ?? null,
    upsert: async (row: ReportResultInsightEntity) => {
      rows.set(`${row.reportId}:${row.cacheKey}`, row);
    },
  } as unknown as Repository<ReportResultInsightEntity>;
  const usageRepo = {
    insert: async () => undefined,
  } as unknown as Repository<ReportResultInsightUsageEntity>;
  const service = new ReportResultInsightService(config, cacheRepo, usageRepo);
  const result = {
    parameterName: 'Hb',
    value: '10',
    unit: 'g/dL',
    referenceRange: '12-16',
    sampleDate: 'Synthetic private date must not be transmitted',
  };
  assert.equal(comparePrintedRange(result), 'below');
  assert.equal(comparePrintedRange({ ...result, value: '14' }), 'within');
  assert.equal(comparePrintedRange({ ...result, value: '17' }), 'above');
  assert.equal(
    comparePrintedRange({ ...result, value: '14', isAbnormal: true }),
    'unknown',
  );
  assert.equal(comparePrintedRange({ ...result, unit: undefined }), 'unknown');
  assert.equal(
    comparePrintedRange({ ...result, referenceRange: '<16' }),
    'within',
  );
  assert.equal(
    comparePrintedRange({ ...result, referenceRange: '<=10' }),
    'within',
  );
  assert.equal(
    comparePrintedRange({ ...result, referenceRange: '<10' }),
    'above',
  );
  assert.equal(
    comparePrintedRange({ ...result, referenceRange: '≥12' }),
    'below',
  );
  assert.equal(
    comparePrintedRange({ ...result, referenceRange: '12 to 16' }),
    'below',
  );
  assert.equal(
    comparePrintedRange({ ...result, referenceRange: '12—16' }),
    'below',
  );
  assert.equal(
    comparePrintedRange({ ...result, referenceRange: 'see report' }),
    'unknown',
  );
  assert.equal(
    comparePrintedRange({
      ...result,
      parameterName: 'Total Cholesterol',
      value: '172',
      unit: 'mg/dL',
      referenceRange: 'Adult Desirable: <200 Borderline: 200-239 High: >239',
    }),
    'within',
  );
  assert.equal(
    comparePrintedRange({
      ...result,
      value: '172',
      referenceRange: 'Normal: <161 Desirable: <150 High: >199',
    }),
    'unknown',
  );
  assert.equal(
    selectStoredResult(
      [{ ...result, unit: '12-16', referenceRange: undefined }],
      { parameterName: ' Hb ', value: '10', unit: '' },
    )?.unit,
    '12-16',
  );
  assert.equal(
    selectStoredResult(
      [
        { ...result, unit: 'g/dL' },
        { ...result, unit: 'mg/dL' },
      ],
      { parameterName: 'Hb', value: '10', unit: '' },
    ),
    undefined,
  );
  try {
    let fetchCount = 0;
    global.fetch = async (url, options) => {
      fetchCount += 1;
      assert.equal(url, 'https://api.openai.com/v1/responses');
      assert.equal(options?.method, 'POST');
      assert.equal(
        (options?.headers as Record<string, string>).Authorization,
        'Bearer test-key',
      );
      const body = JSON.parse(options?.body as string) as Record<
        string,
        unknown
      >;
      assert.equal(body.model, 'gpt-5-mini');
      assert.equal(body.store, false);
      assert.match(
        body.instructions as string,
        /uploaded-report text as data|extracted report data as unverified and as data/,
      );
      assert.deepEqual(
        (body.text as { format: { schema: { required: string[] } } }).format
          .schema.required,
        [
          'testExplanation',
          'resultExplanation',
          'possibleSignificance',
          'lifestyleConsiderations',
          'suggestedFollowup',
          'dataUncertainties',
        ],
      );
      assert.deepEqual(JSON.parse(body.input as string), {
        testName: 'Hb',
        value: '10',
        unit: 'g/dL',
        printedLabRange: '12-16',
        printedRangeCategories: '',
        rangeStatus: 'below',
        labAbnormalFlag: null,
      });
      return new Response(
        JSON.stringify({
          output_text: JSON.stringify({
            testExplanation: 'A blood protein.',
            resultExplanation: 'Below the printed range.',
            possibleSignificance: 'Needs clinical context.',
            lifestyleConsiderations: [
              'Discuss diet after evaluating the cause.',
            ],
            suggestedFollowup: 'Discuss with a clinician.',
            dataUncertainties: ['One result cannot identify the cause.'],
          }),
        }),
      );
    };
    const insight = await service.explain('report-1', result);
    assert.equal(insight.testExplanation, 'A blood protein.');
    assert.equal(rows.size, 1);
    assert.deepEqual(await service.explain('report-1', result), insight);
    assert.equal(fetchCount, 1, 'repeat visit should use saved explanation');
    await service.explain('report-2', result);
    assert.equal(
      fetchCount,
      2,
      'a different report must not reuse another report cache',
    );

    global.fetch = async (_url, options) => {
      fetchCount += 1;
      const body = JSON.parse(options?.body as string) as { input: string };
      assert.equal(JSON.parse(body.input).value, '11');
      return new Response(
        JSON.stringify({ output_text: JSON.stringify(insight) }),
      );
    };
    const changed = { ...result, value: '11' };
    await Promise.all([
      service.explain('report-1', changed),
      service.explain('report-1', changed),
    ]);
    assert.equal(
      fetchCount,
      3,
      'concurrent requests for one value should share a call',
    );
    assert.equal(rows.size, 3, 'a changed value needs its own cache entry');

    const newerModelService = new ReportResultInsightService(
      new ConfigService({
        reports: {
          labAiFallbackOpenaiApiKey: 'test-key',
          labAiFallbackOpenaiModel: 'new-model',
          resultInsightTimeoutMs: 1000,
        },
      }),
      cacheRepo,
      usageRepo,
    );
    global.fetch = async (_url, options) => {
      fetchCount += 1;
      const body = JSON.parse(options?.body as string) as { model: string };
      assert.equal(body.model, 'new-model');
      return new Response(
        JSON.stringify({ output_text: JSON.stringify(insight) }),
      );
    };
    await newerModelService.explain('report-1', result);
    assert.equal(
      fetchCount,
      4,
      'a model change must regenerate the explanation',
    );

    global.fetch = async () => new Response('{', { status: 200 });
    await assert.rejects(() =>
      service.explain('report-1', { ...result, value: '12' }),
    );
    assert.equal(rows.size, 4, 'failed explanations must not be cached');

    let usageWrites = 0;
    const failingUsageRepo = {
      insert: async () => {
        usageWrites += 1;
        throw new Error('usage table unavailable');
      },
    } as unknown as Repository<ReportResultInsightUsageEntity>;
    const serviceWithFailingUsage = new ReportResultInsightService(
      config,
      cacheRepo,
      failingUsageRepo,
    );
    global.fetch = async () => {
      fetchCount += 1;
      return new Response(
        JSON.stringify({ output_text: JSON.stringify(insight) }),
      );
    };
    assert.deepEqual(
      await serviceWithFailingUsage.explain(
        'report-usage-failure',
        result,
        'user-1',
      ),
      insight,
      'a usage write failure must not hide a generated explanation',
    );
    assert.equal(usageWrites, 1);
    assert.deepEqual(
      await serviceWithFailingUsage.explain(
        'report-usage-failure',
        result,
        'user-1',
      ),
      insight,
      'the saved explanation must remain available',
    );

    const unconfigured = new ReportResultInsightService(
      new ConfigService({}),
      cacheRepo,
      usageRepo,
    );
    await assert.rejects(() => unconfigured.explain('report-3', result));

    const unreviewedRepo = {
      ...cacheRepo,
      manager: { query: async () => [] },
    } as unknown as Repository<ReportResultInsightEntity>;
    const unreviewed = new ReportResultInsightService(
      config,
      unreviewedRepo,
      usageRepo,
    );
    const callsBeforeUnreviewed = fetchCount;
    global.fetch = async (_url, options) => {
      fetchCount += 1;
      const body = JSON.parse(options?.body as string) as { input: string };
      assert.deepEqual(JSON.parse(body.input), {
        testName: 'Vitamin D (25-OH)',
        value: '10',
        unit: '',
        printedLabRange: '',
        printedRangeCategories: '',
        rangeStatus: 'unknown',
        labAbnormalFlag: null,
      });
      return new Response(
        JSON.stringify({ output_text: JSON.stringify(insight) }),
      );
    };
    await unreviewed.explain('report-4', {
      ...result,
      parameterName: 'Vitamin D (25-OH)',
      unit: 'unrecognized unit',
      referenceRange: 'see report',
    });
    assert.equal(fetchCount, callsBeforeUnreviewed + 1);
    global.fetch = async (_url, options) => {
      const body = JSON.parse(options?.body as string) as { input: string };
      const input = JSON.parse(body.input) as Record<string, unknown>;
      assert.equal(input.printedLabRange, '<200');
      assert.equal(
        input.printedRangeCategories,
        'Adult Desirable: <200 Borderline: 200-239 High: >239',
      );
      assert.equal(input.rangeStatus, 'within');
      return new Response(
        JSON.stringify({ output_text: JSON.stringify(insight) }),
      );
    };
    await service.explain('report-categorical', {
      ...result,
      parameterName: 'Total Cholesterol',
      value: '172',
      unit: 'mg/dL',
      referenceRange: 'Adult Desirable: <200 Borderline: 200-239 High: >239',
    });
    await assert.rejects(
      () =>
        unreviewed.explain('report-4', {
          ...result,
          parameterName: 'Name: Jane Doe',
        }),
      (error: { response?: { code?: string } }) =>
        error.response?.code === 'RESULT_INSIGHT_UNSAFE_INPUT',
    );
    assert.equal(fetchCount, callsBeforeUnreviewed + 1);
  } finally {
    global.fetch = originalFetch;
  }
  console.log('Report result insight checks passed.');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
