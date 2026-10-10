import { prisma } from '../database/prisma.js';
import { CreateSupportTicketInput, AddSupportMessageInput } from '../models/support.model.js';
import { AppError } from '../utils/app-error.js';

export class SupportRepository {
  async createTicket(userId: string, input: CreateSupportTicketInput) {
    return prisma.supportTicket.create({
      data: {
        userId,
        category: input.category,
        subject: input.subject,
        status: 'OPEN',
      },
    });
  }

  async getUserTickets(userId: string) {
    return prisma.supportTicket.findMany({
      where: { userId },
      orderBy: { updatedAt: 'desc' },
    });
  }

  async getTicketById(userId: string, ticketId: string) {
    const ticket = await prisma.supportTicket.findFirst({
      where: { id: ticketId, userId },
      include: {
        messages: {
          orderBy: { createdAt: 'asc' },
          include: {
            sender: { select: { fullName: true, roles: true } }
          }
        }
      }
    });

    if (!ticket) throw AppError.notFound('Support ticket not found');
    return ticket;
  }

  async addMessage(userId: string, ticketId: string, input: AddSupportMessageInput) {
    // 1. Verify ownership (cannot add to another user's ticket unless admin, which is handled in Phase 9)
    const ticket = await prisma.supportTicket.findFirst({
      where: { id: ticketId, userId }
    });

    if (!ticket) throw AppError.notFound('Support ticket not found');

    if (ticket.status === 'CLOSED') {
       throw AppError.badRequest('Cannot add messages to a closed ticket');
    }

    // 2. Add message and update ticket timestamp
    return prisma.$transaction(async (tx) => {
       const message = await tx.supportMessage.create({
         data: {
           ticketId,
           senderUserId: userId,
           message: input.message,
         }
       });

       await tx.supportTicket.update({
         where: { id: ticketId },
         data: { updatedAt: new Date(), status: 'OPEN' } // Mark open if it was resolved but user replied
       });

       return message;
    });
  }
}

export const supportRepository = new SupportRepository();
