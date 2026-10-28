import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  applicationDefault,
  cert,
  getApps,
  initializeApp,
} from 'firebase-admin/app';
import { getMessaging, Message } from 'firebase-admin/messaging';
import { randomUUID } from 'node:crypto';
import type { PushConfig } from '../../config/push.config';

export interface PushProviderMessage {
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
  deepLink?: string | null;
  imageUrl?: string | null;
  category?: string;
  collapseId?: string;
  expiresAt?: Date;
}
export interface PushProviderResult {
  outcome: 'sent' | 'failed';
  provider: string;
  providerMessageId: string | null;
  errorCode: string | null;
  errorMessage: string | null;
  retryAfterMs?: number;
}
export interface PushProvider {
  send(message: PushProviderMessage): Promise<PushProviderResult>;
}
export function isRetryablePushFailure(code: string | null): boolean {
  return [
    'UNAVAILABLE',
    'INTERNAL',
    'QUOTA_EXCEEDED',
    'FCM_SEND_FAILED',
    'messaging/server-unavailable',
    'messaging/internal-error',
    'messaging/quota-exceeded',
    'messaging/message-rate-exceeded',
    'messaging/device-message-rate-exceeded',
    'app/network-error',
    'app/network-timeout',
  ].includes(code ?? '');
}
export function isInvalidPushToken(code: string | null): boolean {
  return [
    'UNREGISTERED',
    'messaging/registration-token-not-registered',
    'messaging/invalid-registration-token',
  ].includes(code ?? '');
}
@Injectable()
export class PushProviderService implements PushProvider {
  private readonly logger = new Logger(PushProviderService.name);
  constructor(private readonly config: ConfigService) {}
  get providerName(): string {
    return this.config.get<PushConfig>('push')?.provider ?? 'mock';
  }
  async send(message: PushProviderMessage): Promise<PushProviderResult> {
    if (this.providerName === 'mock') {
      if (this.config.get<string>('NODE_ENV') === 'production')
        return this.failure('PUSH_NOT_CONFIGURED');
      return {
        outcome: 'sent',
        provider: 'mock',
        providerMessageId: `mock_${randomUUID()}`,
        errorCode: null,
        errorMessage: null,
      };
    }
    try {
      const push = this.config.getOrThrow<PushConfig>('push');
      const app =
        getApps().find((a) => a.name === 'doclyzer-push') ??
        initializeApp(
          {
            projectId: push.fcm.projectId || undefined,
            credential:
              push.fcm.clientEmail && push.fcm.privateKey
                ? cert({
                    projectId: push.fcm.projectId,
                    clientEmail: push.fcm.clientEmail,
                    privateKey: push.fcm.privateKey,
                  })
                : applicationDefault(),
          },
          'doclyzer-push',
        );
      const marketing = [
        'marketing',
        'product',
        'referrals',
        'admin_announcements',
      ].includes(message.category ?? message.data?.category ?? '');
      const payload: Message = {
        token: message.token,
        notification: {
          title: message.title,
          body: message.body,
          ...(message.imageUrl ? { imageUrl: message.imageUrl } : {}),
        },
        data: message.data ?? {},
        fcmOptions: {
          analyticsLabel: marketing ? 'marketing' : 'transactional',
        },
        android: {
          priority: marketing ? 'normal' : 'high',
          ...(message.expiresAt
            ? { ttl: Math.max(0, message.expiresAt.getTime() - Date.now()) }
            : {}),
          notification: {
            channelId: marketing ? 'marketing' : 'transactional_high',
            icon: 'ic_stat_doclyzer',
            ...(message.collapseId ? { tag: message.collapseId } : {}),
          },
        },
        apns: {
          headers: {
            'apns-push-type': 'alert',
            'apns-priority': marketing ? '5' : '10',
            ...(message.collapseId
              ? { 'apns-collapse-id': message.collapseId }
              : {}),
            ...(message.expiresAt
              ? {
                  'apns-expiration': String(
                    Math.floor(message.expiresAt.getTime() / 1000),
                  ),
                }
              : {}),
          },
          payload: { aps: { sound: 'default' } },
        },
      };
      const providerMessageId = await getMessaging(app).send(payload);
      return {
        outcome: 'sent',
        provider: 'fcm',
        providerMessageId,
        errorCode: null,
        errorMessage: null,
      };
    } catch (error) {
      const code = (error as { code?: string }).code ?? 'FCM_SEND_FAILED';
      this.logger.warn(
        JSON.stringify({
          action: 'PUSH_PROVIDER_FAILURE',
          provider: 'fcm',
          errorCode: code,
        }),
      );
      return this.failure(code);
    }
  }
  async sendBatch(
    messages: PushProviderMessage[],
  ): Promise<PushProviderResult[]> {
    // Bound concurrency independently of the SDK's multicast limit.
    const results: PushProviderResult[] = [];
    for (let i = 0; i < messages.length; i += 10)
      results.push(
        ...(await Promise.all(
          messages.slice(i, i + 10).map((m) => this.send(m)),
        )),
      );
    return results;
  }
  private failure(code: string): PushProviderResult {
    return {
      outcome: 'failed',
      provider: this.providerName,
      providerMessageId: null,
      errorCode: code,
      errorMessage: null,
      retryAfterMs:
        code.includes('quota') || code.includes('rate') ? 60000 : undefined,
    };
  }
}
