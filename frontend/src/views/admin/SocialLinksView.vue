<template>
  <div>
    <div class="admin-page-header">
      <h2>Social Media Links</h2>
      <button class="btn-primary" @click="openModal()">+ Add Link</button>
    </div>

    <div v-if="loading" class="spinner"></div>
    <div v-else class="table-wrap">
      <table>
        <thead><tr><th>Platform</th><th>URL</th><th>Active</th><th>Order</th><th>Actions</th></tr></thead>
        <tbody>
          <tr v-for="link in links" :key="link.link_id">
            <td><strong>{{ link.platform }}</strong></td>
            <td><a :href="link.url" target="_blank" class="text-green" style="font-size:0.85rem;">{{ link.url }}</a></td>
            <td><span class="badge" :class="link.active ? 'badge-green' : 'badge-muted'">{{ link.active ? 'Active' : 'Hidden' }}</span></td>
            <td>{{ link.sort_order }}</td>
            <td class="actions-cell">
              <button class="btn-outline btn-sm" @click="openModal(link)">Edit</button>
              <button class="btn-danger btn-sm" @click="deleteLink(link.link_id)">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="modalOpen" class="modal-overlay" @click.self="modalOpen=false">
      <div class="modal">
        <button class="modal-close" @click="modalOpen=false">✕</button>
        <h3>{{ editingId ? 'Edit Link' : 'Add Social Link' }}</h3>
        <div class="accent-line"></div>
        <div v-if="saved" class="alert alert-success">Saved!</div>
        <div class="form-group"><label>Platform *</label><input v-model="form.platform" placeholder="Facebook, Instagram, X…" /></div>
        <div class="form-group"><label>URL *</label><input v-model="form.url" type="url" placeholder="https://…" /></div>
        <div class="form-row">
          <div class="form-group"><label>Sort Order</label><input v-model.number="form.sort_order" type="number" /></div>
        </div>
        <label class="check-label" style="margin-bottom:1.25rem; display:flex; gap:0.5rem; align-items:center; cursor:pointer;">
          <input type="checkbox" v-model="form.active" style="width:auto;" />
          <span>Active / Visible</span>
        </label>
        <div style="display:flex;gap:0.75rem;">
          <button class="btn-primary" @click="save" :disabled="saving">{{ saving ? 'Saving…' : 'Save' }}</button>
          <button class="btn-outline" @click="modalOpen=false">Cancel</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { socialApi } from '@/api/index';

const links = ref([]);
const loading = ref(true);
const modalOpen = ref(false);
const editingId = ref(null);
const saving = ref(false);
const saved = ref(false);
const form = ref({ platform: '', url: '', sort_order: 0, active: true });

async function load() {
  const { data } = await socialApi.getAllAdmin();
  links.value = data;
  loading.value = false;
}

function openModal(l = null) {
  saved.value = false;
  editingId.value = l ? l.link_id : null;
  form.value = l ? { platform: l.platform, url: l.url, sort_order: l.sort_order, active: !!l.active } : { platform: '', url: '', sort_order: 0, active: true };
  modalOpen.value = true;
}

async function save() {
  saving.value = true;
  try {
    if (editingId.value) await socialApi.update(editingId.value, form.value);
    else await socialApi.create(form.value);
    saved.value = true;
    await load();
    setTimeout(() => { modalOpen.value = false; }, 600);
  } catch {}
  saving.value = false;
}

async function deleteLink(id) {
  if (!confirm('Delete this link?')) return;
  await socialApi.delete(id);
  await load();
}

onMounted(load);
</script>

<style scoped>
.admin-page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
.actions-cell { display: flex; gap: 0.4rem; }
.badge-muted { background: rgba(102,102,102,0.15); color: var(--text-muted); border: 1px solid var(--border); }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
</style>
