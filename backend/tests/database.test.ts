import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { prisma } from '../src/database/prisma.js';
import { userRepository } from '../src/repositories/user.repository.js';
import { checkDatabaseHealth } from '../src/config/database.js';

describe('Database Foundation & Multi-Role Architecture', () => {
  beforeAll(async () => {
    await prisma.$connect();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('should verify database connectivity', async () => {
    const health = await checkDatabaseHealth();
    expect(health.connected).toBe(true);
    expect(health.latencyMs).toBeGreaterThanOrEqual(0);
  });

  it('should support creating a user with multiple roles (CUSTOMER + PROVIDER)', async () => {
    const testEmail = `test.user.${Date.now()}@voltera.app`;

    const user = await userRepository.createUser({
      fullName: 'Test Multi Role',
      email: testEmail,
      phoneNumber: `98${Math.floor(10000000 + Math.random() * 90000000)}`,
      passwordHash: 'hashed_password_string',
      accountStatus: 'ACTIVE',
      roles: ['CUSTOMER', 'PROVIDER'],
    });

    expect(user).toBeDefined();
    expect(user.id).toBeDefined();
    expect(user.email).toBe(testEmail);
    expect(user.roles).toHaveLength(2);

    const roleNames = user.roles?.map((r) => r.role);
    expect(roleNames).toContain('CUSTOMER');
    expect(roleNames).toContain('PROVIDER');

    // Cleanup test user
    await prisma.user.delete({ where: { id: user.id } });
  });
});
