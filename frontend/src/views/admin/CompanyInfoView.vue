<template>
  <div>
    <h2 style="margin-bottom: 1.5rem;">Company Information</h2>
    <div v-if="loading" class="spinner"></div>
    <div v-else class="form-card">
      <div v-if="saved" class="alert alert-success">Company information updated!</div>
      <div v-if="err" class="alert alert-error">{{ err }}</div>
      <div class="form-group"><label>Company Name *</label><input v-model="form.name" placeholder="Your company name" /></div>
      <div class="form-group"><label>Tagline</label><input v-model="form.tagline" placeholder="Your tagline or slogan" /></div>
      <div class="form-row">
        <div class="form-group"><label>Phone</label><input v-model="form.phone" placeholder="+1 (555) 000-0000" /></div>
        <div class="form-group"><label>Email</label><input v-model="form.email" type="email" placeholder="info@company.com" /></div>
      </div>
      <div class="form-group"><label>Address</label><textarea v-model="form.address" rows="2" placeholder="Full address"></textarea></div>
      <div class="form-group"><label>Logo URL</label><input v-model="form.logo_url" placeholder="https://…/logo.png" /></div>
      <div v-if="form.logo_url" class="logo-preview">
        <img :src="form.logo_url" alt="Logo preview" style="max-height:80px;" />
      </div>
      <button class="btn-primary" @click="save" :disabled="saving">{{ saving ? 'Saving…' : 'Save Changes' }}</button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { companyApi } from '@/api/index';

const form = ref({ name: '', tagline: '', phone: '', email: '', address: '', logo_url: '' });
const loading = ref(true);
const saving = ref(false);
const saved = ref(false);
const err = ref('');

onMounted(async () => {
  try { const { data } = await companyApi.get(); Object.assign(form.value, data); } catch {}
  loading.value = false;
});

async function save() {
  saving.value = true; saved.value = false; err.value = '';
  try { await companyApi.update(form.value); saved.value = true; setTimeout(() => { saved.value = false; }, 2500); }
  catch (e) { err.value = e.response?.data?.error || 'Failed to save.'; }
  saving.value = false;
}
</script>

<style scoped>
.form-card { background: var(--bg-card); border: 1px solid var(--border); border-radius: var(--radius-lg); padding: 2rem; max-width: 680px; }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
.logo-preview { margin-bottom: 1.25rem; padding: 1rem; background: var(--bg-secondary); border-radius: var(--radius); border: 1px solid var(--border); display: inline-block; }
</style>
