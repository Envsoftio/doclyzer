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

/**
 * PHI field names whose values must never appear in operational logs.
 * These are clinical/personal data fields — log only safe identifiers
 * (reportId, profileId, userId) instead.
 */
const PHI_FIELD_NAMES = [
  'summary',
  'transcript',
  'parsedText',
  'displayName',
  'labValue',
  'diagnosis',
  'reportContent',
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

/**
 * Redacts PHI field values from a string so it can be logged safely.
 * Covers clinical and personal data fields that must never appear in
 * operational logs. Use alongside redactSecrets() when logging any
 * data that may have passed through PHI-bearing fields.
 *
 * Default-deny policy: logging bodies of PHI-bearing endpoints is
 * forbidden; use safe identifiers (reportId, profileId, userId) instead.
 */
export function redactPhi(value: string | undefined | null): string {
  if (value == null) return '';
  let out = value;
  for (const field of PHI_FIELD_NAMES) {
    // field=value or "field":"value" patterns — redact the value portion
    const reAssignment = new RegExp(`(${field}=)[^\\s,}\\]]+`, 'gi');
    out = out.replace(reAssignment, `$1${REDACTED}`);
    const reJson = new RegExp(`("${field}"\\s*:\\s*")[^"]*"`, 'gi');
    out = out.replace(reJson, `$1${REDACTED}"`);
  }
  return out;
}
