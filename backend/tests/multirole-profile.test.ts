import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import supertest from 'supertest';
import { app } from '../src/app.js';
import { prisma } from '../src/database/prisma.js';
import { otpService } from '../src/services/otp/otp.service.js';
import { MockSmsProvider } from '../src/services/otp/providers/mock-sms.provider.js';

describe('Multi-Role Profiles & Security / IDOR Protection', () => {
  const mockSms = new MockSmsProvider();

  beforeAll(async () => {
    otpService.setProvider(mockSms);
    await prisma.$connect();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('should allow single User to hold both CustomerProfile and ProviderProfile under the SAME userId', async () => {
    mockSms.clear();
    const phone = '9876666001';

    await prisma.user.deleteMany({ where: { phoneNumber: phone } });

    // Step 1: Signup as CUSTOMER
    const res1 = await supertest(app).post('/auth/signup').send({
      fullName: 'Dual Role Owner',
      phone,
      password: 'Password123',
      role: 'CUSTOMER',
    });
    const userId1 = res1.body.data.userId;

    // Step 2: Signup as PROVIDER with same phone
    mockSms.clear();
    const res2 = await supertest(app).post('/auth/signup').send({
      fullName: 'Dual Role Owner',
      phone,
      password: 'Password123',
      role: 'PROVIDER',
    });
    const userId2 = res2.body.data.userId;

    expect(userId1).toBe(userId2); // Same User ID!

    // Verify OTP
    const otp = mockSms.sentMessages[0].message.match(/\d{6}/)?.[0] || '';
    const verifyRes = await supertest(app).post('/auth/otp/verify').send({
      phone,
      otp,
      purpose: 'SIGNUP_VERIFICATION',
    });

    const token = verifyRes.body.data.tokens.accessToken;

    // Save Customer Profile
    const custRes = await supertest(app)
      .put('/customer/profile')
      .set('Authorization', `Bearer ${token}`)
      .send({
        fullName: 'Dual Role Customer',
        city: 'Pune',
        state: 'Maharashtra',
        pincode: '411001',
        dateOfBirth: '10/10/1990',
      });

    expect(custRes.status).toBe(200);
    expect(custRes.body.data.userId).toBe(userId1);

    // Save Provider Profile
    const provRes = await supertest(app)
      .put('/provider/profile')
      .set('Authorization', `Bearer ${token}`)
      .send({
        businessName: 'Dual Role EV Station',
        address: '100 MG Road',
        city: 'Pune',
        state: 'Maharashtra',
        pincode: '411001',
      });

    expect(provRes.status).toBe(200);
    expect(provRes.body.data.userId).toBe(userId1); // Same User ID!

    // Retrieve both profiles
    const getCust = await supertest(app).get('/customer/profile').set('Authorization', `Bearer ${token}`);
    expect(getCust.body.data.fullName).toBe('Dual Role Customer');

    const getProv = await supertest(app).get('/provider/profile').set('Authorization', `Bearer ${token}`);
    expect(getProv.body.data.businessName).toBe('Dual Role EV Station');
  });

  it('IDOR Protection: User A cannot modify User B profile even if attempting payload injection', async () => {
    mockSms.clear();

    // User A (Victim)
    const phoneA = '9876666002';
    await prisma.user.deleteMany({ where: { phoneNumber: phoneA } });
    await supertest(app).post('/auth/signup').send({
      fullName: 'User A Victim',
      phone: phoneA,
      password: 'Password123',
      role: 'CUSTOMER',
    });
    const otpA = mockSms.sentMessages[0].message.match(/\d{6}/)?.[0] || '';
    const verifyA = await supertest(app).post('/auth/otp/verify').send({ phone: phoneA, otp: otpA, purpose: 'SIGNUP_VERIFICATION' });
    const userA_id = verifyA.body.data.user.id;

    // User B (Attacker)
    mockSms.clear();
    const phoneB = '9876666003';
    await prisma.user.deleteMany({ where: { phoneNumber: phoneB } });
    await supertest(app).post('/auth/signup').send({
      fullName: 'User B Attacker',
      phone: phoneB,
      password: 'Password123',
      role: 'CUSTOMER',
    });
    const otpB = mockSms.sentMessages[0].message.match(/\d{6}/)?.[0] || '';
    const verifyB = await supertest(app).post('/auth/otp/verify').send({ phone: phoneB, otp: otpB, purpose: 'SIGNUP_VERIFICATION' });
    const tokenB = verifyB.body.data.tokens.accessToken;

    // User B attempts to send User A's userId in payload to update User A's profile
    const attackRes = await supertest(app)
      .put('/customer/profile')
      .set('Authorization', `Bearer ${tokenB}`)
      .send({
        userId: userA_id, // Injected target userId
        fullName: 'Hacked Name',
        city: 'Hacked City',
      });

    expect(attackRes.status).toBe(200);
    // Profile modified belongs to User B, NOT User A!
    expect(attackRes.body.data.userId).not.toBe(userA_id);
    expect(attackRes.body.data.userId).toBe(verifyB.body.data.user.id);
  });
});
