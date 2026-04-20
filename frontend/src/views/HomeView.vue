<template>
  <div class="home">
    <NavBar />

    <!-- Hero -->
    <section class="hero">
      <div class="hero-bg"></div>
      <div class="container hero-content">
        <div class="hero-badge badge badge-green">Professional Grade</div>
        <h1>
          Premium <span class="text-green">Equipment</span> &amp;<br />
          Lighting Solutions
        </h1>
        <p class="hero-subtitle">
          Discover our comprehensive catalog of industrial-grade equipment and high-performance lighting products designed for every application.
        </p>
        <div class="hero-actions">
          <RouterLink to="/catalog" class="btn-primary">Explore Products</RouterLink>
          <RouterLink to="/contact" class="btn-outline">Get a Quote</RouterLink>
        </div>
        <div class="hero-stats">
          <div class="stat"><span class="stat-num text-green">500+</span><span>Products</span></div>
          <div class="stat"><span class="stat-num text-green">100+</span><span>Brands</span></div>
          <div class="stat"><span class="stat-num text-green">24/7</span><span>Support</span></div>
        </div>
      </div>
      <div class="hero-glow"></div>
    </section>

    <!-- Categories -->
    <section class="section">
      <div class="container">
        <div class="section-header">
          <h2>Browse by Category</h2>
          <div class="accent-line"></div>
          <p class="text-secondary">Find exactly what you need from our curated product categories</p>
        </div>
        <div class="categories-grid">
          <RouterLink
            v-for="cat in categories"
            :key="cat.category_id"
            :to="`/catalog?category=${cat.slug}`"
            class="category-card"
          >
            <div class="cat-icon">{{ getCatIcon(cat.name) }}</div>
            <h3>{{ cat.name }}</h3>
            <p>{{ cat.description }}</p>
            <span class="cat-count-badge">{{ cat.product_count }} items</span>
          </RouterLink>
        </div>
      </div>
    </section>

    <!-- Featured Products -->
    <section class="section" style="background: var(--bg-secondary); border-top: 1px solid var(--border); border-bottom: 1px solid var(--border);">
      <div class="container">
        <div class="section-header">
          <h2>Featured Products</h2>
          <div class="accent-line"></div>
          <p class="text-secondary">Hand-picked selections for quality and performance</p>
        </div>
        <div v-if="loading" class="spinner"></div>
        <div v-else class="grid-4">
          <ProductCard v-for="p in featured" :key="p.product_id" :product="p" />
        </div>
        <div class="view-all-wrap">
          <RouterLink to="/catalog" class="btn-outline">View All Products →</RouterLink>
        </div>
      </div>
    </section>

    <!-- Why Choose Us -->
    <section class="section">
      <div class="container">
        <div class="section-header">
          <h2>Why Choose Us</h2>
          <div class="accent-line"></div>
        </div>
        <div class="grid-3 features">
          <div class="feature-card">
            <div class="feature-icon">⚡</div>
            <h3>Industry Expertise</h3>
            <p class="text-secondary">Years of experience delivering professional equipment and lighting solutions across all sectors.</p>
          </div>
          <div class="feature-card">
            <div class="feature-icon">✓</div>
            <h3>Quality Guaranteed</h3>
            <p class="text-secondary">Every product meets rigorous quality standards before it reaches our catalog.</p>
          </div>
          <div class="feature-card">
            <div class="feature-icon">💬</div>
            <h3>Personal Service</h3>
            <p class="text-secondary">Direct communication for tailored quotes, bulk orders, and technical support.</p>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA -->
    <section class="section cta-section">
      <div class="container">
        <div class="cta-box">
          <h2>Ready to Order?</h2>
          <p>Contact us directly for pricing, availability, and custom orders.</p>
          <div class="cta-actions">
            <RouterLink to="/contact" class="btn-primary">Contact Us</RouterLink>
            <RouterLink to="/catalog" class="btn-outline">Browse Catalog</RouterLink>
          </div>
        </div>
      </div>
    </section>

    <AppFooter />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { RouterLink } from 'vue-router';
import NavBar from '@/components/NavBar.vue';
import AppFooter from '@/components/AppFooter.vue';
import ProductCard from '@/components/ProductCard.vue';
import { productsApi, categoriesApi } from '@/api/index';

const featured = ref([]);
const categories = ref([]);
const loading = ref(true);

