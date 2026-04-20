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
            <td>
              <img
                :src="resolveImage(getThumb(p))"
                style="width:48px;height:48px;object-fit:cover;border-radius:6px;border:1px solid var(--border);"
                @error="e => e.target.src = '/placeholder.svg'"
              />
            </td>
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

          <!-- ── Image Manager ─────────────────────────── -->
          <div class="form-group">
            <label>Product Images</label>

            <!-- Current images -->
            <div v-if="imageList.length" class="image-grid">
              <div v-for="(img, idx) in imageList" :key="idx" class="image-thumb-wrap">
                <img :src="resolveImage(img)" class="image-thumb" @error="e => e.target.src = '/placeholder.svg'" />
                <button class="image-remove" @click="removeImage(idx)" title="Remove">✕</button>
                <span v-if="idx === 0" class="image-primary-badge">Main</span>
              </div>
            </div>
            <p v-else class="text-muted" style="font-size:0.85rem;margin-bottom:0.5rem;">No images yet</p>

            <!-- Upload files -->
            <div
              class="upload-zone"
              :class="{ dragging: isDragging }"
              @dragover.prevent="isDragging = true"
              @dragleave="isDragging = false"
              @drop.prevent="onDrop"
              @click="$refs.fileInput.click()"
            >
              <input ref="fileInput" type="file" accept="image/*" multiple hidden @change="onFilePick" />
              <span v-if="uploading" class="upload-text">Uploading…</span>
              <span v-else class="upload-text">
                <strong>Click to browse</strong> or drag &amp; drop images here
                <em>(JPG, PNG, WebP — max 5 MB each)</em>
              </span>
            </div>

            <!-- Add by URL -->
            <div class="url-add-row">
              <input v-model="urlInput" placeholder="Or paste an image URL…" @keydown.enter.prevent="addUrl" />
              <button class="btn-outline btn-sm" @click="addUrl" :disabled="!urlInput.trim()">Add URL</button>
            </div>
          </div>
          <!-- ── / Image Manager ────────────────────────── -->

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
import { productsApi, categoriesApi, uploadApi } from '@/api/index';

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
const specsText = ref('{}');

// Image manager state
const imageList = ref([]);   // array of URL strings (absolute or /uploads/…)
const urlInput = ref('');
const isDragging = ref(false);
const uploading = ref(false);
const fileInput = ref(null);

const form = ref({ name: '', description: '', category_id: '', status: 'active', featured: false });

// ── helpers ──────────────────────────────────────────
function resolveImage(src) {
  if (!src) return '/placeholder.svg';
  // Already absolute URL — use as-is
  if (src.startsWith('http://') || src.startsWith('https://')) return src;
  // Relative path (e.g. /uploads/file.jpg) — prepend origin
  return src;
}

function getThumb(p) {
  try {
    const imgs = typeof p.images === 'string' ? JSON.parse(p.images) : p.images;
    return imgs?.[0] || null;
  } catch { return null; }
}

function removeImage(idx) { imageList.value.splice(idx, 1); }

function addUrl() {
  const url = urlInput.value.trim();
  if (!url) return;
  if (!imageList.value.includes(url)) imageList.value.push(url);
  urlInput.value = '';
}

async function uploadFiles(files) {
  if (!files.length) return;
  uploading.value = true;
  saveError.value = '';
  try {
    const { data } = await uploadApi.uploadImages(Array.from(files));
    imageList.value.push(...data.urls);
  } catch (e) {
    saveError.value = e.response?.data?.error || 'Upload failed. Check file size and format.';
  }
  uploading.value = false;
}

function onFilePick(e) { uploadFiles(e.target.files); e.target.value = ''; }
function onDrop(e) {
  isDragging.value = false;
  uploadFiles(e.dataTransfer.files);
}

// ── data ─────────────────────────────────────────────
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
  urlInput.value = '';
  isDragging.value = false;
  if (p) {
    editingId.value = p.product_id;
    form.value = { name: p.name, description: p.description || '', category_id: p.category_id || '', status: p.status, featured: !!p.featured };
    const imgs = typeof p.images === 'string' ? JSON.parse(p.images) : (p.images || []);
    imageList.value = Array.isArray(imgs) ? [...imgs] : [];
    specsText.value = typeof p.specifications === 'string' ? p.specifications : JSON.stringify(p.specifications || {});
  } else {
    editingId.value = null;
    form.value = { name: '', description: '', category_id: '', status: 'active', featured: false };
    imageList.value = [];
    specsText.value = '{}';
  }
  modalOpen.value = true;
}

async function saveProduct() {
  saveError.value = '';
  if (!form.value.name.trim()) { saveError.value = 'Product name is required.'; return; }
  let specifications;
  try { specifications = JSON.parse(specsText.value); } catch { saveError.value = 'Specifications must be valid JSON object.'; return; }

  saving.value = true;
  try {
    const payload = { ...form.value, images: imageList.value, specifications };
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
.product-modal { max-width: 660px; max-height: 90vh; overflow-y: auto; }
.product-modal h3 { margin-bottom: 0.25rem; }
.modal-form { margin-top: 0.75rem; }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }

/* Image manager */
.image-grid {
  display: flex; flex-wrap: wrap; gap: 0.5rem;
  margin-bottom: 0.75rem;
}
.image-thumb-wrap {
  position: relative; width: 80px; height: 80px; flex-shrink: 0;
}
.image-thumb {
  width: 100%; height: 100%; object-fit: cover;
  border-radius: var(--radius); border: 1px solid var(--border);
}
.image-remove {
  position: absolute; top: -6px; right: -6px;
  width: 20px; height: 20px; border-radius: 50%;
  background: #ef5350; color: #fff; font-size: 0.65rem;
  display: flex; align-items: center; justify-content: center;
  cursor: pointer; border: 2px solid var(--bg-secondary);
  line-height: 1;
}
.image-primary-badge {
  position: absolute; bottom: 2px; left: 2px;
  font-size: 0.55rem; font-weight: 700; text-transform: uppercase;
  background: var(--green-primary); color: #000;
  padding: 1px 4px; border-radius: 3px;
}

.upload-zone {
  border: 2px dashed var(--border);
  border-radius: var(--radius);
  padding: 1.25rem;
  text-align: center;
  cursor: pointer;
  transition: border-color 0.2s, background 0.2s;
  margin-bottom: 0.6rem;
}
.upload-zone:hover, .upload-zone.dragging {
  border-color: var(--green-primary);
  background: var(--green-glow);
}
.upload-text {
  font-size: 0.85rem; color: var(--text-secondary);
  display: flex; flex-direction: column; gap: 0.25rem; align-items: center;
}
.upload-text strong { color: var(--green-primary); }
.upload-text em { color: var(--text-muted); font-style: normal; font-size: 0.78rem; }

.url-add-row {
  display: flex; gap: 0.5rem;
}
.url-add-row input { flex: 1; }
</style>
