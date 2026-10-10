export type StationStatus = 'ACTIVE' | 'INACTIVE' | 'MAINTENANCE';
export type ChargerStatus = 'AVAILABLE' | 'OCCUPIED' | 'OFFLINE' | 'MAINTENANCE' | 'DISABLED';

export interface ChargingStationModel {
  id: string;
  providerId: string;
  name: string;
  address: string;
  city: string | null;
  state: string | null;
  pincode: string | null;
  latitude: number;
  longitude: number;
  status: StationStatus;
  createdAt: Date;
  updatedAt: Date;
  chargers?: ChargerModel[];
}

export interface ChargerModel {
  id: string;
  stationId: string;
  chargerCode: string;
  name: string | null;
  chargerType: string;
  connectorType: string;
  powerKw: number;
  pricePerHour: number;
  pricePerKwh: number;
  status: ChargerStatus;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateStationInput {
  name: string;
  address: string;
  city?: string;
  state?: string;
  pincode?: string;
  latitude: number;
  longitude: number;
  status?: StationStatus;
}

export interface UpdateStationInput extends Partial<CreateStationInput> {}

export interface CreateChargerInput {
  chargerCode: string;
  name?: string;
  chargerType: string;
  connectorType: string;
  powerKw: number;
  pricePerHour?: number;
  pricePerKwh?: number;
  status?: ChargerStatus;
}

export interface UpdateChargerInput extends Partial<CreateChargerInput> {}

// Filters for customer discovery
export interface ChargerDiscoveryFilters {
  latitude?: number;
  longitude?: number;
  radius?: number; // In kilometers
  city?: string;
  state?: string;
  pincode?: string;
  status?: ChargerStatus;
  connectorType?: string;
  chargerType?: string;
  minPower?: number;
  maxPower?: number;
  search?: string; // Search across station name, address, charger code
}
