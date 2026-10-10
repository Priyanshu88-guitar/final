import { z } from 'zod';

export const createEmergencyRequestSchema = z.object({
  serviceId: z.string().uuid('Invalid service ID'),
  description: z.string().optional(),
  latitude: z.number().min(-90).max(90).optional(),
  longitude: z.number().min(-180).max(180).optional(),
  address: z.string().optional(),
});
