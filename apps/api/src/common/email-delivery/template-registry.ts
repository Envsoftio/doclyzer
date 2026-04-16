export interface EmailTemplateDefinition {
  templateKey: string;
  subject: string;
}

export const EMAIL_TEMPLATE_REGISTRY: Record<string, EmailTemplateDefinition> =
  {
    'account.password_reset': {
      templateKey: 'password-reset',
      subject: 'Reset your Doclyzer password',
    },
    'account.email_changed': {
      templateKey: 'account-email-changed',
      subject: 'Your email address was updated',
    },
    'account.password_changed': {
      templateKey: 'account-password-changed',
      subject: 'Your password was changed',
    },
    'account.closure_confirmed': {
      templateKey: 'account-closure-confirmed',
      subject: 'Your account closure is confirmed',
    },
    'report.upload_complete': {
      templateKey: 'report-upload-complete',
      subject: 'Your report upload is complete',
    },
    'report.parse_failed': {
      templateKey: 'report-parse-failed',
      subject: 'We could not parse your report',
    },
    'billing.payment_success': {
      templateKey: 'billing-payment-success',
      subject: 'Payment received',
    },
    'billing.payment_failed': {
      templateKey: 'billing-payment-failed',
      subject: 'Payment failed',
    },
    'billing.subscription_activated': {
      templateKey: 'billing-subscription-activated',
      subject: 'Subscription activated',
    },
    'billing.subscription_cancelled': {
      templateKey: 'billing-subscription-cancelled',
      subject: 'Subscription cancelled',
    },
    announcement: {
      templateKey: 'admin-announcement',
      subject: 'Important update from Doclyzer',
    },
    incident: {
      templateKey: 'admin-incident',
      subject: 'Service incident update',
    },
    support: {
      templateKey: 'admin-support',
      subject: 'Support update from Doclyzer',
    },
  };
