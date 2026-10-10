import { Request, Response, NextFunction } from 'express';
import { emergencyService } from '../services/emergency.service.js';
import { successResponse } from '../utils/response.js';

export class EmergencyController {
  public getActiveServices = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const result = await emergencyService.getActiveServices();
      res.status(200).json(successResponse('Emergency services retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  public createRequest = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id; // Available to both Customers & Providers
      const result = await emergencyService.createRequest(userId, req.body);
      res.status(201).json(successResponse('Emergency request created', result));
    } catch (error) {
      next(error);
    }
  };

  public getUserRequests = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const result = await emergencyService.getUserRequests(userId);
      res.status(200).json(successResponse('Emergency requests retrieved', result));
    } catch (error) {
      next(error);
    }
  };
}

export const emergencyController = new EmergencyController();
