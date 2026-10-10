import { prisma } from '../database/prisma.js';
import { CreateEmergencyRequestInput } from '../models/emergency.model.js';
import { AppError } from '../utils/app-error.js';

export class EmergencyRepository {
  async getActiveServices() {
    return prisma.emergencyService.findMany({
      where: { active: true },
      orderBy: { name: 'asc' },
    });
  }

  async createRequest(userId: string, input: CreateEmergencyRequestInput) {
    const service = await prisma.emergencyService.findFirst({
      where: { id: input.serviceId, active: true },
    });
    if (!service) throw AppError.notFound('Emergency service not found or inactive');

    // Basic idempotency check (prevent duplicate rapid requests for the same service within last 5 minutes)
    const fiveMinsAgo = new Date(Date.now() - 5 * 60 * 1000);
    const existing = await prisma.emergencyRequest.findFirst({
      where: {
        userId,
        serviceId: input.serviceId,
        status: 'REQUESTED',
        createdAt: { gte: fiveMinsAgo }
      }
    });

    if (existing) {
       return existing; // Idempotently return the existing pending request
    }

    return prisma.emergencyRequest.create({
      data: {
        userId,
        serviceId: input.serviceId,
        description: input.description,
        latitude: input.latitude,
        longitude: input.longitude,
        address: input.address,
        status: 'REQUESTED',
      },
      include: {
        service: true
      }
    });
  }

  async getUserRequests(userId: string) {
    return prisma.emergencyRequest.findMany({
      where: { userId },
      include: { service: true },
      orderBy: { createdAt: 'desc' },
    });
  }
}

export const emergencyRepository = new EmergencyRepository();
