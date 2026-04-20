# EON Marketing — Product Catalog

A full-stack equipment and lighting product catalog with a black & green theme.

## Stack
- **Frontend**: Vue 3 + Vite + Pinia + Vue Router
- **Backend**: Node.js + Express
- **Database**: MySQL

---

## 🐳 Docker Quick Start (Recommended)

### One command — that's it

```bash
bash setup.sh
```

The script will:
1. Check Docker is installed and running
2. Ask for admin username, password, and app port (or use defaults)
3. Generate a secure bcrypt password hash automatically
4. Build all Docker images (backend Node.js + frontend Nginx + MySQL)
5. Start all services with `docker compose up -d`
6. Wait for each service to be healthy
7. Open the site in your browser

**Default credentials** (you can change them when prompted):
| Setting | Default |
|---------|---------|
| Admin username | `admin` |
| Admin password | `Admin@1234` |
| App port | `8080` |

**Access URLs after setup:**
- Store: `http://localhost:8080`
- Admin: `http://localhost:8080/admin/login`
- API:   `http://localhost:3000/api/health`

**Useful Docker commands:**
```bash
docker compose logs -f           # Stream all logs
docker compose stop              # Stop without deleting data
docker compose start             # Restart stopped containers
bash setup.sh --reset            # Wipe database and start fresh
bash setup.sh --force            # Change credentials and rebuild
```

---

## Manual (Non-Docker) Quick Start

### 1. Database
```bash
mysql -u root -p < backend/database/schema.sql
```

### 2. Backend
```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your DB credentials and generate an admin password hash:
node -e "const b=require('bcryptjs');console.log(b.hashSync('yourpassword',10))"
# Paste the output as ADMIN_PASSWORD_HASH in .env
npm run dev
```

### 3. Frontend
```bash
cd frontend
npm install
npm run dev
```

- Client site: http://localhost:5173
- Admin panel: http://localhost:5173/admin/login
- API: http://localhost:3000/api

---

## Features

### Client Site
- Hero section with animated green gradient
- Product catalog with filtering, search, and pagination
- Image gallery with lightbox and zoom
- Product detail with specifications table
- "Inquire Now" modal (email / phone / WhatsApp)
- Static pages: About, Contact, Shipping, Terms
- Social media links in footer
- Fully responsive (mobile + desktop)

### Admin Dashboard
- JWT-secured login
- Product CRUD (images as URL arrays, specs as JSON)
- Category management
- HTML content editor for static pages
- Company info editor
- Social media link manager
- SEO meta tags per page + sitemap generator

---

## API Reference

### Public Endpoints
| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/products` | List products (`?search=&category=&featured=&page=&limit=`) |
| GET | `/api/products/:id` | Single product by ID or slug |
| GET | `/api/categories` | All categories with product count |
| GET | `/api/site-content/:page` | Page content (about, contact, shipping, terms) |
| GET | `/api/company-info` | Company details |
| GET | `/api/social-links` | Active social links |
| GET | `/api/seo/:page` | SEO metadata for a page |
| GET | `/api/seo/sitemap/xml` | XML sitemap |

### Admin Endpoints (JWT required)
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/auth/login` | Get JWT token |
| POST | `/api/products` | Create product |
| PUT | `/api/products/:id` | Update product |
| DELETE | `/api/products/:id` | Delete product |
| POST | `/api/categories` | Create category |
| PUT | `/api/categories/:id` | Update category |
| DELETE | `/api/categories/:id` | Delete category |
| PUT | `/api/site-content/:page` | Update page content |
| PUT | `/api/company-info` | Update company info |
| POST | `/api/social-links` | Add social link |
| PUT | `/api/social-links/:id` | Update social link |
| DELETE | `/api/social-links/:id` | Delete social link |
| POST | `/api/seo` | Create SEO record |
| PUT | `/api/seo/:id` | Update SEO record |

---

## Database Schema

```
Categories ──< Products
SiteContent (independent)
CompanyInfo (independent)
SocialMediaLinks (independent)
SEO (independent)
```

---

## Environment Variables

| Variable | Description |
|----------|-------------|
| `PORT` | Server port (default 3000) |
| `DB_HOST` | MySQL host |
| `DB_PORT` | MySQL port |
| `DB_USER` | MySQL user |
| `DB_PASSWORD` | MySQL password |
| `DB_NAME` | Database name |
| `JWT_SECRET` | Secret key for JWT |
| `JWT_EXPIRES_IN` | Token expiry (e.g. `24h`) |
| `ADMIN_USERNAME` | Admin login username |
| `ADMIN_PASSWORD_HASH` | bcrypt hash of admin password |

---

## Color Palette

| Variable | Value | Usage |
|----------|-------|-------|
| `--bg-primary` | `#0a0a0a` | Page background |
| `--bg-secondary` | `#111111` | Cards, sidebars |
| `--green-primary` | `#00e676` | Accents, buttons, links |
| `--green-secondary` | `#00c853` | Hover states |
| `--text-primary` | `#f5f5f5` | Headings |
| `--text-secondary` | `#b0b0b0` | Body text |
