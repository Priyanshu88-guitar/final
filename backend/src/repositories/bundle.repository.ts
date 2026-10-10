import { prisma } from '../database/prisma.js';
import { AppError } from '../utils/app-error.js';

export class BundleRepository {
  async getActiveBundles() {
    return prisma.bundle.findMany({
      where: { status: 'ACTIVE' },
      orderBy: { price: 'asc' },
    });
  }

  async getBundleById(id: string) {
    const bundle = await prisma.bundle.findFirst({
      where: { id, status: 'ACTIVE' },
    });
    if (!bundle) throw AppError.notFound('Bundle not found or inactive');
    return bundle;
  }

  async createBundlePurchase(customerId: string, bundleId: string) {
    // Basic protection: do not allow if they already have an active purchase of the same bundle
    const activePurchase = await prisma.bundlePurchase.findFirst({
      where: { customerId, bundleId, status: 'ACTIVE' }
    });

    if (activePurchase) {
       throw AppError.conflict('You already have an active subscription for this bundle');
    }

    return prisma.bundlePurchase.create({
      data: {
        customerId,
        bundleId,
        status: 'PENDING',
      },
      include: {
        bundle: true
      }
    });
  }

  async getCustomerBundlePurchases(customerId: string) {
    return prisma.bundlePurchase.findMany({
      where: { customerId },
      include: { bundle: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getCustomerBundlePurchaseById(customerId: string, purchaseId: string) {
    const purchase = await prisma.bundlePurchase.findFirst({
      where: { id: purchaseId, customerId },
      include: { bundle: true, payment: true },
    });
    if (!purchase) throw AppError.notFound('Bundle purchase not found');
    return purchase;
  }
}

export const bundleRepository = new BundleRepository();
