<template>
  <div class="detail-page">
    <NavBar />

    <div v-if="loading" class="spinner" style="margin-top: 120px;"></div>

    <div v-else-if="product" class="container detail-layout">
      <!-- Breadcrumb -->
      <nav class="breadcrumb">
        <RouterLink to="/">Home</RouterLink>
        <span>›</span>
        <RouterLink to="/catalog">Catalog</RouterLink>
        <span>›</span>
        <RouterLink v-if="product.category_slug" :to="`/catalog?category=${product.category_slug}`">{{ product.category_name }}</RouterLink>
        <span>›</span>
        <span class="text-muted">{{ product.name }}</span>
      </nav>

      <div class="product-grid">
        <!-- Gallery -->
        <div class="product-gallery-wrap">
          <ProductGallery :images="parsedImages" :alt="product.name" />
        </div>

        <!-- Info -->
        <div class="product-info">
          <span class="badge badge-green category-tag">{{ product.category_name || 'Uncategorized' }}</span>
          <h1 class="product-title">{{ product.name }}</h1>
          <p class="product-desc">{{ product.description }}</p>

          <div class="inquiry-box">
            <p class="inquiry-note">Price available upon request</p>
            <button class="btn-primary inquire-btn" @click="showModal = true">
              💬 Inquire Now
            </button>
            <div class="quick-contacts">
              <RouterLink :to="`/contact?subject=${encodeURIComponent('Inquiry about ' + (product?.name || ''))}`" class="quick-link">✉ Email Us</RouterLink>
              <a :href="`tel:${company?.phone}`" class="quick-link">📞 Call</a>
            </div>
          </div>

          <!-- Specifications -->
          <div v-if="specs" class="specs-section">
            <h3>Specifications</h3>
            <div class="accent-line"></div>
            <!-- Legacy JSON key-value format -->
            <table v-if="specs.type === 'json'" class="specs-table">
              <tbody>
                <tr v-for="(val, key) in specs.data" :key="key">
                  <td class="spec-key">{{ formatKey(key) }}</td>
                  <td>{{ val }}</td>
                </tr>
              </tbody>
            </table>
            <!-- Rich HTML format (from WYSIWYG editor) -->
            <div v-else class="specs-html" v-html="specs.data"></div>
          </div>
        </div>
      </div>

      <!-- Related Products -->
      <section v-if="related.length" class="section-sm">
        <h2>Related Products</h2>
        <div class="accent-line"></div>
        <div class="grid-4" style="margin-top: 1.5rem;">
          <ProductCard v-for="p in related" :key="p.product_id" :product="p" />
        </div>
      </section>
    </div>

    <div v-else class="container" style="padding: 8rem 1.5rem; text-align: center;">
      <h2>Product not found</h2>
      <RouterLink to="/catalog" class="btn-outline" style="margin-top: 1.5rem; display: inline-flex;">← Back to Catalog</RouterLink>
    </div>

    <InquireModal v-if="showModal" :product-name="product?.name" @close="showModal = false" />
    <AppFooter />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useRoute, RouterLink } from 'vue-router';
import NavBar from '@/components/NavBar.vue';
import AppFooter from '@/components/AppFooter.vue';
import ProductGallery from '@/components/ProductGallery.vue';
import ProductCard from '@/components/ProductCard.vue';
import InquireModal from '@/components/InquireModal.vue';
import { productsApi, companyApi } from '@/api/index';

const route = useRoute();
const product = ref(null);
const related = ref([]);
const company = ref(null);
const loading = ref(true);
const showModal = ref(false);

const parsedImages = computed(() => {
  if (!product.value?.images) return [];
  const imgs = typeof product.value.images === 'string' ? JSON.parse(product.value.images) : product.value.images;
  return Array.isArray(imgs) ? imgs : [];
});

const specs = computed(() => {
  const raw = product.value?.specifications;
  if (!raw) return null;
  // Legacy: already a parsed object (old JSON column auto-parsed by driver)
  if (typeof raw === 'object') return { type: 'json', data: raw };
  // Try to detect legacy JSON string format
  try {
    const parsed = JSON.parse(raw);
    if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) {
      return { type: 'json', data: parsed };
    }
  } catch {}
  // New HTML format from WYSIWYG editor
  const trimmed = raw.replace(/<[^>]*>/g, '').trim();
  if (!trimmed) return null;
  return { type: 'html', data: raw };
});

