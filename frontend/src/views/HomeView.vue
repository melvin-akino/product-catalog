<template>
  <div class="home">
    <NavBar />

    <!-- ── Hero ──────────────────────────────────────────────── -->
    <section class="hero">
      <div class="container hero-container">
      <div class="hero-left">
        <span class="hero-eyebrow">
          <span class="eyebrow-dot"></span> Trusted B2B Supplier
        </span>
        <h1>
          Professional <span class="text-green">Event Equipment</span> and<br />
          LED Lighting<br />Solutions
        </h1>
        <p class="hero-sub">
          Supplying industrial and professional event equipment, LED displays, and
          lighting solutions for events, offices, schools, commercial buildings, and
          more — delivering quality, reliability, and lasting performance.
        </p>
        <div class="hero-actions">
          <RouterLink to="/catalog" class="btn-primary btn-lg">Browse Catalog</RouterLink>
          <RouterLink to="/contact" class="btn-ghost btn-lg">Request a Quote</RouterLink>
        </div>
        <div class="hero-stats">
          <div class="stat-item">
            <span class="stat-val">500<span class="text-green">+</span></span>
            <span class="stat-label">Products</span>
          </div>
          <div class="stat-divider"></div>
          <div class="stat-item">
            <span class="stat-val">100<span class="text-green">+</span></span>
            <span class="stat-label">Brands</span>
          </div>
          <div class="stat-divider"></div>
          <div class="stat-item">
            <span class="stat-val">24<span class="text-green">/7</span></span>
            <span class="stat-label">Support</span>
          </div>
        </div>
      </div>

      <div class="hero-right">
        <div class="showcase-grid">
          <div v-for="(p, i) in showcaseProducts" :key="p.product_id || i" class="showcase-card">
            <RouterLink :to="`/catalog/${p.slug || p.product_id}`" class="showcase-link">
              <img :src="getImg(p)" :alt="p.name" class="showcase-img" @error="e => e.target.src='/placeholder.svg'" />
              <div class="showcase-label">{{ p.name }}</div>
            </RouterLink>
          </div>
          <div v-if="showcaseProducts.length < 4" v-for="i in (4 - showcaseProducts.length)" :key="'ph'+i" class="showcase-card showcase-placeholder">
            <div class="ph-inner"><Package :size="28" /></div>
          </div>
        </div>
        <div class="showcase-glow"></div>
      </div>

      </div><!-- /.hero-container -->
      <div class="hero-gradient"></div>
    </section>

    <!-- ── Trust bar ──────────────────────────────────────────── -->
    <div v-if="brands.length" class="trust-bar">
      <div class="trust-label">Trusted brands we carry</div>
      <div class="ticker-wrap">
        <div class="ticker">
          <span v-for="(b, i) in [...brands, ...brands]" :key="i" class="ticker-item">
            <img v-if="b.logo_url" :src="b.logo_url" :alt="b.name" class="ticker-logo" @error="e => e.target.style.display='none'" />
            <span class="ticker-name">{{ b.name }}</span>
          </span>
        </div>
      </div>
    </div>

    <!-- ── Categories ─────────────────────────────────────────── -->
    <section class="section">
      <div class="container">
        <div class="section-head">
          <div class="section-tag">Categories</div>
          <h2>Browse by Category</h2>
          <p class="text-secondary">Find exactly what you need from our curated product lines</p>
        </div>
        <div class="categories-grid">
          <RouterLink
            v-for="cat in categories" :key="cat.category_id"
            :to="`/catalog?category=${cat.slug}`"
            class="cat-card"
          >
            <div class="cat-icon-wrap">
              <component :is="getCatIcon(cat.name)" :size="24" />
            </div>
            <div class="cat-body">
              <h3>{{ cat.name }}</h3>
              <p>{{ cat.description }}</p>
            </div>
            <div class="cat-meta">
              <span class="cat-count">{{ cat.product_count }} items</span>
              <ArrowRight :size="16" class="cat-arrow" />
            </div>
          </RouterLink>
        </div>
      </div>
    </section>

    <!-- ── Featured Products ───────────────────────────────────── -->
    <section class="section featured-section">
      <div class="container">
        <div class="section-head-row">
          <div>
            <div class="section-tag">Featured</div>
            <h2>Top Picks</h2>
          </div>
          <RouterLink to="/catalog" class="btn-outline view-all-btn">
            View All <ArrowRight :size="15" />
          </RouterLink>
        </div>
        <div v-if="loading" class="products-skeleton">
          <div v-for="i in 4" :key="i" class="skeleton-card"></div>
        </div>
        <div v-else class="grid-4">
          <ProductCard v-for="p in featured" :key="p.product_id" :product="p" />
        </div>
      </div>
    </section>

    <!-- ── Why Choose Us ──────────────────────────────────────── -->
    <section class="section">
      <div class="container">
        <div class="section-head">
          <div class="section-tag">Why Us</div>
          <h2>Built for Professionals</h2>
          <p class="text-secondary">Everything you need to source, compare, and order with confidence</p>
        </div>
        <div class="features-grid">
          <div v-for="f in features" :key="f.title" class="feature-row">
            <div class="feature-icon-box">
              <component :is="f.icon" :size="20" />
            </div>
            <div>
              <h4>{{ f.title }}</h4>
              <p>{{ f.desc }}</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ── CTA ────────────────────────────────────────────────── -->
    <section class="cta-section">
      <div class="container">
        <div class="cta-inner">
          <div class="cta-text">
            <h2>Ready to place an order?</h2>
            <p>Reach out for pricing, availability, and custom bulk order quotes.</p>
          </div>
          <div class="cta-actions">
            <RouterLink to="/contact" class="btn-primary btn-lg">Contact Us</RouterLink>
            <RouterLink to="/catalog" class="btn-ghost btn-lg">Browse Catalog</RouterLink>
          </div>
        </div>
      </div>
    </section>

    <AppFooter />
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { RouterLink } from 'vue-router';
import {
  Lightbulb, Settings2, Wrench, Package,
  ArrowRight, Award, ShieldCheck, MessageCircle,
  Truck, Layers, RotateCcw,
} from 'lucide-vue-next';
import NavBar from '@/components/NavBar.vue';
import AppFooter from '@/components/AppFooter.vue';
import ProductCard from '@/components/ProductCard.vue';
import { productsApi, categoriesApi, brandsApi, contentApi } from '@/api/index';

