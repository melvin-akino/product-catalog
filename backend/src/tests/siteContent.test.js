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

const mockPage = {
  content_id: 1,
  page_name: 'about',
  content_body: '<h1>About Us</h1><p>We sell lights.</p>',
};

describe('Site Content API', () => {
  beforeEach(() => jest.clearAllMocks());

  describe('GET /api/site-content/:page', () => {
    it('returns content for an existing page', async () => {
      pool.query.mockResolvedValueOnce([[mockPage], []]);

      const res = await request(app).get('/api/site-content/about');
      expect(res.status).toBe(200);
      expect(res.body.page_name).toBe('about');
      expect(res.body.content_body).toContain('<h1>');
    });

    it('returns 404 for nonexistent page', async () => {
      pool.query.mockResolvedValueOnce([[], []]);

      const res = await request(app).get('/api/site-content/nonexistent');
      expect(res.status).toBe(404);
      expect(res.body.error).toBeDefined();
    });

    it('works for all standard pages', async () => {
      const pages = ['about', 'contact', 'shipping', 'terms'];
      for (const page of pages) {
        pool.query.mockResolvedValueOnce([[{ ...mockPage, page_name: page }], []]);
        const res = await request(app).get(`/api/site-content/${page}`);
        expect(res.status).toBe(200);
      }
    });
  });

  describe('PUT /api/site-content/:page', () => {
    it('returns 401 without auth', async () => {
      const res = await request(app)
        .put('/api/site-content/about')
        .send({ content_body: '<p>Updated</p>' });
      expect(res.status).toBe(401);
    });

    it('updates existing page content', async () => {
      const updated = { ...mockPage, content_body: '<h1>Updated</h1>' };
      pool.query
        .mockResolvedValueOnce([[mockPage], []])  // check existing
        .mockResolvedValueOnce([{ affectedRows: 1 }, []])  // UPDATE
        .mockResolvedValueOnce([[updated], []]);  // fetch updated

      const res = await request(app)
        .put('/api/site-content/about')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({ content_body: '<h1>Updated</h1>' });

      expect(res.status).toBe(200);
      expect(res.body.content_body).toBe('<h1>Updated</h1>');
    });

    it('creates page content if it does not exist yet', async () => {
      pool.query
        .mockResolvedValueOnce([[], []])  // no existing page
        .mockResolvedValueOnce([{ insertId: 5 }, []])  // INSERT
        .mockResolvedValueOnce([[{ ...mockPage, page_name: 'newpage' }], []]);

      const res = await request(app)
        .put('/api/site-content/newpage')
        .set('Authorization', `Bearer ${adminToken()}`)
        .send({ content_body: '<p>New page content</p>' });

      expect(res.status).toBe(200);
    });
  });

  describe('GET /api/site-content (admin list)', () => {
    it('returns 401 without auth', async () => {
      const res = await request(app).get('/api/site-content');
      expect(res.status).toBe(401);
    });

    it('returns all pages with valid auth', async () => {
      pool.query.mockResolvedValueOnce([[mockPage, { ...mockPage, page_name: 'contact' }], []]);

      const res = await request(app)
        .get('/api/site-content')
        .set('Authorization', `Bearer ${adminToken()}`);

      expect(res.status).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body).toHaveLength(2);
    });
  });
});
