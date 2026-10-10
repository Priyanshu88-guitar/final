import { ISmsProvider, SmsDeliveryResult } from '../otp-provider.interface.js';
import { logger } from '../../../config/logger.js';

export class ConsoleSmsProvider implements ISmsProvider {
  name = 'ConsoleSmsProvider';

  isConfigured(): boolean {
    return true;
  }

  async sendSms(phoneNumber: string, message: string): Promise<SmsDeliveryResult> {
    logger.info(`[SMS Provider: ${this.name}] Sending SMS to ${phoneNumber}: ${message}`);
    return {
      success: true,
      providerName: this.name,
      providerMessageId: `console-${Date.now()}`,
    };
  }
}
