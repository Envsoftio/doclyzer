import { ForbiddenException } from '@nestjs/common';
import { REPORT_LIMIT_EXCEEDED } from '../reports.types';

export interface ReportLimitExceededData {
  limit: number;
  current: number;
  planName: string;
  tier: string;
  upgradeHint: string;
}

export class ReportLimitExceededException extends ForbiddenException {
  constructor(data: ReportLimitExceededData) {
    const baseMessage =
      data.tier === 'free'
        ? `Free plan allows ${data.limit} reports. Upgrade to Pro for more.`
        : `${data.planName} plan allows ${data.limit} reports. Manage your plan in Billing.`;
    super({
      code: REPORT_LIMIT_EXCEEDED,
      message: baseMessage,
      data,
    });
  }
}