const featured = ref([]);
const heroProducts = ref([]);
const categories = ref([]);
const brands = ref([]);
const loading = ref(true);

const features = [
  { icon: Award,          title: 'Industry Expertise',   desc: 'Years of experience across construction, manufacturing, and commercial sectors.' },
  { icon: ShieldCheck,    title: 'Quality Guaranteed',   desc: 'Every product meets rigorous standards before listing in our catalog.' },
  { icon: MessageCircle,  title: 'Personal Service',     desc: 'Direct communication for tailored quotes and technical support.' },
  { icon: Truck,          title: 'Fast Delivery',        desc: 'Reliable logistics with express options available on request.' },
  { icon: Layers,         title: 'Bulk Order Ready',     desc: 'Volume pricing and custom packaging for large-scale projects.' },
  { icon: RotateCcw,      title: 'Warranty Support',     desc: 'Backed warranty support on all major brands and product lines.' },
];

const showcaseProducts = computed(() => heroProducts.value.length ? heroProducts.value : featured.value.slice(0, 4));

onMounted(async () => {
  try {
    const [fp, cats, br] = await Promise.all([
      productsApi.getAll({ featured: true, limit: 8 }),
      categoriesApi.getAll(),
      brandsApi.getPublic(),
    ]);
    featured.value = fp.data.products;
    categories.value = cats.data;
    brands.value = br.data;

    // Load admin-pinned hero products
    try {
      const { data: hero } = await contentApi.getPage('hero_products');
      const ids = JSON.parse(hero.content_body || '[]');
      if (ids.length) {
        const { data } = await productsApi.getAll({ ids: ids.join(','), limit: 4 });
        // Preserve the admin-selected order
        heroProducts.value = ids.map(id => data.products.find(p => p.product_id === id)).filter(Boolean);
      }
    } catch {}
  } catch {}
  loading.value = false;
});

