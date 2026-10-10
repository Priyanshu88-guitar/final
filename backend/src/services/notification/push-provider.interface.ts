export interface IPushProvider {
  name: string;
  sendToDevice(token: string, title: string, body: string, data?: any): Promise<boolean>;
}
