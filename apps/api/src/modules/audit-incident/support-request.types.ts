import { BadRequestException } from '@nestjs/common';

export type SupportRequestStatus = 'open' | 'triaged' | 'resolved';

export const SUPPORT_REQUEST_STATUSES: SupportRequestStatus[] = [
  'open',
  'triaged',
  'resolved',
];

export type SupportActionType =
  | 'auth'
  | 'report_upload'
  | 'report_parse'
  | 'share_link_create'
  | 'share_link_revoke'
  | 'billing_entitlement'
  | 'billing_checkout'
  | 'notification_preferences'
  | 'account_profile_update';

export const SUPPORT_ACTION_TYPES: SupportActionType[] = [
  'auth',
  'report_upload',
  'report_parse',
  'share_link_create',
  'share_link_revoke',
  'billing_entitlement',
  'billing_checkout',
  'notification_preferences',
  'account_profile_update',
];

export interface SupportRequestListItem {
  id: string;
  userId: string;
  actionType: SupportActionType;
  correlationId: string;
  status: SupportRequestStatus;
  createdAt: string;
}

export interface SupportRequestDetail extends SupportRequestListItem {
  clientActionId: string | null;
  errorCode: string | null;
  errorMessage: string | null;
  entityIds: Record<string, string> | null;
  userMessage: string | null;
}

export interface SupportRequestListResult {
  items: SupportRequestListItem[];
  total: number;
  page: number;
  limit: number;
}

export enum SupportRequestErrorCode {
  SUPPORT_REQUEST_CONTEXT_REQUIRED = 'SUPPORT_REQUEST_CONTEXT_REQUIRED',
}

export class SupportRequestContextException extends BadRequestException {
  constructor(message?: string) {
    super({
      code: SupportRequestErrorCode.SUPPORT_REQUEST_CONTEXT_REQUIRED,
      message:
        message ??
        'Support request must include correlationId or clientActionId',
    });
  }
}
