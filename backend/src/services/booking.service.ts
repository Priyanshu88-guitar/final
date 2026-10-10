import { AppError } from '../utils/app-error.js';
import { bookingRepository } from '../repositories/booking.repository.js';
import { CreateBookingInput } from '../models/booking.model.js';

export class BookingService {
  async createCustomerBooking(customerId: string, input: CreateBookingInput) {
    return bookingRepository.createBookingWithOverlapCheck(customerId, input);
  }

  async getCustomerBookings(customerId: string) {
    return bookingRepository.findCustomerBookings(customerId);
  }

  async getCustomerBookingDetails(customerId: string, bookingId: string) {
    const booking = await bookingRepository.findCustomerBookingById(customerId, bookingId);
    if (!booking) {
      throw AppError.notFound('Booking not found or you do not have permission');
    }
    return booking;
  }

  async cancelCustomerBooking(customerId: string, bookingId: string) {
    const booking = await bookingRepository.findCustomerBookingById(customerId, bookingId);
    if (!booking) throw AppError.notFound('Booking not found');

    if (!['PENDING', 'CONFIRMED'].includes(booking.status)) {
      throw AppError.badRequest('Booking cannot be cancelled from its current state');
    }

    if (booking.session?.status === 'ACTIVE') {
      throw AppError.badRequest('Cannot cancel booking with an active charging session');
    }

    return bookingRepository.updateBookingStatus(bookingId, 'CANCELLED');
  }

  async getProviderBookings(providerId: string) {
    return bookingRepository.findProviderBookingRequests(providerId);
  }

  async getProviderBookingDetails(providerId: string, bookingId: string) {
    const booking = await bookingRepository.findProviderBookingById(providerId, bookingId);
    if (!booking) {
      throw AppError.notFound('Booking not found or not authorized');
    }
    return booking;
  }

  // Not strictly used since we auto-confirm, but keeping here for future Provider approval flow
  async acceptBooking(providerId: string, bookingId: string) {
    const booking = await bookingRepository.findProviderBookingById(providerId, bookingId);
    if (!booking) throw AppError.notFound('Booking not found');
    if (booking.status !== 'PENDING') throw AppError.badRequest('Only PENDING bookings can be accepted');

    return bookingRepository.updateBookingStatus(bookingId, 'CONFIRMED');
  }

  async rejectBooking(providerId: string, bookingId: string) {
    const booking = await bookingRepository.findProviderBookingById(providerId, bookingId);
    if (!booking) throw AppError.notFound('Booking not found');
    if (booking.status !== 'PENDING') throw AppError.badRequest('Only PENDING bookings can be rejected');

    return bookingRepository.updateBookingStatus(bookingId, 'REJECTED');
  }

  async startSession(customerId: string, bookingId: string) {
    return bookingRepository.startSession(bookingId, customerId);
  }

  async endSession(customerId: string, sessionId: string) {
    return bookingRepository.endSession(sessionId, customerId);
  }

  async getActiveSession(customerId: string) {
    return bookingRepository.findCustomerActiveSession(customerId);
  }
}

export const bookingService = new BookingService();
