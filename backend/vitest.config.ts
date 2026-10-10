import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    fileParallelism: false,
    maxWorkers: 1,
    env: {
      APP_ENV: 'test',
      JWT_SECRET: 'test-jwt-secret-key-minimum-32-chars-long',
      REFRESH_TOKEN_SECRET: 'test-refresh-secret-key-32-chars-long',
      PAYMENT_PROVIDER: 'mock',
      PLATFORM_FEE_PERCENTAGE: '10',
      PUSH_PROVIDER: 'mock',
    },
  },
});
