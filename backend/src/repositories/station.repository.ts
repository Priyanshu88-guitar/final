import { Prisma } from '@prisma/client';
import { prisma } from '../database/prisma.js';
import { CreateStationInput, UpdateStationInput, CreateChargerInput, UpdateChargerInput, ChargerDiscoveryFilters } from '../models/station.model.js';

export class StationRepository {
  async createStation(providerId: string, input: CreateStationInput) {
    return prisma.chargingStation.create({
      data: {
        providerId,
        name: input.name,
        address: input.address,
        city: input.city || null,
        state: input.state || null,
        pincode: input.pincode || null,
        latitude: input.latitude,
        longitude: input.longitude,
        status: input.status || 'ACTIVE',
      },
      include: { chargers: true },
    });
  }

  async findStationsByProvider(providerId: string) {
    return prisma.chargingStation.findMany({
      where: { providerId },
      include: { chargers: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findStationByIdAndProvider(stationId: string, providerId: string) {
    return prisma.chargingStation.findFirst({
      where: { id: stationId, providerId },
      include: { chargers: true },
    });
  }

  async updateStation(stationId: string, input: UpdateStationInput) {
    return prisma.chargingStation.update({
      where: { id: stationId },
      data: {
        ...(input.name !== undefined && { name: input.name }),
        ...(input.address !== undefined && { address: input.address }),
        ...(input.city !== undefined && { city: input.city }),
        ...(input.state !== undefined && { state: input.state }),
        ...(input.pincode !== undefined && { pincode: input.pincode }),
        ...(input.latitude !== undefined && { latitude: input.latitude }),
        ...(input.longitude !== undefined && { longitude: input.longitude }),
        ...(input.status !== undefined && { status: input.status }),
      },
      include: { chargers: true },
    });
  }

  async createCharger(stationId: string, input: CreateChargerInput) {
    return prisma.charger.create({
      data: {
        stationId,
        chargerCode: input.chargerCode,
        name: input.name || null,
        chargerType: input.chargerType,
        connectorType: input.connectorType,
        powerKw: input.powerKw,
        pricePerHour: input.pricePerHour || 0.0,
        pricePerKwh: input.pricePerKwh || 0.0,
        status: input.status || 'AVAILABLE',
      },
    });
  }

  async findChargerById(chargerId: string) {
    return prisma.charger.findUnique({
      where: { id: chargerId },
      include: { station: true },
    });
  }

  async updateCharger(chargerId: string, input: UpdateChargerInput) {
    return prisma.charger.update({
      where: { id: chargerId },
      data: {
        ...(input.chargerCode !== undefined && { chargerCode: input.chargerCode }),
        ...(input.name !== undefined && { name: input.name }),
        ...(input.chargerType !== undefined && { chargerType: input.chargerType }),
        ...(input.connectorType !== undefined && { connectorType: input.connectorType }),
        ...(input.powerKw !== undefined && { powerKw: input.powerKw }),
        ...(input.pricePerHour !== undefined && { pricePerHour: input.pricePerHour }),
        ...(input.pricePerKwh !== undefined && { pricePerKwh: input.pricePerKwh }),
        ...(input.status !== undefined && { status: input.status }),
      },
    });
  }

  async discoverChargers(filters: ChargerDiscoveryFilters) {
    const whereClause: Prisma.ChargerWhereInput = {};

    if (filters.status) whereClause.status = filters.status;
    if (filters.connectorType) whereClause.connectorType = filters.connectorType;
    if (filters.chargerType) whereClause.chargerType = filters.chargerType;

    if (filters.minPower || filters.maxPower) {
      whereClause.powerKw = {};
      if (filters.minPower !== undefined) whereClause.powerKw.gte = Number(filters.minPower);
      if (filters.maxPower !== undefined) whereClause.powerKw.lte = Number(filters.maxPower);
    }

    const stationWhere: Prisma.ChargingStationWhereInput = {
      status: 'ACTIVE',
    };

    if (filters.city) stationWhere.city = { contains: filters.city };
    if (filters.state) stationWhere.state = { contains: filters.state };
    if (filters.pincode) stationWhere.pincode = filters.pincode;

    if (filters.search) {
      const searchStr = filters.search;
      whereClause.OR = [
        { chargerCode: { contains: searchStr } },
        { name: { contains: searchStr } },
        {
          station: {
            OR: [
              { name: { contains: searchStr } },
              { address: { contains: searchStr } },
            ],
          },
        },
      ];
    }

    const existingStationWhere = whereClause.station as Prisma.ChargingStationWhereInput | undefined;
    whereClause.station = {
      ...existingStationWhere,
      ...stationWhere,
    };

    const chargersResult = await prisma.charger.findMany({
      where: whereClause,
      include: {
        station: true,
      },
      orderBy: { createdAt: 'desc' },
    });

    let chargers: any[] = chargersResult;

    const hasLat = filters.latitude !== undefined && filters.latitude !== null && String(filters.latitude).trim() !== '';
    const hasLng = filters.longitude !== undefined && filters.longitude !== null && String(filters.longitude).trim() !== '';

    if (hasLat && hasLng) {
      const lat = Number(filters.latitude);
      const lon = Number(filters.longitude);
      const rad = filters.radius !== undefined ? Number(filters.radius) : undefined;
      const R = 6371; // km

      chargers = chargers.map((charger) => {
        const dLat = (charger.station.latitude - lat) * (Math.PI / 180);
        const dLon = (charger.station.longitude - lon) * (Math.PI / 180);
        const a =
          Math.sin(dLat / 2) * Math.sin(dLat / 2) +
          Math.cos(lat * (Math.PI / 180)) * Math.cos(charger.station.latitude * (Math.PI / 180)) *
          Math.sin(dLon / 2) * Math.sin(dLon / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        const distance = R * c;

        // Spread to create a new plain JS object since Prisma objects may not allow arbitrary properties
        return { ...charger, distanceKm: distance };
      });

      if (rad !== undefined && !isNaN(rad)) {
        return chargers.filter((c: any) => c.distanceKm <= rad);
      }

      return chargers.sort((a: any, b: any) => a.distanceKm - b.distanceKm);
    }

    return chargers;
  }
}

export const stationRepository = new StationRepository();
