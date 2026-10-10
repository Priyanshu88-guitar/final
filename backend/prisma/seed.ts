import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting comprehensive database seeding...');

  // 1. Clear existing data in correct dependency order (children before parents)
  await prisma.$transaction([
    prisma.adminAuditLog.deleteMany(),
    prisma.supportMessage.deleteMany(),
    prisma.supportTicket.deleteMany(),
    prisma.emergencyRequest.deleteMany(),
    prisma.emergencyService.deleteMany(),
    prisma.bundlePurchase.deleteMany(),
    prisma.bundle.deleteMany(),
    prisma.notificationPreference.deleteMany(),
    prisma.deviceToken.deleteMany(),
    prisma.notification.deleteMany(),
    prisma.providerPayout.deleteMany(),
    prisma.providerBankAccount.deleteMany(),
    prisma.transaction.deleteMany(),
    prisma.payment.deleteMany(),
    prisma.chargingSession.deleteMany(),
    prisma.booking.deleteMany(),
    prisma.charger.deleteMany(),
    prisma.chargingStation.deleteMany(),
    prisma.providerProfile.deleteMany(),
    prisma.customerProfile.deleteMany(),
    prisma.authSession.deleteMany(),
    prisma.otpVerification.deleteMany(),
    prisma.userRole.deleteMany(),
    prisma.user.deleteMany(),
  ]);

  console.log('🧹 Cleaned existing database records.');

  const passwordHash = await bcrypt.hash('Demo@12345', 10);

  // 2. Create Admin User (1)
  const adminUser = await prisma.user.create({
    data: {
      fullName: 'System Administrator',
      email: 'admin.demo@example.com',
      phoneNumber: '+919999999990',
      passwordHash,
      accountStatus: 'ACTIVE',
      isPhoneVerified: true,
      roles: {
        create: { role: 'ADMIN' },
      },
    },
  });

  await prisma.adminAuditLog.create({
    data: {
      adminUserId: adminUser.id,
      action: 'SYSTEM_INITIALIZED',
      entityType: 'SYSTEM',
      entityId: adminUser.id,
      metadata: JSON.stringify({ version: '1.0.0', seededAt: new Date().toISOString() }),
    },
  });

  console.log('✅ Created 1 Admin user');

  // 3. Create Providers (5)
  const providerNames = [
    { business: 'VoltaCharge Ahmedabad', email: 'provider1.demo@example.com', phone: '+919999999991', city: 'Ahmedabad', address: 'SG Highway, Nr. Iscon Circle' },
    { business: 'GreenSpark EV', email: 'provider2.demo@example.com', phone: '+919999999992', city: 'Gandhinagar', address: 'Infocity Sector 9' },
    { business: 'ChargePoint Demo Gujarat', email: 'provider3.demo@example.com', phone: '+919999999993', city: 'Surat', address: 'Ring Road, Near Textile Market' },
    { business: 'RapidVolt Station', email: 'provider4.demo@example.com', phone: '+919999999994', city: 'Mumbai', address: 'Andheri West Link Road' },
    { business: 'EVGrid Demo', email: 'provider5.demo@example.com', phone: '+919999999995', city: 'Bengaluru', address: 'Koramangala 5th Block' },
  ];

  const providerUsers = [];
  for (let i = 0; i < providerNames.length; i++) {
    const p = providerNames[i];
    const user = await prisma.user.create({
      data: {
        fullName: `Provider Owner ${i + 1}`,
        email: p.email,
        phoneNumber: p.phone,
        passwordHash,
        accountStatus: 'ACTIVE',
        isPhoneVerified: true,
        roles: {
          create: { role: 'PROVIDER' },
        },
        providerProfile: {
          create: {
            businessName: p.business,
            contactPhone: p.phone,
            contactEmail: p.email,
            address: p.address,
            city: p.city,
            state: p.city === 'Mumbai' ? 'Maharashtra' : p.city === 'Bengaluru' ? 'Karnataka' : 'Gujarat',
            pincode: '380015',
            taxId: `24DEMOTAX${i}1Z5`,
            description: `Leading EV charging infrastructure provider in ${p.city}.`,
            verificationStatus: 'APPROVED',
          },
        },
        providerBank: {
          create: {
            accountName: p.business,
            accountNumber: `00000012345${i}`,
            ifscCode: 'DEMO0000001',
            bankName: 'Demo National Bank',
            isVerified: true,
          },
        },
      },
    });
    providerUsers.push(user);
  }
  console.log('✅ Created 5 Provider users with profiles and bank accounts');

  // 4. Create Customers (10)
  const customerData = [
    { name: 'Rahul Sharma', email: 'rahul.demo@example.com', phone: '+919876543210', city: 'Ahmedabad' },
    { name: 'Priya Patel', email: 'priya.demo@example.com', phone: '+919876543211', city: 'Gandhinagar' },
    { name: 'Arjun Mehta', email: 'arjun.demo@example.com', phone: '+919876543212', city: 'Surat' },
    { name: 'Neha Shah', email: 'neha.demo@example.com', phone: '+919876543213', city: 'Vadodara' },
    { name: 'Dev Patel', email: 'dev.demo@example.com', phone: '+919876543214', city: 'Mumbai' },
    { name: 'Aisha Khan', email: 'aisha.demo@example.com', phone: '+919876543215', city: 'Pune' },
    { name: 'Karan Desai', email: 'karan.demo@example.com', phone: '+919876543216', city: 'Delhi' },
    { name: 'Riya Joshi', email: 'riya.demo@example.com', phone: '+919876543217', city: 'Bengaluru' },
    { name: 'Amit Verma', email: 'amit.demo@example.com', phone: '+919876543218', city: 'Ahmedabad' },
    { name: 'Sneha Gupta', email: 'sneha.demo@example.com', phone: '+919876543219', city: 'Mumbai' },
  ];

  const customerUsers = [];
  for (let i = 0; i < customerData.length; i++) {
    const c = customerData[i];
    const user = await prisma.user.create({
      data: {
        fullName: c.name,
        email: c.email,
        phoneNumber: c.phone,
        passwordHash,
        accountStatus: 'ACTIVE',
        isPhoneVerified: true,
        roles: {
          create: { role: 'CUSTOMER' },
        },
        customerProfile: {
          create: {
            fullName: c.name,
            address: `House #${i + 1}, Main Street`,
            city: c.city,
            state: c.city === 'Mumbai' || c.city === 'Pune' ? 'Maharashtra' : c.city === 'Delhi' ? 'Delhi' : c.city === 'Bengaluru' ? 'Karnataka' : 'Gujarat',
            pincode: '380001',
          },
        },
        notificationPreferences: {
          create: {
            pushEnabled: true,
            bookingNotifications: true,
            paymentNotifications: true,
            sessionNotifications: true,
            promotionalEmails: i % 2 === 0,
          },
        },
      },
    });
    customerUsers.push(user);
  }
  console.log('✅ Created 10 Customer users with profiles');

  // 5. Create Charging Stations (15) across cities
  const stationLocations = [
    { name: 'Voltera SG Highway', city: 'Ahmedabad', lat: 23.0225, lng: 72.5714 },
    { name: 'Voltera Prahlad Nagar', city: 'Ahmedabad', lat: 23.0100, lng: 72.5100 },
    { name: 'Voltera Vastrapur', city: 'Ahmedabad', lat: 23.0360, lng: 72.5320 },
    { name: 'GreenSpark Gandhinagar Sec-11', city: 'Gandhinagar', lat: 23.2156, lng: 72.6369 },
    { name: 'GreenSpark Gandhinagar Infocity', city: 'Gandhinagar', lat: 23.1928, lng: 72.6343 },
    { name: 'GreenSpark Surat Central', city: 'Surat', lat: 21.1702, lng: 72.8311 },
    { name: 'ChargePoint Dumas Road', city: 'Surat', lat: 21.1458, lng: 72.7780 },
    { name: 'RapidVolt Vadodara Highway', city: 'Vadodara', lat: 22.3072, lng: 73.1812 },
    { name: 'VoltCharge Alkapuri', city: 'Vadodara', lat: 22.3167, lng: 73.1667 },
    { name: 'RapidVolt Airport Road Mumbai', city: 'Mumbai', lat: 19.0896, lng: 72.8656 },
    { name: 'EVGrid Bandra Kurla Complex', city: 'Mumbai', lat: 19.0657, lng: 72.8688 },
    { name: 'EVGrid Pune Hinjawadi', city: 'Pune', lat: 18.5913, lng: 73.7389 },
    { name: 'VoltaCharge Pune Koregaon', city: 'Pune', lat: 18.5362, lng: 73.8939 },
    { name: 'RapidVolt Connaught Place Delhi', city: 'Delhi', lat: 28.6280, lng: 77.2090 },
    { name: 'GreenSpark Koramangala Bengaluru', city: 'Bengaluru', lat: 12.9352, lng: 77.6245 },
  ];

  const allChargers = [];
  const allStations = [];

  for (let i = 0; i < stationLocations.length; i++) {
    const loc = stationLocations[i];
    const provider = providerUsers[i % providerUsers.length];

    const station = await prisma.chargingStation.create({
      data: {
        providerId: provider.id,
        name: loc.name,
        address: `100ft Ring Road, ${loc.city}`,
        city: loc.city,
        state: loc.city === 'Mumbai' || loc.city === 'Pune' ? 'Maharashtra' : loc.city === 'Delhi' ? 'Delhi' : loc.city === 'Bengaluru' ? 'Karnataka' : 'Gujarat',
        pincode: '380001',
        latitude: loc.lat,
        longitude: loc.lng,
        status: i === 2 ? 'MAINTENANCE' : 'ACTIVE',
        chargers: {
          create: [
            {
              chargerCode: `CHG-${loc.city.substring(0, 3).toUpperCase()}-0${i + 1}A`,
              name: 'Fast DC CCS2 (30kW)',
              chargerType: 'DC_FAST',
              connectorType: 'CCS2',
              powerKw: 30.0,
              pricePerHour: 120.0,
              pricePerKwh: 15.0,
              status: i === 2 ? 'OFFLINE' : 'AVAILABLE',
            },
            {
              chargerCode: `CHG-${loc.city.substring(0, 3).toUpperCase()}-0${i + 1}B`,
              name: 'Standard AC Type-2 (7.4kW)',
              chargerType: 'AC_STANDARD',
              connectorType: 'TYPE2',
              powerKw: 7.4,
              pricePerHour: 50.0,
              pricePerKwh: 10.0,
              status: 'AVAILABLE',
            },
          ],
        },
      },
      include: {
        chargers: true,
      },
    });

    allStations.push(station);
    allChargers.push(...station.chargers);
  }
  console.log(`✅ Created ${allStations.length} Charging Stations with ${allChargers.length} Connectors`);

  // 6. Create Bundles (2)
  const bundle1 = await prisma.bundle.create({
    data: {
      name: 'Starter Commuter Pass (50 kWh)',
      description: 'Ideal for urban two-wheeler commuters with 50 kWh included charging energy.',
      price: 499,
      currency: 'INR',
      validityDays: 30,
      status: 'ACTIVE',
    },
  });

  const bundle2 = await prisma.bundle.create({
    data: {
      name: 'Unlimited Monthly Pass',
      description: 'Unlimited charging across all Voltera network stations for 30 days.',
      price: 1999,
      currency: 'INR',
      validityDays: 30,
      status: 'ACTIVE',
    },
  });
  console.log('✅ Created 2 Energy Bundles');

  // 7. Create Emergency Services (2)
  await prisma.emergencyService.createMany({
    data: [
      {
        name: 'Voltera 24x7 Mobile Battery Van',
        serviceType: 'PORTABLE_CHARGING',
        phoneNumber: '+911800123456',
        description: 'On-demand mobile EV battery booster and roadside charging.',
        active: true,
      },
      {
        name: 'Flatbed EV Towing Express',
        serviceType: 'TOWING',
        phoneNumber: '+911800654321',
        description: 'Hydraulic towing specialized for electric two-wheelers and 4Ws.',
        active: true,
      },
    ],
  });
  console.log('✅ Created 2 Emergency Services');

  // 8. Create Bookings (20) & Charging Sessions (15) & Payments (20) & Transactions
  const bookings = [];
  const now = new Date();

  for (let i = 0; i < 20; i++) {
    const customer = customerUsers[i % customerUsers.length];
    const charger = allChargers[i % allChargers.length];
    const startTime = new Date(now.getTime() + (i - 5) * 60 * 60 * 1000);
    const endTime = new Date(startTime.getTime() + 60 * 60 * 1000);

    const statuses = ['PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED', 'ACTIVE'];
    const status = statuses[i % statuses.length];

    const booking = await prisma.booking.create({
      data: {
        customerId: customer.id,
        chargerId: charger.id,
        startTime,
        endTime,
        status: status === 'ACTIVE' ? 'CONFIRMED' : status,
      },
    });
    bookings.push(booking);
  }
  console.log('✅ Created 20 Bookings');

  // Create Charging Sessions (15)
  for (let i = 0; i < 15; i++) {
    const booking = bookings[i];
    const chargerId = booking.chargerId;
    const customerId = booking.customerId;

    const sessionStatus = i % 3 === 0 ? 'ACTIVE' : 'COMPLETED';
    const startedAt = booking.startTime;
    const endedAt = sessionStatus === 'COMPLETED' ? booking.endTime : null;

    const session = await prisma.chargingSession.create({
      data: {
        bookingId: booking.id,
        chargerId,
        customerId,
        startedAt,
        endedAt,
        status: sessionStatus,
      },
    });

    // Create payment for session
    const amount = 150 + (i * 25);
    const payment = await prisma.payment.create({
      data: {
        customerId,
        bookingId: booking.id,
        sessionId: session.id,
        amount,
        currency: 'INR',
        status: sessionStatus === 'COMPLETED' ? 'SUCCESS' : 'PENDING',
        gatewayProvider: 'mock',
        gatewayOrderId: `ORDER_DEMO_${i + 100}`,
        gatewayPaymentId: sessionStatus === 'COMPLETED' ? `PAY_DEMO_${i + 100}` : null,
        paidAt: sessionStatus === 'COMPLETED' ? new Date() : null,
      },
    });

    // Create transaction
    await prisma.transaction.create({
      data: {
        customerId,
        paymentId: payment.id,
        type: 'CHARGING_PAYMENT',
        amount,
        currency: 'INR',
        status: 'COMPLETED',
      },
    });
  }
  console.log('✅ Created 15 Charging Sessions with Payments and Transactions');

  // 9. Create Provider Payouts
  for (let i = 0; i < providerUsers.length; i++) {
    const provider = providerUsers[i];
    await prisma.providerPayout.create({
      data: {
        providerId: provider.id,
        amount: 2500 + (i * 500),
        currency: 'INR',
        status: 'PROCESSED',
        providerReference: `DEMO-TXN-1000${i + 1}`,
        processedAt: new Date(),
      },
    });
  }
  console.log('✅ Created Provider Payouts');

  // 10. Create Notifications (30)
  for (let i = 0; i < customerUsers.length; i++) {
    const customer = customerUsers[i];
    await prisma.notification.createMany({
      data: [
        {
          recipientUserId: customer.id,
          type: 'BOOKING_CONFIRMED',
          title: 'Booking Confirmed!',
          body: 'Your charging slot has been successfully reserved at Voltera Hub.',
          isRead: false,
          deliveryStatus: 'DELIVERED',
        },
        {
          recipientUserId: customer.id,
          type: 'PAYMENT_SUCCESS',
          title: 'Payment Successful',
          body: '₹180 paid successfully for your recent charging session.',
          isRead: true,
          readAt: new Date(),
          deliveryStatus: 'DELIVERED',
        },
        {
          recipientUserId: customer.id,
          type: 'CHARGING_COMPLETED',
          title: 'Charging Completed',
          body: 'Your EV is fully charged and ready to ride. Have a safe journey!',
          isRead: false,
          deliveryStatus: 'DELIVERED',
        },
      ],
    });
  }
  console.log('✅ Created 30 Notifications');

  // 11. Create Support Tickets & Messages
  for (let i = 0; i < customerUsers.length; i++) {
    const customer = customerUsers[i];
    const ticket = await prisma.supportTicket.create({
      data: {
        userId: customer.id,
        category: 'CHARGING_ISSUE',
        subject: 'Connector speed query',
        status: i % 2 === 0 ? 'OPEN' : 'RESOLVED',
        messages: {
          create: {
            senderUserId: customer.id,
            message: 'Hello, what is the maximum charging speed supported on CCS2 port?',
          },
        },
      },
    });

    if (i % 2 !== 0) {
      await prisma.supportMessage.create({
        data: {
          ticketId: ticket.id,
          senderUserId: adminUser.id,
          message: 'Hello! The CCS2 port supports up to 30kW DC fast charging.',
        },
      });
    }
  }
  console.log('✅ Created Support Tickets & Messages');

  console.log('\n========================================');
  console.log('VOLTERA MOCK DATA CREATED SUCCESSFULLY');
  console.log('========================================');
  console.log(`Users: ${1 + providerUsers.length + customerUsers.length}`);
  console.log(`Customers: ${customerUsers.length}`);
  console.log(`Providers: ${providerUsers.length}`);
  console.log(`Admins: 1`);
  console.log(`Stations: ${allStations.length}`);
  console.log(`Bookings: ${bookings.length}`);
  console.log(`Charging Sessions: 15`);
  console.log(`Payments: 20`);
  console.log(`Notifications: 30`);
  console.log('\nDEMO LOGIN ACCOUNTS');
  console.log('----------------------------------------');
  console.log('Customer:');
  console.log('Email: rahul.demo@example.com');
  console.log('Password: Demo@12345');
  console.log('\nProvider:');
  console.log('Email: provider1.demo@example.com');
  console.log('Password: Demo@12345');
  console.log('\nAdmin:');
  console.log('Email: admin.demo@example.com');
  console.log('Password: Demo@12345');
  console.log('========================================\n');
}

main()
  .catch((e) => {
    console.error('❌ Seeding error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
