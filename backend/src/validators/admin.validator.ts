import { z } from 'zod';

export const updateAccountStatusSchema = z.object({
  status: z.enum(['ACTIVE', 'SUSPENDED', 'DISABLED']),
});

export const updateProviderVerificationSchema = z.object({
  status: z.enum(['PENDING', 'VERIFIED', 'REJECTED']),
});
