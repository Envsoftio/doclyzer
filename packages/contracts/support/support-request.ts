export enum SupportActionType {
  AUTH = 'auth',
  REPORT_UPLOAD = 'report_upload',
  REPORT_PARSE = 'report_parse',
  SHARE_LINK_CREATE = 'share_link_create',
  SHARE_LINK_REVOKE = 'share_link_revoke',
  BILLING_ENTITLEMENT = 'billing_entitlement',
  BILLING_CHECKOUT = 'billing_checkout',
  NOTIFICATION_PREFERENCES = 'notification_preferences',
  ACCOUNT_PROFILE_UPDATE = 'account_profile_update',
}

export interface SupportRequestEntityIds {
  reportId?: string;
  shareLinkId?: string;
  profileId?: string;
}

export interface SupportRequestMetadata {
  appVersion?: string;
  platform?: string;
  surface?: string;
}

export interface SupportRequestContext {
  actionType: SupportActionType;
  correlationId?: string;
  clientActionId?: string;
  errorCode?: string;
  entityIds?: SupportRequestEntityIds;
  metadata?: SupportRequestMetadata;
}

export interface CreateSupportRequestPayload {
  context: SupportRequestContext;
  userMessage?: string;
  errorMessage?: string;
}

export interface SupportRequestResponse {
  id: string;
  correlationId: string;
}
