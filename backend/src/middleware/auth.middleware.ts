import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken, AuthTokenPayload } from '../utils/token.js';
import { AppError } from '../utils/app-error.js';
import { prisma } from '../database/prisma.js';
import { UserRoleType } from '../models/user.model.js';

// Extend Express Request type
declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        phoneNumber: string;
        roles: UserRoleType[];
        activeRole: UserRoleType;
      };
    }
  }
}

export async function requireAuth(req: Request, _res: Response, next: NextFunction): Promise<void> {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw AppError.unauthorized('Authentication token is required');
    }

    const token = authHeader.split(' ')[1];
    if (!token) {
      throw AppError.unauthorized('Authentication token is missing');
    }

    const payload: AuthTokenPayload = verifyAccessToken(token);

    // Verify user exists and account status in database
    const user = await prisma.user.findUnique({
      where: { id: payload.sub },
      include: { roles: true },
    });

    if (!user) {
      throw AppError.unauthorized('User account no longer exists');
    }

    if (user.accountStatus === 'SUSPENDED' || user.accountStatus === 'DISABLED') {
      throw AppError.forbidden(`Your account has been ${user.accountStatus.toLowerCase()}. Please contact support.`);
    }

    const dbRoles = user.roles.map((r) => r.role as UserRoleType);

    // Support client requested active role context (e.g. X-Active-Role) safely
    let activeRole = payload.activeRole || dbRoles[0] || 'CUSTOMER';
    const clientRequestedRole = req.headers['x-active-role'] as string | undefined;

    if (clientRequestedRole) {
      const upperRole = clientRequestedRole.toUpperCase() as UserRoleType;
      if (!dbRoles.includes(upperRole)) {
        throw AppError.forbidden(`Your account does not possess the requested role '${clientRequestedRole}'`);
      }
      activeRole = upperRole;
    }

    req.user = {
      id: user.id,
      phoneNumber: user.phoneNumber,
      roles: dbRoles,
      activeRole,
    };

    next();
  } catch (error) {
    next(error);
  }
}

export function requireRole(...allowedRoles: UserRoleType[]) {
  return (req: Request, _res: Response, next: NextFunction): void => {
    if (!req.user) {
      return next(AppError.unauthorized('Authentication required'));
    }

    const userRoles = req.user.roles;
    const hasRole = allowedRoles.some((role) => userRoles.includes(role));

    if (!hasRole) {
      return next(
        AppError.forbidden(
          `Access denied. Required role(s): ${allowedRoles.join(', ')}. Your roles: ${userRoles.join(', ')}`
        )
      );
    }

    next();
  };
}
