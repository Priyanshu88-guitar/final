import { z } from 'zod';

export const uuidParamSchema = z.object({
  id: z.string().uuid('Invalid UUID format').optional(),
  notificationId: z.string().uuid('Invalid UUID format').optional(),
  bookingId: z.string().uuid('Invalid UUID format').optional(),
  chargerId: z.string().uuid('Invalid UUID format').optional(),
  stationId: z.string().uuid('Invalid UUID format').optional(),
  sessionId: z.string().uuid('Invalid UUID format').optional(),
  bundleId: z.string().uuid('Invalid UUID format').optional(),
  ticketId: z.string().uuid('Invalid UUID format').optional(),
});

export const paginationQuerySchema = z.object({
  page: z.string().optional().transform((val) => (val ? Math.max(1, parseInt(val, 10)) : 1)),
  limit: z.string().optional().transform((val) => (val ? Math.min(100, Math.max(1, parseInt(val, 10))) : 20)),
});
