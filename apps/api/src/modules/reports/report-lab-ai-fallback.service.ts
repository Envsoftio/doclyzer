import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { redactSecrets } from '../../common/redact-secrets';
import type { ExtractedLabValue } from './lab-value-extractor';

interface TryExtractInput {
  reportId: string;
  trigger: 'upload' | 'retry';
  confidence: number;
  lowConfidenceReasons: string[];
  candidateRows: string[];
}

interface TryExtractResult {
  extractedLabValues: ExtractedLabValue[];
  source: 'ai_fallback';
}

@Injectable()
export class ReportLabAiFallbackService {
  private readonly logger = new Logger(ReportLabAiFallbackService.name);
  private static readonly MAX_ROWS = 400;

  constructor(private readonly configService: ConfigService) {}

  async tryExtract(input: TryExtractInput): Promise<TryExtractResult | null> {
    const enabled =
      this.configService.get<boolean>('reports.labAiFallbackEnabled') ?? false;
    if (!enabled) return null;

    const minConfidence =
      this.configService.get<number>('reports.labAiFallbackMinConfidence') ??
      0.72;
    if (input.confidence >= minConfidence) return null;

    const sanitizedRows = this.sanitizeRowsForTransport(input.candidateRows);
    if (sanitizedRows.length === 0) {
      this.logger.warn(
        `Lab AI fallback skipped for reportId=${input.reportId}: no safe candidate rows after sanitization`,
      );
      return null;
    }

    const timeoutMs =
      this.configService.get<number>('reports.labAiFallbackTimeoutMs') ??
      10_000;
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeoutMs);

