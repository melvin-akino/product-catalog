<template>
  <div class="catalog-page">
    <NavBar />
    <div class="page-hero">
      <div class="container">
        <h1>Product <span class="text-green">Catalog</span></h1>
        <p class="text-secondary">Browse our complete range of equipment and lighting products</p>
      </div>
    </div>

    <div class="container catalog-layout">
      <!-- Mobile filter toggle -->
      <button class="mobile-filter-btn btn-outline" @click="filterOpen = true">⚙ Filters</button>

      <FilterSidebar
        v-model="filters"
        :categories="categories"
        :mobile-open="filterOpen"
        @close="filterOpen = false"
      />

      <div class="catalog-main">
        <!-- Results bar -->
        <div class="results-bar">
          <span class="text-secondary">{{ total }} product{{ total !== 1 ? 's' : '' }} found</span>
          <select v-model="sortBy" @change="loadProducts(1)">
            <option value="newest">Newest First</option>
            <option value="name_asc">Name A–Z</option>
            <option value="name_desc">Name Z–A</option>
            <option value="featured">Featured</option>
          </select>
        </div>

        <div v-if="loading" class="spinner"></div>
        <div v-else-if="products.length === 0" class="empty-state">
          <div class="empty-icon">🔍</div>
          <h3>No products found</h3>
          <p class="text-secondary">Try adjusting your search or filter criteria</p>
          <button class="btn-outline" @click="clearFilters">Clear Filters</button>
        </div>
        <div v-else class="products-grid">
          <ProductCard v-for="p in products" :key="p.product_id" :product="p" />
        </div>

        <!-- Pagination -->
        <div v-if="totalPages > 1" class="pagination">
          <button :disabled="page === 1" @click="loadProducts(page - 1)" class="page-btn">‹</button>
          <button
            v-for="p in pageNumbers"
            :key="p"
            class="page-btn"
            :class="{ active: p === page }"
            @click="loadProducts(p)"
          >{{ p }}</button>
          <button :disabled="page === totalPages" @click="loadProducts(page + 1)" class="page-btn">›</button>
        </div>
      </div>
    </div>

    <AppFooter />
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import NavBar from '@/components/NavBar.vue';
import AppFooter from '@/components/AppFooter.vue';
import ProductCard from '@/components/ProductCard.vue';
import FilterSidebar from '@/components/FilterSidebar.vue';
import { productsApi, categoriesApi } from '@/api/index';

const route = useRoute();
const router = useRouter();

const products = ref([]);
const categories = ref([]);
const loading = ref(true);
const total = ref(0);
const page = ref(1);
const limit = 12;
const filterOpen = ref(false);
const sortBy = ref('newest');

const filters = ref({
  search: route.query.search || '',
  category: route.query.category || '',
  featured: false,
});

const totalPages = computed(() => Math.ceil(total.value / limit));
const pageNumbers = computed(() => {
  const pages = [];
  const start = Math.max(1, page.value - 2);
  const end = Math.min(totalPages.value, page.value + 2);
  for (let i = start; i <= end; i++) pages.push(i);
  return pages;
});

async function loadProducts(p = 1) {
  loading.value = true;
  page.value = p;
  try {
    const { data } = await productsApi.getAll({
      page: p,
      limit,
      search: filters.value.search,
      category: filters.value.category,
      featured: filters.value.featured || undefined,
    });
    products.value = data.products;
    total.value = data.total;
  } catch {}
  loading.value = false;
}

function clearFilters() {
  filters.value = { search: '', category: '', featured: false };
}

watch(filters, () => loadProducts(1), { deep: true });

onMounted(async () => {
  const [cats] = await Promise.all([categoriesApi.getAll(), loadProducts()]);
  categories.value = cats.data;
});
</script>

<style scoped>
.catalog-layout {
  display: grid;
  grid-template-columns: 260px 1fr;
  gap: 2rem;
  padding: 2.5rem 1.5rem;
  align-items: start;
}
.mobile-filter-btn { display: none; margin-bottom: 1rem; }
.results-bar {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 1.5rem;
}
.results-bar select { width: auto; padding: 0.4rem 0.75rem; font-size: 0.875rem; }
.products-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 1.5rem; }
.empty-state { text-align: center; padding: 4rem 2rem; }
.empty-icon { font-size: 3rem; margin-bottom: 1rem; }
.empty-state h3 { margin-bottom: 0.5rem; }
.empty-state p { margin-bottom: 1.5rem; }
.pagination { display: flex; gap: 0.4rem; justify-content: center; margin-top: 2.5rem; }
.page-btn {
  width: 36px; height: 36px; border-radius: var(--radius);
  background: var(--bg-card); border: 1px solid var(--border);
  color: var(--text-secondary); font-size: 0.9rem;
  display: flex; align-items: center; justify-content: center;
}
.page-btn:hover:not(:disabled) { border-color: var(--green-border); color: var(--green-primary); }
.page-btn.active { background: var(--green-primary); color: #000; border-color: var(--green-primary); font-weight: 700; }
.page-btn:disabled { opacity: 0.3; cursor: not-allowed; }
@media (max-width: 768px) {
  .catalog-layout { grid-template-columns: 1fr; }
  .mobile-filter-btn { display: flex; }
}
</style>
