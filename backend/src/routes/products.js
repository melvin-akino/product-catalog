const express = require('express');
const { body, validationResult } = require('express-validator');
const { pool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

// Normalise specifications before storing: always string | null, never object.
// Guards against legacy callers sending a plain JS object which mysql2 would
// silently coerce to the literal string "[object Object]".
function normalizeSpecs(value) {
  if (value == null) return null;
  if (typeof value === 'string') return value.trim() || null;
  return JSON.stringify(value); // object/array fallback — shouldn't happen with WYSIWYG
}

// GET /api/products — client-facing with optional filters
router.get('/', async (req, res) => {
  try {
    const { category, search, featured, ids, sort, page = 1, limit = 12 } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);
    let where = ['p.status = "active"'];
    const params = [];

    if (ids) {
      const idList = ids.split(',').map(Number).filter(Boolean);
      if (idList.length) {
        where.push(`p.product_id IN (${idList.map(() => '?').join(',')})`);
        params.push(...idList);
      }
    }
    if (category) {
      where.push('c.slug = ?');
      params.push(category);
    }
    if (search) {
      where.push('(p.name LIKE ? OR p.description LIKE ?)');
      params.push(`%${search}%`, `%${search}%`);
    }
    if (featured === 'true') {
      where.push('p.featured = 1');
    }

    const whereClause = where.length ? `WHERE ${where.join(' AND ')}` : '';

    const baseOrder =
      sort === 'name_asc' ? 'p.name ASC' :
      sort === 'name_desc' ? 'p.name DESC' :
      'p.created_at DESC';
    // Always sort by category display_priority first (unless user picks a specific sort)
    const orderClause = (sort === 'name_asc' || sort === 'name_desc')
      ? baseOrder
      : `COALESCE(c.display_priority, 999) ASC, ${baseOrder}`;

    const [rows] = await pool.query(
      `SELECT p.product_id, p.name, p.brand, p.description, p.specifications, p.images,
              p.slug, p.featured, p.status, c.category_id, c.name AS category_name, c.slug AS category_slug
       FROM products p LEFT JOIN categories c ON p.category_id = c.category_id
       ${whereClause} ORDER BY ${orderClause} LIMIT ? OFFSET ?`,
      [...params, parseInt(limit), offset]
    );

    const [[{ total }]] = await pool.query(
      `SELECT COUNT(*) as total FROM products p LEFT JOIN categories c ON p.category_id = c.category_id ${whereClause}`,
      params
    );

    res.json({ products: rows, total, page: parseInt(page), limit: parseInt(limit) });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch products' });
  }
});

// GET /api/products/:id
// Accepts either a numeric product_id or a slug string.
// IMPORTANT: Do NOT combine both with OR on the same value — that can return
// the wrong row if MySQL resolves the OR against an unexpected index.
router.get('/:id', async (req, res) => {
  try {
    const idParam = req.params.id;
    const isNumeric = /^\d+$/.test(idParam);
    const [rows] = await pool.query(
      isNumeric
        ? `SELECT p.*, c.name AS category_name, c.slug AS category_slug
           FROM products p LEFT JOIN categories c ON p.category_id = c.category_id
           WHERE p.product_id = ?`
        : `SELECT p.*, c.name AS category_name, c.slug AS category_slug
           FROM products p LEFT JOIN categories c ON p.category_id = c.category_id
           WHERE p.slug = ?`,
      [idParam]
    );
    if (!rows.length) return res.status(404).json({ error: 'Product not found' });
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch product' });
  }
});

// POST /api/products — admin only
router.post(
  '/',
  authenticateToken,
  [
    body('name').trim().notEmpty().withMessage('Product name is required'),
    body('category_id').optional().isInt(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { name, description, specifications, images, category_id, featured } = req.body;
    const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '') + '-' + Date.now();

    try {
      const [result] = await pool.query(
        `INSERT INTO products (name, description, specifications, images, category_id, slug, featured)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          name,
          description || null,
          normalizeSpecs(specifications),
          images ? JSON.stringify(images) : JSON.stringify([]),
          category_id || null,
          slug,
          featured ? 1 : 0,
        ]
      );
      const [rows] = await pool.query('SELECT * FROM products WHERE product_id = ?', [result.insertId]);
      res.status(201).json(rows[0]);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Failed to create product' });
    }
  }
);

// PUT /api/products/:id — admin only
router.put('/:id', authenticateToken, async (req, res) => {
  const { name, description, specifications, images, category_id, featured, status } = req.body;
  try {
    await pool.query(
      `UPDATE products SET name=?, description=?, specifications=?, images=?, category_id=?, featured=?, status=?
       WHERE product_id = ?`,
      [
        name,
        description || null,
        normalizeSpecs(specifications),
        images ? JSON.stringify(images) : null,
        category_id || null,
        featured ? 1 : 0,
        status || 'active',
        req.params.id,
      ]
    );
    const [rows] = await pool.query('SELECT * FROM products WHERE product_id = ?', [req.params.id]);
    if (!rows.length) return res.status(404).json({ error: 'Product not found' });
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to update product' });
  }
});

// DELETE /api/products/:id — admin only
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const [result] = await pool.query('DELETE FROM products WHERE product_id = ?', [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Product not found' });
    res.json({ message: 'Product deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete product' });
  }
});

module.exports = router;
