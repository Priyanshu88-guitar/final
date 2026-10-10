import { Request, Response, NextFunction } from 'express';
import { supportService } from '../services/support.service.js';
import { successResponse } from '../utils/response.js';

export class SupportController {
  public createTicket = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const result = await supportService.createTicket(userId, req.body);
      res.status(201).json(successResponse('Support ticket created', result));
    } catch (error) {
      next(error);
    }
  };

  public getUserTickets = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const result = await supportService.getUserTickets(userId);
      res.status(200).json(successResponse('Support tickets retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  public getTicketById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { ticketId } = req.params;
      const result = await supportService.getTicketById(userId, ticketId);
      res.status(200).json(successResponse('Support ticket retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  public addMessage = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { ticketId } = req.params;
      const result = await supportService.addMessage(userId, ticketId, req.body);
      res.status(201).json(successResponse('Message added successfully', result));
    } catch (error) {
      next(error);
    }
  };
}

export const supportController = new SupportController();
