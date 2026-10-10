import { Request, Response, NextFunction } from 'express';
import { bundleService } from '../services/bundle.service.js';
import { successResponse } from '../utils/response.js';

export class BundleController {
  public getActiveBundles = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const result = await bundleService.getActiveBundles();
      res.status(200).json(successResponse('Bundles retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  public getBundleById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { bundleId } = req.params;
      const result = await bundleService.getBundleById(bundleId);
      res.status(200).json(successResponse('Bundle retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  public purchaseBundle = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const customerId = req.user!.id;
      const { bundleId } = req.params;
      const result = await bundleService.purchaseBundle(customerId, bundleId);
      res.status(201).json(successResponse('Bundle purchase initiated', result));
    } catch (error) {
      next(error);
    }
  };

  public getCustomerBundlePurchases = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const customerId = req.user!.id;
      const result = await bundleService.getCustomerBundlePurchases(customerId);
      res.status(200).json(successResponse('Bundle purchases retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  public getCustomerBundlePurchaseById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const customerId = req.user!.id;
      const { purchaseId } = req.params;
      const result = await bundleService.getCustomerBundlePurchaseById(customerId, purchaseId);
      res.status(200).json(successResponse('Bundle purchase details retrieved', result));
    } catch (error) {
      next(error);
    }
  };
}

export const bundleController = new BundleController();
