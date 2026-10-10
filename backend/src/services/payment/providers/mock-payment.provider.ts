import { IPaymentProvider } from '../payment-provider.interface.js';
import { PaymentGatewayOrder, WebhookEventPayload } from '../../../models/payment.model.js';
import crypto from 'crypto';

export class MockPaymentProvider implements IPaymentProvider {
  name = 'mock';

  async createOrder(amountPaise: number, currency: string, receiptId: string): Promise<PaymentGatewayOrder> {
    const gatewayOrderId = `mock_order_${crypto.randomBytes(8).toString('hex')}`;

    return {
      gatewayOrderId,
      amount: amountPaise,
      currency,
      provider: this.name,
      clientSecret: 'mock_client_secret',
    };
  }

  verifyWebhookSignature(payload: WebhookEventPayload): boolean {
    // In mock, always return true if a valid signature string is sent for testing
    return typeof payload.signature === 'string' && payload.signature.length > 0;
  }
}
