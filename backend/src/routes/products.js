const express = require('express');
const { body, validationResult } = require('express-validator');
const { pool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

// GET /api/products — client-facing with optional filters
router.get('/', async (req, res) => {
  try {
    const { category, search, featured, page = 1, limit = 12 } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);
    let where = ['p.status = "active"'];
    const params = [];

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

    const [rows] = await pool.query(
      `SELECT p.product_id, p.name, p.description, p.specifications, p.images,
              p.slug, p.featured, c.category_id, c.name AS category_name, c.slug AS category_slug
       FROM products p LEFT JOIN categories c ON p.category_id = c.category_id
       ${whereClause} ORDER BY p.created_at DESC LIMIT ? OFFSET ?`,
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
router.get('/:id', async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT p.*, c.name AS category_name, c.slug AS category_slug
       FROM products p LEFT JOIN categories c ON p.category_id = c.category_id
       WHERE p.product_id = ? OR p.slug = ?`,
      [req.params.id, req.params.id]
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
          specifications ? JSON.stringify(specifications) : null,
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
        specifications ? JSON.stringify(specifications) : null,
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
