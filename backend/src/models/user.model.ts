export type UserRoleType = 'CUSTOMER' | 'PROVIDER' | 'ADMIN';

export type AccountStatusType = 'ACTIVE' | 'INACTIVE' | 'SUSPENDED' | 'PENDING_VERIFICATION' | 'DISABLED';

export interface UserRoleModel {
  id: string;
  userId: string;
  role: UserRoleType;
  assignedAt: Date;
}

export interface UserModel {
  id: string;
  fullName: string | null;
  phoneNumber: string;
  email: string | null;
  accountStatus: AccountStatusType;
  isPhoneVerified: boolean;
  lastLoginAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
  roles?: UserRoleModel[];
}

export interface CreateUserInput {
  fullName?: string;
  phoneNumber: string;
  passwordHash: string;
  email?: string;
  accountStatus?: AccountStatusType;
  roles?: UserRoleType[];
}
