import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import supertest from 'supertest';
import { app } from '../src/app.js';
import { prisma } from '../src/database/prisma.js';
import { otpService } from '../src/services/otp/otp.service.js';
import { MockSmsProvider } from '../src/services/otp/providers/mock-sms.provider.js';
import crypto from 'crypto';

describe('Payments & Transactions API', () => {
  const mockSms = new MockSmsProvider();
  let providerToken: string;
  let providerId: string;
  let customerToken: string;
  let customerId: string;
  let chargerId: string;
  let bookingId: string;
  let paymentOrderId: string;

  beforeAll(async () => {
    otpService.setProvider(mockSms);
    await prisma.$connect();

    // Clean start
    await prisma.transaction.deleteMany();
    await prisma.providerPayout.deleteMany();
    await prisma.providerBankAccount.deleteMany();
    await prisma.payment.deleteMany();
    await prisma.chargingSession.deleteMany();
    await prisma.booking.deleteMany();
    await prisma.charger.deleteMany();
    await prisma.chargingStation.deleteMany();

    // Setup Provider
    mockSms.clear();
    const pPhone = '9876000010';
    await prisma.otpVerification.deleteMany({ where: { phoneNumber: pPhone } });
    await prisma.user.deleteMany({ where: { phoneNumber: pPhone } });
    await supertest(app).post('/auth/signup').send({ fullName: 'Finance Provider', phone: pPhone, password: 'Password123', role: 'PROVIDER' });
    const otpP = mockSms.sentMessages[mockSms.sentMessages.length - 1].message.match(/\d{6}/)?.[0] || '';
    const resP = await supertest(app).post('/auth/otp/verify').send({ phone: pPhone, otp: otpP, purpose: 'SIGNUP_VERIFICATION' });
    providerToken = resP.body.data.tokens.accessToken;
    providerId = resP.body.data.user.id;

    // Setup Customer
    mockSms.clear();
    const cPhone = '9876000011';
    await prisma.otpVerification.deleteMany({ where: { phoneNumber: cPhone } });
    await prisma.user.deleteMany({ where: { phoneNumber: cPhone } });
    await supertest(app).post('/auth/signup').send({ fullName: 'Finance Customer', phone: cPhone, password: 'Password123', role: 'CUSTOMER' });
    const otpC = mockSms.sentMessages[mockSms.sentMessages.length - 1].message.match(/\d{6}/)?.[0] || '';
    const resC = await supertest(app).post('/auth/otp/verify').send({ phone: cPhone, otp: otpC, purpose: 'SIGNUP_VERIFICATION' });
    customerToken = resC.body.data.tokens.accessToken;
    customerId = resC.body.data.user.id;

    // Create Station & Charger (Price: Rs 100 per hour)
    const stRes = await supertest(app).post('/provider/stations').set('Authorization', `Bearer ${providerToken}`).send({
      name: 'Finance Station', address: '404 Fin St', latitude: 12.971, longitude: 77.594,
    });
    const stationId = stRes.body.data.id;

    const chRes = await supertest(app).post(`/provider/stations/${stationId}/chargers`).set('Authorization', `Bearer ${providerToken}`).send({
      chargerCode: 'FIN-100', chargerType: 'AC', connectorType: 'TYPE_2', powerKw: 7.2, pricePerHour: 100.0,
    });
    chargerId = chRes.body.data.id;

    // Create Booking (Duration: 2 hours => Rs 200)
    const startTime = new Date(Date.now() + 1000 * 60 * 60).toISOString();
    const endTime = new Date(Date.now() + 1000 * 60 * 60 * 3).toISOString();
    const bRes = await supertest(app).post('/customer/bookings').set('Authorization', `Bearer ${customerToken}`).send({ chargerId, startTime, endTime });
    bookingId = bRes.body.data.id;
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('should calculate server-side pricing and create payment order for customer', async () => {
    const res = await supertest(app)
      .post('/customer/payments/create')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({ bookingId });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.amountPaise).toBe(20000); // 2 hours * 100 Rs = 200 Rs => 20000 paise
    expect(res.body.data.currency).toBe('INR');
    expect(res.body.data).toHaveProperty('gatewayOrderId');

    paymentOrderId = res.body.data.gatewayOrderId;
  });

  it('should reject payment creation without bookingId or sessionId', async () => {
    const res = await supertest(app)
      .post('/customer/payments/create')
      .set('Authorization', `Bearer ${customerToken}`)
      .send({});

    expect(res.status).toBe(422);
  });

  it('should handle webhook idempotently and record payment success & transactions', async () => {
    // Simulate Gateway Webhook
    // Uses MockPaymentProvider logic where any signature string validates successfully
    const payload = {
      event: 'payment.success',
      signature: 'dummy-signature',
      payload: {
        gatewayOrderId: paymentOrderId,
        gatewayPaymentId: 'pay_12345'
      }
    };

    const res1 = await supertest(app).post('/payments/webhook').send(payload);
    expect(res1.status).toBe(200);

    // Verify internally status updated to PAID
    const customerPayments = await supertest(app).get('/customer/payments').set('Authorization', `Bearer ${customerToken}`);
    expect(customerPayments.body.data[0].status).toBe('PAID');
    expect(customerPayments.body.data[0].amount).toBe(20000);

    // Check transactions created
    const customerTxns = await supertest(app).get('/customer/transactions').set('Authorization', `Bearer ${customerToken}`);
    expect(customerTxns.body.data.length).toBe(1);
    expect(customerTxns.body.data[0].type).toBe('PAYMENT');
    expect(customerTxns.body.data[0].amount).toBe(20000);

    // Check idempotency (duplicate webhook event should be ignored/processed safely)
    const res2 = await supertest(app).post('/payments/webhook').send(payload);
    expect(res2.status).toBe(200);

    const checkTxnsAgain = await supertest(app).get('/customer/transactions').set('Authorization', `Bearer ${customerToken}`);
    expect(checkTxnsAgain.body.data.length).toBe(1); // Still 1, no duplicate created
  });

  it('should calculate provider earnings applying platform commission correctly', async () => {
    // Payment was 20000 paise (Rs 200). Commission is 10% (Rs 20 = 2000 paise).
    // Net earnings = 18000 paise (Rs 180).
    const res = await supertest(app).get('/provider/earnings').set('Authorization', `Bearer ${providerToken}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.totalEarnedPaise).toBe(20000);
    expect(res.body.data.totalCommissionPaise).toBe(2000);
    expect(res.body.data.netEarningsPaise).toBe(18000);
    expect(res.body.data.availableBalancePaise).toBe(18000);
  });

  it('should allow provider to save bank account details safely', async () => {
    const res = await supertest(app)
      .post('/provider/bank-account')
      .set('Authorization', `Bearer ${providerToken}`)
      .send({
        accountName: 'VOLTERA PROVIDER 1',
        accountNumber: '123456789012',
        ifscCode: 'HDFC0001234',
        bankName: 'HDFC Bank',
      });

    expect(res.status).toBe(200);

    const getRes = await supertest(app).get('/provider/bank-account').set('Authorization', `Bearer ${providerToken}`);
    expect(getRes.body.data.accountNumber).toBe('123456789012');
  });

  it('should allow provider to request a payout if balance is sufficient', async () => {
    // Request Rs 100 (10000 paise). Available is 18000 paise.
    const res = await supertest(app)
      .post('/provider/payouts')
      .set('Authorization', `Bearer ${providerToken}`)
      .send({
        amount: 100 // Client sends in INR format, backend converts to paise
      });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);

    const getPayouts = await supertest(app).get('/provider/payouts').set('Authorization', `Bearer ${providerToken}`);
    expect(getPayouts.body.data.length).toBe(1);
    expect(getPayouts.body.data[0].amount).toBe(10000); // Saved internally as paise
    expect(getPayouts.body.data[0].status).toBe('REQUESTED');

    // Check earnings again. Available balance should now be 18000 - 10000 = 8000 paise
    const earningsRes = await supertest(app).get('/provider/earnings').set('Authorization', `Bearer ${providerToken}`);
    expect(earningsRes.body.data.availableBalancePaise).toBe(8000);
  });

  it('should reject provider payout if balance is insufficient', async () => {
    // Try to request Rs 200 (20000 paise). Only 8000 paise available.
    const res = await supertest(app)
      .post('/provider/payouts')
      .set('Authorization', `Bearer ${providerToken}`)
      .send({ amount: 200 });

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.error.message).toContain('Insufficient');
  });
});
