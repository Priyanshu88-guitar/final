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
  const notifications = await prisma.notification.count();
  const emergencyRequests = await prisma.emergencyRequest.count();
  const supportTickets = await prisma.supportTicket.count();
  const savedChargers = await prisma.savedCharger.count();

  console.log(`\n--- [${label}] ---`);
  console.log(`Users: ${users} | Roles: ${roles} | CustProfiles: ${customerProfiles} | ProvProfiles: ${providerProfiles}`);
  console.log(`Stations: ${stations} | Chargers: ${chargers} | Bookings: ${bookings} | Sessions: ${sessions}`);
  console.log(`Payments: ${payments} | Transactions: ${transactions} | Bundles: ${bundles}`);
  console.log(`Notifications: ${notifications} | Emergency: ${emergencyRequests} | Tickets: ${supportTickets} | Saved: ${savedChargers}`);
  console.log('--------------------------------------------------\n');
}

async function main() {
  console.log('🌱 Starting Master Seeding & Repair Script (Phase 2, Idempotent)...');
  await printCounts('BEFORE MASTER SEEDING');

  const passwordHash = await bcrypt.hash('Password123', 10);

  // 1. Ensure Admin User exists
  const adminPhone = '+919999999990';
  await prisma.user.upsert({
    where: { phoneNumber: adminPhone },
    create: {
      fullName: 'System Administrator',
      email: 'admin.voltera@example.com',
      phoneNumber: adminPhone,
      passwordHash,
      accountStatus: 'ACTIVE',
      isPhoneVerified: true,
      roles: { create: { role: 'ADMIN' } },
    },
    update: { accountStatus: 'ACTIVE' },
  });

  // 2. Ensure at least 25 Customer accounts & profiles
  const customerTarget = 25;
  const existingCustomers = await prisma.user.findMany({
    where: { roles: { some: { role: 'CUSTOMER' } } },
    include: { customerProfile: true },
  });

  const firstNames = ['Aarav', 'Vivaan', 'Aditya', 'Vihaan', 'Arjun', 'Sai', 'Ayaan', 'Reyansh', 'Krishna', 'Ishaan', 'Diya', 'Sanya', 'Ananya', 'Kavya', 'Riya', 'Meera', 'Pooja', 'Neha', 'Tanvi', 'Priti', 'Siddharth', 'Rohan', 'Kabir', 'Dhruv', 'Varun'];
  const lastNames = ['Sharma', 'Verma', 'Singh', 'Gupta', 'Kumar', 'Patel', 'Mehta', 'Shah', 'Joshi', 'Malhotra', 'Reddy', 'Kapoor', 'Nair', 'Sen', 'Banerjee', 'Das', 'Iyer', 'Deshmukh', 'Kulkarni', 'Rao', 'Roy', 'Chawla', 'Saxena', 'Menon', 'Pillai'];
  const cities = ['Jamnagar', 'Ahmedabad', 'Gandhinagar', 'Surat', 'Vadodara', 'Rajkot', 'Mumbai', 'Pune', 'Bengaluru', 'Delhi'];

  let custAdded = 0;
  for (let i = existingCustomers.length; custAdded < (customerTarget - existingCustomers.length) && i < firstNames.length + 10; i++) {
    const phone = `+91987654${(5000 + i).toString()}`;
    const email = `customer.${i + 1}@voltera.demo`;
    const fullName = `${firstNames[i % firstNames.length]} ${lastNames[i % lastNames.length]}`;
    const city = cities[i % cities.length];

    await prisma.$transaction(async (tx) => {
      await tx.user.create({
        data: {
          fullName,
          email,
          phoneNumber: phone,
          passwordHash,
          accountStatus: 'ACTIVE',
          isPhoneVerified: true,
          roles: { create: { role: 'CUSTOMER' } },
          customerProfile: {
            create: {
              fullName,
              city,
              state: 'Gujarat',
              pincode: '361008',
              address: `Plot ${i + 1}, Main Road, ${city}`,
            },
          },
        },
      });
    });
    custAdded++;
  }

  // Ensure all customers have profiles
  const allCustomers = await prisma.user.findMany({
    where: { roles: { some: { role: 'CUSTOMER' } } },
    include: { customerProfile: true },
  });
  for (const c of allCustomers) {
    if (!c.customerProfile) {
      await prisma.customerProfile.create({
        data: {
          userId: c.id,
          fullName: c.fullName || 'Customer',
          city: 'Jamnagar',
          state: 'Gujarat',
          pincode: '361008',
          address: 'Jamnagar City Center',
        },
      });
    }
  }

  // 3. Ensure at least 20 Provider accounts & profiles
  const providerTarget = 20;
  const existingProviders = await prisma.user.findMany({
    where: { roles: { some: { role: 'PROVIDER' } } },
    include: { providerProfile: true },
  });

  let provAdded = 0;
  for (let i = existingProviders.length; provAdded < (providerTarget - existingProviders.length) && i < 25; i++) {
    const phone = `+91987653${(5000 + i).toString()}`;
    const email = `provider.${i + 1}@voltera.demo`;
    const busName = `Jamnagar EV Solutions #${i + 1}`;
    const city = cities[i % cities.length];

    await prisma.$transaction(async (tx) => {
      await tx.user.create({
        data: {
          fullName: `Provider Owner ${i + 1}`,
          email,
          phoneNumber: phone,
          passwordHash,
          accountStatus: 'ACTIVE',
          isPhoneVerified: true,
          roles: { create: { role: 'PROVIDER' } },
          providerProfile: {
            create: {
              businessName: busName,
              contactPhone: phone,
              contactEmail: email,
              address: `Station Hub ${i + 1}, ${city}`,
              city,
              state: 'Gujarat',
              pincode: '361008',
              verificationStatus: 'VERIFIED',
            },
          },
        },
      });
    });
    provAdded++;
  }

  const allProviders = await prisma.user.findMany({
    where: { roles: { some: { role: 'PROVIDER' } } },
    include: { providerProfile: true },
  });
  for (const p of allProviders) {
    if (!p.providerProfile) {
      await prisma.providerProfile.create({
        data: {
          userId: p.id,
          businessName: p.fullName ? `${p.fullName} EV Hub` : 'Jamnagar EV Hub',
          address: 'Jamnagar Highway',
          city: 'Jamnagar',
          state: 'Gujarat',
          pincode: '361008',
          verificationStatus: 'VERIFIED',
        },
      });
    } else if (p.providerProfile.verificationStatus !== 'VERIFIED') {
      await prisma.providerProfile.update({
        where: { userId: p.id },
        data: { verificationStatus: 'VERIFIED' },
      });
    }
  }

  // 4. Ensure 28+ Stations and Chargers (Jamnagar-first, positive prices > 0)
  const targetStations = 28;
  const existingStations = await prisma.chargingStation.findMany({ include: { chargers: true } });
  const stationsNeeded = Math.max(0, targetStations - existingStations.length);

  const jamnagarStations = [
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
  ];

  const provs = await prisma.user.findMany({ where: { roles: { some: { role: 'PROVIDER' } } } });

  let stAdded = 0;
  for (let i = existingStations.length; stAdded < stationsNeeded && i < jamnagarStations.length; i++) {
    const loc = jamnagarStations[i];
    const provider = provs[i % provs.length];
    const code = `CHG-JAM-MASTER-${(100 + i).toString()}`;

    await prisma.chargingStation.create({
      data: {
        providerId: provider.id,
        name: loc.name,
        address: loc.address,
        city: 'Jamnagar',
        state: 'Gujarat',
        pincode: '361008',
        latitude: loc.lat,
        longitude: loc.lng,
        status: 'ACTIVE',
        chargers: {
          create: {
            chargerCode: code,
            name: 'Fast DC CCS2 (60kW)',
            chargerType: 'DC_FAST',
            connectorType: 'CCS2',
            powerKw: 60.0,
            pricePerHour: 150.0,
            pricePerKwh: 15.0,
            status: 'AVAILABLE',
          },
        },
      },
    });
    stAdded++;
  }

  await prisma.chargingStation.updateMany({ data: { status: 'ACTIVE' } });
  await prisma.charger.updateMany({
    where: { pricePerKwh: { lte: 0 } },
    data: { pricePerKwh: 15.0, pricePerHour: 150.0 },
  });

  // 5. Ensure 28+ Bookings, Sessions, Payments, Transactions
  const targetBookings = 28;
  const existingBookings = await prisma.booking.count();
  const bookingsNeeded = Math.max(0, targetBookings - existingBookings);

  const custs = await prisma.user.findMany({ where: { roles: { some: { role: 'CUSTOMER' } } } });
  const chgs = await prisma.charger.findMany({ include: { station: true } });
  const now = new Date();

  for (let i = 0; i < bookingsNeeded; i++) {
    const cust = custs[i % custs.length];
    const chg = chgs[i % chgs.length];
    const startTime = new Date(now.getTime() - ((i % 10) + 1) * 24 * 60 * 60 * 1000);
    const endTime = new Date(startTime.getTime() + 45 * 60 * 1000);
    const cost = Math.round(chg.pricePerKwh * 15);

    await prisma.$transaction(async (tx) => {
      const b = await tx.booking.create({
        data: {
          customerId: cust.id,
          chargerId: chg.id,
          startTime,
          endTime,
          status: 'COMPLETED',
        },
      });

      const s = await tx.chargingSession.create({
        data: {
          bookingId: b.id,
          customerId: cust.id,
          chargerId: chg.id,
          startedAt: startTime,
          endedAt: endTime,
          status: 'COMPLETED',
        },
      });

      const p = await tx.payment.create({
        data: {
          customerId: cust.id,
          bookingId: b.id,
          sessionId: s.id,
          amount: cost,
          currency: 'INR',
          status: 'SUCCESS',
          gatewayProvider: 'mock',
          paidAt: endTime,
        },
      });

      await tx.transaction.create({
        data: {
          paymentId: p.id,
          customerId: cust.id,
          providerId: chg.station.providerId,
          type: 'CHARGING_PAYMENT',
          amount: cost,
          currency: 'INR',
          status: 'COMPLETED',
        },
      });
    });
  }

  // 6. Ensure Bundles (15)
  const bundleItems = [
    { name: 'Jamnagar Commuter Pass (50 kWh)', price: 499, validityDays: 30 },
    { name: 'Gujarat Highway Express Pass (120 kWh)', price: 999, validityDays: 60 },
    { name: 'Monthly Unlimited Off-Peak Pass', price: 1499, validityDays: 30 },
    { name: 'Weekend Traveler Pack (80 kWh)', price: 699, validityDays: 14 },
    { name: 'Commercial Fleet Ultra Saver (500 kWh)', price: 3999, validityDays: 90 },
    { name: 'Fast DC Super Pass (200 kWh)', price: 1899, validityDays: 45 },
    { name: 'Student EV Pass (30 kWh)', price: 299, validityDays: 30 },
    { name: 'Standard AC Monthly Pass (100 kWh)', price: 599, validityDays: 30 },
    { name: 'VIP Priority Pass (150 kWh)', price: 1299, validityDays: 45 },
    { name: 'Yearly Super Saver Pass (1000 kWh)', price: 7999, validityDays: 365 },
    { name: 'Eco City Rider Pass (40 kWh)', price: 399, validityDays: 30 },
    { name: 'Rapid Highway Pass (150 kWh)', price: 1199, validityDays: 30 },
    { name: 'Night Owl Unlimited Pass', price: 899, validityDays: 30 },
    { name: 'Saurashtra Regional Pass (250 kWh)', price: 1999, validityDays: 60 },
    { name: 'Voltera Elite Pass (Unlimited)', price: 4999, validityDays: 30 },
  ];

  for (const b of bundleItems) {
    await prisma.bundle.upsert({
      where: { id: `bundle-master-${b.name.replaceAll(' ', '-').toLowerCase().substring(0, 20)}` },
      create: {
        id: `bundle-master-${b.name.replaceAll(' ', '-').toLowerCase().substring(0, 20)}`,
        name: b.name,
        description: `Premium EV charging bundle in Jamnagar & Gujarat with ₹${b.price} value.`,
        price: b.price,
        currency: 'INR',
        validityDays: b.validityDays,
        status: 'ACTIVE',
      },
      update: { price: b.price },
    });
  }

  // 7. Ensure Notifications, Saved Chargers, Support Tickets, Emergency Requests
  for (let i = 0; i < 20; i++) {
    const cust = custs[i % custs.length];
    const chg = chgs[i % chgs.length];

    await prisma.savedCharger.upsert({
      where: { customerId_chargerId: { customerId: cust.id, chargerId: chg.id } },
      create: { customerId: cust.id, chargerId: chg.id },
      update: {},
    });

    await prisma.notification.create({
      data: {
        recipientUserId: cust.id,
        type: i % 2 === 0 ? 'SESSION' : 'BOOKING',
        title: i % 2 === 0 ? 'Charging Session Completed' : 'Booking Confirmed',
        body: 'Your Voltera EV charging session in Jamnagar was completed successfully.',
        isRead: i % 3 === 0,
      },
    });

    await prisma.supportTicket.create({
      data: {
        userId: cust.id,
        category: 'BILLING',
        subject: 'Inquiry regarding charging bundle pricing',
        status: i % 2 === 0 ? 'CLOSED' : 'OPEN',
      },
    });
  }

  const emgService = await prisma.emergencyService.upsert({
    where: { id: 'emg-roadside-towing' },
    create: {
      id: 'emg-roadside-towing',
      name: '24/7 Voltera EV Roadside Towing & Mobile Battery Support',
      serviceType: 'TOWING',
      phoneNumber: '+9118001239999',
      description: 'Emergency EV battery boost and roadside assistance across Jamnagar.',
      active: true,
    },
    update: {},
  });

  for (let i = 0; i < 15; i++) {
    const cust = custs[i % custs.length];
    await prisma.emergencyRequest.create({
      data: {
        userId: cust.id,
        serviceId: emgService.id,
        status: i % 2 === 0 ? 'RESOLVED' : 'REQUESTED',
        description: 'Roadside assistance requested near Khodiyar Colony, Jamnagar.',
        latitude: 22.484432,
        longitude: 70.063333,
        address: 'Khodiyar Colony, Jamnagar',
      },
    });
  }

  await printCounts('AFTER MASTER SEEDING');
  console.log('✅ Master seeding & repair completed successfully and idempotently.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
