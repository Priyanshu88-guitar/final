import { AppError } from '../utils/app-error.js';
import { financialRepository } from '../repositories/financial.repository.js';
import { BankAccountInput, PayoutRequestInput } from '../models/payment.model.js';

export class FinancialService {

  // --- CUSTOMER APIs ---

  async getCustomerPaymentHistory(customerId: string) {
    return financialRepository.getCustomerPayments(customerId);
  }

  async getCustomerTransactions(customerId: string) {
    return financialRepository.getCustomerTransactions(customerId);
  }

  // --- PROVIDER APIs ---

  async getProviderEarnings(providerId: string) {
    return financialRepository.getProviderEarnings(providerId);
  }

  async getProviderBank(providerId: string) {
    return financialRepository.getProviderBank(providerId);
  }

  async upsertProviderBank(providerId: string, input: BankAccountInput) {
    return financialRepository.upsertProviderBank(providerId, input);
  }

  async requestPayout(providerId: string, input: PayoutRequestInput) {
    // Input is presumably INR. Convert to paise for internal safety.
    const requestedPaise = Math.round(input.amount * 100);

    if (requestedPaise <= 0) {
      throw AppError.badRequest('Payout amount must be greater than zero');
    }

    return financialRepository.requestPayout(providerId, requestedPaise);
  }

  async getProviderPayouts(providerId: string) {
    return financialRepository.getProviderPayouts(providerId);
  }
}

export const financialService = new FinancialService();
