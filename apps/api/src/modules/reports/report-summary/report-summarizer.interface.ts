export interface ReportSummarizer {
  /**
   * Generate a summary for the given PDF buffer.
   * Returns null if summarisation is disabled, misconfigured, or the provider fails.
   * Never throws.
   */
  generateSummary(pdfBuffer: Buffer): Promise<string | null>;
}
