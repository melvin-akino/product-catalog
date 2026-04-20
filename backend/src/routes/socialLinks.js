const express = require('express');
const { pool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM social_media_links WHERE active=1 ORDER BY sort_order ASC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch social links' });
  }
});

router.get('/all', authenticateToken, async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM social_media_links ORDER BY sort_order ASC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch social links' });
  }
});

router.post('/', authenticateToken, async (req, res) => {
  const { platform, url, icon, active, sort_order } = req.body;
  try {
    const [result] = await pool.query(
      'INSERT INTO social_media_links (platform, url, icon, active, sort_order) VALUES (?,?,?,?,?)',
      [platform, url, icon || platform.toLowerCase(), active ?? 1, sort_order || 0]
    );
    const [rows] = await pool.query('SELECT * FROM social_media_links WHERE link_id=?', [result.insertId]);
    res.status(201).json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to create social link' });
  }
});

router.put('/:id', authenticateToken, async (req, res) => {
  const { platform, url, icon, active, sort_order } = req.body;
  try {
    await pool.query(
      'UPDATE social_media_links SET platform=?, url=?, icon=?, active=?, sort_order=? WHERE link_id=?',
      [platform, url, icon, active ?? 1, sort_order || 0, req.params.id]
    );
    const [rows] = await pool.query('SELECT * FROM social_media_links WHERE link_id=?', [req.params.id]);
    if (!rows.length) return res.status(404).json({ error: 'Link not found' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update social link' });
  }
});

router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    await pool.query('DELETE FROM social_media_links WHERE link_id=?', [req.params.id]);
    res.json({ message: 'Social link deleted' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete social link' });
  }
});

module.exports = router;
