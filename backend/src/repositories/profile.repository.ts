import { prisma } from '../database/prisma.js';
import { SaveCustomerProfileInput, SaveProviderProfileInput } from '../models/profile.model.js';

export class CustomerProfileRepository {
  async findByUserId(userId: string) {
    return prisma.customerProfile.findUnique({
      where: { userId },
      include: { user: true },
    });
  }

  async upsertProfile(userId: string, input: SaveCustomerProfileInput) {
    // If email or fullName updated, sync with User record
    if (input.fullName || input.email) {
      await prisma.user.update({
        where: { id: userId },
        data: {
          ...(input.fullName && { fullName: input.fullName }),
          ...(input.email && { email: input.email }),
        },
      });
    }

    return prisma.customerProfile.upsert({
      where: { userId },
      create: {
        userId,
        fullName: input.fullName || null,
        dateOfBirth: input.dateOfBirth || null,
        city: input.city || null,
        state: input.state || null,
        pincode: input.pincode || null,
        address: input.address || null,
        profileImage: input.profileImage || null,
      },
      update: {
        ...(input.fullName !== undefined && { fullName: input.fullName }),
        ...(input.dateOfBirth !== undefined && { dateOfBirth: input.dateOfBirth }),
        ...(input.city !== undefined && { city: input.city }),
        ...(input.state !== undefined && { state: input.state }),
        ...(input.pincode !== undefined && { pincode: input.pincode }),
        ...(input.address !== undefined && { address: input.address }),
        ...(input.profileImage !== undefined && { profileImage: input.profileImage }),
      },
      include: { user: true },
    });
  }
}

export class ProviderProfileRepository {
  async findByUserId(userId: string) {
    return prisma.providerProfile.findUnique({
      where: { userId },
      include: { user: true },
    });
  }

  async upsertProfile(userId: string, input: SaveProviderProfileInput) {
    return prisma.providerProfile.upsert({
      where: { userId },
      create: {
        userId,
        businessName: input.businessName,
        contactPhone: input.contactPhone || null,
        contactEmail: input.contactEmail || null,
        address: input.address,
        city: input.city || null,
        state: input.state || null,
        pincode: input.pincode || null,
        taxId: input.taxId || null,
        description: input.description || null,
        logoImage: input.logoImage || null,
        verificationStatus: 'PENDING',
      },
      update: {
        businessName: input.businessName,
        ...(input.contactPhone !== undefined && { contactPhone: input.contactPhone }),
        ...(input.contactEmail !== undefined && { contactEmail: input.contactEmail }),
        ...(input.address !== undefined && { address: input.address }),
        ...(input.city !== undefined && { city: input.city }),
        ...(input.state !== undefined && { state: input.state }),
        ...(input.pincode !== undefined && { pincode: input.pincode }),
        ...(input.taxId !== undefined && { taxId: input.taxId }),
        ...(input.description !== undefined && { description: input.description }),
        ...(input.logoImage !== undefined && { logoImage: input.logoImage }),
      },
      include: { user: true },
    });
  }
}

export const customerProfileRepository = new CustomerProfileRepository();
export const providerProfileRepository = new ProviderProfileRepository();
