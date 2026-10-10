import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import supertest from 'supertest';
import { app } from '../src/app.js';
import { prisma } from '../src/database/prisma.js';
import { otpService } from '../src/services/otp/otp.service.js';
import { MockSmsProvider } from '../src/services/otp/providers/mock-sms.provider.js';

describe('Provider Charger API', () => {
  const mockSms = new MockSmsProvider();
  let providerToken: string;
  let provider2Token: string;
  let stationId: string;

  beforeAll(async () => {
    otpService.setProvider(mockSms);
    await prisma.$connect();

    mockSms.clear();
    const pPhone = '9876888001';
    await prisma.otpVerification.deleteMany({ where: { phoneNumber: pPhone } });
    await prisma.user.deleteMany({ where: { phoneNumber: pPhone } });

    const signup1Res = await supertest(app).post('/auth/signup').send({ fullName: 'Charger Provider One', phone: pPhone, password: 'Password123', role: 'PROVIDER' });
    expect(signup1Res.status).toBe(201);

    const otp1 = mockSms.sentMessages[mockSms.sentMessages.length - 1].message.match(/\d{6}/)?.[0] || '';
    const res1 = await supertest(app).post('/auth/otp/verify').send({ phone: pPhone, otp: otp1, purpose: 'SIGNUP_VERIFICATION' });
    providerToken = res1.body.data.tokens.accessToken;

    mockSms.clear();
    const p2Phone = '9876888002';
    await prisma.otpVerification.deleteMany({ where: { phoneNumber: p2Phone } });
    await prisma.user.deleteMany({ where: { phoneNumber: p2Phone } });

    const signup2Res = await supertest(app).post('/auth/signup').send({ fullName: 'Charger Provider Two', phone: p2Phone, password: 'Password123', role: 'PROVIDER' });
    expect(signup2Res.status).toBe(201);

    const otp2 = mockSms.sentMessages[mockSms.sentMessages.length - 1].message.match(/\d{6}/)?.[0] || '';
    const res2 = await supertest(app).post('/auth/otp/verify').send({ phone: p2Phone, otp: otp2, purpose: 'SIGNUP_VERIFICATION' });
    provider2Token = res2.body.data.tokens.accessToken;

    const stRes = await supertest(app).post('/provider/stations').set('Authorization', `Bearer ${providerToken}`).send({
      name: 'Charger Station Test',
      address: '123 Test St',
      latitude: 12.971,
      longitude: 77.594,
    });
    stationId = stRes.body.data.id;
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('should allow provider to add a charger to their station', async () => {
    const res = await supertest(app)
      .post(`/provider/stations/${stationId}/chargers`)
      .set('Authorization', `Bearer ${providerToken}`)
      .send({
        chargerCode: 'CHG-100',
        name: 'Fast Charger 1',
        chargerType: 'DC',
        connectorType: 'CCS2',
        powerKw: 50.0,
        pricePerKwh: 15.0,
      });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.chargerCode).toBe('CHG-100');
    expect(res.body.data.stationId).toBe(stationId);
  });

  it('should prevent Provider 2 from adding a charger to Provider 1 station', async () => {
    const res = await supertest(app)
      .post(`/provider/stations/${stationId}/chargers`)
      .set('Authorization', `Bearer ${provider2Token}`)
      .send({
        chargerCode: 'CHG-101',
        chargerType: 'AC',
        connectorType: 'TYPE_2',
        powerKw: 22.0,
      });

    expect(res.status).toBe(404); // Station not found for this provider
  });

  it('should reject duplicate charger code (409)', async () => {
    const res = await supertest(app)
      .post(`/provider/stations/${stationId}/chargers`)
      .set('Authorization', `Bearer ${providerToken}`)
      .send({
        chargerCode: 'CHG-100', // Duplicate
        chargerType: 'AC',
        connectorType: 'TYPE_2',
        powerKw: 22.0,
      });

    expect(res.status).toBe(409);
  });

  it('should allow Provider 1 to update their charger', async () => {
    const stRes = await supertest(app).get(`/provider/stations/${stationId}`).set('Authorization', `Bearer ${providerToken}`);
    const chargerId = stRes.body.data.chargers[0].id;

    const res = await supertest(app)
      .patch(`/provider/chargers/${chargerId}`)
      .set('Authorization', `Bearer ${providerToken}`)
      .send({
        status: 'OFFLINE',
        pricePerKwh: 18.0,
      });

    expect(res.status).toBe(200);
    expect(res.body.data.status).toBe('OFFLINE');
    expect(res.body.data.pricePerKwh).toBe(18.0);
  });

  it('should prevent Provider 2 from updating Provider 1 charger', async () => {
    const stRes = await supertest(app).get(`/provider/stations/${stationId}`).set('Authorization', `Bearer ${providerToken}`);
    const chargerId = stRes.body.data.chargers[0].id;

    const res = await supertest(app)
      .patch(`/provider/chargers/${chargerId}`)
      .set('Authorization', `Bearer ${provider2Token}`)
      .send({
        status: 'AVAILABLE',
      });

    expect(res.status).toBe(403);
  });
});
