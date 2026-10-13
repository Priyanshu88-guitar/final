import { prisma } from '../database/prisma.js';
import { AppError } from '../utils/app-error.js';
import { customerProfileRepository, providerProfileRepository } from '../repositories/profile.repository.js';
import {
  CustomerProfileModel,
  ProviderProfileModel,
  SaveCustomerProfileInput,
  SaveProviderProfileInput,
  ProfileStatus,
} from '../models/profile.model.js';

export class ProfileService {
  private computeCustomerCompletion(fullName?: string | null, dob?: string | null, city?: string | null, state?: string | null, pincode?: string | null): ProfileStatus {
    if (fullName && dob && city && state && pincode) {
      return 'COMPLETE';
    }
    return 'INCOMPLETE';
  }

  private computeProviderCompletion(businessName?: string | null, address?: string | null, city?: string | null, state?: string | null, pincode?: string | null): ProfileStatus {
    if (businessName && address && city && state && pincode) {
      return 'COMPLETE';
    }
    return 'INCOMPLETE';
  }

  async getCustomerProfile(userId: string): Promise<CustomerProfileModel> {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { roles: true },
    });

    if (!user) {
      throw AppError.notFound('User not found');
    }

    const hasCustomerRole = user.roles.some((r) => r.role === 'CUSTOMER');
    if (!hasCustomerRole) {
      throw AppError.forbidden('User does not possess the CUSTOMER role');
    }

    const profile = await customerProfileRepository.findByUserId(userId);

    const fullName = profile?.fullName || user.fullName || null;
    const dob = profile?.dateOfBirth || null;
    const city = profile?.city || null;
    const state = profile?.state || null;
    const pincode = profile?.pincode || null;

    const profileStatus = this.computeCustomerCompletion(fullName, dob, city, state, pincode);

    return {
      id: profile?.id || '',
      userId: user.id,
      fullName,
      phoneNumber: user.phoneNumber,
      email: user.email,
      dateOfBirth: dob,
      city,
      state,
      pincode,
      address: profile?.address || null,
      profileImage: profile?.profileImage || null,
      profileStatus,
      createdAt: profile?.createdAt || user.createdAt,
      updatedAt: profile?.updatedAt || user.updatedAt,
    };
  }

  async saveCustomerProfile(userId: string, input: SaveCustomerProfileInput): Promise<CustomerProfileModel> {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { roles: true },
    });

    if (!user) {
      throw AppError.notFound('User not found');
    }

    const hasCustomerRole = user.roles.some((r) => r.role === 'CUSTOMER');
    if (!hasCustomerRole) {
      throw AppError.forbidden('User does not possess the CUSTOMER role');
    }

    const updated = await customerProfileRepository.upsertProfile(userId, input);

    const fullName = updated.fullName || updated.user.fullName || null;
    const dob = updated.dateOfBirth;
    const city = updated.city;
    const state = updated.state;
    const pincode = updated.pincode;

    const profileStatus = this.computeCustomerCompletion(fullName, dob, city, state, pincode);

    return {
      id: updated.id,
      userId: updated.userId,
      fullName,
      phoneNumber: updated.user.phoneNumber,
      email: updated.user.email,
      dateOfBirth: dob,
      city,
      state,
      pincode,
      address: updated.address,
      profileImage: updated.profileImage,
      profileStatus,
      createdAt: updated.createdAt,
      updatedAt: updated.updatedAt,
    };
  }

  async getProviderProfile(userId: string): Promise<ProviderProfileModel> {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { roles: true },
    });

    if (!user) {
      throw AppError.notFound('User not found');
    }

    const hasProviderRole = user.roles.some((r) => r.role === 'PROVIDER');
    if (!hasProviderRole) {
      throw AppError.forbidden('User does not possess the PROVIDER role');
    }

    const profile = await providerProfileRepository.findByUserId(userId);

    const businessName = profile?.businessName || '';
    const address = profile?.address || '';
    const city = profile?.city || null;
    const state = profile?.state || null;
    const pincode = profile?.pincode || null;

    const profileStatus = this.computeProviderCompletion(businessName, address, city, state, pincode);

    return {
      id: profile?.id || '',
      userId: user.id,
      businessName,
      contactPhone: profile?.contactPhone || user.phoneNumber,
      contactEmail: profile?.contactEmail || user.email,
      address,
      city,
      state,
      pincode,
      taxId: profile?.taxId || null,
      description: profile?.description || null,
      verificationStatus: (profile?.verificationStatus as 'PENDING' | 'VERIFIED' | 'REJECTED') || 'PENDING',
      logoImage: profile?.logoImage || null,
      profileStatus,
      createdAt: profile?.createdAt || user.createdAt,
      updatedAt: profile?.updatedAt || user.updatedAt,
    };
  }

  async saveProviderProfile(userId: string, input: SaveProviderProfileInput): Promise<ProviderProfileModel> {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { roles: true },
    });

    if (!user) {
      throw AppError.notFound('User not found');
    }

    const hasProviderRole = user.roles.some((r) => r.role === 'PROVIDER');
    if (!hasProviderRole) {
      throw AppError.forbidden('User does not possess the PROVIDER role');
    }

    const updated = await providerProfileRepository.upsertProfile(userId, input);

    const profileStatus = this.computeProviderCompletion(
      updated.businessName,
      updated.address,
      updated.city,
      updated.state,
      updated.pincode
    );

    return {
      id: updated.id,
      userId: updated.userId,
      businessName: updated.businessName,
      contactPhone: updated.contactPhone || updated.user.phoneNumber,
      contactEmail: updated.contactEmail || updated.user.email,
      address: updated.address,
      city: updated.city,
      state: updated.state,
      pincode: updated.pincode,
      taxId: updated.taxId,
      description: updated.description,
      verificationStatus: updated.verificationStatus as 'PENDING' | 'VERIFIED' | 'REJECTED',
      logoImage: updated.logoImage,
      profileStatus,
      createdAt: updated.createdAt,
      updatedAt: updated.updatedAt,
    };
  }

  async getSavedChargers(userId: string) {
    const saved = await prisma.savedCharger.findMany({
      where: { customerId: userId },
      include: {
        charger: {
          include: {
            station: true,
          },
        },
      },
    });
    return saved.map((s) => ({
      id: s.id,
      chargerId: s.chargerId,
      charger: s.charger,
      createdAt: s.createdAt,
    }));
  }

  async saveCharger(userId: string, chargerId: string) {
    const charger = await prisma.charger.findUnique({
      where: { id: chargerId },
    });
    if (!charger) {
      throw AppError.notFound('Charger not found');
    }

    const existing = await prisma.savedCharger.findUnique({
      where: {
        customerId_chargerId: {
          customerId: userId,
          chargerId,
        },
      },
    });

    if (existing) {
      return existing;
    }

    return await prisma.savedCharger.create({
      data: {
        customerId: userId,
        chargerId,
      },
      include: {
        charger: true,
      },
    });
  }

  async removeSavedCharger(userId: string, chargerId: string) {
    await prisma.savedCharger.deleteMany({
      where: {
        customerId: userId,
        chargerId,
      },
    });
    return { message: 'Saved charger removed successfully' };
  }

  async getCustomerVehicles(userId: string) {
    const profile = await customerProfileRepository.findByUserId(userId);
    if (!profile) throw AppError.notFound('Customer profile not found');

    return prisma.customerVehicle.findMany({
      where: { customerProfileId: profile.id },
      orderBy: { createdAt: 'desc' }
    });
  }

  async addCustomerVehicle(userId: string, input: any) {
    const profile = await customerProfileRepository.findByUserId(userId);
    if (!profile) throw AppError.notFound('Customer profile not found. Please complete profile setup first.');

    return prisma.customerVehicle.create({
      data: {
        customerProfileId: profile.id,
        make: input.make,
        model: input.model,
        type: input.type || 'TWO_WHEELER',
        batteryCapacity: input.batteryCapacity,
        connectorType: input.connectorType,
        mileage: input.mileage,
      }
    });
  }

  async getProviderSetupPhotos(userId: string) {
    const profile = await providerProfileRepository.findByUserId(userId);
    if (!profile) throw AppError.notFound('Provider profile not found');

    return prisma.providerSetupPhoto.findMany({
      where: { providerProfileId: profile.id },
      orderBy: { createdAt: 'desc' }
    });
  }

  async addProviderSetupPhoto(userId: string, input: any) {
    const profile = await providerProfileRepository.findByUserId(userId);
    if (!profile) throw AppError.notFound('Provider profile not found. Please complete profile setup first.');

    return prisma.providerSetupPhoto.create({
      data: {
        providerProfileId: profile.id,
        photoUrl: input.photoUrl,
        description: input.description,
      }
    });
  }
}

export const profileService = new ProfileService();