    try {
      const data = await this.callOpenAiProvider(
        input,
        sanitizedRows,
        controller.signal,
      );
      if (!data) return null;

      const extracted = this.parseResponseRows(data);
      if (extracted.length === 0) {
        this.logger.warn(
          `Lab AI fallback produced no valid rows for reportId=${input.reportId}`,
        );
        return null;
      }

      this.logger.log(
        JSON.stringify({
          action: 'REPORT_LAB_AI_FALLBACK_USED',
          reportId: input.reportId,
          trigger: input.trigger,
          confidence: input.confidence,
          candidateRows: sanitizedRows.length,
          extractedRows: extracted.length,
        }),
      );

      return { extractedLabValues: extracted, source: 'ai_fallback' };
    } catch (err) {
      const isAbort = err instanceof Error && err.name === 'AbortError';
      this.logger.warn(
        redactSecrets(
          isAbort
            ? `Lab AI fallback timed out after ${timeoutMs}ms`
            : `Lab AI fallback request failed: ${err instanceof Error ? err.message : String(err)}`,
        ),
      );
      return null;
    } finally {
      clearTimeout(timer);
    }
  }

  private async callOpenAiProvider(
    input: TryExtractInput,
    sanitizedRows: string[],
    signal: AbortSignal,
  ): Promise<unknown | null> {
    const apiKey =
      this.configService.get<string>('reports.labAiFallbackOpenaiApiKey') ?? '';
    if (!apiKey) {
      this.logger.warn(
        redactSecrets(
          'Lab AI fallback provider=openai but REPORT_LAB_AI_FALLBACK_OPENAI_API_KEY is not set',
        ),
      );
      return null;
    }

    const model =
      this.configService.get<string>('reports.labAiFallbackOpenaiModel') ??
      'gpt-5-mini';
    const baseUrl =
      this.configService.get<string>('reports.labAiFallbackOpenaiBaseUrl') ??
      'https://api.openai.com/v1';
    const endpoint = `${baseUrl.replace(/\/+$/, '')}/responses`;

    const schema = {
      type: 'object',
      additionalProperties: false,
      properties: {
        rows: {
          type: 'array',
          items: {
            type: 'object',
            additionalProperties: false,
            properties: {
              parameterName: { type: 'string' },
              value: { type: 'string' },
              unit: { type: 'string' },
              referenceRange: { type: 'string' },
              sampleDate: { type: 'string' },
            },
            required: [
              'parameterName',
              'value',
              'unit',
              'referenceRange',
              'sampleDate',
            ],
          },
        },
      },
      required: ['rows'],
    };

    const prompt = JSON.stringify(
      this.buildProviderPayload(input, sanitizedRows),
    );
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model,
        instructions:
          'Extract lab test rows from sanitized lab table snippets. Never infer patient identity. Return only JSON matching schema. If unit, referenceRange or sampleDate is unknown, return empty string.',
        input: `Payload:\n${prompt}`,
        text: {
          format: {
            type: 'json_schema',
            name: 'lab_rows',
            schema,
            strict: true,
          },
        },
      }),
      signal,
    });

    if (!response.ok) {
      this.logger.warn(
        redactSecrets(
          `Lab AI fallback (openai) returned non-OK status=${response.status} reportId=${input.reportId}`,
        ),
      );
      return null;
    }
    return response.json();
  }

  private buildProviderPayload(
    input: TryExtractInput,
    sanitizedRows: string[],
  ): Record<string, unknown> {
    return {
      reportId: input.reportId,
      trigger: input.trigger,
      confidence: input.confidence,
      lowConfidenceReasons: input.lowConfidenceReasons,
      piiPolicy: {
        containsPatientIdentity: false,
        note: 'Rows contain only sanitized lab table snippets.',
      },
      rows: sanitizedRows,
      outputSchema: {
        items: [
          {
            parameterName: 'string',
            value: 'string',
            unit: 'string',
            referenceRange: 'string',
            sampleDate: 'string',
          },
        ],
      },
    };
  }

  private sanitizeRowsForTransport(rows: string[]): string[] {
    const out: string[] = [];
    const seen = new Set<string>();
    for (const row of rows) {
      const cleaned = row.replace(/\s+/g, ' ').trim();
      if (!cleaned) continue;
      if (cleaned.length > 160) continue;
      const l = cleaned.toLowerCase();
      if (
        /\b(patient|name|age\/gender|mobile|phone|address|email|booking id|order id|barcode|referred by|sample collected on|sample received on|report generated on|customer since|sin no)\b/.test(
          l,
        )
      ) {
        continue;
      }
      const key = cleaned.toLowerCase();
      if (seen.has(key)) continue;
      seen.add(key);
      out.push(cleaned);
      if (out.length >= ReportLabAiFallbackService.MAX_ROWS) break;
    }
    return out;
  }

  private parseResponseRows(data: unknown): ExtractedLabValue[] {
    let rawRows = this.collectRows(data);
    if (rawRows.length === 0) {
      const text = this.extractTextFromResponse(data);
      const parsed = text ? this.tryParseJsonObject(text) : null;
      if (parsed) {
        rawRows = this.collectRows(parsed);
      }
    }
    const out: ExtractedLabValue[] = [];
    const seen = new Set<string>();

    for (const raw of rawRows) {
      const parameterName = this.readFirstString(raw, [
        'parameterName',
        'testName',
        'name',
        'parameter',
      ]);
      const value = this.readFirstString(raw, ['value', 'result']);
      const unit = this.readFirstString(raw, ['unit', 'units']);
      const referenceRange = this.readFirstString(raw, [
        'referenceRange',
        'normalRange',
        'range',
      ]);
      const sampleDate = this.readFirstString(raw, ['sampleDate', 'date']);

      if (!parameterName || !value) continue;
      const normalizedName = this.normalizeText(parameterName);
      const normalizedValue = this.normalizeValue(value);
      const normalizedUnit = unit ? this.normalizeText(unit) : null;
      const normalizedReferenceRange = referenceRange
        ? this.normalizeText(referenceRange)
        : null;
      const normalizedSampleDate = sampleDate
        ? this.normalizeText(sampleDate)
        : null;

      if (!this.isLikelyLabName(normalizedName)) continue;
      if (!this.isLikelyLabValue(normalizedValue)) continue;
      if (normalizedUnit && normalizedUnit.length > 24) continue;

      const key = `${normalizedName.toLowerCase()}::${normalizedValue.toLowerCase()}::${(normalizedUnit ?? '').toLowerCase()}`;
      if (seen.has(key)) continue;
      seen.add(key);

      out.push({
        parameterName: normalizedName,
        value: normalizedValue,
        unit: normalizedUnit,
        ...(normalizedReferenceRange
          ? { referenceRange: normalizedReferenceRange }
          : {}),
        sampleDate: normalizedSampleDate,
      });
    }

    return out;
  }

  private extractTextFromResponse(data: unknown): string | null {
    if (!data || typeof data !== 'object') return null;
    const root = data as Record<string, unknown>;

    if (typeof root.output_text === 'string' && root.output_text.trim()) {
      return root.output_text.trim();
    }

    if (Array.isArray(root.output)) {
      for (const item of root.output) {
        if (!item || typeof item !== 'object') continue;
        const obj = item as Record<string, unknown>;
        if (!Array.isArray(obj.content)) continue;
        for (const c of obj.content) {
          if (!c || typeof c !== 'object') continue;
          const contentObj = c as Record<string, unknown>;
          const text =
            typeof contentObj.text === 'string'
              ? contentObj.text
              : typeof contentObj.output_text === 'string'
                ? contentObj.output_text
                : null;
          if (text && text.trim()) return text.trim();
        }
      }
    }

    if (Array.isArray(root.choices) && root.choices.length > 0) {
      const first = root.choices[0];
      if (first && typeof first === 'object') {
        const choice = first as Record<string, unknown>;
        const message =
          choice.message && typeof choice.message === 'object'
            ? (choice.message as Record<string, unknown>)
            : null;
        const content =
          message && typeof message.content === 'string'
            ? message.content
            : null;
        if (content && content.trim()) return content.trim();
      }
    }

    return null;
  }

  private tryParseJsonObject(text: string): unknown | null {
    const direct = this.safeJsonParse(text);
    if (direct) return direct;

    const start = text.indexOf('{');
    const end = text.lastIndexOf('}');
    if (start === -1 || end === -1 || end <= start) return null;
    const slice = text.slice(start, end + 1);
    return this.safeJsonParse(slice);
  }

  private safeJsonParse(text: string): unknown | null {
    try {
      return JSON.parse(text);
    } catch {
      return null;
    }
  }

  private collectRows(data: unknown): Array<Record<string, unknown>> {
    const out: Array<Record<string, unknown>> = [];

    const walk = (node: unknown): void => {
      if (!node) return;
      if (Array.isArray(node)) {
        for (const item of node) walk(item);
        return;
      }
      if (typeof node !== 'object') return;

      const obj = node as Record<string, unknown>;
      const hasName =
        typeof obj.parameterName === 'string' ||
        typeof obj.testName === 'string' ||
        typeof obj.name === 'string' ||
        typeof obj.parameter === 'string';
      const hasValue =
        typeof obj.value === 'string' || typeof obj.result === 'string';

      if (hasName && hasValue) {
        out.push(obj);
      }

      for (const value of Object.values(obj)) {
        walk(value);
      }
    };

    walk(data);
    return out;
  }

  private readFirstString(
    obj: Record<string, unknown>,
    keys: string[],
  ): string | null {
    for (const key of keys) {
      const value = obj[key];
      if (typeof value === 'string' && value.trim().length > 0) {
        return value.trim();
      }
    }
    return null;
  }

  private normalizeText(value: string): string {
    return value.replace(/\s+/g, ' ').trim();
  }

  private normalizeValue(value: string): string {
    const cleaned = value.replace(/\s+/g, ' ').trim();
    if (/^[<>]?\s*[-+]?\d[\d,]*(?:\.\d+)?$/.test(cleaned)) {
      return cleaned.replace(/[,\s]+/g, '');
    }
    return cleaned;
  }

  private isLikelyLabName(name: string): boolean {
    const n = name.toLowerCase();
    if (name.length < 2 || name.length > 100) return false;
    if (
      /\b(patient|booking|order id|sample|report|summary|suggestion|page \d|sin no|barcode|method|reference)\b/.test(
        n,
      )
    ) {
      return false;
    }
    return /[a-z]/i.test(name);
  }

  private isLikelyLabValue(value: string): boolean {
    const v = value.toLowerCase();
    if (!value || value.length > 40) return false;
    if (/^[<>]?\s*[-+]?\d[\d,]*(?:\.\d+)?$/.test(value)) return true;
    return /^(negative|positive|nil|normal|absent|present|clear|cloudy|turbid|trace|pale yellow|yellow|amber|straw)$/i.test(
      v,
    );
  }
}
