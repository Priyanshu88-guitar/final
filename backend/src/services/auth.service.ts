import { prisma } from '../database/prisma.js';
import { env } from '../config/env.js';
import { AppError } from '../utils/app-error.js';
import { hashPassword, verifyPassword, validatePasswordRequirements } from '../utils/password.js';
import { generateAccessToken, generateRefreshToken, hashToken } from '../utils/token.js';
import { validateAndNormalizeIndianPhone } from '../utils/phone-validator.js';
import { otpService } from './otp/otp.service.js';
import { UserRoleType } from '../models/user.model.js';

export interface SignupInput {
  fullName: string;
  phone: string;
  email?: string;
  password: string;
  role: 'CUSTOMER' | 'PROVIDER';
}

export interface AuthResponseData {
  user: {
    id: string;
    fullName: string | null;
    phoneNumber: string;
    email: string | null;
    accountStatus: string;
    isPhoneVerified: boolean;
    roles: UserRoleType[];
    providerVerificationStatus?: string | null;
  };
  tokens?: {
    accessToken: string;
    refreshToken: string;
  };
}

export class AuthService {
  async signup(input: SignupInput): Promise<{ message: string; userId: string }> {
    const normalizedPhone = validateAndNormalizeIndianPhone(input.phone);
    validatePasswordRequirements(input.password);

    if ((input.role as string).toUpperCase() === 'ADMIN') {
      throw AppError.forbidden('Admin accounts cannot be created via public signup.');
    }

    const targetRole = input.role.toUpperCase() as 'CUSTOMER' | 'PROVIDER';

    // Check if user already exists
    const existingUser = await prisma.user.findUnique({
      where: { phoneNumber: normalizedPhone },
      include: { roles: true },
    });

    let userId: string;

    if (existingUser) {
      const existingRoles = existingUser.roles.map((r) => r.role);
      if (existingRoles.includes(targetRole)) {
        throw AppError.conflict(`An account with phone number +91${normalizedPhone} already exists with role ${targetRole}. Please log in.`);
      }

      // Multi-Role Support: Attach new role to existing user
      await prisma.userRole.create({
        data: {
          userId: existingUser.id,
          role: targetRole,
        },
      });

      userId = existingUser.id;
    } else {
      // Create new user
      const pwdHash = await hashPassword(input.password);

      const newUser = await prisma.user.create({
        data: {
          fullName: input.fullName,
          phoneNumber: normalizedPhone,
          email: input.email || null,
          passwordHash: pwdHash,
          accountStatus: 'PENDING_VERIFICATION',
          isPhoneVerified: false,
          roles: {
            create: [{ role: targetRole }],
          },
        },
      });

      userId = newUser.id;
    }

    // Automatically approve provider registration for demo mode
    if (targetRole === 'PROVIDER') {
      await prisma.providerProfile.upsert({
        where: { userId },
        create: {
          userId,
          businessName: input.fullName || 'My EV Business',
          contactPhone: normalizedPhone,
          contactEmail: input.email || null,
          address: 'Demo Address, Ahmedabad',
          city: 'Ahmedabad',
          state: 'Gujarat',
          pincode: '380001',
          verificationStatus: 'VERIFIED',
        },
        update: {
          verificationStatus: 'VERIFIED',
        },
      });
    } else if (targetRole === 'CUSTOMER') {
      await prisma.customerProfile.upsert({
        where: { userId },
        create: {
          userId,
          fullName: input.fullName || 'Customer',
          city: 'Ahmedabad',
          state: 'Gujarat',
          pincode: '380001',
        },
        update: {},
      });
    }

    // Send OTP for signup verification
    await otpService.generateAndSendOtp(normalizedPhone, 'SIGNUP_VERIFICATION', userId, {
      skipCooldown: env.APP_ENV === 'test',
    });

    return {
      message: 'Signup successful. Verification OTP sent to mobile number.',
      userId,
    };
  }

