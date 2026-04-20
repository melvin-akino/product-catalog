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

const mockCategory = { category_id: 1, name: 'Lighting', description: 'LED solutions', slug: 'lighting', product_count: 10 };

describe('Categories API', () => {
  beforeEach(() => jest.clearAllMocks());

  describe('GET /api/categories', () => {
    it('returns array of categories with product_count', async () => {
      pool.query.mockResolvedValueOnce([[mockCategory], []]);

      const res = await request(app).get('/api/categories');
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body[0].name).toBe('Lighting');
      expect(res.body[0].product_count).toBe(10);
    });

    it('returns empty array when no categories exist', async () => {
      pool.query.mockResolvedValueOnce([[], []]);

      const res = await request(app).get('/api/categories');
      expect(res.status).toBe(200);
      expect(res.body).toHaveLength(0);
    });
  });

  describe('GET /api/categories/:id', () => {
    it('returns a single category by ID', async () => {
      pool.query.mockResolvedValueOnce([[mockCategory], []]);

      const res = await request(app).get('/api/categories/1');
      expect(res.status).toBe(200);
      expect(res.body.slug).toBe('lighting');
    });

    it('returns a single category by slug', async () => {
      pool.query.mockResolvedValueOnce([[mockCategory], []]);

      const res = await request(app).get('/api/categories/lighting');
      expect(res.status).toBe(200);
    });

    it('returns 404 for nonexistent category', async () => {
      pool.query.mockResolvedValueOnce([[], []]);

      const res = await request(app).get('/api/categories/9999');
      expect(res.status).toBe(404);
    });
  });

  describe('POST /api/categories', () => {
    it('returns 401 without auth', async () => {
      const res = await request(app).post('/api/categories').send({ name: 'Test' });
      expect(res.status).toBe(401);
    });

    it('creates a category with valid auth', async () => {
      pool.query
        .mockResolvedValueOnce([{ insertId: 2 }, []])
        .mockResolvedValueOnce([[{ ...mockCategory, category_id: 2, name: 'Equipment' }], []]);

      const res = await request(app)
        .post('/api/categories')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({ name: 'Equipment', description: 'Tools and machinery' });

      expect(res.status).toBe(201);
      expect(res.body.name).toBe('Equipment');
    });

    it('returns 400 when name is missing', async () => {
      const res = await request(app)
        .post('/api/categories')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({ description: 'No name' });

      expect(res.status).toBe(400);
    });

    it('returns 409 on duplicate category', async () => {
      pool.query.mockRejectedValueOnce({ code: 'ER_DUP_ENTRY' });

      const res = await request(app)
        .post('/api/categories')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({ name: 'Lighting' });

      expect(res.status).toBe(409);
    });
  });

  describe('PUT /api/categories/:id', () => {
    it('returns 401 without auth', async () => {
      const res = await request(app).put('/api/categories/1').send({ name: 'Updated' });
      expect(res.status).toBe(401);
    });

    it('updates category with valid auth', async () => {
      pool.query
        .mockResolvedValueOnce([{ affectedRows: 1 }, []])
        .mockResolvedValueOnce([[{ ...mockCategory, name: 'Updated Lighting' }], []]);

      const res = await request(app)
        .put('/api/categories/1')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({ name: 'Updated Lighting', description: 'Updated desc' });

      expect(res.status).toBe(200);
      expect(res.body.name).toBe('Updated Lighting');
    });
  });

  describe('DELETE /api/categories/:id', () => {
    it('returns 401 without auth', async () => {
      const res = await request(app).delete('/api/categories/1');
      expect(res.status).toBe(401);
    });

    it('deletes category with valid auth', async () => {
      pool.query.mockResolvedValueOnce([{ affectedRows: 1 }, []]);

      const res = await request(app)
        .delete('/api/categories/1')
        .set('Authorization', `Bearer ${adminToken()}`);

      expect(res.status).toBe(200);
      expect(res.body.message).toContain('deleted');
    });
  });
});
