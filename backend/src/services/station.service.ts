import { AppError } from '../utils/app-error.js';
import { stationRepository } from '../repositories/station.repository.js';
import { CreateStationInput, UpdateStationInput, CreateChargerInput, UpdateChargerInput, ChargerDiscoveryFilters } from '../models/station.model.js';
import { Prisma } from '@prisma/client';

export class StationService {
  async createStation(providerId: string, input: CreateStationInput) {
    return stationRepository.createStation(providerId, input);
  }

  async getProviderStations(providerId: string) {
    return stationRepository.findStationsByProvider(providerId);
  }

  async getProviderStationDetails(providerId: string, stationId: string) {
    const station = await stationRepository.findStationByIdAndProvider(stationId, providerId);
    if (!station) {
      throw AppError.notFound('Station not found or you do not have permission to view it');
    }
    return station;
  }

  async updateStation(providerId: string, stationId: string, input: UpdateStationInput) {
    const station = await stationRepository.findStationByIdAndProvider(stationId, providerId);
    if (!station) {
      throw AppError.notFound('Station not found or you do not have permission to modify it');
    }

    return stationRepository.updateStation(stationId, input);
  }

  async createCharger(providerId: string, stationId: string, input: CreateChargerInput) {
    // Verify station ownership
    const station = await stationRepository.findStationByIdAndProvider(stationId, providerId);
    if (!station) {
      throw AppError.notFound('Station not found or you do not have permission to add chargers to it');
    }

    try {
      return await stationRepository.createCharger(stationId, input);
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
        throw AppError.conflict('A charger with this charger code already exists.');
      }
      throw error;
    }
  }

  async updateCharger(providerId: string, chargerId: string, input: UpdateChargerInput) {
    // Check charger and ownership
    const charger = await stationRepository.findChargerById(chargerId);
    if (!charger) {
      throw AppError.notFound('Charger not found');
    }

    if (charger.station.providerId !== providerId) {
      throw AppError.forbidden('You do not have permission to modify this charger');
    }

    try {
      return await stationRepository.updateCharger(chargerId, input);
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
        throw AppError.conflict('A charger with this charger code already exists.');
      }
      throw error;
    }
  }

  async discoverChargers(filters: ChargerDiscoveryFilters) {
    let chargers = await stationRepository.discoverChargers(filters);

    // Map to a frontend-friendly DTO format based on Customer API needs
    const mapped = chargers.map((c: any) => {
      let distanceKm = c.distanceKm;

      // Fallback manual calculation if repository missed it
      if (distanceKm === undefined && filters.latitude !== undefined && filters.longitude !== undefined) {
        const lat = Number(filters.latitude);
        const lon = Number(filters.longitude);
        const R = 6371; // km
        const dLat = (c.station.latitude - lat) * (Math.PI / 180);
        const dLon = (c.station.longitude - lon) * (Math.PI / 180);
        const a =
          Math.sin(dLat / 2) * Math.sin(dLat / 2) +
          Math.cos(lat * (Math.PI / 180)) * Math.cos(c.station.latitude * (Math.PI / 180)) *
          Math.sin(dLon / 2) * Math.sin(dLon / 2);
        const ch = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        distanceKm = R * ch;
      }

      return {
        id: c.id,
        chargerCode: c.chargerCode,
        name: c.name || c.station.name,
        providerId: c.station.providerId,
        locationAddress: c.station.address,
        latitude: c.station.latitude,
        longitude: c.station.longitude,
        city: c.station.city,
        state: c.station.state,
        pincode: c.station.pincode,
        chargerType: c.chargerType,
        connectorType: c.connectorType,
        powerKw: c.powerKw,
        pricePerHour: c.pricePerHour,
        pricePerKwh: c.pricePerKwh,
        isAvailable: c.status === 'AVAILABLE',
        status: c.status,
        stationId: c.station.id,
        stationName: c.station.name,
        distanceKm: distanceKm !== undefined ? Math.round(distanceKm * 10) / 10 : undefined, // rounded to 1 decimal
      };
    });

    if (filters.latitude !== undefined && filters.longitude !== undefined && filters.radius === undefined) {
      mapped.sort((a, b) => (a.distanceKm || 0) - (b.distanceKm || 0));
    }

    return mapped;
  }

  async getChargerDetails(chargerId: string) {
    const charger = await stationRepository.findChargerById(chargerId);
    if (!charger || charger.station.status !== 'ACTIVE') {
      throw AppError.notFound('Charger not found');
    }

    return {
      id: charger.id,
      chargerCode: charger.chargerCode,
      name: charger.name || charger.station.name,
      providerId: charger.station.providerId,
      locationAddress: charger.station.address,
      latitude: charger.station.latitude,
      longitude: charger.station.longitude,
      city: charger.station.city,
      state: charger.station.state,
      pincode: charger.station.pincode,
      chargerType: charger.chargerType,
      connectorType: charger.connectorType,
      powerKw: charger.powerKw,
      pricePerHour: charger.pricePerHour,
      pricePerKwh: charger.pricePerKwh,
      isAvailable: charger.status === 'AVAILABLE',
      status: charger.status,
      stationId: charger.station.id,
      stationName: charger.station.name,
    };
  }
}

export const stationService = new StationService();
