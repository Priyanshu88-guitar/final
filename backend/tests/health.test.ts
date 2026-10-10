import { describe, it, expect } from 'vitest';
import supertest from 'supertest';
import { app } from '../src/app.js';

describe('GET /health', () => {
  it('should return 200 OK and valid health check payload', async () => {
    const response = await supertest(app).get('/health');

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('success', true);
    expect(response.body).toHaveProperty('message', 'VOLTERA backend is running');
    expect(response.body).toHaveProperty('data');
    expect(response.body.data).toHaveProperty('status', 'ok');
    expect(response.body.data).toHaveProperty('timestamp');
    expect(response.body.data.database).toHaveProperty('connected', true);
  });

  it('should return 200 OK for /api/v1/health', async () => {
    const response = await supertest(app).get('/api/v1/health');

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('success', true);
    expect(response.body.data).toHaveProperty('status', 'ok');
  });
});
