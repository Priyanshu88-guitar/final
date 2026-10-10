import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import supertest from 'supertest';
import { app } from '../src/app.js';
import { prisma } from '../src/database/prisma.js';
import { otpService } from '../src/services/otp/otp.service.js';
import { MockSmsProvider } from '../src/services/otp/providers/mock-sms.provider.js';
import { notificationService } from '../src/services/notification/notification.service.js';
import { MockPushProvider } from '../src/services/notification/providers/mock-push.provider.js';

describe('Notifications & Communication API', () => {
  const mockSms = new MockSmsProvider();
  const mockPush = new MockPushProvider();
  let userToken: string;
  let userId: string;

  beforeAll(async () => {
    otpService.setProvider(mockSms);
    notificationService.setProvider(mockPush);
    await prisma.$connect();

    // Clean DB
    await prisma.notification.deleteMany();
    await prisma.deviceToken.deleteMany();
    await prisma.notificationPreference.deleteMany();

    // Setup Test User
    mockSms.clear();
    const phone = '9876000100';
    await prisma.otpVerification.deleteMany({ where: { phoneNumber: phone } });
    await prisma.user.deleteMany({ where: { phoneNumber: phone } });

    await supertest(app).post('/auth/signup').send({ fullName: 'Notify User', phone, password: 'Password123', role: 'CUSTOMER' });
    const otp = mockSms.sentMessages[mockSms.sentMessages.length - 1].message.match(/\d{6}/)?.[0] || '';
    const res = await supertest(app).post('/auth/otp/verify').send({ phone, otp, purpose: 'SIGNUP_VERIFICATION' });

    userToken = res.body.data.tokens.accessToken;
    userId = res.body.data.user.id;
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('should allow user to update preferences', async () => {
    // Implicitly creates on upsert via service
    const res = await supertest(app)
      .patch('/notifications/preferences')
      .set('Authorization', `Bearer ${userToken}`)
      .send({ promotionalEmails: true, bookingNotifications: false });

    expect(res.status).toBe(200);
    expect(res.body.data.promotionalEmails).toBe(true);
    expect(res.body.data.bookingNotifications).toBe(false);
  });

  it('should return current preferences correctly', async () => {
    const res = await supertest(app).get('/notifications/preferences').set('Authorization', `Bearer ${userToken}`);
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.pushEnabled).toBe(true);
  });

  it('should allow user to register a device token', async () => {
    const res = await supertest(app)
      .post('/notifications/devices/register')
      .set('Authorization', `Bearer ${userToken}`)
      .send({ token: 'test-fcm-token-123', platform: 'android' });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
  });

  it('should correctly intercept notifications based on preferences (push disabled via booking setting)', async () => {
    mockPush.clear();

    await notificationService.sendNotification({
      recipientUserId: userId,
      type: 'BOOKING_CREATED',
      title: 'Booking Created',
      body: 'Your booking is successful',
      dataPayload: { bookingId: 'dummy-booking' },
    });

    expect(mockPush.sentPushes.length).toBe(0);

    const dbNotifs = await prisma.notification.findMany({ where: { recipientUserId: userId } });
    expect(dbNotifs.length).toBe(1);
    expect(dbNotifs[0].title).toBe('Booking Created');
  });

  it('should retrieve paginated in-app notifications', async () => {
    const res = await supertest(app)
      .get('/notifications?page=1&limit=10')
      .set('Authorization', `Bearer ${userToken}`);

    expect(res.status).toBe(200);
    expect(res.body.data.items).toBeInstanceOf(Array);
    expect(res.body.data.items.length).toBe(1);
    expect(res.body.data.meta.unreadCount).toBe(1);
  });

  it('should mark a specific notification as read', async () => {
    const notifs = await supertest(app).get('/notifications').set('Authorization', `Bearer ${userToken}`);
    const notifId = notifs.body.data.items[0].id;

    const res = await supertest(app)
      .patch(`/notifications/${notifId}/read`)
      .set('Authorization', `Bearer ${userToken}`);

    expect(res.status).toBe(200);
    expect(res.body.data.isRead).toBe(true);

    const checkCount = await supertest(app).get('/notifications/unread-count').set('Authorization', `Bearer ${userToken}`);
    expect(checkCount.body.data.count).toBe(0);
  });

  it('should allow user to unregister a device', async () => {
    const res = await supertest(app)
      .post('/notifications/devices/unregister')
      .set('Authorization', `Bearer ${userToken}`)
      .send({ token: 'test-fcm-token-123' });

    expect(res.status).toBe(200);

    const activeDevices = await prisma.deviceToken.findMany({ where: { userId, isActive: true } });
    expect(activeDevices.length).toBe(0);
  });

  it('should enforce IDOR protection on notifications (cannot mark another users notification as read)', async () => {
    mockSms.clear();
    const phoneB = '9876000101';
    await prisma.otpVerification.deleteMany({ where: { phoneNumber: phoneB } });
    await prisma.user.deleteMany({ where: { phoneNumber: phoneB } });

    await supertest(app).post('/auth/signup').send({ fullName: 'User B', phone: phoneB, password: 'Password123', role: 'CUSTOMER' });
    const otpB = mockSms.sentMessages[mockSms.sentMessages.length - 1].message.match(/\d{6}/)?.[0] || '';
    const resB = await supertest(app).post('/auth/otp/verify').send({ phone: phoneB, otp: otpB, purpose: 'SIGNUP_VERIFICATION' });
    const tokenB = resB.body.data.tokens.accessToken;

    const notifsA = await supertest(app).get('/notifications').set('Authorization', `Bearer ${userToken}`);
    const notifAId = notifsA.body.data.items[0].id;

    const hackRes = await supertest(app)
      .patch(`/notifications/${notifAId}/read`)
      .set('Authorization', `Bearer ${tokenB}`);

    expect(hackRes.status).toBe(404);
  });
});
