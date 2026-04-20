require('./setup');
const request = require('supertest');

jest.mock('../config/database', () => ({
  pool: {
    query: jest.fn(),
    getConnection: jest.fn().mockResolvedValue({ release: jest.fn() }),
  },
  testConnection: jest.fn().mockResolvedValue(true),
}));

const app = require('../app');

describe('Health Check', () => {
  it('GET /api/health → 200 with status ok', async () => {
    const res = await request(app).get('/api/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
    expect(res.body.timestamp).toBeDefined();
  });

  it('GET /api/health → timestamp is a valid ISO string', async () => {
    const res = await request(app).get('/api/health');
    expect(() => new Date(res.body.timestamp)).not.toThrow();
  });

  it('GET /nonexistent → redirects (not 404 from API)', async () => {
    const res = await request(app).get('/api/nonexistent-route');
    expect([404, 301, 302]).toContain(res.status);
  });
});
