import { ServiceUnavailableException } from '@nestjs/common';
import { REPORT_FILE_UNAVAILABLE } from '../reports.types';

export class ReportFileUnavailableException extends ServiceUnavailableException {
  constructor() {
    super({
      code: REPORT_FILE_UNAVAILABLE,
      message: 'Report file is no longer available in storage.',
    });
  }
}
