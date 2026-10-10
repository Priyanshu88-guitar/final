import { z } from 'zod';

export const registerDeviceSchema = z.object({
  token: z.string().min(5, 'Invalid device token'),
  platform: z.enum(['android', 'ios', 'web']),
  deviceMeta: z.string().optional(),
});

export const updatePreferencesSchema = z.object({
  pushEnabled: z.boolean().optional(),
  bookingNotifications: z.boolean().optional(),
  paymentNotifications: z.boolean().optional(),
  sessionNotifications: z.boolean().optional(),
  promotionalEmails: z.boolean().optional(),
});
