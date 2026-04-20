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

const mockSeo = {
  seo_id: 1,
  page_name: 'home',
  meta_title: 'EON Marketing – Equipment & Lighting',
  meta_description: 'Professional equipment and lighting products.',
  keywords: JSON.stringify(['equipment', 'lighting', 'industrial']),
  og_image: null,
};

describe('SEO API', () => {
  beforeEach(() => jest.clearAllMocks());

  describe('GET /api/seo', () => {
    it('returns all SEO records', async () => {
      pool.query.mockResolvedValueOnce([[mockSeo], []]);

      const res = await request(app).get('/api/seo');
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body[0].page_name).toBe('home');
    });

    it('is publicly accessible', async () => {
      pool.query.mockResolvedValueOnce([[mockSeo], []]);
      const res = await request(app).get('/api/seo');
      expect(res.status).toBe(200);
    });
  });

  describe('GET /api/seo/:page', () => {
    it('returns SEO data for a specific page', async () => {
      pool.query.mockResolvedValueOnce([[mockSeo], []]);

      const res = await request(app).get('/api/seo/home');
      expect(res.status).toBe(200);
      expect(res.body.meta_title).toBe('EON Marketing – Equipment & Lighting');
    });

    it('returns 404 for nonexistent page SEO', async () => {
      pool.query.mockResolvedValueOnce([[], []]);

      const res = await request(app).get('/api/seo/nonexistent');
      expect(res.status).toBe(404);
    });
  });

  describe('POST /api/seo', () => {
    it('returns 401 without auth', async () => {
      const res = await request(app).post('/api/seo').send({ page_name: 'test' });
      expect(res.status).toBe(401);
    });

    it('creates a SEO record with valid auth', async () => {
      pool.query
        .mockResolvedValueOnce([{ insertId: 2 }, []])
        .mockResolvedValueOnce([[{ ...mockSeo, seo_id: 2, page_name: 'about' }], []]);

      const res = await request(app)
        .post('/api/seo')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({
          page_name: 'about',
          meta_title: 'About – EON Marketing',
          meta_description: 'Learn about us.',
          keywords: ['about', 'company'],
          og_image: null,
        });

      expect(res.status).toBe(201);
      expect(res.body.page_name).toBe('about');
    });

    it('returns 409 for duplicate page_name', async () => {
      pool.query.mockRejectedValueOnce({ code: 'ER_DUP_ENTRY' });

      const res = await request(app)
        .post('/api/seo')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({ page_name: 'home', meta_title: 'Dupe', meta_description: '', keywords: [] });

      expect(res.status).toBe(409);
    });
  });

  describe('PUT /api/seo/:id', () => {
    it('returns 401 without auth', async () => {
      const res = await request(app).put('/api/seo/1').send({ meta_title: 'New' });
      expect(res.status).toBe(401);
    });

    it('updates SEO record with valid auth', async () => {
      const updated = { ...mockSeo, meta_title: 'Updated Title' };
      pool.query
        .mockResolvedValueOnce([{ affectedRows: 1 }, []])
        .mockResolvedValueOnce([[updated], []]);

      const res = await request(app)
        .put('/api/seo/1')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({ page_name: 'home', meta_title: 'Updated Title', meta_description: 'Desc', keywords: ['kw'], og_image: null });

      expect(res.status).toBe(200);
      expect(res.body.meta_title).toBe('Updated Title');
    });

    it('returns 404 when SEO record does not exist', async () => {
      pool.query
        .mockResolvedValueOnce([{ affectedRows: 1 }, []])
        .mockResolvedValueOnce([[], []]);

      const res = await request(app)
        .put('/api/seo/9999')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({ page_name: 'ghost', meta_title: '', meta_description: '', keywords: [] });

      expect(res.status).toBe(404);
    });
  });

  describe('GET /api/seo/sitemap/xml', () => {
    it('returns valid XML sitemap', async () => {
      pool.query
        .mockResolvedValueOnce([[{ slug: 'led-panel', updated_at: new Date() }], []])
        .mockResolvedValueOnce([[{ slug: 'lighting' }], []]);

      const res = await request(app).get('/api/seo/sitemap/xml');
      expect(res.status).toBe(200);
      expect(res.headers['content-type']).toContain('xml');
      expect(res.text).toContain('<?xml');
      expect(res.text).toContain('<urlset');
      expect(res.text).toContain('</urlset>');
    });

    it('sitemap includes product URLs', async () => {
      pool.query
        .mockResolvedValueOnce([[{ slug: 'led-panel-36w', updated_at: new Date() }], []])
        .mockResolvedValueOnce([[{ slug: 'lighting' }], []]);

      const res = await request(app).get('/api/seo/sitemap/xml');
      expect(res.text).toContain('led-panel-36w');
    });
  });
});
