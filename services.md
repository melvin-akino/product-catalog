# Services

---

## frontend (nginx)

| Property | Value |
|---|---|
| Container | `eon_frontend` |
| Image | `nginx:1.25-alpine` |
| Internal port | 80 |
| Host port | `${APP_PORT:-9090}` |
| Source | `frontend/Dockerfile` |
| Build input | `frontend/dist/` (pre-built locally) |
| Config | `frontend/nginx.conf` |
| Depends on | `backend` (healthy) |

**Responsibilities:**
- Serve pre-built Vue 3 SPA static assets
- Proxy `/api/*` and `/uploads/*` to `backend:3000`
- SPA fallback: all unmatched routes → `index.html`
- Gzip compression for JS/CSS/JSON/SVG
- 1-year cache headers on static assets (immutable)

**Health check:** `curl -fso /dev/null http://127.0.0.1/` (interval 15s)

---

## backend (Node.js Express)

| Property | Value |
|---|---|
| Container | `eon_backend` |
| Image | `node:20-alpine` (built from source) |
| Internal port | 3000 |
| Host port | none (not exposed externally) |
| Source | `backend/Dockerfile` |
| Entry point | `backend/src/index.js` |
| Env | mounted as volume `.env.backend → /app/.env` |
| Uploads | named volume `eon_uploads_data → /app/uploads` |
| Depends on | `mysql` (healthy) |

**Responsibilities:**
- REST API at `/api/*`
- JWT authentication and authorization
- Input validation via express-validator
- File uploads via multer
- Database access via mysql2 connection pool
- Serving `/uploads/*` static files

**Health check:** `wget -qO- http://localhost:3000/api/health` (interval 15s)

**Key source files:**
```
backend/src/
  index.js              — Express app setup, middleware, route mounting
  routes/
    auth.js             — POST /auth/login, GET /auth/me
    products.js         — CRUD /products
    categories.js       — CRUD /categories
    users.js            — CRUD /users
    upload.js           — POST /upload/images
    company.js          — GET/PUT /company
    settings.js         — GET/PUT /settings
  middleware/
    auth.js             — authenticateToken, requireAdmin
  config/
    database.js         — mysql2 pool + testConnection (named export: { pool })
```

---

## mysql (MariaDB)

| Property | Value |
|---|---|
| Container | `eon_mysql` |
| Image | `mariadb:11` |
| Internal port | 3306 |
| Host port | 3306 (exposed — tighten for production) |
| Data | named volume `eon_mysql_data → /var/lib/mysql` |
| Init scripts | `01-schema.sql`, `02-seed.sql` via `docker-entrypoint-initdb.d/` |
| Env vars | `MARIADB_ROOT_PASSWORD`, `MARIADB_DATABASE` from `.env` |

**Health check:** `healthcheck.sh --connect --innodb_initialized` (interval 10s, retries 12)

**Schema:** `backend/database/schema.sql`
**Seed:** `backend/database/seed-products.sql`

---

## Startup Order

```
mysql  ──healthy──▶  backend  ──healthy──▶  frontend
```

Never start all services simultaneously. See ADR-004.

---

## Environment Variables

### `.env` (Docker Compose + frontend context)
```
APP_PORT=9090
DB_NAME=product_catalog
DB_PASSWORD=<secret>
```

### `.env.backend` (mounted into backend container as `/app/.env`)
```
PORT=3000
DB_HOST=mysql
DB_PORT=3306
DB_USER=root
DB_PASSWORD=<secret>
DB_NAME=product_catalog
JWT_SECRET=<secret>
ADMIN_USERNAME=admin
ADMIN_PASSWORD=<plaintext — used at seed time>
ADMIN_PASSWORD_HASH=<bcrypt hash — used at runtime>
```

Both files are **gitignored**. Transferred to EC2 via SCP only. Never committed.

---

## Named Volumes

| Volume | Purpose |
|---|---|
| `eon_mysql_data` | MariaDB data directory — persists across container restarts |
| `eon_uploads_data` | User-uploaded product images — persists across deploys |
