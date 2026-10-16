import assert from 'node:assert/strict';
import { createServer } from 'node:http';
import { Agent, getGlobalDispatcher, setGlobalDispatcher } from 'undici';
import { ConfigService } from '@nestjs/config';
import { SuryaOcrClient } from '../src/modules/reports/surya-ocr.client';
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
  const client = new SuryaOcrClient(
    new ConfigService({
      reports: {
        suryaOcrEnabled: true,
        suryaOcrBaseUrl: 'http://ocr.invalid',
        suryaOcrTimeoutMs: 500,
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
        JSON.stringify({ text: 'Glucose 90', parsedJson: document('90') }),
      );
    };
    assert.ok(await client.parsePdf(Buffer.from('pdf')));
    for (const response of [
      new Response('', { status: 503 }),
      new Response('{'),
      new Response('{}'),
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
          text: 'Glucose 90',
          parsedJson: document('90'),
          diagnostics: { warnings: ['unsupported_result_row'] },
        }),
      );
    assert.equal(await client.parsePdf(Buffer.from('pdf')), null);
    global.fetch = async () => {
      throw new DOMException('timeout', 'TimeoutError');
    };
    assert.equal(await client.parsePdf(Buffer.from('pdf')), null);
    global.fetch = () => {
      throw new Error('Disabled client must not fetch');
    };
    assert.equal(
      await new SuryaOcrClient(new ConfigService()).parsePdf(
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
        JSON.stringify({ text: 'Glucose 90', parsedJson: document('90') }),
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
    const longClient = new SuryaOcrClient(
      new ConfigService({
        reports: {
          suryaOcrEnabled: true,
          suryaOcrBaseUrl: url,
          suryaOcrTimeoutMs: 4000,
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

  const calls: string[] = [];
  let suryaResult: unknown = { text: 'Glucose 90', parsedJson: document('90') };
  let nativeResult: unknown = {
    text: 'Glucose 90',
    parsedJson: document('90'),
  };
  const service = Object.assign(
    Object.create(ReportsService.prototype) as object,
    {
      odlJsonParser: new OpenDataLoaderJsonParser(),
      logger: { log: () => undefined },
      logParseQuality: () => undefined,
      evaluateParsedTranscript: (text: string) => ({ ok: Boolean(text), text }),
      openDataLoaderClient: { parsePdf: () => Promise.resolve(null) },
      suryaOcrClient: {
        parsePdf: () => {
          calls.push('surya');
          return Promise.resolve(suryaResult);
        },
      },
      doclingOcrClient: {
        parsePdf: (_: Buffer, options: { forceOcr?: boolean }) => {
          calls.push(options.forceOcr ? 'docling-ocr' : 'native');
          return Promise.resolve(
            options.forceOcr
              ? { text: 'Glucose 91', parsedJson: document('91') }
              : nativeResult,
          );
        },
      },
    },
  ) as unknown as {
    parseReportBuffer(
      buffer: Buffer,
      trigger: string,
      id: string,
      source: string,
    ): Promise<{ opendataloaderJson: unknown }>;
  };
  const parse = (source: string) =>
    service.parseReportBuffer(
      Buffer.from('pdf'),
      'upload',
      'synthetic',
      source,
    );
  await parse('pdf');
  assert.deepEqual(
    calls.splice(0),
    ['native'],
    'Good native extraction avoids OCR',
  );
  let result = await parse('image');
  assert.deepEqual(calls.splice(0), ['surya'], 'Images prefer Surya');
  assert.deepEqual(result.opendataloaderJson, document('90'));
  nativeResult = null;
  await parse('pdf');
  assert.deepEqual(calls.splice(0), ['native', 'surya'], 'Scans use Surya');
  suryaResult = null;
  result = await parse('image');
  assert.deepEqual(calls.splice(0), ['surya', 'docling-ocr']);
  assert.deepEqual(result.opendataloaderJson, document('91'));
  suryaResult = {
    text: 'Narrative only',
    parsedJson: { type: 'document', kids: [] },
  };
  await parse('image');
  assert.deepEqual(
    calls.splice(0),
    ['surya', 'docling-ocr'],
    'Prose alone is not usable lab extraction',
  );
  console.log(
    'PASS Surya HTTP contract, failures, disabled mode, native/image/scanned PDF routing and fallback',
  );
}
void main().catch((error: unknown) => {
  console.error(error);
  process.exitCode = 1;
});
