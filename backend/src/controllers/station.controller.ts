import { Request, Response, NextFunction } from 'express';
import { stationService } from '../services/station.service.js';
import { successResponse } from '../utils/response.js';
import { chargerDiscoveryFiltersSchema } from '../validators/station.validator.js';

export class StationController {
  // --- PROVIDER APIs ---

  public createStation = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const providerId = req.user!.id;
      const result = await stationService.createStation(providerId, req.body);
      res.status(201).json(successResponse('Station created successfully', result));
    } catch (error) {
      next(error);
    }
  };

  public getProviderStations = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const providerId = req.user!.id;
      const result = await stationService.getProviderStations(providerId);
      res.status(200).json(successResponse('Stations retrieved successfully', result));
    } catch (error) {
      next(error);
    }
  };

  public getProviderStationDetails = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const providerId = req.user!.id;
      const { stationId } = req.params;
      const result = await stationService.getProviderStationDetails(providerId, stationId);
      res.status(200).json(successResponse('Station details retrieved successfully', result));
    } catch (error) {
      next(error);
    }
  };

  public updateStation = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const providerId = req.user!.id;
      const { stationId } = req.params;
      const result = await stationService.updateStation(providerId, stationId, req.body);
      res.status(200).json(successResponse('Station updated successfully', result));
    } catch (error) {
      next(error);
    }
  };

  public createCharger = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const providerId = req.user!.id;
      const { stationId } = req.params;
      const result = await stationService.createCharger(providerId, stationId, req.body);
      res.status(201).json(successResponse('Charger added successfully', result));
    } catch (error) {
      next(error);
    }
  };

  public updateCharger = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const providerId = req.user!.id;
      const { chargerId } = req.params;
      const result = await stationService.updateCharger(providerId, chargerId, req.body);
      res.status(200).json(successResponse('Charger updated successfully', result));
    } catch (error) {
      next(error);
    }
  };

  // --- CUSTOMER APIs ---

  public discoverChargers = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      // Force parse here just to ensure it's strongly typed and actually applied
      // in case req.query object reassignment drops fields
      const filters = chargerDiscoveryFiltersSchema.parse(req.query);
      const result = await stationService.discoverChargers(filters);
      res.status(200).json(successResponse('Chargers discovered successfully', result));
    } catch (error) {
      next(error);
    }
  };

  public getChargerDetails = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { chargerId } = req.params;
      const result = await stationService.getChargerDetails(chargerId);
      res.status(200).json(successResponse('Charger details retrieved successfully', result));
    } catch (error) {
      next(error);
    }
  };
}

export const stationController = new StationController();
