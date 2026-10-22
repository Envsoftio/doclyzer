import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { isDoclingDocument } from './docling-document-adapter';
import { redactSecrets } from '../../common/redact-secrets';

interface DoclingOptions {
  doOcr?: boolean;
  forceOcr?: boolean;
  engine?: 'auto' | 'rapidocr' | 'tesseract';
  signal?: AbortSignal;
}

interface MultipartPart {
  name: string;
  value: string | Buffer;
  filename?: string;
  contentType?: string;
}

@Injectable()
export class DoclingOcrClient {
  private readonly logger = new Logger(DoclingOcrClient.name);

  constructor(private readonly configService: ConfigService) {}

  async parsePdf(
    buffer: Buffer,
    options?: DoclingOptions,
  ): Promise<{ text: string; parsedJson?: unknown } | null> {
    const enabled =
      this.configService.get<boolean>('reports.doclingOcrEnabled') ?? false;
    if (!enabled) return null;

    const configuredBaseUrl =
      this.configService.get<string>('reports.doclingOcrBaseUrl') ??
      'http://127.0.0.1:5002';
    const timeoutMs =
      this.configService.get<number>('reports.doclingOcrTimeoutMs') ?? 180000;
    const ocrEngine =
      options?.engine ??
      this.configService.get<string>('reports.doclingOcrEngine') ??
      'tesseract';
    const languages = (
      (options?.engine
        ? ''
        : this.configService
            .get<string>('reports.doclingOcrLanguages')
            ?.trim()) || (ocrEngine.startsWith('tesser') ? 'eng' : '')
    )
      .split(',')
      .map((lang) => lang.trim())
      .filter(Boolean);
    const baseUrls = this.getBaseUrlCandidates(configuredBaseUrl);

    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);
    const signal = options?.signal
      ? AbortSignal.any([controller.signal, options.signal])
      : controller.signal;
    let lastError: string | null = null;

