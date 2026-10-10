import { z } from 'zod';

export const bookingStatusSchema = z.enum(['PENDING', 'CONFIRMED', 'REJECTED', 'CANCELLED', 'COMPLETED', 'EXPIRED']);
export const sessionStatusSchema = z.enum(['PENDING', 'ACTIVE', 'COMPLETED', 'CANCELLED', 'FAILED']);

export const createBookingSchema = z.object({
  chargerId: z.string().uuid('Invalid charger ID'),
  startTime: z.coerce.date().refine((date) => date > new Date(), { message: 'Start time must be in the future' }),
  endTime: z.coerce.date(),
}).refine((data) => data.endTime > data.startTime, {
  message: 'End time must be after start time',
  path: ['endTime'],
}).refine((data) => {
  const durationMs = data.endTime.getTime() - data.startTime.getTime();
  // Max duration 24 hours
  return durationMs <= 24 * 60 * 60 * 1000;
}, {
  message: 'Booking duration cannot exceed 24 hours',
  path: ['endTime'],
});
