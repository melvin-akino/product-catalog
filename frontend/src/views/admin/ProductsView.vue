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
        <option v-for="c in categories" :key="c.category_id" :value="c.slug">{{ c.name }}</option>
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
            <td>
              <button class="toggle-btn" :class="p.featured ? 'toggle-on' : 'toggle-off'" @click="toggleFeatured(p)" title="Toggle featured">
                {{ p.featured ? '★' : '☆' }}
              </button>
            </td>
            <td>
              <button class="badge status-toggle" :class="p.status === 'active' ? 'badge-green' : 'badge-inactive'" @click="toggleStatus(p)">
                {{ p.status || 'inactive' }}
              </button>
            </td>
            <td>
              <div class="actions-cell">
                <button class="btn-outline btn-sm" @click="openModal(p)">Edit</button>
                <button class="btn-danger btn-sm" @click="deleteProduct(p.product_id)">Delete</button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Product Modal -->
    <div v-if="modalOpen" class="modal-overlay">
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

          <!-- Image Manager -->
          <div class="form-group">
            <label>Product Images</label>
            <div v-if="imageList.length" class="image-grid">
              <div v-for="(img, idx) in imageList" :key="idx" class="image-thumb-wrap">
                <img :src="resolveImage(img)" class="image-thumb" @error="e => e.target.src = '/placeholder.svg'" />
                <button class="image-remove" @click="removeImage(idx)" title="Remove">✕</button>
                <span v-if="idx === 0" class="image-primary-badge">Main</span>
              </div>
            </div>
            <p v-else class="text-muted" style="font-size:0.85rem;margin-bottom:0.5rem;">No images yet</p>
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
            <div class="url-add-row">
              <input v-model="urlInput" placeholder="Or paste an image URL…" @keydown.enter.prevent="addUrl" />
              <button class="btn-outline btn-sm" @click="addUrl" :disabled="!urlInput.trim()">Add URL</button>
            </div>
          </div>

          <!-- Specifications Table Editor -->
          <div class="form-group">
            <label>Specifications</label>
            <div class="spec-editor">
              <div class="spec-header-row">
                <span class="spec-col-label">Specification</span>
                <span class="spec-col-label">Value</span>
                <span style="width:32px;"></span>
              </div>
              <div v-for="(row, idx) in specRows" :key="idx" class="spec-row">
                <input v-model="row.key" class="spec-input" placeholder="e.g. Wattage" />
                <input v-model="row.value" class="spec-input" placeholder="e.g. 100W / 150W / 200W" />
                <button class="spec-del-btn" @click="removeSpecRow(idx)" title="Remove row">✕</button>
              </div>
              <button class="btn-outline btn-sm spec-add-btn" @click="addSpecRow">+ Add Row</button>
            </div>
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
import { ref, onMounted, onUnmounted } from 'vue';
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

// Image manager state
const imageList = ref([]);
const urlInput = ref('');
const isDragging = ref(false);
const uploading = ref(false);
const fileInput = ref(null);

// Spec table editor
const specRows = ref([{ key: '', value: '' }]);

const form = ref({ name: '', description: '', category_id: '', status: 'active', featured: false });

// ── Spec helpers ─────────────────────────────────────────────
function parseSpecHtml(html) {
  if (!html?.trim()) return [{ key: '', value: '' }];
  try {
    const doc = new DOMParser().parseFromString(html, 'text/html');
    const rows = [];
    doc.querySelectorAll('tr').forEach(tr => {
      const tds = tr.querySelectorAll('td, th');
      if (tds.length === 2) {
        rows.push({ key: tds[0].textContent.trim(), value: tds[1].textContent.trim() });
      } else if (tds.length > 2) {
        // Legacy: all specs packed into one row as consecutive key/value td pairs
        for (let i = 0; i + 1 < tds.length; i += 2) {
          rows.push({ key: tds[i].textContent.trim(), value: tds[i + 1].textContent.trim() });
        }
      }
    });
    return rows.length ? rows : [{ key: '', value: '' }];
  } catch {
    return [{ key: '', value: '' }];
  }
}

