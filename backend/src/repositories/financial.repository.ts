import { prisma } from '../database/prisma.js';
import { PaymentStatus, TransactionType, PayoutStatus, BankAccountInput } from '../models/payment.model.js';
import { AppError } from '../utils/app-error.js';

export class FinancialRepository {
  async getChargeableBookingDetails(bookingId: string, customerId: string) {
    const booking = await prisma.booking.findFirst({
      where: { id: bookingId, customerId },
      include: {
        charger: { include: { station: true } },
      },
    });

    if (!booking) {
      throw AppError.notFound('Booking not found');
    }

    return booking;
  }

  async getChargeableSessionDetails(sessionId: string, customerId: string) {
    const session = await prisma.chargingSession.findFirst({
      where: { id: sessionId, customerId },
      include: {
        charger: { include: { station: true } },
        booking: true,
      },
    });

    if (!session) {
      throw AppError.notFound('Session not found');
    }

    return session;
  }

  async createPaymentOrder(
    customerId: string,
    amountPaise: number,
    provider: string,
    gatewayOrderId: string,
    bookingId?: string,
    sessionId?: string,
    bundlePurchaseId?: string
  ) {
    return prisma.payment.create({
      data: {
        customerId,
        amount: amountPaise,
        currency: 'INR',
        status: 'CREATED',
        gatewayProvider: provider,
        gatewayOrderId,
        ...(bookingId && { bookingId }),
        ...(sessionId && { sessionId }),
        ...(bundlePurchaseId && { bundlePurchaseId }),
      },
    });
  }

  async findPaymentByOrderId(gatewayOrderId: string) {
    return prisma.payment.findUnique({
      where: { gatewayOrderId },
      include: { booking: { include: { charger: { include: { station: true } } } }, session: true },
    });
  }

  async markPaymentAsPaid(paymentId: string, gatewayPaymentId: string, providerId: string | undefined, platformFeePercentage: number) {
    return prisma.$transaction(async (tx) => {
      const payment = await tx.payment.findUnique({ where: { id: paymentId } });
      if (!payment) throw AppError.notFound('Payment not found');

      // Idempotency: If already paid, do nothing
      if (payment.status === 'PAID') return payment;

      const updatedPayment = await tx.payment.update({
        where: { id: paymentId },
        data: {
          status: 'PAID',
          gatewayPaymentId,
          paidAt: new Date(),
        },
      });

      // Create Payment Transaction
      // If providerId is set, it's a provider transaction.
      // If undefined (e.g. Bundle Purchase), it's a platform transaction (no providerId)
      await tx.transaction.create({
        data: {
          customerId: payment.customerId,
          ...(providerId && { providerId }),
          paymentId: payment.id,
          type: 'PAYMENT',
          amount: payment.amount,
          currency: payment.currency,
          status: 'COMPLETED',
        },
      });

      if (providerId) {
        // Calculate and deduct commission for provider payments
        const commissionAmount = Math.round(payment.amount * (platformFeePercentage / 100));

        if (commissionAmount > 0) {
          await tx.transaction.create({
            data: {
              customerId: payment.customerId,
              providerId,
              paymentId: payment.id,
              type: 'COMMISSION',
              amount: commissionAmount,
              currency: payment.currency,
              status: 'COMPLETED',
            },
          });
        }
      }

      // Activate Bundle Purchase if applicable
      if (payment.bundlePurchaseId) {
        const bp = await tx.bundlePurchase.findUnique({ where: { id: payment.bundlePurchaseId }, include: { bundle: true } });
        if (bp && bp.status !== 'ACTIVE') {
          let expiresAt = null;
          if (bp.bundle.validityDays) {
            expiresAt = new Date();
            expiresAt.setDate(expiresAt.getDate() + bp.bundle.validityDays);
          }
          await tx.bundlePurchase.update({
            where: { id: bp.id },
            data: {
              status: 'ACTIVE',
              purchasedAt: new Date(),
              expiresAt,
            }
          });
        }
      }

      return updatedPayment;
    });
  }

  async markPaymentAsFailed(paymentId: string) {
    return prisma.$transaction(async (tx) => {
      const payment = await tx.payment.update({
        where: { id: paymentId },
        data: { status: 'FAILED' },
      });

      if (payment.bundlePurchaseId) {
         await tx.bundlePurchase.update({
            where: { id: payment.bundlePurchaseId },
            data: { status: 'FAILED' }
         });
      }

      return payment;
    });
  }

