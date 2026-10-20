import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Agent } from 'undici';
import type { OcrOutput } from './report-ocr-cascade';
import type { PaddleRaw, NativeWord } from './geometry/evidence';

export interface PaddlePageOutput extends OcrOutput {
  parsedJson: {
    type: 'document';
    kids: [];
    extractionIncomplete: true;
    paddlePage: {
      page_width: number;
      page_height: number;
      dpi: number;
      native_words: NativeWord[];
      paddle: PaddleRaw;
      model_version: string;
      paddleocr_version: string;
      docling_parse_version: string;
    };
  };
}

/** Page OCR supplies source evidence; it never fabricates Docling table cells. */
@Injectable()
export class PaddleOcrClient {
  private readonly log = new Logger(PaddleOcrClient.name);
  constructor(private readonly config: ConfigService) {}

  async parsePdf(buffer: Buffer, signal?: AbortSignal): Promise<PaddlePageOutput | null> {
    return this.extract(buffer, 'application/pdf', signal);
  }

  async parseImage(buffer: Buffer, contentType: 'image/jpeg' | 'image/png', signal?: AbortSignal): Promise<PaddlePageOutput | null> {
    return this.extract(buffer, contentType, signal);
  }

  private async extract(buffer: Buffer, contentType: 'application/pdf' | 'image/jpeg' | 'image/png', signal?: AbortSignal): Promise<PaddlePageOutput | null> {
    const base = this.config.get<string>('reports.paddleOcrBaseUrl');
    const key = this.config.get<string>('reports.paddleOcrApiKey');
    const timeout = this.config.get<number>('reports.paddleOcrTimeoutMs') ?? 65000;
    if (!base || !key || buffer.length > 10 * 1024 * 1024) return null;
    const dispatcher = new Agent({ headersTimeout: timeout, bodyTimeout: timeout });
    try {
      const response = await fetch(`${base.replace(/\/+$/, '')}/v1/extract/page`, {
        method: 'POST',
        headers: { 'content-type': contentType, 'x-api-key': key },
        body: new Uint8Array(buffer),
        signal: signal ? AbortSignal.any([signal, AbortSignal.timeout(timeout)]) : AbortSignal.timeout(timeout),
        dispatcher,
      } as RequestInit & { dispatcher: Agent });
      if (!response.ok) {
        this.log.warn(`PADDLE_OCR_PAGE_FAILED status=${response.status}`);
        return null;
      }
      const reader = response.body?.getReader();
      if (!reader) return null;
      const chunks: Buffer[] = [];
      let size = 0;
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        size += value.length;
        if (size > 5 * 1024 * 1024) {
          await reader.cancel();
          return null;
        }
        chunks.push(Buffer.from(value));
      }
      const raw = JSON.parse(Buffer.concat(chunks).toString('utf8')) as PaddlePageOutput['parsedJson']['paddlePage'];
      if (!raw || !Number.isFinite(raw.page_width) || !Number.isFinite(raw.page_height) ||
        !Number.isFinite(raw.dpi) || raw.dpi <= 0 ||
        !Array.isArray(raw.native_words) ||
        !Array.isArray(raw.paddle?.rec_texts) ||
        !Array.isArray(raw.paddle?.rec_scores) ||
        !Array.isArray(raw.paddle?.rec_polys) ||
        raw.paddle.rec_texts.length !== raw.paddle.rec_scores.length ||
        raw.paddle.rec_texts.length !== raw.paddle.rec_polys.length) return null;
      return {
        text: raw.paddle.rec_texts.join('\n'),
        parsedJson: { type: 'document', kids: [], extractionIncomplete: true, paddlePage: raw },
      };
    } catch (error) {
      signal?.throwIfAborted();
      this.log.warn(`PADDLE_OCR_REQUEST_FAILED reason=${error instanceof Error ? error.name : 'unknown'}`);
      return null;
    } finally {
      await dispatcher.destroy();
    }
  }
}
