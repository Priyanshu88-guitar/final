export type BookingStatus = 'PENDING' | 'CONFIRMED' | 'REJECTED' | 'CANCELLED' | 'COMPLETED' | 'EXPIRED';
export type SessionStatus = 'PENDING' | 'ACTIVE' | 'COMPLETED' | 'CANCELLED' | 'FAILED';

export interface BookingModel {
  id: string;
  customerId: string;
  chargerId: string;
  startTime: Date;
  endTime: Date;
  status: BookingStatus;
  createdAt: Date;
  updatedAt: Date;
}

export interface ChargingSessionModel {
  id: string;
  bookingId: string;
  chargerId: string;
  customerId: string;
  startedAt: Date;
  endedAt: Date | null;
  status: SessionStatus;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateBookingInput {
  chargerId: string;
  startTime: string | Date;
  endTime: string | Date;
}
