import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import supertest from 'supertest';
import { app } from '../src/app.js';
import { prisma } from '../src/database/prisma.js';
import { otpService } from '../src/services/otp/otp.service.js';
import { MockSmsProvider } from '../src/services/otp/providers/mock-sms.provider.js';

describe('Provider Business Profile API', () => {
  const mockSms = new MockSmsProvider();

  beforeAll(async () => {
    otpService.setProvider(mockSms);
    await prisma.$connect();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  async function createVerifiedProvider(phone: string) {
    await prisma.user.deleteMany({ where: { phoneNumber: phone } });

    await supertest(app).post('/auth/signup').send({
      fullName: 'Provider Owner',
      phone,
      password: 'Password123',
      role: 'PROVIDER',
    });

    const otp = mockSms.sentMessages[mockSms.sentMessages.length - 1].message.match(/\d{6}/)?.[0] || '';
    const verifyRes = await supertest(app).post('/auth/otp/verify').send({
      phone,
      otp,
      purpose: 'SIGNUP_VERIFICATION',
    });

    return verifyRes.body.data.tokens.accessToken as string;
  }

  it('should reject unauthenticated request to provider profile (401)', async () => {
    const res = await supertest(app).get('/provider/profile');
    expect(res.status).toBe(401);
  });

  it('should reject Customer-only user from accessing provider profile (403)', async () => {
    const customerPhone = '9876555001';
    await prisma.user.deleteMany({ where: { phoneNumber: customerPhone } });

    await supertest(app).post('/auth/signup').send({
      fullName: 'Customer User',
      phone: customerPhone,
      password: 'Password123',
      role: 'CUSTOMER',
    });

    const otp = mockSms.sentMessages[mockSms.sentMessages.length - 1].message.match(/\d{6}/)?.[0] || '';
    const verifyRes = await supertest(app).post('/auth/otp/verify').send({
      phone: customerPhone,
      otp,
      purpose: 'SIGNUP_VERIFICATION',
    });

    const customerToken = verifyRes.body.data.tokens.accessToken;

    const res = await supertest(app).get('/provider/profile').set('Authorization', `Bearer ${customerToken}`);

    expect(res.status).toBe(403);
  });

  it('should allow Provider to create/update business profile with verificationStatus = PENDING', async () => {
    const phone = '9876555002';
    const providerToken = await createVerifiedProvider(phone);

    const updateRes = await supertest(app)
      .post('/provider/profile')
      .set('Authorization', `Bearer ${providerToken}`)
      .send({
        businessName: 'GreenCharge EV Hub',
        contactPhone: phone,
        contactEmail: 'contact@greencharge.com',
        address: '45 Electric Way, Tech Park',
        city: 'Bengaluru',
        state: 'Karnataka',
        pincode: '560001',
        taxId: '29ABCDE1234F1Z5',
        description: 'Fast EV charging hub with 4 Type-2 chargers.',
      });

    expect(updateRes.status).toBe(200);
    expect(updateRes.body.success).toBe(true);
    expect(updateRes.body.data.businessName).toBe('GreenCharge EV Hub');
    expect(updateRes.body.data.city).toBe('Bengaluru');
    expect(updateRes.body.data.verificationStatus).toBe('PENDING'); // Initial status must be PENDING
    expect(updateRes.body.data.profileStatus).toBe('COMPLETE');
  });

  it('should PREVENT provider from self-verifying profile (verificationStatus remains PENDING)', async () => {
    const phone = '9876555003';
    const providerToken = await createVerifiedProvider(phone);

    // Attempt to inject verificationStatus = VERIFIED
    const updateRes = await supertest(app)
      .put('/provider/profile')
      .set('Authorization', `Bearer ${providerToken}`)
      .send({
        businessName: 'Sneaky Provider',
        address: '789 Main St',
        verificationStatus: 'VERIFIED', // Client attempting self-verification
      });

    expect(updateRes.status).toBe(200);
    // verificationStatus must remain PENDING
    expect(updateRes.body.data.verificationStatus).toBe('PENDING');
  });
});
