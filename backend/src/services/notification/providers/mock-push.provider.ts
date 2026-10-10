import { IPushProvider } from '../push-provider.interface.js';
import { logger } from '../../../config/logger.js';

export class MockPushProvider implements IPushProvider {
  name = 'mock_push';
  public sentPushes: { token: string; title: string; body: string; data?: any }[] = [];

  async sendToDevice(token: string, title: string, body: string, data?: any): Promise<boolean> {
    logger.debug(`[MockPushProvider] Sending push to ${token}: ${title} - ${body}`);
    this.sentPushes.push({ token, title, body, data });
    return true; // Simulate success
  }

  clear() {
    this.sentPushes = [];
  }
}
