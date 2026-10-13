import { z } from 'zod';

const phoneTransform = z.string().transform((val, ctx) => {
  const trimmed = val.trim();
  if (/[a-zA-Z]/.test(trimmed)) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Phone number must contain only numeric digits',
    });
    return z.NEVER;
  }

  let digits = trimmed;
  if (digits.startsWith('+91')) digits = digits.substring(3);
  else if (digits.length === 12 && digits.startsWith('91')) digits = digits.substring(2);
  else if (digits.length === 11 && digits.startsWith('0')) digits = digits.substring(1);

  if (!/^\d+$/.test(digits)) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Phone number must contain only numeric digits',
    });
    return z.NEVER;
  }

  if (digits.length !== 10) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Phone number must be exactly 10 digits',
    });
    return z.NEVER;
  }

  return digits;
});

const fullNameSchema = z.string().trim().transform((val, ctx) => {
  if (!val || val.length < 2) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Full name must be at least 2 characters long',
    });
    return z.NEVER;
  }
  if (/\d/.test(val)) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Full name cannot contain numeric digits',
    });
    return z.NEVER;
  }
  if (!/^[a-zA-Z\s'.-]+$/.test(val)) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Full name contains invalid characters',
    });
    return z.NEVER;
  }
  return val;
});

const passwordSchema = z.string().transform((val, ctx) => {
  if (!val || val.length < 8) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Password must be at least 8 characters long',
    });
    return z.NEVER;
  }
  if (!/[A-Za-z]/.test(val) || !/[0-9]/.test(val)) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Password must contain at least one letter and one number',
    });
    return z.NEVER;
  }
  return val;
});

export const signupSchema = z.object({
  fullName: fullNameSchema,
  phone: phoneTransform,
  email: z.string().email('Invalid email address format').optional().or(z.literal('')),
  password: passwordSchema,
  role: z.enum(['CUSTOMER', 'PROVIDER', 'customer', 'provider', 'SERVICE_PROVIDER', 'service_provider', 'service provider', 'SERVICE PROVIDER'], {
      errorMap: () => ({ message: 'Public signup only allows CUSTOMER or PROVIDER roles' }),
    }).transform((val) => {
      const upper = val.toUpperCase();
      if (upper.includes('PROVIDER') || upper.includes('SERVICE')) return 'PROVIDER';
      return 'CUSTOMER';
    }),
  businessName: z.string().optional(),
  address: z.string().optional(),
  city: z.string().optional(),
  state: z.string().optional(),
  pincode: z.string().optional(),
  taxId: z.string().optional(),
});

export const verifyOtpSchema = z.object({
  phone: phoneTransform,
  otp: z.string().length(6, 'OTP must be exactly 6 digits').regex(/^\d+$/, 'OTP must be numeric'),
  purpose: z.enum(['SIGNUP_VERIFICATION', 'LOGIN_VERIFICATION', 'PASSWORD_RESET']),
});

export const resendOtpSchema = z.object({
  phone: phoneTransform,
  purpose: z.enum(['SIGNUP_VERIFICATION', 'LOGIN_VERIFICATION', 'PASSWORD_RESET']),
});

export const loginSchema = z.object({
  phone: phoneTransform,
  password: z.string().min(1, 'Password is required'),
});

export const forgotPasswordSchema = z.object({
  phone: phoneTransform,
});

export const resetPasswordSchema = z.object({
  phone: phoneTransform,
  otp: z.string().length(6, 'OTP must be exactly 6 digits').regex(/^\d+$/, 'OTP must be numeric'),
  newPassword: passwordSchema,
});

export const changePasswordSchema = z.object({
  currentPassword: z.string().min(1, 'Current password is required'),
  newPassword: passwordSchema,
});
