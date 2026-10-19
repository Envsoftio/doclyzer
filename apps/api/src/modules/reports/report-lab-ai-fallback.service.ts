import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
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
  constructor(private readonly configService: ConfigService) {}

  async tryExtract(input: TryExtractInput): Promise<TryExtractResult | null> {
    // Unstructured OCR rows can contain unlabeled identity data. A keyword
    // blacklist cannot establish anonymity, so fail closed even when enabled.
    return null;
  }
}
