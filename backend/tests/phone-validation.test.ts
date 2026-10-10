import { describe, it, expect } from 'vitest';
import { validateAndNormalizeIndianPhone } from '../src/utils/phone-validator.js';
import { AppError } from '../src/utils/app-error.js';

describe('Phone Number Validation (Indian 10-Digit Mobile Numbers)', () => {
  it('should accept valid 10-digit Indian mobile numbers', () => {
    expect(validateAndNormalizeIndianPhone('9876543210')).toBe('9876543210');
    expect(validateAndNormalizeIndianPhone(' 9876543210 ')).toBe('9876543210');
  });

  it('should normalize +91 and 91 prefixed numbers to 10 digits', () => {
    expect(validateAndNormalizeIndianPhone('+919876543210')).toBe('9876543210');
    expect(validateAndNormalizeIndianPhone('919876543210')).toBe('9876543210');
    expect(validateAndNormalizeIndianPhone('09876543210')).toBe('9876543210');
  });

  it('should reject 9-digit phone numbers', () => {
    expect(() => validateAndNormalizeIndianPhone('987654321')).toThrow(AppError);
  });

  it('should reject 11-digit phone numbers without prefix', () => {
    expect(() => validateAndNormalizeIndianPhone('98765432101')).toThrow(AppError);
  });

  it('should reject alphabetic characters in phone numbers', () => {
    expect(() => validateAndNormalizeIndianPhone('abc1234567')).toThrow(AppError);
    expect(() => validateAndNormalizeIndianPhone('12345abc90')).toThrow(AppError);
  });

  it('should reject empty or whitespace phone numbers', () => {
    expect(() => validateAndNormalizeIndianPhone('')).toThrow(AppError);
    expect(() => validateAndNormalizeIndianPhone('   ')).toThrow(AppError);
  });
});
