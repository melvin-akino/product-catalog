const express = require('express');
const { Resend } = require('resend');
const rateLimit = require('express-rate-limit');
const { pool } = require('../config/database');

const router = express.Router();

// Instantiated lazily so missing key doesn't crash startup
let _resend = null;
function getResend() {
  if (!_resend) _resend = new Resend(process.env.RESEND_API_KEY);
  return _resend;
}

const contactLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 5,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many messages sent. Please try again in an hour.' },
});

router.post('/', contactLimiter, async (req, res) => {
  const { name, email, subject, message, honeypot } = req.body;

  // Honeypot — bots fill hidden fields, humans don't
  if (honeypot) return res.status(200).json({ ok: true });

  if (!name?.trim() || !email?.trim() || !message?.trim()) {
    return res.status(400).json({ error: 'Name, email, and message are required.' });
  }

  // Basic email format check
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return res.status(400).json({ error: 'Invalid email address.' });
  }

  // Fetch recipient from company_info
  let toEmail = process.env.CONTACT_FALLBACK_EMAIL || 'info@eonmarketing.com';
  let companyName = 'Eon Marketing';
  try {
    const [rows] = await pool.query('SELECT email, name FROM company_info LIMIT 1');
    if (rows.length && rows[0].email) toEmail = rows[0].email;
    if (rows.length && rows[0].name) companyName = rows[0].name;
  } catch {}

  const fromDomain = process.env.RESEND_FROM_DOMAIN;
  const fromAddress = fromDomain
    ? `${companyName} Contact Form <noreply@${fromDomain}>`
    : `${companyName} Contact Form <onboarding@resend.dev>`;

  try {
    await getResend().emails.send({
      from: fromAddress,
      to: toEmail,
      reply_to: email,
      subject: subject?.trim() || `New inquiry from ${name}`,
      html: `
        <div style="font-family:sans-serif;max-width:600px;margin:0 auto;padding:24px;background:#f9f9f9;border-radius:8px;">
          <h2 style="color:#1a1a1a;border-bottom:2px solid #22c55e;padding-bottom:12px;">New Contact Form Inquiry</h2>
          <table style="width:100%;border-collapse:collapse;margin:16px 0;">
            <tr><td style="padding:8px 0;color:#555;width:120px;"><strong>From</strong></td><td style="padding:8px 0;color:#1a1a1a;">${escHtml(name)}</td></tr>
            <tr><td style="padding:8px 0;color:#555;"><strong>Email</strong></td><td style="padding:8px 0;"><a href="mailto:${escHtml(email)}" style="color:#22c55e;">${escHtml(email)}</a></td></tr>
            ${subject?.trim() ? `<tr><td style="padding:8px 0;color:#555;"><strong>Subject</strong></td><td style="padding:8px 0;color:#1a1a1a;">${escHtml(subject)}</td></tr>` : ''}
          </table>
          <div style="background:#fff;border:1px solid #e5e5e5;border-radius:6px;padding:16px;margin-top:8px;">
            <p style="margin:0;color:#1a1a1a;line-height:1.7;white-space:pre-wrap;">${escHtml(message)}</p>
          </div>
          <p style="margin-top:20px;font-size:12px;color:#999;">Sent via the Contact form on your website. Reply directly to this email to respond to ${escHtml(name)}.</p>
        </div>
      `,
    });

    res.json({ ok: true });
  } catch (err) {
    console.error('Resend error:', err);
    res.status(500).json({ error: 'Failed to send message. Please try again later.' });
  }
});

function escHtml(str) {
  return String(str ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

module.exports = router;
