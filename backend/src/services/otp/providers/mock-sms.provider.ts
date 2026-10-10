import { ISmsProvider, SmsDeliveryResult } from '../otp-provider.interface.js';

export class MockSmsProvider implements ISmsProvider {
  name = 'MockSmsProvider';
  public sentMessages: { phoneNumber: string; message: string }[] = [];

  isConfigured(): boolean {
    return true;
  }

  async sendSms(phoneNumber: string, message: string): Promise<SmsDeliveryResult> {
    this.sentMessages.push({ phoneNumber, message });
    return {
      success: true,
      providerName: this.name,
      providerMessageId: `mock-${this.sentMessages.length}`,
    };
  }

  clear(): void {
    this.sentMessages = [];
  }
}
