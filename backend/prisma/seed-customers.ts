import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function printCounts(label: string) {
  const users = await prisma.user.count();
  const roles = await prisma.userRole.count();
  const customerProfiles = await prisma.customerProfile.count();
  const stations = await prisma.chargingStation.count();
  const chargers = await prisma.charger.count();
  const bookings = await prisma.booking.count();
  const sessions = await prisma.chargingSession.count();
  const payments = await prisma.payment.count();
  const transactions = await prisma.transaction.count();

  console.log(`\n--- [${label}] ---`);
  console.log(`Users: ${users} | Roles: ${roles} | CustomerProfiles: ${customerProfiles}`);
  console.log(`Stations: ${stations} | Chargers: ${chargers} | Bookings: ${bookings}`);
  console.log(`Sessions: ${sessions} | Payments: ${payments} | Transactions: ${transactions}`);
  console.log('--------------------\n');
  return { users, roles, customerProfiles, stations, chargers, bookings, sessions, payments, transactions };
}

async function main() {
  console.log('🌱 Starting Step 1: Customer Accounts & Profiles Seeding (Robust, Atomic & Idempotent)...');

  const beforeCounts = await printCounts('BEFORE SEEDING');

  const passwordHash = await bcrypt.hash('Password123', 10);
  const targetTotalCustomers = 28;

  // 1. Audit all existing users globally (prevent collisions with providers/admins)
  const allUsers = await prisma.user.findMany({
    include: { roles: true, customerProfile: true },
  });

  const globalPhones = new Set(allUsers.map(u => u.phoneNumber));
  const globalEmails = new Set(allUsers.map(u => u.email).filter(Boolean));

  const existingCustomers = allUsers.filter(u => u.roles.some(r => r.role === 'CUSTOMER'));
  console.log(`📊 Existing customer accounts found: ${existingCustomers.length}`);

  // 2. Audit existing customers missing CustomerProfile and create them non-destructively
  for (const customer of existingCustomers) {
    if (!customer.customerProfile) {
      console.log(`⚠️ Customer ID ${customer.id} lacks a profile. Creating default profile safely...`);
      await prisma.customerProfile.create({
        data: {
          userId: customer.id,
          fullName: customer.fullName || 'Valued Customer',
          city: 'Ahmedabad',
          state: 'Gujarat',
          pincode: '380001',
          address: 'Demo Address',
        },
      });
    }
  }

  const additionalNeeded = Math.max(0, targetTotalCustomers - existingCustomers.length);
  console.log(`➕ Additional customer accounts needed to reach target of ${targetTotalCustomers}: ${additionalNeeded}`);

  const sampleCities = ['Ahmedabad', 'Gandhinagar', 'Surat', 'Vadodara', 'Rajkot', 'Mumbai', 'Pune', 'Bengaluru', 'Delhi', 'Jaipur'];
  const sampleNames = [
    'Aarav Sharma', 'Vivaan Verma', 'Aditya Singh', 'Vihaan Gupta', 'Arjun Kumar',
    'Sai Patel', 'Ayaan Mehta', 'Reyansh Shah', 'Krishna Joshi', 'Ishaan Malhotra',
    'Diya Reddy', 'Sanya Kapoor', 'Ananya Nair', 'Kavya Sen', 'Riya Banerjee',
    'Meera Das', 'Pooja Iyer', 'Neha Deshmukh', 'Tanvi Kulkarni', 'Priti Rao',
    'Siddharth Roy', 'Rohan Chawla', 'Kabir Saxena', 'Dhruv Menon', 'Varun Pillai',
    'Nisha Agarwal', 'Swati Bhat', 'Priyanka Nambiar', 'Deepika Shinde', 'Anjali Thakur'
  ];

  let addedCount = 0;
  for (let i = 0; addedCount < additionalNeeded && i < sampleNames.length; i++) {
    const phoneNum = `+91987654${(3400 + allUsers.length + addedCount).toString()}`;
    const emailStr = `demo.customer.${i + 1 + allUsers.length}@voltera.demo`;
    const nameStr = sampleNames[i % sampleNames.length];
    const cityStr = sampleCities[i % sampleCities.length];

    if (globalPhones.has(phoneNum) || globalEmails.has(emailStr)) {
      continue;
    }

    // Atomic transaction for creating User + UserRole + CustomerProfile
    await prisma.$transaction(async (tx) => {
      await tx.user.create({
        data: {
          fullName: nameStr,
          email: emailStr,
          phoneNumber: phoneNum,
          passwordHash,
          accountStatus: 'ACTIVE',
          isPhoneVerified: true,
          roles: {
            create: { role: 'CUSTOMER' },
          },
          customerProfile: {
            create: {
              fullName: nameStr,
              city: cityStr,
              state: cityStr === 'Mumbai' || cityStr === 'Pune' ? 'Maharashtra' : cityStr === 'Delhi' ? 'Delhi' : cityStr === 'Bengaluru' ? 'Karnataka' : 'Gujarat',
              pincode: '380001',
              address: `Block ${i + 1}, City Center`,
            },
          },
        },
      });

      globalPhones.add(phoneNum);
      globalEmails.add(emailStr);
    });

    addedCount++;
  }

  const afterCounts = await printCounts('AFTER SEEDING');

  // Verify record counts integrity (non-customer records must not decrease)
  if (afterCounts.stations < beforeCounts.stations || afterCounts.chargers < beforeCounts.chargers) {
    throw new Error('Integrity violation: Charging stations or chargers count decreased!');
  }

  console.log(`✅ Customer step 1 seeding verified successfully and idempotently.`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
