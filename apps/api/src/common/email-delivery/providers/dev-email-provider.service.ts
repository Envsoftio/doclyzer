import { Injectable } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import type {
  EmailProvider,
  EmailSendInput,
  EmailSendResult,
} from '../email-provider.interface';

@Injectable()
export class DevEmailProviderService implements EmailProvider {
  send(input: EmailSendInput): Promise<EmailSendResult> {
    void input;
    return Promise.resolve({
      outcome: 'sent',
      provider: 'dev-stub',
      providerMessageId: randomUUID(),
      errorCode: null,
    });
  }
}
