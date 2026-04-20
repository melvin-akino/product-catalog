<template>
  <aside class="filter-sidebar" :class="{ open: mobileOpen }">
    <div class="filter-header">
      <h3>Filters</h3>
      <button class="filter-close" @click="$emit('close')">✕</button>
    </div>

    <div class="filter-section">
      <h4>Search</h4>
      <input
        v-model="localSearch"
        type="text"
        placeholder="Search products…"
        @input="emitFilters"
      />
    </div>

    <div class="filter-section">
      <h4>Category</h4>
      <div class="category-list">
        <button
          class="cat-btn"
          :class="{ active: localCategory === '' }"
          @click="selectCategory('')"
        >All</button>
        <button
          v-for="cat in categories"
          :key="cat.category_id"
          class="cat-btn"
          :class="{ active: localCategory === cat.slug }"
          @click="selectCategory(cat.slug)"
        >
          {{ cat.name }}
          <span class="cat-count">{{ cat.product_count }}</span>
        </button>
      </div>
    </div>

    <div class="filter-section">
      <label class="check-label">
        <input type="checkbox" v-model="localFeatured" @change="emitFilters" />
        <span>Featured only</span>
      </label>
    </div>

    <button class="btn-outline clear-btn" @click="clearFilters">Clear Filters</button>
  </aside>
</template>

<script setup>
import { ref, watch } from 'vue';

const props = defineProps({
  categories: { type: Array, default: () => [] },
  mobileOpen: { type: Boolean, default: false },
  modelValue: { type: Object, default: () => ({}) },
});

const emit = defineEmits(['update:modelValue', 'close']);

const localSearch = ref(props.modelValue.search || '');
const localCategory = ref(props.modelValue.category || '');
const localFeatured = ref(props.modelValue.featured || false);

let debounceTimer;
function emitFilters() {
  clearTimeout(debounceTimer);
  debounceTimer = setTimeout(() => {
    emit('update:modelValue', {
      search: localSearch.value,
      category: localCategory.value,
      featured: localFeatured.value,
    });
  }, 300);
}

function selectCategory(slug) {
  localCategory.value = slug;
  emitFilters();
}

function clearFilters() {
  localSearch.value = '';
  localCategory.value = '';
  localFeatured.value = false;
  emitFilters();
}
</script>

<style scoped>
.filter-sidebar {
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  padding: 1.5rem;
  position: sticky; top: 90px;
  display: flex; flex-direction: column; gap: 0;
}
.filter-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; }
.filter-header h3 { font-size: 1rem; font-weight: 700; }
.filter-close { display: none; background: none; color: var(--text-muted); font-size: 1.1rem; }
.filter-section { margin-bottom: 1.5rem; padding-bottom: 1.5rem; border-bottom: 1px solid var(--border); }
.filter-section:last-of-type { border-bottom: none; }
.filter-section h4 { font-size: 0.78rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--text-muted); margin-bottom: 0.75rem; }
.category-list { display: flex; flex-direction: column; gap: 0.3rem; }
.cat-btn {
  display: flex; justify-content: space-between; align-items: center;
  background: none; color: var(--text-secondary); padding: 0.5rem 0.75rem;
  border-radius: var(--radius); text-align: left; font-size: 0.9rem;
  border: 1px solid transparent;
}
.cat-btn:hover { color: var(--green-primary); background: var(--green-glow); }
.cat-btn.active { color: var(--green-primary); border-color: var(--green-border); background: var(--green-glow); font-weight: 600; }
.cat-count { font-size: 0.75rem; color: var(--text-muted); background: var(--bg-secondary); padding: 0.1rem 0.4rem; border-radius: 999px; }
.check-label { display: flex; align-items: center; gap: 0.5rem; cursor: pointer; font-size: 0.9rem; color: var(--text-secondary); }
.check-label input { width: auto; accent-color: var(--green-primary); }
.clear-btn { margin-top: 0.5rem; width: 100%; justify-content: center; }
@media (max-width: 768px) {
  .filter-sidebar {
    position: fixed; inset: 0; z-index: 800;
    border-radius: 0; overflow-y: auto;
    transform: translateX(-100%); transition: transform 0.3s ease;
  }
  .filter-sidebar.open { transform: translateX(0); }
  .filter-close { display: block; }
}
</style>
