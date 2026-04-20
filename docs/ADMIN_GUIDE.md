# Admin Panel Guide

The admin panel is accessible at `http://localhost:8080/admin` (Docker) or the deployed URL `/admin`.

---

## Logging In

1. Navigate to `/admin/login`
2. Enter the admin credentials configured in `.env.backend`:
   - Username: value of `ADMIN_USERNAME`
   - Password: value of `ADMIN_PASSWORD` (plain text, hashed on setup)
3. Click **Login**

Your session token is valid for 24 hours. If you are redirected to the login page, your session has expired.

---

## Navigation

The sidebar on the left contains all admin sections. Click **‹** to collapse it for more workspace. On mobile, use the **☰** button in the top bar to toggle the sidebar.

| Section        | Purpose                                          |
|----------------|--------------------------------------------------|
| Dashboard      | Overview stats and quick links                   |
| Products       | Create, edit, delete, and search products        |
| Categories     | Manage product categories                        |
| Content Editor | Edit About, Contact, Shipping, Terms pages       |
| Company Info   | Update business name, address, contact details   |
| Social Links   | Manage social media links shown in the footer    |
| SEO Manager    | Set meta tags and view sitemap                   |

Click the **?** button in the top-right corner of any page to open the contextual help panel for that section.

---

## Products

### Adding a Product

1. Go to **Products → + Add Product**
2. Fill in required fields:
   - **Name** (required)
   - **Category** (required — select from dropdown)
3. Fill in optional fields:
   - **Description** — supports plain text, displayed on the product page
   - **Price** — in Philippine Peso (PHP)
   - **Stock** — quantity available
   - **Featured** — check to show in the homepage featured section
   - **Slug** — auto-generated from name; change only if needed
4. Add **Specifications** — click **+ Add Spec**, enter a label and value (e.g., Power → 100W)
5. Upload **Images** — drag and drop or click to browse. First image is the catalog thumbnail
6. Click **Save Product**

### Editing a Product

Click the **✏️** icon in the product list row. The same form opens pre-filled with current data. Make changes and click **Save**.

### Deleting a Product

Click **🗑️** in the product row. Confirm the deletion. This action is permanent.

### Searching and Filtering

- Use the **search bar** at the top of the products list to filter by name or description
- Use the **category dropdown** to show only products in a specific category

---

## Categories

### Adding a Category

1. Go to **Categories → + Add Category**
2. Enter a **Name** (required) and optional **Description**
3. The slug is auto-generated. Edit it manually if needed
4. Click **Save**

### Deleting a Category

Categories with products assigned cannot be deleted until those products are reassigned or deleted. The panel will show a warning.

---

## Content Editor

### Editing a Page

1. Go to **Content Editor**
2. Select a page from the list: **About**, **Contact**, **Shipping**, **Terms**
3. Edit the HTML in the text area
4. Click **Save**

The content body accepts standard HTML. Common tags:

```html
<h2>Section Heading</h2>
<p>Paragraph text with <strong>bold</strong> and <em>italic</em>.</p>
<ul>
  <li>Bullet point</li>
</ul>
<a href="mailto:eonmgm@gmail.com">Contact us</a>
```

To preview, click **View Site** at the bottom of the sidebar and navigate to the page.

---

## Company Info

1. Go to **Company Info**
2. Update any fields:
   - **Company Name** — appears in navbar and footer
   - **Address** — shown in footer and Contact page
   - **Phone** — shown in footer and Contact page
   - **Email** — shown in footer and Contact page
   - **Tagline** — marketing tagline shown below the logo
   - **Logo URL** — full URL to your logo image
3. Click **Save**

---

## Social Links

### Adding a Link

1. Go to **Social Links → + Add Link**
2. Fill in:
   - **Platform** — display name (e.g., Facebook, Instagram)
   - **URL** — full social media URL (e.g., `https://facebook.com/eonmgm`)
   - **Icon** — icon identifier (e.g., `facebook`, `instagram`, `twitter`)
   - **Active** — toggle to show/hide on the public site
   - **Sort Order** — integer controlling display order (lower = first)
3. Click **Save**

### Hiding a Link Temporarily

Toggle the **Active** switch to off. The link is hidden from the public site but remains in the database.

---

## SEO Manager

### Setting Up a Page's SEO

1. Go to **SEO Manager → + Add SEO Record**
2. Set **Page Name** — the internal page slug (e.g., `home`, `about`, `catalog`)
3. Fill in:
   - **Meta Title** — shown in browser tab and search results (50–60 chars recommended)
   - **Meta Description** — search snippet (120–160 chars recommended)
   - **Keywords** — comma-separated keywords
   - **OG Image URL** — image shown when shared on social media (1200×630 px)
4. Click **Save**

### Submitting Your Sitemap to Google

The sitemap is generated automatically at:
```
https://yourdomain.com/api/seo/sitemap/xml
```

Submit this URL in [Google Search Console](https://search.google.com/search-console) under **Sitemaps**.

---

## Help System

Each admin section has a contextual help panel. Click the **?** button (top-right corner) to open it. The panel includes:

- Step-by-step instructions for the current section
- Frequently asked questions with expandable answers
- A search bar to find help topics across all sections
- A link to contact support via email

---

## Logging Out

Click **🚪 Logout** at the bottom of the sidebar. You are redirected to the login page and your token is cleared from local storage.

---

## Troubleshooting

| Problem                           | Solution                                                    |
|-----------------------------------|-------------------------------------------------------------|
| Login fails with correct password | Check `ADMIN_USERNAME` and `ADMIN_PASSWORD_HASH` in `.env.backend` |
| Images not uploading              | Verify the `uploads_data` Docker volume is mounted correctly |
| Changes not appearing on site     | Hard refresh (Ctrl+Shift+R) to clear browser cache          |
| Session expires too quickly       | JWT tokens last 24 hours; this is by design for security    |
| Sitemap not updating              | The sitemap is generated live from the database; no cache   |
