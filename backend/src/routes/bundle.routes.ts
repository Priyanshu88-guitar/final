import { Router } from 'express';
import { bundleController } from '../controllers/bundle.controller.js';
import { requireAuth, requireRole } from '../middleware/auth.middleware.js';
import { validate } from '../middleware/validate.middleware.js';
import { uuidParamSchema } from '../validators/common.validator.js';

const router = Router();

// Public listing
router.get('/', bundleController.getActiveBundles);
router.get('/:bundleId', validate({ params: uuidParamSchema }), bundleController.getBundleById);

// Protected Customer actions
router.post('/:bundleId/purchase', requireAuth, requireRole('CUSTOMER'), validate({ params: uuidParamSchema }), bundleController.purchaseBundle);

export const bundleRoutes = router;
