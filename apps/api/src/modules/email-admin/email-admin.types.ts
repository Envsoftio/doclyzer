import { BadRequestException } from '@nestjs/common';

export const EMAIL_ADMIN_INVALID_DATE_RANGE =
  'EMAIL_ADMIN_INVALID_DATE_RANGE';

export class EmailAdminInvalidDateRangeException extends BadRequestException {
  constructor(message: string) {
    super({
      code: EMAIL_ADMIN_INVALID_DATE_RANGE,
      message,
    });
  }
}

export interface EmailQueueStatusSnapshot {
  snapshotAt: string;
  counts: {
    pending: number;
    processing: number;
    completed: number;
  };
  total: number;
}

export interface EmailDeliveryAnalyticsByType {
  emailType: string;
  sent: number;
  failed: number;
  bounced: number;
}

export interface EmailDeliveryAnalyticsResponse {
  window: {
    start: string;
    end: string;
  };
  filters: {
    emailType: string | null;
    recipientScope: string | null;
  };
  totals: {
    sent: number;
    failed: number;
    bounced: number;
  };
  byType: EmailDeliveryAnalyticsByType[];
}

export interface EmailSendingHistoryItem {
  id: string;
  occurredAt: string;
  emailType: string;
  recipientScope: string;
  outcome: 'sent' | 'failed' | 'bounced';
}

export interface EmailSendingHistoryResponse {
  window: {
    start: string;
    end: string;
  };
  pagination: {
    page: number;
    pageSize: number;
    total: number;
    totalPages: number;
  };
  items: EmailSendingHistoryItem[];
}
