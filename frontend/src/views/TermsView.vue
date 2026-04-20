<template>
  <div>
    <NavBar />
    <div class="page-hero">
      <div class="container">
        <h1>Terms &amp; <span class="text-green">Conditions</span></h1>
        <div class="accent-line" style="margin: 0.75rem auto 0;"></div>
      </div>
    </div>
    <div class="container section">
      <div v-if="loading" class="spinner"></div>
      <div v-else class="content-body" v-html="content"></div>
    </div>
    <AppFooter />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import NavBar from '@/components/NavBar.vue';
import AppFooter from '@/components/AppFooter.vue';
import { contentApi } from '@/api/index';

const content = ref('');
const loading = ref(true);

onMounted(async () => {
  try { const { data } = await contentApi.getPage('terms'); content.value = data.content_body; } catch {}
  loading.value = false;
});
</script>

<style scoped>
.content-body { max-width: 800px; margin: 0 auto; line-height: 1.8; color: var(--text-secondary); }
.content-body :deep(h1), .content-body :deep(h2), .content-body :deep(h3) { color: var(--text-primary); margin-bottom: 0.75rem; margin-top: 2rem; }
.content-body :deep(p) { margin-bottom: 1.25rem; }
.content-body :deep(ul) { margin-left: 1.5rem; margin-bottom: 1.25rem; }
</style>
