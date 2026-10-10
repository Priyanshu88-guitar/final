import { emergencyRepository } from '../repositories/emergency.repository.js';
import { CreateEmergencyRequestInput } from '../models/emergency.model.js';
import { notificationService } from './notification/notification.service.js';

export class EmergencyService {
  async getActiveServices() {
    return emergencyRepository.getActiveServices();
  }

  async createRequest(userId: string, input: CreateEmergencyRequestInput) {
    const request = await emergencyRepository.createRequest(userId, input);

    // If it's a new request, trigger notification
    if (request.createdAt.getTime() > Date.now() - 5000) {
       // request type inference here from Prisma includes service relationship safely
       const serviceName = (request as any).service?.name || 'Emergency Service';
       await notificationService.sendNotification({
          recipientUserId: userId,
          type: 'EMERGENCY_REQUESTED' as any,
          title: 'Emergency Request Received',
          body: `Your request for ${serviceName} has been received.`,
          relatedEntityId: request.id,
          relatedEntityType: 'EMERGENCY_REQUEST'
       });
    }

    return request;
  }

  async getUserRequests(userId: string) {
    return emergencyRepository.getUserRequests(userId);
  }
}

export const emergencyService = new EmergencyService();
