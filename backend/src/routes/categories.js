const express = require('express');
const { body, validationResult } = require('express-validator');
const { pool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT c.*, COUNT(p.product_id) AS product_count
       FROM categories c LEFT JOIN products p ON c.category_id = p.category_id AND p.status = 'active'
       GROUP BY c.category_id ORDER BY c.name ASC`
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch categories' });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM categories WHERE category_id = ? OR slug = ?', [req.params.id, req.params.id]);
    if (!rows.length) return res.status(404).json({ error: 'Category not found' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch category' });
  }
});

router.post(
  '/',
  authenticateToken,
  [body('name').trim().notEmpty().withMessage('Category name is required')],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { name, description } = req.body;
    const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');

    try {
      const [result] = await pool.query(
        'INSERT INTO categories (name, description, slug) VALUES (?, ?, ?)',
        [name, description || null, slug]
      );
      const [rows] = await pool.query('SELECT * FROM categories WHERE category_id = ?', [result.insertId]);
      res.status(201).json(rows[0]);
    } catch (err) {
      if (err.code === 'ER_DUP_ENTRY') return res.status(409).json({ error: 'Category already exists' });
      res.status(500).json({ error: 'Failed to create category' });
    }
  }
);

router.put('/:id', authenticateToken, async (req, res) => {
  const { name, description } = req.body;
  try {
    await pool.query('UPDATE categories SET name=?, description=? WHERE category_id=?', [name, description || null, req.params.id]);
    const [rows] = await pool.query('SELECT * FROM categories WHERE category_id = ?', [req.params.id]);
    if (!rows.length) return res.status(404).json({ error: 'Category not found' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update category' });
  }
});

router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const [result] = await pool.query('DELETE FROM categories WHERE category_id = ?', [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Category not found' });
    res.json({ message: 'Category deleted' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete category' });
  }
});

module.exports = router;
