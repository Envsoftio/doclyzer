import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { redactSecrets } from '../../common/redact-secrets';

@Injectable()
export class DoclingClient {
  private readonly logger = new Logger(DoclingClient.name);

  constructor(private readonly configService: ConfigService) {}

  async parsePdf(buffer: Buffer): Promise<{ text: string } | null> {
    const enabled =
      this.configService.get<boolean>('reports.doclingEnabled') ?? false;
    if (!enabled) return null;

    const url = this.configService.get<string>('reports.doclingHttpUrl') ?? '';
    if (!url) {
      this.logger.warn(
        redactSecrets('Docling enabled but DOCLING_HTTP_URL is not set'),
      );
      return null;
    }

    const timeoutMs =
      this.configService.get<number>('reports.doclingTimeoutMs') ?? 60_000;

    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);

    try {
      const response = await fetch(`${url}/v1alpha/convert/source`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          file_source: {
            base64_string: buffer.toString('base64'),
            filename: 'report.pdf',
          },
          options: { to_formats: ['md'] },
        }),
        signal: controller.signal,
      });

      if (!response.ok) {
        this.logger.warn(
          redactSecrets(`Docling returned non-OK status: ${response.status}`),
        );
        return null;
      }

      const data = (await response.json()) as unknown;
      const md =
        typeof data === 'object' &&
        data !== null &&
        'document' in data &&
        typeof (data as Record<string, unknown>).document === 'object' &&
        (data as Record<string, unknown>).document !== null &&
        'export_formats' in
          ((data as Record<string, unknown>).document as object) &&
        typeof (
          (data as Record<string, Record<string, unknown>>).document
            .export_formats as Record<string, unknown>
        ).md === 'string'
          ? (data as Record<string, Record<string, Record<string, string>>>)
              .document.export_formats.md
          : null;

      if (!md) {
        this.logger.warn('Docling response missing document.export_formats.md');
        return null;
      }

      return { text: md };
    } catch (err) {
      const isAbort = err instanceof Error && err.name === 'AbortError';
      this.logger.warn(
        redactSecrets(
          isAbort
            ? `Docling request timed out after ${timeoutMs}ms`
            : `Docling request failed: ${err instanceof Error ? err.message : String(err)}`,
        ),
      );
      return null;
    } finally {
      clearTimeout(timer);
    }
  }
}
