const express = require('express');
const { pool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM seo ORDER BY page_name ASC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch SEO data' });
  }
});

router.get('/:page', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM seo WHERE page_name = ?', [req.params.page]);
    if (!rows.length) return res.status(404).json({ error: 'SEO record not found' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch SEO data' });
  }
});

router.post('/', authenticateToken, async (req, res) => {
  const { page_name, meta_title, meta_description, keywords, og_image } = req.body;
  try {
    const [result] = await pool.query(
      'INSERT INTO seo (page_name, meta_title, meta_description, keywords, og_image) VALUES (?,?,?,?,?)',
      [page_name, meta_title, meta_description, keywords ? JSON.stringify(keywords) : null, og_image]
    );
    const [rows] = await pool.query('SELECT * FROM seo WHERE seo_id=?', [result.insertId]);
    res.status(201).json(rows[0]);
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') return res.status(409).json({ error: 'SEO record for this page already exists' });
    res.status(500).json({ error: 'Failed to create SEO record' });
  }
});

router.put('/:id', authenticateToken, async (req, res) => {
  const { meta_title, meta_description, keywords, og_image, page_name } = req.body;
  try {
    await pool.query(
      'UPDATE seo SET page_name=?, meta_title=?, meta_description=?, keywords=?, og_image=? WHERE seo_id=?',
      [page_name, meta_title, meta_description, keywords ? JSON.stringify(keywords) : null, og_image, req.params.id]
    );
    const [rows] = await pool.query('SELECT * FROM seo WHERE seo_id=?', [req.params.id]);
    if (!rows.length) return res.status(404).json({ error: 'SEO record not found' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update SEO record' });
  }
});

router.get('/sitemap/xml', async (req, res) => {
  try {
    const [products] = await pool.query('SELECT slug, updated_at FROM products WHERE status="active"');
    const [categories] = await pool.query('SELECT slug FROM categories');
    const baseUrl = req.query.baseUrl || 'https://yoursite.com';

    const staticPages = ['', 'catalog', 'about', 'contact', 'shipping', 'terms'];
    let xml = `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n`;

    staticPages.forEach(page => {
      xml += `  <url><loc>${baseUrl}/${page}</loc><changefreq>monthly</changefreq></url>\n`;
    });
    categories.forEach(c => {
      xml += `  <url><loc>${baseUrl}/catalog?category=${c.slug}</loc><changefreq>weekly</changefreq></url>\n`;
    });
    products.forEach(p => {
      xml += `  <url><loc>${baseUrl}/catalog/${p.slug}</loc><lastmod>${new Date(p.updated_at).toISOString().split('T')[0]}</lastmod><changefreq>weekly</changefreq></url>\n`;
    });

    xml += `</urlset>`;
    res.set('Content-Type', 'application/xml');
    res.send(xml);
  } catch (err) {
    res.status(500).json({ error: 'Failed to generate sitemap' });
  }
});

module.exports = router;
