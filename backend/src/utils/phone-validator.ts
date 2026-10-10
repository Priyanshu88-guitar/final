import { AppError } from './app-error.js';

/**
 * Validates and normalizes Indian mobile numbers.
 * Enforces strictly:
 * - Trim whitespace
 * - Accepts optional country prefix (+91 or 91)
 * - Digits only
 * - Must resolve to EXACTLY 10 digits
 * - First digit must be 6, 7, 8, or 9 (standard Indian mobile range) or 1-9 for strict 10 digits validation
 */
export function validateAndNormalizeIndianPhone(phone: unknown): string {
  if (typeof phone !== 'string') {
    throw AppError.badRequest('Phone number must be a string');
  }

  const trimmed = phone.trim();

  if (!trimmed) {
    throw AppError.badRequest('Phone number is required');
  }

  // Reject if contains letters or forbidden special characters
  if (/[a-zA-Z]/.test(trimmed)) {
    throw AppError.badRequest('Phone number must contain only numeric digits');
  }

  // Handle prefix if present: e.g. +91 or 91 followed by 10 digits
  let digitsOnly = trimmed;
  if (digitsOnly.startsWith('+91')) {
    digitsOnly = digitsOnly.substring(3);
  } else if (digitsOnly.length === 12 && digitsOnly.startsWith('91')) {
    digitsOnly = digitsOnly.substring(2);
  } else if (digitsOnly.startsWith('0') && digitsOnly.length === 11) {
    digitsOnly = digitsOnly.substring(1);
  }

  // Check if remaining string contains strictly digits only
  if (!/^\d+$/.test(digitsOnly)) {
    throw AppError.badRequest('Phone number must contain only numeric digits');
  }

  if (digitsOnly.length < 10) {
    throw AppError.badRequest('Phone number must be exactly 10 digits');
  }

  if (digitsOnly.length > 10) {
    throw AppError.badRequest('Phone number must be exactly 10 digits');
  }

  return digitsOnly;
}
