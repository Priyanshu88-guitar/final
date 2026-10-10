import { Router } from 'express';
import { adminController } from '../controllers/admin.controller.js';
import { requireAuth, requireRole } from '../middleware/auth.middleware.js';
import { validate } from '../middleware/validate.middleware.js';
import { updateAccountStatusSchema, updateProviderVerificationSchema } from '../validators/admin.validator.js';
import { paginationQuerySchema, uuidParamSchema } from '../validators/common.validator.js';

const router = Router();

// Absolutely enforce ADMIN role on ALL endpoints below
router.use(requireAuth, requireRole('ADMIN'));

router.get('/dashboard', adminController.getDashboard);

// User Management
router.get('/users', validate({ query: paginationQuerySchema }), adminController.getUsers);
router.patch('/users/:id/status', validate({ params: uuidParamSchema, body: updateAccountStatusSchema }), adminController.updateUserStatus);

// Provider Management
router.get('/providers', validate({ query: paginationQuerySchema }), adminController.getProviders);
router.patch('/providers/:id/verification', validate({ params: uuidParamSchema, body: updateProviderVerificationSchema }), adminController.updateProviderVerification);

// Generic Lists
router.get('/stations', validate({ query: paginationQuerySchema }), adminController.getStations);
router.get('/bookings', validate({ query: paginationQuerySchema }), adminController.getBookings);

export const adminRoutes = router;
