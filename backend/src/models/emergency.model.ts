export interface CreateEmergencyRequestInput {
  serviceId: string;
  description?: string;
  latitude?: number;
  longitude?: number;
  address?: string;
}
