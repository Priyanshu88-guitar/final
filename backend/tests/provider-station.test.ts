import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import supertest from 'supertest';
import { app } from '../src/app.js';
import { prisma } from '../src/database/prisma.js';
import { otpService } from '../src/services/otp/otp.service.js';
import { MockSmsProvider } from '../src/services/otp/providers/mock-sms.provider.js';

describe('Provider Station API', () => {
  const mockSms = new MockSmsProvider();
  let provider1Token: string;
  let provider2Token: string;

  beforeAll(async () => {
    otpService.setProvider(mockSms);
    await prisma.$connect();

    // Create Provider 1
    mockSms.clear();
    const p1Phone = '9876777001';
    await prisma.otpVerification.deleteMany({ where: { phoneNumber: p1Phone } });
    await prisma.user.deleteMany({ where: { phoneNumber: p1Phone } });

    const signup1Res = await supertest(app).post('/auth/signup').send({ fullName: 'Provider One', phone: p1Phone, password: 'Password123', role: 'PROVIDER' });
    expect(signup1Res.status).toBe(201); // Ensure it succeeds

    const otp1 = mockSms.sentMessages[mockSms.sentMessages.length - 1].message.match(/\d{6}/)?.[0] || '';
    const res1 = await supertest(app).post('/auth/otp/verify').send({ phone: p1Phone, otp: otp1, purpose: 'SIGNUP_VERIFICATION' });
    provider1Token = res1.body.data.tokens.accessToken;

    // Create Provider 2
    mockSms.clear();
    const p2Phone = '9876777002';
    await prisma.otpVerification.deleteMany({ where: { phoneNumber: p2Phone } });
    await prisma.user.deleteMany({ where: { phoneNumber: p2Phone } });

    const signup2Res = await supertest(app).post('/auth/signup').send({ fullName: 'Provider Two', phone: p2Phone, password: 'Password123', role: 'PROVIDER' });
    expect(signup2Res.status).toBe(201); // Ensure it succeeds

    const otp2 = mockSms.sentMessages[mockSms.sentMessages.length - 1].message.match(/\d{6}/)?.[0] || '';
    const res2 = await supertest(app).post('/auth/otp/verify').send({ phone: p2Phone, otp: otp2, purpose: 'SIGNUP_VERIFICATION' });
    provider2Token = res2.body.data.tokens.accessToken;
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('should allow provider to create a station', async () => {
    const res = await supertest(app)
      .post('/provider/stations')
      .set('Authorization', `Bearer ${provider1Token}`)
      .send({
        name: 'P1 Central Station',
        address: '100 Main St',
        city: 'Mumbai',
        state: 'Maharashtra',
        pincode: '400001',
        latitude: 18.922,
        longitude: 72.834,
      });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toHaveProperty('id');
    expect(res.body.data.name).toBe('P1 Central Station');
  });

  it('should reject invalid coordinates (422)', async () => {
    const res = await supertest(app)
      .post('/provider/stations')
      .set('Authorization', `Bearer ${provider1Token}`)
      .send({
        name: 'Invalid Location Station',
        address: '100 Main St',
        latitude: 200, // Invalid lat
        longitude: -200, // Invalid long
      });

    expect(res.status).toBe(422);
    expect(res.body.success).toBe(false);
  });

  it('should allow provider to list their own stations', async () => {
    const res = await supertest(app)
      .get('/provider/stations')
      .set('Authorization', `Bearer ${provider1Token}`);

    expect(res.status).toBe(200);
    expect(res.body.data).toBeInstanceOf(Array);
    expect(res.body.data.length).toBeGreaterThan(0);
    expect(res.body.data[0].name).toBe('P1 Central Station');
  });

  it('should prevent Provider 2 from viewing Provider 1 station details (404/403 equivalent)', async () => {
    const p1Stations = await supertest(app).get('/provider/stations').set('Authorization', `Bearer ${provider1Token}`);
    const stationId = p1Stations.body.data[0].id;

    const res = await supertest(app)
      .get(`/provider/stations/${stationId}`)
      .set('Authorization', `Bearer ${provider2Token}`);

    expect(res.status).toBe(404); // Not found for this provider
  });

  it('should allow Provider 1 to update their own station', async () => {
    const p1Stations = await supertest(app).get('/provider/stations').set('Authorization', `Bearer ${provider1Token}`);
    const stationId = p1Stations.body.data[0].id;

    const res = await supertest(app)
      .patch(`/provider/stations/${stationId}`)
      .set('Authorization', `Bearer ${provider1Token}`)
      .send({
        status: 'INACTIVE',
      });

    expect(res.status).toBe(200);
    expect(res.body.data.status).toBe('INACTIVE');
  });

  it('should prevent Provider 2 from updating Provider 1 station (404/403 equivalent)', async () => {
    const p1Stations = await supertest(app).get('/provider/stations').set('Authorization', `Bearer ${provider1Token}`);
    const stationId = p1Stations.body.data[0].id;

    const res = await supertest(app)
      .patch(`/provider/stations/${stationId}`)
      .set('Authorization', `Bearer ${provider2Token}`)
      .send({
        name: 'Hacked Station Name',
      });

    expect(res.status).toBe(404);
  });
});