function getImg(p) {
  if (!p.images) return '/placeholder.svg';
  const parsed = typeof p.images === 'string' ? JSON.parse(p.images) : p.images;
  return (parsed && parsed[0]) ? parsed[0] : '/placeholder.svg';
}

function getCatIcon(name) {
  const n = name.toLowerCase();
  if (n.includes('light')) return Lightbulb;
  if (n.includes('equip')) return Settings2;
  if (n.includes('access')) return Wrench;
  return Package;
}
</script>

<style scoped>
/* ── Hero ───────────────────────────────────────────────────── */
.hero {
  min-height: 100vh; padding-top: 68px;
  position: relative; overflow: hidden;
}
.hero-container {
  display: flex; align-items: center; justify-content: space-between;
  gap: 3rem;
  min-height: calc(100vh - 68px);
}
.hero-gradient {
  position: absolute; inset: 0; pointer-events: none;
  background:
    radial-gradient(ellipse 55% 70% at 20% 50%, rgba(0,230,118,0.06) 0%, transparent 60%),
    radial-gradient(ellipse 40% 40% at 80% 20%, rgba(0,230,118,0.04) 0%, transparent 50%);
}
.hero-left {
  flex: 1; position: relative; z-index: 1;
  padding: 4rem 0 4rem 0;
  max-width: 560px;
}
.hero-eyebrow {
  display: inline-flex; align-items: center; gap: 0.5rem;
  font-size: 0.78rem; font-weight: 600; letter-spacing: 0.1em;
  text-transform: uppercase; color: var(--green-primary);
  margin-bottom: 1.5rem;
}
.eyebrow-dot {
  width: 6px; height: 6px; border-radius: 50%;
  background: var(--green-primary);
  box-shadow: 0 0 8px var(--green-primary);
  animation: pulse 2s ease-in-out infinite;
}
@keyframes pulse {
  0%,100% { opacity: 1; } 50% { opacity: 0.4; }
}
.hero-left h1 { margin-bottom: 1.25rem; font-size: clamp(2.2rem, 4.5vw, 3.5rem); }
.hero-sub {
  font-size: 1rem; color: var(--text-secondary); max-width: 460px;
  margin-bottom: 2.25rem; line-height: 1.75;
}
.hero-actions { display: flex; gap: 0.75rem; flex-wrap: wrap; margin-bottom: 3rem; }
.btn-lg { padding: 0.85rem 2rem; font-size: 0.95rem; }
.btn-ghost {
  background: transparent; color: var(--text-primary);
  border: 1px solid var(--border-light); font-weight: 600;
  border-radius: var(--radius); transition: all 0.2s;
}
.btn-ghost:hover { border-color: var(--text-muted); background: rgba(255,255,255,0.04); }
.hero-stats { display: flex; align-items: center; gap: 2rem; }
.stat-item { display: flex; flex-direction: column; gap: 0.15rem; }
.stat-val { font-size: 1.6rem; font-weight: 800; letter-spacing: -0.03em; }
.stat-label { font-size: 0.72rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.08em; }
.stat-divider { width: 1px; height: 36px; background: var(--border-light); }

