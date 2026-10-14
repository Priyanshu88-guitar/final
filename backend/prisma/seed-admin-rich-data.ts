import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import dotenv from 'dotenv';

dotenv.config();

const prisma = new PrismaClient();

async function printCounts(label: string) {
  const users = await prisma.user.count();
  const roles = await prisma.userRole.count();
  const customerProfiles = await prisma.customerProfile.count();
  const providerProfiles = await prisma.providerProfile.count();
  const stations = await prisma.chargingStation.count();
  const chargers = await prisma.charger.count();
  const bookings = await prisma.booking.count();
  const sessions = await prisma.chargingSession.count();
  const payments = await prisma.payment.count();
  const transactions = await prisma.transaction.count();
  const bundles = await prisma.bundle.count();
  const bundlePurchases = await prisma.bundlePurchase.count();
  const notifications = await prisma.notification.count();
  const emergencyRequests = await prisma.emergencyRequest.count();
  const supportTickets = await prisma.supportTicket.count();
  const savedChargers = await prisma.savedCharger.count();

  console.log(`\n=================== [${label}] ===================`);
  console.log(`Users: ${users} | Roles: ${roles} | CustProfiles: ${customerProfiles} | ProvProfiles: ${providerProfiles}`);
  console.log(`Stations: ${stations} | Chargers: ${chargers} | Bookings: ${bookings} | Sessions: ${sessions}`);
  console.log(`Payments: ${payments} | Transactions: ${transactions} | Bundles: ${bundles} | Purchases: ${bundlePurchases}`);
  console.log(`Notifications: ${notifications} | Emergency: ${emergencyRequests} | Tickets: ${supportTickets} | Saved: ${savedChargers}`);
  console.log('======================================================\n');
}

