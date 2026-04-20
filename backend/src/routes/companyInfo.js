const express = require('express');
const { pool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM company_info LIMIT 1');
    if (!rows.length) return res.status(404).json({ error: 'Company info not found' });
    const row = rows[0];
    // Resolve which logo is active so the frontend doesn't have to
    row.logo_active = row.logo_source === 'upload' ? (row.logo_upload || row.logo_url) : (row.logo_url || row.logo_upload);
    res.json(row);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch company info' });
  }
});

router.put('/', authenticateToken, async (req, res) => {
  const { name, address, phone, email, tagline, logo_url, logo_upload, logo_source } = req.body;
  const source = ['url', 'upload'].includes(logo_source) ? logo_source : 'url';
  try {
    const [existing] = await pool.query('SELECT * FROM company_info LIMIT 1');
    if (existing.length) {
      await pool.query(
        'UPDATE company_info SET name=?, address=?, phone=?, email=?, tagline=?, logo_url=?, logo_upload=?, logo_source=? WHERE company_id=?',
        [name, address, phone, email, tagline, logo_url || null, logo_upload || null, source, existing[0].company_id]
      );
    } else {
      await pool.query(
        'INSERT INTO company_info (name, address, phone, email, tagline, logo_url, logo_upload, logo_source) VALUES (?,?,?,?,?,?,?,?)',
        [name, address, phone, email, tagline, logo_url || null, logo_upload || null, source]
      );
    }
    const [rows] = await pool.query('SELECT * FROM company_info LIMIT 1');
    const row = rows[0];
    row.logo_active = row.logo_source === 'upload' ? (row.logo_upload || row.logo_url) : (row.logo_url || row.logo_upload);
    res.json(row);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update company info' });
  }
});

module.exports = router;
