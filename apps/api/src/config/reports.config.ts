import { registerAs } from '@nestjs/config';

export interface ReportsConfig {
  parseStubFail: boolean;
  /** When true, retry parse stub returns parsed (for testing retry success path). */
  parseStubRetrySucceeds: boolean;
  /** When true and parse would fail, stub returns content_not_recognized (not a health report). */
  parseStubContentNotRecognized: boolean;
}

export const reportsConfig = registerAs(
  'reports',
  (): ReportsConfig => ({
    parseStubFail: process.env.PARSE_STUB_FAIL === 'true',
    parseStubRetrySucceeds: process.env.PARSE_STUB_RETRY_SUCCEEDS === 'true',
    parseStubContentNotRecognized:
      process.env.PARSE_STUB_CONTENT_NOT_RECOGNIZED === 'true',
  }),
);
