import { supportRepository } from '../repositories/support.repository.js';
import { CreateSupportTicketInput, AddSupportMessageInput } from '../models/support.model.js';
import { notificationService } from './notification/notification.service.js';

export class SupportService {
  async createTicket(userId: string, input: CreateSupportTicketInput) {
    const ticket = await supportRepository.createTicket(userId, input);

    await notificationService.sendNotification({
      recipientUserId: userId,
      type: 'SUPPORT_TICKET_CREATED' as any,
      title: 'Support Ticket Created',
      body: `Your ticket regarding "${ticket.subject}" has been opened.`,
      relatedEntityId: ticket.id,
      relatedEntityType: 'SUPPORT_TICKET'
    });

    return ticket;
  }

  async getUserTickets(userId: string) {
    return supportRepository.getUserTickets(userId);
  }

  async getTicketById(userId: string, ticketId: string) {
    return supportRepository.getTicketById(userId, ticketId);
  }

  async addMessage(userId: string, ticketId: string, input: AddSupportMessageInput) {
    return supportRepository.addMessage(userId, ticketId, input);
  }
}

export const supportService = new SupportService();
