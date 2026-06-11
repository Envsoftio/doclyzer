import { registerAs } from '@nestjs/config';

export interface RevenueCatConfig {
  webhookAuthorization: string;
}

export const revenueCatConfig = registerAs(
  'revenueCat',
  (): RevenueCatConfig => ({
    webhookAuthorization: process.env.REVENUECAT_WEBHOOK_AUTHORIZATION ?? '',
  }),
);
