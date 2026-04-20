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

      <!-- ── Logo Manager ───────────────────────────── -->
      <div class="form-group">
        <label>Company Logo</label>

        <!-- Source toggle -->
        <div class="logo-source-tabs">
          <button
            class="source-tab"
            :class="{ active: form.logo_source === 'url' }"
            @click="form.logo_source = 'url'"
          >🔗 URL</button>
          <button
            class="source-tab"
            :class="{ active: form.logo_source === 'upload' }"
            @click="form.logo_source = 'upload'"
          >📁 Uploaded File</button>
        </div>

        <!-- URL input -->
        <div v-if="form.logo_source === 'url'" class="logo-input-section">
          <input v-model="form.logo_url" placeholder="https://example.com/logo.png" />
          <small class="text-muted">Paste the full URL to your logo image.</small>
        </div>

        <!-- Upload section -->
        <div v-else class="logo-input-section">
          <div
            class="upload-zone"
            :class="{ dragging: isDragging }"
            @dragover.prevent="isDragging = true"
            @dragleave="isDragging = false"
            @drop.prevent="onDrop"
            @click="$refs.logoFileInput.click()"
          >
            <input ref="logoFileInput" type="file" accept="image/*" hidden @change="onFilePick" />
            <span v-if="uploading" class="upload-text">Uploading…</span>
            <span v-else class="upload-text">
              <strong>Click to browse</strong> or drag &amp; drop your logo here
              <em>(JPG, PNG, WebP, SVG — max 5 MB)</em>
            </span>
          </div>
          <div v-if="form.logo_upload" class="uploaded-path">
            <span class="path-label">Current file:</span>
            <code>{{ form.logo_upload }}</code>
            <button class="clear-btn" @click="form.logo_upload = ''" title="Remove uploaded logo">✕</button>
          </div>
        </div>

        <!-- Live preview -->
        <div v-if="activeLogo" class="logo-preview">
          <span class="preview-label">Preview</span>
          <img :src="activeLogo" alt="Logo preview" @error="onPreviewError" />
          <span class="preview-source-badge">Using: {{ form.logo_source === 'upload' ? 'Uploaded file' : 'URL' }}</span>
        </div>
        <p v-else class="text-muted preview-empty">No logo set — the text logo will be shown in the header.</p>
      </div>
      <!-- ── / Logo Manager ──────────────────────────── -->

      <button class="btn-primary" @click="save" :disabled="saving">{{ saving ? 'Saving…' : 'Save Changes' }}</button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { companyApi, uploadApi } from '@/api/index';

const form = ref({ name: '', tagline: '', phone: '', email: '', address: '', logo_url: '', logo_upload: '', logo_source: 'url' });
const loading = ref(true);
const saving = ref(false);
const saved = ref(false);
const err = ref('');
const isDragging = ref(false);
const uploading = ref(false);
const logoFileInput = ref(null);

const activeLogo = computed(() => {
  if (form.value.logo_source === 'upload') return form.value.logo_upload || '';
  return form.value.logo_url || '';
});

function onPreviewError(e) { e.target.style.display = 'none'; }

async function uploadLogo(file) {
  uploading.value = true;
  err.value = '';
  try {
    const { data } = await uploadApi.uploadImages([file]);
    form.value.logo_upload = data.urls[0];
    form.value.logo_source = 'upload';
  } catch (e) {
    err.value = e.response?.data?.error || 'Upload failed. Check file size and format.';
  }
  uploading.value = false;
}

function onFilePick(e) {
  const file = e.target.files[0];
  if (file) uploadLogo(file);
  e.target.value = '';
}

function onDrop(e) {
  isDragging.value = false;
  const file = e.dataTransfer.files[0];
  if (file) uploadLogo(file);
}

onMounted(async () => {
  try {
    const { data } = await companyApi.get();
    Object.assign(form.value, {
      name: data.name || '',
      tagline: data.tagline || '',
      phone: data.phone || '',
      email: data.email || '',
      address: data.address || '',
      logo_url: data.logo_url || '',
      logo_upload: data.logo_upload || '',
      logo_source: data.logo_source || 'url',
    });
  } catch {}
  loading.value = false;
});

async function save() {
  saving.value = true; saved.value = false; err.value = '';
  try {
    await companyApi.update(form.value);
    saved.value = true;
    setTimeout(() => { saved.value = false; }, 2500);
  } catch (e) {
    err.value = e.response?.data?.error || 'Failed to save.';
  }
  saving.value = false;
}
</script>

<style scoped>
.form-card { background: var(--bg-card); border: 1px solid var(--border); border-radius: var(--radius-lg); padding: 2rem; max-width: 680px; }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }

/* Logo source tabs */
.logo-source-tabs { display: flex; gap: 0; margin-bottom: 0.75rem; border: 1px solid var(--border); border-radius: var(--radius); overflow: hidden; width: fit-content; }
.source-tab {
  padding: 0.45rem 1rem; font-size: 0.85rem; font-weight: 600;
  background: var(--bg-secondary); color: var(--text-muted);
  cursor: pointer; border: none; transition: all 0.15s;
}
.source-tab.active { background: var(--green-glow); color: var(--green-primary); }
.source-tab:first-child { border-right: 1px solid var(--border); }

.logo-input-section { display: flex; flex-direction: column; gap: 0.4rem; }

/* Upload zone */
.upload-zone {
  border: 2px dashed var(--border); border-radius: var(--radius);
  padding: 1.25rem; text-align: center; cursor: pointer;
  transition: border-color 0.2s, background 0.2s;
}
.upload-zone:hover, .upload-zone.dragging {
  border-color: var(--green-primary); background: var(--green-glow);
}
.upload-text {
  font-size: 0.85rem; color: var(--text-secondary);
  display: flex; flex-direction: column; gap: 0.25rem; align-items: center;
}
.upload-text strong { color: var(--green-primary); }
.upload-text em { color: var(--text-muted); font-style: normal; font-size: 0.78rem; }

/* Uploaded file path display */
.uploaded-path {
  display: flex; align-items: center; gap: 0.5rem;
  background: var(--bg-secondary); padding: 0.4rem 0.75rem;
  border-radius: var(--radius); border: 1px solid var(--border);
  font-size: 0.82rem;
}
.path-label { color: var(--text-muted); white-space: nowrap; }
.uploaded-path code { color: var(--green-primary); flex: 1; word-break: break-all; }
.clear-btn { background: none; color: var(--text-muted); font-size: 0.8rem; cursor: pointer; flex-shrink: 0; }
.clear-btn:hover { color: #ef5350; }

/* Preview */
.logo-preview {
  margin-top: 0.75rem; padding: 1.25rem;
  background: var(--bg-secondary); border: 1px solid var(--border);
  border-radius: var(--radius); display: flex; flex-direction: column; align-items: flex-start; gap: 0.5rem;
}
.preview-label { font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.08em; color: var(--text-muted); font-weight: 700; }
.logo-preview img { max-height: 80px; max-width: 260px; object-fit: contain; }
.preview-source-badge { font-size: 0.75rem; color: var(--green-secondary); font-weight: 600; }
.preview-empty { font-size: 0.85rem; margin-top: 0.5rem; }
</style>
