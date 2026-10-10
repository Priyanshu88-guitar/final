import { prisma } from '../database/prisma.js';
import { SendNotificationInput, RegisterDeviceInput, NotificationPreferencesInput } from '../models/notification.model.js';
import { AppError } from '../utils/app-error.js';

export class NotificationRepository {

  async createNotification(input: SendNotificationInput, deliveryStatus: 'PENDING' | 'SENT' | 'FAILED' = 'PENDING') {
    return prisma.notification.create({
      data: {
        recipientUserId: input.recipientUserId,
        type: input.type,
        title: input.title,
        body: input.body,
        dataPayload: input.dataPayload ? JSON.stringify(input.dataPayload) : null,
        relatedEntityId: input.relatedEntityId,
        relatedEntityType: input.relatedEntityType,
        deliveryStatus,
      },
    });
  }

  async getUserNotifications(userId: string, skip: number = 0, take: number = 20) {
    const [items, totalCount, unreadCount] = await Promise.all([
      prisma.notification.findMany({
        where: { recipientUserId: userId },
        orderBy: { createdAt: 'desc' },
        skip,
        take,
      }),
      prisma.notification.count({ where: { recipientUserId: userId } }),
      prisma.notification.count({ where: { recipientUserId: userId, isRead: false } }),
    ]);

    return {
      items,
      meta: {
        totalCount,
        unreadCount,
        page: Math.floor(skip / take) + 1,
        limit: take,
        totalPages: Math.ceil(totalCount / take),
      }
    };
  }

  async getUnreadCount(userId: string) {
    return prisma.notification.count({
      where: { recipientUserId: userId, isRead: false },
    });
  }

  async markAsRead(userId: string, notificationId: string) {
    const notification = await prisma.notification.findFirst({
      where: { id: notificationId, recipientUserId: userId },
    });

    if (!notification) {
      throw AppError.notFound('Notification not found');
    }

    if (notification.isRead) return notification;

    return prisma.notification.update({
      where: { id: notificationId },
      data: { isRead: true, readAt: new Date() },
    });
  }

  async markAllAsRead(userId: string) {
    return prisma.notification.updateMany({
      where: { recipientUserId: userId, isRead: false },
      data: { isRead: true, readAt: new Date() },
    });
  }

  async getNotificationById(userId: string, notificationId: string) {
    const notif = await prisma.notification.findFirst({
      where: { id: notificationId, recipientUserId: userId },
    });
    if (!notif) throw AppError.notFound('Notification not found');
    return notif;
  }

  // --- Device Management ---

  async registerDevice(userId: string, input: RegisterDeviceInput) {
    return prisma.deviceToken.upsert({
      where: { token: input.token },
      create: {
        userId,
        token: input.token,
        platform: input.platform,
        deviceMeta: input.deviceMeta,
        isActive: true,
      },
      update: {
        userId, // reassigned if user logs out and someone else logs in on same device
        isActive: true,
        lastUsedAt: new Date(),
      },
    });
  }

  async unregisterDevice(userId: string, token: string) {
    return prisma.deviceToken.updateMany({
      where: { userId, token },
      data: { isActive: false },
    });
  }

  async getActiveDevices(userId: string) {
    return prisma.deviceToken.findMany({
      where: { userId, isActive: true },
    });
  }

  // --- Preferences ---

  async getPreferences(userId: string) {
    let prefs = await prisma.notificationPreference.findUnique({
      where: { userId },
    });

    if (!prefs) {
      prefs = await prisma.notificationPreference.create({
        data: { userId },
      });
    }

    return prefs;
  }

  async updatePreferences(userId: string, input: NotificationPreferencesInput) {
    return prisma.notificationPreference.upsert({
      where: { userId },
      create: {
        userId,
        pushEnabled: input.pushEnabled ?? true,
        bookingNotifications: input.bookingNotifications ?? true,
        paymentNotifications: input.paymentNotifications ?? true,
        sessionNotifications: input.sessionNotifications ?? true,
        promotionalEmails: input.promotionalEmails ?? false,
      },
      update: {
        ...(input.pushEnabled !== undefined && { pushEnabled: input.pushEnabled }),
        ...(input.bookingNotifications !== undefined && { bookingNotifications: input.bookingNotifications }),
        ...(input.paymentNotifications !== undefined && { paymentNotifications: input.paymentNotifications }),
        ...(input.sessionNotifications !== undefined && { sessionNotifications: input.sessionNotifications }),
        ...(input.promotionalEmails !== undefined && { promotionalEmails: input.promotionalEmails }),
      },
    });
  }
}

export const notificationRepository = new NotificationRepository();