function buildSpecHtml(rows) {
  const filled = rows.filter(r => r.key.trim() || r.value.trim());
  if (!filled.length) return null;
  const trs = filled.map(r =>
    `<tr><td><strong>${esc(r.key)}</strong></td><td>${esc(r.value)}</td></tr>`
  ).join('');
  return `<table><tbody>${trs}</tbody></table>`;
}

function esc(s) {
  return String(s ?? '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function addSpecRow() { specRows.value.push({ key: '', value: '' }); }
function removeSpecRow(idx) {
  if (specRows.value.length > 1) specRows.value.splice(idx, 1);
  else specRows.value[0] = { key: '', value: '' };
}

// ── Image helpers ─────────────────────────────────────────────
function resolveImage(src) {
  if (!src) return '/placeholder.svg';
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
    saveError.value = e.response?.data?.error || 'Upload failed.';
  }
  uploading.value = false;
}

function onFilePick(e) { uploadFiles(e.target.files); e.target.value = ''; }
function onDrop(e) { isDragging.value = false; uploadFiles(e.dataTransfer.files); }

// ── Data ─────────────────────────────────────────────────────
async function loadProducts() {
  const params = { limit: 50 };
  if (search.value) params.search = search.value;
  if (filterCategory.value) params.category = filterCategory.value;
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
    form.value = { name: p.name, description: p.description || '', category_id: p.category_id || '', status: p.status || 'active', featured: !!p.featured };
    const imgs = typeof p.images === 'string' ? JSON.parse(p.images) : (p.images || []);
    imageList.value = Array.isArray(imgs) ? [...imgs] : [];
    specRows.value = parseSpecHtml(typeof p.specifications === 'string' ? p.specifications : '');
  } else {
    editingId.value = null;
    form.value = { name: '', description: '', category_id: '', status: 'active', featured: false };
    imageList.value = [];
    specRows.value = [{ key: '', value: '' }];
  }
  modalOpen.value = true;
}

