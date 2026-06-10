# API Contracts

Base path: `/api`
Auth header: `Authorization: Bearer <jwt>` (required on all admin routes)
Content-Type: `application/json`

---

## Auth

### POST /api/auth/login
**Auth:** None
**Body:** `{ username: string, password: string }`
**Response 200:** `{ token: string, user: { user_id, username, role } }`
**Response 401:** `{ error: "Invalid credentials" }`

### GET /api/auth/me
**Auth:** Required
**Response 200:** `{ user_id, username, role, status }`

---

## Products

### GET /api/products
**Auth:** None
**Query:** `limit`, `offset`, `search`, `category_id`, `featured`
**Response 200:** `{ products: Product[], total: number }`

### GET /api/products/:id
**Auth:** None
**Response 200:** `Product`
**Response 404:** `{ error: "Product not found" }`

### POST /api/products
**Auth:** Admin
**Body:** `ProductInput`
**Response 201:** `Product`

### PUT /api/products/:id
**Auth:** Admin
**Body:** `ProductInput`
**Response 200:** `Product`

### DELETE /api/products/:id
**Auth:** Admin
**Response 204:** (empty)

#### Product type
```
Product {
  product_id: number
  name: string
  description: string | null
  specifications: string | null   // HTML string (Quill output) or null
  images: string[]                // JSON array of URLs
  category_id: number | null
  slug: string
  featured: 0 | 1
  status: "active" | "inactive"
  created_at: string
  updated_at: string
}
```

#### ProductInput type
```
ProductInput {
  name: string           // required
  description?: string
  specifications?: string  // HTML string from WYSIWYG editor
  images?: string[]
  category_id?: number
  featured?: boolean
  status?: "active" | "inactive"
}
```

---

## Categories

### GET /api/categories
**Auth:** None
**Response 200:** `Category[]`

### POST /api/categories
**Auth:** Admin
**Body:** `{ name: string }`
**Response 201:** `Category`

### PUT /api/categories/:id
**Auth:** Admin
**Body:** `{ name: string }`
**Response 200:** `Category`

### DELETE /api/categories/:id
**Auth:** Admin
**Response 204:** (empty)

#### Category type
```
Category { category_id: number, name: string, slug: string }
```

---

## Users

### GET /api/users
**Auth:** Admin
**Response 200:** `User[]`

### POST /api/users
**Auth:** Admin
**Body:** `{ username, email, password, role, status }`
**Response 201:** `User`
**Response 409:** `{ error: "Username or email already exists" }`

### PUT /api/users/:id
**Auth:** Admin
**Body:** partial `User` fields
**Response 200:** `User`

### DELETE /api/users/:id
**Auth:** Admin
**Response 204:** (empty)

#### User type
```
User {
  user_id: number
  username: string
  email: string
  role: "admin" | "viewer"
  status: "active" | "inactive"
  created_at: string
}
```
Password is never returned in responses.

---

## Uploads

### POST /api/upload/images
**Auth:** Admin
**Content-Type:** `multipart/form-data`
**Field:** `images` (multiple files, max 5 MB each, JPG/PNG/WebP)
**Response 200:** `{ urls: string[] }` — paths like `/uploads/filename.jpg`

---

## Company Info

### GET /api/company
**Auth:** None
**Response 200:** `CompanyInfo`

### PUT /api/company
**Auth:** Admin
**Body:** partial `CompanyInfo` fields
**Response 200:** `CompanyInfo`

#### CompanyInfo type
```
CompanyInfo {
  company_id: number
  name: string
  tagline: string | null
  description: string | null
  email: string | null
  phone: string | null
  address: string | null
  facebook_url: string | null
  logo_url: string | null
}
```

---

## Site Settings / SEO

### GET /api/settings
**Auth:** None
**Response 200:** `SiteSettings`

### PUT /api/settings
**Auth:** Admin
**Body:** partial `SiteSettings`
**Response 200:** `SiteSettings`

---

## Health

### GET /api/health
**Auth:** None
**Response 200:** `{ status: "ok", db: "connected" }`

---

## Error Envelope

All errors follow:
```
{ error: string, details?: string[] }
```
HTTP status codes: 400 (validation), 401 (unauthenticated), 403 (forbidden), 404 (not found), 409 (conflict), 500 (server error).
