import { Router } from 'express';
import { profileController } from '../controllers/profile.controller.js';
import { bookingController } from '../controllers/booking.controller.js';
import { paymentController } from '../controllers/payment.controller.js';
import { requireAuth, requireRole } from '../middleware/auth.middleware.js';
import { validate } from '../middleware/validate.middleware.js';
import { saveCustomerProfileSchema } from '../validators/profile.validator.js';
import { createBookingSchema } from '../validators/booking.validator.js';
import { createPaymentSchema } from '../validators/payment.validator.js';
import { saveCustomerVehicleSchema } from '../validators/profile.validator.js';

const router = Router();

// Require Auth & Role for all customer routes
router.use(requireAuth, requireRole('CUSTOMER'));

// Profiles
router.get('/profile', profileController.getCustomerProfile);
router.post('/profile', validate({ body: saveCustomerProfileSchema }), profileController.saveCustomerProfile);
router.put('/profile', validate({ body: saveCustomerProfileSchema }), profileController.saveCustomerProfile);
router.patch('/profile', validate({ body: saveCustomerProfileSchema }), profileController.saveCustomerProfile);

// Vehicles
router.get('/vehicles', profileController.getCustomerVehicles);
router.post('/vehicles', validate({ body: saveCustomerVehicleSchema }), profileController.addCustomerVehicle);

// Saved Chargers
router.get('/saved-chargers', profileController.getSavedChargers);
router.post('/saved-chargers/:chargerId', profileController.saveCharger);
router.delete('/saved-chargers/:chargerId', profileController.removeSavedCharger);

// Bookings
router.post('/bookings', validate({ body: createBookingSchema }), bookingController.createBooking);
router.get('/bookings', bookingController.getCustomerBookings);
router.get('/bookings/:bookingId', bookingController.getCustomerBookingDetails);
router.post('/bookings/:bookingId/cancel', bookingController.cancelCustomerBooking);

// Sessions
router.post('/bookings/:bookingId/start-session', bookingController.startSession);
router.get('/sessions/active', bookingController.getActiveSession);
router.post('/sessions/:sessionId/end', bookingController.endSession);

// Payments & Finances
router.post('/payments/create', validate({ body: createPaymentSchema }), paymentController.createPayment);
router.get('/payments', paymentController.getPaymentHistory);
router.get('/transactions', paymentController.getTransactionHistory);

export const customerRoutes = router;
