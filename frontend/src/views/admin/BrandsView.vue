<template>
  <div>
    <div class="page-header">
      <div>
        <h1 class="page-title">Trusted Brands</h1>
        <p class="page-sub">Brands displayed in the scrolling ticker on the homepage</p>
      </div>
      <button class="btn-primary" @click="openModal()">
        <Plus :size="15" /> Add Brand
      </button>
    </div>

    <div v-if="alert.msg" class="alert" :class="`alert-${alert.type}`">{{ alert.msg }}</div>

    <div class="card table-card">
      <div v-if="loading" class="spinner"></div>
      <div v-else-if="!brands.length" class="empty-state">
        <Award :size="40" class="empty-icon" />
        <p>No brands yet. Add your first trusted brand above.</p>
      </div>
      <div v-else class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Logo</th>
              <th>Brand Name</th>
              <th>Website</th>
              <th>Order</th>
              <th>Status</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="b in brands" :key="b.brand_id">
              <td>
                <div class="logo-cell">
                  <img v-if="b.logo_url" :src="b.logo_url" :alt="b.name" class="brand-logo" @error="e => e.target.style.display='none'" />
                  <div v-else class="logo-placeholder"><ImageOff :size="16" /></div>
                </div>
              </td>
              <td><strong>{{ b.name }}</strong></td>
              <td>
                <a v-if="b.website_url" :href="b.website_url" target="_blank" rel="noopener" class="text-green site-link">
                  {{ b.website_url.replace(/^https?:\/\//, '') }}
                </a>
                <span v-else class="text-muted">—</span>
              </td>
              <td class="text-muted">{{ b.sort_order }}</td>
              <td>
                <button class="status-toggle" :class="b.active ? 'active' : 'inactive'" @click="toggleActive(b)">
                  <span class="status-dot"></span>
                  {{ b.active ? 'Visible' : 'Hidden' }}
                </button>
              </td>
              <td>
                <div class="row-actions">
                  <button class="icon-btn" title="Edit" @click="openModal(b)"><Pencil :size="14" /></button>
                  <button class="icon-btn danger" title="Delete" @click="confirmDelete(b)"><Trash2 :size="14" /></button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Create / Edit Modal -->
    <div v-if="modalOpen" class="modal-overlay">
      <div class="modal">
        <button class="modal-close" @click="closeModal"><X :size="16" /></button>
        <h3 class="modal-title">{{ editingId ? 'Edit Brand' : 'Add Brand' }}</h3>

        <div class="form-group">
          <label>Brand Name *</label>
          <input v-model="form.name" type="text" placeholder="e.g. Philips" required />
        </div>

        <div class="form-group">
          <label>Logo URL</label>
          <input v-model="form.logo_url" type="url" placeholder="https://…/logo.png" />
          <div v-if="form.logo_url" class="logo-preview-wrap">
            <img :src="form.logo_url" class="logo-preview" alt="Preview" @error="e => e.target.style.opacity='0.2'" />
          </div>
        </div>

        <div class="form-group">
          <label>Website URL</label>
          <input v-model="form.website_url" type="url" placeholder="https://brand.com" />
        </div>

        <div class="form-row">
          <div class="form-group">
            <label>Sort Order</label>
            <input v-model.number="form.sort_order" type="number" min="0" placeholder="0" />
          </div>
          <div class="form-group toggle-group">
            <label>Visibility</label>
            <label class="check-label">
              <input type="checkbox" v-model="form.active" style="width:auto;" />
              <span>Show on site</span>
            </label>
          </div>
        </div>

        <div v-if="formError" class="form-error">{{ formError }}</div>

        <div class="modal-actions">
          <button class="btn-outline" @click="closeModal">Cancel</button>
          <button class="btn-primary" @click="save" :disabled="saving">
            {{ saving ? 'Saving…' : 'Save Brand' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Delete confirm -->
    <div v-if="deleteTarget" class="modal-overlay">
      <div class="modal modal-sm">
        <button class="modal-close" @click="deleteTarget = null"><X :size="16" /></button>
        <div class="delete-icon-wrap"><Trash2 :size="28" /></div>
        <h3 class="modal-title">Delete Brand?</h3>
        <p class="delete-msg">
          This will permanently remove <strong>{{ deleteTarget.name }}</strong>.
        </p>
        <div class="modal-actions">
          <button class="btn-outline" @click="deleteTarget = null">Cancel</button>
          <button class="btn-danger" @click="doDelete" :disabled="saving">
            {{ saving ? 'Deleting…' : 'Delete' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import { Plus, Pencil, Trash2, X, Award, ImageOff } from 'lucide-vue-next';
import { brandsApi } from '@/api/index';

const brands = ref([]);
const loading = ref(true);
const saving = ref(false);
const modalOpen = ref(false);
const editingId = ref(null);
const deleteTarget = ref(null);
const formError = ref('');
const alert = ref({ msg: '', type: 'success' });

const form = ref({ name: '', logo_url: '', website_url: '', sort_order: 0, active: true });

async function load() {
  loading.value = true;
  try {
    const { data } = await brandsApi.getAll();
    brands.value = data;
  } catch {
    showAlert('Failed to load brands.', 'error');
  }
  loading.value = false;
}

function openModal(b = null) {
  formError.value = '';
  editingId.value = b ? b.brand_id : null;
  form.value = b
    ? { name: b.name, logo_url: b.logo_url || '', website_url: b.website_url || '', sort_order: b.sort_order ?? 0, active: !!b.active }
    : { name: '', logo_url: '', website_url: '', sort_order: 0, active: true };
  modalOpen.value = true;
}

function closeModal() { modalOpen.value = false; }

async function save() {
  formError.value = '';
  if (!form.value.name.trim()) { formError.value = 'Brand name is required.'; return; }
  saving.value = true;
  try {
    if (editingId.value) {
      await brandsApi.update(editingId.value, form.value);
      showAlert('Brand updated.');
    } else {
      await brandsApi.create(form.value);
      showAlert('Brand added.');
    }
    closeModal();
    await load();
  } catch {
    formError.value = 'Failed to save. Please try again.';
  }
  saving.value = false;
}

function confirmDelete(b) { deleteTarget.value = b; }

async function doDelete() {
  saving.value = true;
  try {
    await brandsApi.delete(deleteTarget.value.brand_id);
    showAlert(`"${deleteTarget.value.name}" deleted.`);
    deleteTarget.value = null;
    await load();
  } catch {
    showAlert('Failed to delete.', 'error');
  }
  saving.value = false;
}

async function toggleActive(b) {
  try {
    await brandsApi.update(b.brand_id, { ...b, active: !b.active });
    b.active = !b.active;
  } catch {
    showAlert('Failed to update status.', 'error');
  }
}

function showAlert(msg, type = 'success') {
  alert.value = { msg, type };
  setTimeout(() => { alert.value.msg = ''; }, 4000);
}

function onKeyDown(e) {
  if (e.key !== 'Escape') return;
  if (deleteTarget.value) { deleteTarget.value = null; return; }
  if (modalOpen.value) closeModal();
}
onMounted(() => { document.addEventListener('keydown', onKeyDown); load(); });
onUnmounted(() => document.removeEventListener('keydown', onKeyDown));
</script>

<style scoped>
.page-header {
  display: flex; justify-content: space-between; align-items: flex-start;
  margin-bottom: 1.5rem; flex-wrap: wrap; gap: 1rem;
}
.page-title { font-size: 1.35rem; font-weight: 800; margin-bottom: 0.2rem; }
.page-sub { color: var(--text-muted); font-size: 0.875rem; }
.btn-primary { display: flex; align-items: center; gap: 0.45rem; }

.table-card { padding: 0; overflow: hidden; }
.empty-state { padding: 4rem; text-align: center; color: var(--text-muted); }
.empty-icon { margin: 0 auto 1rem; opacity: 0.4; }

/* Logo cell */
.logo-cell { width: 56px; height: 36px; display: flex; align-items: center; }
.brand-logo { max-width: 56px; max-height: 36px; object-fit: contain; border-radius: 4px; background: rgba(255,255,255,0.04); padding: 2px; }
.logo-placeholder { width: 40px; height: 36px; display: flex; align-items: center; justify-content: center; color: var(--border-light); }

.site-link { font-size: 0.82rem; text-decoration: none; }
.site-link:hover { text-decoration: underline; }
.text-muted { color: var(--text-muted); }

/* Status toggle */
.status-toggle {
  display: inline-flex; align-items: center; gap: 0.4rem;
  font-size: 0.78rem; font-weight: 600;
  background: none; border-radius: 999px; padding: 0.2rem 0.6rem;
  border: 1px solid; cursor: pointer; transition: all 0.2s;
}
.status-toggle.active { color: var(--green-primary); border-color: var(--green-border); background: var(--green-glow); }
.status-toggle.inactive { color: var(--text-muted); border-color: var(--border); }
.status-dot { width: 6px; height: 6px; border-radius: 50%; flex-shrink: 0; }
.status-toggle.active .status-dot { background: var(--green-primary); }
.status-toggle.inactive .status-dot { background: var(--text-muted); }

/* Row actions */
.row-actions { display: flex; gap: 0.25rem; justify-content: flex-end; }
.icon-btn {
  width: 30px; height: 30px; border-radius: var(--radius);
  background: none; border: 1px solid var(--border);
  color: var(--text-muted); display: flex; align-items: center; justify-content: center;
  transition: all 0.2s;
}
.icon-btn:hover { border-color: var(--border-light); color: var(--text-primary); background: var(--bg-card-hover); }
.icon-btn.danger:hover { color: #ef5350; border-color: rgba(239,83,80,0.4); background: rgba(239,83,80,0.08); }

/* Modal */
.modal-sm { max-width: 400px; }
.modal-title { font-size: 1.1rem; font-weight: 700; margin-bottom: 1.25rem; }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
.toggle-group { display: flex; flex-direction: column; }
.check-label { display: flex; align-items: center; gap: 0.5rem; cursor: pointer; margin-top: 0.5rem; font-size: 0.9rem; }
.modal-actions { display: flex; justify-content: flex-end; gap: 0.75rem; margin-top: 1.5rem; }

/* Logo preview */
.logo-preview-wrap { margin-top: 0.5rem; background: rgba(255,255,255,0.04); border: 1px solid var(--border); border-radius: var(--radius); padding: 0.5rem; display: inline-block; }
.logo-preview { max-height: 48px; max-width: 160px; object-fit: contain; display: block; }

/* Delete modal */
.delete-icon-wrap {
  width: 56px; height: 56px; border-radius: 50%;
  background: rgba(239,83,80,0.1); border: 1px solid rgba(239,83,80,0.3);
  display: flex; align-items: center; justify-content: center;
  color: #ef5350; margin: 0 auto 1.25rem;
}
.modal-title { text-align: center; }
.delete-msg { color: var(--text-secondary); font-size: 0.9rem; text-align: center; line-height: 1.6; }
.delete-msg strong { color: var(--text-primary); }
</style>
