import { z } from 'zod';

export const createPaymentSchema = z.object({
  bookingId: z.string().uuid().optional(),
  sessionId: z.string().uuid().optional(),
  bundlePurchaseId: z.string().uuid().optional(),
}).refine(data => data.bookingId || data.sessionId || data.bundlePurchaseId, {
  message: "Either bookingId, sessionId, or bundlePurchaseId must be provided.",
});

export const saveBankAccountSchema = z.object({
  accountName: z.string().trim().min(2, 'Account name is required'),
  accountNumber: z.string().trim().min(5, 'Invalid account number'),
  ifscCode: z.string().trim().regex(/^[A-Z]{4}0[A-Z0-9]{6}$/, 'Invalid IFSC code format'),
  bankName: z.string().trim().optional(),
});

export const requestPayoutSchema = z.object({
  amount: z.number().positive('Payout amount must be positive'),
});
