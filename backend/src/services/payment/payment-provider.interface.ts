import { PaymentGatewayOrder, WebhookEventPayload } from '../../models/payment.model.js';

export interface IPaymentProvider {
  name: string;
  createOrder(amountPaise: number, currency: string, receiptId: string): Promise<PaymentGatewayOrder>;
  verifyWebhookSignature(payload: WebhookEventPayload): boolean;
}
