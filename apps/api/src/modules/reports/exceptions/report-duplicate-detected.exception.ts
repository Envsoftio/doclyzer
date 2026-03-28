import { ConflictException } from '@nestjs/common';
import type { DuplicateReportInfo } from '../reports.types';
import { REPORT_DUPLICATE_DETECTED } from '../reports.types';

export class ReportDuplicateDetectedException extends ConflictException {
  constructor(existingReport: DuplicateReportInfo) {
    super({
      code: REPORT_DUPLICATE_DETECTED,
      message: 'A report with the same content already exists in this profile.',
      existingReport,
    });
  }
}
