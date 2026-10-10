import { app } from './app.js';
import { env } from './config/env.js';
import { connectDatabase, disconnectDatabase } from './config/database.js';
import { logger } from './config/logger.js';

async function startServer(): Promise<void> {
  const isDbConnected = await connectDatabase();

  if (!isDbConnected) {
    logger.warn('⚠️ Server starting with database disconnected/unreachable.');
  }

  const server = app.listen(env.PORT, () => {
    logger.info(`🚀 VOLTERA Backend API running on port ${env.PORT} [${env.APP_ENV}]`);
    logger.info(`👉 Health Check: http://localhost:${env.PORT}/health`);
  });

  // Graceful Shutdown
  const shutdown = async (signal: string) => {
    logger.info(`Received ${signal}. Shutting down gracefully...`);

    server.close(async () => {
      logger.info('HTTP server closed.');
      await disconnectDatabase();
      process.exit(0);
    });

    // Force exit after 10 seconds
    setTimeout(() => {
      logger.error('Could not close connections in time, forcefully shutting down');
      process.exit(1);
    }, 10000);
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}

startServer().catch((error) => {
  logger.error('Fatal error starting server', { error });
  process.exit(1);
});
