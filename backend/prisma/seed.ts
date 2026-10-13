*777import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database reset and 20+ Jamnagar charging stations seeding...');

  // 1. Clean existing data in dependency order
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
    prisma.savedCharger.deleteMany(),
    prisma.charger.deleteMany(),
    prisma.chargingStation.deleteMany(),
    prisma.providerProfile.deleteMany(),
    prisma.customerVehicle.deleteMany(),
    prisma.providerSetupPhoto.deleteMany(),
    prisma.customerProfile.deleteMany(),
    prisma.authSession.deleteMany(),
    prisma.otpVerification.deleteMany(),
    prisma.userRole.deleteMany(),
    prisma.user.deleteMany(),
  ]);

  console.log('🧹 Wiped all existing database records.');

  // 2. Create the 3 specific Admin Users
  const admins = [
    { name: 'Priyanshu', phone: '7984601520', pass: 'priyanshu7094' },
    { name: 'Param', phone: '9081918230', pass: 'param7108' },
    { name: 'Het', phone: '7487862959', pass: 'het7113' }
  ];

  for (const admin of admins) {
    const passwordHash = await bcrypt.hash(admin.pass, 10);
    const user = await prisma.user.create({
      data: {
        fullName: admin.name,
        phoneNumber: admin.phone,
        passwordHash,
        accountStatus: 'ACTIVE',
        isPhoneVerified: true,
        roles: { create: { role: 'ADMIN' } },
      },
    });

    await prisma.adminAuditLog.create({
      data: {
        adminUserId: user.id,
        action: 'SYSTEM_INITIALIZED',
        entityType: 'SYSTEM',
        entityId: user.id,
        metadata: JSON.stringify({ note: `Admin ${admin.name} seeded` }),
      },
    });
  }

  // 3. Create 10 Dummy Customers in Jamnagar
  const customersData = [
    { name: 'Rahul Sharma', phone: '9876543210' },
    { name: 'Priya Patel', phone: '9876543211' },
    { name: 'Amit Verma', phone: '9876543212' },
    { name: 'Neha Gupta', phone: '9876543213' },
    { name: 'Vikram Singh', phone: '9876543214' },
    { name: 'Pooja Mehta', phone: '9876543215' },
    { name: 'Rohit Kulkarni', phone: '9876543216' },
    { name: 'Sneha Joshi', phone: '9876543217' },
    { name: 'Ankit Trivedi', phone: '9876543218' },
    { name: 'Divya Pandya', phone: '9876543219' },
  ];

  const createdCustomers = [];
  for (const c of customersData) {
    const passwordHash = await bcrypt.hash('Password123', 10);
    const user = await prisma.user.create({
      data: {
        fullName: c.name,
        phoneNumber: c.phone,
        passwordHash,
        accountStatus: 'ACTIVE',
        isPhoneVerified: true,
        email: `${c.name.toLowerCase().replace(/[^a-z]/g, '')}@voltera.com`,
        roles: { create: { role: 'CUSTOMER' } },
        customerProfile: {
          create: {
            fullName: c.name,
            city: 'Jamnagar',
            state: 'Gujarat',
            pincode: '361001',
            address: 'Jamnagar Resident',
            dateOfBirth: '1995-05-15',
          }
        }
      },
      include: { customerProfile: true }
    });

    if (user.customerProfile) {
      await prisma.customerVehicle.create({
        data: {
          customerProfileId: user.customerProfile.id,
          make: 'Ather',
          model: '450X',
          type: 'TWO_WHEELER',
          batteryCapacity: 3.7,
          connectorType: 'Type-2',
          mileage: 85,
        }
      });
    }
    createdCustomers.push(user);
  }

  // 4. Create 20+ Jamnagar Charging Stations & Providers across exact common locations
  const jamnagarStations = [
    { business: 'Lakhota Lake EV Hub', lat: 22.4720, lng: 70.0633, address: 'Near Lakhota Lake / Ranmal Lake, Jamnagar' },
    { business: 'Park Colony Supercharger', lat: 22.4830, lng: 70.0650, address: 'Park Colony Main Road, Jamnagar' },
    { business: 'PN Marg Fast Charge', lat: 22.4750, lng: 70.0500, address: 'Pandit Nehru Marg, Jamnagar' },
    { business: 'Ranjit Park Charging Plaza', lat: 22.4600, lng: 70.0550, address: 'Near Ranjit Park, Jamnagar' },
    { business: 'Bedi Gate Eco Hub', lat: 22.4780, lng: 70.0710, address: 'Bedi Gate Road, Jamnagar' },
    { business: 'Digvijay Plot EV Hub', lat: 22.4760, lng: 70.0580, address: 'Digvijay Plot, Jamnagar' },
    { business: 'Circuit House Central EV', lat: 22.4991, lng: 70.0448, address: 'Near Circuit House, Jamnagar' },
    { business: 'Patel Colony Power Hub', lat: 22.4810, lng: 70.0620, address: 'Patel Colony Jamnagar' },
    { business: 'Jamnagar Bus Station Fast Charge', lat: 22.4680, lng: 70.0590, address: 'ST Bus Station Road, Jamnagar' },
    { business: 'GIDC Phase-III Industrial Charger', lat: 22.4450, lng: 70.0900, address: 'GIDC Phase-III, Jamnagar' },
    { business: 'Hapa Railway Station EV Hub', lat: 22.4350, lng: 70.1200, address: 'Hapa Railway Station Area, Jamnagar' },
    { business: 'Dwarkadhish Highway Express', lat: 22.4900, lng: 69.9800, address: 'Dwarka-Jamnagar Highway' },
    { business: 'Amber Cinema Square EV Point', lat: 22.4730, lng: 70.0540, address: 'Amber Cinema Road, Jamnagar' },
    { business: 'Vasant Vihar Green Charge', lat: 22.4880, lng: 70.0670, address: 'Vasant Vihar Society, Jamnagar' },
    { business: 'Janta Chowk VoltStation', lat: 22.4650, lng: 70.0680, address: 'Janta Chowk, Jamnagar' },
    { business: 'Jamnagar Airport Road EV Point', lat: 22.4500, lng: 70.0150, address: 'Airport Road, Jamnagar' },
    { business: 'Jamnagar Port Marine Charger', lat: 22.4950, lng: 70.0750, address: 'Bedi Bunder Port Road, Jamnagar' },
    { business: 'Ashapuri Temple Square Station', lat: 22.4820, lng: 70.0530, address: 'Ashapuri Temple Area, Jamnagar' },
    { business: 'Indira Gandhi Marg Supercharger', lat: 22.4700, lng: 70.0520, address: 'Indira Gandhi Marg, Jamnagar' },
    { business: 'Bedi Bunder Road Fast Power', lat: 22.4850, lng: 70.0800, address: 'Bedi Bunder Road, Jamnagar' },
  ];

  let phoneCounter = 9123456700;
  const createdChargers = [];

  for (const s of jamnagarStations) {
    const phone = `${phoneCounter++}`;
    const passwordHash = await bcrypt.hash('Password123', 10);
    const user = await prisma.user.create({
      data: {
        fullName: s.business,
        phoneNumber: phone,
        passwordHash,
        accountStatus: 'ACTIVE',
        isPhoneVerified: true,
        email: `${s.business.toLowerCase().replace(/[^a-z]/g, '')}@voltera.com`,
        roles: { create: { role: 'PROVIDER' } },
        providerProfile: {
          create: {
            businessName: s.business,
            address: s.address,
            city: 'Jamnagar',
            state: 'Gujarat',
            pincode: '361001',
            verificationStatus: 'VERIFIED',
            taxId: '29ABCDE1234F1Z5',
            description: 'Top-tier EV fast charging hub in Jamnagar.',
          }
        }
      },
      include: { providerProfile: true }
    });

    if (user.providerProfile) {
      const station = await prisma.chargingStation.create({
        data: {
          providerId: user.id,
          name: s.business,
          address: s.address,
          city: 'Jamnagar',
          state: 'Gujarat',
          pincode: '361001',
          latitude: s.lat,
          longitude: s.lng,
          status: 'ACTIVE',
        }
      });

      const chg1 = await prisma.charger.create({
        data: {
          stationId: station.id,
          chargerCode: `JMG-${station.id.substring(0, 4)}-1`,
          name: `${s.business} - DC CCS2`,
          chargerType: 'DC',
          connectorType: 'CCS2',
          powerKw: 60.0,
          pricePerHour: 140.0,
          pricePerKwh: 14.0,
          status: 'AVAILABLE',
        }
      });
      createdChargers.push(chg1);

      const chg2 = await prisma.charger.create({
        data: {
          stationId: station.id,
          chargerCode: `JMG-${station.id.substring(0, 4)}-2`,
          name: `${s.business} - AC Type-2`,
          chargerType: 'AC',
          connectorType: 'Type-2',
          powerKw: 11.0,
          pricePerHour: 60.0,
          pricePerKwh: 10.0,
          status: 'AVAILABLE',
        }
      });
      createdChargers.push(chg2);

      await prisma.providerBankAccount.create({
        data: {
          providerId: user.id,
          accountName: s.business,
          accountNumber: '123456789012',
          ifscCode: 'HDFC0001234',
          bankName: 'HDFC Bank',
          isVerified: true,
        }
      });

      await prisma.providerSetupPhoto.create({
        data: {
          providerProfileId: user.providerProfile.id,
          photoUrl: 'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=500',
          description: 'Jamnagar verified charging station setup',
        }
      });
    }
  }

  // 5. Create Bookings, Sessions, Payments & Transactions
  const now = new Date();
  for (let i = 0; i < createdCustomers.length; i++) {
    const customer = createdCustomers[i];
    const charger = createdChargers[i % createdChargers.length];

    const startTime = new Date(now.getTime() + i * 3600000);
    const endTime = new Date(startTime.getTime() + 3600000);

    const booking = await prisma.booking.create({
      data: {
        customerId: customer.id,
        chargerId: charger.id,
        startTime,
        endTime,
        status: i < 5 ? 'COMPLETED' : 'CONFIRMED',
      }
    });

    const payment = await prisma.payment.create({
      data: {
        customerId: customer.id,
        bookingId: booking.id,
        amount: 15000,
        currency: 'INR',
        status: 'SUCCESS',
        gatewayOrderId: `order_jamnagar_${i}`,
        gatewayPaymentId: `pay_jamnagar_${i}`,
      }
    });

    await prisma.transaction.create({
      data: {
        customerId: customer.id,
        paymentId: payment.id,
        amount: 15000,
        type: 'CREDIT',
        status: 'COMPLETED',
      }
    });

    if (i < 5) {
      await prisma.chargingSession.create({
        data: {
          bookingId: booking.id,
          customerId: customer.id,
          chargerId: charger.id,
          status: 'COMPLETED',
          startedAt: startTime,
          endedAt: endTime,
        }
      });
    }
  }

  // 6. Create Support Tickets & Emergency Requests
  for (const customer of createdCustomers.slice(0, 3)) {
    const ticket = await prisma.supportTicket.create({
      data: {
        userId: customer.id,
        category: 'BILLING',
        subject: 'Double charged inquiry',
        status: 'OPEN',
      }
    });

    await prisma.supportMessage.create({
      data: {
        ticketId: ticket.id,
        senderUserId: customer.id,
        message: 'Hello, I noticed a duplicate payment for my recent charging session.',
      }
    });
  }

  const emergencyService = await prisma.emergencyService.create({
    data: {
      name: 'Jamnagar City Rapid Towing',
      serviceType: 'TOWING',
      phoneNumber: '1800123456',
      description: '24/7 rapid towing across Jamnagar landmarks',
    }
  });

  await prisma.emergencyRequest.create({
    data: {
      userId: createdCustomers[0].id,
      serviceId: emergencyService.id,
      description: 'Flat tire near Lakhota Lake',
      latitude: 22.4720,
      longitude: 70.0633,
      status: 'REQUESTED',
    }
  });

  // 7. Create Bundles
  await prisma.bundle.createMany({
    data: [
      { name: 'Jamnagar City Unlimited Pass', description: 'Unlimited charging across all 20 Jamnagar stations for 30 days', price: 79900, validityDays: 30, status: 'ACTIVE' },
      { name: 'Gujarat State EV Pass', description: 'All-Gujarat EV charging pass with 30% discount', price: 149900, validityDays: 30, status: 'ACTIVE' },
    ]
  });

  console.log('✅ Successfully seeded 20+ Jamnagar charging stations & 40+ chargers!');
  const userCount = await prisma.user.count();
  const stationCount = await prisma.chargingStation.count();
  const chargerCount = await prisma.charger.count();

  console.log('\n========================================');
  console.log('20+ JAMNAGAR STATIONS SEED COMPLETED');
  console.log('========================================');
  console.log(`Total Users: ${userCount}`);
  console.log(`Total Stations in Jamnagar: ${stationCount}`);
  console.log(`Total Chargers: ${chargerCount}`);
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
