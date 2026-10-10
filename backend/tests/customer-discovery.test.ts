import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import supertest from 'supertest';
import { app } from '../src/app.js';
import { prisma } from '../src/database/prisma.js';
import { otpService } from '../src/services/otp/otp.service.js';
import { MockSmsProvider } from '../src/services/otp/providers/mock-sms.provider.js';

describe('Customer Charger Discovery API', () => {
  const mockSms = new MockSmsProvider();
  let customerToken: string;

  beforeAll(async () => {
    otpService.setProvider(mockSms);
    await prisma.$connect();

    // Ensure clean state
    await prisma.charger.deleteMany({});
    await prisma.chargingStation.deleteMany({});

    // Setup Customer
    mockSms.clear();
    const phone = '9876999001';
    await prisma.otpVerification.deleteMany({ where: { phoneNumber: phone } });
    await prisma.user.deleteMany({ where: { phoneNumber: phone } });
    await supertest(app).post('/auth/signup').send({ fullName: 'Customer Disc', phone, password: 'Password123', role: 'CUSTOMER' });
    const otp1 = mockSms.sentMessages[mockSms.sentMessages.length - 1].message.match(/\d{6}/)?.[0] || '';
    const res1 = await supertest(app).post('/auth/otp/verify').send({ phone, otp: otp1, purpose: 'SIGNUP_VERIFICATION' });
    customerToken = res1.body.data.tokens.accessToken;

    // Setup Provider & Data
    const pPhone = '9876999002';
    await prisma.otpVerification.deleteMany({ where: { phoneNumber: pPhone } });
    await prisma.user.deleteMany({ where: { phoneNumber: pPhone } });
    const providerUser = await prisma.user.create({
      data: {
        fullName: 'Discovery Provider',
        phoneNumber: pPhone,
        passwordHash: 'dummy',
        accountStatus: 'ACTIVE',
        isPhoneVerified: true,
        roles: { create: [{ role: 'PROVIDER' }] },
      },
    });

    const st1 = await prisma.chargingStation.create({
      data: {
        providerId: providerUser.id,
        name: 'Alpha Station',
        address: 'MG Road',
        city: 'Bengaluru',
        latitude: 12.9716,
        longitude: 77.5946,
        status: 'ACTIVE',
      },
    });

    const st2 = await prisma.chargingStation.create({
      data: {
        providerId: providerUser.id,
        name: 'Beta Station (Offline)',
        address: 'Indiranagar',
        city: 'Bengaluru',
        latitude: 12.9784,
        longitude: 77.6408,
        status: 'INACTIVE', // INACTIVE stations shouldn't show chargers to customers
      },
    });

    await prisma.charger.createMany({
      data: [
        { stationId: st1.id, chargerCode: 'C-01', chargerType: 'AC', connectorType: 'TYPE_2', powerKw: 7.2, status: 'AVAILABLE' },
        { stationId: st1.id, chargerCode: 'C-02', chargerType: 'DC', connectorType: 'CCS2', powerKw: 50.0, status: 'OCCUPIED' },
        { stationId: st2.id, chargerCode: 'C-03', chargerType: 'DC', connectorType: 'CCS2', powerKw: 100.0, status: 'AVAILABLE' },
      ],
    });
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('should list chargers from ACTIVE stations only', async () => {
    const res = await supertest(app).get('/chargers'); // Public discovery is allowed in this implementation

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.length).toBe(2); // C-01, C-02 (C-03 is in INACTIVE station)
    expect(res.body.data[0].distanceKm).toBeUndefined(); // No location provided
  });

  it('should filter chargers by connector type and status', async () => {
    const res = await supertest(app).get('/chargers?connectorType=CCS2&status=OCCUPIED');

    expect(res.status).toBe(200);
    expect(res.body.data.length).toBe(1);
    expect(res.body.data[0].chargerCode).toBe('C-02');
  });

  it('should filter chargers by power range', async () => {
    const res = await supertest(app).get('/chargers?minPower=40');

    expect(res.status).toBe(200);
    expect(res.body.data.length).toBe(1);
    expect(res.body.data[0].chargerCode).toBe('C-02');
  });

  it('should filter chargers by search keyword', async () => {
    const res = await supertest(app).get('/chargers?search=Alpha');

    expect(res.status).toBe(200);
    expect(res.body.data.length).toBe(2);
  });

  it('should calculate distance and sort if lat/lng are provided', async () => {
    // Exact same coordinates as Alpha Station
    const res = await supertest(app).get('/chargers?latitude=12.9716&longitude=77.5946');

    expect(res.status).toBe(200);
    expect(res.body.data.length).toBe(2);
    expect(res.body.data[0].distanceKm).toBeDefined();
    expect(res.body.data[0].distanceKm).toBeLessThanOrEqual(0.1);
  });

  it('should filter by radius if radius is provided', async () => {
    // Very far coordinates
    const res = await supertest(app).get('/chargers?latitude=28.6139&longitude=77.2090&radius=50');

    expect(res.status).toBe(200);
    expect(res.body.data.length).toBe(0); // Delhi is >50km from Bengaluru
  });

  it('should fetch charger details', async () => {
    const listRes = await supertest(app).get('/chargers');
    const chargerId = listRes.body.data[0].id;

    const res = await supertest(app).get(`/chargers/${chargerId}`);

    expect(res.status).toBe(200);
    expect(res.body.data.id).toBe(chargerId);
    expect(res.body.data.stationName).toBe('Alpha Station');
  });

  it('should reject fetching charger details if station is inactive (404)', async () => {
    const c03 = await prisma.charger.findUnique({ where: { chargerCode: 'C-03' } });

    const res = await supertest(app).get(`/chargers/${c03!.id}`);

    expect(res.status).toBe(404);
  });
});
