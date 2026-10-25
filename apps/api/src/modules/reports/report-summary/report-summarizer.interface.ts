/** Only these clinical fields may cross the report-summary provider boundary. */
export interface SummaryLabValue {
  parameterName: string;
  value: string;
  unit: string | null;
  referenceRange: string | null;
}

export interface SummaryProviderUsage {
  model: string;
  inputTokens: number;
  outputTokens: number;
}

export interface ReportSummarizer {
  /** Returns null when disabled, unsafe, or unavailable. Never sends a source file. */
  generateSummary(
    values: SummaryLabValue[],
    onUsage?: (usage: SummaryProviderUsage) => void,
  ): Promise<string | null>;
}
