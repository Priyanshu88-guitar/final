import { Router } from 'express';
import { profileController } from '../controllers/profile.controller.js';
import { stationController } from '../controllers/station.controller.js';
import { bookingController } from '../controllers/booking.controller.js';
import { financialController } from '../controllers/financial.controller.js';
import { requireAuth, requireRole } from '../middleware/auth.middleware.js';
import { validate } from '../middleware/validate.middleware.js';
import { saveProviderProfileSchema } from '../validators/profile.validator.js';
import { createStationSchema, updateStationSchema, createChargerSchema, updateChargerSchema } from '../validators/station.validator.js';
import { saveBankAccountSchema, requestPayoutSchema } from '../validators/payment.validator.js';

const router = Router();

// Require Auth & Role for all provider routes
router.use(requireAuth, requireRole('PROVIDER'));

// Profile Endpoints
router.get('/profile', profileController.getProviderProfile);
router.post('/profile', validate({ body: saveProviderProfileSchema }), profileController.saveProviderProfile);
router.put('/profile', validate({ body: saveProviderProfileSchema }), profileController.saveProviderProfile);
router.patch('/profile', validate({ body: saveProviderProfileSchema }), profileController.saveProviderProfile);

// Station Management Endpoints
router.post('/stations', validate({ body: createStationSchema }), stationController.createStation);
router.get('/stations', stationController.getProviderStations);
router.get('/stations/:stationId', stationController.getProviderStationDetails);
router.patch('/stations/:stationId', validate({ body: updateStationSchema }), stationController.updateStation);

// Charger Management Endpoints
router.post('/stations/:stationId/chargers', validate({ body: createChargerSchema }), stationController.createCharger);
router.patch('/chargers/:chargerId', validate({ body: updateChargerSchema }), stationController.updateCharger);

// Booking Requests Management
router.get('/bookings', bookingController.getProviderBookings);
router.get('/bookings/:bookingId', bookingController.getProviderBookingDetails);
router.post('/bookings/:bookingId/accept', bookingController.acceptBooking);
router.post('/bookings/:bookingId/reject', bookingController.rejectBooking);

// Financial Management Endpoints
router.get('/earnings', financialController.getEarnings);
router.get('/bank-account', financialController.getBankAccount);
router.post('/bank-account', validate({ body: saveBankAccountSchema }), financialController.saveBankAccount);
router.get('/payouts', financialController.getPayouts);
router.post('/payouts', validate({ body: requestPayoutSchema }), financialController.requestPayout);

export const providerRoutes = router;
