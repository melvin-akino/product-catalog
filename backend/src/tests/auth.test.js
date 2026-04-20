require('./setup');
const request = require('supertest');
const jwt = require('jsonwebtoken');

jest.mock('../config/database', () => ({
  pool: {
    query: jest.fn(),
    getConnection: jest.fn().mockResolvedValue({ release: jest.fn() }),
  },
  testConnection: jest.fn().mockResolvedValue(true),
}));

const app = require('../app');

describe('Auth API', () => {
  describe('POST /api/auth/login', () => {
    it('returns JWT token for valid credentials', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ username: 'admin', password: 'testpass' });

      expect(res.status).toBe(200);
      expect(res.body.token).toBeDefined();
      expect(res.body.username).toBe('admin');
      expect(res.body.role).toBe('admin');
    });

    it('token payload contains correct claims', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ username: 'admin', password: 'testpass' });

      const decoded = jwt.verify(res.body.token, process.env.JWT_SECRET);
      expect(decoded.username).toBe('admin');
      expect(decoded.role).toBe('admin');
    });

    it('returns 401 for wrong username', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ username: 'wronguser', password: 'testpass' });

      expect(res.status).toBe(401);
      expect(res.body.error).toBeDefined();
    });

    it('returns 401 for wrong password', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ username: 'admin', password: 'wrongpassword' });

      expect(res.status).toBe(401);
      expect(res.body.error).toBeDefined();
    });

    it('returns 400 when username is missing', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ password: 'testpass' });

      expect(res.status).toBe(400);
      expect(res.body.errors).toBeDefined();
    });

    it('returns 400 when password is missing', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({ username: 'admin' });

      expect(res.status).toBe(400);
      expect(res.body.errors).toBeDefined();
    });

    it('returns 400 when body is empty', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({});

      expect(res.status).toBe(400);
    });
  });

  describe('POST /api/auth/verify', () => {
    let validToken;

    beforeEach(() => {
      validToken = jwt.sign(
        { username: 'admin', role: 'admin' },
        process.env.JWT_SECRET,
        { expiresIn: '1h' }
      );
    });

    it('returns valid:true for a good token', async () => {
      const res = await request(app)
        .post('/api/auth/verify')
        .set('Authorization', `Bearer ${validToken}`);

      expect(res.status).toBe(200);
      expect(res.body.valid).toBe(true);
      expect(res.body.user.username).toBe('admin');
    });

    it('returns 401 when no Authorization header is sent', async () => {
      const res = await request(app).post('/api/auth/verify');
      expect(res.status).toBe(401);
      expect(res.body.valid).toBe(false);
    });

    it('returns 403 for a tampered token', async () => {
      const res = await request(app)
        .post('/api/auth/verify')
        .set('Authorization', 'Bearer eyJhbGciOiJIUzI1NiJ9.bad.payload');

      expect(res.status).toBe(403);
      expect(res.body.valid).toBe(false);
    });

    it('returns 403 for an expired token', async () => {
      const expired = jwt.sign(
        { username: 'admin', role: 'admin' },
        process.env.JWT_SECRET,
        { expiresIn: '-1s' }
      );
      const res = await request(app)
        .post('/api/auth/verify')
        .set('Authorization', `Bearer ${expired}`);

      expect(res.status).toBe(403);
    });
  });
});
