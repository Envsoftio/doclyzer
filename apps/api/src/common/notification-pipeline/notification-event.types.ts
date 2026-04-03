export enum NotifiableEventType {
  ACCOUNT_EMAIL_CHANGED = 'ACCOUNT_EMAIL_CHANGED',
  ACCOUNT_PASSWORD_CHANGED = 'ACCOUNT_PASSWORD_CHANGED',
  ACCOUNT_CLOSURE_CONFIRMED = 'ACCOUNT_CLOSURE_CONFIRMED',
  REPORT_UPLOAD_COMPLETE = 'REPORT_UPLOAD_COMPLETE',
  REPORT_PARSE_FAILED = 'REPORT_PARSE_FAILED',
  BILLING_PAYMENT_SUCCESS = 'BILLING_PAYMENT_SUCCESS',
  BILLING_PAYMENT_FAILED = 'BILLING_PAYMENT_FAILED',
  SUBSCRIPTION_ACTIVATED = 'SUBSCRIPTION_ACTIVATED',
  SUBSCRIPTION_CANCELLED = 'SUBSCRIPTION_CANCELLED',
}

export type NotificationCategory = 'security' | 'compliance' | 'product';

export const EVENT_CATEGORY_MAP: Record<
  NotifiableEventType,
  { category: NotificationCategory; emailType: string }
> = {
  [NotifiableEventType.REPORT_UPLOAD_COMPLETE]: {
    category: 'product',
    emailType: 'report.upload_complete',
  },
  [NotifiableEventType.REPORT_PARSE_FAILED]: {
    category: 'product',
    emailType: 'report.parse_failed',
  },
  [NotifiableEventType.BILLING_PAYMENT_SUCCESS]: {
    category: 'product',
    emailType: 'billing.payment_success',
  },
  [NotifiableEventType.BILLING_PAYMENT_FAILED]: {
    category: 'product',
    emailType: 'billing.payment_failed',
  },
  [NotifiableEventType.SUBSCRIPTION_ACTIVATED]: {
    category: 'product',
    emailType: 'billing.subscription_activated',
  },
  [NotifiableEventType.SUBSCRIPTION_CANCELLED]: {
    category: 'product',
    emailType: 'billing.subscription_cancelled',
  },
  [NotifiableEventType.ACCOUNT_EMAIL_CHANGED]: {
    category: 'security',
    emailType: 'account.email_changed',
  },
  [NotifiableEventType.ACCOUNT_PASSWORD_CHANGED]: {
    category: 'security',
    emailType: 'account.password_changed',
  },
  [NotifiableEventType.ACCOUNT_CLOSURE_CONFIRMED]: {
    category: 'compliance',
    emailType: 'account.closure_confirmed',
  },
};

export const MANDATORY_NOTIFICATION_CATEGORIES: ReadonlySet<NotificationCategory> =
  new Set(['security', 'compliance']);
