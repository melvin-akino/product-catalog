# Architecture — EON Marketing Product Catalog

## System Overview

A B2B product catalog web application for EON Marketing & General Merchandise (San Juan, Philippines). Clients browse products and submit inquiries. Admins manage products, categories, users, content, and SEO settings via a protected panel.

---

## Tier Diagram

```
Browser
  │
  ▼
[ nginx : 80 ]  ──── static Vue 3 SPA (pre-built dist/)
  │
  │  /api/*  /uploads/*  → proxy_pass
  ▼
[ Node.js Express : 3000 ]
  │
  ▼
[ MariaDB 11 : 3306 ]
```

All three tiers run as Docker containers on a single EC2 t3.micro instance, orchestrated by Docker Compose.

---

## Frontend

| Concern | Choice |
|---|---|
| Framework | Vue 3 (Composition API) |
| Build tool | Vite 5 |
| State | Pinia |
| Routing | Vue Router 4 |
| Icons | lucide-vue-next |
| Rich text | @vueup/vue-quill (Quill Snow) |
| Font | Inter (Google Fonts) |
| Theme | Dark B2B — CSS custom properties |

**Build strategy:** Vite runs on the developer's machine. Only `dist/` is shipped to EC2. The frontend Docker image is nginx-only (`COPY dist/`). No Node.js on the server.

**Routing:** All routes served by Vue Router via nginx `try_files $uri $uri/ /index.html`.

**API base:** All API calls go through `/api/` which nginx proxies to the backend container.

---

## Backend

| Concern | Choice |
|---|---|
| Runtime | Node.js 20 (Alpine) |
| Framework | Express 4 |
| Auth | JWT (jsonwebtoken) + bcrypt |
| Validation | express-validator |
| DB driver | mysql2 (compatible with MariaDB) |
| File uploads | multer → `/app/uploads/` volume |

**Auth model:** JWT stored in localStorage. Admin-only routes require `authenticateToken` middleware + `role === 'admin'` check.

**Startup dependency:** Backend waits for MariaDB `service_healthy` before starting (Docker Compose `depends_on` condition).

---

## Database

| Concern | Choice |
|---|---|
| Engine | MariaDB 11 |
| Init | `01-schema.sql` + `02-seed.sql` via `docker-entrypoint-initdb.d/` |
| Persistence | Docker named volume `eon_mysql_data` |

Key tables: `products`, `categories`, `users`, `company_info`, `site_settings`.

---

## Infrastructure

See `infra.md` for full details.

---

## Request Flow

```
Client GET /catalog
  → nginx serves index.html (SPA)
  → Vue Router renders CatalogView
  → Pinia store calls GET /api/products
  → nginx proxies to backend:3000
  → Express queries MariaDB
  → JSON response → Pinia → rendered DOM
```

```
Admin POST /api/products
  → Vue sends JWT in Authorization: Bearer <token>
  → authenticateToken middleware validates
  → express-validator sanitizes body
  → pool.query INSERT INTO products
  → 201 JSON response
```

---

## Constraints

- **Single server:** All tiers on one t3.micro (1 GB RAM). No horizontal scaling.
- **No swap originally:** Added 2 GB swapfile (persisted in `/etc/fstab`) to prevent OOM.
- **Sequential container start:** mysql → healthy → backend → healthy → frontend. Never `docker compose up` all at once.
- **Local build only:** Never run `npm run build` on EC2. Always build locally and SCP `dist/`.
- **No CI/CD pipeline** currently. Deployments are manual via `aws-deploy.sh`.
