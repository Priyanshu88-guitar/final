import express, { Application } from 'express';
import cors from 'cors';
import { env } from './config/env.js';
import { httpLogger } from './middleware/logger.middleware.js';
import { errorHandler, notFoundHandler } from './middleware/error.middleware.js';
import { apiRouter } from './routes/index.js';

export function createApp(): Application {
  const app = express();

  // Basic security & parsing middleware
  app.use(cors({ origin: env.CORS_ORIGIN }));
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));

  // HTTP Request Logger
  app.use(httpLogger);

  // Mount API Router
  app.use('/', apiRouter);

  // 404 Handler
  app.use(notFoundHandler);

  // Central Error Handler
  app.use(errorHandler);

  return app;
}

export const app = createApp();
