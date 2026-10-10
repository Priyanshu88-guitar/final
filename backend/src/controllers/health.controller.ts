import { Request, Response, NextFunction } from 'express';
import { healthService } from '../services/health.service.js';
import { successResponse } from '../utils/response.js';

export class HealthController {
  public getHealth = async (
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> => {
    try {
      const healthData = await healthService.performHealthCheck();

      const statusCode = healthData.status === 'ok' ? 200 : 503;

      res.status(statusCode).json(
        successResponse('VOLTERA backend is running', healthData)
      );
    } catch (error) {
      next(error);
    }
  };
}

export const healthController = new HealthController();
