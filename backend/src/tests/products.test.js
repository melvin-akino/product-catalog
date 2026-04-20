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

const mockProduct = {
  product_id: 1,
  name: 'LED High Bay 100W',
  description: 'Industrial LED light',
  specifications: JSON.stringify({ Power: '100W' }),
  images: JSON.stringify(['https://example.com/img.jpg']),
  slug: 'led-high-bay-100w',
  featured: 1,
  status: 'active',
  category_id: 1,
  category_name: 'Lighting',
  category_slug: 'lighting',
};

describe('Products API', () => {
  beforeEach(() => jest.clearAllMocks());

  // ── GET /api/products ─────────────────────────────────────────
  describe('GET /api/products', () => {
    it('returns paginated product list with total', async () => {
      pool.query
        .mockResolvedValueOnce([[mockProduct], []])
        .mockResolvedValueOnce([[{ total: 1 }], []]);

      const res = await request(app).get('/api/products');
      expect(res.status).toBe(200);
      expect(res.body.products).toHaveLength(1);
      expect(res.body.total).toBe(1);
      expect(res.body.page).toBe(1);
    });

    it('accepts search query parameter', async () => {
      pool.query
        .mockResolvedValueOnce([[mockProduct], []])
        .mockResolvedValueOnce([[{ total: 1 }], []]);

      const res = await request(app).get('/api/products?search=LED');
      expect(res.status).toBe(200);
      const [sql] = pool.query.mock.calls[0];
      expect(sql).toContain('LIKE');
    });

    it('accepts category query parameter', async () => {
      pool.query
        .mockResolvedValueOnce([[mockProduct], []])
        .mockResolvedValueOnce([[{ total: 1 }], []]);

      const res = await request(app).get('/api/products?category=lighting');
      expect(res.status).toBe(200);
      const [sql] = pool.query.mock.calls[0];
      expect(sql).toContain('c.slug');
    });

    it('accepts featured=true filter', async () => {
      pool.query
        .mockResolvedValueOnce([[mockProduct], []])
        .mockResolvedValueOnce([[{ total: 1 }], []]);

      const res = await request(app).get('/api/products?featured=true');
      expect(res.status).toBe(200);
      const [sql] = pool.query.mock.calls[0];
      expect(sql).toContain('featured');
    });

    it('returns empty list when no products match', async () => {
      pool.query
        .mockResolvedValueOnce([[], []])
        .mockResolvedValueOnce([[{ total: 0 }], []]);

      const res = await request(app).get('/api/products?search=nonexistent');
      expect(res.status).toBe(200);
      expect(res.body.products).toHaveLength(0);
      expect(res.body.total).toBe(0);
    });

    it('respects page and limit params', async () => {
      pool.query
        .mockResolvedValueOnce([[mockProduct], []])
        .mockResolvedValueOnce([[{ total: 50 }], []]);

      const res = await request(app).get('/api/products?page=2&limit=5');
      expect(res.status).toBe(200);
      expect(res.body.page).toBe(2);
      expect(res.body.limit).toBe(5);
    });
  });

  // ── GET /api/products/:id ─────────────────────────────────────
  describe('GET /api/products/:id', () => {
    it('returns single product by ID', async () => {
      pool.query.mockResolvedValueOnce([[mockProduct], []]);

      const res = await request(app).get('/api/products/1');
      expect(res.status).toBe(200);
      expect(res.body.name).toBe('LED High Bay 100W');
    });

    it('returns single product by slug', async () => {
      pool.query.mockResolvedValueOnce([[mockProduct], []]);

      const res = await request(app).get('/api/products/led-high-bay-100w');
      expect(res.status).toBe(200);
      expect(res.body.slug).toBe('led-high-bay-100w');
    });

    it('returns 404 for nonexistent product', async () => {
      pool.query.mockResolvedValueOnce([[], []]);

      const res = await request(app).get('/api/products/9999');
      expect(res.status).toBe(404);
      expect(res.body.error).toBeDefined();
    });
  });

  // ── POST /api/products ────────────────────────────────────────
  describe('POST /api/products', () => {
    it('returns 401 without auth token', async () => {
      const res = await request(app)
        .post('/api/products')
        .send({ name: 'New Product' });
      expect(res.status).toBe(401);
    });

    it('creates a product with valid auth and data', async () => {
      pool.query
        .mockResolvedValueOnce([{ insertId: 42 }, []])
        .mockResolvedValueOnce([[{ ...mockProduct, product_id: 42 }], []]);

      const res = await request(app)
        .post('/api/products')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({
          name: 'New LED Panel',
          description: 'A bright panel',
          category_id: 1,
          images: ['https://example.com/img.jpg'],
          specifications: { Power: '36W' },
        });

      expect(res.status).toBe(201);
    });

    it('returns 400 when name is missing', async () => {
      const res = await request(app)
        .post('/api/products')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({ description: 'No name provided' });

      expect(res.status).toBe(400);
      expect(res.body.errors).toBeDefined();
    });
  });

  // ── PUT /api/products/:id ─────────────────────────────────────
  describe('PUT /api/products/:id', () => {
    it('returns 401 without auth token', async () => {
      const res = await request(app)
        .put('/api/products/1')
        .send({ name: 'Updated' });
      expect(res.status).toBe(401);
    });

    it('updates a product with valid auth', async () => {
      pool.query
        .mockResolvedValueOnce([{ affectedRows: 1 }, []])
        .mockResolvedValueOnce([[{ ...mockProduct, name: 'Updated Name' }], []]);

      const res = await request(app)
        .put('/api/products/1')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({ name: 'Updated Name', status: 'active', featured: false });

      expect(res.status).toBe(200);
      expect(res.body.name).toBe('Updated Name');
    });

    it('returns 404 when product does not exist', async () => {
      pool.query
        .mockResolvedValueOnce([{ affectedRows: 1 }, []])
        .mockResolvedValueOnce([[], []]);

      const res = await request(app)
        .put('/api/products/9999')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({ name: 'Ghost', status: 'active' });

      expect(res.status).toBe(404);
    });
  });

  // ── DELETE /api/products/:id ──────────────────────────────────
  describe('DELETE /api/products/:id', () => {
    it('returns 401 without auth token', async () => {
      const res = await request(app).delete('/api/products/1');
      expect(res.status).toBe(401);
    });

    it('deletes a product with valid auth', async () => {
      pool.query.mockResolvedValueOnce([{ affectedRows: 1 }, []]);

      const res = await request(app)
        .delete('/api/products/1')
        .set('Authorization', `Bearer ${adminToken()}`);

      expect(res.status).toBe(200);
      expect(res.body.message).toContain('deleted');
    });

    it('returns 404 when product does not exist', async () => {
      pool.query.mockResolvedValueOnce([{ affectedRows: 0 }, []]);

      const res = await request(app)
        .delete('/api/products/9999')
        .set('Authorization', `Bearer ${adminToken()}`);

      expect(res.status).toBe(404);
    });
  });
});
