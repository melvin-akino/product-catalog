# Architecture Overview

## System Design

EON Marketing Product Catalog is a full-stack web application with three independently deployed services orchestrated by Docker Compose.

```
┌─────────────────────────────────────────────────────┐
│                    Browser                          │
└─────────────┬──────────────────┬───────────────────┘
              │ :8080            │ /api/*
              ▼                  ▼
┌─────────────────────────────────────────────────────┐
│            Nginx (frontend container)               │
│  ┌──────────────────────┐  ┌──────────────────────┐ │
│  │  Vue 3 SPA (dist/)   │  │  /api/ → backend:3000│ │
│  │  Static HTML/JS/CSS  │  │  Reverse Proxy       │ │
│  └──────────────────────┘  └──────────────────────┘ │
└─────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────┐
│            Node.js / Express (backend)              │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────────┐ │
│  │  Routes  │ │  Auth    │ │  Multer (uploads)    │ │
│  │  /api/*  │ │  JWT     │ │  /uploads/ static    │ │
│  └──────────┘ └──────────┘ └──────────────────────┘ │
└─────────────────────────────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────┐
│                 MySQL 8.0                           │
│   products │ categories │ site_content             │
│   company_info │ social_media_links │ seo_settings │
└─────────────────────────────────────────────────────┘
```

## Tech Stack

| Layer       | Technology                        | Purpose                               |
|-------------|-----------------------------------|---------------------------------------|
| Frontend    | Vue 3 (Composition API)           | Reactive SPA                          |
| Routing     | Vue Router 4                      | Client-side navigation / history mode |
| State       | Pinia                             | Auth store, token persistence         |
| Build       | Vite 5                            | Dev server, production bundling       |
| Backend     | Node.js 20 + Express 4            | REST API server                       |
| Auth        | jsonwebtoken + bcryptjs           | JWT-based admin authentication        |
| Uploads     | Multer                            | Multipart image handling              |
| Database    | MySQL 8.0 (mysql2/promise)        | Relational product data               |
| Web server  | Nginx 1.25                        | Static file serving + API proxy       |
| Container   | Docker + Docker Compose v2        | Local and production deployment       |
| Testing     | Jest 29 + Supertest               | Unit/integration tests for API        |

## Directory Structure

```
product-catalog/
├── docker-compose.yml          # Service orchestration
├── .env.backend                # Backend secrets (not committed)
├── setup.sh                    # One-command project bootstrap
├── run-tests.sh                # CLI test runner
│
├── frontend/
│   ├── Dockerfile              # Multi-stage: Vite build → Nginx serve
│   ├── nginx.conf              # SPA routing + /api/ proxy
│   ├── src/
│   │   ├── App.vue             # Root component, global styles
│   │   ├── main.js             # App bootstrap, Pinia, Router
│   │   ├── assets/main.css     # CSS custom properties (theme)
│   │   ├── stores/auth.js      # Pinia auth store
│   │   ├── router/index.js     # Route definitions, auth guard
│   │   ├── components/
│   │   │   ├── NavBar.vue
│   │   │   ├── AppFooter.vue
│   │   │   ├── ProductCard.vue
│   │   │   ├── ProductGallery.vue
│   │   │   ├── InquireModal.vue
│   │   │   ├── FilterSidebar.vue
│   │   │   └── admin/
│   │   │       └── HelpPanel.vue
│   │   └── views/
│   │       ├── HomeView.vue
│   │       ├── CatalogView.vue
│   │       ├── ProductDetailView.vue
│   │       ├── AboutView.vue
│   │       ├── ContactView.vue
│   │       ├── ShippingView.vue
│   │       ├── TermsView.vue
│   │       └── admin/
│   │           ├── AdminLayout.vue
│   │           ├── LoginView.vue
│   │           ├── DashboardView.vue
│   │           ├── ProductsView.vue
│   │           ├── CategoriesView.vue
│   │           ├── ContentEditorView.vue
│   │           ├── CompanyInfoView.vue
│   │           ├── SocialLinksView.vue
│   │           └── SEOManagerView.vue
│
├── backend/
│   ├── Dockerfile              # Node 20 Alpine image
│   ├── package.json
│   └── src/
│       ├── server.js           # Entry point — listen only
│       ├── app.js              # Express app (importable for tests)
│       ├── config/
│       │   └── database.js     # mysql2/promise pool
│       ├── middleware/
│       │   └── auth.js         # JWT verification middleware
│       ├── routes/
│       │   ├── auth.js
│       │   ├── products.js
│       │   ├── categories.js
│       │   ├── siteContent.js
│       │   ├── companyInfo.js
│       │   ├── socialLinks.js
│       │   └── seo.js
│       └── tests/
│           ├── setup.js
│           ├── health.test.js
│           ├── auth.test.js
│           ├── products.test.js
│           ├── categories.test.js
│           ├── siteContent.test.js
│           ├── companyInfo.test.js
│           ├── socialLinks.test.js
│           └── seo.test.js
│
└── database/
    ├── schema.sql              # Table definitions
    └── seed-products.sql       # 24 sample products
```

## Database Schema

```sql
categories      (category_id, name, description, slug)
products        (product_id, name, description, specs JSON, price,
                 images JSON, category_id FK, slug, featured, stock, created_at, updated_at)
site_content    (content_id, page_name UNIQUE, content_body)
company_info    (company_id, name, address, phone, email, tagline, logo_url)
social_media_links (link_id, platform, url, icon, active, sort_order)
seo_settings    (seo_id, page_name UNIQUE, meta_title, meta_description,
                 keywords JSON, og_image)
```

## Data Flow

### Public Product Browsing

```
User browser → GET /products/led-high-bay-100w
→ Vue Router matches ProductDetailView
→ fetch('/api/products/led-high-bay-100w')
→ Nginx proxy → Express route handler
→ MySQL SELECT * FROM products WHERE slug = ?
→ JSON response → Vue renders
```

### Admin Authentication

```
Admin → POST /api/auth/login { username, password }
→ Express: bcrypt.compare(password, process.env.ADMIN_PASSWORD_HASH)
→ jwt.sign({ username, role: 'admin' }, JWT_SECRET, { expiresIn: '24h' })
→ { token } returned to frontend
→ Pinia auth store: localStorage.setItem('admin_token', token)
→ All subsequent admin requests: Authorization: Bearer <token>
→ auth middleware: jwt.verify(token, JWT_SECRET)
```

### Image Upload

```
Admin form → multipart/form-data POST /api/products (with images)
→ Multer saves to /app/uploads/ (Docker volume: uploads_data)
→ Express returns { filename } in product.images JSON array
→ Frontend renders: /uploads/<filename>
→ Nginx serves /uploads/ → /app/uploads/ volume mount
```

## Key Design Decisions

**app.js vs server.js split** — Express configuration lives in `app.js` (no `listen()` call). `server.js` is the entry point that calls `app.listen()`. This lets Jest/Supertest import the app without starting the HTTP server or triggering database connection attempts.

**bcrypt hash in Docker** — Docker Compose v5 interpolates `$` in environment variable values, corrupting bcrypt hashes. The `.env.backend` file is mounted as a Docker volume (`/app/.env`) so Node's `dotenv` reads it directly; Docker never parses volume file contents.

**No checkout flow** — Products use an "Inquire Now" modal that composes a mailto link. This keeps the stack simple (no payment processing, no order tables) and fits the business model of a B2B equipment supplier.

**JSON columns for specs and images** — Product specifications (key-value pairs) and image file lists are stored as JSON. This avoids additional join tables for what is essentially variable-length metadata per product.
