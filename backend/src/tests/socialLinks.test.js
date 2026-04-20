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

const mockLink = { link_id: 1, platform: 'Facebook', url: 'https://facebook.com/eonmgm', icon: 'facebook', active: 1, sort_order: 1 };

describe('Social Links API', () => {
  beforeEach(() => jest.clearAllMocks());

  describe('GET /api/social-links', () => {
    it('returns active social links publicly', async () => {
      pool.query.mockResolvedValueOnce([[mockLink], []]);

      const res = await request(app).get('/api/social-links');
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body[0].platform).toBe('Facebook');
    });

    it('only returns active links to public', async () => {
      pool.query.mockResolvedValueOnce([[mockLink], []]);
      await request(app).get('/api/social-links');
      const [sql] = pool.query.mock.calls[0];
      expect(sql).toContain('active=1');
    });

    it('returns empty array when no links exist', async () => {
      pool.query.mockResolvedValueOnce([[], []]);
      const res = await request(app).get('/api/social-links');
      expect(res.status).toBe(200);
      expect(res.body).toHaveLength(0);
    });
  });

  describe('GET /api/social-links/all (admin)', () => {
    it('returns 401 without auth', async () => {
      const res = await request(app).get('/api/social-links/all');
      expect(res.status).toBe(401);
    });

    it('returns all links including inactive ones with auth', async () => {
      const inactive = { ...mockLink, link_id: 2, platform: 'TikTok', active: 0 };
      pool.query.mockResolvedValueOnce([[mockLink, inactive], []]);

      const res = await request(app)
        .get('/api/social-links/all')
        .set('Authorization', `Bearer ${adminToken()}`);

      expect(res.status).toBe(200);
      expect(res.body).toHaveLength(2);
    });
  });

  describe('POST /api/social-links', () => {
    it('returns 401 without auth', async () => {
      const res = await request(app).post('/api/social-links').send({ platform: 'X', url: 'https://x.com' });
      expect(res.status).toBe(401);
    });

    it('creates a social link with valid auth', async () => {
      pool.query
        .mockResolvedValueOnce([{ insertId: 3 }, []])
        .mockResolvedValueOnce([[{ ...mockLink, link_id: 3, platform: 'X', url: 'https://x.com' }], []]);

      const res = await request(app)
        .post('/api/social-links')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({ platform: 'X', url: 'https://x.com', sort_order: 2 });

      expect(res.status).toBe(201);
      expect(res.body.platform).toBe('X');
    });
  });

  describe('PUT /api/social-links/:id', () => {
    it('returns 401 without auth', async () => {
      const res = await request(app).put('/api/social-links/1').send({ platform: 'FB', url: 'https://fb.com' });
      expect(res.status).toBe(401);
    });

    it('updates a social link with valid auth', async () => {
      const updated = { ...mockLink, url: 'https://facebook.com/eonmgm2' };
      pool.query
        .mockResolvedValueOnce([{ affectedRows: 1 }, []])
        .mockResolvedValueOnce([[updated], []]);

      const res = await request(app)
        .put('/api/social-links/1')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({ platform: 'Facebook', url: 'https://facebook.com/eonmgm2', icon: 'facebook', active: 1, sort_order: 1 });

      expect(res.status).toBe(200);
    });

    it('returns 404 when link does not exist', async () => {
      pool.query
        .mockResolvedValueOnce([{ affectedRows: 1 }, []])
        .mockResolvedValueOnce([[], []]);

      const res = await request(app)
        .put('/api/social-links/9999')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({ platform: 'FB', url: 'https://fb.com', icon: 'fb', active: 1, sort_order: 0 });

      expect(res.status).toBe(404);
    });
  });

  describe('DELETE /api/social-links/:id', () => {
    it('returns 401 without auth', async () => {
      const res = await request(app).delete('/api/social-links/1');
      expect(res.status).toBe(401);
    });

    it('deletes a link with valid auth', async () => {
      pool.query.mockResolvedValueOnce([{ affectedRows: 1 }, []]);

      const res = await request(app)
        .delete('/api/social-links/1')
        .set('Authorization', `Bearer ${adminToken()}`);

      expect(res.status).toBe(200);
      expect(res.body.message).toBeDefined();
    });
  });
});
