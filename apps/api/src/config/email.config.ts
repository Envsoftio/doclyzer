import { join } from 'path';
import { registerAs } from '@nestjs/config';
import { existsSync } from 'node:fs';

export const emailConfig = registerAs('email', () => {
  const explicitTemplatesPath = process.env.EMAIL_TEMPLATES_PATH;
  const templatesPath =
    explicitTemplatesPath ??
    [
      join(process.cwd(), 'src/email/templates'),
      join(process.cwd(), 'apps/api/src/email/templates'),
    ].find((candidate) => existsSync(candidate)) ??
    join(process.cwd(), 'src/email/templates');

  const env = process.env.NODE_ENV ?? 'development';
  const workerEnabledRaw = process.env.EMAIL_WORKER_ENABLED;
  const workerEnabled =
    workerEnabledRaw !== undefined
      ? workerEnabledRaw === 'true'
      : env !== 'test';

  return {
    provider: process.env.EMAIL_PROVIDER ?? 'dev',
    fromAddress: process.env.EMAIL_FROM_ADDRESS ?? 'no-reply@doclyzer.local',
    fromName: process.env.EMAIL_FROM_NAME ?? 'Doclyzer',
    templatesPath,
    worker: {
      enabled: workerEnabled,
      pollIntervalMs: Number.parseInt(
        process.env.EMAIL_WORKER_POLL_INTERVAL_MS ?? '15000',
        10,
      ),
      batchSize: Number.parseInt(
        process.env.EMAIL_WORKER_BATCH_SIZE ?? '25',
        10,
      ),
    },
    auth: {
      baseUrl: process.env.BETTER_AUTH_URL ?? 'http://localhost:3000',
      basePath: process.env.BETTER_AUTH_BASE_PATH ?? '/v1/auth',
    },
  };
});
