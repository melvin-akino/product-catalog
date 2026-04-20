<template>
  <div class="gallery">
    <div class="main-image-wrap" @click="lightboxOpen = true">
      <img :src="activeImage" :alt="alt" class="main-image" @error="onImgError" />
      <span class="zoom-hint">🔍 Click to zoom</span>
    </div>
    <div class="thumbnails" v-if="images.length > 1">
      <button
        v-for="(img, i) in images"
        :key="i"
        class="thumb"
        :class="{ active: activeIndex === i }"
        @click="activeIndex = i"
      >
        <img :src="img" :alt="`${alt} ${i + 1}`" @error="onImgError" />
      </button>
    </div>

    <!-- Lightbox -->
    <Teleport to="body">
      <div v-if="lightboxOpen" class="lightbox" @click.self="lightboxOpen = false">
        <button class="lb-close" @click="lightboxOpen = false">✕</button>
        <button v-if="images.length > 1" class="lb-nav lb-prev" @click="prevImage">‹</button>
        <img :src="activeImage" :alt="alt" class="lb-image" />
        <button v-if="images.length > 1" class="lb-nav lb-next" @click="nextImage">›</button>
        <div class="lb-counter" v-if="images.length > 1">{{ activeIndex + 1 }} / {{ images.length }}</div>
      </div>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';

const props = defineProps({
  images: { type: Array, default: () => [] },
  alt: { type: String, default: 'Product image' },
});

const activeIndex = ref(0);
const lightboxOpen = ref(false);

const activeImage = computed(() => props.images[activeIndex.value] || '/placeholder.svg');

function prevImage() { activeIndex.value = (activeIndex.value - 1 + props.images.length) % props.images.length; }
function nextImage() { activeIndex.value = (activeIndex.value + 1) % props.images.length; }
function onImgError(e) { e.target.src = '/placeholder.svg'; }
</script>

<style scoped>
.gallery { display: flex; flex-direction: column; gap: 0.75rem; }
.main-image-wrap {
  position: relative; border-radius: var(--radius-lg); overflow: hidden;
  border: 1px solid var(--border); aspect-ratio: 4/3;
  background: var(--bg-secondary); cursor: zoom-in;
}
.main-image { width: 100%; height: 100%; object-fit: cover; transition: transform 0.4s ease; }
.main-image-wrap:hover .main-image { transform: scale(1.04); }
.zoom-hint {
  position: absolute; bottom: 0.75rem; right: 0.75rem;
  background: rgba(0,0,0,0.7); color: var(--text-secondary);
  font-size: 0.75rem; padding: 0.3rem 0.6rem; border-radius: var(--radius);
}
.thumbnails { display: flex; gap: 0.5rem; flex-wrap: wrap; }
.thumb {
  width: 72px; height: 72px; border-radius: var(--radius);
  overflow: hidden; border: 2px solid var(--border);
  background: var(--bg-secondary); padding: 0;
  transition: border-color 0.2s;
}
.thumb.active, .thumb:hover { border-color: var(--green-primary); }
.thumb img { width: 100%; height: 100%; object-fit: cover; }

.lightbox {
  position: fixed; inset: 0; background: rgba(0,0,0,0.93);
  display: flex; align-items: center; justify-content: center;
  z-index: 2000; padding: 2rem;
}
.lb-image { max-width: 90vw; max-height: 85vh; object-fit: contain; border-radius: var(--radius); }
.lb-close {
  position: absolute; top: 1.5rem; right: 1.5rem;
  background: var(--bg-card); color: var(--text-primary);
  width: 40px; height: 40px; border-radius: 50%;
  font-size: 1.1rem; font-weight: 700;
}
.lb-nav {
  position: absolute; top: 50%; transform: translateY(-50%);
  background: var(--bg-card); color: var(--text-primary);
  width: 48px; height: 48px; border-radius: 50%;
  font-size: 1.8rem; display: flex; align-items: center; justify-content: center;
}
.lb-prev { left: 1.5rem; }
.lb-next { right: 1.5rem; }
.lb-nav:hover { background: var(--green-glow); color: var(--green-primary); }
.lb-counter { position: absolute; bottom: 1.5rem; left: 50%; transform: translateX(-50%); color: var(--text-muted); font-size: 0.85rem; }
</style>
