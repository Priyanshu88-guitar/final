import { Router } from 'express';
import { healthRoutes } from './health.routes.js';
import { authRoutes } from './auth.routes.js';
import { customerRoutes } from './customer.routes.js';
import { providerRoutes } from './provider.routes.js';
import { chargerRoutes } from './charger.routes.js';
import { paymentRoutes } from './payment.routes.js';
import { notificationRoutes } from './notification.routes.js';
import { bundleRoutes } from './bundle.routes.js';
import { emergencyRoutes } from './emergency.routes.js';
import { supportRoutes } from './support.routes.js';
import { adminRoutes } from './admin.routes.js';

const router = Router();

// Root routes
router.use('/health', healthRoutes);
router.use('/auth', authRoutes);
router.use('/customer', customerRoutes);
router.use('/provider', providerRoutes);
router.use('/chargers', chargerRoutes);
router.use('/payments', paymentRoutes); // Webhook
router.use('/notifications', notificationRoutes);
router.use('/bundles', bundleRoutes);
router.use('/emergency', emergencyRoutes);
router.use('/support', supportRoutes);
router.use('/admin', adminRoutes);

// API v1 router namespace
const v1Router = Router();
v1Router.use('/health', healthRoutes);
v1Router.use('/auth', authRoutes);
v1Router.use('/customer', customerRoutes);
v1Router.use('/provider', providerRoutes);
v1Router.use('/chargers', chargerRoutes);
v1Router.use('/payments', paymentRoutes);
v1Router.use('/notifications', notificationRoutes);
v1Router.use('/bundles', bundleRoutes);
v1Router.use('/emergency', emergencyRoutes);
v1Router.use('/support', supportRoutes);
v1Router.use('/admin', adminRoutes);

router.use('/api/v1', v1Router);

export const apiRouter = router;
