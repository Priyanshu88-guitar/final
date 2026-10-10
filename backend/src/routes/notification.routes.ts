import { Router } from 'express';
import { notificationController } from '../controllers/notification.controller.js';
import { requireAuth } from '../middleware/auth.middleware.js';
import { validate } from '../middleware/validate.middleware.js';
import { registerDeviceSchema, updatePreferencesSchema } from '../validators/notification.validator.js';
import { paginationQuerySchema, uuidParamSchema } from '../validators/common.validator.js';

const router = Router();

router.use(requireAuth);

// Preferences (Put these before /:notificationId to avoid route matching conflicts)
router.get('/preferences', notificationController.getPreferences);
router.patch('/preferences', validate({ body: updatePreferencesSchema }), notificationController.updatePreferences);

// Retrieval & Interaction
router.get('/', validate({ query: paginationQuerySchema }), notificationController.getUserNotifications);
router.get('/unread-count', notificationController.getUnreadCount);
router.get('/:notificationId', validate({ params: uuidParamSchema }), notificationController.getNotificationById);
router.patch('/read-all', notificationController.markAllAsRead);
router.patch('/:notificationId/read', validate({ params: uuidParamSchema }), notificationController.markAsRead);

// Device Management
router.post('/devices/register', validate({ body: registerDeviceSchema }), notificationController.registerDevice);
router.post('/devices/unregister', notificationController.unregisterDevice);

export const notificationRoutes = router;