onMounted(async () => {
  try {
    const [fp, cats] = await Promise.all([
      productsApi.getAll({ featured: true, limit: 8 }),
      categoriesApi.getAll(),
    ]);
    featured.value = fp.data.products;
    categories.value = cats.data;
  } catch {}
  loading.value = false;
});

function getCatIcon(name) {
  const n = name.toLowerCase();
  if (n.includes('light')) return '💡';
  if (n.includes('equip')) return '⚙️';
  if (n.includes('access')) return '🔧';
  return '📦';
}
</script>

<style scoped>
/* Hero */
.hero {
  position: relative; min-height: 100vh;
  display: flex; align-items: center;
  overflow: hidden; padding-top: 70px;
}
.hero-bg {
  position: absolute; inset: 0;
  background: radial-gradient(ellipse 80% 60% at 50% 40%, rgba(0,230,118,0.07) 0%, transparent 70%);
  pointer-events: none;
}
.hero-glow {
  position: absolute; bottom: -100px; left: 50%; transform: translateX(-50%);
  width: 700px; height: 300px;
  background: radial-gradient(ellipse, rgba(0,230,118,0.12) 0%, transparent 70%);
  pointer-events: none;
}
.hero-content { position: relative; z-index: 1; padding: 4rem 0; max-width: 760px; }
.hero-badge { margin-bottom: 1.5rem; font-size: 0.8rem; }
.hero-content h1 { margin-bottom: 1.25rem; }
.hero-subtitle { font-size: 1.15rem; color: var(--text-secondary); max-width: 560px; margin-bottom: 2rem; line-height: 1.7; }
.hero-actions { display: flex; gap: 1rem; flex-wrap: wrap; margin-bottom: 3rem; }
.hero-stats { display: flex; gap: 3rem; flex-wrap: wrap; }
.stat { display: flex; flex-direction: column; gap: 0.15rem; }
.stat-num { font-size: 1.75rem; font-weight: 800; }
.stat span:last-child { font-size: 0.82rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.08em; }

/* Section header */
.section-header { text-align: center; margin-bottom: 3rem; }
.section-header .accent-line { margin: 0.75rem auto 1rem; }
.section-header p { max-width: 500px; margin: 0 auto; }

/* Categories */
.categories-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 1.5rem; }
.category-card {
  background: var(--bg-card); border: 1px solid var(--border);
  border-radius: var(--radius-lg); padding: 2rem 1.5rem;
  text-decoration: none; color: inherit;
  transition: all 0.3s; position: relative; overflow: hidden;
}
.category-card::before {
  content: ''; position: absolute; top: 0; left: 0; right: 0; height: 3px;
  background: var(--green-primary); transform: scaleX(0); transform-origin: left;
  transition: transform 0.3s;
}
.category-card:hover::before { transform: scaleX(1); }
.category-card:hover { border-color: var(--green-border); box-shadow: var(--shadow-green); transform: translateY(-4px); }
.cat-icon { font-size: 2.5rem; margin-bottom: 0.75rem; }
.category-card h3 { font-size: 1.15rem; margin-bottom: 0.5rem; }
.category-card p { color: var(--text-muted); font-size: 0.875rem; margin-bottom: 1rem; }
.cat-count-badge { font-size: 0.78rem; color: var(--green-primary); font-weight: 600; }

/* View all */
.view-all-wrap { text-align: center; margin-top: 2.5rem; }

/* Features */
.feature-card {
  background: var(--bg-card); border: 1px solid var(--border);
  border-radius: var(--radius-lg); padding: 2rem;
  transition: all 0.3s;
}
.feature-card:hover { border-color: var(--green-border); box-shadow: var(--shadow-green); }
.feature-icon { font-size: 2rem; color: var(--green-primary); margin-bottom: 1rem; }
.feature-card h3 { margin-bottom: 0.5rem; }

/* CTA */
.cta-section { background: var(--bg-secondary); border-top: 1px solid var(--border); }
.cta-box {
  text-align: center; max-width: 600px; margin: 0 auto;
  background: var(--bg-card); border: 1px solid var(--green-border);
  border-radius: var(--radius-lg); padding: 3.5rem 2rem;
  box-shadow: var(--shadow-green);
}
.cta-box h2 { margin-bottom: 0.75rem; }
.cta-box p { color: var(--text-secondary); margin-bottom: 2rem; }
.cta-actions { display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap; }
</style>