async function main() {
  console.log('🌱 Starting Rich Admin Dataset Seeding (Idempotent & Varied Statuses)...');
  await printCounts('BEFORE ADMIN RICH SEEDING');

  const passwordHash = await bcrypt.hash('Password123', 10);
  const now = new Date();

  // 1. Seed Customer Users (30 Total with varied statuses)
  const customerNames = [
    'Aarav Sharma', 'Vivaan Verma', 'Aditya Singh', 'Vihaan Gupta', 'Arjun Kumar',
    'Sai Patel', 'Ayaan Mehta', 'Reyansh Shah', 'Krishna Joshi', 'Ishaan Malhotra',
    'Diya Reddy', 'Sanya Kapoor', 'Ananya Nair', 'Kavya Sen', 'Riya Banerjee',
    'Meera Das', 'Pooja Iyer', 'Neha Deshmukh', 'Tanvi Kulkarni', 'Priti Rao',
    'Siddharth Roy', 'Rohan Chawla', 'Kabir Saxena', 'Dhruv Menon', 'Varun Pillai',
    'Nisha Agarwal', 'Swati Bhat', 'Priyanka Nambiar', 'Deepika Shinde', 'Anjali Thakur'
  ];

  const custStatuses = ['ACTIVE', 'ACTIVE', 'ACTIVE', 'ACTIVE', 'PENDING_VERIFICATION', 'SUSPENDED'];

  for (let i = 0; i < customerNames.length; i++) {
    const phone = `+91987654${(1000 + i).toString()}`;
    const email = `customer.admin.${i + 1}@voltera.demo`;
    const status = custStatuses[i % custStatuses.length];

    const u = await prisma.user.upsert({
      where: { phoneNumber: phone },
      create: {
        fullName: customerNames[i],
        email,
        phoneNumber: phone,
        passwordHash,
        accountStatus: status,
        isPhoneVerified: status === 'ACTIVE',
        roles: { create: { role: 'CUSTOMER' } },
        customerProfile: {
          create: {
            fullName: customerNames[i],
            city: 'Jamnagar',
            state: 'Gujarat',
            pincode: '361008',
            address: `Block ${i + 1}, Jamnagar`,
          },
        },
      },
      update: { accountStatus: status },
    });

    await prisma.userRole.upsert({
      where: { userId_role: { userId: u.id, role: 'CUSTOMER' } },
      create: { userId: u.id, role: 'CUSTOMER' },
      update: {},
    });
  }

  // 2. Seed Provider Users (20 Total with VERIFIED, PENDING, REJECTED statuses)
  const providerNames = [
    'Jamnagar Power Grid', 'Saurashtra Charging Hub', 'Khodiyar Green Energy',
    'Bedi Port EV Infrastructure', 'Polytechnic Fast Charge', 'Saru Section Charging Co',
    'Rameshwar Volt Station', 'Park Colony Energy', 'PN Marg Electric Stations',
    'Aerodrome Road Charging', 'Ranjit Nagar EV', 'Digvijay Plot Power',
    'Indra Nagar Charging', 'Patel Colony Energy', 'Mandvi Tower Charging',
    'Lal Bungalow EV Station', 'Railway Road Charging', 'Tagle Bridge Volt Hub',
    'Vasant Vihar Green Energy', 'Reliancenagar Supercharge'
  ];

  const verificationStatuses = ['VERIFIED', 'VERIFIED', 'VERIFIED', 'PENDING', 'REJECTED'];

  for (let i = 0; i < providerNames.length; i++) {
    const phone = `+91987653${(1000 + i).toString()}`;
    const email = `provider.admin.${i + 1}@voltera.demo`;
    const vStatus = verificationStatuses[i % verificationStatuses.length];

    const pUser = await prisma.user.upsert({
      where: { phoneNumber: phone },
      create: {
        fullName: `Owner - ${providerNames[i]}`,
        email,
        phoneNumber: phone,
        passwordHash,
        accountStatus: 'ACTIVE',
        isPhoneVerified: true,
        roles: { create: { role: 'PROVIDER' } },
        providerProfile: {
          create: {
            businessName: providerNames[i],
            contactPhone: phone,
            contactEmail: email,
            address: `Station Location #${i + 1}, Jamnagar`,
            city: 'Jamnagar',
            state: 'Gujarat',
            pincode: '361008',
            verificationStatus: vStatus,
          },
        },
      },
      update: { accountStatus: 'ACTIVE' },
    });

    await prisma.userRole.upsert({
      where: { userId_role: { userId: pUser.id, role: 'PROVIDER' } },
      create: { userId: pUser.id, role: 'PROVIDER' },
      update: {},
    });

    await prisma.providerProfile.upsert({
      where: { userId: pUser.id },
      create: {
        userId: pUser.id,
        businessName: providerNames[i],
        address: `Station Location #${i + 1}, Jamnagar`,
        city: 'Jamnagar',
        state: 'Gujarat',
        pincode: '361008',
        verificationStatus: vStatus,
      },
      update: { verificationStatus: vStatus },
    });
  }

  // 3. Seed Charging Stations & Chargers (30 Stations, 35+ Chargers with ACTIVE, MAINTENANCE, INACTIVE)
  const providers = await prisma.user.findMany({
    where: { roles: { some: { role: 'PROVIDER' } } },
    include: { providerProfile: true },
  });

  const jamnagarLocations = [
    { name: 'VOLTERA Hub - Khodiyar Colony', address: 'Khodiyar Colony, Jamnagar', lat: 22.484432, lng: 70.063333 },
    { name: 'VOLTERA Station - Bedi Port Road', address: 'Bedi, Jamnagar', lat: 22.510000, lng: 70.060000 },
    { name: 'VOLTERA Station - Gov. Polytechnic', address: 'Government Polytechnic, Jamnagar', lat: 22.4791315, lng: 70.0347841 },
    { name: 'VOLTERA Station - Saru Section', address: 'Saru Section, Jamnagar', lat: 22.472000, lng: 70.055000 },
    { name: 'VOLTERA Station - Rameshwar', address: 'Rameshwar Area, Jamnagar', lat: 22.465000, lng: 70.075000 },
    { name: 'VOLTERA Station - Park Colony', address: 'Park Colony, Jamnagar', lat: 22.490000, lng: 70.050000 },
    { name: 'VOLTERA Station - PN Marg', address: 'PN Marg, Jamnagar', lat: 22.475000, lng: 70.065000 },
    { name: 'VOLTERA Station - Aerodrome Road', address: 'Aerodrome Road, Jamnagar', lat: 22.455000, lng: 70.085000 },
    { name: 'VOLTERA Station - Ranjit Nagar', address: 'Ranjit Nagar, Jamnagar', lat: 22.480000, lng: 70.070000 },
    { name: 'VOLTERA Station - Digvijay Plot', address: 'Digvijay Plot, Jamnagar', lat: 22.470000, lng: 70.050000 },
    { name: 'VOLTERA Station - Indra Nagar', address: 'Indra Nagar, Jamnagar', lat: 22.495000, lng: 70.040000 },
    { name: 'VOLTERA Station - Patel Colony', address: 'Patel Colony, Jamnagar', lat: 22.485000, lng: 70.055000 },
    { name: 'VOLTERA Station - Mandvi Tower', address: 'Mandvi Tower Area, Jamnagar', lat: 22.470000, lng: 70.070000 },
    { name: 'VOLTERA Station - Digvijaysinhji Rd', address: 'Digvijaysinhji Road, Jamnagar', lat: 22.473000, lng: 70.072000 },
    { name: 'VOLTERA Station - Samrat Cinema', address: 'Samrat Cinema Road, Jamnagar', lat: 22.468000, lng: 70.060000 },
    { name: 'VOLTERA Station - Lal Bungalow', address: 'Lal Bungalow, Jamnagar', lat: 22.476000, lng: 70.062000 },
    { name: 'VOLTERA Station - ST Bus Stand', address: 'ST Bus Stand, Jamnagar', lat: 22.478000, lng: 70.058000 },
    { name: 'VOLTERA Station - Railway Station', address: 'Railway Station Road, Jamnagar', lat: 22.482000, lng: 70.053000 },
    { name: 'VOLTERA Station - Tagle Bridge', address: 'Tagle Bridge Area, Jamnagar', lat: 22.462000, lng: 70.068000 },
    { name: 'VOLTERA Station - Vasant Vihar', address: 'Vasant Vihar, Jamnagar', lat: 22.492000, lng: 70.045000 },
    { name: 'VOLTERA Station - Shantilal Park', address: 'Shantilal Park, Jamnagar', lat: 22.488000, lng: 70.060000 },
    { name: 'VOLTERA Station - Reliancenagar', address: 'Reliancenagar, Jamnagar', lat: 22.502000, lng: 70.035000 },
    { name: 'VOLTERA Station - Digvijay Ext', address: 'Digvijay Plot Ext, Jamnagar', lat: 22.471000, lng: 70.048000 },
    { name: 'VOLTERA Station - Sikka Rd Junc', address: 'Sikka Road Junction, Jamnagar', lat: 22.450000, lng: 70.090000 },
    { name: 'VOLTERA Station - Airport Rd', address: 'Airport Road, Jamnagar', lat: 22.458000, lng: 70.015000 },
    { name: 'VOLTERA Station - Bedi Gate', address: 'Bedi Gate, Jamnagar', lat: 22.475000, lng: 70.078000 },
    { name: 'VOLTERA Station - Darargadh', address: 'Darargadh, Jamnagar', lat: 22.472000, lng: 70.079000 },
    { name: 'VOLTERA Station - Mehrab', address: 'Mehrab, Jamnagar', lat: 22.481000, lng: 70.066000 },
    { name: 'VOLTERA Station - Highway Bypass', address: 'Bypass Road, Jamnagar', lat: 22.440000, lng: 70.100000 },
    { name: 'VOLTERA Station - GIDC Phase 3', address: 'GIDC Phase 3, Jamnagar', lat: 22.430000, lng: 70.020000 },
  ];

  const stationStatuses = ['ACTIVE', 'ACTIVE', 'ACTIVE', 'ACTIVE', 'MAINTENANCE', 'INACTIVE'];
  const chargerStatuses = ['AVAILABLE', 'OCCUPIED', 'AVAILABLE', 'OFFLINE', 'MAINTENANCE'];

  for (let i = 0; i < jamnagarLocations.length; i++) {
    const loc = jamnagarLocations[i];
    const p = providers[i % providers.length];
    const sStatus = stationStatuses[i % stationStatuses.length];
    const cCode = `CHG-ADMIN-RICH-${(100 + i).toString()}`;
    const cStatus = chargerStatuses[i % chargerStatuses.length];

    const existingSt = await prisma.chargingStation.findFirst({
      where: { name: loc.name },
    });

    if (!existingSt) {
      await prisma.chargingStation.create({
        data: {
          providerId: p.id,
          name: loc.name,
          address: loc.address,
          city: 'Jamnagar',
          state: 'Gujarat',
          pincode: '361008',
          latitude: loc.lat,
          longitude: loc.lng,
          status: sStatus,
          chargers: {
            create: {
              chargerCode: cCode,
              name: `Fast Charger ${i + 1}`,
              chargerType: i % 2 === 0 ? 'DC_FAST' : 'AC_STANDARD',
              connectorType: i % 3 === 0 ? 'CCS2' : i % 3 === 1 ? 'TYPE_2' : 'CHAdeMO',
              powerKw: i % 2 === 0 ? 60.0 : 22.0,
              pricePerHour: 150.0,
              pricePerKwh: 16.5,
              status: cStatus,
            },
          },
        },
      });
    }
  }

  // 4. Seed Bookings, Charging Sessions, Payments & Transactions (COMPLETED, PENDING, FAILED, CANCELLED)
  const customers = await prisma.user.findMany({ where: { roles: { some: { role: 'CUSTOMER' } } } });
  const chargers = await prisma.charger.findMany({ include: { station: true } });

  const bookingStatuses = [
    'COMPLETED', 'COMPLETED', 'COMPLETED', 'COMPLETED',
    'PENDING', 'CONFIRMED', 'CANCELLED', 'EXPIRED'
  ];

  const paymentStatuses = ['SUCCESS', 'SUCCESS', 'SUCCESS', 'CREATED', 'FAILED', 'REFUNDED'];

  for (let i = 0; i < 40; i++) {
    const cust = customers[i % customers.length];
    const chg = chargers[i % chargers.length];
    const bStatus = bookingStatuses[i % bookingStatuses.length];
    const pStatus = paymentStatuses[i % paymentStatuses.length];

    const daysAgo = (i % 20) + 1;
    const startTime = new Date(now.getTime() - daysAgo * 24 * 60 * 60 * 1000);
    const durationMins = 30 + (i % 4) * 15;
    const endTime = new Date(startTime.getTime() + durationMins * 60 * 1000);
    const cost = Math.round((chg.pricePerKwh || 15) * (durationMins / 60) * chg.powerKw);

    await prisma.$transaction(async (tx) => {
      const b = await tx.booking.create({
        data: {
          customerId: cust.id,
          chargerId: chg.id,
          startTime,
          endTime,
          status: bStatus,
        },
      });

      let sessionStatus = 'COMPLETED';
      if (bStatus === 'CANCELLED' || bStatus === 'EXPIRED') sessionStatus = 'CANCELLED';
      else if (bStatus === 'PENDING' || bStatus === 'CONFIRMED') sessionStatus = 'ACTIVE';

      const s = await tx.chargingSession.create({
        data: {
          bookingId: b.id,
          customerId: cust.id,
          chargerId: chg.id,
          startedAt: startTime,
          endedAt: sessionStatus === 'COMPLETED' ? endTime : null,
          status: sessionStatus,
        },
      });

      const payment = await tx.payment.create({
        data: {
          customerId: cust.id,
          bookingId: b.id,
          sessionId: s.id,
          amount: cost > 0 ? cost : 200,
          currency: 'INR',
          status: pStatus,
          gatewayProvider: 'mock',
          gatewayOrderId: `order_admin_rich_${i}_${Date.now()}`,
          paidAt: pStatus === 'SUCCESS' ? endTime : null,
        },
      });

      await tx.transaction.create({
        data: {
          paymentId: payment.id,
          customerId: cust.id,
          providerId: chg.station.providerId,
          type: 'CHARGING_PAYMENT',
          amount: cost > 0 ? cost : 200,
          currency: 'INR',
          status: pStatus === 'SUCCESS' ? 'COMPLETED' : 'FAILED',
        },
      });
    });
  }

  // 5. Seed Support Tickets & Emergency Requests with varied statuses
  const ticketCategories = ['BILLING', 'CHARGER_FAULT', 'BOOKING_CANCEL', 'APP_FEEDBACK'];
  const ticketStatuses = ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'];

  for (let i = 0; i < 25; i++) {
    const cust = customers[i % customers.length];
    const cat = ticketCategories[i % ticketCategories.length];
    const tStatus = ticketStatuses[i % ticketStatuses.length];

    const ticket = await prisma.supportTicket.create({
      data: {
        userId: cust.id,
        category: cat,
        subject: `Support Inquiry #${i + 101} regarding ${cat}`,
        status: tStatus,
      },
    });

    await prisma.supportMessage.create({
      data: {
        ticketId: ticket.id,
        senderUserId: cust.id,
        message: `Hello support team, I need assistance with my ${cat.toLowerCase()} issue on my charging session.`,
      },
    });
  }

  const emgStatuses = ['REQUESTED', 'DISPATCHED', 'RESOLVED', 'CANCELLED'];
  const emgService = await prisma.emergencyService.findFirst();

  if (emgService) {
    for (let i = 0; i < 20; i++) {
      const cust = customers[i % customers.length];
      const eStat = emgStatuses[i % emgStatuses.length];

      await prisma.emergencyRequest.create({
        data: {
          userId: cust.id,
          serviceId: emgService.id,
          status: eStat,
          description: `Emergency battery boost request near Jamnagar #${i + 1}`,
          latitude: 22.484432,
          longitude: 70.063333,
          address: 'Khodiyar Colony, Jamnagar',
        },
      });
    }
  }

  await printCounts('AFTER ADMIN RICH SEEDING');
  console.log('✅ Admin rich dataset seeding completed successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
