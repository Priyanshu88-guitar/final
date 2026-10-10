import { Request, Response, NextFunction } from 'express';
import { bookingService } from '../services/booking.service.js';
import { successResponse } from '../utils/response.js';

export class BookingController {
  // --- CUSTOMER APIs ---

  public createBooking = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const customerId = req.user!.id;
      const result = await bookingService.createCustomerBooking(customerId, req.body);
      res.status(201).json(successResponse('Booking created successfully', result));
    } catch (error) {
      next(error);
    }
  };

  public getCustomerBookings = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const customerId = req.user!.id;
      const result = await bookingService.getCustomerBookings(customerId);
      res.status(200).json(successResponse('Bookings retrieved successfully', result));
    } catch (error) {
      next(error);
    }
  };

  public getCustomerBookingDetails = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const customerId = req.user!.id;
      const { bookingId } = req.params;
      const result = await bookingService.getCustomerBookingDetails(customerId, bookingId);
      res.status(200).json(successResponse('Booking details retrieved successfully', result));
    } catch (error) {
      next(error);
    }
  };

  public cancelCustomerBooking = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const customerId = req.user!.id;
      const { bookingId } = req.params;
      const result = await bookingService.cancelCustomerBooking(customerId, bookingId);
      res.status(200).json(successResponse('Booking cancelled successfully', result));
    } catch (error) {
      next(error);
    }
  };

  public startSession = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const customerId = req.user!.id;
      const { bookingId } = req.params;
      const result = await bookingService.startSession(customerId, bookingId);
      res.status(201).json(successResponse('Charging session started successfully', result));
    } catch (error) {
      next(error);
    }
  };

  public getActiveSession = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const customerId = req.user!.id;
      const result = await bookingService.getActiveSession(customerId);
      res.status(200).json(successResponse('Active session retrieved', result));
    } catch (error) {
      next(error);
    }
  };

  public endSession = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const customerId = req.user!.id;
      const { sessionId } = req.params;
      const result = await bookingService.endSession(customerId, sessionId);
      res.status(200).json(successResponse('Charging session ended successfully', result));
    } catch (error) {
      next(error);
    }
  };

  // --- PROVIDER APIs ---

  public getProviderBookings = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const providerId = req.user!.id;
      const result = await bookingService.getProviderBookings(providerId);
      res.status(200).json(successResponse('Booking requests retrieved successfully', result));
    } catch (error) {
      next(error);
    }
  };

  public getProviderBookingDetails = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const providerId = req.user!.id;
      const { bookingId } = req.params;
      const result = await bookingService.getProviderBookingDetails(providerId, bookingId);
      res.status(200).json(successResponse('Booking details retrieved successfully', result));
    } catch (error) {
      next(error);
    }
  };

  public acceptBooking = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const providerId = req.user!.id;
      const { bookingId } = req.params;
      const result = await bookingService.acceptBooking(providerId, bookingId);
      res.status(200).json(successResponse('Booking accepted', result));
    } catch (error) {
      next(error);
    }
  };

  public rejectBooking = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const providerId = req.user!.id;
      const { bookingId } = req.params;
      const result = await bookingService.rejectBooking(providerId, bookingId);
      res.status(200).json(successResponse('Booking rejected', result));
    } catch (error) {
      next(error);
    }
  };
}

export const bookingController = new BookingController();
