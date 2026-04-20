<template>
  <div>
    <div class="admin-page-header">
      <h2>SEO Manager</h2>
      <a :href="`/api/seo/sitemap/xml`" target="_blank" class="btn-outline">🗺 Generate Sitemap</a>
    </div>

    <div class="page-tabs">
      <button v-for="p in pages" :key="p" class="tab-btn" :class="{ active: activePage === p }" @click="selectPage(p)">{{ p }}</button>
    </div>

    <div v-if="loading" class="spinner"></div>
    <div v-else class="form-card">
      <div v-if="saved" class="alert alert-success">SEO settings saved!</div>
      <div v-if="err" class="alert alert-error">{{ err }}</div>
      <div class="form-group"><label>Page Name</label><input :value="activePage" disabled /></div>
      <div class="form-group"><label>Meta Title (50–60 chars recommended)</label>
        <input v-model="form.meta_title" :maxlength="80" placeholder="Page title for search engines" />
        <small class="text-muted">{{ form.meta_title?.length || 0 }} / 80 chars</small>
      </div>
      <div class="form-group"><label>Meta Description (120–160 chars recommended)</label>
        <textarea v-model="form.meta_description" :maxlength="200" rows="3" placeholder="Brief description for search results"></textarea>
        <small class="text-muted">{{ form.meta_description?.length || 0 }} / 200 chars</small>
      </div>
      <div class="form-group"><label>Keywords (comma-separated)</label>
        <input v-model="keywordsText" placeholder="keyword1, keyword2, keyword3" />
      </div>
      <div class="form-group"><label>OG Image URL</label>
        <input v-model="form.og_image" type="url" placeholder="https://…/og-image.jpg" />
      </div>

      <div class="seo-preview">
        <h4>Search Preview</h4>
        <div class="serp-card">
          <div class="serp-url">yoursite.com / {{ activePage }}</div>
          <div class="serp-title">{{ form.meta_title || 'Page Title' }}</div>
          <div class="serp-desc">{{ form.meta_description || 'Meta description will appear here…' }}</div>
        </div>
      </div>

      <button class="btn-primary" @click="save" :disabled="saving">{{ saving ? 'Saving…' : 'Save SEO Settings' }}</button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { seoApi } from '@/api/index';

const pages = ['home', 'catalog', 'about', 'contact', 'shipping', 'terms'];
const activePage = ref('home');
const form = ref({ meta_title: '', meta_description: '', og_image: '' });
const keywordsText = ref('');
const loading = ref(false);
const saving = ref(false);
const saved = ref(false);
const err = ref('');
const editingId = ref(null);

async function selectPage(page) {
  activePage.value = page;
  loading.value = true;
  form.value = { meta_title: '', meta_description: '', og_image: '' };
  keywordsText.value = '';
  editingId.value = null;
  try {
    const { data } = await seoApi.getPage(page);
    form.value = { meta_title: data.meta_title || '', meta_description: data.meta_description || '', og_image: data.og_image || '' };
    const kw = typeof data.keywords === 'string' ? JSON.parse(data.keywords) : data.keywords;
    keywordsText.value = Array.isArray(kw) ? kw.join(', ') : '';
    editingId.value = data.seo_id;
  } catch {}
  loading.value = false;
}

async function save() {
  saving.value = true; saved.value = false; err.value = '';
  const keywords = keywordsText.value.split(',').map(k => k.trim()).filter(Boolean);
  const payload = { page_name: activePage.value, ...form.value, keywords };
  try {
    if (editingId.value) await seoApi.update(editingId.value, payload);
    else { const { data } = await seoApi.create(payload); editingId.value = data.seo_id; }
    saved.value = true;
    setTimeout(() => { saved.value = false; }, 2500);
  } catch (e) { err.value = e.response?.data?.error || 'Failed to save.'; }
  saving.value = false;
}

onMounted(() => selectPage('home'));
</script>

<style scoped>
.admin-page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
.page-tabs { display: flex; gap: 0.5rem; margin-bottom: 1.5rem; flex-wrap: wrap; }
.tab-btn { padding: 0.5rem 1rem; border-radius: var(--radius); background: var(--bg-secondary); border: 1px solid var(--border); color: var(--text-secondary); font-size: 0.875rem; }
.tab-btn.active { background: var(--green-glow); border-color: var(--green-border); color: var(--green-primary); }
.form-card { background: var(--bg-card); border: 1px solid var(--border); border-radius: var(--radius-lg); padding: 2rem; max-width: 720px; }
.seo-preview { margin: 1.5rem 0; }
.seo-preview h4 { font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--text-muted); margin-bottom: 0.75rem; }
.serp-card { background: var(--bg-secondary); border: 1px solid var(--border); border-radius: var(--radius); padding: 1.25rem 1.5rem; }
.serp-url { font-size: 0.8rem; color: #8ab4f8; margin-bottom: 0.25rem; }
.serp-title { font-size: 1.05rem; color: #8ab4f8; font-weight: 600; margin-bottom: 0.35rem; }
.serp-desc { font-size: 0.875rem; color: var(--text-muted); line-height: 1.5; }
</style>
