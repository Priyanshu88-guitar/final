import crypto from 'crypto';
import { prisma } from '../../database/prisma.js';
import { env } from '../../config/env.js';
import { AppError } from '../../utils/app-error.js';
import { ISmsProvider } from './otp-provider.interface.js';
import { ConsoleSmsProvider } from './providers/console-sms.provider.js';
import { MockSmsProvider } from './providers/mock-sms.provider.js';
import { TwilioSmsProvider } from './providers/twilio-sms.provider.js';
import { logger } from '../../config/logger.js';

export type OtpPurpose = 'SIGNUP_VERIFICATION' | 'LOGIN_VERIFICATION' | 'PASSWORD_RESET';

export class OtpService {
  private smsProvider: ISmsProvider;

  constructor(provider?: ISmsProvider) {
    if (provider) {
      this.smsProvider = provider;
    } else if (env.OTP_PROVIDER === 'mock') {
      this.smsProvider = new MockSmsProvider();
    } else if (env.OTP_PROVIDER === 'twilio') {
      this.smsProvider = new TwilioSmsProvider();
    } else {
      this.smsProvider = new ConsoleSmsProvider();
    }
  }

  setProvider(provider: ISmsProvider): void {
    this.smsProvider = provider;
  }

  getProvider(): ISmsProvider {
    return this.smsProvider;
  }

  private hashOtp(otp: string): string {
    return crypto.createHmac('sha256', env.JWT_SECRET).update(otp).digest('hex');
  }

  private generateSecureOtp(): string {
    // Generates a cryptographically secure 6-digit number
    return crypto.randomInt(100000, 1000000).toString();
  }

  async generateAndSendOtp(
    phoneNumber: string,
    purpose: OtpPurpose,
    userId?: string,
    options?: { skipCooldown?: boolean }
  ): Promise<{ message: string; cooldownSeconds: number }> {
    // Check resend cooldown
    if (!options?.skipCooldown) {
      const latestOtp = await prisma.otpVerification.findFirst({
        where: {
          phoneNumber,
          purpose,
          isUsed: false,
        },
        orderBy: { createdAt: 'desc' },
      });

      if (latestOtp) {
        const secondsSinceLastOtp = (Date.now() - latestOtp.createdAt.getTime()) / 1000;
        if (secondsSinceLastOtp < env.OTP_RESEND_COOLDOWN_SECONDS) {
          const remainingCooldown = Math.ceil(env.OTP_RESEND_COOLDOWN_SECONDS - secondsSinceLastOtp);
          throw AppError.tooManyRequests(
            `Please wait ${remainingCooldown} seconds before requesting a new OTP.`
          );
        }
      }
    }

    // Invalidate previous active OTPs for this phone number and purpose
    await prisma.otpVerification.updateMany({
      where: {
        phoneNumber,
        purpose,
        isUsed: false,
      },
      data: { isUsed: true },
    });

    // Generate new OTP
    const plainOtp = this.generateSecureOtp();
    const otpHash = this.hashOtp(plainOtp);
    const expiresAt = new Date(Date.now() + env.OTP_TTL_MINUTES * 60 * 1000);

    // Save hashed OTP in database
    await prisma.otpVerification.create({
      data: {
        userId,
        phoneNumber,
        otpHash,
        purpose,
        expiresAt,
      },
    });

    // Deliver via SMS Provider
    const message = `Your VOLTERA verification code is: ${plainOtp}. Valid for ${env.OTP_TTL_MINUTES} minutes. Do not share it.`;
    const deliveryResult = await this.smsProvider.sendSms(phoneNumber, message);

    if (!deliveryResult.success) {
      logger.warn(`SMS delivery failed via ${deliveryResult.providerName}: ${deliveryResult.error}`);
    }

    const isProviderReady = this.smsProvider.isConfigured();

    return {
      message: isProviderReady ? 'OTP sent successfully' : 'OTP generated (SMS Gateway not configured)',
      cooldownSeconds: env.OTP_RESEND_COOLDOWN_SECONDS,
    };
  }

  async verifyOtp(phoneNumber: string, purpose: OtpPurpose, plainOtp: string): Promise<boolean> {
    const record = await prisma.otpVerification.findFirst({
      where: {
        phoneNumber,
        purpose,
        isUsed: false,
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!record) {
      throw AppError.badRequest('No active OTP found. Please request a new OTP.');
    }

    if (record.isUsed) {
      throw AppError.badRequest('This OTP has already been used.');
    }

    if (new Date() > record.expiresAt) {
      await prisma.otpVerification.update({
        where: { id: record.id },
        data: { isUsed: true },
      });
      throw AppError.badRequest('OTP has expired. Please request a new one.');
    }

    if (record.attempts >= record.maxAttempts) {
      await prisma.otpVerification.update({
        where: { id: record.id },
        data: { isUsed: true },
      });
      throw AppError.tooManyRequests('Maximum OTP verification attempts exceeded. Please request a new OTP.');
    }

    const providedHash = this.hashOtp(plainOtp);

    if (providedHash !== record.otpHash) {
      // Increment attempt count
      await prisma.otpVerification.update({
        where: { id: record.id },
        data: { attempts: { increment: 1 } },
      });

      const remainingAttempts = record.maxAttempts - (record.attempts + 1);
      if (remainingAttempts <= 0) {
        await prisma.otpVerification.update({
          where: { id: record.id },
          data: { isUsed: true },
        });
        throw AppError.tooManyRequests('Maximum OTP verification attempts exceeded. Please request a new OTP.');
      }

      throw AppError.badRequest(`Invalid OTP code. ${remainingAttempts} attempts remaining.`);
    }

    // Success: mark OTP as used
    await prisma.otpVerification.update({
      where: { id: record.id },
      data: { isUsed: true },
    });

    return true;
  }
}

export const otpService = new OtpService();
