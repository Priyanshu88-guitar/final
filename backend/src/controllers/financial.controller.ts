import { Request, Response, NextFunction } from 'express';
import { financialService } from '../services/financial.service.js';
import { successResponse } from '../utils/response.js';

export class FinancialController {

  // --- PROVIDER APIs ---

  public getEarnings = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const providerId = req.user!.id;
      const result = await financialService.getProviderEarnings(providerId);
      res.status(200).json(successResponse('Earnings retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  public getBankAccount = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const providerId = req.user!.id;
      const result = await financialService.getProviderBank(providerId);
      // It's okay if result is null; frontend will handle empty bank details
      res.status(200).json(successResponse('Bank account retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  public saveBankAccount = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const providerId = req.user!.id;
      const result = await financialService.upsertProviderBank(providerId, req.body);
      res.status(200).json(successResponse('Bank account saved', result));
    } catch (error) {
      next(error);
    }
  };

  public requestPayout = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const providerId = req.user!.id;
      const result = await financialService.requestPayout(providerId, req.body);
      res.status(201).json(successResponse('Payout requested successfully', result));
    } catch (error) {
      next(error);
    }
  };

  public getPayouts = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const providerId = req.user!.id;
      const result = await financialService.getProviderPayouts(providerId);
      res.status(200).json(successResponse('Payouts history retrieved', result));
    } catch (error) {
      next(error);
    }
  };
}

export const financialController = new FinancialController();
