<template>
  <div>
    <h2 style="margin-bottom: 1.5rem;">Content Editor</h2>

    <div class="page-tabs">
      <button
        v-for="page in pages"
        :key="page.key"
        class="tab-btn"
        :class="{ active: activePage === page.key }"
        @click="selectPage(page.key)"
      >{{ page.label }}</button>
    </div>

    <div v-if="loading" class="spinner"></div>
    <div v-else class="editor-wrap">
      <div class="editor-toolbar">
        <button class="tool-btn" @click="insertTag('h2')">H2</button>
        <button class="tool-btn" @click="insertTag('h3')">H3</button>
        <button class="tool-btn" @click="insertTag('p')">P</button>
        <button class="tool-btn" @click="insertTag('ul')">List</button>
        <button class="tool-btn" @click="insertTag('strong')"><b>B</b></button>
        <span class="tool-sep">|</span>
        <span class="tool-hint text-muted">HTML editor</span>
      </div>
      <textarea
        ref="editorRef"
        v-model="content"
        rows="18"
        class="html-editor"
        placeholder="Enter HTML content for this page…"
      ></textarea>
      <div class="editor-actions">
        <button class="btn-primary" @click="save" :disabled="saving">{{ saving ? 'Saving…' : 'Save Changes' }}</button>
        <span v-if="saved" class="alert alert-success" style="padding:0.5rem 1rem;display:inline-flex;">Saved!</span>
      </div>

      <div class="preview-section">
        <h4>Preview</h4>
        <div class="content-preview" v-html="content"></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { contentApi } from '@/api/index';

const pages = [
  { key: 'about', label: 'About Us' },
  { key: 'contact', label: 'Contact Us' },
  { key: 'shipping', label: 'Shipping Policy' },
  { key: 'terms', label: 'Terms & Conditions' },
];

const activePage = ref('about');
const content = ref('');
const loading = ref(false);
const saving = ref(false);
const saved = ref(false);
const editorRef = ref(null);

async function selectPage(key) {
  activePage.value = key;
  loading.value = true;
  try {
    const { data } = await contentApi.getPage(key);
    content.value = data.content_body || '';
  } catch { content.value = ''; }
  loading.value = false;
}

async function save() {
  saving.value = true;
  saved.value = false;
  try {
    await contentApi.updatePage(activePage.value, { content_body: content.value });
    saved.value = true;
    setTimeout(() => { saved.value = false; }, 2500);
  } catch {}
  saving.value = false;
}

function insertTag(tag) {
  const el = editorRef.value;
  if (!el) return;
  const start = el.selectionStart;
  const end = el.selectionEnd;
  const selected = content.value.slice(start, end);
  let insert;
  if (tag === 'ul') insert = `<ul>\n  <li>${selected || 'Item'}</li>\n</ul>`;
  else insert = `<${tag}>${selected || `Content`}</${tag}>`;
  content.value = content.value.slice(0, start) + insert + content.value.slice(end);
}

onMounted(() => selectPage('about'));
</script>

<style scoped>
.page-tabs { display: flex; gap: 0.5rem; margin-bottom: 1.5rem; flex-wrap: wrap; }
.tab-btn {
  padding: 0.55rem 1.1rem; border-radius: var(--radius);
  background: var(--bg-secondary); border: 1px solid var(--border);
  color: var(--text-secondary); font-size: 0.9rem; font-weight: 500;
}
.tab-btn.active { background: var(--green-glow); border-color: var(--green-border); color: var(--green-primary); }
.tab-btn:hover { color: var(--green-primary); }
.editor-toolbar { display: flex; gap: 0.4rem; align-items: center; padding: 0.6rem 0.75rem; background: var(--bg-secondary); border: 1px solid var(--border); border-bottom: none; border-radius: var(--radius) var(--radius) 0 0; }
.tool-btn { background: var(--bg-card); border: 1px solid var(--border); color: var(--text-secondary); padding: 0.3rem 0.6rem; border-radius: 4px; font-size: 0.8rem; }
.tool-btn:hover { color: var(--green-primary); border-color: var(--green-border); }
.tool-sep { color: var(--border); margin: 0 0.25rem; }
.tool-hint { font-size: 0.78rem; }
.html-editor {
  width: 100%; border-radius: 0 0 var(--radius) var(--radius);
  font-family: 'Consolas', 'Monaco', monospace; font-size: 0.875rem;
  line-height: 1.6; resize: vertical; border-top: none;
}
.editor-actions { display: flex; gap: 1rem; align-items: center; margin-top: 1rem; }
.preview-section { margin-top: 2rem; }
.preview-section h4 { font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--text-muted); margin-bottom: 0.75rem; }
.content-preview {
  background: var(--bg-card); border: 1px solid var(--border);
  border-radius: var(--radius-lg); padding: 2rem;
  color: var(--text-secondary); line-height: 1.8;
}
.content-preview :deep(h1), .content-preview :deep(h2), .content-preview :deep(h3) { color: var(--text-primary); margin-bottom: 0.5rem; margin-top: 1.5rem; }
.content-preview :deep(p) { margin-bottom: 1rem; }
.content-preview :deep(ul) { margin-left: 1.5rem; margin-bottom: 1rem; }
</style>