/* ── Hero right ─────────────────────────────────────────────── */
.hero-right {
  flex: 1; position: relative; z-index: 1;
  display: flex; align-items: center; justify-content: center;
  padding: 4rem 0;
  max-width: 500px;
}
.showcase-glow {
  position: absolute; inset: -40px;
  background: radial-gradient(ellipse, rgba(0,230,118,0.08) 0%, transparent 65%);
  pointer-events: none;
}
.showcase-grid {
  display: grid; grid-template-columns: 1fr 1fr;
  gap: 0.75rem; width: 100%; position: relative; z-index: 1;
}
.showcase-card {
  background: var(--bg-card); border: 1px solid var(--border);
  border-radius: var(--radius-lg); overflow: hidden;
  aspect-ratio: 1; position: relative;
  transition: border-color 0.25s, transform 0.25s;
}
.showcase-card:hover { border-color: var(--green-border); transform: scale(1.02); }
.showcase-link { display: block; width: 100%; height: 100%; position: relative; }
.showcase-img { width: 100%; height: 100%; object-fit: cover; }
.showcase-label {
  position: absolute; bottom: 0; left: 0; right: 0;
  background: linear-gradient(transparent, rgba(0,0,0,0.8));
  padding: 1.5rem 0.75rem 0.65rem;
  font-size: 0.72rem; font-weight: 600; color: var(--text-primary);
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.showcase-placeholder {
  background: var(--bg-secondary);
}
.ph-inner {
  width: 100%; height: 100%;
  display: flex; align-items: center; justify-content: center;
  color: var(--border-light);
}

/* ── Trust bar ──────────────────────────────────────────────── */
.trust-bar {
  border-top: 1px solid var(--border); border-bottom: 1px solid var(--border);
  background: var(--bg-secondary);
  padding: 1rem 0; display: flex; align-items: center; gap: 2rem;
  overflow: hidden;
}
.trust-label {
  flex-shrink: 0; padding-left: 1.5rem;
  font-size: 0.72rem; font-weight: 600; letter-spacing: 0.1em;
  text-transform: uppercase; color: var(--text-muted);
}
.ticker-wrap { flex: 1; overflow: hidden; }
.ticker {
  display: flex; align-items: center; gap: 2.5rem; white-space: nowrap;
  animation: ticker-scroll 28s linear infinite;
}
.ticker-item {
  display: inline-flex; align-items: center; gap: 0.5rem; flex-shrink: 0;
}
.ticker-logo {
  height: 22px; max-width: 64px; object-fit: contain;
  opacity: 0.55; filter: grayscale(1);
  transition: opacity 0.2s, filter 0.2s;
}
.ticker-logo:hover { opacity: 0.9; filter: grayscale(0); }
.ticker-name {
  font-size: 0.85rem; font-weight: 600; color: var(--text-muted);
  letter-spacing: 0.05em;
}
@keyframes ticker-scroll {
  0% { transform: translateX(0); }
  100% { transform: translateX(-50%); }
}

/* ── Section head ───────────────────────────────────────────── */
.section-head { text-align: center; margin-bottom: 3rem; }
.section-tag {
  display: inline-block; font-size: 0.72rem; font-weight: 700;
  text-transform: uppercase; letter-spacing: 0.12em;
  color: var(--green-primary); margin-bottom: 0.6rem;
}
.section-head h2 { margin-bottom: 0.65rem; }
.section-head p { max-width: 460px; margin: 0 auto; font-size: 0.95rem; }

/* ── Categories ─────────────────────────────────────────────── */
.categories-grid {
  display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 1rem;
}
.cat-card {
  background: var(--bg-card); border: 1px solid var(--border);
  border-radius: var(--radius-lg); padding: 1.5rem;
  display: flex; align-items: flex-start; gap: 1rem;
  flex-wrap: wrap;
  text-decoration: none; color: inherit;
  transition: border-color 0.25s, box-shadow 0.25s, transform 0.25s;
  position: relative;
}
.cat-card:hover {
  border-color: var(--green-border); box-shadow: var(--shadow-green);
  transform: translateY(-2px);
}
.cat-icon-wrap {
  width: 44px; height: 44px; border-radius: 10px; flex-shrink: 0;
  background: var(--green-glow); border: 1px solid var(--green-border);
  display: flex; align-items: center; justify-content: center;
  color: var(--green-primary);
}
.cat-body { flex: 1; min-width: 0; }
.cat-body h3 { font-size: 1rem; font-weight: 700; margin-bottom: 0.3rem; }
.cat-body p { font-size: 0.82rem; color: var(--text-muted); line-height: 1.5; }
.cat-meta {
  width: 100%; display: flex; justify-content: space-between; align-items: center;
  margin-top: 0.5rem; padding-top: 0.75rem; border-top: 1px solid var(--border);
}
.cat-count { font-size: 0.75rem; color: var(--green-primary); font-weight: 600; }
.cat-arrow { color: var(--text-muted); transition: transform 0.2s, color 0.2s; }
.cat-card:hover .cat-arrow { transform: translateX(4px); color: var(--green-primary); }

/* ── Featured section ───────────────────────────────────────── */
.featured-section { background: var(--bg-secondary); border-top: 1px solid var(--border); border-bottom: 1px solid var(--border); }
.section-head-row { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 2rem; }
.view-all-btn { display: flex; align-items: center; gap: 0.4rem; font-size: 0.85rem; }

.products-skeleton { display: grid; grid-template-columns: repeat(4, 1fr); gap: 1.25rem; }
.skeleton-card {
  aspect-ratio: 3/4; border-radius: var(--radius-lg);
  background: linear-gradient(90deg, var(--bg-card) 25%, var(--bg-card-hover) 50%, var(--bg-card) 75%);
  background-size: 200% 100%;
  animation: shimmer 1.4s infinite;
}
@keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }

