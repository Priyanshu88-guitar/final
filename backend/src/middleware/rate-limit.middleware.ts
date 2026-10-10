import rateLimit from 'express-rate-limit';
import { errorResponse } from '../utils/response.js';
import { env } from '../config/env.js';

export const loginRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  limit: 10, // 10 attempts per IP per window
  standardHeaders: 'draft-7',
  legacyHeaders: false,
  skip: () => env.APP_ENV === 'test',
  handler: (_req, res) => {
    res.status(429).json(
      errorResponse(
        'Too many failed login attempts. Please try again after 15 minutes.',
        'TOO_MANY_REQUESTS'
      )
    );
  },
});

export const otpRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  limit: 5, // 5 requests per IP per window
  standardHeaders: 'draft-7',
  legacyHeaders: false,
  skip: () => env.APP_ENV === 'test',
  handler: (_req, res) => {
    res.status(429).json(
      errorResponse(
        'Too many OTP requests. Please wait 15 minutes before trying again.',
        'TOO_MANY_REQUESTS'
      )
    );
  },
});
