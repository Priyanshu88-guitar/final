import { bundleRepository } from '../repositories/bundle.repository.js';
import { paymentService } from './payment/payment.service.js';

export class BundleService {
  async getActiveBundles() {
    return bundleRepository.getActiveBundles();
  }

  async getBundleById(id: string) {
    return bundleRepository.getBundleById(id);
  }

  async purchaseBundle(customerId: string, bundleId: string) {
    // Check exists
    await bundleRepository.getBundleById(bundleId);

    // Create PENDING purchase record
    const purchase = await bundleRepository.createBundlePurchase(customerId, bundleId);

    // Delegate payment creation
    const paymentOrder = await paymentService.createPaymentOrder(customerId, { bundlePurchaseId: purchase.id });

    return {
      purchaseId: purchase.id,
      paymentDetails: paymentOrder
    };
  }

  async getCustomerBundlePurchases(customerId: string) {
    return bundleRepository.getCustomerBundlePurchases(customerId);
  }

  async getCustomerBundlePurchaseById(customerId: string, purchaseId: string) {
    return bundleRepository.getCustomerBundlePurchaseById(customerId, purchaseId);
  }
}

export const bundleService = new BundleService();
