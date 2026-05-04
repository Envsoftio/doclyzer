import { registerAs } from '@nestjs/config';

export interface ReportsConfig {
  /** Enable/disable AI report summarisation. */
  reportSummaryEnabled: boolean;
  /** Provider type for summarisation (currently only 'http' supported). */
  reportSummaryProvider: string;
  /** Base URL of the internal summariser HTTP service. */
  reportSummaryHttpUrl: string;
  /** Timeout in ms for summariser HTTP call. */
  reportSummaryTimeoutMs: number;
  /** Enable/disable OpenDataLoader parser integration. */
  opendataloaderEnabled: boolean;
  /** CLI executable used for OpenDataLoader parsing. */
  opendataloaderCliCommand: string;
  /** Timeout in ms for OpenDataLoader CLI execution. */
  opendataloaderTimeoutMs: number;
  /** Extra CLI arguments passed to OpenDataLoader command. */
  opendataloaderExtraArgs: string;
  /** Enable/disable low-confidence AI fallback for lab extraction. */
  labAiFallbackEnabled: boolean;
  /** OpenAI API key for low-confidence lab extraction fallback. */
  labAiFallbackOpenaiApiKey: string;
  /** OpenAI model used for fallback extraction. */
  labAiFallbackOpenaiModel: string;
  /** OpenAI base URL override (optional). */
  labAiFallbackOpenaiBaseUrl: string;
  /** Timeout in ms for fallback extraction model call. */
  labAiFallbackTimeoutMs: number;
  /** Minimum deterministic confidence required to skip AI fallback. */
  labAiFallbackMinConfidence: number;
}

export const reportsConfig = registerAs(
  'reports',
  (): ReportsConfig => ({
    reportSummaryEnabled: process.env.REPORT_SUMMARY_ENABLED === 'true',
    reportSummaryProvider: process.env.REPORT_SUMMARY_PROVIDER ?? 'http',
    reportSummaryHttpUrl: process.env.REPORT_SUMMARY_HTTP_URL ?? '',
    reportSummaryTimeoutMs: parseInt(
      process.env.REPORT_SUMMARY_TIMEOUT_MS ?? '10000',
      10,
    ),
    opendataloaderEnabled: process.env.OPENDATALOADER_ENABLED === 'true',
    opendataloaderCliCommand:
      process.env.OPENDATALOADER_CLI_COMMAND ?? 'opendataloader-pdf',
    opendataloaderTimeoutMs: parseInt(
      process.env.OPENDATALOADER_TIMEOUT_MS ?? '120000',
      10,
    ),
    opendataloaderExtraArgs: process.env.OPENDATALOADER_EXTRA_ARGS ?? '',
    labAiFallbackEnabled: process.env.REPORT_LAB_AI_FALLBACK_ENABLED === 'true',
    labAiFallbackOpenaiApiKey:
      process.env.REPORT_LAB_AI_FALLBACK_OPENAI_API_KEY ?? '',
    labAiFallbackOpenaiModel:
      process.env.REPORT_LAB_AI_FALLBACK_OPENAI_MODEL ?? 'gpt-5-mini',
    labAiFallbackOpenaiBaseUrl:
      process.env.REPORT_LAB_AI_FALLBACK_OPENAI_BASE_URL ??
      'https://api.openai.com/v1',
    labAiFallbackTimeoutMs: parseInt(
      process.env.REPORT_LAB_AI_FALLBACK_TIMEOUT_MS ?? '10000',
      10,
    ),
    labAiFallbackMinConfidence: parseFloat(
      process.env.REPORT_LAB_AI_FALLBACK_MIN_CONFIDENCE ?? '0.72',
    ),
  }),
);
