import { Injectable, Logger } from '@nestjs/common';
import { NotificationService } from './notification.service';

@Injectable()
export class InMemoryNotificationService extends NotificationService {
  private readonly logger = new Logger(InMemoryNotificationService.name);
  private readonly deliveries = new Map<string, string>();

  sendPasswordResetToken(email: string, rawToken: string): Promise<void> {
    this.deliveries.set(email.trim().toLowerCase(), rawToken);
    this.logger.log(
      `[DEV-STUB] Password reset token queued for delivery to ${email}`,
    );
    // Production: replace this class with an implementation that calls an
    // email/SMS service (e.g., SendGrid, AWS SES, Twilio).
    return Promise.resolve();
  }

  /** Test/dev utility — retrieve the last token "delivered" to an email. */
  getLastTokenForEmail(email: string): string | undefined {
    return this.deliveries.get(email.trim().toLowerCase());
  }
}
