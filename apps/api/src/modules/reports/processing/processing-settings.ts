import { ConfigService } from '@nestjs/config';
export function processingSettings(config: ConfigService) {
  const int = (key: string, fallback: number, min = 1, max = 2147483647) => {
    const n = Number(config.get(key, fallback));
    if (!Number.isSafeInteger(n) || n < min || n > max)
      throw new Error(`Invalid ${key}`);
    return n;
  };
  return {
    admission:
      config.get('REPORT_ASYNC_ACCEPTANCE_ENABLED', 'false') === 'true',
    runtime: config.get('REPORT_ASYNC_RUNTIME_ENABLED', 'false') === 'true',
    role: config.get<string>('REPORT_PROCESS_ROLE', 'api'),
    policy: {
      maxAttempts: int('REPORT_MAX_ATTEMPTS', 3, 1, 10),
      processingDeadlineMs: int('REPORT_DEADLINE_MS', 1800000),
      uploadDeadlineMs: int('REPORT_UPLOAD_DEADLINE_MS', 120000),
      idempotencyRetentionMs: int('REPORT_IDEMPOTENCY_RETENTION_MS', 604800000),
      cleanupRetryMs: int('REPORT_ORPHAN_RETRY_MS', 3600000),
    },
    leaseMs: int('REPORT_LEASE_MS', 60000, 3000),
    concurrency: int('REPORT_WORKER_CONCURRENCY', 1, 1, 4),
    maxPages: int('REPORT_MAX_PAGES', 100, 1, 1000),
    maxImagePixels: int('REPORT_MAX_IMAGE_PIXELS', 25000000),
    providerBase: config
      .get<string>('DOCLING_OCR_BASE_URL', 'http://127.0.0.1:5002')
      .replace(/\/+$/, ''),
    providerApiKey: config.get<string>('DOCLING_API_KEY', ''),
    providerInstance: config.get<string>(
      'DOCLING_INSTANCE_ID',
      'docling-1.37.0',
    ),
    providerRequestMs: int('REPORT_PROVIDER_REQUEST_MS', 30000),
    eventRetentionMs: int('REPORT_EVENT_RETENTION_MS', 604800000),
    notificationExpiryMs: int('REPORT_NOTIFICATION_EXPIRY_MS', 604800000),
    pushEnabled:
      config.get('REPORT_COMPLETION_PUSH_ENABLED', 'false') === 'true',
  };
}
