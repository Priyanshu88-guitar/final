import { z } from 'zod';

const fullNameSchema = z.string().trim().optional().transform((val, ctx) => {
  if (!val) return val;
  if (val.length < 2) {
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

const pincodeSchema = z.string().trim().optional().or(z.literal('')).transform((val, ctx) => {
  if (!val) return undefined;
  if (!/^\d{6}$/.test(val)) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Pincode must be exactly 6 numeric digits',
    });
    return z.NEVER;
  }
  return val;
});

const dobSchema = z.string().trim().optional().or(z.literal('')).transform((val, ctx) => {
  if (!val) return undefined;

  let parsedDate: Date | null = null;

  // Handle DD/MM/YYYY format
  if (/^\d{2}\/\d{2}\/\d{4}$/.test(val)) {
    const [day, month, year] = val.split('/').map((s) => parseInt(s, 10));
    parsedDate = new Date(year, month - 1, day);
  } else if (/^\d{4}-\d{2}-\d{2}$/.test(val)) {
    parsedDate = new Date(val);
  } else {
    parsedDate = new Date(val);
  }

  if (!parsedDate || isNaN(parsedDate.getTime())) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Invalid date of birth format. Use DD/MM/YYYY or YYYY-MM-DD',
    });
    return z.NEVER;
  }

  if (parsedDate > new Date()) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Date of birth cannot be in the future',
    });
    return z.NEVER;
  }

  return val;
});

export const saveCustomerProfileSchema = z.object({
  fullName: fullNameSchema,
  email: z.string().email('Invalid email address format').optional().or(z.literal('')),
  dateOfBirth: dobSchema,
  city: z.string().trim().max(100, 'City cannot exceed 100 characters').optional().or(z.literal('')),
  state: z.string().trim().max(100, 'State cannot exceed 100 characters').optional().or(z.literal('')),
  pincode: pincodeSchema,
  address: z.string().trim().max(500, 'Address cannot exceed 500 characters').optional().or(z.literal('')),
  profileImage: z.string().url('Invalid profile image URL').optional().or(z.literal('')),
});

export const saveProviderProfileSchema = z.object({
  businessName: z.string().trim().min(2, 'Business name must be at least 2 characters').max(150, 'Business name cannot exceed 150 characters'),
  contactPhone: z.string().trim().optional().or(z.literal('')),
  contactEmail: z.string().email('Invalid contact email format').optional().or(z.literal('')),
  address: z.string().trim().min(5, 'Address must be at least 5 characters').max(500, 'Address cannot exceed 500 characters'),
  city: z.string().trim().max(100).optional().or(z.literal('')),
  state: z.string().trim().max(100).optional().or(z.literal('')),
  pincode: pincodeSchema,
  taxId: z.string().trim().max(50).optional().or(z.literal('')),
  description: z.string().trim().max(1000).optional().or(z.literal('')),
  logoImage: z.string().url('Invalid logo image URL').optional().or(z.literal('')),
});

export const saveCustomerVehicleSchema = z.object({
  make: z.string().trim().min(1, 'Make is required'),
  model: z.string().trim().min(1, 'Model is required'),
  type: z.string().trim().min(1, 'Type is required').default('TWO_WHEELER'),
  batteryCapacity: z.number().positive('Battery capacity must be positive').optional(),
  connectorType: z.string().trim().optional(),
  mileage: z.number().positive('Mileage must be positive').optional(),
});

export const saveProviderSetupPhotoSchema = z.object({
  photoUrl: z.string().trim().min(1, 'Photo data/url is required'),
  description: z.string().trim().optional(),
});
