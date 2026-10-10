import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import supertest from 'supertest';
import { app } from '../src/app.js';
import { prisma } from '../src/database/prisma.js';
import { otpService } from '../src/services/otp/otp.service.js';
import { MockSmsProvider } from '../src/services/otp/providers/mock-sms.provider.js';

describe('Auth API — Authorization & Multi-Role Support', () => {
  const mockSms = new MockSmsProvider();

  beforeAll(async () => {
    otpService.setProvider(mockSms);
    await prisma.$connect();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('should reject unauthenticated request to protected endpoint (401)', async () => {
    const res = await supertest(app).get('/auth/me');
    expect(res.status).toBe(401);
  });

  it('should reject invalid Bearer token (401)', async () => {
    const res = await supertest(app).get('/auth/me').set('Authorization', 'Bearer invalid.jwt.token');
    expect(res.status).toBe(401);
  });

  it('should enforce role authorization: Customer cannot access Provider-only or Admin-only endpoints', async () => {
    mockSms.clear();
    const phone = '9876333001';

    await prisma.user.deleteMany({ where: { phoneNumber: phone } });

    // Customer Signup
    await supertest(app).post('/auth/signup').send({
      fullName: 'Customer Only',
      phone,
      password: 'Password123',
      role: 'CUSTOMER',
    });

    const otp = mockSms.sentMessages[0].message.match(/\d{6}/)?.[0] || '';
    const verifyRes = await supertest(app).post('/auth/otp/verify').send({
      phone,
      otp,
      purpose: 'SIGNUP_VERIFICATION',
    });

    const customerToken = verifyRes.body.data.tokens.accessToken;

    // Access Customer endpoint -> Allowed (200)
    const customerAccess = await supertest(app)
      .get('/auth/protected/customer-only')
      .set('Authorization', `Bearer ${customerToken}`);
    expect(customerAccess.status).toBe(200);

    // Access Provider endpoint -> Forbidden (403)
    const providerAccess = await supertest(app)
      .get('/auth/protected/provider-only')
      .set('Authorization', `Bearer ${customerToken}`);
    expect(providerAccess.status).toBe(403);

    // Access Admin endpoint -> Forbidden (403)
    const adminAccess = await supertest(app)
      .get('/auth/protected/admin-only')
      .set('Authorization', `Bearer ${customerToken}`);
    expect(adminAccess.status).toBe(403);
  });

  it('should support Multi-Role User (Customer + Provider on same user ID)', async () => {
    mockSms.clear();
    const phone = '9876333002';

    await prisma.user.deleteMany({ where: { phoneNumber: phone } });

    // Step 1: Signup as CUSTOMER
    const res1 = await supertest(app).post('/auth/signup').send({
      fullName: 'Multi Role User',
      phone,
      password: 'Password123',
      role: 'CUSTOMER',
    });
    const userId1 = res1.body.data.userId;

    // Step 2: Signup as PROVIDER with same phone number
    mockSms.clear();
    const res2 = await supertest(app).post('/auth/signup').send({
      fullName: 'Multi Role User',
      phone,
      password: 'Password123',
      role: 'PROVIDER',
    });
    const userId2 = res2.body.data.userId;

    // Must be the SAME User ID!
    expect(userId1).toBe(userId2);

    // Verify OTP
    const otp = mockSms.sentMessages[0].message.match(/\d{6}/)?.[0] || '';
    const verifyRes = await supertest(app).post('/auth/otp/verify').send({
      phone,
      otp,
      purpose: 'SIGNUP_VERIFICATION',
    });

    const multiRoleToken = verifyRes.body.data.tokens.accessToken;
    const userRoles = verifyRes.body.data.user.roles;

    expect(userRoles).toContain('CUSTOMER');
    expect(userRoles).toContain('PROVIDER');

    // Multi-role user can access BOTH Customer and Provider endpoints!
    const customerAccess = await supertest(app)
      .get('/auth/protected/customer-only')
      .set('Authorization', `Bearer ${multiRoleToken}`);
    expect(customerAccess.status).toBe(200);

    const providerAccess = await supertest(app)
      .get('/auth/protected/provider-only')
      .set('Authorization', `Bearer ${multiRoleToken}`);
    expect(providerAccess.status).toBe(200);

    // Multi-role user CANNOT access Admin endpoint
    const adminAccess = await supertest(app)
      .get('/auth/protected/admin-only')
      .set('Authorization', `Bearer ${multiRoleToken}`);
    expect(adminAccess.status).toBe(403);
  });

  it('should reject client attempting to request unpossessed active role context (X-Active-Role: ADMIN)', async () => {
    mockSms.clear();
    const phone = '9876333003';

    await prisma.user.deleteMany({ where: { phoneNumber: phone } });

    await supertest(app).post('/auth/signup').send({
      fullName: 'Privilege Escalation Test',
      phone,
      password: 'Password123',
      role: 'CUSTOMER',
    });

    const otp = mockSms.sentMessages[0].message.match(/\d{6}/)?.[0] || '';
    const verifyRes = await supertest(app).post('/auth/otp/verify').send({
      phone,
      otp,
      purpose: 'SIGNUP_VERIFICATION',
    });

    const token = verifyRes.body.data.tokens.accessToken;

    // Send header X-Active-Role: ADMIN without having ADMIN role in database -> Forbidden (403)
    const escRes = await supertest(app)
      .get('/auth/me')
      .set('Authorization', `Bearer ${token}`)
      .set('X-Active-Role', 'ADMIN');

    expect(escRes.status).toBe(403);
    expect(escRes.body.success).toBe(false);
  });
});
