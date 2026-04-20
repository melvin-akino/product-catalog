<template>
  <div>
    <div class="admin-page-header">
      <h2>Categories</h2>
      <button class="btn-primary" @click="openModal()">+ Add Category</button>
    </div>

    <div v-if="loading" class="spinner"></div>
    <div v-else class="table-wrap">
      <table>
        <thead><tr><th>Name</th><th>Slug</th><th>Products</th><th>Description</th><th>Actions</th></tr></thead>
        <tbody>
          <tr v-for="c in categories" :key="c.category_id">
            <td><strong>{{ c.name }}</strong></td>
            <td><code style="font-size:0.8rem;color:var(--text-muted);">{{ c.slug }}</code></td>
            <td>{{ c.product_count }}</td>
            <td class="text-muted" style="font-size:0.85rem;max-width:240px;">{{ c.description || '—' }}</td>
            <td class="actions-cell">
              <button class="btn-outline btn-sm" @click="openModal(c)">Edit</button>
              <button class="btn-danger btn-sm" @click="deleteCategory(c.category_id)">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="modalOpen" class="modal-overlay" @click.self="modalOpen=false">
      <div class="modal">
        <button class="modal-close" @click="modalOpen=false">✕</button>
        <h3>{{ editingId ? 'Edit Category' : 'Add Category' }}</h3>
        <div class="accent-line"></div>
        <div v-if="success" class="alert alert-success">Category saved!</div>
        <div v-if="err" class="alert alert-error">{{ err }}</div>
        <div class="form-group"><label>Name *</label><input v-model="form.name" placeholder="Category name" /></div>
        <div class="form-group"><label>Description</label><textarea v-model="form.description" rows="3" placeholder="Brief description…"></textarea></div>
        <div style="display:flex;gap:0.75rem;margin-top:0.5rem;">
          <button class="btn-primary" @click="save" :disabled="saving">{{ saving ? 'Saving…' : 'Save' }}</button>
          <button class="btn-outline" @click="modalOpen=false">Cancel</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
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
  form.value = c ? { name: c.name, description: c.description || '' } : { name: '', description: '' };
  modalOpen.value = true;
}

async function save() {
  if (!form.value.name.trim()) { err.value = 'Name is required.'; return; }
  saving.value = true;
  try {
    if (editingId.value) await categoriesApi.update(editingId.value, form.value);
    else await categoriesApi.create(form.value);
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

onMounted(load);
</script>

<style scoped>
.admin-page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
.actions-cell { display: flex; gap: 0.4rem; }
</style>
