import { registerAs } from '@nestjs/config';

export interface ReportsConfig {
  parseStubFail: boolean;
  /** When true, retry parse stub returns parsed (for testing retry success path). */
  parseStubRetrySucceeds: boolean;
  /** When true and parse would fail, stub returns content_not_recognized (not a health report). */
  parseStubContentNotRecognized: boolean;
  /** Enable/disable AI report summarisation. */
  reportSummaryEnabled: boolean;
  /** Provider type for summarisation (currently only 'http' supported). */
  reportSummaryProvider: string;
  /** Base URL of the internal summariser HTTP service. */
  reportSummaryHttpUrl: string;
  /** Timeout in ms for summariser HTTP call. */
  reportSummaryTimeoutMs: number;
  /** Enable/disable real Docling PDF parsing (replaces stub when true). */
  doclingEnabled: boolean;
  /** Base URL of the Docling serve HTTP service. */
  doclingHttpUrl: string;
  /** Timeout in ms for Docling HTTP call. */
  doclingTimeoutMs: number;
}

export const reportsConfig = registerAs(
  'reports',
  (): ReportsConfig => ({
    parseStubFail: process.env.PARSE_STUB_FAIL === 'true',
    parseStubRetrySucceeds: process.env.PARSE_STUB_RETRY_SUCCEEDS === 'true',
    parseStubContentNotRecognized:
      process.env.PARSE_STUB_CONTENT_NOT_RECOGNIZED === 'true',
    reportSummaryEnabled: process.env.REPORT_SUMMARY_ENABLED === 'true',
    reportSummaryProvider: process.env.REPORT_SUMMARY_PROVIDER ?? 'http',
    reportSummaryHttpUrl: process.env.REPORT_SUMMARY_HTTP_URL ?? '',
    reportSummaryTimeoutMs: parseInt(
      process.env.REPORT_SUMMARY_TIMEOUT_MS ?? '10000',
      10,
    ),
    doclingEnabled: process.env.DOCLING_ENABLED === 'true',
    doclingHttpUrl: process.env.DOCLING_HTTP_URL ?? '',
    doclingTimeoutMs: parseInt(process.env.DOCLING_TIMEOUT_MS ?? '60000', 10),
  }),
);
