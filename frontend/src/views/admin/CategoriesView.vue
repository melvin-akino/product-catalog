<template>
  <div>
    <div class="admin-page-header">
      <h2>Categories</h2>
      <button class="btn-primary" @click="openModal()">+ Add Category</button>
    </div>

    <div v-if="loading" class="spinner"></div>
    <div v-else class="table-wrap">
      <table>
        <thead><tr><th>Priority</th><th>Name</th><th>Slug</th><th>Products</th><th>Description</th><th>Actions</th></tr></thead>
        <tbody>
          <tr v-for="c in categories" :key="c.category_id">
            <td style="text-align:center;">
              <span class="priority-badge" :class="c.display_priority < 999 ? 'priority-set' : 'priority-default'">
                {{ c.display_priority < 999 ? c.display_priority : '—' }}
              </span>
            </td>
            <td><strong>{{ c.name }}</strong></td>
            <td><code style="font-size:0.8rem;color:var(--text-muted);">{{ c.slug }}</code></td>
            <td>{{ c.product_count }}</td>
            <td class="text-muted" style="font-size:0.85rem;max-width:240px;">{{ c.description || '—' }}</td>
            <td>
              <div class="actions-cell">
                <button class="btn-outline btn-sm" @click="openModal(c)">Edit</button>
                <button class="btn-danger btn-sm" @click="deleteCategory(c.category_id)">Delete</button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="modalOpen" class="modal-overlay">
      <div class="modal">
        <button class="modal-close" @click="modalOpen=false">✕</button>
        <h3>{{ editingId ? 'Edit Category' : 'Add Category' }}</h3>
        <div class="accent-line"></div>
        <div v-if="success" class="alert alert-success">Category saved!</div>
        <div v-if="err" class="alert alert-error">{{ err }}</div>
        <div class="form-group"><label>Name *</label><input v-model="form.name" placeholder="Category name" /></div>
        <div class="form-group"><label>Description</label><textarea v-model="form.description" rows="3" placeholder="Brief description…"></textarea></div>
        <div class="form-group">
          <label>Display Priority <span style="font-weight:400;color:var(--text-muted);font-size:0.8rem;">(lower number = shown first in catalog; leave blank for default)</span></label>
          <input v-model.number="form.display_priority" type="number" min="1" max="999" placeholder="e.g. 1, 2, 3…" style="max-width:160px;" />
        </div>
        <div style="display:flex;gap:0.75rem;margin-top:0.5rem;">
          <button class="btn-primary" @click="save" :disabled="saving">{{ saving ? 'Saving…' : 'Save' }}</button>
          <button class="btn-outline" @click="modalOpen=false">Cancel</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import { categoriesApi } from '@/api/index';

const categories = ref([]);
const loading = ref(true);
const modalOpen = ref(false);
const editingId = ref(null);
const saving = ref(false);
const success = ref(false);
const err = ref('');
const form = ref({ name: '', description: '' });

async function load() {
  const { data } = await categoriesApi.getAll();
  categories.value = data;
  loading.value = false;
}

function openModal(c = null) {
  success.value = false; err.value = '';
  editingId.value = c ? c.category_id : null;
  form.value = c ? { name: c.name, description: c.description || '', display_priority: c.display_priority < 999 ? c.display_priority : null } : { name: '', description: '', display_priority: null };
  modalOpen.value = true;
}

async function save() {
  if (!form.value.name.trim()) { err.value = 'Name is required.'; return; }
  saving.value = true;
  try {
    const payload = { ...form.value, display_priority: form.value.display_priority || 999 };
    if (editingId.value) await categoriesApi.update(editingId.value, payload);
    else await categoriesApi.create(payload);
    success.value = true;
    await load();
    setTimeout(() => { modalOpen.value = false; }, 600);
  } catch (e) { err.value = e.response?.data?.error || 'Failed to save.'; }
  saving.value = false;
}

async function deleteCategory(id) {
  if (!confirm('Delete this category?')) return;
  await categoriesApi.delete(id);
  await load();
}

function onKeyDown(e) { if (e.key === 'Escape') modalOpen.value = false; }
onMounted(() => { document.addEventListener('keydown', onKeyDown); load(); });
onUnmounted(() => document.removeEventListener('keydown', onKeyDown));
</script>

<style scoped>
.admin-page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
.actions-cell { display: flex; gap: 0.4rem; }
.priority-badge {
  display: inline-block; padding: 0.2rem 0.55rem;
  border-radius: 999px; font-size: 0.78rem; font-weight: 700;
}
.priority-set { background: var(--green-glow); color: var(--green-primary); border: 1px solid var(--green-border); }
.priority-default { color: var(--text-muted); }
</style>
