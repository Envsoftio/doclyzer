import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { ConfigService } from '@nestjs/config';
import { ReportsService } from '../src/modules/reports/reports.service';
import { LabDetailsExtractor } from '../src/modules/reports/lab-details-extractor';
import { OpenDataLoaderJsonParser } from '../src/modules/reports/opendataloader-json-parser';
import { LabValueExtractor } from '../src/modules/reports/lab-value-extractor';
import { ReportSummaryService } from '../src/modules/reports/report-summary/report-summary.service';
import { ReportLabAiFallbackService } from '../src/modules/reports/report-lab-ai-fallback.service';
import { ReportResultInsightService } from '../src/modules/reports/report-result-insight.service';

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
        reportSummaryHttpUrl: 'https://example.invalid',
        labAiFallbackEnabled: true,
        labAiFallbackOpenaiApiKey: 'fixture',
      },
    });
    assert.equal(
      await new ReportSummaryService(config).generateSummary(
        Buffer.from('Synthetic identity'),
      ),
      null,
    );
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
      { parameterName: 'Glucose', value: '42', unit: 'Synthetic Address' },
      { parameterName: 'Glucose', value: '42', referenceRange: 'Age 44' },
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
      'PASS privacy boundaries: enabled services made zero outbound requests; unsafe insight fields rejected; synthetic patient extraction',
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
