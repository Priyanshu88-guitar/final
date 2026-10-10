import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import supertest from 'supertest';
import { app } from '../src/app.js';
import { prisma } from '../src/database/prisma.js';
import { otpService } from '../src/services/otp/otp.service.js';
import { MockSmsProvider } from '../src/services/otp/providers/mock-sms.provider.js';

describe('Customer Profile API', () => {
  const mockSms = new MockSmsProvider();

  beforeAll(async () => {
    otpService.setProvider(mockSms);
    await prisma.$connect();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  async function createVerifiedCustomer(phone: string) {
    await prisma.user.deleteMany({ where: { phoneNumber: phone } });

    await supertest(app).post('/auth/signup').send({
      fullName: 'Customer Test',
      phone,
      password: 'Password123',
      role: 'CUSTOMER',
    });

    const otp = mockSms.sentMessages[mockSms.sentMessages.length - 1].message.match(/\d{6}/)?.[0] || '';
    const verifyRes = await supertest(app).post('/auth/otp/verify').send({
      phone,
      otp,
      purpose: 'SIGNUP_VERIFICATION',
    });

    return verifyRes.body.data.tokens.accessToken as string;
  }

  it('should reject unauthenticated request to customer profile (401)', async () => {
    const res = await supertest(app).get('/customer/profile');
    expect(res.status).toBe(401);
  });

  it('should return initial incomplete profile for new verified customer', async () => {
    const phone = '9876444001';
    const token = await createVerifiedCustomer(phone);

    const res = await supertest(app).get('/customer/profile').set('Authorization', `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.phoneNumber).toBe(phone);
    expect(res.body.data.profileStatus).toBe('INCOMPLETE');
  });

  it('should allow customer to update own profile and compute profileStatus = COMPLETE', async () => {
    const phone = '9876444002';
    const token = await createVerifiedCustomer(phone);

    const updateRes = await supertest(app)
      .put('/customer/profile')
      .set('Authorization', `Bearer ${token}`)
      .send({
        fullName: 'Aarav Mehta',
        email: 'aarav@example.com',
        dateOfBirth: '15/08/1995',
        city: 'Mumbai',
        state: 'Maharashtra',
        pincode: '400001',
        address: '123 Marine Drive',
      });

    expect(updateRes.status).toBe(200);
    expect(updateRes.body.success).toBe(true);
    expect(updateRes.body.data.fullName).toBe('Aarav Mehta');
    expect(updateRes.body.data.city).toBe('Mumbai');
    expect(updateRes.body.data.pincode).toBe('400001');
    expect(updateRes.body.data.profileStatus).toBe('COMPLETE');
  });

  it('should reject date of birth in the future (422)', async () => {
    const phone = '9876444003';
    const token = await createVerifiedCustomer(phone);

    const res = await supertest(app)
      .put('/customer/profile')
      .set('Authorization', `Bearer ${token}`)
      .send({
        dateOfBirth: '01/01/2099', // Future date
      });

    expect(res.status).toBe(422);
    expect(res.body.success).toBe(false);
  });

  it('should reject invalid Indian pincode (422)', async () => {
    const phone = '9876444004';
    const token = await createVerifiedCustomer(phone);

    const res = await supertest(app)
      .put('/customer/profile')
      .set('Authorization', `Bearer ${token}`)
      .send({
        pincode: '12345', // 5 digits instead of 6
      });

    expect(res.status).toBe(422);
    expect(res.body.success).toBe(false);
  });

  it('should reject names containing numbers (422)', async () => {
    const phone = '9876444005';
    const token = await createVerifiedCustomer(phone);

    const res = await supertest(app)
      .put('/customer/profile')
      .set('Authorization', `Bearer ${token}`)
      .send({
        fullName: 'Rahul123',
      });

    expect(res.status).toBe(422);
    expect(res.body.success).toBe(false);
  });
});