  async getCustomerPayments(customerId: string) {
    return prisma.payment.findMany({
      where: { customerId },
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        amount: true,
        currency: true,
        status: true,
        gatewayProvider: true,
        createdAt: true,
        paidAt: true,
        bookingId: true,
        sessionId: true,
        bundlePurchaseId: true,
      }
    });
  }

  async getCustomerTransactions(customerId: string) {
    return prisma.transaction.findMany({
      where: { customerId, type: 'PAYMENT' }, // Limit to customer relevant transactions to avoid duplicate display (Commission is internal)
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        type: true,
        amount: true,
        currency: true,
        status: true,
        createdAt: true,
        paymentId: true,
      }
    });
  }

  async getProviderEarnings(providerId: string) {
    const transactions = await prisma.transaction.findMany({
      where: { providerId, status: 'COMPLETED' },
    });

    let totalEarnedPaise = 0;
    let totalCommissionPaise = 0;
    let totalPaidOutPaise = 0;

    for (const txn of transactions) {
      if (txn.type === 'PAYMENT') totalEarnedPaise += txn.amount;
      else if (txn.type === 'COMMISSION') totalCommissionPaise += txn.amount;
      else if (txn.type === 'PAYOUT') totalPaidOutPaise += txn.amount;
      else if (txn.type === 'REFUND') totalEarnedPaise -= txn.amount; // Simple handling
    }

    // Also account for pending payouts in REQUESTED or PROCESSING states for available balance calculations
    const pendingPayouts = await prisma.providerPayout.findMany({
      where: { providerId, status: { in: ['REQUESTED', 'PROCESSING'] } },
    });

    const pendingAmount = pendingPayouts.reduce((sum, p) => sum + p.amount, 0);

    const netEarningsPaise = totalEarnedPaise - totalCommissionPaise;
    const availableBalancePaise = netEarningsPaise - totalPaidOutPaise - pendingAmount;

    return {
      totalEarnedPaise,
      totalCommissionPaise,
      netEarningsPaise,
      totalPaidOutPaise,
      availableBalancePaise,
    };
  }

  async getProviderBank(providerId: string) {
    return prisma.providerBankAccount.findUnique({
      where: { providerId },
    });
  }

  async upsertProviderBank(providerId: string, input: BankAccountInput) {
    return prisma.providerBankAccount.upsert({
      where: { providerId },
      create: {
        providerId,
        accountName: input.accountName,
        accountNumber: input.accountNumber,
        ifscCode: input.ifscCode,
        bankName: input.bankName || null,
      },
      update: {
        accountName: input.accountName,
        accountNumber: input.accountNumber,
        ifscCode: input.ifscCode,
        bankName: input.bankName || null,
        isVerified: false, // Reset verification on change
      },
    });
  }

  async requestPayout(providerId: string, requestedAmountPaise: number) {
    return prisma.$transaction(async (tx) => {
      // 1. Double check bank exists
      const bank = await tx.providerBankAccount.findUnique({ where: { providerId } });
      if (!bank) throw AppError.badRequest('Bank account details missing');

      // 2. Calculate true balance
      const transactions = await tx.transaction.findMany({
        where: { providerId, status: 'COMPLETED' },
      });

      let netEarned = 0;
      let totalPaidOut = 0;

      for (const txn of transactions) {
        if (txn.type === 'PAYMENT') netEarned += txn.amount;
        else if (txn.type === 'COMMISSION') netEarned -= txn.amount;
        else if (txn.type === 'PAYOUT') totalPaidOut += txn.amount;
        else if (txn.type === 'REFUND') netEarned -= txn.amount;
      }

      // Also account for pending payouts in REQUESTED or PROCESSING states
      const pendingPayouts = await tx.providerPayout.findMany({
        where: { providerId, status: { in: ['REQUESTED', 'PROCESSING'] } },
      });

      const pendingAmount = pendingPayouts.reduce((sum, p) => sum + p.amount, 0);

      const availableBalancePaise = netEarned - totalPaidOut - pendingAmount;

      if (requestedAmountPaise > availableBalancePaise) {
        throw AppError.badRequest('Insufficient available balance for this payout');
      }

      // 3. Create Payout Request
      return tx.providerPayout.create({
        data: {
          providerId,
          amount: requestedAmountPaise,
          currency: 'INR',
          status: 'REQUESTED',
        },
      });
    });
  }

  async getProviderPayouts(providerId: string) {
    return prisma.providerPayout.findMany({
      where: { providerId },
      orderBy: { createdAt: 'desc' },
    });
  }
}

export const financialRepository = new FinancialRepository();
