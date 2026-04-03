import { Injectable } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import type {
  EmailProvider,
  EmailSendInput,
  EmailSendResult,
} from '../email-provider.interface';

@Injectable()
export class DevEmailProviderService implements EmailProvider {
  async send(_input: EmailSendInput): Promise<EmailSendResult> {
    return {
      outcome: 'sent',
      provider: 'dev-stub',
      providerMessageId: randomUUID(),
      errorCode: null,
    };
  }
}
