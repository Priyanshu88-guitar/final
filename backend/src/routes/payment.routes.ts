import { Router } from 'express';
import { paymentController } from '../controllers/payment.controller.js';
import { validate } from '../middleware/validate.middleware.js';

// Define strict payload validation or let service handle specific formats
// Assuming a generic webhook shape, let the paymentService enforce signature checks.

const router = Router();

// Public Webhook Endpoint (No Auth Middleware - Protected by Signature Check in Service)
router.post('/webhook', paymentController.handleWebhook);

export const paymentRoutes = router;
