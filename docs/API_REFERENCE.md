# API Reference

Base URL: `http://localhost:8080/api` (Docker) or `http://localhost:3000/api` (backend direct)

All protected endpoints require:
```
Authorization: Bearer <jwt_token>
```

---

## Authentication

### POST /api/auth/login

Authenticate as admin and receive a JWT token.

**Request**
```json
{
  "username": "admin",
  "password": "yourpassword"
}
```

**Response 200**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "username": "admin",
  "role": "admin"
}
```

**Response 401**
```json
{ "error": "Invalid credentials" }
```

---

### GET /api/auth/verify

Verify a JWT token is valid and not expired.

**Headers:** `Authorization: Bearer <token>`

**Response 200**
```json
{ "valid": true, "username": "admin", "role": "admin" }
```

**Response 401**
```json
{ "error": "No token provided" }
```

---

## Products

### GET /api/products

List products with optional filtering and pagination.

**Query Parameters**

| Param      | Type    | Default | Description                            |
|------------|---------|---------|----------------------------------------|
| `page`     | integer | 1       | Page number                            |
| `limit`    | integer | 12      | Items per page (max 100)               |
| `search`   | string  | —       | Full-text search on name/description   |
| `category` | string  | —       | Filter by category slug or ID          |
| `featured` | boolean | —       | `true` returns only featured products  |

**Response 200**
```json
{
  "products": [
    {
      "product_id": 1,
      "name": "LED High Bay Light 100W UFO",
      "description": "...",
      "specs": { "Power": "100W", "Lumens": "13000 lm" },
      "price": 2500.00,
      "images": ["led-high-bay-100w-ufo-1.jpg"],
      "category_id": 1,
      "category_name": "Lighting",
      "slug": "led-high-bay-100w-ufo",
      "featured": true,
      "stock": 50,
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2024-01-01T00:00:00.000Z"
    }
  ],
  "total": 24,
  "page": 1,
  "limit": 12,
  "pages": 2
}
```

---

### GET /api/products/:identifier

Get a single product by numeric ID or slug.

**Response 200** — single product object (same shape as list item)

**Response 404**
```json
{ "error": "Product not found" }
```

---

### POST /api/products 🔒

Create a new product.

**Content-Type:** `multipart/form-data` (when uploading images) or `application/json`

**Body Fields**

| Field         | Type    | Required | Description                          |
|---------------|---------|----------|--------------------------------------|
| `name`        | string  | ✅       | Product name                         |
| `category_id` | integer | ✅       | Category foreign key                 |
| `description` | string  | —        | Full product description             |
| `specs`       | JSON    | —        | Key-value specification pairs        |
| `price`       | decimal | —        | Price in PHP (default 0)             |
| `stock`       | integer | —        | Stock quantity (default 0)           |
| `featured`    | boolean | —        | Show in featured section             |
| `slug`        | string  | —        | Auto-generated from name if omitted  |
| `images`      | files   | —        | Image uploads (multipart only)       |

**Response 201** — newly created product object

**Response 400**
```json
{ "error": "Product name is required" }
```

---

### PUT /api/products/:id 🔒

Update an existing product. Same body as POST.

**Response 200** — updated product object

**Response 404**
```json
{ "error": "Product not found" }
```

---

### DELETE /api/products/:id 🔒

Delete a product permanently.

**Response 200**
```json
{ "message": "Product deleted successfully" }
```

**Response 404**
```json
{ "error": "Product not found" }
```

---

## Categories

### GET /api/categories

List all categories with product counts.

**Response 200**
```json
[
  {
    "category_id": 1,
    "name": "Lighting",
    "description": "LED and lighting solutions",
    "slug": "lighting",
    "product_count": 10
  }
]
```

---

### GET /api/categories/:identifier

Get a single category by numeric ID or slug.

**Response 404**
```json
{ "error": "Category not found" }
```

---

### POST /api/categories 🔒

Create a category.

```json
{
  "name": "Equipment",
  "description": "Industrial tools and machinery"
}
```

**Response 201** — created category object

**Response 400** — name missing

**Response 409** — duplicate name/slug

---

### PUT /api/categories/:id 🔒

Update a category. Same body as POST.

**Response 200** — updated category object

---

### DELETE /api/categories/:id 🔒

**Response 200**
```json
{ "message": "Category deleted successfully" }
```

---

## Site Content

### GET /api/site-content/:page

Get HTML content for a named page.

**Pages:** `about`, `contact`, `shipping`, `terms`

**Response 200**
```json
{
  "content_id": 1,
  "page_name": "about",
  "content_body": "<h1>About Us</h1><p>...</p>"
}
```

**Response 404**
```json
{ "error": "Page not found" }
```

---

### GET /api/site-content 🔒

List all page content records.

**Response 200** — array of content objects

---

### PUT /api/site-content/:page 🔒

Create or update content for a page. Upserts based on `page_name`.

```json
{ "content_body": "<h1>About EON Marketing</h1><p>...</p>" }
```

**Response 200** — updated content object

---

## Company Info

### GET /api/company-info

Get company information (public).

**Response 200**
```json
{
  "company_id": 1,
  "name": "EON Marketing and General Merchandise",
  "address": "San Juan, Metro Manila, Philippines",
  "phone": "+63 917 000 0000",
  "email": "eonmgm@gmail.com",
  "tagline": "Your One-Stop Shop for Equipment and Lighting Solutions",
  "logo_url": null
}
```

**Response 404** — company info not yet configured

---

### PUT /api/company-info 🔒

Create or update company info (upsert).

```json
{
  "name": "EON Marketing",
  "address": "San Juan, Metro Manila",
  "phone": "+63 917 000 0000",
  "email": "eonmgm@gmail.com",
  "tagline": "Quality Equipment & Lighting",
  "logo_url": "https://example.com/logo.png"
}
```

**Response 200** — updated company info object

---

## Social Links

### GET /api/social-links

Get active social media links (public).

**Response 200**
```json
[
  {
    "link_id": 1,
    "platform": "Facebook",
    "url": "https://facebook.com/eonmgm",
    "icon": "facebook",
    "active": 1,
    "sort_order": 1
  }
]
```

---

### GET /api/social-links/all 🔒

Get all social links including inactive ones.

---

### POST /api/social-links 🔒

```json
{
  "platform": "Instagram",
  "url": "https://instagram.com/eonmgm",
  "icon": "instagram",
  "active": 1,
  "sort_order": 2
}
```

**Response 201** — created link object

---

### PUT /api/social-links/:id 🔒

Update a social link. Same body as POST.

**Response 200** — updated link object

**Response 404** — link not found

---

### DELETE /api/social-links/:id 🔒

**Response 200**
```json
{ "message": "Social link deleted successfully" }
```

---

## SEO

### GET /api/seo

Get all SEO records (public).

**Response 200** — array of SEO objects

---

### GET /api/seo/:page

Get SEO data for a named page.

**Response 200**
```json
{
  "seo_id": 1,
  "page_name": "home",
  "meta_title": "EON Marketing – Equipment & Lighting",
  "meta_description": "Professional equipment and lighting products.",
  "keywords": ["equipment", "lighting", "industrial"],
  "og_image": null
}
```

**Response 404** — no SEO record for this page

---

### POST /api/seo 🔒

```json
{
  "page_name": "about",
  "meta_title": "About – EON Marketing",
  "meta_description": "Learn about EON Marketing.",
  "keywords": ["about", "company", "lighting"],
  "og_image": null
}
```

**Response 201** — created SEO object

**Response 409** — duplicate page_name

---

### PUT /api/seo/:id 🔒

Update SEO record. Same body as POST.

**Response 200** — updated SEO object

**Response 404** — record not found

---

### GET /api/seo/sitemap/xml

Generate and return an XML sitemap (public).

**Response 200** — `Content-Type: application/xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://yourdomain.com/</loc>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://yourdomain.com/products/led-high-bay-100w-ufo</loc>
    <lastmod>2024-01-01</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.8</priority>
  </url>
  ...
</urlset>
```

---

## Health Check

### GET /api/health

**Response 200**
```json
{ "status": "ok", "timestamp": "2024-01-01T00:00:00.000Z" }
```

---

## Error Responses

All errors follow this shape:

```json
{ "error": "Human-readable error message" }
```

| Status | Meaning                          |
|--------|----------------------------------|
| 400    | Bad request / validation failed  |
| 401    | Missing or invalid JWT token     |
| 403    | Forbidden (wrong role)           |
| 404    | Resource not found               |
| 409    | Conflict (e.g. duplicate slug)   |
| 500    | Internal server error            |
