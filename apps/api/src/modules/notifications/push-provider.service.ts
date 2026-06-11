import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createSign, randomUUID } from 'node:crypto';
import type { PushConfig } from '../../config/push.config';

export interface PushProviderMessage {
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
  deepLink?: string | null;
}

export interface PushProviderResult {
  outcome: 'sent' | 'failed';
  provider: string;
  providerMessageId: string | null;
  errorCode: string | null;
  errorMessage: string | null;
}

interface FcmOAuthResponse {
  access_token?: string;
  expires_in?: number;
  error?: string;
  error_description?: string;
}

interface FcmSendResponse {
  name?: string;
  error?: {
    status?: string;
    message?: string;
  };
}

@Injectable()
export class PushProviderService {
  private readonly logger = new Logger(PushProviderService.name);
  private accessToken: string | null = null;
  private accessTokenExpiresAt = 0;

  constructor(private readonly config: ConfigService) {}

  get providerName(): string {
    return this.shouldUseFcm() ? 'fcm' : 'mock';
  }

  async send(message: PushProviderMessage): Promise<PushProviderResult> {
    if (!this.shouldUseFcm()) {
      return {
        outcome: 'sent',
        provider: 'mock',
        providerMessageId: `mock_${randomUUID()}`,
        errorCode: null,
        errorMessage: null,
      };
    }

    try {
      return await this.sendFcm(message);
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : 'Unknown FCM send error';
      this.logger.warn(`FCM push send failed: ${errorMessage}`);
      return {
        outcome: 'failed',
        provider: 'fcm',
        providerMessageId: null,
        errorCode: 'FCM_SEND_FAILED',
        errorMessage,
      };
    }
  }

  private shouldUseFcm(): boolean {
    const push = this.config.get<PushConfig>('push');
    return Boolean(
      push?.provider === 'fcm' &&
        push.fcm.projectId &&
        push.fcm.clientEmail &&
        push.fcm.privateKey,
    );
  }

  private async sendFcm(
    message: PushProviderMessage,
  ): Promise<PushProviderResult> {
    const push = this.config.getOrThrow<PushConfig>('push');
    const token = await this.getAccessToken(push);
    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${encodeURIComponent(
        push.fcm.projectId,
      )}/messages:send`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token: message.token,
            notification: {
              title: message.title,
              body: message.body,
            },
            data: message.data ?? {},
            android: {
              priority: 'HIGH',
              notification: {
                sound: 'default',
              },
            },
            apns: {
              payload: {
                aps: {
                  sound: 'default',
                },
              },
            },
            webpush: message.deepLink
              ? {
                  fcmOptions: {
                    link: message.deepLink,
                  },
                }
              : undefined,
          },
        }),
      },
    );

    const payload = (await response.json().catch(() => ({}))) as FcmSendResponse;
    if (!response.ok) {
      return {
        outcome: 'failed',
        provider: 'fcm',
        providerMessageId: null,
        errorCode: payload.error?.status ?? `FCM_HTTP_${response.status}`,
        errorMessage:
          payload.error?.message ?? `FCM request failed (${response.status})`,
      };
    }

    return {
      outcome: 'sent',
      provider: 'fcm',
      providerMessageId: payload.name ?? null,
      errorCode: null,
      errorMessage: null,
    };
  }

  private async getAccessToken(push: PushConfig): Promise<string> {
    const now = Math.floor(Date.now() / 1000);
    if (this.accessToken && this.accessTokenExpiresAt - 60 > now) {
      return this.accessToken;
    }

    const assertion = this.buildServiceAccountJwt(push, now);
    const body = new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    });
    const response = await fetch(push.fcm.oauthTokenUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body,
    });
    const payload = (await response.json().catch(() => ({}))) as FcmOAuthResponse;
    if (!response.ok || !payload.access_token) {
      throw new Error(
        payload.error_description ??
          payload.error ??
          `FCM OAuth token request failed (${response.status})`,
      );
    }

    this.accessToken = payload.access_token;
    this.accessTokenExpiresAt = now + (payload.expires_in ?? 3600);
    return payload.access_token;
  }

  private buildServiceAccountJwt(push: PushConfig, now: number): string {
    const header = this.base64UrlJson({ alg: 'RS256', typ: 'JWT' });
    const claims = this.base64UrlJson({
      iss: push.fcm.clientEmail,
      scope: push.fcm.scope,
      aud: push.fcm.oauthTokenUrl,
      iat: now,
      exp: now + 3600,
    });
    const unsigned = `${header}.${claims}`;
    const signature = createSign('RSA-SHA256')
      .update(unsigned)
      .sign(push.fcm.privateKey, 'base64url');
    return `${unsigned}.${signature}`;
  }

  private base64UrlJson(value: Record<string, string | number>): string {
    return Buffer.from(JSON.stringify(value)).toString('base64url');
  }
}
