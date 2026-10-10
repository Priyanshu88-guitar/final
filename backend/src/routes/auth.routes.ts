import { Router, Request, Response } from 'express';
import { authController } from '../controllers/auth.controller.js';
import { validate } from '../middleware/validate.middleware.js';
import { requireAuth, requireRole } from '../middleware/auth.middleware.js';
import { loginRateLimiter, otpRateLimiter } from '../middleware/rate-limit.middleware.js';
import {
  signupSchema,
  verifyOtpSchema,
  resendOtpSchema,
  loginSchema,
  forgotPasswordSchema,
  resetPasswordSchema,
  changePasswordSchema,
} from '../validators/auth.validator.js';
import { successResponse } from '../utils/response.js';

const router = Router();

// Public Authentication Endpoints
router.post('/signup', validate({ body: signupSchema }), authController.signup);
router.post('/otp/verify', otpRateLimiter, validate({ body: verifyOtpSchema }), authController.verifyOtp);
router.post('/otp/resend', otpRateLimiter, validate({ body: resendOtpSchema }), authController.resendOtp);
router.post('/login', loginRateLimiter, validate({ body: loginSchema }), authController.login);
router.post('/password/forgot', otpRateLimiter, validate({ body: forgotPasswordSchema }), authController.forgotPassword);
router.post('/password/reset', otpRateLimiter, validate({ body: resetPasswordSchema }), authController.resetPassword);

// Protected Authentication Endpoints
router.post('/logout', requireAuth, authController.logout);
router.get('/me', requireAuth, authController.me);
router.post('/register-role', requireAuth, authController.registerRole);
router.post('/password/change', requireAuth, validate({ body: changePasswordSchema }), authController.changePassword);

// Protected Role Authorization Verification Endpoints
router.get('/protected/customer-only', requireAuth, requireRole('CUSTOMER'), (req: Request, res: Response) => {
  res.status(200).json(successResponse('Customer endpoint accessed successfully', { activeRole: req.user?.activeRole }));
});

router.get('/protected/provider-only', requireAuth, requireRole('PROVIDER'), (req: Request, res: Response) => {
  res.status(200).json(successResponse('Provider endpoint accessed successfully', { activeRole: req.user?.activeRole }));
});

router.get('/protected/admin-only', requireAuth, requireRole('ADMIN'), (req: Request, res: Response) => {
  res.status(200).json(successResponse('Admin endpoint accessed successfully', { activeRole: req.user?.activeRole }));
});

export const authRoutes = router;
