require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const { testConnection } = require('./config/database');

const authRoutes = require('./routes/auth');
const productsRoutes = require('./routes/products');
const categoriesRoutes = require('./routes/categories');
const siteContentRoutes = require('./routes/siteContent');
const companyInfoRoutes = require('./routes/companyInfo');
const socialLinksRoutes = require('./routes/socialLinks');
const seoRoutes = require('./routes/seo');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors({ origin: '*', credentials: true }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

app.use('/api/auth', authRoutes);
app.use('/api/products', productsRoutes);
app.use('/api/categories', categoriesRoutes);
app.use('/api/site-content', siteContentRoutes);
app.use('/api/company-info', companyInfoRoutes);
app.use('/api/social-links', socialLinksRoutes);
app.use('/api/seo', seoRoutes);

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, async () => {
  await testConnection();
  console.log(`✓ Server running on http://localhost:${PORT}`);
});
