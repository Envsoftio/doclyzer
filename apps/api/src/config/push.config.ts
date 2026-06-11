import { registerAs } from '@nestjs/config';

export interface PushConfig {
  provider: 'mock' | 'fcm';
  adminApprovalSecret: string;
  fcm: {
    projectId: string;
    clientEmail: string;
    privateKey: string;
    oauthTokenUrl: string;
    scope: string;
  };
}

export const pushConfig = registerAs(
  'push',
  (): PushConfig => ({
    provider: process.env.PUSH_PROVIDER === 'fcm' ? 'fcm' : 'mock',
    adminApprovalSecret: process.env.PUSH_ADMIN_APPROVAL_SECRET ?? '',
    fcm: {
      projectId: process.env.FCM_PROJECT_ID ?? '',
      clientEmail: process.env.FCM_CLIENT_EMAIL ?? '',
      privateKey: (process.env.FCM_PRIVATE_KEY ?? '').replace(/\\n/g, '\n'),
      oauthTokenUrl:
        process.env.FCM_OAUTH_TOKEN_URL ??
        'https://oauth2.googleapis.com/token',
      scope:
        process.env.FCM_SCOPE ??
        'https://www.googleapis.com/auth/firebase.messaging',
    },
  }),
);
