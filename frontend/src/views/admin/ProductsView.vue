<template>
  <div class="products-admin">
    <div class="admin-page-header">
      <h2>Products</h2>
      <button class="btn-primary" @click="openModal()">+ Add Product</button>
    </div>

    <div class="filter-bar">
      <input v-model="search" placeholder="Search products…" style="max-width: 320px;" @input="loadProducts" />
      <select v-model="filterCategory" @change="loadProducts" style="width:auto;">
        <option value="">All Categories</option>
        <option v-for="c in categories" :key="c.category_id" :value="c.category_id">{{ c.name }}</option>
      </select>
    </div>

    <div v-if="loading" class="spinner"></div>
    <div v-else class="table-wrap">
      <table>
        <thead>
          <tr><th>Image</th><th>Name</th><th>Category</th><th>Featured</th><th>Status</th><th>Actions</th></tr>
        </thead>
        <tbody>
          <tr v-for="p in products" :key="p.product_id">
            <td><img :src="getThumb(p)" style="width:48px;height:48px;object-fit:cover;border-radius:6px;border:1px solid var(--border);" /></td>
            <td><strong>{{ p.name }}</strong></td>
            <td>{{ p.category_name || '—' }}</td>
            <td><span :class="p.featured ? 'text-green' : 'text-muted'">{{ p.featured ? '★' : '☆' }}</span></td>
            <td><span class="badge" :class="p.status === 'active' ? 'badge-green' : 'badge-muted'">{{ p.status }}</span></td>
            <td class="actions-cell">
              <button class="btn-outline btn-sm" @click="openModal(p)">Edit</button>
              <button class="btn-danger btn-sm" @click="deleteProduct(p.product_id)">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Product Modal -->
    <div v-if="modalOpen" class="modal-overlay" @click.self="modalOpen = false">
      <div class="modal product-modal">
        <button class="modal-close" @click="modalOpen = false">✕</button>
        <h3>{{ editingId ? 'Edit Product' : 'Add Product' }}</h3>
        <div class="accent-line"></div>

        <div v-if="saveSuccess" class="alert alert-success">Product saved successfully!</div>
        <div v-if="saveError" class="alert alert-error">{{ saveError }}</div>

        <div class="modal-form">
          <div class="form-group">
            <label>Product Name *</label>
            <input v-model="form.name" type="text" placeholder="Product name" required />
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Category</label>
              <select v-model="form.category_id">
                <option value="">No category</option>
                <option v-for="c in categories" :key="c.category_id" :value="c.category_id">{{ c.name }}</option>
              </select>
            </div>
            <div class="form-group">
              <label>Status</label>
              <select v-model="form.status">
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label>Description</label>
            <textarea v-model="form.description" rows="3" placeholder="Product description…"></textarea>
          </div>
          <div class="form-group">
            <label>Images (JSON array of URLs)</label>
            <textarea v-model="imagesText" rows="2" placeholder='["https://…", "https://…"]'></textarea>
            <small class="text-muted">Enter a JSON array of image URLs</small>
          </div>
          <div class="form-group">
            <label>Specifications (JSON object)</label>
            <textarea v-model="specsText" rows="4" placeholder='{"Power": "500W", "Voltage": "220V"}'></textarea>
          </div>
          <label class="check-label" style="margin-bottom:1.25rem; display:flex; gap:0.5rem; align-items:center; cursor:pointer;">
            <input type="checkbox" v-model="form.featured" style="width:auto;" />
            <span>Mark as Featured</span>
          </label>
          <div style="display:flex;gap:0.75rem;">
            <button class="btn-primary" @click="saveProduct" :disabled="saving">
              {{ saving ? 'Saving…' : editingId ? 'Update' : 'Create' }}
            </button>
            <button class="btn-outline" @click="modalOpen = false">Cancel</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { productsApi, categoriesApi } from '@/api/index';

const products = ref([]);
const categories = ref([]);
const loading = ref(true);
const search = ref('');
const filterCategory = ref('');
const modalOpen = ref(false);
const editingId = ref(null);
const saving = ref(false);
const saveSuccess = ref(false);
const saveError = ref('');
const imagesText = ref('[]');
const specsText = ref('{}');

const form = ref({ name: '', description: '', category_id: '', status: 'active', featured: false });

function getThumb(p) {
  try {
    const imgs = typeof p.images === 'string' ? JSON.parse(p.images) : p.images;
    return imgs?.[0] || '/placeholder.svg';
  } catch { return '/placeholder.svg'; }
}

async function loadProducts() {
  const params = { limit: 50 };
  if (search.value) params.search = search.value;
  try {
    const { data } = await productsApi.getAll(params);
    products.value = data.products;
  } catch {}
  loading.value = false;
}

function openModal(p = null) {
  saveSuccess.value = false;
  saveError.value = '';
  if (p) {
    editingId.value = p.product_id;
    form.value = { name: p.name, description: p.description || '', category_id: p.category_id || '', status: p.status, featured: !!p.featured };
    imagesText.value = typeof p.images === 'string' ? p.images : JSON.stringify(p.images || []);
    specsText.value = typeof p.specifications === 'string' ? p.specifications : JSON.stringify(p.specifications || {});
  } else {
    editingId.value = null;
    form.value = { name: '', description: '', category_id: '', status: 'active', featured: false };
    imagesText.value = '[]';
    specsText.value = '{}';
  }
  modalOpen.value = true;
}

async function saveProduct() {
  saveError.value = '';
  if (!form.value.name.trim()) { saveError.value = 'Product name is required.'; return; }
  let images, specifications;
  try { images = JSON.parse(imagesText.value); } catch { saveError.value = 'Images must be valid JSON array.'; return; }
  try { specifications = JSON.parse(specsText.value); } catch { saveError.value = 'Specifications must be valid JSON object.'; return; }

  saving.value = true;
  try {
    const payload = { ...form.value, images, specifications };
    if (editingId.value) {
      await productsApi.update(editingId.value, payload);
    } else {
      await productsApi.create(payload);
    }
    saveSuccess.value = true;
    await loadProducts();
    setTimeout(() => { modalOpen.value = false; }, 800);
  } catch (e) {
    saveError.value = e.response?.data?.error || 'Failed to save product.';
  }
  saving.value = false;
}

async function deleteProduct(id) {
  if (!confirm('Delete this product? This cannot be undone.')) return;
  await productsApi.delete(id);
  await loadProducts();
}

onMounted(async () => {
  const [, cats] = await Promise.all([loadProducts(), categoriesApi.getAll()]);
  categories.value = cats.data;
});
</script>

<style scoped>
.admin-page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
.filter-bar { display: flex; gap: 0.75rem; margin-bottom: 1.5rem; flex-wrap: wrap; }
.actions-cell { display: flex; gap: 0.4rem; }
.badge-muted { background: rgba(102,102,102,0.15); color: var(--text-muted); border: 1px solid var(--border); }
.product-modal { max-width: 640px; max-height: 90vh; overflow-y: auto; }
.product-modal h3 { margin-bottom: 0.25rem; }
.modal-form { margin-top: 0.75rem; }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
</style>
