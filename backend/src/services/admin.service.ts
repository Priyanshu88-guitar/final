import { adminRepository } from '../repositories/admin.repository.js';
import { AppError } from '../utils/app-error.js';
import { notificationService } from './notification/notification.service.js';

export class AdminService {
  async getDashboardMetrics() {
    return adminRepository.getDashboardMetrics();
  }

  async getUsers(page: number, limit: number, roleFilter?: string) {
    const skip = (page - 1) * limit;
    const { items, total } = await adminRepository.getUsers(skip, limit, roleFilter);
    return {
      items,
      meta: {
        totalCount: total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      }
    };
  }

  async updateUserStatus(adminId: string, userId: string, status: string) {
    // Prevent an admin from disabling themselves to avoid locking the system
    if (adminId === userId) {
      throw AppError.badRequest('Admins cannot change their own account status through this endpoint');
    }
    const updated = await adminRepository.updateUserStatus(adminId, userId, status);

    // Notify user of account suspension
    if (status === 'SUSPENDED' || status === 'DISABLED') {
       await notificationService.sendNotification({
         recipientUserId: userId,
         type: 'SECURITY_ALERT' as any,
         title: 'Account Status Update',
         body: `Your account has been marked as ${status}. Contact support if this is a mistake.`
       });
    }

    return updated;
  }

  async getProviders(page: number, limit: number) {
    const skip = (page - 1) * limit;
    const { items, total } = await adminRepository.getProviders(skip, limit);
    return {
      items,
      meta: {
        totalCount: total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      }
    };
  }

  async updateProviderVerification(adminId: string, providerUserId: string, status: string, setupStatus?: string) {
    const updated = await adminRepository.updateProviderVerification(adminId, providerUserId, status, setupStatus);

    await notificationService.sendNotification({
      recipientUserId: providerUserId,
      type: 'PROVIDER_VERIFICATION_UPDATE' as any,
      title: 'Provider Verification Update',
      body: `Your provider account verification status is now: ${status}.`
    });

    return updated;
  }

  async getStations(page: number, limit: number) {
    const skip = (page - 1) * limit;
    const { items, total } = await adminRepository.getStations(skip, limit);
    return {
      items,
      meta: {
        totalCount: total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      }
    };
  }

  async getBookings(page: number, limit: number) {
    const skip = (page - 1) * limit;
    const { items, total } = await adminRepository.getBookings(skip, limit);
    return {
      items,
      meta: {
        totalCount: total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      }
    };
  }
}

export const adminService = new AdminService();
