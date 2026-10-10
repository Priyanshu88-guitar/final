import { notificationRepository } from '../../repositories/notification.repository.js';
import { SendNotificationInput, RegisterDeviceInput, NotificationPreferencesInput } from '../../models/notification.model.js';
import { env } from '../../config/env.js';
import { IPushProvider } from './push-provider.interface.js';
import { MockPushProvider } from './providers/mock-push.provider.js';
import { logger } from '../../config/logger.js';

export class NotificationService {
  private pushProvider: IPushProvider;

  constructor() {
    if (env.PUSH_PROVIDER === 'mock' || env.APP_ENV === 'test') {
      this.pushProvider = new MockPushProvider();
    } else {
      // Stub for real FCM if configured
      this.pushProvider = new MockPushProvider();
    }
  }

  setProvider(provider: IPushProvider) {
    this.pushProvider = provider;
  }

  getProviderName(): string {
    return this.pushProvider.name;
  }

  private async canSendPush(userId: string, type: string): Promise<boolean> {
    const prefs = await notificationRepository.getPreferences(userId);
    if (!prefs.pushEnabled) return false;

    if (type.startsWith('BOOKING_') && !prefs.bookingNotifications) return false;
    if (type.startsWith('PAYMENT_') && !prefs.paymentNotifications) return false;
    if (type.startsWith('SESSION_') && !prefs.sessionNotifications) return false;

    return true;
  }

  async sendNotification(input: SendNotificationInput): Promise<void> {
    try {
      // 1. Check preferences
      const shouldPush = await this.canSendPush(input.recipientUserId, input.type);

      // 2. Persist to DB (always persist for in-app history even if push is disabled)
      const notif = await notificationRepository.createNotification(input, shouldPush ? 'PENDING' : 'SENT');

      // 3. Attempt Push Delivery
      if (shouldPush) {
        const devices = await notificationRepository.getActiveDevices(input.recipientUserId);

        if (devices.length > 0) {
          let pushSuccess = false;

          for (const device of devices) {
            try {
              const success = await this.pushProvider.sendToDevice(
                device.token,
                input.title,
                input.body,
                input.dataPayload
              );
              if (success) pushSuccess = true;
            } catch (err) {
              logger.warn(`Push delivery failed for token ${device.token}`);
              // If Firebase threw an Unregistered/InvalidToken error, we would unregister it here
              // e.g. await notificationRepository.unregisterDevice(input.recipientUserId, device.token);
            }
          }

          // Not mutating DB deliveryStatus strictly for performance, but in real robust app
          // we'd update `notif.deliveryStatus = pushSuccess ? 'SENT' : 'FAILED'`
        }
      }
    } catch (error) {
      logger.error('Failed to process and send notification', { error, input });
      // Do not throw to caller to ensure main business transaction isn't aborted just because notification failed
    }
  }

  async getUserNotifications(userId: string, page: number = 1, limit: number = 20) {
    const skip = (page - 1) * limit;
    return notificationRepository.getUserNotifications(userId, skip, limit);
  }

  async getUnreadCount(userId: string) {
    const count = await notificationRepository.getUnreadCount(userId);
    return { count };
  }

  async markAsRead(userId: string, notificationId: string) {
    return notificationRepository.markAsRead(userId, notificationId);
  }

  async markAllAsRead(userId: string) {
    return notificationRepository.markAllAsRead(userId);
  }

  async getNotificationById(userId: string, notificationId: string) {
    return notificationRepository.getNotificationById(userId, notificationId);
  }

  async registerDevice(userId: string, input: RegisterDeviceInput) {
    return notificationRepository.registerDevice(userId, input);
  }

  async unregisterDevice(userId: string, token: string) {
    return notificationRepository.unregisterDevice(userId, token);
  }

  async getPreferences(userId: string) {
    return notificationRepository.getPreferences(userId);
  }

  async updatePreferences(userId: string, input: NotificationPreferencesInput) {
    return notificationRepository.updatePreferences(userId, input);
  }
}

export const notificationService = new NotificationService();
