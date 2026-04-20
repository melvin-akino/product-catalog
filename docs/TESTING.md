# Testing Guide

## Overview

The backend has a full Jest + Supertest test suite covering all API endpoints. Tests run against a mocked database — no MySQL instance or Docker setup required.

**Total: 83 tests across 8 test files**

| File                    | Tests | What it covers                              |
|-------------------------|-------|---------------------------------------------|
| `health.test.js`        | 3     | Health endpoint, response shape, timestamp  |
| `auth.test.js`          | 11    | Login, verify, invalid creds, expired token |
| `products.test.js`      | 16    | CRUD, pagination, search, 404, auth guards  |
| `categories.test.js`    | 13    | CRUD, slug lookup, 400/409 errors           |
| `siteContent.test.js`   | 9     | GET/PUT pages, upsert, admin list           |
| `companyInfo.test.js`   | 8     | GET/PUT, upsert, field verification         |
| `socialLinks.test.js`   | 12    | Public/admin list, CRUD, active filter      |
| `seo.test.js`           | 11    | CRUD, 409 duplicate, XML sitemap            |

---

## Running Tests

### Option 1 — Shell script (recommended)

From the project root:

```bash
# Run all tests
bash run-tests.sh

# Run with coverage report
bash run-tests.sh --coverage

# Run a specific test file
bash run-tests.sh auth
bash run-tests.sh products

# Watch mode (re-runs on file changes)
bash run-tests.sh --watch
```

The script auto-installs dependencies if `node_modules/jest` is missing.

### Option 2 — npm directly

```bash
cd backend
npm install           # first time only
npm test              # run all tests
npm run test:coverage # with coverage report
npm run test:watch    # watch mode
```

### Option 3 — single file

```bash
cd backend
npx jest src/tests/auth.test.js --forceExit
```

---

## Test Output

A passing run looks like:

```
 PASS  src/tests/health.test.js
 PASS  src/tests/auth.test.js
 PASS  src/tests/products.test.js
 PASS  src/tests/categories.test.js
 PASS  src/tests/siteContent.test.js
 PASS  src/tests/companyInfo.test.js
 PASS  src/tests/socialLinks.test.js
 PASS  src/tests/seo.test.js

Test Suites: 8 passed, 8 total
Tests:       83 passed, 83 total
```

---

## How the Tests Work

### Database Mocking

All tests mock the MySQL pool so no real database is needed:

```js
jest.mock('../config/database', () => ({
  pool: {
    query: jest.fn(),
    getConnection: jest.fn().mockResolvedValue({ release: jest.fn() }),
  },
  testConnection: jest.fn().mockResolvedValue(true),
}));
```

This is declared at the top of each test file, before `require('../app')`.

### Setup File

`src/tests/setup.js` sets environment variables before any test runs:

```js
process.env.JWT_SECRET = 'test_jwt_secret_for_unit_tests';
process.env.ADMIN_USERNAME = 'admin';
const bcrypt = require('bcryptjs');
process.env.ADMIN_PASSWORD_HASH = bcrypt.hashSync('testpass', 4);
```

Cost factor 4 is used (instead of production's 10) to keep tests fast.

Each test file begins with `require('./setup')` to ensure these are set before `app.js` loads.

### Mock Pattern

Route handlers call `pool.query()` sequentially. Mock each call in order:

```js
// Single query (e.g., GET by ID)
pool.query.mockResolvedValueOnce([[mockProduct], []]);

// Two queries (e.g., INSERT then SELECT)
pool.query
  .mockResolvedValueOnce([{ insertId: 5 }, []])
  .mockResolvedValueOnce([[newProduct], []]);

// Error simulation
pool.query.mockRejectedValueOnce({ code: 'ER_DUP_ENTRY' });
```

Each test calls `jest.clearAllMocks()` in `beforeEach` to reset call history.

### Auth Token Helper

Protected endpoints require a JWT. Each file has:

```js
const adminToken = () =>
  jwt.sign({ username: 'admin', role: 'admin' }, process.env.JWT_SECRET, { expiresIn: '1h' });
```

Usage:
```js
const res = await request(app)
  .post('/api/products')
  .set('Authorization', `Bearer ${adminToken()}`)
  .send({ name: 'Test Product', category_id: 1 });
```

---

## Writing New Tests

### File template

```js
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

describe('My Route API', () => {
  beforeEach(() => jest.clearAllMocks());

  it('returns data', async () => {
    pool.query.mockResolvedValueOnce([[{ id: 1 }], []]);
    const res = await request(app).get('/api/my-route');
    expect(res.status).toBe(200);
  });
});
```

### Checklist for new route tests

- [ ] GET list (public access, empty array case)
- [ ] GET single by ID (200 and 404)
- [ ] POST without auth → 401
- [ ] POST with valid auth → 201 + correct body
- [ ] POST with missing required field → 400
- [ ] POST duplicate → 409 (if unique constraint exists)
- [ ] PUT without auth → 401
- [ ] PUT with valid auth → 200 + updated body
- [ ] PUT nonexistent → 404
- [ ] DELETE without auth → 401
- [ ] DELETE with valid auth → 200 + message
- [ ] DELETE nonexistent → 404

---

## Coverage

Run `bash run-tests.sh --coverage` to generate an HTML report at `backend/coverage/lcov-report/index.html`.

Open it in a browser:
```bash
# macOS / Linux
open backend/coverage/lcov-report/index.html

# Windows
start backend/coverage/lcov-report/index.html
```

Coverage is collected from all `src/**/*.js` files except `src/server.js` (entry point only, no logic to test).

---

## CI Integration

To run tests in a CI pipeline (e.g., GitHub Actions):

```yaml
- name: Run backend tests
  working-directory: ./backend
  run: |
    npm ci
    npm test
  env:
    JWT_SECRET: ci_test_secret
    ADMIN_USERNAME: admin
    ADMIN_PASSWORD_HASH: ${{ secrets.ADMIN_PASSWORD_HASH }}
```

No database service is needed since all DB calls are mocked.
