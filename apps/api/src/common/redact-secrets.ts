/**
 * Env key names that must never appear in logs (values are redacted).
 * Add any new .env keys that hold secrets here.
 */
const SENSITIVE_KEYS = [
  'DATABASE_URL',
  'B2_KEY_ID',
  'B2_APPLICATION_KEY',
  'B2_BUCKET_NAME',
  'B2_ENDPOINT',
  'POSTGRES_PASSWORD',
  'REDIS_URL',
  'API_KEY',
  'SECRET',
] as const;

const REDACTED = '***REDACTED***';

/**
 * Redacts known sensitive env values from a string so it can be logged safely.
 * Use for any error message, stack, or context that might contain env or config.
 */
export function redactSecrets(value: string | undefined | null): string {
  if (value == null) return '';
  let out = value;
  for (const key of SENSITIVE_KEYS) {
    // KEY=value (value = rest of token, no spaces)
    const re = new RegExp(`(${key}=)[^\\s]+`, 'gi');
    out = out.replace(re, `$1${REDACTED}`);
  }
  // Common patterns that might leak in error messages
  out = out.replace(/postgres(ql)?:\/\/[^\s]+/gi, `postgres***://${REDACTED}`);
  out = out.replace(/Bearer\s+[\w.-]+/gi, 'Bearer ***REDACTED***');
  return out;
}
