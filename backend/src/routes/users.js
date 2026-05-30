const express = require('express');
const bcrypt = require('bcryptjs');
const { body, validationResult } = require('express-validator');
const router = express.Router();
const pool = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

router.use(authenticateToken);

// GET /api/users — list all
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query(
      'SELECT user_id, username, email, role, status, created_at, updated_at FROM users ORDER BY created_at DESC'
    );
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

// POST /api/users — create
router.post(
  '/',
  [
    body('username').trim().notEmpty().withMessage('Username is required'),
    body('email').isEmail().withMessage('Valid email is required').normalizeEmail(),
    body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
    body('role').isIn(['admin', 'viewer']).withMessage('Role must be admin or viewer'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { username, email, password, role } = req.body;
    try {
      const hash = await bcrypt.hash(password, 10);
      const [result] = await pool.query(
        'INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, ?)',
        [username, email, hash, role]
      );
      res.status(201).json({ user_id: result.insertId, username, email, role, status: 'active' });
    } catch (err) {
      if (err.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({ error: 'Username or email already exists' });
      }
      console.error(err);
      res.status(500).json({ error: 'Failed to create user' });
    }
  }
);

// PUT /api/users/:id — update
router.put(
  '/:id',
  [
    body('username').trim().notEmpty().withMessage('Username is required'),
    body('email').isEmail().withMessage('Valid email is required').normalizeEmail(),
    body('role').isIn(['admin', 'viewer']).withMessage('Role must be admin or viewer'),
    body('status').isIn(['active', 'inactive']).withMessage('Status must be active or inactive'),
    body('password').optional({ nullable: true, checkFalsy: true })
      .isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

    const { username, email, role, status, password } = req.body;
    const { id } = req.params;

    try {
      if (password) {
        const hash = await bcrypt.hash(password, 10);
        await pool.query(
          'UPDATE users SET username=?, email=?, role=?, status=?, password=? WHERE user_id=?',
          [username, email, role, status, hash, id]
        );
      } else {
        await pool.query(
          'UPDATE users SET username=?, email=?, role=?, status=? WHERE user_id=?',
          [username, email, role, status, id]
        );
      }
      const [rows] = await pool.query(
        'SELECT user_id, username, email, role, status, created_at, updated_at FROM users WHERE user_id=?',
        [id]
      );
      if (!rows.length) return res.status(404).json({ error: 'User not found' });
      res.json(rows[0]);
    } catch (err) {
      if (err.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({ error: 'Username or email already exists' });
      }
      console.error(err);
      res.status(500).json({ error: 'Failed to update user' });
    }
  }
);

// DELETE /api/users/:id
router.delete('/:id', async (req, res) => {
  try {
    const [result] = await pool.query('DELETE FROM users WHERE user_id=?', [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ error: 'User not found' });
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to delete user' });
  }
});

module.exports = router;
