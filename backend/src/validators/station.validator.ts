import { z } from 'zod';

export const stationStatusSchema = z.enum(['ACTIVE', 'INACTIVE', 'MAINTENANCE']);
export const chargerStatusSchema = z.enum(['AVAILABLE', 'OCCUPIED', 'OFFLINE', 'MAINTENANCE', 'DISABLED']);

export const createStationSchema = z.object({
  name: z.string().trim().min(2, 'Station name must be at least 2 characters').max(150),
  address: z.string().trim().min(5, 'Address must be at least 5 characters').max(500),
  city: z.string().trim().max(100).optional(),
  state: z.string().trim().max(100).optional(),
  pincode: z.string().regex(/^\d{6}$/, 'Pincode must be exactly 6 digits').optional().or(z.literal('')),
  latitude: z.number().min(-90).max(90, 'Invalid latitude'),
  longitude: z.number().min(-180).max(180, 'Invalid longitude'),
  status: stationStatusSchema.optional(),
});

export const updateStationSchema = createStationSchema.partial();

export const createChargerSchema = z.object({
  chargerCode: z.string().trim().min(2, 'Charger code must be at least 2 characters').max(50),
  name: z.string().trim().max(100).optional(),
  chargerType: z.string().trim().min(1, 'Charger type is required').max(50),
  connectorType: z.string().trim().min(1, 'Connector type is required').max(50),
  powerKw: z.number().positive('Power must be greater than 0').max(1000, 'Power exceeds realistic limits'),
  pricePerHour: z.number().min(0, 'Price cannot be negative').optional(),
  pricePerKwh: z.number().min(0, 'Price cannot be negative').optional(),
  status: chargerStatusSchema.optional(),
});

export const updateChargerSchema = createChargerSchema.partial();

export const chargerDiscoveryFiltersSchema = z.object({
  latitude: z.coerce.number().min(-90).max(90).optional(),
  longitude: z.coerce.number().min(-180).max(180).optional(),
  radius: z.coerce.number().positive().optional(),
  city: z.string().trim().optional(),
  state: z.string().trim().optional(),
  pincode: z.string().regex(/^\d{6}$/).optional(),
  status: chargerStatusSchema.optional(),
  connectorType: z.string().trim().optional(),
  chargerType: z.string().trim().optional(),
  minPower: z.coerce.number().positive().optional(),
  maxPower: z.coerce.number().positive().optional(),
  search: z.string().trim().optional(),
});