async function saveProduct() {
  saveError.value = '';
  if (!form.value.name.trim()) { saveError.value = 'Product name is required.'; return; }
  saving.value = true;
  try {
    const payload = { ...form.value, images: imageList.value, specifications: buildSpecHtml(specRows.value) };
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

// ── Inline toggles ───────────────────────────────────────────
async function toggleStatus(p) {
  const newStatus = p.status === 'active' ? 'inactive' : 'active';
  try {
    const imgs = typeof p.images === 'string' ? JSON.parse(p.images || '[]') : (p.images || []);
    await productsApi.update(p.product_id, {
      name: p.name, description: p.description, specifications: p.specifications,
      images: imgs, category_id: p.category_id, featured: p.featured, status: newStatus,
    });
    p.status = newStatus;
  } catch {}
}

async function toggleFeatured(p) {
  const newFeatured = !p.featured;
  try {
    const imgs = typeof p.images === 'string' ? JSON.parse(p.images || '[]') : (p.images || []);
    await productsApi.update(p.product_id, {
      name: p.name, description: p.description, specifications: p.specifications,
      images: imgs, category_id: p.category_id, featured: newFeatured, status: p.status,
    });
    p.featured = newFeatured;
  } catch {}
}

function onKeyDown(e) { if (e.key === 'Escape') modalOpen.value = false; }
onMounted(async () => {
  document.addEventListener('keydown', onKeyDown);
  const [, cats] = await Promise.all([loadProducts(), categoriesApi.getAll()]);
  categories.value = cats.data;
});
onUnmounted(() => document.removeEventListener('keydown', onKeyDown));
</script>

<style scoped>
.admin-page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
.filter-bar { display: flex; gap: 0.75rem; margin-bottom: 1.5rem; flex-wrap: wrap; }
.actions-cell { display: flex; gap: 0.4rem; }
.product-modal { max-width: 660px; max-height: 90vh; overflow-y: auto; }
.product-modal h3 { margin-bottom: 0.25rem; }
.modal-form { margin-top: 0.75rem; }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }

/* Inline toggles */
.toggle-btn {
  background: none; border: none; font-size: 1.1rem;
  cursor: pointer; padding: 0.1rem 0.3rem; border-radius: 4px;
  transition: transform 0.15s;
}
.toggle-btn:hover { transform: scale(1.2); }
.toggle-on { color: var(--green-primary); }
.toggle-off { color: var(--text-muted); }

.status-toggle {
  cursor: pointer;
  border: none;
  font-size: 0.75rem;
  font-weight: 600;
  letter-spacing: 0.04em;
  padding: 0.2rem 0.7rem;
  border-radius: 999px;
  transition: opacity 0.15s, transform 0.15s;
}
.status-toggle:hover { opacity: 0.8; transform: scale(1.05); }
.badge-inactive {
  background: rgba(102,102,102,0.15);
  color: var(--text-muted);
  border: 1px solid var(--border);
}

/* Image manager */
.image-grid { display: flex; flex-wrap: wrap; gap: 0.5rem; margin-bottom: 0.75rem; }
.image-thumb-wrap { position: relative; width: 80px; height: 80px; flex-shrink: 0; }
.image-thumb { width: 100%; height: 100%; object-fit: cover; border-radius: var(--radius); border: 1px solid var(--border); }
.image-remove {
  position: absolute; top: -6px; right: -6px;
  width: 20px; height: 20px; border-radius: 50%;
  background: #ef5350; color: #fff; font-size: 0.65rem;
  display: flex; align-items: center; justify-content: center;
  cursor: pointer; border: 2px solid var(--bg-secondary); line-height: 1;
}
.image-primary-badge {
  position: absolute; bottom: 2px; left: 2px;
  font-size: 0.55rem; font-weight: 700; text-transform: uppercase;
  background: var(--green-primary); color: #000;
  padding: 1px 4px; border-radius: 3px;
}
.upload-zone {
  border: 2px dashed var(--border); border-radius: var(--radius);
  padding: 1.25rem; text-align: center; cursor: pointer;
  transition: border-color 0.2s, background 0.2s; margin-bottom: 0.6rem;
}
.upload-zone:hover, .upload-zone.dragging { border-color: var(--green-primary); background: var(--green-glow); }
.upload-text { font-size: 0.85rem; color: var(--text-secondary); display: flex; flex-direction: column; gap: 0.25rem; align-items: center; }
.upload-text strong { color: var(--green-primary); }
.upload-text em { color: var(--text-muted); font-style: normal; font-size: 0.78rem; }
.url-add-row { display: flex; gap: 0.5rem; }
.url-add-row input { flex: 1; }

/* Spec table editor */
.spec-editor {
  border: 1px solid var(--border-light);
  border-radius: var(--radius);
  overflow: hidden;
}
.spec-header-row {
  display: grid;
  grid-template-columns: 1fr 1fr 32px;
  gap: 0;
  background: var(--bg-secondary);
  padding: 0.5rem 0.75rem;
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--text-muted);
}
.spec-row {
  display: grid;
  grid-template-columns: 1fr 1fr 32px;
  gap: 0;
  border-top: 1px solid var(--border);
}
.spec-input {
  border: none;
  border-right: 1px solid var(--border);
  border-radius: 0;
  background: var(--bg-card);
  color: var(--text-primary);
  font-size: 0.875rem;
  padding: 0.6rem 0.75rem;
  width: 100%;
  transition: background 0.15s;
}
.spec-input:last-of-type { border-right: none; }
.spec-input:focus { background: var(--bg-card-hover); outline: none; box-shadow: none; border-color: transparent; }
.spec-del-btn {
  background: transparent; border: none; color: var(--text-muted);
  font-size: 0.7rem; cursor: pointer; display: flex;
  align-items: center; justify-content: center;
  transition: color 0.15s;
}
.spec-del-btn:hover { color: #ef5350; }
.spec-add-btn { margin: 0.6rem; }
</style>
