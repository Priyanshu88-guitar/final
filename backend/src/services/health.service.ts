import { checkDatabaseHealth, DatabaseHealthResult } from '../config/database.js';
import { env } from '../config/env.js';

export interface HealthCheckResult {
  status: 'ok' | 'degraded' | 'error';
  timestamp: string;
  environment: string;
  database: DatabaseHealthResult;
}

export class HealthService {
  async performHealthCheck(): Promise<HealthCheckResult> {
    const dbHealth = await checkDatabaseHealth();

    let status: 'ok' | 'degraded' | 'error' = 'ok';
    if (!dbHealth.connected) {
      status = 'degraded';
    }

    return {
      status,
      timestamp: new Date().toISOString(),
      environment: env.APP_ENV,
      database: dbHealth,
    };
  }
}

export const healthService = new HealthService();
