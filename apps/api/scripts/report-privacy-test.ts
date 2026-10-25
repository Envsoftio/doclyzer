import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { ConfigService } from '@nestjs/config';
import { HttpException } from '@nestjs/common';
import { ReportsService } from '../src/modules/reports/reports.service';
import { LabDetailsExtractor } from '../src/modules/reports/lab-details-extractor';
import { OpenDataLoaderJsonParser } from '../src/modules/reports/opendataloader-json-parser';
import { LabValueExtractor } from '../src/modules/reports/lab-value-extractor';
import {
  ReportSummaryService,
  safeSummaryValues,
} from '../src/modules/reports/report-summary/report-summary.service';
import { ReportLabAiFallbackService } from '../src/modules/reports/report-lab-ai-fallback.service';
import { ReportResultInsightService } from '../src/modules/reports/report-result-insight.service';
import { ReportProcessingController } from '../src/modules/reports/processing/report-processing.controller';
import { ReportEntity } from '../src/database/entities/report.entity';
import { ReportLabValueEntity } from '../src/database/entities/report-lab-value.entity';

async function main() {
  let requests = 0;
  const originalFetch = global.fetch;
  global.fetch = async () => {
    requests++;
    throw new Error('Transport forbidden');
  };
  try {
    const config = new ConfigService({
      reports: {
        reportSummaryEnabled: true,
        labAiFallbackEnabled: true,
        labAiFallbackOpenaiApiKey: 'fixture',
        reportNarrativeOpenaiModel: 'gpt-5-mini',
        reportNarrativeInputPricePerMillion: 0.1,
        reportNarrativeOutputPricePerMillion: 0.5,
        resultInsightOpenaiInputPricePerMillion: 0.1,
        resultInsightOpenaiOutputPricePerMillion: 0.5,
      },
    });
    const summaryUsageRows: Array<Record<string, unknown>> = [];
    const summaryUsageRepo = {
      insert: async (row: Record<string, unknown>) => {
        summaryUsageRows.push(row);
      },
    } as never;
    assert.equal(
      await new ReportSummaryService(config, summaryUsageRepo).generateSummary([
        {
          parameterName: 'Patient Name',
          value: '42',
          unit: null,
          referenceRange: null,
        },
        {
          parameterName: 'Glucose',
          value: '5551234567',
          unit: null,
          referenceRange: null,
        },
      ]),
      null,
    );
    const summaryReportId = '11111111-1111-4111-8111-111111111111';
    const summaryUserId = '22222222-2222-4222-8222-222222222222';
    let savedSummary: string | null = null;
    let savedStatus = 'not_requested';
    let generations = 0;
    let failEnrichment = false;
    const summaryController = new ReportProcessingController(
      {
        query: async (sql: string, args?: unknown[]) => {
          if (sql.includes('SELECT id FROM reports'))
            return [{ id: summaryReportId }];
          if (sql.includes("SET summary_status='pending'")) {
            if (
              (savedSummary?.trim() && args?.[2] !== true) ||
              !['not_requested', 'failed', 'ready'].includes(savedStatus)
            )
              return [[], 0];
            savedStatus = 'pending';
            return [[{ generation: 0 }], 1];
          }
          if (sql.includes('SET summary_status=CASE')) {
            savedStatus = savedSummary ? 'ready' : 'failed';
            return [];
          }
          if (sql.includes('SELECT summary_status AS'))
            return [{ summaryStatus: savedStatus }];
          throw new Error('Unexpected summary query');
        },
      } as never,
      config,
      {} as never,
      {} as never,
      {} as never,
      { enforceRateLimit: () => undefined } as never,
      {} as never,
      {
        enrichWorkerSummary: async (_reportId: string, generation: number) => {
          assert.equal(generation, 0);
          generations++;
          if (failEnrichment) throw new Error('Synthetic provider failure');
          savedSummary = 'Saved explanation';
          savedStatus = 'ready';
          return true;
        },
      } as never,
    );
    const summaryRequest = { user: { id: summaryUserId } } as never;
    await summaryController.retrySummary(summaryRequest, summaryReportId);
    await summaryController.retrySummary(summaryRequest, summaryReportId);
    assert.equal(
      generations,
      1,
      'a saved summary must be reused without regenerating',
    );
    savedSummary = null;
    savedStatus = 'failed';
    await summaryController.retrySummary(summaryRequest, summaryReportId);
    assert.equal(generations, 2, 'failed summaries must be retryable');
    savedSummary = null;
    savedStatus = 'failed';
    failEnrichment = true;
    await assert.rejects(
      summaryController.retrySummary(summaryRequest, summaryReportId),
      (error: unknown) => {
        assert.ok(error instanceof HttpException);
        assert.deepEqual(error.getResponse(), {
          code: 'REPORT_SUMMARY_UNAVAILABLE',
          message: 'The summary could not be generated. Please try again.',
        });
        return true;
      },
    );
    assert.equal(savedStatus, 'failed');
    savedSummary = 'Earlier summary';
    savedStatus = 'ready';
    const generationsBeforeSavedSummary = generations;
    await summaryController.retrySummary(summaryRequest, summaryReportId);
    assert.equal(generations, generationsBeforeSavedSummary);
    assert.equal(savedSummary, 'Earlier summary');
    assert.equal(savedStatus, 'ready');
    failEnrichment = false;
    await summaryController.retrySummary(summaryRequest, summaryReportId, 'true');
    assert.equal(generations, generationsBeforeSavedSummary + 1);
    assert.equal(savedSummary, 'Saved explanation');
    const storedReport = {
      id: summaryReportId,
      processingGeneration: 0,
      processingState: null,
      status: 'parsed',
      summary: null as string | null,
      summaryStatus: 'pending',
    };
    const storedRows = [
      {
        id: '33333333-3333-4333-8333-333333333333',
        parameterName: 'Glucose',
        value: '92',
        unit: 'mg/dL',
        referenceRange: '70-99',
        reviewVersion: 0,
      },
    ];
    let summaryCalls = 0;
    let summaryUsageWrites = 0;
    let saves = 0;
    let failSummaryGeneration = false;
    let generatedSummary = 'Overview\nThe saved result is glucose 92 mg/dL.';
    const manager = {
      getRepository: (entity: unknown) =>
        entity === ReportEntity
          ? {
              findOne: async () => storedReport,
              save: async () => {
                saves++;
              },
            }
          : entity === ReportLabValueEntity
            ? { find: async () => storedRows }
            : null,
    };
    const persistenceService = Object.assign(
      Object.create(ReportsService.prototype) as object,
      {
        configService: config,
        reportRepo: {
          findOneBy: async () => storedReport,
          manager: {
            transaction: async (
              work: (value: typeof manager) => Promise<void>,
            ) => work(manager),
          },
        },
        reportLabValueRepo: { find: async () => storedRows },
        reportSummaryService: {
          generateSummary: async (
            _rows: unknown,
            onUsage: (usage: {
              model: string;
              inputTokens: number;
              outputTokens: number;
            }) => void,
          ) => {
            summaryCalls++;
            if (failSummaryGeneration) return null;
            onUsage({ model: 'fixture', inputTokens: 120, outputTokens: 80 });
            return generatedSummary;
          },
          recordUsageSafely: async () => {
            summaryUsageWrites++;
          },
        },
      },
    ) as unknown as ReportsService;
    await persistenceService.enrichWorkerSummary(summaryReportId, 0);
    await persistenceService.enrichWorkerSummary(summaryReportId, 0);
    assert.equal(summaryCalls, 1);
    assert.equal(
      summaryUsageWrites,
      1,
      'a cached summary must not create another cost event',
    );
    assert.equal(saves, 1);
    assert.equal(storedReport.summaryStatus, 'ready');
    assert.equal(
      storedReport.summary,
      'Overview\nThe saved result is glucose 92 mg/dL.',
    );
    generatedSummary =
      'Overview\nThe refreshed explanation includes glucose 92 mg/dL.';
    assert.equal(
      await persistenceService.enrichWorkerSummary(summaryReportId, 0),
      false,
    );
    assert.equal(summaryCalls, 1);
    assert.equal(
      storedReport.summary,
      'Overview\nThe saved result is glucose 92 mg/dL.',
    );
    assert.equal(
      await persistenceService.enrichWorkerSummary(summaryReportId, 0, true),
      true,
    );
    assert.equal(storedReport.summary, generatedSummary);
    failSummaryGeneration = true;
    assert.equal(
      await persistenceService.enrichWorkerSummary(summaryReportId, 0, true),
      false,
    );
    assert.equal(storedReport.summary, generatedSummary);
    assert.equal(storedReport.summaryStatus, 'ready');
    failSummaryGeneration = false;
    storedReport.summary = null;
    storedReport.summaryStatus = 'not_requested';
    assert.equal(
      await persistenceService.enrichWorkerSummary(summaryReportId, 0),
      true,
    );
    assert.equal(storedReport.summary, generatedSummary);
    storedReport.summary = null;
    storedReport.summaryStatus = 'not_requested';
    failSummaryGeneration = true;
    assert.equal(
      await persistenceService.enrichWorkerSummary(summaryReportId, 0),
      false,
    );
    assert.equal(storedReport.summaryStatus, 'failed');
    assert.equal(storedReport.summary, null);
    assert.equal(
      await new ReportLabAiFallbackService(config).tryExtract({
        reportId: 'fixture',
        trigger: 'upload',
        confidence: 0,
        lowConfidenceReasons: ['Synthetic name'],
        candidateRows: ['Synthetic Person 44 5551234567'],
      }),
      null,
    );
    const repo = {
      manager: {
        query: async (_sql: string, args: string[]) =>
          args[0] === 'glucose' ? [{ name: 'Glucose' }] : [],
      },
    };
    const insight = new ReportResultInsightService(
      config,
      repo as never,
      {} as never,
    );
    for (const result of [
      { parameterName: 'Synthetic Person', value: '42' },
      { parameterName: 'Glucose', value: '5551234567' },
    ]) {
      let rejected = false;
      try {
        await insight.explain('fixture', result);
      } catch {
        rejected = true;
      }
      assert.ok(rejected);
    }
    assert.equal(requests, 0);
    assert.deepEqual(
      safeSummaryValues([
        {
          parameterName: 'Glucose',
          value: '92',
          unit: 'mg/dL',
          referenceRange: '70-99',
        },
        {
          parameterName: 'Patient Name',
          value: '42',
          unit: null,
          referenceRange: null,
        },
        {
          parameterName: 'Glucose',
          value: '9876543210',
          unit: null,
          referenceRange: null,
        },
      ]),
      [
        {
          parameterName: 'Glucose',
          value: '92',
          unit: 'mg/dL',
          referenceRange: '70-99',
        },
      ],
    );
    global.fetch = async (_url, options) => {
      requests++;
      const body = JSON.parse(String(options?.body)) as Record<string, unknown>;
      const input = JSON.parse(String(body.input)) as Record<string, unknown>;
      assert.deepEqual(input, {
        results: [
          {
            parameterName: 'Glucose',
            value: '92',
            unit: 'mg/dL',
            referenceRange: '70-99',
          },
        ],
      });
      assert.equal(body.store, false);
      assert.match(
        String(body.instructions),
        /what the test measures in plain words/,
      );
      assert.match(String(body.instructions), /Connect related values/);
      assert.ok(!String(options?.body).includes('Synthetic Person'));
      return new Response(
        JSON.stringify({
          usage: { input_tokens: 120, output_tokens: 80, total_tokens: 200 },
          output_text: JSON.stringify({
            overview:
              'The supplied glucose result falls within the printed reference range. It is one measurement and needs the report and clinical context to be useful.',
            resultsToDiscuss:
              'Glucose is 92 mg/dL, compared with the printed range of 70-99 mg/dL. This test measures the amount of sugar in the blood at the time the sample was taken. A result within this printed range does not by itself answer every question about blood sugar regulation. Whether the sample was collected fasting, after a meal, or at another time can change how a clinician interprets it. This single value cannot establish a long-term pattern or replace other information about symptoms and prior results.',
            otherResults:
              'No other interpretable test values were supplied for this summary.',
            questionsForClinician:
              'Was this sample taken fasting, and does that affect which range should be used? Check the extracted result against the original report and ask whether any other results or previous measurements change its interpretation.',
          }),
        }),
        { status: 200 },
      );
    };
    const summaryService = new ReportSummaryService(config, summaryUsageRepo);
    let providerUsage: {
      model: string;
      inputTokens: number;
      outputTokens: number;
    } | null = null;
    const summary = await summaryService.generateSummary(
      [
        {
          parameterName: 'Glucose',
          value: '92',
          unit: 'mg/dL',
          referenceRange: '70-99',
          patientName: 'Synthetic Person',
        } as never,
      ],
      (usage) => {
        providerUsage = usage;
      },
    );
    assert.ok(summary?.includes('Results to discuss\nGlucose is 92 mg/dL'));
    assert.deepEqual(providerUsage, {
      model: 'gpt-5-mini',
      inputTokens: 120,
      outputTokens: 80,
    });
    await summaryService.recordUsageSafely(
      summaryUserId,
      summaryReportId,
      providerUsage,
    );
    assert.equal(summaryUsageRows.length, 1);
    assert.equal(summaryUsageRows[0].estimatedCostUsd, '0.00005200');
    assert.equal(summaryUsageRows[0].totalTokens, 200);
    assert.match(
      String(summaryUsageRows[0].cacheKey),
      /^summary:[0-9a-f-]{36}$/,
    );
    assert.ok(!JSON.stringify(summaryUsageRows).includes('Glucose'));
    assert.equal(requests, 1);
    let summaryAttempts = 0;
    global.fetch = async () => {
      summaryAttempts++;
      return new Response(
        JSON.stringify({
          usage: { input_tokens: 100, output_tokens: 40 },
          output_text: JSON.stringify(
            summaryAttempts === 1
              ? {
                  overview: 'MCHC is low.',
                  resultsToDiscuss: 'MCHC is 30.7 g/dL.',
                  otherResults: '',
                  questionsForClinician: 'Ask your doctor.',
                }
              : {
                  overview:
                    'The reported MCHC is below its printed reference range. This finding needs the rest of the blood count and clinical context before it can be interpreted for this person.',
                  resultsToDiscuss:
                    'MCHC is 30.7 g/dL, below the printed reference range of 32-36 g/dL. MCHC describes how concentrated hemoglobin is inside red blood cells; hemoglobin is the protein that carries oxygen. A lower value can mean the cells contain less hemoglobin for their size. One possible explanation is reduced iron availability, because iron is needed to make hemoglobin. Another possibility is an inherited difference in hemoglobin production. These are possibilities, not diagnoses from this value alone. The hemoglobin level and red blood cell count would help show whether anemia is present. MCV would add information about cell size, while ferritin could help assess iron stores if a clinician thinks that test is appropriate. Those related values were not supplied here, so the pattern cannot be narrowed down from this extract.',
                  otherResults:
                    'No other interpretable blood count measurements were supplied. The printed range itself may depend on the laboratory and the person being tested, so the original report should be checked.',
                  questionsForClinician:
                    'What were the hemoglobin and MCV results on the same report, and do they change the interpretation? Would checking iron stores be useful in this situation? Confirm that 30.7 g/dL and the 32-36 g/dL range were extracted correctly from the original report.',
                },
          ),
        }),
        { status: 200 },
      );
    };
    let retryUsage: {
      model: string;
      inputTokens: number;
      outputTokens: number;
    } | null = null;
    const detailedSummary = await summaryService.generateSummary(
      [
        {
          parameterName: 'MCHC',
          value: '30.7',
          unit: 'g/dL',
          referenceRange: '32-36',
        },
      ],
      (usage) => {
        retryUsage = usage;
      },
    );
    assert.equal(summaryAttempts, 2);
    assert.ok(detailedSummary?.includes('MCHC is 30.7 g/dL'));
    assert.deepEqual(retryUsage, {
      model: 'gpt-5-mini',
      inputTokens: 200,
      outputTokens: 80,
    });
    await summaryService.recordUsageSafely(
      summaryUserId,
      summaryReportId,
      retryUsage,
    );
    assert.equal(summaryUsageRows.length, 2);
    assert.equal(summaryUsageRows[1].totalTokens, 280);
    assert.equal(summaryUsageRows[1].estimatedCostUsd, '0.00006000');
    global.fetch = async () =>
      new Response(
        JSON.stringify({
          output_text: JSON.stringify({
            overview: 'Contact me at patient@example.com for details.',
            resultsToDiscuss: '',
            otherResults: '',
            questionsForClinician: '',
          }),
        }),
      );
    assert.equal(
      await new ReportSummaryService(config, summaryUsageRepo).generateSummary([
        {
          parameterName: 'Glucose',
          value: '92',
          unit: 'mg/dL',
          referenceRange: '70-99',
        },
      ]),
      null,
    );
    global.fetch = async () => {
      throw new Error('Transport forbidden');
    };
    const service = Object.create(ReportsService.prototype) as any;
    const synthetic =
      'Name : Example Person Client Name : Example Diagnostics\nSex/Age Male / 44 Years\nCollected On : 12-10-2026';
    const patient = service.extractPatientDetails(synthetic);
    assert.equal(patient.name, 'Example Person');
    assert.equal(
      service.extractPatientDetails(
        '| Name | : Example Person | Ref By : Example | Client Name | Example Lab |',
      ).name,
      'Example Person',
    );
    assert.equal(patient.age, '44 Years');
    assert.equal(patient.gender, 'Male');
    assert.equal(patient.sampleCollectionDate, '12-10-2026');
    console.log(
      'PASS privacy boundaries: unsafe inputs caused zero requests; summary sent only allowed result fields; unsafe insight fields rejected',
    );
    if (process.argv[2]) {
      const raw = readFileSync(process.argv[2], 'utf8');
      const conversion = process.argv[2].endsWith('.json')
        ? JSON.parse(raw)
        : null;
      const text = conversion ? conversion.document.md_content : raw;
      service.labDetailsExtractor = new LabDetailsExtractor();
      if (conversion) {
        const parsed = new OpenDataLoaderJsonParser().parseWithDiagnostics(
          conversion.document.json_content,
        );
        console.log(
          JSON.stringify({
            conversionStatus: conversion.status,
            pages: Object.keys(conversion.document.json_content.pages ?? {})
              .length,
            structuredRows: parsed.extractedLabValues.length,
            candidateRows: parsed.diagnostics.candidateRows,
            parsedRows: parsed.diagnostics.parsedRows,
          }),
        );
      }
      const extracted = service.extractPatientDetails(text);
      const combined = service.withBestPatientDetails(
        { patientDetails: {}, sections: [] },
        text,
      );
      if (!combined.patientDetails.name || !combined.labDetails?.name)
        throw new Error('Persisted details missing');
      if (process.argv[3]) {
        const independent = service.extractPatientDetails(
          readFileSync(process.argv[3], 'utf8'),
        );
        for (const field of ['name', 'age', 'gender', 'sampleCollectionDate']) {
          if (extracted[field] !== independent[field]) {
            console.log({ disagreeingField: field });
            throw new Error('Independent extraction disagrees');
          }
        }
        console.log(
          'PASS patient fields agree across independent PDF text and Docling extraction',
        );
      }
      const lab = new LabDetailsExtractor().extractFromTranscript(text);
      const rows = new LabValueExtractor().extract(text);
      const fields = Object.fromEntries(
        Object.entries(extracted).map(([k, v]) => [k, Boolean(v)]),
      );
      console.log(
        JSON.stringify({
          patientFields: fields,
          labFields: Object.fromEntries(
            Object.entries(lab).map(([k, v]) => [k, Boolean(v)]),
          ),
          extractedRows: rows.length,
          outboundRequests: requests,
        }),
      );
      // Never put real values into assertion diffs or console output.
      if (
        !extracted.name ||
        !extracted.age ||
        !extracted.gender ||
        !lab.name ||
        !rows.length
      )
        throw new Error('Local file extraction missing required fields');
    }
  } finally {
    global.fetch = originalFetch;
  }
}
main().catch(() => {
  console.error('Privacy/extraction verification failed (details suppressed)');
  process.exitCode = 1;
});
