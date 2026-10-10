import jwt, { JwtPayload } from 'jsonwebtoken';
import crypto from 'crypto';
import { env } from '../config/env.js';
import { AppError } from './app-error.js';
import { UserRoleType } from '../models/user.model.js';

export interface AuthTokenPayload extends JwtPayload {
  sub: string; // userId
  phoneNumber: string;
  roles: UserRoleType[];
  activeRole?: UserRoleType;
}

export interface GeneratedTokens {
  accessToken: string;
  refreshToken: string;
  expiresIn: string;
}

export function generateAccessToken(
  userId: string,
  phoneNumber: string,
  roles: UserRoleType[],
  activeRole?: UserRoleType
): string {
  const payload: Omit<AuthTokenPayload, 'iat' | 'exp'> = {
    sub: userId,
    phoneNumber,
    roles,
    activeRole: activeRole || roles[0] || 'CUSTOMER',
    jti: crypto.randomUUID(), // Add jti to prevent exact identical tokens
  };

  return jwt.sign(payload, env.JWT_SECRET, {
    expiresIn: env.JWT_EXPIRES_IN as jwt.SignOptions['expiresIn'],
  });
}

export function generateRefreshToken(userId: string): string {
  const payload = {
    sub: userId,
    type: 'refresh',
    jti: crypto.randomUUID(), // Ensure uniqueness even if created in the same second
  };

  return jwt.sign(payload, env.REFRESH_TOKEN_SECRET, {
    expiresIn: env.REFRESH_TOKEN_EXPIRES_IN as jwt.SignOptions['expiresIn'],
  });
}

export function verifyAccessToken(token: string): AuthTokenPayload {
  try {
    const decoded = jwt.verify(token, env.JWT_SECRET) as AuthTokenPayload;
    if (!decoded.sub) {
      throw AppError.unauthorized('Invalid access token payload');
    }
    return decoded;
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      throw AppError.unauthorized('Access token has expired');
    }
    if (error instanceof jwt.JsonWebTokenError) {
      throw AppError.unauthorized('Invalid access token');
    }
    throw error;
  }
}

export function verifyRefreshToken(token: string): { sub: string } {
  try {
    const decoded = jwt.verify(token, env.REFRESH_TOKEN_SECRET) as { sub: string; type?: string };
    if (!decoded.sub || decoded.type !== 'refresh') {
      throw AppError.unauthorized('Invalid refresh token payload');
    }
    return decoded;
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      throw AppError.unauthorized('Refresh token has expired');
    }
    if (error instanceof jwt.JsonWebTokenError) {
      throw AppError.unauthorized('Invalid refresh token');
    }
    throw error;
  }
}

export function hashToken(token: string): string {
  return crypto.createHash('sha256').update(token).digest('hex');
}
