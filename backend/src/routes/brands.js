const express = require('express');
const { pool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

// Public — active brands only
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT brand_id, name, logo_url, website_url, sort_order FROM trusted_brands WHERE active = 1 ORDER BY sort_order ASC, name ASC'
    );
    res.json(rows);
  } catch {
    res.status(500).json({ error: 'Failed to fetch brands' });
  }
});

// Admin — all brands
router.get('/all', authenticateToken, async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT * FROM trusted_brands ORDER BY sort_order ASC, name ASC'
    );
    res.json(rows);
  } catch {
    res.status(500).json({ error: 'Failed to fetch brands' });
  }
});

// Create
router.post('/', authenticateToken, async (req, res) => {
  const { name, logo_url, website_url, sort_order, active } = req.body;
  if (!name?.trim()) return res.status(400).json({ error: 'Name is required.' });
  try {
    const [result] = await pool.query(
      'INSERT INTO trusted_brands (name, logo_url, website_url, sort_order, active) VALUES (?, ?, ?, ?, ?)',
      [name.trim(), logo_url || null, website_url || null, sort_order ?? 0, active ? 1 : 0]
    );
    const [rows] = await pool.query('SELECT * FROM trusted_brands WHERE brand_id = ?', [result.insertId]);
    res.status(201).json(rows[0]);
  } catch {
    res.status(500).json({ error: 'Failed to create brand' });
  }
});

// Update
router.put('/:id', authenticateToken, async (req, res) => {
  const { name, logo_url, website_url, sort_order, active } = req.body;
  if (!name?.trim()) return res.status(400).json({ error: 'Name is required.' });
  try {
    await pool.query(
      'UPDATE trusted_brands SET name=?, logo_url=?, website_url=?, sort_order=?, active=? WHERE brand_id=?',
      [name.trim(), logo_url || null, website_url || null, sort_order ?? 0, active ? 1 : 0, req.params.id]
    );
    const [rows] = await pool.query('SELECT * FROM trusted_brands WHERE brand_id = ?', [req.params.id]);
    if (!rows.length) return res.status(404).json({ error: 'Brand not found' });
    res.json(rows[0]);
  } catch {
    res.status(500).json({ error: 'Failed to update brand' });
  }
});

// Delete
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    await pool.query('DELETE FROM trusted_brands WHERE brand_id = ?', [req.params.id]);
    res.json({ ok: true });
  } catch {
    res.status(500).json({ error: 'Failed to delete brand' });
  }
});

module.exports = router;
