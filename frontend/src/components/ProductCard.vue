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
        <span class="view-btn">View Details →</span>
      </div>
      <span v-if="product.featured" class="featured-badge badge badge-green">Featured</span>
    </div>
    <div class="card-body">
      <span class="category-tag">{{ product.category_name || 'Uncategorized' }}</span>
      <h3 class="card-title">{{ product.name }}</h3>
      <p class="card-desc">{{ truncatedDesc }}</p>
      <div class="card-footer">
        <span class="inquire-hint">Inquire for pricing</span>
        <span class="arrow">→</span>
      </div>
    </div>
  </RouterLink>
</template>

<script setup>
import { computed } from 'vue';
import { RouterLink } from 'vue-router';

const props = defineProps({ product: { type: Object, required: true } });

const mainImage = computed(() => {
  const imgs = props.product.images;
  if (!imgs) return '/placeholder.svg';
  const parsed = typeof imgs === 'string' ? JSON.parse(imgs) : imgs;
  return (parsed && parsed[0]) ? parsed[0] : '/placeholder.svg';
});

const truncatedDesc = computed(() => {
  const d = props.product.description || '';
  return d.length > 100 ? d.slice(0, 100) + '…' : d;
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
  transition: all 0.3s ease;
}
.product-card:hover {
  border-color: var(--green-border);
  box-shadow: var(--shadow-green);
  transform: translateY(-5px);
}
.card-image-wrap { position: relative; overflow: hidden; aspect-ratio: 4/3; background: var(--bg-secondary); }
.card-image {
  width: 100%; height: 100%; object-fit: cover;
  transition: transform 0.4s ease;
}
.product-card:hover .card-image { transform: scale(1.07); }
.card-overlay {
  position: absolute; inset: 0;
  background: rgba(0, 230, 118, 0.12);
  display: flex; align-items: center; justify-content: center;
  opacity: 0; transition: opacity 0.3s;
}
.product-card:hover .card-overlay { opacity: 1; }
.view-btn {
  background: var(--green-primary); color: #000;
  font-weight: 700; padding: 0.6rem 1.2rem;
  border-radius: var(--radius); font-size: 0.9rem;
}
.featured-badge { position: absolute; top: 0.75rem; left: 0.75rem; }
.card-body { padding: 1.25rem; display: flex; flex-direction: column; flex: 1; }
.category-tag { font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.1em; color: var(--green-primary); font-weight: 600; margin-bottom: 0.4rem; }
.card-title { font-size: 1.05rem; font-weight: 700; margin-bottom: 0.5rem; line-height: 1.35; }
.card-desc { font-size: 0.85rem; color: var(--text-muted); flex: 1; line-height: 1.55; }
.card-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 1rem; padding-top: 0.75rem; border-top: 1px solid var(--border); }
.inquire-hint { font-size: 0.8rem; color: var(--text-muted); }
.arrow { color: var(--green-primary); font-weight: 700; transition: transform 0.2s; }
.product-card:hover .arrow { transform: translateX(4px); }
</style>
