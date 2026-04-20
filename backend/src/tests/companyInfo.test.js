require('./setup');
const request = require('supertest');
const jwt = require('jsonwebtoken');

jest.mock('../config/database', () => ({
  pool: { query: jest.fn(), getConnection: jest.fn().mockResolvedValue({ release: jest.fn() }) },
  testConnection: jest.fn().mockResolvedValue(true),
}));

const app = require('../app');
const { pool } = require('../config/database');

const adminToken = () =>
  jwt.sign({ username: 'admin', role: 'admin' }, process.env.JWT_SECRET, { expiresIn: '1h' });

const mockCompany = {
  company_id: 1,
  name: 'EON Marketing and General Merchandise',
  address: 'San Juan, Metro Manila, Philippines',
  phone: '+63 917 000 0000',
  email: 'eonmgm@gmail.com',
  tagline: 'Your One-Stop Shop for Equipment and Lighting Solutions',
  logo_url: null,
};

describe('Company Info API', () => {
  beforeEach(() => jest.clearAllMocks());

  describe('GET /api/company-info', () => {
    it('returns company information', async () => {
      pool.query.mockResolvedValueOnce([[mockCompany], []]);

      const res = await request(app).get('/api/company-info');
      expect(res.status).toBe(200);
      expect(res.body.name).toBe('EON Marketing and General Merchandise');
      expect(res.body.email).toBe('eonmgm@gmail.com');
    });

    it('returns 404 when company info is not set up', async () => {
      pool.query.mockResolvedValueOnce([[], []]);

      const res = await request(app).get('/api/company-info');
      expect(res.status).toBe(404);
    });

    it('is publicly accessible (no auth required)', async () => {
      pool.query.mockResolvedValueOnce([[mockCompany], []]);

      const res = await request(app).get('/api/company-info');
      expect(res.status).toBe(200);
    });
  });

  describe('PUT /api/company-info', () => {
    it('returns 401 without auth', async () => {
      const res = await request(app)
        .put('/api/company-info')
        .send({ name: 'Updated Co' });
      expect(res.status).toBe(401);
    });

    it('updates company info with valid auth (existing record)', async () => {
      const updated = { ...mockCompany, name: 'Updated EON', tagline: 'New tagline' };
      pool.query
        .mockResolvedValueOnce([[mockCompany], []])  // fetch existing
        .mockResolvedValueOnce([{ affectedRows: 1 }, []])  // UPDATE
        .mockResolvedValueOnce([[updated], []]);  // fetch result

      const res = await request(app)
        .put('/api/company-info')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({ name: 'Updated EON', tagline: 'New tagline', address: 'San Juan', phone: '123', email: 'a@b.com', logo_url: null });

      expect(res.status).toBe(200);
      expect(res.body.name).toBe('Updated EON');
    });

    it('creates company info if none exists yet', async () => {
      pool.query
        .mockResolvedValueOnce([[], []])  // no existing
        .mockResolvedValueOnce([{ insertId: 1 }, []])  // INSERT
        .mockResolvedValueOnce([[mockCompany], []]);

      const res = await request(app)
        .put('/api/company-info')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({ name: 'EON', address: '', phone: '', email: '', tagline: '', logo_url: '' });

      expect(res.status).toBe(200);
    });

    it('preserves all fields in the update', async () => {
      pool.query
        .mockResolvedValueOnce([[mockCompany], []])
        .mockResolvedValueOnce([{ affectedRows: 1 }, []])
        .mockResolvedValueOnce([[mockCompany], []]);

      const payload = { name: 'EON', address: '123 St', phone: '+63', email: 'e@e.com', tagline: 'Tag', logo_url: 'https://logo.png' };
      await request(app)
        .put('/api/company-info')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send(payload);

      const [sql, params] = pool.query.mock.calls[1];
      expect(sql).toContain('UPDATE company_info');
      expect(params).toContain('EON');
    });
  });
});
