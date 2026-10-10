import bcrypt from 'bcryptjs';
import { AppError } from './app-error.js';

const BCRYPT_SALT_ROUNDS = 12;

export async function hashPassword(plainText: string): Promise<string> {
  return bcrypt.hash(plainText, BCRYPT_SALT_ROUNDS);
}

export async function verifyPassword(plainText: string, hash: string): Promise<boolean> {
  return bcrypt.compare(plainText, hash);
}

export function validatePasswordRequirements(password: string): void {
  if (!password || typeof password !== 'string') {
    throw AppError.badRequest('Password is required');
  }

  if (password.length < 8) {
    throw AppError.badRequest('Password must be at least 8 characters long');
  }

  if (password.length > 128) {
    throw AppError.badRequest('Password cannot exceed 128 characters');
  }

  if (!/[A-Za-z]/.test(password) || !/[0-9]/.test(password)) {
    throw AppError.badRequest('Password must contain at least one letter and one number');
  }
}
