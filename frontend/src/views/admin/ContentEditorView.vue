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
      <QuillEditor
        v-model:content="content"
        content-type="html"
        :toolbar="toolbar"
        :modules="quillModules"
        theme="snow"
        class="content-editor"
        @ready="onEditorReady"
      />
      <div class="table-insert-bar">
        <span class="table-insert-label">Insert table:</span>
        <input v-model.number="tableRows" type="number" min="1" max="10" class="table-dim-input" />
        <span class="table-insert-label">×</span>
        <input v-model.number="tableCols" type="number" min="1" max="10" class="table-dim-input" />
        <button class="btn-outline btn-sm" @click="insertTable">Insert Table</button>
      </div>
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
import { QuillEditor } from '@vueup/vue-quill';
import Table from 'quill/modules/table.js';
import { contentApi } from '@/api/index';

const toolbar = [
  [{ header: [2, 3, 4, false] }],
  ['bold', 'italic', 'underline'],
  [{ list: 'ordered' }, { list: 'bullet' }],
  ['link'],
  ['clean'],
];

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
const quillModules = [{ name: 'table', module: Table, options: {} }];
const editorQuill = ref(null);
const tableRows = ref(3);
const tableCols = ref(3);

function onEditorReady(quill) { editorQuill.value = quill; }
function insertTable() {
  if (!editorQuill.value) return;
  editorQuill.value.getModule('table').insertTable(tableRows.value, tableCols.value);
}

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

/* Quill dark theme overrides */
.content-editor :deep(.ql-toolbar) {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius) var(--radius) 0 0;
}
.content-editor :deep(.ql-container) {
  background: var(--surface);
  border: 1px solid var(--border);
  border-top: none;
  border-radius: 0 0 var(--radius) var(--radius);
  min-height: 280px;
  font-family: inherit;
  font-size: 0.9rem;
  color: var(--text);
}
.content-editor :deep(.ql-editor) { min-height: 260px; }
.content-editor :deep(.ql-toolbar .ql-stroke) { stroke: var(--text-secondary); }
.content-editor :deep(.ql-toolbar .ql-fill) { fill: var(--text-secondary); }
.content-editor :deep(.ql-toolbar .ql-picker) { color: var(--text-secondary); }
.content-editor :deep(.ql-toolbar .ql-picker-options) {
  background: var(--bg-card);
  border-color: var(--border);
}
.content-editor :deep(.ql-toolbar button:hover .ql-stroke),
.content-editor :deep(.ql-toolbar button.ql-active .ql-stroke) { stroke: var(--green-primary); }
.content-editor :deep(.ql-toolbar button:hover .ql-fill),
.content-editor :deep(.ql-toolbar button.ql-active .ql-fill) { fill: var(--green-primary); }
.content-editor :deep(.ql-editor h2),
.content-editor :deep(.ql-editor h3),
.content-editor :deep(.ql-editor h4) { color: var(--text); }
.content-editor :deep(.ql-editor a) { color: var(--green-primary); }
.content-editor :deep(.ql-editor table) {
  border-collapse: collapse; width: 100%; margin: 0.5rem 0;
}
.content-editor :deep(.ql-editor td) {
  border: 1px solid var(--border); padding: 0.4rem 0.6rem;
  min-width: 80px; color: var(--text);
}

.table-insert-bar {
  display: flex; align-items: center; gap: 0.5rem;
  margin-top: 0.5rem; flex-wrap: wrap;
}
.table-insert-label { font-size: 0.8rem; color: var(--text-muted); }
.table-dim-input {
  width: 52px; text-align: center; padding: 0.25rem 0.4rem;
  font-size: 0.85rem;
}
</style>
