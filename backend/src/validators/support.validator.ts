import { z } from 'zod';

export const createSupportTicketSchema = z.object({
  category: z.string().min(2, 'Category is required'),
  subject: z.string().min(5, 'Subject must be at least 5 characters long'),
});

export const addSupportMessageSchema = z.object({
  message: z.string().min(1, 'Message cannot be empty'),
});
