import assert from 'node:assert/strict';
import { PDFDocument } from 'pdf-lib';
import { ReportWorkerService } from '../src/modules/reports/processing/report-worker.service';
import { createServer } from 'node:http';
import { Agent, getGlobalDispatcher, setGlobalDispatcher } from 'undici';
import { ConfigService } from '@nestjs/config';
import { UnlimitedOcrClient } from '../src/modules/reports/unlimited-ocr.client';
import { ReportsService } from '../src/modules/reports/reports.service';
import { OpenDataLoaderJsonParser } from '../src/modules/reports/opendataloader-json-parser';

const document = (value: string) => ({
  type: 'document',
  kids: [
    {
      type: 'table',
      rows: [
        ['Test Name', 'Result', 'Unit'],
        ['Glucose', value, 'mg/dL'],
      ].map((row) => ({ cells: row.map((content) => ({ content })) })),
    },
  ],
});
async function main() {
  const originalFetch = global.fetch;
  const client = new UnlimitedOcrClient(
    new ConfigService({
      reports: {
        unlimitedOcrEnabled: true,
        unlimitedOcrBaseUrl: 'http://ocr.invalid',
        unlimitedOcrTimeoutMs: 500,
      },
    }),
  );
  try {
    global.fetch = async (url, options) => {
      assert.equal(url, 'http://ocr.invalid/v1/convert/pdf');
      assert.equal(options?.method, 'POST');
      assert.deepEqual(
        Buffer.from(options?.body as Uint8Array),
        Buffer.from('pdf'),
      );
      return new Response(
        JSON.stringify({
          engine: 'unlimited-ocr',
          adapterVersion: 1,
          text: 'Glucose 90',
          parsedJson: document('90'),
        }),
      );
    };
    assert.ok(await client.parsePdf(Buffer.from('pdf')));
    for (const response of [
      new Response('', { status: 503 }),
      new Response('{'),
      new Response('{}'),
      new Response(
        JSON.stringify({ text: 'Glucose 90', parsedJson: document('90') }),
      ), // Reject a stale/different OCR service.
      new Response(
        JSON.stringify({
          text: 'text',
          parsedJson: { type: 'wrong', kids: [] },
        }),
      ),
    ]) {
      global.fetch = async () => response;
      assert.equal(await client.parsePdf(Buffer.from('pdf')), null);
    }
    global.fetch = async () =>
      new Response(
        JSON.stringify({
          engine: 'unlimited-ocr',
          adapterVersion: 1,
          text: 'Glucose 90',
          parsedJson: document('90'),
          diagnostics: { warnings: ['unsupported_result_row'] },
        }),
      );
    assert.equal(
      (
        (await client.parsePdf(Buffer.from('pdf')))?.parsedJson as {
          extractionIncomplete: boolean;
        }
      ).extractionIncomplete,
      true,
    );
    global.fetch = async () => {
      throw new DOMException('timeout', 'TimeoutError');
    };
    assert.equal(await client.parsePdf(Buffer.from('pdf')), null);
    global.fetch = () => {
      throw new Error('Disabled client must not fetch');
    };
    assert.equal(
      await new UnlimitedOcrClient(new ConfigService()).parsePdf(
        Buffer.from('pdf'),
      ),
      null,
    );
  } finally {
    global.fetch = originalFetch;
  }

  // Reproduce a shorter HTTP header deadline without waiting five minutes.
  const previousDispatcher = getGlobalDispatcher();
  const shortDispatcher = new Agent({ headersTimeout: 20 });
  const server = createServer((_req, res) => {
    setTimeout(() => {
      res.setHeader('Content-Type', 'application/json');
      res.end(
        JSON.stringify({
          engine: 'unlimited-ocr',
          adapterVersion: 1,
          text: 'Glucose 90',
          parsedJson: document('90'),
        }),
      );
    }, 1500);
  });
  await new Promise<void>((resolve) => server.listen(0, '127.0.0.1', resolve));
  const address = server.address();
  assert.ok(address && typeof address !== 'string');
  const url = `http://127.0.0.1:${address.port}`;
  try {
    setGlobalDispatcher(shortDispatcher);
    await assert.rejects(fetch(url));
    const longClient = new UnlimitedOcrClient(
      new ConfigService({
        reports: {
          unlimitedOcrEnabled: true,
          unlimitedOcrBaseUrl: url,
          unlimitedOcrTimeoutMs: 4000,
        },
      }),
    );
    assert.ok(
      await longClient.parsePdf(Buffer.from('pdf')),
      'OCR-specific header deadline must override the shorter global deadline',
    );
  } finally {
    setGlobalDispatcher(previousDispatcher);
    await shortDispatcher.destroy();
    server.closeAllConnections();
    await new Promise<void>((resolve) => server.close(() => resolve()));
  }

  // Exercise the actual worker boundary, including resumption of durable fallback work.
  const pdf = await PDFDocument.create();
  pdf.addPage();
  const pdfBytes = Buffer.from(await pdf.save());
  for (const scenario of [
    'unlimited',
    'fallback',
    'resume',
    'staged',
    'uncertain',
  ]) {
    const workerCalls: string[] = [];
    const worker = Object.assign(Object.create(ReportWorkerService.prototype), {
      config: new ConfigService(),
      log: { log: () => undefined, warn: () => undefined },
      db: {
        query: async () => [
          {
            deadline_at: new Date(Date.now() + 60000),
            content_type: 'application/pdf',
            original_file_name: 'fixture.pdf',
            original_file_storage_key: 'fixture',
            provider_task_id: scenario === 'resume' ? 'existing-task' : null,
            staged_result: scenario === 'staged' ? {} : null,
            submission_uncertain_at:
              scenario === 'uncertain' ? new Date() : null,
          },
        ],
      },
      storage: { get: async () => pdfBytes },
      reports: {
        normalizeWorkerSource: async () => ({
          buffer: pdfBytes,
          source: 'pdf',
        }),
        extractWithOcrCascade: async () => {
          workerCalls.push('cascade');
          return { text: 'fixture', parsedJson: document('90') };
        },
        prepareWorkerResult: async () => ({
          outcome: 'ready',
          persist: async () => {},
        }),
      },
    });
    await worker.execute(
      { reportId: 'fixture', jobId: 'fixture', attempt: 1 },
      {
        setStage: async () => {},
        complete: async () => {
          workerCalls.push('complete');
        },
        fail: async () => {
          assert.fail('Worker must complete');
        },
      },
      {
        convert: async () => {
          workerCalls.push('docling');
          return { text: 'fixture', parsedJson: document('90') };
        },
      },
      new AbortController().signal,
    );
    assert.deepEqual(workerCalls, ['docling', 'cascade', 'complete'], scenario);
  }
  console.log(
    'PASS Unlimited HTTP contract, failures, disabled mode, worker native/cascade wiring',
  );
}
void main().catch((error: unknown) => {
  console.error(error);
  process.exitCode = 1;
});
