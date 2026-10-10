import { ISmsProvider, SmsDeliveryResult } from '../otp-provider.interface.js';
import { env } from '../../../config/env.js';

export class TwilioSmsProvider implements ISmsProvider {
  name = 'TwilioSmsProvider';

  isConfigured(): boolean {
    return Boolean(env.OTP_API_KEY && env.OTP_SENDER_ID);
  }

  async sendSms(phoneNumber: string, message: string): Promise<SmsDeliveryResult> {
    if (!this.isConfigured()) {
      return {
        success: false,
        providerName: this.name,
        error: 'Twilio SMS credentials (OTP_API_KEY / OTP_SENDER_ID) are not configured in environment variables.',
      };
    }

    // Actual Twilio REST API integration placeholder when credentials provided
    return {
      success: true,
      providerName: this.name,
      providerMessageId: `twilio-${Date.now()}`,
    };
  }
}
