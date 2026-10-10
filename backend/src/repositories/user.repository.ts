import { prisma } from '../database/prisma.js';
import { CreateUserInput, UserModel, UserRoleType } from '../models/user.model.js';

export class UserRepository {
  async findById(id: string): Promise<UserModel | null> {
    const user = await prisma.user.findUnique({
      where: { id },
      include: { roles: true },
    });
    return user as UserModel | null;
  }

  async findByEmail(email: string): Promise<UserModel | null> {
    const user = await prisma.user.findUnique({
      where: { email },
      include: { roles: true },
    });
    return user as UserModel | null;
  }

  async findByPhoneNumber(phoneNumber: string): Promise<UserModel | null> {
    const user = await prisma.user.findUnique({
      where: { phoneNumber },
      include: { roles: true },
    });
    return user as UserModel | null;
  }

  async createUser(input: CreateUserInput & { phoneNumber: string; passwordHash: string }): Promise<UserModel> {
    const { fullName, email, phoneNumber, passwordHash, accountStatus = 'ACTIVE', roles = ['CUSTOMER'] } = input;

    const user = await prisma.user.create({
      data: {
        fullName,
        email,
        phoneNumber,
        passwordHash,
        accountStatus,
        roles: {
          create: roles.map((role) => ({ role })),
        },
      },
      include: { roles: true },
    });

    return user as UserModel;
  }

  async addRoleToUser(userId: string, role: UserRoleType): Promise<void> {
    await prisma.userRole.upsert({
      where: {
        userId_role: { userId, role },
      },
      create: {
        userId,
        role,
      },
      update: {},
    });
  }

  async removeRoleFromUser(userId: string, role: UserRoleType): Promise<void> {
    await prisma.userRole.deleteMany({
      where: {
        userId,
        role,
      },
    });
  }
}

export const userRepository = new UserRepository();
