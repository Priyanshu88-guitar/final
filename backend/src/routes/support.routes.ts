import { Router } from 'express';
import { supportController } from '../controllers/support.controller.js';
import { requireAuth } from '../middleware/auth.middleware.js';
import { validate } from '../middleware/validate.middleware.js';
import { createSupportTicketSchema, addSupportMessageSchema } from '../validators/support.validator.js';
import { uuidParamSchema } from '../validators/common.validator.js';

const router = Router();

// Used by both Customers and Providers (Role-agnostic authenticated operations targeting own tickets)
router.use(requireAuth);

router.post('/tickets', validate({ body: createSupportTicketSchema }), supportController.createTicket);
router.get('/tickets', supportController.getUserTickets);
router.get('/tickets/:ticketId', validate({ params: uuidParamSchema.extend({ ticketId: uuidParamSchema.shape.id }) }), supportController.getTicketById);
router.post('/tickets/:ticketId/messages', validate({ params: uuidParamSchema.extend({ ticketId: uuidParamSchema.shape.id }), body: addSupportMessageSchema }), supportController.addMessage);

export const supportRoutes = router;
