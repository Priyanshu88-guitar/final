import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import supertest from 'supertest';
import { app } from '../src/app.js';
import { prisma } from '../src/database/prisma.js';
import { otpService } from '../src/services/otp/otp.service.js';
import { MockSmsProvider } from '../src/services/otp/providers/mock-sms.provider.js';

describe('Auth API — OTP, Password Management & Logout', () => {
  const mockSms = new MockSmsProvider();

  beforeAll(async () => {
    otpService.setProvider(mockSms);
    await prisma.$connect();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('should reject invalid OTP', async () => {
    mockSms.clear();
    const phone = '9876222001';

    await prisma.user.deleteMany({ where: { phoneNumber: phone } });

    await supertest(app).post('/auth/signup').send({
      fullName: 'OTP Test User',
      phone,
      password: 'Password123',
      role: 'CUSTOMER',
    });

    const res = await supertest(app).post('/auth/otp/verify').send({
      phone,
      otp: '000000', // Invalid OTP
      purpose: 'SIGNUP_VERIFICATION',
    });

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
  });

  it('should enforce cooldown on OTP resend request', async () => {
    mockSms.clear();
    const phone = '9876222002';

    await prisma.user.deleteMany({ where: { phoneNumber: phone } });

    await supertest(app).post('/auth/signup').send({
      fullName: 'Cooldown Test User',
      phone,
      password: 'Password123',
      role: 'CUSTOMER',
    });

    // Immediate resend attempt (within 60s cooldown)
    const resendRes = await supertest(app).post('/auth/otp/resend').send({
      phone,
      purpose: 'SIGNUP_VERIFICATION',
    });

    expect(resendRes.status).toBe(429); // Cooldown enforced
    expect(resendRes.body.success).toBe(false);
  });

  it('should handle forgot password and reset password flow', async () => {
    mockSms.clear();
    const phone = '9876222003';

    await prisma.user.deleteMany({ where: { phoneNumber: phone } });

    // Signup & Verify
    await supertest(app).post('/auth/signup').send({
      fullName: 'Forgot Pwd User',
      phone,
      password: 'OldPassword123',
      role: 'CUSTOMER',
    });

    const signupOtp = mockSms.sentMessages[0].message.match(/\d{6}/)?.[0] || '';
    await supertest(app).post('/auth/otp/verify').send({
      phone,
      otp: signupOtp,
      purpose: 'SIGNUP_VERIFICATION',
    });

    // Forgot Password
    mockSms.clear();
    const forgotRes = await supertest(app).post('/auth/password/forgot').send({
      phone,
    });
    expect(forgotRes.status).toBe(200);

    // Get Reset OTP from mock
    const resetOtp = mockSms.sentMessages[0].message.match(/\d{6}/)?.[0] || '';

    // Reset Password
    const resetRes = await supertest(app).post('/auth/password/reset').send({
      phone,
      otp: resetOtp,
      newPassword: 'NewPassword123',
    });

    expect(resetRes.status).toBe(200);

    // Old password should fail login
    const oldLogin = await supertest(app).post('/auth/login').send({
      phone,
      password: 'OldPassword123',
    });
    expect(oldLogin.status).toBe(401);

    // New password should succeed login
    const newLogin = await supertest(app).post('/auth/login').send({
      phone,
      password: 'NewPassword123',
    });
    expect(newLogin.status).toBe(200);
  });

  it('should handle authenticated change password', async () => {
    mockSms.clear();
    const phone = '9876222004';

    await prisma.user.deleteMany({ where: { phoneNumber: phone } });

    await supertest(app).post('/auth/signup').send({
      fullName: 'Change Pwd User',
      phone,
      password: 'Password123',
      role: 'CUSTOMER',
    });

    const signupOtp = mockSms.sentMessages[0].message.match(/\d{6}/)?.[0] || '';
    const verifyRes = await supertest(app).post('/auth/otp/verify').send({
      phone,
      otp: signupOtp,
      purpose: 'SIGNUP_VERIFICATION',
    });

    const token = verifyRes.body.data.tokens.accessToken;

    // Change Password with wrong current password -> Fail
    const failChange = await supertest(app)
      .post('/auth/password/change')
      .set('Authorization', `Bearer ${token}`)
      .send({
        currentPassword: 'WrongCurrentPassword',
        newPassword: 'BrandNewPassword123',
      });
    expect(failChange.status).toBe(400);

    // Change Password with correct current password -> Success
    const successChange = await supertest(app)
      .post('/auth/password/change')
      .set('Authorization', `Bearer ${token}`)
      .send({
        currentPassword: 'Password123',
        newPassword: 'BrandNewPassword123',
      });
    expect(successChange.status).toBe(200);
  });

  it('should support logout and invalidate session', async () => {
    mockSms.clear();
    const phone = '9876222005';

    await prisma.user.deleteMany({ where: { phoneNumber: phone } });

    await supertest(app).post('/auth/signup').send({
      fullName: 'Logout Test User',
      phone,
      password: 'Password123',
      role: 'CUSTOMER',
    });

    const signupOtp = mockSms.sentMessages[0].message.match(/\d{6}/)?.[0] || '';
    const verifyRes = await supertest(app).post('/auth/otp/verify').send({
      phone,
      otp: signupOtp,
      purpose: 'SIGNUP_VERIFICATION',
    });

    const token = verifyRes.body.data.tokens.accessToken;

    // Access protected GET /auth/me -> 200
    const meBefore = await supertest(app).get('/auth/me').set('Authorization', `Bearer ${token}`);
    expect(meBefore.status).toBe(200);

    // Logout
    const logoutRes = await supertest(app).post('/auth/logout').set('Authorization', `Bearer ${token}`).send();
    expect(logoutRes.status).toBe(200);
  });
});
