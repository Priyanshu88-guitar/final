export type PaymentStatus = 'CREATED' | 'AUTHORIZED' | 'PAID' | 'FAILED' | 'REFUNDED';
export type TransactionType = 'PAYMENT' | 'REFUND' | 'PAYOUT' | 'COMMISSION';
export type PayoutStatus = 'REQUESTED' | 'PROCESSING' | 'PAID' | 'FAILED';

export interface CreatePaymentInput {
  bookingId?: string;
  sessionId?: string;
  bundlePurchaseId?: string;
}

export interface WebhookEventPayload {
  event: string;
  payload: any;
  signature: string;
}

export interface BankAccountInput {
  accountName: string;
  accountNumber: string;
  ifscCode: string;
  bankName?: string;
}

export interface PayoutRequestInput {
  amount: number; // Requested amount in INR (frontend format, backend converts to paise)
}

// Payment gateway abstraction
export interface PaymentGatewayOrder {
  gatewayOrderId: string;
  amount: number;
  currency: string;
  provider: string;
  clientSecret?: string; // e.g. Razorpay Key or Stripe Client Secret for frontend injection
}
