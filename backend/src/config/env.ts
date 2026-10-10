import dotenv from 'dotenv';
import path from 'path';
import { z } from 'zod';

// Load environment variables from .env file
dotenv.config({ path: path.resolve(process.cwd(), '.env') });

const envSchema = z.object({
  PORT: z.string().default('3000').transform((val) => parseInt(val, 10)),
  APP_ENV: z.enum(['development', 'test', 'production']).default('development'),
  DATABASE_URL: z.string().min(1, 'DATABASE_URL is required'),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  CORS_ORIGIN: z.string().default('*'),

  JWT_SECRET: z.string().min(16, 'JWT_SECRET must be at least 16 characters long'),
  JWT_EXPIRES_IN: z.string().default('1h'),
  REFRESH_TOKEN_SECRET: z.string().min(16, 'REFRESH_TOKEN_SECRET must be at least 16 characters long'),
  REFRESH_TOKEN_EXPIRES_IN: z.string().default('7d'),

  OTP_TTL_MINUTES: z.string().default('5').transform((val) => parseInt(val, 10)),
  OTP_RESEND_COOLDOWN_SECONDS: z.string().default('60').transform((val) => parseInt(val, 10)),
  OTP_PROVIDER: z.string().default('console'),
  OTP_API_KEY: z.string().optional().default(''),
  OTP_SENDER_ID: z.string().optional().default(''),

  PAYMENT_PROVIDER: z.string().default('mock'),
  PAYMENT_API_KEY: z.string().optional().default(''),
  PAYMENT_API_SECRET: z.string().optional().default(''),
  PAYMENT_WEBHOOK_SECRET: z.string().optional().default(''),
  PLATFORM_FEE_PERCENTAGE: z.string().default('10').transform((val) => parseFloat(val)),

  PUSH_PROVIDER: z.string().default('mock'),
  FCM_SERVER_KEY: z.string().optional().default(''),
});

const _env = envSchema.safeParse(process.env);

if (!_env.success) {
  console.error('❌ Invalid environment variables configuration:');
  console.error(JSON.stringify(_env.error.format(), null, 2));
  process.exit(1);
}

export const env = _env.data;