    try {
      for (const baseUrl of baseUrls) {
        if (signal.aborted) return null;
        const endpoint = `${baseUrl.replace(/\/+$/, '')}/v1/convert/file`;
        const callWithFields = async (): Promise<Response> => {
          const { body, contentType } = this.buildMultipartBody([
            {
              name: 'files',
              value: buffer,
              filename: 'report.pdf',
              contentType: 'application/pdf',
            },
            { name: 'to_formats', value: 'md' },
            { name: 'to_formats', value: 'json' },
            { name: 'from_formats', value: 'pdf' },
            { name: 'pipeline', value: 'standard' },
            { name: 'do_ocr', value: String(options?.doOcr !== false) },
            { name: 'pdf_backend', value: 'docling_parse' },
            { name: 'do_table_structure', value: 'true' },
            { name: 'table_structure_preset', value: 'tableformer_v1_accurate' },
            { name: 'table_mode', value: 'accurate' },
            { name: 'table_cell_matching', value: 'true' },
            {
              name: 'force_ocr',
              value: options?.forceOcr ? 'true' : 'false',
            },
            {
              name: 'ocr_preset',
              value: ocrEngine === 'tesseract' ? 'tesseract-table' : ocrEngine,
            },
            ...languages.map((value) => ({ name: 'ocr_lang', value })),
            { name: 'return_as_file', value: 'false' },
          ]);
          return fetch(endpoint, {
            method: 'POST',
            body: new Uint8Array(body),
            headers: {
              'Content-Type': contentType,
              'Content-Length': String(body.length),
              ...(this.configService.get<string>('DOCLING_API_KEY')
                ? {
                    'X-Api-Key':
                      this.configService.get<string>('DOCLING_API_KEY')!,
                  }
                : {}),
            },
            signal,
          });
        };

        try {
          const response = await this.callWithRetry(callWithFields, 2);
          if (!response.ok) {
            this.logger.warn(
              `Docling conversion failed status=${response.status} engine=${ocrEngine}`,
            );
            // Never retry an engine-specific request with another request schema:
            // ignored options could silently run the default engine twice.
            return null;
          }
          const data = (await response.json()) as unknown;
          this.logger.log(
            JSON.stringify({
              action: 'DOCLING_OCR_RESPONSE_SHAPE_DEBUG',
              endpoint,
              shape: this.describeShape(data),
            }),
          );
          const { text, parsedJson } = this.extractOutputs(data);
          this.logger.log(
            JSON.stringify({
              action: 'DOCLING_OCR_RESULT',
              endpoint,
              engine: options?.doOcr === false ? 'native' : ocrEngine,
              hasText: text.length > 0,
              textChars: text.length,
              hasJson: Boolean(parsedJson),
            }),
          );
          return { text, ...(parsedJson ? { parsedJson } : {}) };
        } catch (err) {
          const cause =
            err && typeof err === 'object' && 'cause' in err
              ? String((err as { cause?: unknown }).cause)
              : '';
          lastError = `${err instanceof Error ? err.message : String(err)} cause=${cause} endpoint=${endpoint}`;
          this.logger.warn(
            redactSecrets(
              `Docling OCR base URL attempt failed: baseUrl=${baseUrl} error=${lastError}`,
            ),
          );
        }
      }
      if (lastError) {
        this.logger.warn(
          redactSecrets(`Docling OCR exhausted base URLs: ${lastError}`),
        );
      }
      return null;
    } catch (err) {
      const isAbort = err instanceof Error && err.name === 'AbortError';
      const cause =
        err && typeof err === 'object' && 'cause' in err
          ? String((err as { cause?: unknown }).cause)
          : '';
      this.logger.warn(
        redactSecrets(
          isAbort
            ? `Docling OCR timed out after ${timeoutMs}ms`
            : `Docling OCR request failed: ${err instanceof Error ? err.message : String(err)} baseUrls=${baseUrls.join(',')} cause=${cause}`,
        ),
      );
      return null;
    } finally {
      clearTimeout(timer);
    }
  }

  private getBaseUrlCandidates(configuredBaseUrl: string): string[] {
    const candidates = [
      configuredBaseUrl,
      'http://127.0.0.1:5002',
      'http://localhost:5002',
      'http://docling:5002',
    ];
    return Array.from(new Set(candidates.map((u) => u.replace(/\/+$/, ''))));
  }

  private buildMultipartBody(parts: MultipartPart[]): {
    body: Buffer;
    contentType: string;
  } {
    const boundary = `----doclyzer-${Date.now()}-${Math.random().toString(16).slice(2)}`;
    const chunks: Buffer[] = [];
    for (const part of parts) {
      const headerLines: string[] = [`--${boundary}`];
      const escapedName = part.name.replace(/"/g, '\\"');
      if (part.filename) {
        const escapedFilename = part.filename.replace(/"/g, '\\"');
        headerLines.push(
          `Content-Disposition: form-data; name="${escapedName}"; filename="${escapedFilename}"`,
        );
        headerLines.push(
          `Content-Type: ${part.contentType ?? 'application/octet-stream'}`,
        );
      } else {
        headerLines.push(
          `Content-Disposition: form-data; name="${escapedName}"`,
        );
      }
      headerLines.push('');
      chunks.push(Buffer.from(`${headerLines.join('\r\n')}\r\n`, 'utf8'));
      if (Buffer.isBuffer(part.value)) {
        chunks.push(part.value);
      } else {
        chunks.push(Buffer.from(part.value, 'utf8'));
      }
      chunks.push(Buffer.from('\r\n', 'utf8'));
    }
    chunks.push(Buffer.from(`--${boundary}--\r\n`, 'utf8'));
    return {
      body: Buffer.concat(chunks),
      contentType: `multipart/form-data; boundary=${boundary}`,
    };
  }

  private async callWithRetry(
    fn: () => Promise<Response>,
    maxAttempts: number,
  ): Promise<Response> {
    let lastError: unknown;
    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await fn();
      } catch (err) {
        lastError = err;
        this.logger.warn(
          redactSecrets(
            `Docling OCR request attempt ${attempt}/${maxAttempts} failed: ${err instanceof Error ? err.message : String(err)}`,
          ),
        );
        if (attempt < maxAttempts) {
          await new Promise((resolve) => setTimeout(resolve, 700 * attempt));
        }
      }
    }
    throw lastError instanceof Error ? lastError : new Error(String(lastError));
  }

  private async readBodyPreview(response: Response): Promise<string> {
    try {
      const text = await response.text();
      if (!text) return '';
      return text.slice(0, 3000);
    } catch {
      return '';
    }
  }

  private extractOutputs(data: unknown): {
    text: string;
    parsedJson?: unknown;
  } {
    const readPath = (obj: unknown, path: string[]): unknown => {
      let cur = obj as Record<string, unknown> | undefined;
      for (const key of path) {
        if (!cur || typeof cur !== 'object' || !(key in cur)) return undefined;
        cur = cur[key] as Record<string, unknown>;
      }
      return cur;
    };

    // HTTP 200 can still carry a failed or partially failed conversion.
    const status = readPath(data, ['status']);
    if (typeof status === 'string' && status !== 'success') return { text: '' };
    const mdCandidates: unknown[] = [
      readPath(data, ['document', 'md_content']),
      readPath(data, ['document_result', 'output', 'md']),
      readPath(data, ['document_result', 'output', 'markdown']),
      readPath(data, ['output', 'md']),
      readPath(data, ['output', 'markdown']),
      readPath(data, ['md']),
      readPath(data, ['markdown']),
      readPath(data, ['result', 'output', 'md']),
      readPath(data, ['result', 'output', 'markdown']),
      readPath(data, ['document_result', 'md']),
      readPath(data, ['document_result', 'markdown']),
    ];
    const jsonCandidates: unknown[] = [
      readPath(data, ['document', 'json_content']),
      readPath(data, ['document']),
      readPath(data, ['document_result', 'output', 'json']),
      readPath(data, ['output', 'json']),
      readPath(data, ['json']),
      readPath(data, ['result', 'output', 'json']),
      readPath(data, ['document_result', 'output', 'json_docling']),
      readPath(data, ['output', 'json_docling']),
      readPath(data, ['document_result', 'json']),
      readPath(data, ['document_result', 'json_docling']),
    ];

    const text = this.findFirstMarkdownLike(data, mdCandidates);
    const parsedJson = this.findFirstDoclingJsonLike(data, jsonCandidates);
    return {
      text,
      ...(parsedJson ? { parsedJson } : {}),
    };
  }

  private findFirstMarkdownLike(data: unknown, seeded: unknown[]): string {
    for (const v of seeded) {
      if (typeof v === 'string' && v.trim().length > 0) return v;
    }
    const stack: unknown[] = [data];
    while (stack.length > 0) {
      const cur = stack.pop();
      if (!cur) continue;
      if (Array.isArray(cur)) {
        for (const item of cur) stack.push(item);
        continue;
      }
      if (typeof cur !== 'object') continue;
      const obj = cur as Record<string, unknown>;
      for (const [k, v] of Object.entries(obj)) {
        if (
          typeof v === 'string' &&
          /^(md|markdown)$/i.test(k) &&
          v.trim().length > 0
        ) {
          return v;
        }
        stack.push(v);
      }
    }
    return this.extractTextFallback(data) ?? '';
  }

  private findFirstDoclingJsonLike(data: unknown, seeded: unknown[]): unknown {
    for (const v of seeded) {
      if (isDoclingDocument(v)) return v;
      if (
        v &&
        typeof v === 'object' &&
        Array.isArray((v as Record<string, unknown>).kids)
      )
        return v;
    }
    const stack: unknown[] = [data];
    while (stack.length > 0) {
      const cur = stack.pop();
      if (!cur) continue;
      if (Array.isArray(cur)) {
        for (const item of cur) stack.push(item);
        continue;
      }
      if (typeof cur !== 'object') continue;
      const obj = cur as Record<string, unknown>;
      if (isDoclingDocument(obj)) return obj;
      if (Array.isArray(obj.kids) || Array.isArray(obj['list items'])) {
        return obj;
      }
      for (const [k, v] of Object.entries(obj)) {
        if (
          (k === 'json' || k === 'json_docling' || k === 'json_content') &&
          v &&
          typeof v === 'object'
        ) {
          return v;
        }
        stack.push(v);
      }
    }
    return undefined;
  }

  private extractTextFallback(data: unknown): string | null {
    const out: string[] = [];
    const walk = (node: unknown): void => {
      if (!node) return;
      if (Array.isArray(node)) {
        for (const item of node) walk(item);
        return;
      }
      if (typeof node === 'object') {
        const obj = node as Record<string, unknown>;
        if (typeof obj.text === 'string') {
          const s = obj.text.trim();
          if (s.length > 0) out.push(s);
        }
        if (typeof obj.content === 'string') {
          const s = obj.content.trim();
          if (s.length > 0) out.push(s);
        }
        for (const v of Object.values(obj)) walk(v);
      }
    };
    walk(data);
    const merged = out
      .filter(Boolean)
      .filter((line) => !/^#\/(texts|groups|tables|pictures)\//i.test(line))
      .filter(
        (line) => !/^(TOPLEFT|BOTTOMLEFT|_root_|unspecified)$/i.test(line),
      )
      .join('\n')
      .trim();
    return merged.length > 0 ? merged : null;
  }

  private safeForLog(value: unknown): unknown {
    try {
      const serialized = JSON.stringify(value);
      if (!serialized) return value;
      const limit = 15000;
      if (serialized.length <= limit) return JSON.parse(serialized);
      return {
        truncated: true,
        totalChars: serialized.length,
        preview: serialized.slice(0, limit),
      };
    } catch {
      return { unserializable: true };
    }
  }

  private describeShape(data: unknown): unknown {
    if (!data || typeof data !== 'object') return { type: typeof data };
    const root = data as Record<string, unknown>;
    const keys = Object.keys(root).slice(0, 40);
    const output = root.output as Record<string, unknown> | undefined;
    const documentResult = root.document_result as
      | Record<string, unknown>
      | undefined;
    return {
      rootKeys: keys,
      hasOutput: Boolean(output && typeof output === 'object'),
      outputKeys:
        output && typeof output === 'object'
          ? Object.keys(output).slice(0, 20)
          : [],
      hasDocumentResult: Boolean(
        documentResult && typeof documentResult === 'object',
      ),
      documentResultKeys:
        documentResult && typeof documentResult === 'object'
          ? Object.keys(documentResult).slice(0, 20)
          : [],
    };
  }
}
