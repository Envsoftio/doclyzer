import { registerAs } from '@nestjs/config';

export interface PushConfig {
  provider: 'mock' | 'fcm';
  fcm: {
    projectId: string;
    clientEmail: string;
    privateKey: string;
  };
}

export const pushConfig = registerAs(
  'push',
  (): PushConfig => ({
    provider: process.env.PUSH_PROVIDER === 'fcm' ? 'fcm' : 'mock',
    fcm: {
      projectId: process.env.FCM_PROJECT_ID ?? '',
      clientEmail: process.env.FCM_CLIENT_EMAIL ?? '',
      privateKey: (process.env.FCM_PRIVATE_KEY ?? '').replace(/\\n/g, '\n'),
    },
  }),
);
