import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import supertest from 'supertest';
import { app } from '../src/app.js';
import { prisma } from '../src/database/prisma.js';
import { otpService } from '../src/services/otp/otp.service.js';
import { MockSmsProvider } from '../src/services/otp/providers/mock-sms.provider.js';

describe('Auth API — Signup & Login', () => {
  const mockSms = new MockSmsProvider();

  beforeAll(async () => {
    otpService.setProvider(mockSms);
    await prisma.$connect();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('should allow valid Customer signup and generate verification OTP', async () => {
    mockSms.clear();
    const phone = '9876111001';

    await prisma.otpVerification.deleteMany({ where: { phoneNumber: phone } });
    await prisma.user.deleteMany({ where: { phoneNumber: phone } });

    const res = await supertest(app).post('/auth/signup').send({
      fullName: 'Rahul Sharma',
      phone,
      email: 'rahul@example.com',
      password: 'Password123',
      role: 'CUSTOMER',
    });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toHaveProperty('userId');

    // Check SMS was triggered
    expect(mockSms.sentMessages.length).toBe(1);
    expect(mockSms.sentMessages[0].phoneNumber).toBe(phone);
  });

  it('should allow valid Provider signup', async () => {
    mockSms.clear();
    const phone = '9876111002';

    await prisma.otpVerification.deleteMany({ where: { phoneNumber: phone } });
    await prisma.user.deleteMany({ where: { phoneNumber: phone } });

    const res = await supertest(app).post('/auth/signup').send({
      fullName: 'Vikram Singh',
      phone,
      password: 'Password123',
      role: 'PROVIDER',
    });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
  });

  it('should reject attempted public ADMIN signup', async () => {
    const res = await supertest(app).post('/auth/signup').send({
      fullName: 'Hacker Admin',
      phone: '9876111003',
      password: 'Password123',
      role: 'ADMIN',
    });

    expect(res.status).toBe(422); // Validation error: admin not in allowed enum for public signup
    expect(res.body.success).toBe(false);
  });

  it('should reject signup with invalid 9-digit phone number', async () => {
    const res = await supertest(app).post('/auth/signup').send({
      fullName: 'Invalid Phone',
      phone: '987654321',
      password: 'Password123',
      role: 'CUSTOMER',
    });

    expect(res.status).toBe(422);
    expect(res.body.success).toBe(false);
  });

  it('should reject signup with numbers in full name', async () => {
    const res = await supertest(app).post('/auth/signup').send({
      fullName: 'John123 Doe',
      phone: '9876111004',
      password: 'Password123',
      role: 'CUSTOMER',
    });

    expect(res.status).toBe(422);
    expect(res.body.success).toBe(false);
  });

  it('should reject signup with weak password', async () => {
    const res = await supertest(app).post('/auth/signup').send({
      fullName: 'Weak Password',
      phone: '9876111005',
      password: '123',
      role: 'CUSTOMER',
    });

    expect(res.status).toBe(422);
    expect(res.body.success).toBe(false);
  });

  it('should allow login with valid credentials', async () => {
    mockSms.clear();
    const phone = '9876111099'; // Distinct phone number for login test

    await prisma.otpVerification.deleteMany({ where: { phoneNumber: phone } });
    await prisma.user.deleteMany({ where: { phoneNumber: phone } });

    // Signup
    const signupRes = await supertest(app).post('/auth/signup').send({
      fullName: 'Login Test User',
      phone,
      password: 'Password123',
      role: 'CUSTOMER',
    });

    expect(signupRes.status).toBe(201);

    // Extract OTP from mock provider
    const msg = mockSms.sentMessages[0].message;
    const otp = msg.match(/\d{6}/)?.[0] || '';

    // Verify OTP
    const verifyRes = await supertest(app).post('/auth/otp/verify').send({
      phone,
      otp,
      purpose: 'SIGNUP_VERIFICATION',
    });

    expect(verifyRes.status).toBe(200);

    // Login
    const loginRes = await supertest(app).post('/auth/login').send({
      phone,
      password: 'Password123',
    });

    expect(loginRes.status).toBe(200);
    expect(loginRes.body.success).toBe(true);
    expect(loginRes.body.data).toHaveProperty('tokens');
    expect(loginRes.body.data.tokens).toHaveProperty('accessToken');
    expect(loginRes.body.data.tokens).toHaveProperty('refreshToken');
    expect(loginRes.body.data.user.phoneNumber).toBe(phone);
  });

  it('should reject login with wrong password', async () => {
    const phone = '9876111099';

    const loginRes = await supertest(app).post('/auth/login').send({
      phone,
      password: 'WrongPassword123',
    });

    expect(loginRes.status).toBe(401);
    expect(loginRes.body.success).toBe(false);
  });

  it('should reject login for suspended account', async () => {
    const phone = '9876111007';

    await prisma.otpVerification.deleteMany({ where: { phoneNumber: phone } });
    await prisma.user.deleteMany({ where: { phoneNumber: phone } });

    const user = await prisma.user.create({
      data: {
        fullName: 'Suspended User',
        phoneNumber: phone,
        passwordHash: 'dummy',
        accountStatus: 'SUSPENDED',
      },
    });

    const loginRes = await supertest(app).post('/auth/login').send({
      phone,
      password: 'Password123',
    });

    expect(loginRes.status).toBe(403);
    expect(loginRes.body.success).toBe(false);

    await prisma.user.delete({ where: { id: user.id } });
  });
});
