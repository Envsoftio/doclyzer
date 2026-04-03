export interface EmailSendInput {
  to: string[];
  subject: string;
  html: string;
  text: string;
  fromName: string;
  fromAddress: string;
  metadata?: Record<string, string | number | boolean | null> | null;
}

export interface EmailSendResult {
  outcome: 'sent' | 'failed' | 'bounced';
  provider: string;
  providerMessageId: string | null;
  errorCode?: string | null;
}

export interface EmailProvider {
  send(input: EmailSendInput): Promise<EmailSendResult>;
}

export const EMAIL_PROVIDER = 'EMAIL_PROVIDER';
