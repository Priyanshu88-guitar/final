import { describe, it, expect } from 'vitest';
import supertest from 'supertest';
import { app } from '../src/app.js';

describe('Error Handling & Invalid Requests', () => {
  it('should return 404 for unknown route in standardized error format', async () => {
    const response = await supertest(app).get('/non-existent-endpoint');

    expect(response.status).toBe(404);
    expect(response.body).toHaveProperty('success', false);
    expect(response.body).toHaveProperty('error');
    expect(response.body.error).toHaveProperty('code', 'NOT_FOUND');
    expect(response.body.error).toHaveProperty('message');
    expect(response.body.error.message).toContain('Route GET /non-existent-endpoint not found');
  });

  it('should return 400 for malformed JSON request body', async () => {
    const response = await supertest(app)
      .post('/health')
      .set('Content-Type', 'application/json')
      .send('{"invalid_json": ');

    expect(response.status).toBe(400);
    expect(response.body).toHaveProperty('success', false);
    expect(response.body.error).toHaveProperty('code', 'MALFORMED_JSON');
  });
});