function formatKey(key) {
  return key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
}

async function loadProduct() {
  loading.value = true;
  try {
    const { data } = await productsApi.getById(route.params.id);
    product.value = data;
    if (data.category_id) {
      const rel = await productsApi.getAll({ category: data.category_slug, limit: 5 });
      related.value = rel.data.products.filter(p => p.product_id !== data.product_id).slice(0, 4);
    }
  } catch { product.value = null; }
  loading.value = false;
}

onMounted(async () => {
  const [c] = await Promise.all([companyApi.get(), loadProduct()]);
  company.value = c.data;
});

watch(() => route.params.id, loadProduct);
</script>

<style scoped>
.detail-layout { padding: 2rem 1.5rem 4rem; }
.breadcrumb { display: flex; gap: 0.5rem; align-items: center; font-size: 0.85rem; color: var(--text-muted); margin-bottom: 2rem; flex-wrap: wrap; }
.breadcrumb a { color: var(--text-muted); }
.breadcrumb a:hover { color: var(--green-primary); }
.product-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 3rem; margin-top: 0.5rem; }
.category-tag { margin-bottom: 0.75rem; }
.product-title { font-size: clamp(1.5rem, 3vw, 2.25rem); margin-bottom: 1rem; line-height: 1.2; }
.product-desc { color: var(--text-secondary); line-height: 1.7; margin-bottom: 2rem; font-size: 1rem; }
.inquiry-box {
  background: var(--bg-card); border: 1px solid var(--green-border);
  border-radius: var(--radius-lg); padding: 1.5rem;
  margin-bottom: 2rem;
}
.inquiry-note { color: var(--text-muted); font-size: 0.875rem; margin-bottom: 1rem; }
.inquire-btn { width: 100%; justify-content: center; font-size: 1rem; padding: 0.9rem; margin-bottom: 1rem; }
.quick-contacts { display: flex; gap: 1rem; }
.quick-link {
  flex: 1; text-align: center; padding: 0.6rem;
  border-radius: var(--radius); border: 1px solid var(--border);
  color: var(--text-secondary); font-size: 0.875rem; background: var(--bg-secondary);
}
.quick-link:hover { border-color: var(--green-border); color: var(--green-primary); }
.specs-section { margin-top: 0.5rem; }
.specs-section h3 { margin-bottom: 0.25rem; }
.specs-table { width: 100%; border-radius: var(--radius); overflow: hidden; margin-top: 0.5rem; }
.spec-key { color: var(--text-muted); font-size: 0.875rem; font-weight: 600; width: 40%; }

/* Rich HTML specs from WYSIWYG editor */
.specs-html { margin-top: 0.75rem; font-size: 0.925rem; line-height: 1.7; color: var(--text-secondary); }
.specs-html :deep(h2), .specs-html :deep(h3) { color: var(--text); margin: 0.75rem 0 0.4rem; font-size: 1rem; }
.specs-html :deep(ul), .specs-html :deep(ol) { padding-left: 1.5rem; margin: 0.4rem 0; }
.specs-html :deep(li) { margin-bottom: 0.25rem; }
.specs-html :deep(strong) { color: var(--text-primary); }
.specs-html :deep(p) { margin: 0.35rem 0; }

/* 2-column spec table */
.specs-html :deep(table) {
  width: 100%;
  border-collapse: collapse;
  border: 1px solid var(--border);
  border-radius: var(--radius);
  overflow: hidden;
  margin-top: 0.25rem;
}
.specs-html :deep(tr) { border-bottom: 1px solid var(--border); }
.specs-html :deep(tr:last-child) { border-bottom: none; }
.specs-html :deep(tr:nth-child(even) td:first-child) { background: var(--bg-card-hover); }
.specs-html :deep(td) { padding: 0.65rem 1rem; vertical-align: middle; font-size: 0.875rem; }
.specs-html :deep(td:first-child) {
  width: 38%;
  background: var(--bg-secondary);
  color: var(--text-muted);
  font-weight: 600;
  border-right: 1px solid var(--border);
}
.specs-html :deep(td:last-child) { color: var(--text-primary); }

@media (max-width: 900px) { .product-grid { grid-template-columns: 1fr; } }
</style>
