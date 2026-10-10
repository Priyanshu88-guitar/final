import { env } from '../../config/env.js';
import { AppError } from '../../utils/app-error.js';
import { CreatePaymentInput, WebhookEventPayload } from '../../models/payment.model.js';
import { financialRepository } from '../../repositories/financial.repository.js';
import { IPaymentProvider } from './payment-provider.interface.js';
import { MockPaymentProvider } from './providers/mock-payment.provider.js';
import { prisma } from '../../database/prisma.js';

export class PaymentService {
  private provider: IPaymentProvider;

  constructor() {
    if (env.PAYMENT_PROVIDER === 'mock') {
      this.provider = new MockPaymentProvider();
    } else {
      // Stub for real Razorpay Provider if implemented
      this.provider = new MockPaymentProvider();
    }
  }

  // Allow test injection
  setProvider(provider: IPaymentProvider) {
    this.provider = provider;
  }

  getProviderName(): string {
    return this.provider.name;
  }

  private calculateAmountFromBooking(booking: any): number {
    const durationMs = booking.endTime.getTime() - booking.startTime.getTime();
    const durationHours = durationMs / (1000 * 60 * 60);
    const rate = booking.charger.pricePerHour;

    // Amount in INR
    const amountInr = durationHours * rate;

    // Return paise (smallest unit)
    return Math.round(amountInr * 100);
  }

  async createPaymentOrder(customerId: string, input: CreatePaymentInput) {
    let amountPaise = 0;

    // Ensure we are calculating server-side
    if (input.bookingId) {
      const booking = await financialRepository.getChargeableBookingDetails(input.bookingId, customerId);
      amountPaise = this.calculateAmountFromBooking(booking);
    } else if (input.sessionId) {
      // In Phase 6, we'll bill based on the booking duration associated with the session since we lack real kWh meter data.
      const session = await financialRepository.getChargeableSessionDetails(input.sessionId, customerId);
      amountPaise = this.calculateAmountFromBooking({ ...session.booking, charger: session.charger });
    } else if (input.bundlePurchaseId) {
      const bp = await prisma.bundlePurchase.findUnique({
         where: { id: input.bundlePurchaseId, customerId },
         include: { bundle: true }
      });
      if (!bp) throw AppError.notFound('Bundle purchase not found');
      amountPaise = bp.bundle.price;
    } else {
      throw AppError.badRequest('Valid bookingId, sessionId, or bundlePurchaseId is required to calculate payment');
    }

    if (amountPaise <= 0) {
      throw AppError.badRequest('Calculated amount is zero or invalid. Cannot create payment.');
    }

    const receiptId = `rcpt_${Date.now()}_${customerId.substring(0,6)}`;

    // Create Order with Gateway
    const gatewayOrder = await this.provider.createOrder(amountPaise, 'INR', receiptId);

    // Save internally
    const payment = await financialRepository.createPaymentOrder(
      customerId,
      gatewayOrder.amount,
      this.provider.name,
      gatewayOrder.gatewayOrderId,
      input.bookingId,
      input.sessionId,
      input.bundlePurchaseId
    );

    return {
      paymentId: payment.id,
      amountPaise: payment.amount,
      currency: payment.currency,
      provider: payment.gatewayProvider,
      gatewayOrderId: payment.gatewayOrderId,
      clientSecret: gatewayOrder.clientSecret, // Used by frontend SDKs
    };
  }

  async handleWebhook(payload: WebhookEventPayload) {
    // 1. Verify Signature
    const isValid = this.provider.verifyWebhookSignature(payload);
    if (!isValid) {
      throw AppError.unauthorized('Invalid webhook signature');
    }

    const event = payload.event;

    // In Mock, we expect payload.payload to have gatewayOrderId, gatewayPaymentId, status
    const data = payload.payload;
    const gatewayOrderId = data.gatewayOrderId;

    if (!gatewayOrderId) return { received: true, status: 'ignored_missing_order_id' };

    // Need to strictly instruct prisma to retrieve nested fields to satisfy TypeScript optional chaining later
    const payment = await prisma.payment.findUnique({
      where: { gatewayOrderId },
      include: {
        booking: { include: { charger: { include: { station: true } } } },
        session: { include: { charger: { include: { station: true } } } }
      }
    });

    if (!payment) return { received: true, status: 'ignored_unknown_order' };

    // 2. Handle specific events idempotently
    if (event === 'payment.captured' || event === 'payment.success') {
      const providerId = payment.booking?.charger?.station?.providerId || payment.session?.charger?.station?.providerId;
      // If providerId is undefined (e.g., Platform bundle purchase), it correctly skips provider-routing inside markPaymentAsPaid

      await financialRepository.markPaymentAsPaid(
        payment.id,
        data.gatewayPaymentId || `mock_pay_${Date.now()}`,
        providerId,
        env.PLATFORM_FEE_PERCENTAGE
      );

    } else if (event === 'payment.failed') {
      await financialRepository.markPaymentAsFailed(payment.id);
    }

    return { received: true, status: 'processed' };
  }
}

export const paymentService = new PaymentService();
