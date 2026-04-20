const express = require('express');
const { pool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

router.get('/:page', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM site_content WHERE page_name = ?', [req.params.page]);
    if (!rows.length) return res.status(404).json({ error: 'Page not found' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch content' });
  }
});

router.put('/:page', authenticateToken, async (req, res) => {
  const { content_body } = req.body;
  try {
    const [existing] = await pool.query('SELECT * FROM site_content WHERE page_name = ?', [req.params.page]);
    if (existing.length) {
      await pool.query('UPDATE site_content SET content_body=? WHERE page_name=?', [content_body, req.params.page]);
    } else {
      await pool.query('INSERT INTO site_content (page_name, content_body) VALUES (?,?)', [req.params.page, content_body]);
    }
    const [rows] = await pool.query('SELECT * FROM site_content WHERE page_name = ?', [req.params.page]);
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update content' });
  }
});

router.get('/', authenticateToken, async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM site_content ORDER BY page_name ASC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch all content' });
  }
});

module.exports = router;
