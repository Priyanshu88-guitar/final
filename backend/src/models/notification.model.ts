export type NotificationType =
  // Booking events
  | 'BOOKING_CREATED'
  | 'BOOKING_CONFIRMED'
  | 'BOOKING_REJECTED'
  | 'BOOKING_CANCELLED'
  | 'BOOKING_COMPLETED'
  // Session events
  | 'SESSION_STARTED'
  | 'SESSION_COMPLETED'
  | 'SESSION_FAILED'
  // Financial events
  | 'PAYMENT_SUCCESS'
  | 'PAYMENT_FAILED'
  | 'PAYOUT_PROCESSED'
  // Provider events
  | 'NEW_BOOKING_REQUEST';

export type DeliveryStatus = 'PENDING' | 'SENT' | 'FAILED';

export interface NotificationPayload {
  screen?: string;
  bookingId?: string;
  sessionId?: string;
  paymentId?: string;
  payoutId?: string;
  [key: string]: any;
}

export interface SendNotificationInput {
  recipientUserId: string;
  type: NotificationType;
  title: string;
  body: string;
  dataPayload?: NotificationPayload;
  relatedEntityId?: string;
  relatedEntityType?: string;
}

export interface RegisterDeviceInput {
  token: string;
  platform: 'android' | 'ios' | 'web';
  deviceMeta?: string;
}

export interface NotificationPreferencesInput {
  pushEnabled?: boolean;
  bookingNotifications?: boolean;
  paymentNotifications?: boolean;
  sessionNotifications?: boolean;
  promotionalEmails?: boolean;
}
