const express = require('express');
const { pool } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM company_info LIMIT 1');
    if (!rows.length) return res.status(404).json({ error: 'Company info not found' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch company info' });
  }
});

router.put('/', authenticateToken, async (req, res) => {
  const { name, address, phone, email, tagline, logo_url } = req.body;
  try {
    const [existing] = await pool.query('SELECT * FROM company_info LIMIT 1');
    if (existing.length) {
      await pool.query(
        'UPDATE company_info SET name=?, address=?, phone=?, email=?, tagline=?, logo_url=? WHERE company_id=?',
        [name, address, phone, email, tagline, logo_url, existing[0].company_id]
      );
    } else {
      await pool.query(
        'INSERT INTO company_info (name, address, phone, email, tagline, logo_url) VALUES (?,?,?,?,?,?)',
        [name, address, phone, email, tagline, logo_url]
      );
    }
    const [rows] = await pool.query('SELECT * FROM company_info LIMIT 1');
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update company info' });
  }
});

module.exports = router;
