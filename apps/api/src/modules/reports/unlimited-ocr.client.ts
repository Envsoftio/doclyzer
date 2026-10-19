import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Agent } from 'undici';

@Injectable()
export class UnlimitedOcrClient {
  private readonly logger = new Logger(UnlimitedOcrClient.name);

  constructor(private readonly config: ConfigService) {}

  async parsePdf(
    buffer: Buffer,
    signal?: AbortSignal,
  ): Promise<{ text: string; parsedJson: unknown } | null> {
    if (!this.config.get<boolean>('reports.unlimitedOcrEnabled')) return null;
    const baseUrl = this.config.get<string>('reports.unlimitedOcrBaseUrl');
    if (!baseUrl) return null;
    const timeout =
      this.config.get<number>('reports.unlimitedOcrTimeoutMs') ?? 610000;
    const startedAt = Date.now();
    // AbortSignal alone does not override Node fetch's five-minute header timeout.
    const dispatcher = new Agent({
      headersTimeout: timeout,
      bodyTimeout: timeout,
    });
    try {
      const response = await fetch(
        `${baseUrl.replace(/\/+$/, '')}/v1/convert/pdf`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/pdf' },
          body: new Uint8Array(buffer),
          signal: signal
            ? AbortSignal.any([signal, AbortSignal.timeout(timeout)])
            : AbortSignal.timeout(timeout),
          dispatcher,
        } as RequestInit & { dispatcher: Agent },
      );
      if (!response.ok) {
        this.logger.warn(
          `Unlimited conversion failed: HTTP ${response.status}`,
        );
        return null;
      }
      const data = (await response.json()) as {
        engine?: unknown;
        adapterVersion?: unknown;
        text?: unknown;
        diagnostics?: { warnings?: unknown };
        parsedJson?: {
          type?: unknown;
          kids?: unknown;
          extractionIncomplete?: boolean;
        };
      };
      if (
        data.engine !== 'unlimited-ocr' ||
        data.adapterVersion !== 1 ||
        typeof data.text !== 'string' ||
        !data.text.trim() ||
        data.parsedJson?.type !== 'document' ||
        !Array.isArray(data.parsedJson.kids)
      ) {
        this.logger.warn('Unlimited returned an invalid document');
        return null;
      }
      const warnings = data.diagnostics?.warnings;
      if (Array.isArray(warnings) && warnings.length > 0) {
        this.logger.warn(
          'Unlimited found unresolved result rows; page requires review',
        );
        data.parsedJson.extractionIncomplete = true;
      }
      this.logger.log('UNLIMITED_OCR_CONVERSION_SUCCEEDED');
      return { text: data.text, parsedJson: data.parsedJson };
    } catch (error) {
      signal?.throwIfAborted();
      // Neither report contents nor backend response bodies belong in logs.
      const cause = error instanceof Error ? error.cause : null;
      const code =
        cause && typeof cause === 'object' && 'code' in cause
          ? String(cause.code)
          : error instanceof Error
            ? error.name
            : 'UNKNOWN';
      this.logger.warn(
        `Unlimited request failed code=${code} elapsedMs=${Date.now() - startedAt}; page requires review`,
      );
      return null;
    } finally {
      await dispatcher.destroy();
    }
  }
}
