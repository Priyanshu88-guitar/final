import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import supertest from 'supertest';
import { app } from '../src/app.js';
import { prisma } from '../src/database/prisma.js';
import { otpService } from '../src/services/otp/otp.service.js';
import { MockSmsProvider } from '../src/services/otp/providers/mock-sms.provider.js';

describe('Booking & Charging Session API', () => {
  const mockSms = new MockSmsProvider();
  let providerToken: string;
  let customerToken: string;
  let chargerId: string;
  let bookingId: string;
  let sessionId: string;

  beforeAll(async () => {
    otpService.setProvider(mockSms);
    await prisma.$connect();

    // Clean start
    await prisma.chargingSession.deleteMany();
    await prisma.booking.deleteMany();
    await prisma.charger.deleteMany();
    await prisma.chargingStation.deleteMany();

    // Setup Provider
    mockSms.clear();
    const pPhone = '9876000001';
    await prisma.otpVerification.deleteMany({ where: { phoneNumber: pPhone } });
    await prisma.user.deleteMany({ where: { phoneNumber: pPhone } });
    await supertest(app).post('/auth/signup').send({ fullName: 'Booking Provider', phone: pPhone, password: 'Password123', role: 'PROVIDER' });
    const otpP = mockSms.sentMessages[mockSms.sentMessages.length - 1].message.match(/\d{6}/)?.[0] || '';
    const resP = await supertest(app).post('/auth/otp/verify').send({ phone: pPhone, otp: otpP, purpose: 'SIGNUP_VERIFICATION' });
    providerToken = resP.body.data.tokens.accessToken;

    // Setup Customer
    mockSms.clear();
    const cPhone = '9876000002';
    await prisma.otpVerification.deleteMany({ where: { phoneNumber: cPhone } });
    await prisma.user.deleteMany({ where: { phoneNumber: cPhone } });
    await supertest(app).post('/auth/signup').send({ fullName: 'Booking Customer', phone: cPhone, password: 'Password123', role: 'CUSTOMER' });
    const otpC = mockSms.sentMessages[mockSms.sentMessages.length - 1].message.match(/\d{6}/)?.[0] || '';
    const resC = await supertest(app).post('/auth/otp/verify').send({ phone: cPhone, otp: otpC, purpose: 'SIGNUP_VERIFICATION' });
    customerToken = resC.body.data.tokens.accessToken;

    // Create Station & Charger
    const stRes = await supertest(app).post('/provider/stations').set('Authorization', `Bearer ${providerToken}`).send({
      name: 'Booking Station', address: '123 Test St', latitude: 12.971, longitude: 77.594,
    });
    const stationId = stRes.body.data.id;

    const chRes = await supertest(app).post(`/provider/stations/${stationId}/chargers`).set('Authorization', `Bearer ${providerToken}`).send({
      chargerCode: 'BK-100', chargerType: 'DC', connectorType: 'CCS2', powerKw: 50.0,
    });
    chargerId = chRes.body.data.id;
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('should allow customer to create a valid booking', async () => {
    const startTime = new Date(Date.now() + 1000 * 60 * 60).toISOString(); // +1 hour
    const endTime = new Date(Date.now() + 1000 * 60 * 60 * 2).toISOString(); // +2 hours

    const res = await supertest(app)
      .post('/customer/bookings')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ chargerId, startTime, endTime });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.status).toBe('CONFIRMED'); // Auto-confirm behavior
    bookingId = res.body.data.id;
  });

  it('should reject overlapping booking for the same charger (409)', async () => {
    // Attempt overlap: +1.5 hours to +2.5 hours
    const startTime = new Date(Date.now() + 1000 * 60 * 60 * 1.5).toISOString();
    const endTime = new Date(Date.now() + 1000 * 60 * 60 * 2.5).toISOString();

    const res = await supertest(app)
      .post('/customer/bookings')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ chargerId, startTime, endTime });

    expect(res.status).toBe(409);
    expect(res.body.success).toBe(false);
  });

  it('should allow booking for adjacent non-overlapping time', async () => {
    // Attempt adjacent: +2 hours to +3 hours
    const startTime = new Date(Date.now() + 1000 * 60 * 60 * 2).toISOString();
    const endTime = new Date(Date.now() + 1000 * 60 * 60 * 3).toISOString();

    const res = await supertest(app)
      .post('/customer/bookings')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ chargerId, startTime, endTime });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
  });

  it('should reject booking in the past (422)', async () => {
    const startTime = new Date(Date.now() - 1000 * 60 * 60).toISOString();
    const endTime = new Date(Date.now() + 1000 * 60 * 60).toISOString();

    const res = await supertest(app)
      .post('/customer/bookings')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ chargerId, startTime, endTime });

    expect(res.status).toBe(422);
    expect(res.body.success).toBe(false);
  });

  it('should prevent customer from starting session too early', async () => {
    // Current time is ~1 hour before the start of bookingId
    const res = await supertest(app)
      .post(`/customer/bookings/${bookingId}/start-session`)
      .set('Authorization', `Bearer ${customerToken}`);

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.error.message).toContain('Too early');
  });

  it('should allow customer to start a session for a valid booking', async () => {
    // Since overlapping bookings are blocked on the same charger, let's create a *new* charger
    const stId = (await prisma.charger.findFirst())!.stationId;
    const newChRes = await supertest(app).post(`/provider/stations/${stId}/chargers`).set('Authorization', `Bearer ${providerToken}`).send({
      chargerCode: 'BK-101', chargerType: 'DC', connectorType: 'CCS2', powerKw: 50.0,
    });
    const cId2 = newChRes.body.data.id;

    // Create an immediate booking for this test on the NEW charger
    const startTime = new Date(Date.now() + 1000 * 60).toISOString(); // +1 min
    const endTime = new Date(Date.now() + 1000 * 60 * 60).toISOString();

    const bRes = await supertest(app)
      .post('/customer/bookings')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ chargerId: cId2, startTime, endTime });

    expect(bRes.status).toBe(201);
    const immediateBookingId = bRes.body.data.id;

    // Start Session
    const sRes = await supertest(app)
      .post(`/customer/bookings/${immediateBookingId}/start-session`)
      .set('Authorization', `Bearer ${customerToken}`);

    expect(sRes.status).toBe(201);
    expect(sRes.body.success).toBe(true);
    expect(sRes.body.data.status).toBe('ACTIVE');
    sessionId = sRes.body.data.id;

    // Verify charger status changed to OCCUPIED
    const cRes = await supertest(app).get(`/chargers/${cId2}`);
    expect(cRes.body.data.status).toBe('OCCUPIED');
  });

  it('should reject starting a session if charger is already occupied', async () => {
    // sessionId refers to the ACTIVE session created above on charger cId2.
    // Try starting another session on that exact booking id.
    const actSess = await prisma.chargingSession.findUnique({where: {id: sessionId}});
    const activeBookingId = actSess!.bookingId;

    const sRes2 = await supertest(app).post(`/customer/bookings/${activeBookingId}/start-session`).set('Authorization', `Bearer ${customerToken}`);
    expect(sRes2.status).toBe(409); // Already occupied / session exists
  });

  it('should allow customer to end an active session', async () => {
    const actSess = await prisma.chargingSession.findUnique({where: {id: sessionId}});
    const cId = actSess!.chargerId;

    const res = await supertest(app)
      .post(`/customer/sessions/${sessionId}/end`)
      .set('Authorization', `Bearer ${customerToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.status).toBe('COMPLETED');

    // Verify charger status reverted to AVAILABLE
    const cRes = await supertest(app).get(`/chargers/${cId}`);
    expect(cRes.body.data.status).toBe('AVAILABLE');
  });

  it('should prevent Provider from viewing another providers booking requests', async () => {
    // Create another provider
    mockSms.clear();
    const pPhone2 = '9876000003';
    await prisma.otpVerification.deleteMany({ where: { phoneNumber: pPhone2 } });
    await prisma.user.deleteMany({ where: { phoneNumber: pPhone2 } });
    await supertest(app).post('/auth/signup').send({ fullName: 'Other Provider', phone: pPhone2, password: 'Password123', role: 'PROVIDER' });
    const otpP2 = mockSms.sentMessages[0].message.match(/\d{6}/)?.[0] || '';
    const resP2 = await supertest(app).post('/auth/otp/verify').send({ phone: pPhone2, otp: otpP2, purpose: 'SIGNUP_VERIFICATION' });
    const provider2Token = resP2.body.data.tokens.accessToken;

    const res = await supertest(app).get('/provider/bookings').set('Authorization', `Bearer ${provider2Token}`);
    expect(res.status).toBe(200);
    expect(res.body.data.length).toBe(0); // Cannot see Provider 1's bookings

    // Provider 1 should see the bookings
    const res1 = await supertest(app).get('/provider/bookings').set('Authorization', `Bearer ${providerToken}`);
    expect(res1.status).toBe(200);
    expect(res1.body.data.length).toBeGreaterThan(0);
  });
});
