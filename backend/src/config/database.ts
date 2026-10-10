import { prisma } from '../database/prisma.js';
import { logger } from './logger.js';

export interface DatabaseHealthResult {
  connected: boolean;
  latencyMs?: number;
  error?: string;
}

export async function connectDatabase(): Promise<boolean> {
  try {
    logger.info('Connecting to database...');
    await prisma.$connect();
    logger.info('✅ Database connected successfully.');
    return true;
  } catch (error) {
    logger.error('❌ Failed to connect to database', { error });
    return false;
  }
}

export async function disconnectDatabase(): Promise<void> {
  try {
    await prisma.$disconnect();
    logger.info('Database connection closed gracefully.');
  } catch (error) {
    logger.error('Error disconnecting from database', { error });
  }
}

export async function checkDatabaseHealth(): Promise<DatabaseHealthResult> {
  const startTime = Date.now();
  try {
    await prisma.$queryRaw`SELECT 1`;
    const latencyMs = Date.now() - startTime;
    return {
      connected: true,
      latencyMs,
    };
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Unknown database error';
    logger.error('Database health check failed', { error: errorMessage });
    return {
      connected: false,
      error: errorMessage,
    };
  }
}
