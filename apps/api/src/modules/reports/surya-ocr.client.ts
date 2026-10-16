import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Agent } from 'undici';

@Injectable()
export class SuryaOcrClient {
  private readonly logger = new Logger(SuryaOcrClient.name);

  constructor(private readonly config: ConfigService) {}

  async parsePdf(
    buffer: Buffer,
  ): Promise<{ text: string; parsedJson: unknown } | null> {
    if (!this.config.get<boolean>('reports.suryaOcrEnabled')) return null;
    const baseUrl = this.config.get<string>('reports.suryaOcrBaseUrl');
    if (!baseUrl) return null;
    const timeout =
      this.config.get<number>('reports.suryaOcrTimeoutMs') ?? 610000;
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
          signal: AbortSignal.timeout(timeout),
          dispatcher,
        } as RequestInit & { dispatcher: Agent },
      );
      if (!response.ok) {
        this.logger.warn(`Surya conversion failed: HTTP ${response.status}`);
        return null;
      }
      const data = (await response.json()) as {
        text?: unknown;
        diagnostics?: { warnings?: unknown };
        parsedJson?: { type?: unknown; kids?: unknown };
      };
      if (
        typeof data.text !== 'string' ||
        !data.text.trim() ||
        data.parsedJson?.type !== 'document' ||
        !Array.isArray(data.parsedJson.kids)
      ) {
        this.logger.warn('Surya returned an invalid document');
        return null;
      }
      const warnings = data.diagnostics?.warnings;
      if (
        Array.isArray(warnings) &&
        warnings.some((w) => w !== 'flag_moved_from_unit')
      ) {
        this.logger.warn(
          'Surya found unresolved result rows; using OCR fallback',
        );
        return null;
      }
      return { text: data.text, parsedJson: data.parsedJson };
    } catch (error) {
      // Neither report contents nor backend response bodies belong in logs.
      const cause = error instanceof Error ? error.cause : null;
      const code =
        cause && typeof cause === 'object' && 'code' in cause
          ? String(cause.code)
          : error instanceof Error
            ? error.name
            : 'UNKNOWN';
      this.logger.warn(
        `Surya request failed code=${code} elapsedMs=${Date.now() - startedAt}; using OCR fallback`,
      );
      return null;
    } finally {
      await dispatcher.destroy();
    }
  }
}
