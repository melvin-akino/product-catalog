<template>
  <div class="hero-admin">
    <div class="admin-page-header">
      <div>
        <h2>Hero Showcase</h2>
        <p class="text-muted" style="font-size:0.875rem;margin-top:0.25rem;">
          Select up to 6 products to display in the homepage hero section (3 × 2 grid).
        </p>
      </div>
      <button class="btn-primary" @click="save" :disabled="saving">
        {{ saving ? 'Saving…' : 'Save Changes' }}
      </button>
    </div>

    <div v-if="saveSuccess" class="alert alert-success">Hero products updated successfully!</div>
    <div v-if="saveError" class="alert alert-error">{{ saveError }}</div>

    <div v-if="loading" class="spinner"></div>
    <div v-else class="slots-grid">
      <div v-for="i in 6" :key="i" class="slot-card">
        <div class="slot-header">
          <span class="slot-num">Slot {{ i }}</span>
          <span v-if="selected[i-1]" class="badge badge-green">Selected</span>
          <span v-else class="badge badge-empty">Empty</span>
        </div>

        <div v-if="selected[i-1]" class="slot-preview">
          <img :src="getImg(selected[i-1])" class="slot-img" @error="e => e.target.src='/placeholder.svg'" />
          <div class="slot-name">{{ selected[i-1].name }}</div>
          <button class="slot-clear" @click="clear(i-1)">✕ Remove</button>
        </div>
        <div v-else class="slot-empty">
          <Package :size="32" />
          <span>No product selected</span>
        </div>

        <div class="slot-search-wrap">
          <input
            v-model="queries[i-1]"
            class="slot-input"
            placeholder="Search products…"
            @focus="openDrop[i-1] = true"
            @blur="closeDrop(i-1)"
          />
          <div v-if="openDrop[i-1]" class="search-dropdown">
            <button
              v-for="p in filtered(queries[i-1])"
              :key="p.product_id"
              class="drop-item"
              @mousedown.prevent="pick(i-1, p)"
            >
              <img :src="getImg(p)" class="drop-thumb" @error="e => e.target.src='/placeholder.svg'" />
              <span>{{ p.name }}</span>
            </button>
            <div v-if="!filtered(queries[i-1]).length" class="drop-empty">No products found</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { Package } from 'lucide-vue-next';
import { productsApi, contentApi } from '@/api/index';

const allProducts = ref([]);
const selected = ref([null, null, null, null, null, null]);
const queries = ref(['', '', '', '', '', '']);
const openDrop = ref([false, false, false, false, false, false]);
const loading = ref(true);
const saving = ref(false);
const saveSuccess = ref(false);
const saveError = ref('');

function filtered(q) {
  const term = q.toLowerCase().trim();
  if (!term) return allProducts.value.slice(0, 12);
  return allProducts.value.filter(p => p.name.toLowerCase().includes(term)).slice(0, 12);
}

function getImg(p) {
  try {
    const imgs = typeof p.images === 'string' ? JSON.parse(p.images) : p.images;
    return imgs?.[0] || '/placeholder.svg';
  } catch { return '/placeholder.svg'; }
}

function pick(idx, product) {
  selected.value[idx] = product;
  queries.value[idx] = '';
  openDrop.value[idx] = false;
}

function clear(idx) {
  selected.value[idx] = null;
}

function closeDrop(idx) {
  setTimeout(() => { openDrop.value[idx] = false; }, 150);
}

async function save() {
  saving.value = true;
  saveSuccess.value = false;
  saveError.value = '';
  try {
    const ids = selected.value.filter(Boolean).map(p => p.product_id);
    await contentApi.updatePage('hero_products', { content_body: JSON.stringify(ids) });
    saveSuccess.value = true;
    setTimeout(() => { saveSuccess.value = false; }, 3000);
  } catch {
    saveError.value = 'Failed to save. Please try again.';
  }
  saving.value = false;
}

onMounted(async () => {
  try {
    const { data: prods } = await productsApi.getAll({ limit: 200 });
    allProducts.value = prods.products;

    try {
      const { data: hero } = await contentApi.getPage('hero_products');
      const ids = JSON.parse(hero.content_body || '[]');
      selected.value = ids.map(id => allProducts.value.find(p => p.product_id === id) || null);
      while (selected.value.length < 6) selected.value.push(null);
    } catch {}
  } catch {}
  loading.value = false;
});
</script>

<style scoped>
.admin-page-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1.5rem; }

.slots-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.25rem;
}
@media (max-width: 1100px) { .slots-grid { grid-template-columns: repeat(2, 1fr); } }
@media (max-width: 600px) { .slots-grid { grid-template-columns: 1fr; } }

.slot-card {
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  padding: 1.25rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.slot-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.slot-num {
  font-size: 0.78rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--text-muted);
}
.badge-empty {
  background: rgba(102,102,102,0.15);
  color: var(--text-muted);
  border: 1px solid var(--border);
  display: inline-flex;
  align-items: center;
  padding: 0.2rem 0.7rem;
  border-radius: 999px;
  font-size: 0.75rem;
  font-weight: 600;
}

.slot-preview {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  text-align: center;
}
.slot-img {
  width: 100%;
  aspect-ratio: 1;
  object-fit: cover;
  border-radius: var(--radius);
  border: 1px solid var(--border);
}
.slot-name {
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--text-primary);
  line-height: 1.3;
}
.slot-clear {
  background: transparent;
  border: 1px solid var(--border);
  color: var(--text-muted);
  font-size: 0.75rem;
  padding: 0.25rem 0.65rem;
  border-radius: var(--radius);
  cursor: pointer;
  transition: all 0.2s;
}
.slot-clear:hover { border-color: #c62828; color: #ef5350; }

.slot-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 2rem 1rem;
  color: var(--text-muted);
  border: 2px dashed var(--border);
  border-radius: var(--radius);
  font-size: 0.85rem;
  flex: 1;
}

.slot-search-wrap { position: relative; }
.slot-input {
  width: 100%;
  font-size: 0.85rem;
  padding: 0.5rem 0.75rem;
}

.search-dropdown {
  position: absolute;
  top: calc(100% + 4px);
  left: 0; right: 0;
  background: var(--bg-card);
  border: 1px solid var(--border-light);
  border-radius: var(--radius);
  z-index: 50;
  max-height: 220px;
  overflow-y: auto;
  box-shadow: var(--shadow);
}
.drop-item {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  width: 100%;
  padding: 0.5rem 0.75rem;
  background: transparent;
  border: none;
  color: var(--text-primary);
  font-size: 0.85rem;
  text-align: left;
  cursor: pointer;
  border-bottom: 1px solid var(--border);
  transition: background 0.15s;
}
.drop-item:last-child { border-bottom: none; }
.drop-item:hover { background: var(--bg-card-hover); }
.drop-thumb {
  width: 32px; height: 32px;
  object-fit: cover;
  border-radius: 4px;
  border: 1px solid var(--border);
  flex-shrink: 0;
}
.drop-empty {
  padding: 0.75rem;
  text-align: center;
  font-size: 0.85rem;
  color: var(--text-muted);
}
</style>
