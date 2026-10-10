export interface SmsDeliveryResult {
  success: boolean;
  providerName: string;
  providerMessageId?: string;
  error?: string;
}

export interface ISmsProvider {
  name: string;
  isConfigured(): boolean;
  sendSms(phoneNumber: string, message: string): Promise<SmsDeliveryResult>;
}
