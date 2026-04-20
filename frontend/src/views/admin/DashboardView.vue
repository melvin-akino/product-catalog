<template>
  <div class="dashboard">
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon">📦</div>
        <div class="stat-info">
          <div class="stat-value">{{ stats.products }}</div>
          <div class="stat-label">Total Products</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">🏷️</div>
        <div class="stat-info">
          <div class="stat-value">{{ stats.categories }}</div>
          <div class="stat-label">Categories</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">⭐</div>
        <div class="stat-info">
          <div class="stat-value">{{ stats.featured }}</div>
          <div class="stat-label">Featured</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">🔗</div>
        <div class="stat-info">
          <div class="stat-value">{{ stats.social }}</div>
          <div class="stat-label">Social Links</div>
        </div>
      </div>
    </div>

    <div class="dashboard-grid">
      <div class="dash-section">
        <div class="dash-header">
          <h3>Recent Products</h3>
          <RouterLink to="/admin/products" class="dash-link">View all →</RouterLink>
        </div>
        <div v-if="loading" class="spinner"></div>
        <div v-else class="table-wrap">
          <table>
            <thead><tr><th>Name</th><th>Category</th><th>Status</th><th>Action</th></tr></thead>
            <tbody>
              <tr v-for="p in recentProducts" :key="p.product_id">
                <td>{{ p.name }}</td>
                <td><span class="text-muted">{{ p.category_name || '—' }}</span></td>
                <td><span class="badge" :class="p.status === 'active' ? 'badge-green' : 'badge-muted'">{{ p.status }}</span></td>
                <td><RouterLink :to="`/catalog/${p.slug}`" target="_blank" class="dash-link" style="font-size:0.8rem;">Preview</RouterLink></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="dash-section">
        <h3>Quick Actions</h3>
        <div class="quick-actions">
          <RouterLink v-for="a in quickActions" :key="a.to" :to="a.to" class="qa-card">
            <span class="qa-icon">{{ a.icon }}</span>
            <span class="qa-label">{{ a.label }}</span>
          </RouterLink>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { RouterLink } from 'vue-router';
import { productsApi, categoriesApi, socialApi } from '@/api/index';

const loading = ref(true);
const recentProducts = ref([]);
const stats = ref({ products: 0, categories: 0, featured: 0, social: 0 });

const quickActions = [
  { to: '/admin/products', icon: '➕', label: 'Add Product' },
  { to: '/admin/categories', icon: '🏷️', label: 'Manage Categories' },
  { to: '/admin/content', icon: '📝', label: 'Edit Content' },
  { to: '/admin/seo', icon: '🔍', label: 'SEO Settings' },
  { to: '/admin/social', icon: '🔗', label: 'Social Links' },
  { to: '/admin/company', icon: '🏢', label: 'Company Info' },
];

onMounted(async () => {
  try {
    const [prod, cats, feat, social] = await Promise.all([
      productsApi.getAll({ limit: 8 }),
      categoriesApi.getAll(),
      productsApi.getAll({ featured: true, limit: 1 }),
      socialApi.getAll(),
    ]);
    recentProducts.value = prod.data.products;
    stats.value = {
      products: prod.data.total,
      categories: cats.data.length,
      featured: feat.data.total,
      social: social.data.length,
    };
  } catch {}
  loading.value = false;
});
</script>

<style scoped>
.stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 1.25rem; margin-bottom: 2rem; }
.stat-card {
  background: var(--bg-card); border: 1px solid var(--border);
  border-radius: var(--radius-lg); padding: 1.5rem;
  display: flex; align-items: center; gap: 1rem;
  transition: all 0.2s;
}
.stat-card:hover { border-color: var(--green-border); box-shadow: var(--shadow-green); }
.stat-icon { font-size: 2rem; }
.stat-value { font-size: 1.75rem; font-weight: 800; color: var(--green-primary); }
.stat-label { font-size: 0.8rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.06em; }
.dashboard-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 1.5rem; }
.dash-section { background: var(--bg-card); border: 1px solid var(--border); border-radius: var(--radius-lg); padding: 1.5rem; }
.dash-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; }
.dash-header h3 { font-size: 1rem; }
.dash-link { color: var(--green-primary); font-size: 0.875rem; }
.dash-section > h3 { margin-bottom: 1rem; font-size: 1rem; }
.badge-muted { background: rgba(102,102,102,0.15); color: var(--text-muted); border: 1px solid var(--border); }
.quick-actions { display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem; }
.qa-card {
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  gap: 0.4rem; padding: 1.1rem 0.75rem;
  background: var(--bg-secondary); border: 1px solid var(--border);
  border-radius: var(--radius); text-decoration: none; color: var(--text-secondary);
  font-size: 0.82rem; font-weight: 500; transition: all 0.2s; text-align: center;
}
.qa-card:hover { border-color: var(--green-border); color: var(--green-primary); background: var(--green-glow); }
.qa-icon { font-size: 1.3rem; }
@media (max-width: 1024px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 768px) { .dashboard-grid { grid-template-columns: 1fr; } }
</style>
