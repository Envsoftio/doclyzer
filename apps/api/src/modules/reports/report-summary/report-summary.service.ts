import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { ReportSummarizer } from './report-summarizer.interface';

@Injectable()
export class ReportSummaryService implements ReportSummarizer {
  constructor(private readonly configService: ConfigService) {}

  async generateSummary(_pdfBuffer: Buffer): Promise<string | null> {
    // A PDF contains identity, contact details and demographics. Configuration
    // must never bypass this boundary. Restore summaries only with a typed,
    // locally validated clinical payload; never transmit the source document.
    return null;
  }
}
