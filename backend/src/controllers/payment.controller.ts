import { Request, Response, NextFunction } from 'express';
import { paymentService } from '../services/payment/payment.service.js';
import { financialService } from '../services/financial.service.js';
import { successResponse } from '../utils/response.js';

export class PaymentController {

  // --- CUSTOMER APIs ---

  public createPayment = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const customerId = req.user!.id;
      const result = await paymentService.createPaymentOrder(customerId, req.body);
      res.status(201).json(successResponse('Payment order created securely', result));
    } catch (error) {
      next(error);
    }
  };

  public getPaymentHistory = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const customerId = req.user!.id;
      const result = await financialService.getCustomerPaymentHistory(customerId);
      res.status(200).json(successResponse('Payment history retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  public getTransactionHistory = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const customerId = req.user!.id;
      const result = await financialService.getCustomerTransactions(customerId);
      res.status(200).json(successResponse('Transaction history retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  // --- WEBHOOK API ---

  public handleWebhook = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const result = await paymentService.handleWebhook(req.body);
      res.status(200).json(successResponse('Webhook processed', result));
    } catch (error) {
      next(error);
    }
  };
}

export const paymentController = new PaymentController();
