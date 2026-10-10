import { Request, Response, NextFunction } from 'express';
import { authService } from '../services/auth.service.js';
import { otpService } from '../services/otp/otp.service.js';
import { successResponse } from '../utils/response.js';
import { validateAndNormalizeIndianPhone } from '../utils/phone-validator.js';

export class AuthController {
  public signup = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const result = await authService.signup(req.body);
      res.status(201).json(successResponse(result.message, { userId: result.userId }));
    } catch (error) {
      next(error);
    }
  };

  public registerRole = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { role } = req.body;
      const authData = await authService.registerRole(userId, role);
      res.status(200).json(successResponse('Role registered successfully', authData));
    } catch (error) {
      next(error);
    }
  };

  public verifyOtp = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { phone, otp, purpose } = req.body;
      if (purpose === 'SIGNUP_VERIFICATION') {
        const authData = await authService.verifySignupOtp(phone, otp);
        res.status(200).json(successResponse('Mobile number verified successfully', authData));
      } else {
        const normalizedPhone = validateAndNormalizeIndianPhone(phone);
        await otpService.verifyOtp(normalizedPhone, purpose, otp);
        res.status(200).json(successResponse('OTP verified successfully'));
      }
    } catch (error) {
      next(error);
    }
  };

  public resendOtp = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { phone, purpose } = req.body;
      const normalizedPhone = validateAndNormalizeIndianPhone(phone);
      const result = await otpService.generateAndSendOtp(normalizedPhone, purpose);
      res.status(200).json(successResponse(result.message, { cooldownSeconds: result.cooldownSeconds }));
    } catch (error) {
      next(error);
    }
  };

  public login = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { phone, password } = req.body;
      const authData = await authService.login(phone, password);
      res.status(200).json(successResponse('Login successful', authData));
    } catch (error) {
      next(error);
    }
  };

  public logout = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const refreshToken = req.body?.refreshToken;
      await authService.logout(userId, refreshToken);
      res.status(200).json(successResponse('Logged out successfully'));
    } catch (error) {
      next(error);
    }
  };

  public me = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const currentUser = await authService.getCurrentUser(userId);
      res.status(200).json(
        successResponse('Authenticated user profile', {
          user: currentUser,
          activeRole: req.user!.activeRole,
        })
      );
    } catch (error) {
      next(error);
    }
  };

  public forgotPassword = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { phone } = req.body;
      const result = await authService.forgotPassword(phone);
      res.status(200).json(successResponse(result.message));
    } catch (error) {
      next(error);
    }
  };

  public resetPassword = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { phone, otp, newPassword } = req.body;
      const result = await authService.resetPassword(phone, otp, newPassword);
      res.status(200).json(successResponse(result.message));
    } catch (error) {
      next(error);
    }
  };

  public changePassword = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const userId = req.user!.id;
      const { currentPassword, newPassword } = req.body;
      const result = await authService.changePassword(userId, currentPassword, newPassword);
      res.status(200).json(successResponse(result.message));
    } catch (error) {
      next(error);
    }
  };
}

export const authController = new AuthController();