  async registerRole(userId: string, role: string): Promise<AuthResponseData> {
    const targetRole = role.toUpperCase() as 'CUSTOMER' | 'PROVIDER' | 'ADMIN';
    if (targetRole === 'ADMIN') {
      throw AppError.forbidden('Cannot self-register as ADMIN.');
    }

    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { roles: true, providerProfile: true },
    });

    if (!user) {
      throw AppError.notFound('User not found');
    }

    const existingRoles = user.roles.map((r) => r.role);
    if (!existingRoles.includes(targetRole)) {
      await prisma.userRole.create({
        data: {
          userId,
          role: targetRole,
        },
      });
    }

    if (targetRole === 'PROVIDER') {
      await prisma.providerProfile.upsert({
        where: { userId },
        create: {
          userId,
          businessName: user.fullName || 'My EV Business',
          contactPhone: user.phoneNumber,
          contactEmail: user.email,
          address: 'Demo Address, Ahmedabad',
          city: 'Ahmedabad',
          state: 'Gujarat',
          pincode: '380001',
          verificationStatus: 'VERIFIED',
        },
        update: {
          verificationStatus: 'VERIFIED',
        },
      });
    } else if (targetRole === 'CUSTOMER') {
      await prisma.customerProfile.upsert({
        where: { userId },
        create: {
          userId,
          fullName: user.fullName || 'Customer',
          city: 'Ahmedabad',
          state: 'Gujarat',
          pincode: '380001',
        },
        update: {},
      });
    }

    const updatedUser = await prisma.user.findUnique({
      where: { id: userId },
      include: { roles: true, providerProfile: true },
    });

    const roles = updatedUser!.roles.map((r) => r.role as UserRoleType);
    const accessToken = generateAccessToken(userId, user.phoneNumber, roles);
    const refreshToken = generateRefreshToken(userId);

    return {
      user: {
        id: updatedUser!.id,
        fullName: updatedUser!.fullName,
        phoneNumber: updatedUser!.phoneNumber,
        email: updatedUser!.email,
        accountStatus: updatedUser!.accountStatus,
        isPhoneVerified: updatedUser!.isPhoneVerified,
        roles,
        providerVerificationStatus: updatedUser!.providerProfile?.verificationStatus || null,
      },
      tokens: {
        accessToken,
        refreshToken,
      },
    };
  }

  async verifySignupOtp(phone: string, otp: string): Promise<AuthResponseData> {
    const normalizedPhone = validateAndNormalizeIndianPhone(phone);

    await otpService.verifyOtp(normalizedPhone, 'SIGNUP_VERIFICATION', otp);

    const user = await prisma.user.findUnique({
      where: { phoneNumber: normalizedPhone },
      include: { roles: true, providerProfile: true },
    });

    if (!user) {
      throw AppError.notFound('User record not found');
    }

    // Update phone verification status
    const updatedUser = await prisma.user.update({
      where: { id: user.id },
      data: {
        isPhoneVerified: true,
        accountStatus: 'ACTIVE',
      },
      include: { roles: true, providerProfile: true },
    });

    const roles = updatedUser.roles.map((r) => r.role as UserRoleType);

    // Generate Tokens
    const accessToken = generateAccessToken(updatedUser.id, updatedUser.phoneNumber, roles);
    const refreshToken = generateRefreshToken(updatedUser.id);

    // Store Session
    const refreshTokenHash = hashToken(refreshToken);
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

    await prisma.authSession.create({
      data: {
        userId: updatedUser.id,
        tokenHash: refreshTokenHash,
        expiresAt,
      },
    });

    return {
      user: {
        id: updatedUser.id,
        fullName: updatedUser.fullName,
        phoneNumber: updatedUser.phoneNumber,
        email: updatedUser.email,
        accountStatus: updatedUser.accountStatus,
        isPhoneVerified: updatedUser.isPhoneVerified,
        roles,
        providerVerificationStatus: updatedUser.providerProfile?.verificationStatus || null,
      },
      tokens: {
        accessToken,
        refreshToken,
      },
    };
  }

  async login(phone: string, password: string): Promise<AuthResponseData> {
    const normalizedPhone = validateAndNormalizeIndianPhone(phone);

    const user = await prisma.user.findUnique({
      where: { phoneNumber: normalizedPhone },
      include: { roles: true, providerProfile: true },
    });

    if (!user) {
      throw AppError.unauthorized('Invalid phone number or password.');
    }

    if (user.accountStatus === 'SUSPENDED' || user.accountStatus === 'DISABLED') {
      throw AppError.forbidden(`Your account is ${user.accountStatus.toLowerCase()}. Please contact support.`);
    }

    const isPasswordValid = await verifyPassword(password, user.passwordHash);
    if (!isPasswordValid) {
      throw AppError.unauthorized('Invalid phone number or password.');
    }

    const roles = user.roles.map((r) => r.role as UserRoleType);

    // Update last login
    await prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });

    // Generate tokens
    const accessToken = generateAccessToken(user.id, user.phoneNumber, roles);
    const refreshToken = generateRefreshToken(user.id);

    // Store Session
    const refreshTokenHash = hashToken(refreshToken);
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

    await prisma.authSession.create({
      data: {
        userId: user.id,
        tokenHash: refreshTokenHash,
        expiresAt,
      },
    });

    return {
      user: {
        id: user.id,
        fullName: user.fullName,
        phoneNumber: user.phoneNumber,
        email: user.email,
        accountStatus: user.accountStatus,
        isPhoneVerified: user.isPhoneVerified,
        roles,
        providerVerificationStatus: user.providerProfile?.verificationStatus || null,
      },
      tokens: {
        accessToken,
        refreshToken,
      },
    };
  }

  async logout(userId: string, refreshToken?: string): Promise<void> {
    if (refreshToken) {
      const hashed = hashToken(refreshToken);
      await prisma.authSession.updateMany({
        where: { userId, tokenHash: hashed },
        data: { isRevoked: true },
      });
    } else {
      await prisma.authSession.updateMany({
        where: { userId, isRevoked: false },
        data: { isRevoked: true },
      });
    }
  }

  async forgotPassword(phone: string): Promise<{ message: string }> {
    const normalizedPhone = validateAndNormalizeIndianPhone(phone);

    const user = await prisma.user.findUnique({
      where: { phoneNumber: normalizedPhone },
    });

    if (!user) {
      return { message: 'If an account exists with this phone number, an OTP has been sent.' };
    }

    await otpService.generateAndSendOtp(normalizedPhone, 'PASSWORD_RESET', user.id, {
      skipCooldown: env.APP_ENV === 'test',
    });

    return { message: 'If an account exists with this phone number, an OTP has been sent.' };
  }

  async resetPassword(phone: string, otp: string, newPassword: string): Promise<{ message: string }> {
    const normalizedPhone = validateAndNormalizeIndianPhone(phone);
    validatePasswordRequirements(newPassword);

    await otpService.verifyOtp(normalizedPhone, 'PASSWORD_RESET', otp);

    const user = await prisma.user.findUnique({
      where: { phoneNumber: normalizedPhone },
    });

    if (!user) {
      throw AppError.notFound('User account not found');
    }

    const newHash = await hashPassword(newPassword);

    await prisma.user.update({
      where: { id: user.id },
      data: { passwordHash: newHash },
    });

    await prisma.authSession.updateMany({
      where: { userId: user.id, isRevoked: false },
      data: { isRevoked: true },
    });

    return { message: 'Password reset successful. Please log in with your new password.' };
  }

  async changePassword(userId: string, currentPassword: string, newPassword: string): Promise<{ message: string }> {
    validatePasswordRequirements(newPassword);

    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw AppError.notFound('User not found');
    }

    const isCurrentValid = await verifyPassword(currentPassword, user.passwordHash);
    if (!isCurrentValid) {
      throw AppError.badRequest('Current password is incorrect');
    }

    const newHash = await hashPassword(newPassword);

    await prisma.user.update({
      where: { id: userId },
      data: { passwordHash: newHash },
    });

    await prisma.authSession.updateMany({
      where: { userId: user.id, isRevoked: false },
      data: { isRevoked: true },
    });

    return { message: 'Password changed successfully.' };
  }

  async getCurrentUser(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { roles: true, providerProfile: true },
    });

    if (!user) {
      throw AppError.notFound('User not found');
    }

    const roles = user.roles.map((r) => r.role as UserRoleType);

    return {
      id: user.id,
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      email: user.email,
      accountStatus: user.accountStatus,
      isPhoneVerified: user.isPhoneVerified,
      roles,
      providerVerificationStatus: user.providerProfile?.verificationStatus || null,
      createdAt: user.createdAt,
    };
  }
}

export const authService = new AuthService();
