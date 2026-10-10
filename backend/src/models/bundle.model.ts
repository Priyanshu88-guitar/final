export interface Bundle {
  id: string;
  name: string;
  description: string | null;
  price: number;
  currency: string;
  validityDays: number | null;
  status: string;
  createdAt: Date;
  updatedAt: Date;
}
