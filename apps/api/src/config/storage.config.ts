import { registerAs } from '@nestjs/config';

export interface StorageConfig {
  b2KeyId: string | undefined;
  b2ApplicationKey: string | undefined;
  b2Bucket: string | undefined;
  b2Endpoint: string | undefined;
  b2Region: string;
  b2Disabled: boolean;
}

export const storageConfig = registerAs(
  'storage',
  (): StorageConfig => ({
    b2KeyId: process.env.B2_KEY_ID,
    b2ApplicationKey: process.env.B2_APPLICATION_KEY,
    b2Bucket: process.env.B2_BUCKET_NAME,
    b2Endpoint: process.env.B2_ENDPOINT,
    b2Region: process.env.B2_REGION ?? 'us-west-002',
    b2Disabled: process.env.B2_DISABLED === 'true',
  }),
);
