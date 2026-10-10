import { Request, Response, NextFunction } from 'express';
import { notificationService } from '../services/notification/notification.service.js';
import { successResponse } from '../utils/response.js';

export class NotificationController {

  public getUserNotifications = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const page = req.query.page ? parseInt(req.query.page as string, 10) : 1;
      const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : 20;

      const result = await notificationService.getUserNotifications(userId, page, limit);
      res.status(200).json(successResponse('Notifications retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  public getUnreadCount = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const result = await notificationService.getUnreadCount(userId);
      res.status(200).json(successResponse('Unread count retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  public markAsRead = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { notificationId } = req.params;
      const result = await notificationService.markAsRead(userId, notificationId);
      res.status(200).json(successResponse('Notification marked as read', result));
    } catch (error) {
      next(error);
    }
  };

  public markAllAsRead = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      await notificationService.markAllAsRead(userId);
      res.status(200).json(successResponse('All notifications marked as read'));
    } catch (error) {
      next(error);
    }
  };

  public getNotificationById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { notificationId } = req.params;
      const result = await notificationService.getNotificationById(userId, notificationId);
      res.status(200).json(successResponse('Notification retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  public registerDevice = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const result = await notificationService.registerDevice(userId, req.body);
      res.status(200).json(successResponse('Device registered successfully', result));
    } catch (error) {
      next(error);
    }
  };

  public unregisterDevice = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { token } = req.body;
      await notificationService.unregisterDevice(userId, token);
      res.status(200).json(successResponse('Device unregistered successfully'));
    } catch (error) {
      next(error);
    }
  };

  public getPreferences = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const result = await notificationService.getPreferences(userId);
      res.status(200).json(successResponse('Preferences retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  public updatePreferences = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const result = await notificationService.updatePreferences(userId, req.body);
      res.status(200).json(successResponse('Preferences updated', result));
    } catch (error) {
      next(error);
    }
  };
}

export const notificationController = new NotificationController();
