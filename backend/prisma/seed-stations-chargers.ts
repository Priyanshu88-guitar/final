import { PrismaClient } from '@prisma/client';

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
  console.log('🌱 Starting Step 2: Charging Stations & Chargers Seeding (Jamnagar-First, Idempotent)...');

  await printCounts('BEFORE STATION/CHARGER SEEDING');

  const targetTotal = 28;

  const providers = await prisma.user.findMany({
    where: { roles: { some: { role: 'PROVIDER' } } },
  });

  if (providers.length === 0) {
    throw new Error('No provider users found in database to assign charging stations.');
  }

  let currentStations = await prisma.chargingStation.findMany({
    include: { chargers: true },
  });
  let currentChargersCount = await prisma.charger.count();

  console.log(`📊 Existing charging stations: ${currentStations.length} | Existing chargers: ${currentChargersCount}`);

  if (currentStations.length >= targetTotal && currentChargersCount >= targetTotal) {
    console.log('✅ Target of 28 stations and 28 chargers already achieved.');
    await printCounts('FINAL STATION/CHARGER COUNTS');
    return;
  }

  const existingCodes = new Set<string>();
  for (const st of currentStations) {
    for (const ch of st.chargers) {
      existingCodes.add(ch.chargerCode);
    }
  }

  const jamnagarLocalities = [
    { name: 'VOLTERA Station - Khodiyar Colony', address: 'Khodiyar Colony, Jamnagar', lat: 22.484432, lng: 70.063333 },
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

  let addedCount = 0;
  for (let i = 0; i < jamnagarLocalities.length; i++) {
    const stationsCountNow = await prisma.chargingStation.count();
    const chargersCountNow = await prisma.charger.count();
    if (stationsCountNow >= targetTotal && chargersCountNow >= targetTotal) break;

    const loc = jamnagarLocalities[i];
    const provider = providers[i % providers.length];
    const chargerCode = `CHG-JAM-${(300 + i).toString()}`;

    if (existingCodes.has(chargerCode)) {
      continue;
    }

    await prisma.$transaction(async (tx) => {
      await tx.chargingStation.create({
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
              chargerCode: chargerCode,
              name: 'Fast DC CCS2 (60kW)',
              chargerType: 'DC_FAST',
              connectorType: 'CCS2',
              powerKw: 60.0,
              pricePerHour: 150.0,
              pricePerKwh: 18.0,
              status: 'AVAILABLE',
            },
          },
        },
      });
      existingCodes.add(chargerCode);
    });

    addedCount++;
  }

  const finalCounts = await printCounts('FINAL STATION/CHARGER COUNTS');

  if (finalCounts.stations < 28 || finalCounts.chargers < 28) {
    throw new Error(`Integrity violation: Expected at least 28 stations and chargers, got Stations: ${finalCounts.stations}, Chargers: ${finalCounts.chargers}`);
  }

  console.log(`✅ Customer Step 2 completed successfully. Added ${addedCount} stations.`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
