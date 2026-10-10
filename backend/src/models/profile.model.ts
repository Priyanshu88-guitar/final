export type ProviderVerificationStatus = 'PENDING' | 'VERIFIED' | 'REJECTED';

export type ProfileStatus = 'INCOMPLETE' | 'COMPLETE';

export interface CustomerProfileModel {
  id: string;
  userId: string;
  fullName: string | null;
  phoneNumber: string; // Obtained from User
  email: string | null; // Obtained from User
  dateOfBirth: string | null;
  city: string | null;
  state: string | null;
  pincode: string | null;
  address: string | null;
  profileImage: string | null;
  profileStatus: ProfileStatus;
  createdAt: Date;
  updatedAt: Date;
}

export interface ProviderProfileModel {
  id: string;
  userId: string;
  businessName: string;
  contactPhone: string | null;
  contactEmail: string | null;
  address: string;
  city: string | null;
  state: string | null;
  pincode: string | null;
  taxId: string | null;
  description: string | null;
  verificationStatus: ProviderVerificationStatus;
  logoImage: string | null;
  profileStatus: ProfileStatus;
  createdAt: Date;
  updatedAt: Date;
}

export interface SaveCustomerProfileInput {
  fullName?: string;
  email?: string;
  dateOfBirth?: string;
  city?: string;
  state?: string;
  pincode?: string;
  address?: string;
  profileImage?: string;
}

export interface SaveProviderProfileInput {
  businessName: string;
  contactPhone?: string;
  contactEmail?: string;
  address: string;
  city?: string;
  state?: string;
  pincode?: string;
  taxId?: string;
  description?: string;
  logoImage?: string;
}
