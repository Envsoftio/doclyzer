import {
  BadRequestException,
  ForbiddenException,
  TooManyRequestsException,
} from '@nestjs/common';
import type { EmailDeliveryOutcome } from '../../database/entities/email-delivery-event.entity';

export const EMAIL_ADMIN_INVALID_DATE_RANGE =
  'EMAIL_ADMIN_INVALID_DATE_RANGE';
export const EMAIL_ADMIN_INVALID_SEND_REQUEST =
  'EMAIL_ADMIN_INVALID_SEND_REQUEST';
export const EMAIL_ADMIN_APPROVAL_REQUIRED =
  'EMAIL_ADMIN_APPROVAL_REQUIRED';
export const EMAIL_ADMIN_INVALID_APPROVAL_TOKEN =
  'EMAIL_ADMIN_INVALID_APPROVAL_TOKEN';
export const EMAIL_ADMIN_RATE_LIMIT_EXCEEDED =
  'EMAIL_ADMIN_RATE_LIMIT_EXCEEDED';

export class EmailAdminInvalidDateRangeException extends BadRequestException {
  constructor(message: string) {
    super({
      code: EMAIL_ADMIN_INVALID_DATE_RANGE,
      message,
    });
  }
}

export class EmailAdminInvalidSendRequestException extends BadRequestException {
  constructor(message: string) {
    super({
      code: EMAIL_ADMIN_INVALID_SEND_REQUEST,
      message,
    });
  }
}

export class EmailAdminApprovalRequiredException extends ForbiddenException {
  constructor(message: string) {
    super({
      code: EMAIL_ADMIN_APPROVAL_REQUIRED,
      message,
    });
  }
}

export class EmailAdminInvalidApprovalTokenException extends ForbiddenException {
  constructor(message: string) {
    super({
      code: EMAIL_ADMIN_INVALID_APPROVAL_TOKEN,
      message,
    });
  }
}

export class EmailAdminRateLimitExceededException extends TooManyRequestsException {
  constructor(message: string) {
    super({
      code: EMAIL_ADMIN_RATE_LIMIT_EXCEEDED,
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
  outcome: EmailDeliveryOutcome;
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

export type EmailAdminSendState = 'pending' | 'success' | 'failure' | 'reverted';

export interface EmailAdminSendResponse {
  state: EmailAdminSendState;
  emailType: string;
  recipientScope: string;
  queueItemId: string;
  deliveryEventId: string | null;
  requiresApproval: boolean;
  estimatedRecipientCount: number | null;
  acceptedAt: string;
}
