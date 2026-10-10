import { Request, Response, NextFunction } from 'express';
import { Prisma } from '@prisma/client';
import { AppError } from '../utils/app-error.js';
import { errorResponse } from '../utils/response.js';
import { logger } from '../config/logger.js';
import { env } from '../config/env.js';

export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction
): void {
  let statusCode = 500;
  let errorCode = 'INTERNAL_SERVER_ERROR';
  let message = 'An unexpected error occurred';
  let details: unknown = undefined;

  // Handle operational AppErrors
  if (err instanceof AppError) {
    statusCode = err.statusCode;
    errorCode = err.errorCode;
    message = err.message;
    details = err.details;
  }
  // Handle Prisma Database Errors
  else if (err instanceof Prisma.PrismaClientKnownRequestError) {
    if (err.code === 'P2002') {
      statusCode = 409;
      errorCode = 'DUPLICATE_ENTRY';
      message = 'A record with this unique value already exists';
      details = { fields: err.meta?.target };
    } else if (err.code === 'P2025') {
      statusCode = 404;
      errorCode = 'NOT_FOUND';
      message = 'Record not found in database';
    } else {
      statusCode = 400;
      errorCode = 'DATABASE_ERROR';
      message = 'Database operation failed';
    }
  } else if (err instanceof Prisma.PrismaClientValidationError) {
    statusCode = 400;
    errorCode = 'INVALID_DATABASE_INPUT';
    message = 'Invalid data provided to database operation';
  }
  // Handle Syntax Errors (e.g. malformed JSON in request body)
  else if (err instanceof SyntaxError && 'status' in err && (err as { status?: number }).status === 400) {
    statusCode = 400;
    errorCode = 'MALFORMED_JSON';
    message = 'Malformed JSON in request body';
  }

  // Log error details (error level for 5xx, warn for 4xx)
  const logPayload = {
    method: req.method,
    url: req.originalUrl,
    statusCode,
    errorCode,
    message: err.message,
    stack: env.APP_ENV !== 'production' ? err.stack : undefined,
  };

  if (statusCode >= 500) {
    logger.error(`[Unhandled Error] ${err.message}`, logPayload);
  } else {
    logger.warn(`[Client Error] ${err.message}`, logPayload);
  }

  // Hide internal details in production for 500 errors
  if (statusCode === 500 && env.APP_ENV === 'production') {
    message = 'An unexpected internal server error occurred';
    details = undefined;
  }

  res.status(statusCode).json(errorResponse(message, errorCode, details));
}

// 404 Route Not Found Handler
export function notFoundHandler(req: Request, res: Response): void {
  res.status(404).json(
    errorResponse(`Route ${req.method} ${req.originalUrl} not found`, 'NOT_FOUND')
  );
}
