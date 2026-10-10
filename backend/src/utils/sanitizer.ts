const SENSITIVE_KEYS = new Set([
  'password',
  'pass',
  'secret',
  'token',
  'accesstoken',
  'refreshtoken',
  'authorization',
  'otp',
  'pin',
  'cvv',
  'cardnumber',
  'creditcard',
  'database_url',
  'databaseurl',
  'db_password',
  'api_key',
  'apikey',
]);

export function sanitizeData(data: unknown): unknown {
  if (data === null || data === undefined) {
    return data;
  }

  if (typeof data === 'string') {
    return data;
  }

  if (Array.isArray(data)) {
    return data.map((item) => sanitizeData(item));
  }

  if (typeof data === 'object') {
    const sanitizedObj: Record<string, unknown> = {};

    for (const [key, value] of Object.entries(data as Record<string, unknown>)) {
      const lowerKey = key.toLowerCase().replace(/[^a-z0-9]/g, '');

      if (SENSITIVE_KEYS.has(lowerKey)) {
        sanitizedObj[key] = '[REDACTED]';
      } else if (typeof value === 'object' && value !== null) {
        sanitizedObj[key] = sanitizeData(value);
      } else {
        sanitizedObj[key] = value;
      }
    }

    return sanitizedObj;
  }

  return data;
}
