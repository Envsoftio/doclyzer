import { BadRequestException } from '@nestjs/common';

export class ReportUploadException extends BadRequestException {
  constructor(code: string, message: string) {
    super({ code, message });
  }
}
