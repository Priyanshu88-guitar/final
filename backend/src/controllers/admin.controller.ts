import { Request, Response, NextFunction } from 'express';
import { adminService } from '../services/admin.service.js';
import { successResponse } from '../utils/response.js';

export class AdminController {

  public getDashboard = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const result = await adminService.getDashboardMetrics();
      res.status(200).json(successResponse('Dashboard metrics retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  public getUsers = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const page = req.query.page ? parseInt(req.query.page as string, 10) : 1;
      const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : 20;
      const roleFilter = req.query.role as string | undefined;

      const result = await adminService.getUsers(page, limit, roleFilter);
      res.status(200).json(successResponse('Users retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  public updateUserStatus = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const adminId = req.user!.id;
      const { id } = req.params;
      const { status } = req.body;
      const result = await adminService.updateUserStatus(adminId, id, status);
      res.status(200).json(successResponse('User status updated', result));
    } catch (error) {
      next(error);
    }
  };

  public getProviders = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const page = req.query.page ? parseInt(req.query.page as string, 10) : 1;
      const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : 20;

      const result = await adminService.getProviders(page, limit);
      res.status(200).json(successResponse('Providers retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  public updateProviderVerification = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const adminId = req.user!.id;
      const { id } = req.params; // Using the User ID as the reference for simplicity
      const { status } = req.body;
      const result = await adminService.updateProviderVerification(adminId, id, status);
      res.status(200).json(successResponse('Provider verification updated', result));
    } catch (error) {
      next(error);
    }
  };

  public getStations = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const page = req.query.page ? parseInt(req.query.page as string, 10) : 1;
      const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : 20;
      const result = await adminService.getStations(page, limit);
      res.status(200).json(successResponse('Stations retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  public getBookings = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const page = req.query.page ? parseInt(req.query.page as string, 10) : 1;
      const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : 20;
      const result = await adminService.getBookings(page, limit);
      res.status(200).json(successResponse('Bookings retrieved', result));
    } catch (error) {
      next(error);
    }
  };
}

export const adminController = new AdminController();
