<template>
  <RouterLink :to="`/catalog/${product.slug || product.product_id}`" class="product-card">
    <div class="card-image-wrap">
      <img
        :src="mainImage"
        :alt="product.name"
        class="card-image"
        loading="lazy"
        @error="onImgError"
      />
      <div class="card-overlay">
        <span class="view-btn">
          <Eye :size="15" /> View Details
        </span>
      </div>
      <span v-if="product.featured" class="ribbon">
        <Star :size="10" fill="currentColor" /> Featured
      </span>
      <span class="category-chip">{{ product.category_name || 'General' }}</span>
    </div>
    <div class="card-body">
      <h3 class="card-title">{{ product.name }}</h3>
      <p class="card-desc">{{ product.description }}</p>
      <div class="card-footer">
        <span class="inquire-hint">
          <MessageCircle :size="13" /> Inquire for pricing
        </span>
        <ArrowRight :size="16" class="arrow" />
      </div>
    </div>
  </RouterLink>
</template>

<script setup>
import { computed } from 'vue';
import { RouterLink } from 'vue-router';
import { Eye, Star, ArrowRight, MessageCircle } from 'lucide-vue-next';

const props = defineProps({ product: { type: Object, required: true } });

const mainImage = computed(() => {
  const imgs = props.product.images;
  if (!imgs) return '/placeholder.svg';
  const parsed = typeof imgs === 'string' ? JSON.parse(imgs) : imgs;
  return (parsed && parsed[0]) ? parsed[0] : '/placeholder.svg';
});

function onImgError(e) { e.target.src = '/placeholder.svg'; }
</script>

<style scoped>
.product-card {
  display: flex; flex-direction: column;
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  overflow: hidden;
  text-decoration: none; color: inherit;
  transition: border-color 0.25s, box-shadow 0.25s, transform 0.25s;
}
.product-card:hover {
  border-color: var(--green-border);
  box-shadow: 0 8px 32px rgba(0,0,0,0.4), var(--shadow-green);
  transform: translateY(-4px);
}

/* Image */
.card-image-wrap {
  position: relative; overflow: hidden;
  aspect-ratio: 4/3; background: var(--bg-secondary);
}
.card-image { width: 100%; height: 100%; object-fit: cover; transition: transform 0.45s ease; }
.product-card:hover .card-image { transform: scale(1.06); }

/* Overlay */
.card-overlay {
  position: absolute; inset: 0;
  background: linear-gradient(135deg, rgba(0,230,118,0.15), rgba(0,0,0,0.4));
  display: flex; align-items: center; justify-content: center;
  opacity: 0; transition: opacity 0.25s;
}
.product-card:hover .card-overlay { opacity: 1; }
.view-btn {
  display: flex; align-items: center; gap: 0.4rem;
  background: var(--green-primary); color: #000;
  font-weight: 700; padding: 0.55rem 1.1rem;
  border-radius: var(--radius); font-size: 0.85rem;
}

/* Ribbon */
.ribbon {
  position: absolute; top: 0.65rem; right: 0.65rem;
  display: flex; align-items: center; gap: 0.3rem;
  background: var(--green-primary); color: #000;
  font-size: 0.65rem; font-weight: 700; letter-spacing: 0.05em;
  padding: 0.25rem 0.6rem; border-radius: 999px;
  text-transform: uppercase;
}

/* Category chip */
.category-chip {
  position: absolute; bottom: 0.65rem; left: 0.65rem;
  background: rgba(0,0,0,0.72); backdrop-filter: blur(8px);
  color: var(--green-primary); font-size: 0.68rem;
  font-weight: 600; letter-spacing: 0.08em; text-transform: uppercase;
  padding: 0.2rem 0.6rem; border-radius: 999px;
  border: 1px solid var(--green-border);
}

/* Body */
.card-body { padding: 1.1rem 1.1rem 1rem; display: flex; flex-direction: column; flex: 1; }
.card-title {
  font-size: 0.98rem; font-weight: 700;
  margin-bottom: 0.4rem; line-height: 1.35;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}
.card-desc {
  font-size: 0.82rem; color: var(--text-muted); flex: 1; line-height: 1.6;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
  margin-bottom: 0.85rem;
}
.card-footer {
  display: flex; justify-content: space-between; align-items: center;
  padding-top: 0.75rem; border-top: 1px solid var(--border);
}
.inquire-hint {
  display: flex; align-items: center; gap: 0.35rem;
  font-size: 0.78rem; color: var(--text-muted);
}
.arrow { color: var(--green-primary); transition: transform 0.2s; }
.product-card:hover .arrow { transform: translateX(4px); }
</style>
