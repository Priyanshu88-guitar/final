import { Router } from 'express';
import { emergencyController } from '../controllers/emergency.controller.js';
import { requireAuth } from '../middleware/auth.middleware.js';
import { validate } from '../middleware/validate.middleware.js';
import { createEmergencyRequestSchema } from '../validators/emergency.validator.js';

const router = Router();

// Public / Protected
router.get('/services', emergencyController.getActiveServices);

// Protected actions for users (Customer or Provider)
router.use(requireAuth);
router.post('/requests', validate({ body: createEmergencyRequestSchema }), emergencyController.createRequest);
router.get('/requests', emergencyController.getUserRequests);

export const emergencyRoutes = router;
