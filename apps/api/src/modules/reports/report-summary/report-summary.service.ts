import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { redactSecrets } from '../../../common/redact-secrets';
import type { ReportSummarizer } from './report-summarizer.interface';

@Injectable()
export class ReportSummaryService implements ReportSummarizer {
  private readonly logger = new Logger(ReportSummaryService.name);

  constructor(private readonly configService: ConfigService) {}

  async generateSummary(pdfBuffer: Buffer): Promise<string | null> {
    const enabled =
      this.configService.get<boolean>('reports.reportSummaryEnabled') ?? false;
    if (!enabled) return null;

    const url =
      this.configService.get<string>('reports.reportSummaryHttpUrl') ?? '';
    if (!url) {
      this.logger.warn(
        redactSecrets(
          'Report summarisation enabled but REPORT_SUMMARY_HTTP_URL is not set',
        ),
      );
      return null;
    }

    const provider =
      this.configService.get<string>('reports.reportSummaryProvider') ?? 'http';
    if (provider !== 'http') {
      this.logger.warn(
        redactSecrets(
          `Unsupported summariser provider '${provider}'; only 'http' is supported`,
        ),
      );
      return null;
    }

    const timeoutMs =
      this.configService.get<number>('reports.reportSummaryTimeoutMs') ??
      10_000;

    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);

    try {
      const response = await fetch(`${url}/summarise`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ pdf: pdfBuffer.toString('base64') }),
        signal: controller.signal,
      });

      if (!response.ok) {
        this.logger.warn(
          redactSecrets(
            `Summariser returned non-OK status: ${response.status}`,
          ),
        );
        return null;
      }

      const data = (await response.json()) as unknown;
      if (
        typeof data === 'object' &&
        data !== null &&
        'summary' in data &&
        typeof (data as Record<string, unknown>).summary === 'string'
      ) {
        return (data as Record<string, unknown>).summary as string;
      }

      this.logger.warn('Summariser response missing "summary" field');
      return null;
    } catch (err) {
      const isAbort = err instanceof Error && err.name === 'AbortError';
      this.logger.warn(
        redactSecrets(
          isAbort
            ? `Summariser request timed out after ${timeoutMs}ms`
            : `Summariser request failed: ${err instanceof Error ? err.message : String(err)}`,
        ),
      );
      return null;
    } finally {
      clearTimeout(timer);
    }
  }
}
