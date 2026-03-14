import { NotFoundException } from '@nestjs/common';
import { REPORT_NOT_FOUND } from '../reports.types';

export class ReportNotFoundException extends NotFoundException {
  constructor() {
    super({
      code: REPORT_NOT_FOUND,
      message: 'Report not found',
    });
  }
}