/* ── Features ───────────────────────────────────────────────── */
.features-grid {
  display: grid; grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem 2rem;
}
.feature-row {
  display: flex; align-items: flex-start; gap: 1rem;
  padding: 1.25rem; border-radius: var(--radius-lg);
  border: 1px solid var(--border); background: var(--bg-card);
  transition: border-color 0.25s;
}
.feature-row:hover { border-color: var(--border-light); }
.feature-icon-box {
  width: 40px; height: 40px; flex-shrink: 0;
  border-radius: 9px; background: var(--green-glow);
  border: 1px solid var(--green-border);
  display: flex; align-items: center; justify-content: center;
  color: var(--green-primary);
}
.feature-row h4 { font-size: 0.9rem; font-weight: 700; margin-bottom: 0.3rem; }
.feature-row p { font-size: 0.82rem; color: var(--text-muted); line-height: 1.55; }

/* ── CTA ────────────────────────────────────────────────────── */
.cta-section {
  padding: 5rem 0;
  border-top: 1px solid var(--border);
  background: var(--bg-secondary);
}
.cta-inner {
  display: flex; align-items: center; justify-content: space-between;
  gap: 2rem; flex-wrap: wrap;
  background: var(--bg-card); border: 1px solid var(--green-border);
  border-radius: var(--radius-lg); padding: 2.5rem 3rem;
  box-shadow: var(--shadow-green);
}
.cta-text h2 { margin-bottom: 0.5rem; }
.cta-text p { color: var(--text-secondary); font-size: 0.95rem; }
.cta-actions { display: flex; gap: 0.75rem; flex-wrap: wrap; }

/* ── Responsive ─────────────────────────────────────────────── */
@media (max-width: 1024px) {
  .features-grid { grid-template-columns: repeat(2, 1fr); }
  .products-skeleton { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 860px) {
  .hero { min-height: unset; padding: 100px 0 3rem; }
  .hero-container { flex-direction: column; min-height: unset; }
  .hero-left { max-width: 100%; padding: 0; text-align: center; }
  .hero-eyebrow { justify-content: center; }
  .hero-actions { justify-content: center; }
  .hero-stats { justify-content: center; }
  .hero-right { max-width: 100%; width: 100%; padding: 0; }
  .showcase-grid { max-width: 400px; margin: 0 auto; }
  .cta-inner { flex-direction: column; text-align: center; }
}
@media (max-width: 640px) {
  .features-grid, .products-skeleton { grid-template-columns: 1fr; }
  .section-head-row { flex-direction: column; align-items: flex-start; gap: 1rem; }
  .trust-bar { flex-direction: column; gap: 0.75rem; }
}
</style>
