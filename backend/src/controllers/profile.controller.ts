import { Request, Response, NextFunction } from 'express';
import { profileService } from '../services/profile.service.js';
import { successResponse } from '../utils/response.js';

export class ProfileController {
  public getCustomerProfile = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const profile = await profileService.getCustomerProfile(userId);
      res.status(200).json(successResponse('Customer profile retrieved successfully', profile));
    } catch (error) {
      next(error);
    }
  };

  public saveCustomerProfile = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const profile = await profileService.saveCustomerProfile(userId, req.body);
      res.status(200).json(successResponse('Customer profile updated successfully', profile));
    } catch (error) {
      next(error);
    }
  };

  public getProviderProfile = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const profile = await profileService.getProviderProfile(userId);
      res.status(200).json(successResponse('Provider profile retrieved successfully', profile));
    } catch (error) {
      next(error);
    }
  };

  public saveProviderProfile = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const profile = await profileService.saveProviderProfile(userId, req.body);
      res.status(200).json(successResponse('Provider profile updated successfully', profile));
    } catch (error) {
      next(error);
    }
  };

  public getSavedChargers = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const list = await profileService.getSavedChargers(userId);
      res.status(200).json(successResponse('Saved chargers retrieved successfully', list));
    } catch (error) {
      next(error);
    }
  };

  public saveCharger = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const chargerId = req.params.chargerId;
      const result = await profileService.saveCharger(userId, chargerId);
      res.status(201).json(successResponse('Charger saved successfully', result));
    } catch (error) {
      next(error);
    }
  };

  public removeSavedCharger = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const chargerId = req.params.chargerId;
      const result = await profileService.removeSavedCharger(userId, chargerId);
      res.status(200).json(successResponse('Saved charger removed successfully', result));
    } catch (error) {
      next(error);
    }
  };
}

export const profileController = new ProfileController();
